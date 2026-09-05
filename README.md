# Nviti Demo Bank — Flutter

An open-source sample bank app showing how to launch Nviti Chat from Flutter.

The repository uses the sibling SDK checkout during development. Once the SDK repository is published, replace the path dependency with its public Git URL or pub.dev version.

```bash
flutter pub get
flutter test
flutter build apk --debug --dart-define=NVITI_CHAT_URL=https://your-tenant.nvt.ng/chat/WIDGET_HASH?webview=1
```

Production apps should request a short-lived `webview_launch_url` from their backend and pass it to the chat screen at runtime. Never embed an Nviti API token in a mobile app.
