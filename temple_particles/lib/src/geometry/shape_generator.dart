import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vm;

/// Geometric shape generation algorithms
class ShapeGenerator {
  /// Generate a sphere using Fibonacci spiral distribution for even spacing
  static List<vm.Vector3> sphere(int n, double r) {
    final out = <vm.Vector3>[];
    final gap = math.pi * (math.sqrt(5) - 1);
    final radius = r * 1.4; // Consistent scale with other shapes
    
    for (int i = 0; i < n; i++) {
      final y = 1 - (i / (n - 1)) * 2;
      final rad = math.sqrt(1 - y * y);
      final theta = gap * i;
      out.add(vm.Vector3(
        math.cos(theta) * rad * radius,
        y * radius,
        math.sin(theta) * rad * radius,
      ));
    }
    return out;
  }
  
  /// Generate a cube with random distribution across six faces
  static List<vm.Vector3> cube(int n, double s) {
    final out = <vm.Vector3>[];
    final h = s * 1.4; // Consistent scale with other shapes
    final rng = math.Random(42);
    
    for (int i = 0; i < n; i++) {
      final f = rng.nextInt(6); 
      final u = rng.nextDouble() * h * 2 - h; 
      final v = rng.nextDouble() * h * 2 - h;
      
      switch (f) {
        case 0: out.add(vm.Vector3( h, u, v)); break;
        case 1: out.add(vm.Vector3(-h, u, v)); break;
        case 2: out.add(vm.Vector3(u,  h, v)); break;
        case 3: out.add(vm.Vector3(u, -h, v)); break;
        case 4: out.add(vm.Vector3(u, v,  h)); break;
        case 5: out.add(vm.Vector3(u, v, -h)); break;
      }
    }
    return out;
  }
  
  /// Generate a pyramid with weighted distribution between base and triangular faces
  static List<vm.Vector3> pyramid(int n, double s) {
    final out = <vm.Vector3>[];
    final h = s * 1.4; // Consistent scale with other shapes (height)
    final hb = s * 1.4; // Consistent scale with other shapes (base)
    final rng = math.Random(137);
    final apex = vm.Vector3(0, h / 2, 0);
    final base = [
      vm.Vector3(-hb, -h / 2, -hb),
      vm.Vector3( hb, -h / 2, -hb),
      vm.Vector3( hb, -h / 2,  hb),
      vm.Vector3(-hb, -h / 2,  hb),
    ];
    final baseArea = s * s;
    final sideArea = .5 * s * math.sqrt(h * h + hb * hb);
    final baseW = baseArea / (baseArea + 4 * sideArea);

    for (int i = 0; i < n; i++) {
      if (rng.nextDouble() < baseW) {
        final u = rng.nextDouble(), v = rng.nextDouble();
        final p1 = base[0] + (base[1] - base[0]) * u;
        final p2 = base[3] + (base[2] - base[3]) * u;
        final p  = p1 + (p2 - p1) * v;
        out.add(p);
      } else {
        final face = rng.nextInt(4);
        final v1 = base[face], v2 = base[(face + 1) % 4];
        double u = rng.nextDouble(), v = rng.nextDouble();
        if (u + v > 1) { u = 1 - u; v = 1 - v; }
        final p = v1 + (v2 - v1) * u + (apex - v1) * v;
        out.add(p);
      }
    }
    return out;
  }
  
  /// Generate all three shapes
  static List<List<vm.Vector3>> generateAllShapes(int particleCount, double shapeSize) {
    return [
      sphere(particleCount, shapeSize),
      cube(particleCount, shapeSize),
      pyramid(particleCount, shapeSize),
    ];
  }
} 