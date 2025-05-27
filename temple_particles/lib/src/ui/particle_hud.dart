import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/particle_state.dart';

/// HUD overlay widget for displaying morphing status and controls
class ParticleHUD extends StatelessWidget {
  const ParticleHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MorphState>(
      builder: (context, morphState, child) {
        return Positioned(
          top: 80,
          left: 30,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shape: ${_getShapeName(morphState.shape)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (morphState.busy) ...[
                  Text(
                    'Morphing: ${(morphState.t * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: morphState.t,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text(
                    'Tap to morph',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getShapeName(int shapeIndex) {
    switch (shapeIndex) {
      case 0: return 'Sphere';
      case 1: return 'Cube';
      case 2: return 'Pyramid';
      default: return 'Unknown';
    }
  }
}

/// Loading screen widget for displaying boot progress
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadState>(
      builder: (context, loadState, child) {
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.scatter_plot_rounded,
                  color: Colors.blueAccent,
                  size: 64,
                ),
                const SizedBox(height: 32),
                Text(
                  loadState.s,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 200,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: loadState.p,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(loadState.p * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 