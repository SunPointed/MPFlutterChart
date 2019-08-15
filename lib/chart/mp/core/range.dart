class Range {
  double from;
  double to;

  Range(double from, double to) {
    this.from = from;
    this.to = to;
  }

  /**
   * Returns true if this range contains (if the value is in between) the given value, false if not.
   *
   * @param value
   * @return
   */
  bool contains(double value) {
    if (value > from && value <= to)
      return true;
    else
      return false;
  }

  bool isLarger(double value) {
    return value > to;
  }

  bool isSmaller(double value) {
    return value < from;
  }
}
