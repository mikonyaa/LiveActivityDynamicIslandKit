#!/bin/bash
set -euo pipefail

# Usage (from any directory):
#   Tools/check-external-consumer.sh remote [new-consumer-directory]
#   Tools/check-external-consumer.sh local [new-consumer-directory] [package-directory]
# Both modes create a fresh package outside the repository, with isolated SwiftPM
# configuration/cache. Remote always resolves the public exact 0.1.0 dependency.
# The directory is retained, including evidence, even if a command fails.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
repo_dir="$(cd "$script_dir/.." && pwd -P)"
fixture_dir="$script_dir/ExternalConsumer"
mode="${1:-}"
if [[ "$mode" != remote && "$mode" != local ]] || [[ $# -gt 3 ]]; then
    echo "Usage: $0 {remote|local} [new-consumer-directory] [local-package-directory]" >&2
    exit 2
fi
if [[ "$mode" == remote && $# -gt 2 ]]; then
    echo "Remote mode does not accept a local package override." >&2
    exit 2
fi

if [[ -n "${2:-}" ]]; then
    if [[ -e "$2" || -L "$2" ]]; then
        echo "Consumer directory already exists; choose a new directory: $2" >&2
        exit 2
    fi
    consumer_dir="$(python3 - "$2" <<'PY'
import pathlib
import sys
print(pathlib.Path(sys.argv[1]).resolve())
PY
)"
else
    consumer_dir="$(mktemp -d "$(dirname "$repo_dir")/consumer-${mode}-XXXXXX")"
fi
case "$consumer_dir/" in
    "$repo_dir/"*)
        echo "Consumer must be outside the repository: $consumer_dir" >&2
        exit 2
        ;;
esac

mkdir -p "$consumer_dir"
mkdir -p "$consumer_dir/Sources" "$consumer_dir/evidence"
stage="prepare"
record_status() {
    task_exit_code=$?
    python3 - "$consumer_dir/evidence/status.json" "$mode" "$stage" "$task_exit_code" <<'PY'
import datetime
import json
import pathlib
import sys

path, mode, stage, exit_code = sys.argv[1:]
status = {
    'mode': mode, 'stage': stage, 'exitCode': int(exit_code),
    'completedAt': datetime.datetime.now(datetime.timezone.utc).isoformat(),
}
pathlib.Path(path).write_text(json.dumps(status, indent=2, sort_keys=True) + '\n')
PY
}
trap record_status EXIT
cp -R "$fixture_dir/Sources/ConsumerProbe" "$consumer_dir/Sources/"
package_dir=""
if [[ "$mode" == remote ]]; then
    cp "$fixture_dir/Package.remote.swift" "$consumer_dir/Package.swift"
else
    package_dir="$(cd "${3:-$repo_dir}" && pwd -P)"
    test -f "$package_dir/Package.swift"
    python3 - "$fixture_dir/Package.local.swift.in" "$consumer_dir/Package.swift" "$package_dir" <<'PY'
import pathlib
import sys

template, destination, package = sys.argv[1:]
def swift_literal(value):
    return '"' + value.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t') + '"'
identity = pathlib.Path(package).name.removesuffix('.git').lower()
manifest = pathlib.Path(template).read_text().replace('__LOCAL_PACKAGE_PATH__', swift_literal(package))
manifest = manifest.replace('__LOCAL_PACKAGE_IDENTITY__', swift_literal(identity))
pathlib.Path(destination).write_text(manifest)
PY
fi

echo "External consumer ($mode): $consumer_dir"
task_developer_dir="${DEVELOPER_DIR:-$(xcode-select -p)}"
stage="toolchain"
(
    date -u '+%Y-%m-%dT%H:%M:%SZ'
    sw_vers
    swift --version
    xcrun --find swift
    xcrun --sdk macosx --show-sdk-version
    /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' \
        "$task_developer_dir/../Info.plist"
    /usr/libexec/PlistBuddy -c 'Print :ProductBuildVersion' \
        "$task_developer_dir/../version.plist"
) 2>&1 | tee "$consumer_dir/evidence/tools.log"

python3 - "$mode" "$package_dir" "$consumer_dir" <<'PY'
import hashlib
import json
import pathlib
import subprocess
import sys

mode, package, consumer = sys.argv[1:]
root = pathlib.Path(consumer)
record = {'mode': mode, 'consumerDirectory': str(root), 'localPackageDirectory': package or None}
inputs = [root / 'Package.swift', *sorted((root / 'Sources').rglob('*.swift'))]
record['consumerInputSHA256'] = {
    str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest() for path in inputs
}
if package:
    package_root = pathlib.Path(package)
    result = subprocess.run(['git', '-C', package, 'rev-parse', 'HEAD'], capture_output=True, text=True)
    record['localPackageHEAD'] = result.stdout.strip() if result.returncode == 0 else None
    record['localPackageInputSHA256'] = {
        str(path.relative_to(package_root)): hashlib.sha256(path.read_bytes()).hexdigest()
        for path in [package_root / 'Package.swift', *sorted((package_root / 'Sources').rglob('*.swift'))]
    }
else:
    record['remoteURL'] = 'https://github.com/mikonyaa/LiveActivityDynamicIslandKit.git'
    record['remoteExactVersion'] = '0.1.0'
(root / 'evidence' / 'inputs.json').write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')
PY

spm_paths=(--package-path "$consumer_dir" --scratch-path "$consumer_dir/.build"
    --cache-path "$consumer_dir/.swiftpm/cache" --config-path "$consumer_dir/.swiftpm/config"
    --security-path "$consumer_dir/.swiftpm/security")
stage="resolve"
swift package "${spm_paths[@]}" resolve 2>&1 | tee "$consumer_dir/evidence/resolve.log"
stage="dependency-provenance"
swift package "${spm_paths[@]}" show-dependencies --format json > "$consumer_dir/evidence/dependencies.json"
if [[ "$mode" == remote ]]; then
    cp "$consumer_dir/Package.resolved" "$consumer_dir/evidence/Package.resolved"
    python3 - "$consumer_dir/Package.resolved" <<'PY'
import json
import pathlib
import sys

pins = json.loads(pathlib.Path(sys.argv[1]).read_text())['pins']
expected_url = 'https://github.com/mikonyaa/LiveActivityDynamicIslandKit.git'
assert len(pins) == 1, f'Expected exactly one public dependency, found {pins!r}'
pin = pins[0]
assert pin['kind'] == 'remoteSourceControl', pin
assert pin['location'] == expected_url, pin
assert pin['state']['version'] == '0.1.0', pin
assert pin['state']['revision'], pin
print(f"Verified remote exact 0.1.0 at {pin['state']['revision']}")
PY
else
    python3 - "$consumer_dir/evidence/dependencies.json" "$package_dir" <<'PY'
import json
import pathlib
import sys

graph = json.loads(pathlib.Path(sys.argv[1]).read_text())
dependencies = graph['dependencies']
assert len(dependencies) == 1, dependencies
assert pathlib.Path(dependencies[0]['path']).resolve() == pathlib.Path(sys.argv[2]).resolve(), dependencies
print(f"Verified local package path: {dependencies[0]['path']}")
PY
fi
stage="build"
swift build "${spm_paths[@]}" 2>&1 | tee "$consumer_dir/evidence/build.log"
stage="public-api-probe"
swift run "${spm_paths[@]}" --skip-build ConsumerProbe \
    > "$consumer_dir/evidence/public-api.json" 2> "$consumer_dir/evidence/run.log"
stage="input-stability"
python3 - "$consumer_dir/evidence/inputs.json" <<'PY'
import hashlib
import json
import pathlib
import sys

record = json.loads(pathlib.Path(sys.argv[1]).read_text())
for root_key, hashes_key in [('consumerDirectory', 'consumerInputSHA256'),
                             ('localPackageDirectory', 'localPackageInputSHA256')]:
    if not record.get(root_key):
        continue
    root = pathlib.Path(record[root_key])
    changed = [name for name, digest in record[hashes_key].items()
               if hashlib.sha256((root / name).read_bytes()).hexdigest() != digest]
    if changed:
        raise SystemExit(f'Inputs changed during verification; repeat in a fresh consumer: {changed}')
PY
cat "$consumer_dir/evidence/public-api.json"
stage="complete"
echo "External consumer passed ($mode); evidence: $consumer_dir/evidence"
