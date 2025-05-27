/// Configuration constants for the particle system
class ParticleConfig {
  static const int particleCount = 900;          // 500 – 1000 mobile sweet-spot
  static const int starCount     = 100;
  static const double shapeSize  = 100.0;       // Larger size for Canvas rendering

  static const morphDur   = Duration(milliseconds: 3500);
  static const targetFps  = 24;

  // Idle
  static const idleRot    = 0.08;

  // Visual
  static const morphSize  = 0.175;
  static const morphBright= 0.25;
  static const partSizeLo = 0.3;
  static const partSizeHi = 0.5;
} 