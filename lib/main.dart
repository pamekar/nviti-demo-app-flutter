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
  bool invitationDismissed = false;
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
        final id = payload['id'] as String? ?? 'banking';
        final design = industryDesign(id);
        final accent = Color(
          int.tryParse(
                (payload['color'] as String? ?? '#123C69').replaceFirst(
                  '#',
                  'FF',
                ),
                radix: 16,
              ) ??
              0xFF123C69,
        );
        void openChat() {
          final uri = Uri.tryParse(payload['chat_url'] as String? ?? '');
          if (uri == null ||
              uri.scheme != 'https' ||
              !uri.host.endsWith('.nvt.ng')) {
            return;
          }
          setState(() => invitationDismissed = true);
          Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => ChatPage(uri: uri)),
          );
        }

        void explain(String title) => showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  Text(
                    'Explore $title with the ${payload['title']} assistant. Personal records and account actions require a verified demo account. No real transactions are made.',
                  ),
                  const SizedBox(height: 20),
                  if (payload['chat_url'] is String)
                    FilledButton(
                      onPressed: () {
                        Navigator.pop(context);
                        openChat();
                      },
                      child: const Text('Ask assistant'),
                    ),
                ],
              ),
            ),
          ),
        );
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 230),
              children: [
                Text(
                  '${payload['title']} · DEMO',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  design.$1,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: Color(0xFF172B3A),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    gradient: LinearGradient(
                      colors: [accent, Color.lerp(accent, Colors.black, .3)!],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        design.$2.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          letterSpacing: 1.4,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        id == 'banking' ? '₦ — —' : 'Let’s get you connected',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: id == 'banking' ? 36 : 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Verified demo account required\nNo personal account is connected',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final shortcut in design.$3)
                      Expanded(
                        child: Column(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => explain(shortcut.$2),
                              tooltip: shortcut.$2,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: accent,
                                minimumSize: const Size(56, 56),
                              ),
                              icon: Icon(shortcut.$1),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              shortcut.$2,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Explore & manage',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                for (final metric in payload['metrics'] as List)
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(top: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        '${metric['value']}  ${metric['label']}',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                for (final action in payload['actions'] as List)
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: const EdgeInsets.only(top: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: Icon(Icons.grid_view_rounded, color: accent),
                      trailing: const Icon(Icons.chevron_right),
                      title: Text(action['title'] as String),
                      subtitle: const Text('Explore the demo'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: Text(action['title'] as String),
                            ),
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
                  ),
                Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(top: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          id == 'banking' ? 'Recent activity' : 'Your updates',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Nothing to show yet'),
                        const SizedBox(height: 8),
                        const Text(
                          'Connect a verified demo account through the assistant to explore personalized services.',
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  payload['notice'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.blueGrey),
                ),
              ],
            ),
            if (payload['chat_url'] is String)
              Positioned(
                right: 20,
                bottom: 20,
                child: SafeArea(
                  child: FloatingActionButton(
                    heroTag: null,
                    shape: const CircleBorder(),
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    tooltip: 'Chat with ${payload['title']} assistant',
                    onPressed: openChat,
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  ),
                ),
              ),
            if (payload['chat_url'] is String && !invitationDismissed)
              Positioned(
                right: 20,
                left: 40,
                bottom: 96,
                child: SafeArea(
                  child: Material(
                    elevation: 5,
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: openChat,
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Need a hand?\nChat with your assistant ↗',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Dismiss chat invitation',
                          onPressed: () =>
                              setState(() => invitationDismissed = true),
                          icon: const Icon(Icons.close, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

(String, String, List<(IconData, String)>) industryDesign(String id) =>
    switch (id) {
      'hmo' => (
        'Good care,\ncloser to you.',
        'Your health cover',
        [
          (Icons.add, 'Find care'),
          (Icons.favorite_border, 'Benefits'),
          (Icons.receipt_long, 'Claims'),
        ],
      ),
      'logistics' => (
        'Every delivery.\nOne clear view.',
        'Your shipments',
        [
          (Icons.location_on_outlined, 'Track'),
          (Icons.outbound_outlined, 'Send parcel'),
          (Icons.history, 'History'),
        ],
      ),
      'labs' => (
        'A clearer picture\nof your health.',
        'Your test results',
        [
          (Icons.add, 'Book test'),
          (Icons.description_outlined, 'Results'),
          (Icons.schedule, 'Visits'),
        ],
      ),
      'property' => (
        'Find a place\nto call your own.',
        'Your property journey',
        [
          (Icons.home_outlined, 'Properties'),
          (Icons.schedule, 'Viewings'),
          (Icons.favorite_border, 'Saved'),
        ],
      ),
      'hospitality' => (
        'Make room\nfor a great stay.',
        'Your reservations',
        [
          (Icons.bed_outlined, 'Rooms'),
          (Icons.schedule, 'Book stay'),
          (Icons.receipt_long, 'My stays'),
        ],
      ),
      _ => (
        'Your money.\nYour next move.',
        'Account balance',
        [
          (Icons.north_east, 'Transfer'),
          (Icons.grid_view, 'Pay bills'),
          (Icons.download_outlined, 'Statements'),
        ],
      ),
    };

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
