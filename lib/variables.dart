import 'package:flutter/widgets.dart';
// I/flutter (22465): Screen Height:  890.2857142857143
// I/flutter (22465): Screen Width:  411.42857142857144
class Variables {
  static late double screenWidth;
  static late double screenHeight;
  

  static void init(BuildContext context){
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }
}