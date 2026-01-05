import 'package:flutter/material.dart';

import 'package:imposter_app/features/player_setup/presentation/pages/player_setup_page.dart';
import '../widgets/home_action_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _statusMessage = 'اختر إجراءً للعب محلياً (من دون خادم).';

  void _handleCreateRoom() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlayerSetupPage(isHost: true),
      ),
    );
    setState(() {
      _statusMessage = 'تم الانتقال لإعداد اللاعبين كمضيف. (محلي فقط)';
    });
    _showLocalOnlyNotice('Navigated to player setup as host (local-only).');
  }

  void _handleJoinRoom() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PlayerSetupPage(isHost: false),
      ),
    );
    setState(() {
      _statusMessage = 'تم الانتقال لإعداد اللاعبين كلاعب منضم. (محلي فقط)';
    });
    _showLocalOnlyNotice('Navigated to player setup as guest (local-only).');
  }

  void _showLocalOnlyNotice(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Imposter Lobby'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B1E2D), Color(0xFF121212)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'اختر وضع اللعب المحلي',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'التجربة الحالية محلية بالكامل من دون اتصال خلفي.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withOpacity(0.72),
                  ),
                ),
                const SizedBox(height: 28),
                HomeActionButton(
                  icon: Icons.add_box_outlined,
                  label: 'Create Room',
                  description: 'ابدأ جلسة لعب جديدة على نفس الشبكة أو الجهاز.',
                  onPressed: _handleCreateRoom,
                  accentColor: scheme.primary,
                ),
                const SizedBox(height: 16),
                HomeActionButton(
                  icon: Icons.login,
                  label: 'Join Room',
                  description: 'ادخل رمز غرفة محلية للانضمام إلى الأصدقاء.',
                  onPressed: _handleJoinRoom,
                  accentColor: scheme.secondary,
                ),
                const Spacer(),
                _StatusPanel(
                  statusMessage: _statusMessage,
                  iconColor: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.statusMessage,
    required this.iconColor,
  });

  final String statusMessage;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.shield_moon_outlined,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وضع تجريبي بلا خادم',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusMessage,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
