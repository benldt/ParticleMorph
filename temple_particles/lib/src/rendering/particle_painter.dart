import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;
import '../config/particle_config.dart';
import '../state/particle_state.dart';

/// Custom painter for rendering particles, stars, and touch effects
class ParticlePainter extends CustomPainter {
  final List<vm.Vector3> particles;
  final List<vm.Vector3> stars;
  final List<Color> particleColors;
  final List<Color> starColors;
  final List<double> particleSizes;
  final List<double> starSizes;
  final List<double> effects;
  final double rotationY;
  final MorphState morphState;
  final bool touchActive;
  final Offset touchPos;

  const ParticlePainter({
    required this.particles,
    required this.stars,
    required this.particleColors,
    required this.starColors,
    required this.particleSizes,
    required this.starSizes,
    required this.effects,
    required this.rotationY,
    required this.morphState,
    required this.touchActive,
    required this.touchPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = math.min(size.width, size.height) / 400;

    // Draw stars first
    for (int i = 0; i < stars.length; i++) {
      final star = _project3D(stars[i], center, scale, rotationY);
      if (star != null) {
        final paint = Paint()
          ..color = starColors[i]
          ..style = PaintingStyle.fill;
        canvas.drawCircle(star, starSizes[i] * scale, paint);
      }
    }

    // Draw touch indicator when active
    if (touchActive) {
      final paint = Paint()
        ..color = Colors.blueAccent.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      
      // Ripple effect - larger and more visible
      for (int i = 4; i > 0; i--) {
        paint.color = Colors.blueAccent.withOpacity(0.15 * i);
        canvas.drawCircle(touchPos, 30.0 * i, paint);
      }
      
      // Central bright core
      paint.color = Colors.blueAccent.withOpacity(0.8);
      canvas.drawCircle(touchPos, 8.0, paint);
    }

    // Draw particles
    for (int i = 0; i < particles.length; i++) {
      final particle = _project3D(particles[i], center, scale, rotationY);
      if (particle != null) {
        final effect = effects[i];
        final size = particleSizes[i] * scale * (1 + effect * ParticleConfig.morphSize);
        final color = particleColors[i];
        
        final paint = Paint()
          ..color = Color.fromRGBO(
            ((color.r * 255.0).round() * (1 + effect * ParticleConfig.morphBright)).clamp(0, 255).round(),
            ((color.g * 255.0).round() * (1 + effect * ParticleConfig.morphBright)).clamp(0, 255).round(),
            ((color.b * 255.0).round() * (1 + effect * ParticleConfig.morphBright)).clamp(0, 255).round(),
            color.a,
          )
          ..style = PaintingStyle.fill;
        canvas.drawCircle(particle, size, paint);
      }
    }
  }

  /// Project 3D point to 2D screen coordinates with perspective
  Offset? _project3D(vm.Vector3 point, Offset center, double scale, double rotY) {
    // Simple 3D to 2D projection with rotation
    final cosY = math.cos(rotY);
    final sinY = math.sin(rotY);
    
    final rotatedX = point.x * cosY - point.z * sinY;
    final rotatedZ = point.x * sinY + point.z * cosY + 300; // Add depth offset
    
    if (rotatedZ <= 0) return null; // Behind camera
    
    final perspective = 200 / rotatedZ;
    final x = center.dx + rotatedX * scale * perspective;
    final y = center.dy - point.y * scale * perspective;
    
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return true; // Always repaint for animation
  }
} 