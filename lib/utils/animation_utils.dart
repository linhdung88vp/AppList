import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimationUtils {
  // Shimmer loading effect
  static Widget shimmerLoading({
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerLoadingWidget(
      child: child,
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
    );
  }

  // Pulse animation
  static Widget pulseAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return PulseAnimationWidget(
      child: child,
      duration: duration,
    );
  }

  // Fade in animation
  static Widget fadeInAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOut,
  }) {
    return FadeInAnimationWidget(
      child: child,
      duration: duration,
      curve: curve,
    );
  }

  // Slide in animation
  static Widget slideInAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    Curve curve = Curves.easeOutCubic,
    Offset begin = const Offset(0, 0.3),
  }) {
    return SlideInAnimationWidget(
      child: child,
      duration: duration,
      curve: curve,
      begin: begin,
    );
  }

  // Scale animation
  static Widget scaleAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.elasticOut,
  }) {
    return ScaleAnimationWidget(
      child: child,
      duration: duration,
      curve: curve,
    );
  }

  // Bounce animation
  static Widget bounceAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return BounceAnimationWidget(
      child: child,
      duration: duration,
    );
  }

  // Floating animation
  static Widget floatingAnimation({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return FloatingAnimationWidget(
      child: child,
      duration: duration,
    );
  }

  // Gradient text animation
  static Widget gradientTextAnimation({
    required String text,
    required TextStyle style,
    List<Color> colors = const [
      Color(0xFF6B46C1),
      Color(0xFF8B5CF6),
      Color(0xFFA855F7),
      Color(0xFF7C3AED),
    ],
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    return GradientTextAnimationWidget(
      text: text,
      style: style,
      colors: colors,
      duration: duration,
    );
  }
}

// Shimmer Loading Widget
class ShimmerLoadingWidget extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Pulse Animation Widget
class PulseAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PulseAnimationWidget({
    super.key,
    required this.child,
    required this.duration,
  });

  @override
  State<PulseAnimationWidget> createState() => _PulseAnimationWidgetState();
}

class _PulseAnimationWidgetState extends State<PulseAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Fade In Animation Widget
class FadeInAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const FadeInAnimationWidget({
    super.key,
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<FadeInAnimationWidget> createState() => _FadeInAnimationWidgetState();
}

class _FadeInAnimationWidgetState extends State<FadeInAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

// Slide In Animation Widget
class SlideInAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset begin;

  const SlideInAnimationWidget({
    super.key,
    required this.child,
    required this.duration,
    required this.curve,
    required this.begin,
  });

  @override
  State<SlideInAnimationWidget> createState() => _SlideInAnimationWidgetState();
}

class _SlideInAnimationWidgetState extends State<SlideInAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

// Scale Animation Widget
class ScaleAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ScaleAnimationWidget({
    super.key,
    required this.child,
    required this.duration,
    required this.curve,
  });

  @override
  State<ScaleAnimationWidget> createState() => _ScaleAnimationWidgetState();
}

class _ScaleAnimationWidgetState extends State<ScaleAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Bounce Animation Widget
class BounceAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BounceAnimationWidget({
    super.key,
    required this.child,
    required this.duration,
  });

  @override
  State<BounceAnimationWidget> createState() => _BounceAnimationWidgetState();
}

class _BounceAnimationWidgetState extends State<BounceAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

// Floating Animation Widget
class FloatingAnimationWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FloatingAnimationWidget({
    super.key,
    required this.child,
    required this.duration,
  });

  @override
  State<FloatingAnimationWidget> createState() => _FloatingAnimationWidgetState();
}

class _FloatingAnimationWidgetState extends State<FloatingAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_animation.value) * 8),
          child: widget.child,
        );
      },
    );
  }
}

// Gradient Text Animation Widget
class GradientTextAnimationWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;
  final Duration duration;

  const GradientTextAnimationWidget({
    super.key,
    required this.text,
    required this.style,
    required this.colors,
    required this.duration,
  });

  @override
  State<GradientTextAnimationWidget> createState() => _GradientTextAnimationWidgetState();
}

class _GradientTextAnimationWidgetState extends State<GradientTextAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: widget.colors,
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}
