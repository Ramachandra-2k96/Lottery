import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class LotteryWheel extends StatefulWidget {
  const LotteryWheel({Key? key}) : super(key: key);

  @override
  _LotteryWheelState createState() => _LotteryWheelState();
}

class _LotteryWheelState extends State<LotteryWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _result;
  bool _isSpinning = false;

  final List<Color> colors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFF45B7D1),
    const Color(0xFFFFA07A),
    const Color(0xFF98D8C8),
    const Color(0xFFF06292),
    const Color(0xFFAED581),
    const Color(0xFFFFD54F),
    const Color(0xFF4DB6AC),
    const Color(0xFF7986CB),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _spinWheel() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    // Play spinning sound
    await _audioPlayer.play(AssetSource('spinning_sound.wav'));

    // Random number between 0 and 9 (corresponding to indexes 1-10)
    final int randomNumber = Random().nextInt(10);

    // Number of full rotations plus the random angle
    final int spinCount = 5;
    final double anglePerSection = 2 * pi / 10; // Angle per section (360 degrees / 10)
    final double endAngle = 2 * pi * spinCount + randomNumber * anglePerSection;

    // Set the animation to rotate to the end angle
    _animation = Tween<double>(
      begin: 0,
      end: endAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    await _controller.forward(from: 0);

    setState(() {
      _isSpinning = false;
      _result = (10 - randomNumber) % 10 + 1; // Convert the index to the actual number (1-10)
    });

    await _audioPlayer.stop();
    _showResultDialog(_result!);
  }

  void _showResultDialog(int result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: const Text('Result', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('The winning number is:', style: TextStyle(fontSize: 18, color: Colors.black87)),
              const SizedBox(height: 20),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors[result - 1],
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
                ),
                child: Center(
                  child: Text(
                    '$result',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Lucky Spin',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Pacifico'),
              ),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _animation.value,
                          child: child,
                        );
                      },
                      child: CustomPaint(
                        painter: WheelPainter(colors: colors),
                      ),
                    ),
                  ),
                  const PointerPainter(),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSpinning ? null : _spinWheel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: Text(
                  _isSpinning ? 'Spinning...' : 'SPIN',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class WheelPainter extends CustomPainter {
  final List<Color> colors;

  WheelPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;

    for (int i = 0; i < 10; i++) {
      final double startAngle = i * (2 * pi / 10);
      final double sweepAngle = 2 * pi / 10;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = colors[i];

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final double textAngle = startAngle + sweepAngle / 2;
      final double textRadius = radius * 0.75;
      final double textX = centerX + textRadius * cos(textAngle) - textPainter.width / 2;
      final double textY = centerY + textRadius * sin(textAngle) - textPainter.height / 2;

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(textAngle + pi / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // Draw outer circle
    final outerCirclePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(centerX, centerY), radius, outerCirclePaint);

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(Offset(centerX, centerY), 15, innerCirclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PointerPainter extends StatelessWidget {
  const PointerPainter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PointerPainter(),
      size: const Size(78, 34),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(pi+10.2 / 2);

    // Translate back to adjust for the rotation
    canvas.translate(-size.height / 2, -size.width / 2);

    final Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.height / 2, 0)
      ..lineTo(-4, size.width * 0.6)
      ..quadraticBezierTo(size.height / 2, size.width, size.height, size.width * 0.6)
      ..close();

    canvas.drawPath(path, paint);

    // Draw a small circle at the base of the pointer
    final circlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.height / 2, size.width * 0.6), 5, circlePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}