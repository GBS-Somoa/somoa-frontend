import 'package:flutter/material.dart';

class WaterSaturationWidget extends StatelessWidget {
  final int amount;

  const WaterSaturationWidget({
    super.key,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: CustomPaint(
        size: const Size(100, 100),
        painter: _WaterSaturationPainter(amount: amount),
      ),
    );
  }
}

class _WaterSaturationPainter extends CustomPainter {
  final int amount;

  _WaterSaturationPainter({required this.amount});

  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    Paint borderPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double filledHeight = size.height * (amount / 100);
    double unfilledHeight = size.height - filledHeight;

    // Draw the filled area
    canvas.drawRect(
      Rect.fromLTWH(0, unfilledHeight, size.width, filledHeight),
      fillPaint,
    );

    // Draw the border of the box
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Render the amount text inside the box
    TextSpan span = TextSpan(
      text: '$amount%', // Render the amount as percentage
      style: TextStyle(color: Colors.black, fontSize: 16),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
