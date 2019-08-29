import 'package:mp_flutter_chart/chart/mp/core/poolable/point.dart';

class FSize extends Poolable {
  double width;
  double height;

  static ObjectPool<Poolable> pool = ObjectPool.create(256, FSize(0, 0))
    ..setReplenishPercentage(0.5);

  @override
  Poolable instantiate() {
    return FSize(0, 0);
  }

  static FSize getInstance(final double width, final double height) {
    FSize result = pool.get();
    result.width = width;
    result.height = height;
    return result;
  }

  static void recycleInstance(FSize instance) {
    pool.recycle1(instance);
  }

  static void recycleInstances(List<FSize> instances) {
    pool.recycle2(instances);
  }

  FSize(this.width, this.height);

  bool equals(final Object obj) {
    if (obj == null) {
      return false;
    }
    if (this == obj) {
      return true;
    }
    if (obj is FSize) {
      final FSize other = obj as FSize;
      return width == other.width && height == other.height;
    }
    return false;
  }

  @override
  String toString() {
    return "${width}x${height}";
  }

  @override
  int get hashCode {
    return width.toInt() ^ height.toInt();
  }
}
