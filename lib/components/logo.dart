import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final double width;
  final double height;

  const Logo({Key? key, this.width = 150, this.height = 150}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/logo.png', width: width, height: height);
  }
}
