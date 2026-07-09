# Security

This template does not include backend code, credentials, analytics, or push notification credentials.

When adapting it for production:

- Do not commit APNs keys or server credentials.
- Validate any server-driven activity updates before sending them to ActivityKit.
- Keep deep links scoped to screens the user is allowed to access.
- Avoid placing sensitive personal data in Live Activity text because it can appear on the Lock Screen.
