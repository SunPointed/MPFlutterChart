abstract class AbstractBuffer<T> {
  /// index in the buffer
  int index = 0;

  /// double-buffer that holds the data points to draw, order: x,y,x,y,...
  List<double> buffer;

  /// animation phase x-axis
  double phaseX = 1.0;

  /// animation phase y-axis
  double phaseY = 1.0;

  /// indicates from which x-index the visible data begins
  int mFrom = 0;

  /// indicates to which x-index the visible data ranges
  int mTo = 0;

  /// Initialization with buffer-size.
  ///
  /// @param size
  AbstractBuffer(int size) {
    index = 0;
    buffer = List(size);
  }

  /// limits the drawing on the x-axis
  void limitFrom(int from) {
    if (from < 0) from = 0;
    mFrom = from;
  }

  /// limits the drawing on the x-axis
  void limitTo(int to) {
    if (to < 0) to = 0;
    mTo = to;
  }

  /// Resets the buffer index to 0 and makes the buffer reusable.
  void reset() {
    index = 0;
  }

  /// Returns the size (length) of the buffer array.
  ///
  /// @return
  int size() {
    return buffer.length;
  }

  /// Set the phases used for animations.
  ///
  /// @param phaseX
  /// @param phaseY
  void setPhases(double phaseX, double phaseY) {
    this.phaseX = phaseX;
    this.phaseY = phaseY;
  }

  /// Builds up the buffer with the provided data and resets the buffer-index
  /// after feed-completion. This needs to run FAST.
  ///
  /// @param data
  void feed(T data);
}
