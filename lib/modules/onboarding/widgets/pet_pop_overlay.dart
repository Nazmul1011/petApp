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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) {
      // Small pause at the end before dismissing
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onFinish();
        }
      });
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
              padding: const EdgeInsets.all(
                20,
              ), // Reduced padding for better scale
              child: Image.asset(
                widget.imagePath,
                width: 240, // Increased size slightly
                height: 240,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
