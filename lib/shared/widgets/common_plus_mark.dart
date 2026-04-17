import 'package:flutter/material.dart';

class CommonPlusMark extends StatelessWidget {
  const CommonPlusMark({
    super.key,
    required this.size,
    required this.color,
    this.thickness = 4,
  });

  final double size;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: thickness,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
          Container(
            width: thickness,
            height: size,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(thickness),
            ),
          ),
        ],
      ),
    );
  }
}
