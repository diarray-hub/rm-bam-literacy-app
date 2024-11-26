import 'package:flutter/material.dart';

class FloatingHintButton extends StatefulWidget {
  final VoidCallback onPressed;
  final VoidCallback onLongPress;

  const FloatingHintButton({
    Key? key,
    required this.onPressed,
    required this.onLongPress,
  }) : super(key: key);

  @override
  _FloatingHintButtonState createState() => _FloatingHintButtonState();
}

class _FloatingHintButtonState extends State<FloatingHintButton> {
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    // Show the hint when the widget is first built
    _showTemporaryHint();
  }

  void _showTemporaryHint() {
    setState(() {
      _showHint = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  void _replayHint() {
    setState(() {
      _showHint = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showHint = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow overflow for the hint bubble
      alignment: Alignment.center,
      children: [
        if (_showHint)
          Positioned(
            bottom: 70,// Position the hint above the button
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hint Bubble
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "Long press to\nrecord again",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                // The triangle pointer
                CustomPaint(
                  size: const Size(20, 10),
                  painter: _TrianglePainter(color: Colors.black87),
                ),
              ],
            ),
          ),
        GestureDetector(
          onLongPress: () {
            widget.onLongPress();
            _replayHint(); // Replay the hint when long-pressed
          },
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: Colors.grey[350],
            child: const Icon(Icons.navigate_next, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0) // Top center
      ..lineTo(size.width, size.height) // Bottom right
      ..lineTo(0, size.height) // Bottom left
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) => false;
}