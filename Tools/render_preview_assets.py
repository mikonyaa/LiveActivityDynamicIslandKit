from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SCREENSHOTS = ROOT / "Assets" / "Screenshots"

FONT_REGULAR = "/System/Library/Fonts/SFNS.ttf"
FONT_ROUNDED = "/System/Library/Fonts/SFNSRounded.ttf"


def font(size: int, rounded: bool = False) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(FONT_ROUNDED if rounded else FONT_REGULAR, size=size)
    except OSError:
        return ImageFont.load_default(size=size)


def shadowed_round_rect(
    image: Image.Image,
    rect: tuple[int, int, int, int],
    radius: int,
    fill: tuple[int, int, int, int],
    shadow: tuple[int, int, int, int] = (0, 0, 0, 36),
    blur: int = 28,
    offset: tuple[int, int] = (0, 14),
    outline: tuple[int, int, int, int] | None = None,
    width: int = 1,
) -> None:
    layer = Image.new("RGBA", image.size, (0, 0, 0, 0))
    mask = Image.new("L", image.size, 0)
    mask_draw = ImageDraw.Draw(mask)
    shifted = (rect[0] + offset[0], rect[1] + offset[1], rect[2] + offset[0], rect[3] + offset[1])
    mask_draw.rounded_rectangle(shifted, radius=radius, fill=255)
    blurred = mask.filter(ImageFilter.GaussianBlur(blur))
    layer.paste(shadow, mask=blurred)
    image.alpha_composite(layer)

    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(rect, radius=radius, fill=fill)
    if outline:
        draw.rounded_rectangle(rect, radius=radius, outline=outline, width=width)


def text(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    value: str,
    size: int,
    fill: tuple[int, int, int, int],
    rounded: bool = False,
) -> None:
    draw.text(xy, value, fill=fill, font=font(size, rounded=rounded))


def progress_ring(
    draw: ImageDraw.ImageDraw,
    center: tuple[int, int],
    radius: int,
    progress: float,
    accent: tuple[int, int, int, int],
    track: tuple[int, int, int, int],
    width: int,
) -> None:
    box = (center[0] - radius, center[1] - radius, center[0] + radius, center[1] + radius)
    draw.arc(box, start=0, end=360, fill=track, width=width)
    draw.arc(box, start=-90, end=-90 + int(360 * progress), fill=accent, width=width)


def draw_lock_card(
    image: Image.Image,
    rect: tuple[int, int, int, int],
    title_value: str,
    subtitle: str,
    progress: float,
    accent: tuple[int, int, int, int],
    dark: bool = False,
) -> None:
    draw = ImageDraw.Draw(image)
    fill = (255, 255, 255, 232) if not dark else (31, 32, 35, 238)
    outline = (225, 221, 214, 190) if not dark else (72, 72, 78, 210)
    shadowed_round_rect(image, rect, 44, fill, (20, 18, 14, 34 if not dark else 80), 34, (0, 18), outline)

    x1, y1, x2, y2 = rect
    fg = (18, 19, 22, 255) if not dark else (246, 246, 248, 255)
    secondary = (105, 104, 101, 255) if not dark else (174, 174, 180, 255)
    track = (224, 226, 228, 255) if not dark else (69, 70, 75, 255)

    progress_ring(draw, (x1 + 96, y1 + 92), 52, progress, accent, track, 12)
    percent = f"{int(progress * 100)}%"
    bbox = draw.textbbox((0, 0), percent, font=font(30, rounded=True))
    draw.text((x1 + 96 - (bbox[2] - bbox[0]) / 2, y1 + 92 - 18), percent, fill=fg, font=font(30, rounded=True))

    text(draw, (x1 + 178, y1 + 45), title_value, 38, fg, rounded=True)
    text(draw, (x1 + 178, y1 + 93), subtitle, 26, secondary, rounded=True)
    draw.ellipse((x1 + 180, y1 + 139, x1 + 202, y1 + 161), fill=accent)
    text(draw, (x1 + 214, y1 + 132), "On track", 24, accent, rounded=True)


def draw_compact_island(
    image: Image.Image,
    rect: tuple[int, int, int, int],
    label: str,
    progress: float,
    accent: tuple[int, int, int, int],
) -> None:
    draw = ImageDraw.Draw(image)
    shadowed_round_rect(image, rect, 34, (16, 17, 19, 255), (0, 0, 0, 76), 24, (0, 12))
    x1, y1, x2, y2 = rect
    progress_ring(draw, (x1 + 52, y1 + 34), 19, progress, accent, (55, 57, 62, 255), 5)
    text(draw, (x1 + 91, y1 + 18), label, 25, (245, 246, 248, 255), rounded=True)
    text(draw, (x2 - 92, y1 + 18), f"{int(progress * 100)}%", 25, (245, 246, 248, 255), rounded=True)


