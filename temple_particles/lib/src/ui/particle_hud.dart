import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/particle_state.dart';

/// HUD overlay widget for displaying morphing status and controls
class ParticleHUD extends StatelessWidget {
  const ParticleHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0x59191e32),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Consumer<MorphState>(builder: (_, m, __) {
            const names = ['Sphere', 'Cube', 'Pyramid'];
            return Text(
              m.busy ? 'Morphing…'
                     : 'Shape: ${names[m.currentShape]}  (auto-morphing)',
              style: TextStyle(fontSize: 14, color: Colors.white, shadows: [
                Shadow(color: m.busy ? const Color(0xccff9632) : const Color(0xcc0080ff),
                       blurRadius: m.busy ? 8 : 5),
              ]),
            );
          }),
        ),
      ),
    );
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