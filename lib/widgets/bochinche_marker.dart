import 'package:flutter/material.dart';

class BochincheMarker extends StatelessWidget {
  final IconData iconContent;
  final double size;

  const BochincheMarker({
    super.key,
    required this.iconContent,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The base pin shape
          CustomPaint(
            size: Size(size, size),
            painter: _PinPainter(
              pinColor: const Color(0xFF330033),
              borderColor: Colors.white,
            ),
          ),
          // The interior icon
          Positioned(
            top: size * 0.15, // Centered in the rounded top part
            child: Stack(
              children: [
                // Icon border (glow/stroke effect)
                Text(
                  String.fromCharCode(iconContent.codePoint),
                  style: TextStyle(
                    inherit: false,
                    color: Colors.transparent,
                    fontSize: size * 0.45,
                    fontFamily: iconContent.fontFamily,
                    package: iconContent.fontPackage,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.white,
                        offset: Offset.zero,
                      ),
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.white,
                        offset: Offset.zero,
                      ),
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.white,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
                // Main yellow icon
                Icon(
                  iconContent,
                  color: const Color(0xFFFFB822),
                  size: size * 0.45,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color pinColor;
  final Color borderColor;

  _PinPainter({required this.pinColor, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Draw a custom pin shape similar to the image
    // Upper part is a circle, lower part tapers to a point
    path.moveTo(width / 2, height); // Bottom point
    
    // Bottom-right curve
    path.quadraticBezierTo(
      width * 0.9, height * 0.7,
      width, height * 0.4,
    );
    
    // Top circle arc
    path.arcToPoint(
      Offset(0, height * 0.4),
      radius: Radius.circular(width / 2),
      clockwise: false,
    );
    
    // Bottom-left curve
    path.quadraticBezierTo(
      width * 0.1, height * 0.7,
      width / 2, height,
    );
    
    path.close();

    // Draw main pin
    canvas.drawPath(path, paint);

    // Draw inner border
    final Rect innerRect = Rect.fromLTWH(
      width * 0.08, 
      width * 0.08, 
      width * 0.84, 
      width * 0.84
    );
    
    // We want the border to follow the shape, but slightly smaller
    final innerPath = Path();
    final innerFactor = 0.85;
    final offsetX = width * (1 - innerFactor) / 2;
    final offsetY = height * (1 - innerFactor) / 2;
    
    innerPath.moveTo(width / 2, height * 0.95);
    innerPath.quadraticBezierTo(
      width * 0.85, height * 0.7,
      width * 0.92, height * 0.4,
    );
    innerPath.arcToPoint(
      Offset(width * 0.08, height * 0.4),
      radius: Radius.circular(width * 0.42),
      clockwise: false,
    );
    innerPath.quadraticBezierTo(
      width * 0.15, height * 0.7,
      width / 2, height * 0.95,
    );
    innerPath.close();
    
    canvas.drawPath(innerPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