def draw_expanded_island(
    image: Image.Image,
    rect: tuple[int, int, int, int],
    title_value: str,
    subtitle: str,
    progress: float,
    accent: tuple[int, int, int, int],
) -> None:
    draw = ImageDraw.Draw(image)
    shadowed_round_rect(image, rect, 48, (17, 18, 20, 255), (0, 0, 0, 90), 32, (0, 14))
    x1, y1, x2, y2 = rect
    progress_ring(draw, (x1 + 76, y1 + 74), 34, progress, accent, (54, 55, 60, 255), 8)
    text(draw, (x1 + 132, y1 + 31), title_value, 30, (248, 248, 250, 255), rounded=True)
    text(draw, (x1 + 132, y1 + 72), subtitle, 20, (174, 176, 182, 255), rounded=True)
    track = (x1 + 132, y2 - 39, x2 - 48, y2 - 25)
    draw.rounded_rectangle(track, radius=7, fill=(46, 48, 53, 255))
    draw.rounded_rectangle(
        (track[0], track[1], track[0] + int((track[2] - track[0]) * progress), track[3]),
        radius=7,
        fill=accent
    )


def draw_chips(draw: ImageDraw.ImageDraw, chips: list[str], start: tuple[int, int]) -> None:
    x, y = start
    for chip in chips:
        label_font = font(25, rounded=True)
        bbox = draw.textbbox((0, 0), chip, font=label_font)
        width = bbox[2] - bbox[0] + 48
        draw.rounded_rectangle((x, y, x + width, y + 58), radius=29, fill=(255, 255, 255, 206), outline=(219, 216, 209, 255), width=2)
        draw.text((x + 24, y + 15), chip, fill=(41, 43, 48, 255), font=label_font)
        x += width + 18


def draw_static_preview(path: Path, dark: bool = False) -> None:
    bg = (247, 244, 237, 255) if not dark else (13, 14, 17, 255)
    image = Image.new("RGBA", (1600, 1000), bg)
    draw = ImageDraw.Draw(image)

    accent = (0, 122, 255, 255)
    headline = (20, 22, 26, 255) if not dark else (246, 247, 249, 255)
    secondary = (93, 93, 98, 255) if not dark else (172, 174, 180, 255)

    text(draw, (96, 102), "Live Activity &", 72, headline, rounded=True)
    text(draw, (96, 182), "Dynamic Island Kit", 72, headline, rounded=True)
    text(draw, (100, 292), "Reusable ActivityKit states", 34, secondary, rounded=True)
    text(draw, (100, 334), "for SwiftUI and WidgetKit.", 34, secondary, rounded=True)
    draw_chips(draw, ["ActivityKit", "WidgetKit", "SwiftUI", "Open Source"], (96, 430))

    phone = (104, 534, 650, 914)
    shadowed_round_rect(image, phone, 58, (255, 255, 255, 220) if not dark else (28, 29, 33, 242), (0, 0, 0, 32 if not dark else 90), 42, (0, 24), (224, 221, 215, 255) if not dark else (70, 72, 78, 255), 2)
    text(draw, (154, 584), "Delivery", 54, headline, rounded=True)
    text(draw, (156, 648), "Courier is 4 min away", 31, secondary, rounded=True)
    draw_lock_card(image, (148, 706, 606, 884), "Package nearby", "Last turn before arrival", 0.72, accent, dark)

    draw_compact_island(image, (870, 134, 1350, 214), "Ride arriving", 0.66, accent)
    draw_expanded_island(image, (830, 286, 1486, 486), "Boarding closes soon", "Gate A12 · 18 min remaining", 0.78, accent)
    draw_lock_card(image, (830, 602, 1468, 812), "Download finishing", "Preparing offline map", 0.84, accent, dark)

    for i, color in enumerate([(52, 199, 89, 255), (255, 159, 10, 255), (88, 86, 214, 255)]):
        cx = 1380 + i * 42
        draw.ellipse((cx, 136, cx + 24, 160), fill=color)

    image.convert("RGB").save(path, quality=95, optimize=True)


def main() -> None:
    SCREENSHOTS.mkdir(parents=True, exist_ok=True)
    draw_static_preview(SCREENSHOTS / "preview-porcelain.png", dark=False)


if __name__ == "__main__":
    main()
