# TempleApp — 3-Shape Particle Morpher (Mobile-Optimised v1.0.0)

A self-contained Flutter package that renders a 500 – 1,000-point particle system able to morph between Sphere → Cube → Pyramid with Bezier-swarm motion, 3D/4D simplex-noise displacement, and a dim blue-white star-field backdrop.

Targets 24 FPS on mid-range phones while preserving all visual flair of the 15K-point desktop demo.

## Features

- **3D Particle System**: 900 interactive particles that can morph between three geometric shapes
- **Shape Morphing**: Smooth transitions between sphere, cube, and pyramid formations
- **Advanced Visual Effects**:
  - Bezier curve interpolation during morphing
  - 3D/4D simplex noise displacement for organic movement
  - Swirling particle motion during transitions
  - Dynamic color gradients based on particle position
- **Starfield Background**: 100 twinkling stars for atmospheric depth
- **Mobile Optimized**: Targets 24 FPS on mid-range devices
- **Interactive Controls**: Optional gravity-well touch interaction
- **Touch-Attract Feature**: Particles flow toward your finger with orbital motion (opt-in)

## Project Structure

```
temple_particles/
├── lib/
│   ├── particle_morpher.dart           ← Main public API widget
│   ├── simplex_noise.dart             ← Noise generation algorithms (part file)
│   └── src/                           ← Internal modular architecture
│       ├── config/
│       │   └── particle_config.dart   ← Configuration constants
│       ├── state/
│       │   └── particle_state.dart    ← Provider state management  
│       ├── geometry/
│       │   └── shape_generator.dart   ← Shape generation algorithms
│       ├── physics/
│       │   └── particle_physics.dart  ← Animation and touch physics
│       ├── rendering/
│       │   └── particle_painter.dart  ← Custom painter for Canvas rendering
│       ├── ui/
│       │   └── particle_hud.dart      ← HUD and loading screen components
│       ├── core/
│       │   └── particle_engine.dart   ← Main engine coordinating all systems
│       └── utils/
│           └── simplex_noise.dart     ← Standalone noise utility
├── example/                           ← Demo application
├── pubspec.yaml
└── README.md
```

## Quick Start

1. **Add to your Flutter project**:
   ```yaml
   # In your app's pubspec.yaml
   dependencies:
     temple_particles:
       path: path/to/temple_particles
   ```

2. **Import and use**:
   ```dart
   import 'package:temple_particles/particle_morpher.dart';
   
   // Basic usage
   const ParticleMorpher()
   
   // With touch interaction enabled
   const ParticleMorpher(
     enableTouchAttract: true,
     hideHud: false,
   )
   ```

3. **Run the project**:
   ```bash
   cd temple_particles
   flutter pub get
   flutter run
   ```

## API Reference

### ParticleMorpher Widget

```dart
class ParticleMorpher extends StatelessWidget {
  const ParticleMorpher({
    super.key,
    this.hideHud = true,                // Hide/show shape indicator
    this.enableTouchAttract = false,    // Enable gravity-well touch interaction
  });
}
```

### Parameters

- **hideHud** (bool): Controls visibility of the shape indicator HUD
  - `true` (default): HUD hidden for clean presentation
  - `false`: Shows current shape and morphing status

- **enableTouchAttract** (bool): Enables interactive touch-gravity feature
  - `false` (default): Passive viewing mode with auto-morphing
  - `true`: Particles respond to touch with gravity-well physics

## Dependencies

- **vector_math**: 3D vector mathematics
- **provider**: State management for UI updates
- **flutter/material**: Core Flutter framework

## Performance

- **Particle Count**: 900 particles (optimized for mobile)
- **Target FPS**: 24 FPS on mid-range devices
- **Memory Efficient**: Zero runtime allocations in animation loops
- **GPU Accelerated**: Uses hardware-accelerated WebGL rendering

## Controls

### Basic Mode
- **Auto-morphing**: Shapes change automatically every 5 seconds
- **Passive Viewing**: Watch the morphing animations

### Touch-Attract Mode (enableTouchAttract: true)
- **Touch & Hold**: Particles flow toward your finger like a gravity well
- **Drag**: Particles follow your finger in orbital patterns  
- **Release**: Particles smoothly return to their formation
- **During Morph**: Touch interrupts morphing; release resumes it
- **Visual Feedback**: Touch indicator with ripple effects

## Modular Architecture

The codebase has been refactored into a clean, maintainable modular structure:

### Core Modules

- **`config/`**: Configuration constants and settings
- **`state/`**: Provider-based state management for morph progress and loading
- **`geometry/`**: Shape generation algorithms (sphere, cube, pyramid)  
- **`physics/`**: Animation engine, touch interaction, and particle behavior
- **`rendering/`**: Custom painter for Canvas-based particle and star rendering
- **`ui/`**: HUD components and loading screens
- **`core/`**: Main particle engine that coordinates all systems
- **`utils/`**: Utility classes like SimplexNoise

### Public API

The main `particle_morpher.dart` provides a clean public interface while internally using the modular components. This separation allows for:

- **Maintainability**: Each module has a single responsibility
- **Testability**: Individual components can be tested in isolation  
- **Extensibility**: New features can be added without affecting existing code
- **Clean Dependencies**: Clear dependency hierarchy prevents circular imports

## Technical Details

### Shape Generation
- **Sphere**: Fibonacci spiral distribution for even spacing
- **Cube**: Random distribution across six faces
- **Pyramid**: Weighted distribution between base and triangular faces

### Animation System
- **Morphing**: Quadratic Bezier interpolation with intermediate swarm points
- **Idle Animation**: Gentle breathing and noise-based displacement
- **Effects**: Swirl rotation around quasi-random axes during transitions

### Shader Features
- **Particle Rendering**: Circular points with smooth alpha falloff
- **Dynamic Sizing**: Size changes during morphing for emphasis
- **Color Enhancement**: Brightness boosts during active transitions
- **Star Rendering**: Twinkling effect with distance-based sizing

## Integration Notes

This package is designed to be dropped directly into TempleApp or any Flutter application. The `ParticleMorpher` widget is self-contained and manages its own state through Provider.

The system automatically handles:
- WebGL context initialization
- Shader compilation and loading
- Asset management
- Performance optimization
- Error handling and graceful fallbacks

## Tested Platforms

- **iOS**: iPhone 11 and newer
- **Android**: Pixel 4 and equivalent
- **Flutter**: 3.22+ / Dart 3.3+

---

© 2025 TempleApp | MIT License 