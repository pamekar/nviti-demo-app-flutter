# Nviti Demo App — Flutter

Nviti Explorer demonstrates the Nviti Chat SDK across banking, health insurance,
logistics, diagnostics, property and hospitality. Dashboards fetch public data
from live `*-demo.nvt.ng` APIs and include contextual shortcuts, a circular
bottom-right chat launcher and a dismissible native invitation.

## Local development

Keep these sibling directories:
```text
demo_apps/nviti-demo-app-flutter/
sdks/nviti-chat-flutter/
```

SDK publication is still pending. This repository alone is not yet a
self-contained clean-clone build; CI expects `pamekar/nviti-chat-flutter`
to be available. Do not assume the SDK is on a package registry.

Run `flutter pub get`, `flutter analyze`, `flutter test`, then `flutter build apk --release --split-per-abi`.

## Demo boundaries

Account cards show an unconnected state, not invented balances or private
records. Shortcuts explain services and open the assistant; they do not execute
real transactions. Private account operations require server-verified identity.
Never embed API credentials in a mobile app.

Version 1.2.0 retains legacy application/package identifiers for in-place APK
updates. Repository names are industry-neutral; internal identifiers remain
for compatibility. Demo signing keys are not suitable for production releases.
