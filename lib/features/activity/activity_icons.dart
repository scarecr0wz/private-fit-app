import 'package:flutter/material.dart';

class RedBullF1Car extends StatelessWidget {
  final double size;
  const RedBullF1Car({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          '🏎️',
          style: TextStyle(
            fontSize: size * 0.8,
            shadows: const [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
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
