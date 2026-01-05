import 'package:flutter/material.dart';

import '../../../lobby/domain/player.dart';
import '../../../lobby/presentation/pages/lobby_page.dart';

class PlayerSetupPage extends StatefulWidget {
  const PlayerSetupPage({
    super.key,
    required this.isHost,
  });

  final bool isHost;

  @override
  State<PlayerSetupPage> createState() => _PlayerSetupPageState();
}

class _PlayerSetupPageState extends State<PlayerSetupPage> {
  static const int _minPlayers = 3;
  static const int _maxPlayers = 10;

  late int _playerCount;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _playerCount = 4;
    _controllers = List.generate(
      _maxPlayers,
      (index) => TextEditingController(text: 'لاعب ${index + 1}'),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onCountChanged(double value) {
    setState(() {
      _playerCount = value.toInt();
    });
  }

  void _continueToLobby() {
    final List<Player> players = List.generate(_playerCount, (index) {
      final String raw = _controllers[index].text.trim();
      final String name = raw.isEmpty ? 'لاعب ${index + 1}' : raw;
      return Player(
        name: name,
        isHost: widget.isHost && index == 0,
        isReady: true,
      );
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LobbyPage(
          isHost: widget.isHost,
          players: players,
          selfIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعداد اللاعبين'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر عدد اللاعبين ثم اكتب أسماءهم. اللاعب الأول سيكون المضيف عند الإنشاء.',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              _CountSelector(
                current: _playerCount,
                min: _minPlayers,
                max: _maxPlayers,
                onChanged: _onCountChanged,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _playerCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bool isHost = widget.isHost && index == 0;
                    return TextField(
                      controller: _controllers[index],
                      textInputAction: index == _playerCount - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                      decoration: InputDecoration(
                        labelText:
                            isHost ? 'اسم المضيف' : 'اسم اللاعب ${index + 1}',
                        filled: true,
                        fillColor: scheme.surface.withOpacity(0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _continueToLobby,
                icon: const Icon(Icons.forward),
                label: const Text('متابعة إلى اللوبي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountSelector extends StatelessWidget {
  const _CountSelector({
    required this.current,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int current;
  final int min;
  final int max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عدد اللاعبين',
              style:
                  textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              '$current',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        Slider(
          value: current.toDouble(),
          onChanged: onChanged,
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
        ),
      ],
    );
  }
}
