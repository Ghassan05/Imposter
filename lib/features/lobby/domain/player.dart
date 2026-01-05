class Player {
  const Player({
    required this.name,
    required this.isHost,
    required this.isReady,
  });

  final String name;
  final bool isHost;
  final bool isReady;

  Player copyWith({
    String? name,
    bool? isHost,
    bool? isReady,
  }) {
    return Player(
      name: name ?? this.name,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
    );
  }
}
