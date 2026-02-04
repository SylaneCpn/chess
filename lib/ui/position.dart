class Position {
  double bottom;
  double left;

  Position({required this.bottom, required this.left});
  Position.zero() : this(bottom: 0.0, left: 0.0);

  Position operator +(Position other) =>
      Position(bottom: bottom + other.bottom, left: left + other.left);


  void add(Position other) {
    bottom  = bottom + other.bottom;
    left = left + other.left;
  }


  void reset() {
    bottom = 0.0;
    left = 0.0;
  }
}
