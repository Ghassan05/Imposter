import 'dart:math';

import 'package:flutter/material.dart';
import 'package:imposter_app/features/roles/data/secret_words.dart';
import 'package:imposter_app/features/roles/presentation/pages/role_reveal_page.dart';

import '../../domain/player.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({
    super.key,
    required this.isHost,
    required this.players,
    this.selfIndex,
  });

  final bool isHost;
  final List<Player> players;
  final int? selfIndex;

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  late final TextEditingController _nameController;
  late List<Player> _players;
  late int _selfIndex;
  late bool _showSelfBadge;
  int _imposterCount = 1;

  @override
  void initState() {
    super.initState();
    _players = List<Player>.from(widget.players);
    _showSelfBadge = widget.selfIndex != null;
    _selfIndex = (_showSelfBadge &&
            widget.selfIndex! >= 0 &&
            widget.selfIndex! < _players.length)
        ? widget.selfIndex!
        : 0;
    _nameController = TextEditingController(
      text: _players.isNotEmpty ? _players[_selfIndex].name : '',
    );
  }

  void _updateSelfName() {
    if (_players.isEmpty) return;
    final String newName = _nameController.text.trim();
    if (newName.isEmpty) return;
    setState(() {
      _players[_selfIndex] = _players[_selfIndex].copyWith(name: newName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديث الاسم إلى "$newName" (محلي فقط).'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startGame() {
    _imposterCount =
        _imposterCount.clamp(1, (_players.length - 1).clamp(1, 99));
    final RoleAssignments assignments = _assignRoles();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoleRevealPage(assignments: assignments),
      ),
    );
  }

  RoleAssignments _assignRoles() {
    final Random random = Random();
    final int maxImposters = (_players.length - 1).clamp(1, _players.length);
    final int impostersToPick = _imposterCount.clamp(1, maxImposters);
    final Set<int> imposterIndices = {};
    while (imposterIndices.length < impostersToPick) {
      imposterIndices.add(random.nextInt(_players.length));
    }
    final String secretWord = secretWords[random.nextInt(secretWords.length)];
    return RoleAssignments(
      players: _players,
      imposterIndices: imposterIndices.toList(),
      secretWord: secretWord,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHost ? 'اللوبي (مضيف)' : 'اللوبي (منضم)'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_players.isNotEmpty)
                _NameInput(
                  controller: _nameController,
                  onSave: _updateSelfName,
                  label: 'اسمك',
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'اللاعبون المنضمون',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${_players.length} لاعبين',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _PlayerList(
                  players: _players,
                  selfIndex: _selfIndex,
                  showSelfBadge: _showSelfBadge,
                ),
              ),
              if (widget.isHost) ...[
                const SizedBox(height: 12),
                _ImposterSelector(
                  current: _imposterCount,
                  max: (_players.length - 1).clamp(1, _players.length),
                  onChanged: (value) {
                    setState(() {
                      _imposterCount = value.toInt();
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              _StartButton(
                enabled: widget.isHost,
                onPressed: _startGame,
              ),
              const SizedBox(height: 8),
              Text(
                'هذه تجربة محلية تجريبية من دون اتصال أو خادم.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  const _PlayerList({
    required this.players,
    required this.selfIndex,
    required this.showSelfBadge,
  });

  final List<Player> players;
  final int selfIndex;
  final bool showSelfBadge;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return ListView.separated(
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final Player player = players[index];
        final bool isSelf = showSelfBadge && index == selfIndex;
        return Container(
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelf ? scheme.primary : scheme.outlineVariant,
              width: isSelf ? 1.4 : 0.6,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          child: Row(
            children: [
              Icon(
                player.isHost ? Icons.star_rate_rounded : Icons.person_rounded,
                color: player.isHost ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            player.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelf)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primary.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'أنت',
                              style: textTheme.labelSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (player.isHost)
                          _Badge(
                            label: 'المضيف',
                            color: scheme.primary,
                          ),
                        const SizedBox(width: 6),
                        _Badge(
                          label: player.isReady ? 'جاهز' : 'ينتظر',
                          color: player.isReady
                              ? scheme.tertiary
                              : scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({
    required this.controller,
    required this.onSave,
    required this.label,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSave(),
          decoration: InputDecoration(
            labelText: label,
            hintText: 'اكتب الاسم هنا',
            filled: true,
            fillColor: scheme.surface.withOpacity(0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: const Text('حفظ الاسم'),
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('بدء اللعبة'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
        if (!enabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'المضيف فقط يمكنه بدء اللعبة.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

class _ImposterSelector extends StatelessWidget {
  const _ImposterSelector({
    required this.current,
    required this.max,
    required this.onChanged,
  });

  final int current;
  final int max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final int clampedMax = max < 1 ? 1 : max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'عدد المحتالين',
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
          value: current.clamp(1, clampedMax).toDouble(),
          min: 1,
          max: clampedMax.toDouble(),
          divisions: clampedMax - 1 < 1 ? null : clampedMax - 1,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
