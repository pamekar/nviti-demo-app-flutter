import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nviti_chat/nviti_chat.dart';

typedef DemoLoader = Future<Map<String, dynamic>> Function(String url);
Future<Map<String, dynamic>> fetchDemo(String url) async {
  final uri = Uri.parse(url);
  if (uri.scheme != 'https' ||
      !RegExp(r'^[a-z]+-demo\.nvt\.ng$').hasMatch(uri.host)) {
    throw const FormatException('Untrusted demo endpoint');
  }
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final request = await client.getUrl(uri);
    request.followRedirects = false;
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const HttpException('Demo unavailable');
    }
    return jsonDecode(
          await response
              .transform(utf8.decoder)
              .join()
              .timeout(const Duration(seconds: 15)),
        )
        as Map<String, dynamic>;
  } finally {
    client.close(force: true);
  }
}

void main() => runApp(const DemoBankApp());

class DemoBankApp extends StatelessWidget {
  const DemoBankApp({super.key, this.loader = fetchDemo});
  final DemoLoader loader;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Nviti Explorer',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF123C69)),
      useMaterial3: true,
    ),
    home: DemoPage(loader: loader),
  );
}

class DemoPage extends StatefulWidget {
  const DemoPage({
    super.key,
    required this.loader,
    this.url = 'https://banking-demo.nvt.ng/api/v1/mobile/use-cases',
  });
  final DemoLoader loader;
  final String url;
  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
    data = widget.loader(widget.url);
  }

  void reload() => setState(() {
    data = widget.loader(widget.url);
  });
  Widget button(String title, VoidCallback action) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: FilledButton.tonal(
      onPressed: action,
      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      child: Text(title),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Nviti Explorer'),
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: reload,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: data,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Unable to load demo. Check your connection.'),
                button('Retry', reload),
              ],
            ),
          );
        }
        final payload = snapshot.requireData;
        if (payload.containsKey('use_cases')) {
          return ListView(
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                'Choose your experience',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'One app. Different industries. Explore the Nviti assistants.',
                ),
              ),
              for (final item in payload['use_cases'] as List)
                button(
                  item['title'] as String,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => DemoPage(
                        loader: widget.loader,
                        url: item['dashboard_url'] as String,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }
        return ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Text(
              payload['title'] as String,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(payload['notice'] as String),
            ),
            for (final metric in payload['metrics'] as List)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '${metric['value']}  ${metric['label']}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            for (final action in payload['actions'] as List)
              button(
                action['title'] as String,
                () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(action['title'] as String)),
                      body: ListView(
                        padding: const EdgeInsets.all(22),
                        children: [
                          if ((action['items'] as List).isEmpty)
                            const Text('No items available yet.'),
                          for (final item in action['items'] as List)
                            ListTile(title: Text(item as String)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (payload['chat_url'] is String)
              button('Chat with ${payload['title']} assistant', () {
                final uri = Uri.parse(payload['chat_url'] as String);
                if (uri.scheme != 'https' || !uri.host.endsWith('.nvt.ng')) {
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => ChatPage(uri: uri)),
                );
              })
            else
              const Text('Chat is not configured for this experience yet.'),
          ],
        );
      },
    ),
  );
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.uri});
  final Uri uri;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: TextButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
        label: const Text('Close chat'),
      ),
    ),
    body: NvitiChat(
      config: NvitiChatConfig(
        launchUrl: uri,
        allowedOrigin: Uri.parse(uri.origin),
        allowedActions: const {NvitiNativeAction.close},
      ),
      onNativeAction: (request) async {
        if (request.action == NvitiNativeAction.close && context.mounted) {
          Navigator.pop(context);
        }
        return <String, Object?>{'handled': true};
      },
    ),
  );
}
