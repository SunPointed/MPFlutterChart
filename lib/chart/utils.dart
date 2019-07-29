class Utils{
  static double convertDpToPixel(double dp) {
    // todo
    return dp;
  }

  static int getLegendFormatDigits(double step, int bonus) {
    if (step < 0.0000099) {
      return 6 + bonus;
    } else if (step < 0.000099) {
      return 5 + bonus;
    } else if (step < 0.00099) {
      return 4 + bonus;
    } else if (step < 0.0099) {
      return 3 + bonus;
    } else if (step < 0.099) {
      return 2 + bonus;
    } else if (step < 0.99) {
      return 1 + bonus;
    } else {
      return 0 + bonus;
    }
  }

  static int getFormatDigits(double delta) {
    if (delta < 0.1) {
      return 6;
    } else if (delta <= 1) {
      return 4;
    } else if (delta < 20) {
      return 2;
    } else if (delta < 100) {
      return 1;
    } else {
      return 0;
    }
  }

  static final DEBUG = true;

  static void log(Object object){
    if(DEBUG) {
      print(object);
    }
  }
}