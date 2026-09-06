import 'package:flutter/material.dart';
import 'package:nviti_chat/nviti_chat.dart';

const _navy = Color(0xFF123C69);
const _orange = Color(0xFFEE542F);

void main() => runApp(const DemoBankApp());

class DemoBankApp extends StatelessWidget {
  const DemoBankApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Nviti Demo Bank',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: _navy),
      scaffoldBackgroundColor: const Color(0xFFF4F7FB),
      useMaterial3: true,
    ),
    home: const BankHomePage(),
  );
}

class BankHomePage extends StatelessWidget {
  const BankHomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: _navy,
                child: Text(
                  'NB',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening, Ada',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    Text(
                      'Nviti Demo Bank',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_navy, Color(0xFF23659B)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33123C69),
                  blurRadius: 22,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE BALANCE',
                  style: TextStyle(
                    color: Color(0xFFBFD7EA),
                    fontSize: 11,
                    letterSpacing: 1.1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '₦1,248,650.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Savings • 2408',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      'DEMO ACCOUNT',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Quick actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF14213D),
            ),
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QuickAction(icon: Icons.arrow_upward_rounded, label: 'Send'),
              _QuickAction(
                icon: Icons.arrow_downward_rounded,
                label: 'Receive',
              ),
              _QuickAction(icon: Icons.receipt_long_outlined, label: 'Bills'),
              _QuickAction(icon: Icons.more_horiz_rounded, label: 'More'),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFFFECE6),
                  child: Icon(Icons.auto_awesome, color: _orange),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meet Nia',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF14213D),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Your conversational banking assistant',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      key: const Key('open-chat'),
      onPressed: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ChatPage())),
      backgroundColor: _orange,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.chat_bubble_outline_rounded),
      label: const Text(
        'Chat with Nia',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: _navy),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static const launchUrl = String.fromEnvironment(
    'NVITI_CHAT_URL',
    defaultValue: 'https://nviti-demo-bank.nvt.ng/chat/configure-me?webview=1',
  );

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(launchUrl);
    final origin = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nia • Nviti Demo Bank',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
      ),
      body: NvitiChat(
        config: NvitiChatConfig(
          launchUrl: uri,
          allowedOrigin: origin,
          allowedActions: const {
            NvitiNativeAction.close,
          },
        ),
        onNativeAction: (request) async {
          if (request.action == NvitiNativeAction.close && context.mounted) {
            Navigator.of(context).pop();
          }
          return <String, Object?>{'handled': true};
        },
      ),
    );
  }
}
