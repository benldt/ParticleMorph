import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../config/particle_config.dart';
import '../state/particle_state.dart';
import '../geometry/shape_generator.dart';
import '../physics/particle_physics.dart';
import '../rendering/particle_painter.dart';
import '../ui/particle_hud.dart';
import '../utils/simplex_noise.dart';

/// Core particle engine widget that coordinates all functionality
class ParticleEngine extends StatefulWidget {
  const ParticleEngine({
    super.key,
    required this.hideHud,
    required this.enableTouchAttract,
  });

  final bool hideHud;
  final bool enableTouchAttract;

  @override
  ParticleEngineState createState() => ParticleEngineState();
}

class ParticleEngineState extends State<ParticleEngine> with TickerProviderStateMixin {
  // Particle data
  late List<vm.Vector3> _particles;
  late List<vm.Vector3> _targets;
  late List<double> _sizes;
  late List<double> _effects;
  late List<Color> _colors;

  // Star system
  late List<vm.Vector3> _stars;
  late List<double> _starSizes;
  late List<Color> _starColors;

  // Shape data
  late List<List<vm.Vector3>> _shapes;
  
  // Noise generator
  final _noise = SimplexNoise(math.Random(42));

  // Animation controllers
  late final AnimationController _morphController;
  late final Animation<double> _morphAnimation;

  // Timers
  Timer? _ticker;
  Timer? _morphTimer;
  DateTime _lastTime = DateTime.now();
  double _elapsed = 0;
  bool _ready = false;
  
  // Rotation
  double _rotationY = 0;

  // Touch interaction state
  bool _touchActive = false;
  Offset _touchPos = Offset.zero;
  late List<vm.Vector3> _savedPositions;
  late List<double> _savedEffects;
  
  late AnimationController _returnController;
  late Animation<double> _returnAnimation;
  
  double _savedMorphProgress = 0;
  bool _wasInMorph = false;

