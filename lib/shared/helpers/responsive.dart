import 'package:flutter/widgets.dart';

class R {
  static late double w;
  static late double h;
  static late double sp;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;

    w = size.width / 390;
    h = size.height / 844;
    sp = w;
  }

  static double font(double s) => s * sp;
  static double space(double s) => s * h;
  static double width(double s) => s * w;
  static double height(double s) => s * h;
}
