# Temple Particles - 3D Particle Morpher

A mobile-optimized Flutter package that renders a smooth 3D particle system capable of morphing between geometric shapes (Sphere → Cube → Pyramid) with beautiful visual effects.

## ✨ Features

- **3D Shape Morphing**: Seamless transitions between sphere, cube, and pyramid
- **Particle Effects**: 500-1000 particles with smooth Bezier motion
- **Mobile Optimized**: Targets 24 FPS on mid-range devices
- **Visual Effects**: 
  - Breathing animation during idle states
  - Morphing glow effects
  - Starfield background
  - HSL color gradients
- **Touch Controls**: Auto-rotation with touch interaction
- **Customizable**: Optional HUD, configurable particle count and effects

## 🎯 Performance

- **Target**: 24 FPS on iPhone 11 / Pixel 4 or better
- **Particle Count**: 500-1000 (optimized for mobile)
- **Rendering**: Custom Canvas painter (no WebGL dependency)

## 📱 Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/temple_particles.git
cd temple_particles
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the example:
```bash
cd example
flutter run
```

## 🚀 Usage

### Basic Usage
```dart
import 'package:temple_particles/particle_morpher.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: const ParticleMorpher(), // With HUD (default)
      ),
    );
  }
}
```

### Hide HUD
```dart
const ParticleMorpher(hideHud: true) // Particles only, no info overlay
```

## 🎮 Controls

- **Auto-morphing**: Automatically cycles through shapes every 5 seconds
- **Touch interaction**: Touch to pause auto-rotation
- **Smooth transitions**: 3.5 second morph duration with easing curves

## 🏗️ Project Structure

```
temple_particles/
├── lib/
│   ├── particle_morpher.dart    # Main widget
│   └── simplex_noise.dart       # Noise generation
├── example/                     # Example app
├── assets/                      # Shader files (unused in Canvas version)
└── README.md
```

## 🔧 Configuration

Key parameters in `_Cfg` class:
- `particleCount`: 500-1000 particles
- `morphDur`: 3.5 second transitions
- `targetFps`: 24 FPS target
- `shapeSize`: Base size of shapes

## 🎨 Technical Details

- **Rendering**: Custom `CustomPainter` for optimal mobile performance
- **Animation**: Provider state management with `AnimationController`
- **3D Projection**: Simple perspective projection with rotation
- **Shape Generation**: Algorithmic sphere, cube, and pyramid generation
- **Noise**: Simplex noise for organic movement patterns

## 📋 Requirements

- Flutter 3.22+
- Dart 3.3+
- iOS 12+ / Android API 21+

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by modern particle systems and 3D morphing demos
- Optimized for mobile Flutter applications
- Built for TempleApp integration

---

*Smooth, beautiful, mobile-optimized 3D particle morphing for Flutter* ✨ 