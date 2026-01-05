import 'package:flutter/material.dart';

import '../../../description/presentation/pages/description_page.dart';
import '../../../lobby/domain/player.dart';

class RoleAssignments {
  const RoleAssignments({
    required this.players,
    required this.imposterIndices,
    required this.secretWord,
  });

  final List<Player> players;
  final List<int> imposterIndices;
  final String secretWord;
}

class RoleRevealPage extends StatefulWidget {
  const RoleRevealPage({super.key, required this.assignments});

  final RoleAssignments assignments;

  @override
  State<RoleRevealPage> createState() => _RoleRevealPageState();
}

class _RoleRevealPageState extends State<RoleRevealPage> {
  late final List<_ViewState> _viewStates;

  @override
  void initState() {
    super.initState();
    _viewStates = List<_ViewState>.filled(
        widget.assignments.players.length, _ViewState.hidden);
  }

  bool get _allLocked =>
      _viewStates.every((state) => state == _ViewState.locked);

  void _handleTap(int index) {
    final _ViewState state = _viewStates[index];
    switch (state) {
      case _ViewState.hidden:
        setState(() {
          _viewStates[index] = _ViewState.revealed;
        });
        break;
      case _ViewState.revealed:
        setState(() {
          _viewStates[index] = _ViewState.locked;
        });
        break;
      case _ViewState.locked:
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت مشاهدة هذه البطاقة بالفعل.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
    }
  }

  void _proceedToNextPhase() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DescriptionPage(
          players: widget.assignments.players,
          secretWord: widget.assignments.secretWord,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الكشف عن الأدوار'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'كل لاعب يضغط على اسمه لعرض بطاقته ثم يغلقها. البطاقة لا تُفتح مرة ثانية.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: widget.assignments.players.length,
                      itemBuilder: (context, index) {
                        final Player player = widget.assignments.players[index];
                        final bool isImposter =
                            widget.assignments.imposterIndices.contains(index);
                        final _ViewState state = _viewStates[index];
                        return _RoleTile(
                          player: player,
                          isImposter: isImposter,
                          secretWord: widget.assignments.secretWord,
                          state: state,
                          onTap: () => _handleTap(index),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _allLocked ? _proceedToNextPhase : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('بدء الجولة التالية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.player,
    required this.isImposter,
    required this.secretWord,
    required this.state,
    required this.onTap,
  });

  final Player player;
  final bool isImposter;
  final String secretWord;
  final _ViewState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool showing = state == _ViewState.revealed;
    final bool locked = state == _ViewState.locked;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    player.isHost ? Icons.star : Icons.person,
                    color: player.isHost
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (showing)
                _RevealedCard(
                  isImposter: isImposter,
                  secretWord: secretWord,
                )
              else
                _Placeholder(locked: locked),
              const Spacer(),
              Text(
                locked
                    ? 'تمت المشاهدة'
                    : showing
                        ? 'اضغط لإغلاق البطاقة (لن تعود)'
                        : 'اضغط لعرض البطاقة',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: locked
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface.withOpacity(0.75),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevealedCard extends StatelessWidget {
  const _RevealedCard({
    required this.isImposter,
    required this.secretWord,
  });

  final bool isImposter;
  final String secretWord;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isImposter
            ? scheme.errorContainer.withOpacity(0.45)
            : scheme.surfaceTint.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isImposter ? scheme.error : scheme.primary,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isImposter ? 'أنت المحتال' : 'الكلمة السرية:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (!isImposter)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                secretWord,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
          if (isImposter)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'حاول التظاهر أنك تعرف الكلمة.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.locked});

  final bool locked;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              locked ? scheme.outlineVariant : scheme.primary.withOpacity(0.5),
          width: 1.1,
        ),
      ),
      child: Center(
        child: Text(
          locked ? 'مغلق' : 'اضغط لعرض البطاقة',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

enum _ViewState { hidden, revealed, locked }
