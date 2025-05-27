import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vm;
import '../utils/simplex_noise.dart';

/// Physics engine for particle animation, morphing, and touch interaction
class ParticlePhysics {
  /// Initialize stars with random positions and properties
  static void initStars(
    List<vm.Vector3> stars,
    List<double> starSizes,
    List<Color> starColors,
    int starCount,
  ) {
    stars.clear();
    starSizes.clear();
    starColors.clear();
    
    final rng = math.Random();
    for (int i = 0; i < starCount; i++) {
      final th = rng.nextDouble() * math.pi * 2;
      final ph = math.acos(2 * rng.nextDouble() - 1);
      final r = 300 + rng.nextDouble() * 200;
      stars.add(vm.Vector3(
        r * math.sin(ph) * math.cos(th),
        r * math.sin(ph) * math.sin(th),
        r * math.cos(ph),
      ));

      final b = .3 + rng.nextDouble() * .3;
      starColors.add(Color.fromRGBO(
        (b * 0.8 * 255).round(),
        (b * 0.9 * 255).round(),
        (b * 255).round(),
        0.7
      ));
      starSizes.add(rng.nextDouble() * .8 + .4);
    }
  }

  /// Apply morphing animation between shapes
  static void stepMorph(
    List<vm.Vector3> particles,
    List<vm.Vector3> targets,
    List<double> effects,
    double t,
    double elapsed,
  ) {
    final eff = math.sin(t * math.pi);
    final scale = 1 + math.sin(elapsed * .5) * .015;

    for (int i = 0; i < particles.length; i++) {
      final basePos = particles[i] * (1 - t) + targets[i] * t;
      particles[i] = basePos * scale;
      effects[i] = eff;
    }
  }

  /// Apply idle breathing animation
  static void stepIdle(
    List<vm.Vector3> particles,
    List<double> effects,
    List<List<vm.Vector3>> shapes,
    int currentShape,
    double elapsed,
  ) {
    final scale = 1 + math.sin(elapsed * .5) * .015;
    for (int i = 0; i < particles.length; i++) {
      final base = shapes[currentShape][i];
      particles[i] = base * scale;
      effects[i] = 0;
    }
  }

  /// Apply touch-attract gravity physics
  static void stepAttract(
    List<vm.Vector3> particles,
    List<double> effects,
    Offset touchPos,
    double rotationY,
    Size screenSize,
    double dt,
  ) {
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    final scale = math.min(screenSize.width, screenSize.height) / 400;
    
    // Unproject touch position to 3D world coordinates
    final screenX = (touchPos.dx - center.dx) / scale;
    final screenY = -(touchPos.dy - center.dy) / scale;
    
    final perspective = 200.0 / 300.0;
    final worldX = screenX / perspective;
    final worldY = screenY / perspective;
    
    final cosY = math.cos(-rotationY);
    final sinY = math.sin(-rotationY);
    
    final touchWorld = vm.Vector3(
      worldX * cosY - 0 * sinY,
      worldY,
      worldX * sinY + 0 * cosY,
    );
    
    for (int i = 0; i < particles.length; i++) {
      final particle = particles[i];
      final toTouch = touchWorld - particle;
      final distance = toTouch.length;
      
      if (distance > 0.1) {
        final strength = 10000.0 / (distance + 10.0);
        final velocity = toTouch.normalized() * strength * dt;
        
        final tangent = vm.Vector3(
          -toTouch.y,
          toTouch.x,
          toTouch.z * 0.5,
        ).normalized();
        final orbitalSpeed = 100000.0 / (distance + 10.0);
        
        if (distance < 25.0) {
          // Close particles: reduced gravity + strong orbital motion
          final reducedVelocity = velocity * 0.3;
          final strongOrbital = tangent * orbitalSpeed * dt * 2.0;
          particles[i] = particle + reducedVelocity + strongOrbital;
        } else {
          // Normal particles: full gravity + orbital motion
          particles[i] = particle + velocity + (tangent * orbitalSpeed * dt);
        }
      }
      
      effects[i] = math.min(1.0, 50.0 / (distance + 5.0));
    }
  }

  /// Apply return animation from touch interaction
  static void stepReturn(
    List<vm.Vector3> particles,
    List<vm.Vector3> savedPositions,
    List<double> effects,
    List<double> savedEffects,
    List<List<vm.Vector3>> shapes,
    int currentShape,
    double t,
    double elapsed,
    bool wasInMorph,
  ) {
    final easeT = Curves.easeOutBack.transform(t);
    
    for (int i = 0; i < particles.length; i++) {
      particles[i] = particles[i] * (1 - easeT) + savedPositions[i] * easeT;
      effects[i] = effects[i] * (1 - t) + savedEffects[i] * t;
    }
    
    if (!wasInMorph) {
      final scale = 1 + math.sin(elapsed * 0.5) * 0.015;
      for (int i = 0; i < savedPositions.length; i++) {
        final base = shapes[currentShape][i];
        savedPositions[i] = base * scale;
      }
    }
  }

  /// Generate particle colors based on position and noise
  static void recolor(
    List<vm.Vector3> particles,
    List<Color> colors,
    SimplexNoise noise,
    double shapeSize,
  ) {
    final maxR = shapeSize * 1.1;
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final d = p.length;
      final t = (d / maxR).clamp(0, 1).toDouble();
      final n = (noise.noise3D(p.x * .01, p.y * .01, p.z * .01) + 1) * .5;

      final h = 200 / 360;
      final s = 0.6 + (n * 0.1);
      final l = 0.55 + 0.45 * t;
      colors[i] = _hslToColor(h, s, l);
    }
  }

  /// Convert HSL color to RGB
  static Color _hslToColor(double h, double s, double l) {
    double q = l < .5 ? l * (1 + s) : l + s - l * s;
    double p = 2 * l - q;
    double r = _hue(p, q, h + 1 / 3);
    double g = _hue(p, q, h);
    double b = _hue(p, q, h - 1 / 3);
    return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1);
  }

  /// Helper for HSL to RGB conversion
  static double _hue(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }
} 