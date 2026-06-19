import 'package:flutter/material.dart';

class RedBullF1Car extends StatelessWidget {
  final double size;
  const RedBullF1Car({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RedBullF1Painter(),
      ),
    );
  }
}

class RunningShoeIcon extends StatelessWidget {
  final double size;
  const RunningShoeIcon({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          '👟',
          style: TextStyle(fontSize: size * 0.8),
        ),
      ),
    );
  }
}

class _RedBullF1Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Warna Red Bull
    const darkBlue = Color(0xFF001A30);
    const yellow = Color(0xFFFFD700);
    const red = Color(0xFFE30022);
    const tireColor = Color(0xFF222222);

    final paint = Paint()..style = PaintingStyle.fill;

    // Ban Depan
    paint.color = tireColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.1, h * 0.15, w * 0.15, h * 0.25), const Radius.circular(3)), 
      paint
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.75, h * 0.15, w * 0.15, h * 0.25), const Radius.circular(3)), 
      paint
    );

    // Ban Belakang
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.05, h * 0.6, w * 0.2, h * 0.3), const Radius.circular(4)), 
      paint
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.75, h * 0.6, w * 0.2, h * 0.3), const Radius.circular(4)), 
      paint
    );

    // Sayap Depan (Front Wing)
    paint.color = darkBlue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.05, w * 0.7, h * 0.1), const Radius.circular(2)), 
      paint
    );
    paint.color = red;
    canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.07, w * 0.6, h * 0.02), paint);

    // Bodi Utama (Nose ke Cockpit)
    paint.color = darkBlue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.35, h * 0.05, w * 0.3, h * 0.8), const Radius.circular(4)), 
      paint
    );

    // Sayap Belakang (Rear Wing)
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.85, w * 0.6, h * 0.1), const Radius.circular(2)), 
      paint
    );
    paint.color = red;
    canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.9, w * 0.5, h * 0.02), paint);

    // Sidepods
    paint.color = darkBlue;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.25, h * 0.4, w * 0.5, h * 0.35), const Radius.circular(6)), 
      paint
    );

    // Tanda Kuning & Merah di Hidung (Logo RedBull abstraction)
    paint.color = yellow;
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), w * 0.08, paint);
    paint.color = red;
    canvas.drawCircle(Offset(w * 0.5, h * 0.3), w * 0.04, paint);

    // Halo & Cockpit
    paint.color = Colors.black87;
    canvas.drawOval(Rect.fromLTWH(w * 0.4, h * 0.45, w * 0.2, h * 0.15), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