  @override
  void initState() {
    super.initState();
    
    _morphController = AnimationController(
      vsync: this,
      duration: ParticleConfig.morphDur,
    );
    
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    )..addListener(() {
      context.read<MorphState>().set(_morphAnimation.value);
    })..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishMorph();
      }
    });
    
    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _returnAnimation = CurvedAnimation(
      parent: _returnController,
      curve: Curves.easeOutCubic,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _morphTimer?.cancel();
    _morphController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  /// Initialize the particle system
  Future<void> _boot() async {
    final loadState = context.read<LoadState>();
    
    try {
      loadState.upd(0.1, "Building shapes");
      _shapes = ShapeGenerator.generateAllShapes(
        ParticleConfig.particleCount,
        ParticleConfig.shapeSize,
      );

      loadState.upd(0.3, "Allocating particles");
      _particles = List.generate(
        ParticleConfig.particleCount,
        (i) => _shapes[0][i].clone(),
      );
      _targets = List.generate(
        ParticleConfig.particleCount,
        (i) => _shapes[0][i].clone(),
      );
      _sizes = List.generate(
        ParticleConfig.particleCount,
        (i) => ParticleConfig.partSizeLo + 
               math.Random().nextDouble() * 
               (ParticleConfig.partSizeHi - ParticleConfig.partSizeLo),
      );
      _effects = List.filled(ParticleConfig.particleCount, 0.0);
      _colors = List.generate(ParticleConfig.particleCount, (i) => Colors.blue);
      
      // Initialize touch state arrays
      _savedPositions = List.generate(
        ParticleConfig.particleCount,
        (i) => vm.Vector3.zero(),
      );
      _savedEffects = List.filled(ParticleConfig.particleCount, 0.0);
      
      loadState.upd(0.6, "Creating stars");
      _stars = [];
      _starSizes = [];
      _starColors = [];
      ParticlePhysics.initStars(_stars, _starSizes, _starColors, ParticleConfig.starCount);
      
      loadState.upd(0.8, "Coloring particles");
      _recolor();

      loadState.upd(0.9, "Starting animation");
      _ready = true;
      _ticker = Timer.periodic(
        Duration(milliseconds: (1000 / ParticleConfig.targetFps).round()),
        (_) => _animate(),
      );
      
      // Start automatic morphing
      Timer(const Duration(seconds: 3), () {
        _autoMorph();
        _morphTimer = Timer.periodic(
          const Duration(seconds: 5),
          (_) => _autoMorph(),
        );
      });
      
      loadState.upd(1, "Ready!");
      setState(() {});
    } catch (e, stackTrace) {
      debugPrint("Boot error: $e\n$stackTrace");
      loadState.upd(0, "Error: $e");
    }
  }

  /// Main animation loop
  void _animate() {
    if (!_ready || !mounted) return;
    
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1e6;
    _lastTime = now;
    _elapsed += dt;
    
    // Only rotate when not touching
    if (!_touchActive) {
      _rotationY += dt * ParticleConfig.idleRot;
    }

    // Handle different states
    if (_touchActive) {
      _stepAttract(dt);
    } else if (_returnController.isAnimating) {
      _stepReturn();
    } else {
      final morphState = context.read<MorphState>();
      morphState.busy ? _stepMorph(dt) : _stepIdle(dt);
    }
    
    setState(() {});
  }

  /// Apply morphing animation
  void _stepMorph(double dt) {
    final morphState = context.read<MorphState>();
    ParticlePhysics.stepMorph(
      _particles,
      _targets,
      _effects,
      morphState.t,
      _elapsed,
    );
  }

  /// Apply idle breathing animation
  void _stepIdle(double dt) {
    final morphState = context.read<MorphState>();
    ParticlePhysics.stepIdle(
      _particles,
      _effects,
      _shapes,
      morphState.currentShape,
      _elapsed,
    );
  }

  /// Apply touch-attract physics
  void _stepAttract(double dt) {
    ParticlePhysics.stepAttract(
      _particles,
      _effects,
      _touchPos,
      _rotationY,
      MediaQuery.of(context).size,
      dt,
    );
  }

  /// Apply return animation
  void _stepReturn() {
    final morphState = context.read<MorphState>();
    ParticlePhysics.stepReturn(
      _particles,
      _savedPositions,
      _effects,
      _savedEffects,
      _shapes,
      morphState.currentShape,
      _returnAnimation.value,
      _elapsed,
      _wasInMorph,
    );
    
    // Note: Return animation completion is handled in _onTouchEnd with Timer
    // This matches the original implementation
  }

  /// Update particle colors
  void _recolor() {
    ParticlePhysics.recolor(_particles, _colors, _noise, ParticleConfig.shapeSize);
  }

  /// Start morphing to next shape
  void _autoMorph() {
    final morphState = context.read<MorphState>();
    // Prevent morphing during touch or return animation
    if (_touchActive || _returnController.isAnimating || _morphController.isAnimating) return;
    
    final nextShape = (morphState.currentShape + 1) % 3;
    _startMorph(nextShape);
  }

  /// Initiate morphing animation
  void _startMorph(int targetShape) {
    final morphState = context.read<MorphState>();
    if (morphState.busy) return;
    
    morphState.begin(targetShape);
    for (int i = 0; i < _particles.length; i++) {
      _targets[i] = _shapes[targetShape][i];
    }
    _morphController.reset();
    _morphController.forward();
  }

  /// Complete morphing animation
  void _finishMorph() {
    final morphState = context.read<MorphState>();
    
    // Apply current breathing scale to maintain continuity
    final scale = 1 + math.sin(_elapsed * 0.5) * 0.015;
    _particles = _targets.map((v) => v * scale).toList();
    
    for (int i = 0; i < _effects.length; i++) {
      _effects[i] = 0;
    }
    _recolor();
    morphState.end();
    _morphController.reset();
  }

  /// Touch interaction handlers
  void _onTouchStart(Offset position) {
    if (!widget.enableTouchAttract || !_ready) return;
    
    setState(() {
      _touchActive = true;
      _touchPos = position;
      
      // Save current state
      _savedPositions = _particles.map((p) => p.clone()).toList();
      _savedEffects = List<double>.from(_effects);
      
      // Handle morph interruption
      final morphState = context.read<MorphState>();
      if (morphState.busy) {
        _wasInMorph = true;
        _savedMorphProgress = morphState.t;
        _morphController.stop();
      } else {
        _wasInMorph = false;
      }
      
      // Stop any return animation
      _returnController.stop();
      _returnController.reset();
    });
  }

  void _onTouchUpdate(Offset position) {
    if (!_touchActive) return;
    setState(() {
      _touchPos = position;
    });
  }

  void _onTouchEnd() {
    if (!_touchActive) return;
    
    setState(() {
      _touchActive = false;
      
      // Start return animation
      _returnController.forward(from: 0);
      
      // Resume morph if it was interrupted - using Timer like original
      if (_wasInMorph) {
        Timer(const Duration(milliseconds: 50), () {
          if (mounted && !_touchActive) {
            _morphController.forward(from: _savedMorphProgress);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadState>(
      builder: (context, loadState, child) {
        if (!_ready) {
          return const LoadingScreen();
        }

        Widget mainWidget = Stack(
          children: [
            // Main particle canvas
            CustomPaint(
              painter: ParticlePainter(
                particles: _particles,
                stars: _stars,
                particleColors: _colors,
                starColors: _starColors,
                particleSizes: _sizes,
                starSizes: _starSizes,
                effects: _effects,
                rotationY: _rotationY,
                morphState: context.watch<MorphState>(),
                touchActive: _touchActive,
                touchPos: _touchPos,
              ),
              size: Size.infinite,
            ),
            
            // HUD overlay
            if (!widget.hideHud) const ParticleHUD(),
          ],
        );

        // Wrap with gesture detector for touch interaction
        if (widget.enableTouchAttract) {
          mainWidget = GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (details) => _onTouchStart(details.localPosition),
            onPanUpdate: (details) => _onTouchUpdate(details.localPosition),
            onPanEnd: (_) => _onTouchEnd(),
            onPanCancel: () => _onTouchEnd(),
            child: mainWidget,
          );
        }

        return Container(
          color: Colors.black,
          child: mainWidget,
        );
      },
    );
  }
} 