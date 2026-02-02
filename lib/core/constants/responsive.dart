import 'package:flutter/material.dart';

class Responsive {
  final BuildContext _context;
  late double _height;
  late double _width;

  Responsive(this._context) {
    final Size size = MediaQuery.of(_context).size;
    _height = size.height;
    _width = size.width;
  }

  double hp(double percent) => _height * (percent / 100);
  double wp(double percent) => _width * (percent / 100);
}
