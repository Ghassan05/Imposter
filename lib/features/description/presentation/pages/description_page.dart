import 'dart:async';

import 'package:flutter/material.dart';

import '../../../lobby/domain/player.dart';

class DescriptionPage extends StatefulWidget {
  const DescriptionPage({
    super.key,
    required this.players,
    required this.secretWord,
  });

  final List<Player> players;
  final String secretWord;

  @override
  State<DescriptionPage> createState() => _DescriptionPageState();
}

class _DescriptionPageState extends State<DescriptionPage> {
  static const int _turnSeconds = 20;
  late int _currentIndex;
  late int _remainingSeconds;
  Timer? _timer;
  bool _stopped = false;
  bool _wordVisible = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _remainingSeconds = _turnSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_stopped) return;
    setState(() => _remainingSeconds = _turnSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1 || _stopped) {
        setState(() => _remainingSeconds = 0);
        timer.cancel();
      } else {
        setState(() => _remainingSeconds -= 1);
      }
    });
  }

  void _nextTurn() {
    if (_stopped) return;
    _timer?.cancel();
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.players.length;
      _remainingSeconds = _turnSeconds;
    });
    _startTimer();
  }

  void _stopRound() {
    setState(() {
      _stopped = true;
      _wordVisible = false;
    });
    _timer?.cancel();
  }

  void _showWord() {
    setState(() {
      _wordVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Player player = widget.players[_currentIndex];
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool timeOut = _remainingSeconds == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('وصف الجولة'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(
                player: player,
                index: _currentIndex,
                total: widget.players.length,
              ),
              const SizedBox(height: 18),
              _Countdown(
                seconds: _remainingSeconds,
                isExpired: timeOut,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'الجملة الواحدة:',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'دورك لتقول جملة قصيرة واحدة فقط عن الكلمة. لا تكتب شيئاً، فقط تحدث.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (_wordVisible)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surface.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.primary, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الكلمة السرية',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.secretWord,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _stopped ? null : _stopRound,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('إيقاف اللعب'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _stopped ? _showWord : null,
                      icon: const Icon(Icons.visibility),
                      label: const Text('عرض الكلمة'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _stopped ? null : _nextTurn,
                icon: const Icon(Icons.arrow_forward),
                label: Text(timeOut ? 'التالي (انتهى الوقت)' : 'التالي'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.player,
    required this.index,
    required this.total,
  });

  final Player player;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الدور الحالي',
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 6),
            Text(
              player.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${index + 1} / $total',
            style: textTheme.titleSmall,
          ),
        ),
      ],
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({
    required this.seconds,
    required this.isExpired,
  });

  final int seconds;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isExpired
            ? scheme.errorContainer.withOpacity(0.3)
            : scheme.surface.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpired ? scheme.error : scheme.primary,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوقت المتبقي',
            style: textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${seconds}s',
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(
                isExpired ? Icons.timer_off : Icons.timer,
                color: isExpired ? scheme.error : scheme.primary,
              ),
            ],
          ),
          if (isExpired)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'انتهى الوقت! انتقل للاعب التالي.',
                style: textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
