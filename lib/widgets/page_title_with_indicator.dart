import 'package:flutter/material.dart';

class PageTitleWithIndicator extends StatelessWidget {
  final double indicatorWidth; // width of the purple segment
  final double lineWidth; // total width of the line
  final double positionFactor; // 0.0 (start) to 1.0 (end) for dynamic positioning
  final Color indicatorColor;
  final String title;
  final double titleFontSize;

  const PageTitleWithIndicator({
    Key? key,
    this.indicatorWidth = 50.0,
    this.lineWidth = 200.0,
    this.positionFactor = 0.5,
    this.indicatorColor = const Color(0xFF5159FF),
    this.title = 'placeholder',
    this.titleFontSize = 24.0
  }) : super(key: key);

  @override
  @override
Widget build(BuildContext context) {
  final double leftOffset = (lineWidth - indicatorWidth) * positionFactor;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      SizedBox(height: 8), // spacing between text and line
      SizedBox(
        width: lineWidth,
        height: 10,
        child: Stack(
          children: [
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 2,
                  color: Colors.grey[300],
                ),
              ),
            ),
            Positioned(
              left: leftOffset,
              top: 2.5,
              child: Container(
                width: indicatorWidth,
                height: 5,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
}
