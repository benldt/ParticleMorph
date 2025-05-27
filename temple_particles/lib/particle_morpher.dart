// TempleApp – 3-Shape Particle Morpher
//
// Integration:
//   ❶ Add `temple_particles` directory to your repo.
//   ❷ In TempleApp's root pubspec.yaml, add:
//
//          path: modules/temple_particles
//
//   ❸ `import 'package:temple_particles/particle_morpher.dart'`
//   ❄ Embed `const ParticleMorpher()` anywhere in your widget tree.
//
// Tested on Flutter 3.22 / Dart 3.3 (iOS 17, Pixel 7).

library temple_particles;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/state/particle_state.dart';
import 'src/core/particle_engine.dart';

part 'simplex_noise.dart';

/// Public widget for the particle morpher system
class ParticleMorpher extends StatelessWidget {
  /// `hideHud`            → true: HUD hidden, false: HUD shown (default true)
  /// `enableTouchAttract` → Enable gravity-well touch interaction (default false)
  const ParticleMorpher({
    super.key,
    this.hideHud = true,
    this.enableTouchAttract = false,
  });

  final bool hideHud;
  final bool enableTouchAttract;

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MorphState()),
      ChangeNotifierProvider(create: (_) => LoadState()),
    ],
    child: ParticleEngine(
      hideHud: hideHud,
      enableTouchAttract: enableTouchAttract,
    ),
  );
} 