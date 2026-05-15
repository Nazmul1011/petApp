import 'package:flutter/material.dart';

class PetPopOverlay extends StatefulWidget {
  final String imagePath;
  final VoidCallback onFinish;

  const PetPopOverlay({
    super.key,
    required this.imagePath,
    required this.onFinish,
  });

  @override
  State<PetPopOverlay> createState() => _PetPopOverlayState();
}

class _PetPopOverlayState extends State<PetPopOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    // 2 seconds total — the 'Medium' sweet spot
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // More gradual pop in (40% of time) and stay (60% of time)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40, // 0.8 seconds to pop in — feels 'Medium' and smooth
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.15),
        weight: 60, // Stay for the rest
      ),
    ]).animate(_controller);

    // Smooth fade transitions matched to the scale
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20, // Fade in
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60, // Stay
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20, // Fade out
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                widget.imagePath,
                width: 260, // Slightly larger for more impact
                height: 260,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
