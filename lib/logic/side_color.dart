enum SideColor {
  white,
  black;

  SideColor other() {
    return switch(this) {
      .white => .black,
      .black => .white
    };
  }
}