import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SoundWaveAnimator extends StatefulWidget {
  final bool isAnimating;
  final Color waveColor;
  final double height;

  const SoundWaveAnimator({
    super.key,
    required this.isAnimating,
    this.waveColor = AppColors.emeraldLight,
    this.height = 18,
  });

  @override
  State<SoundWaveAnimator> createState() => _SoundWaveAnimatorState();
}

class _SoundWaveAnimatorState extends State<SoundWaveAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SoundWaveAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isAnimating && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final val = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBar(widget.isAnimating ? (0.3 + 0.7 * ((val + 0.1) % 1.0)) : 0.3),
            const SizedBox(width: 3),
            _buildBar(widget.isAnimating ? (0.4 + 0.6 * ((val + 0.4) % 1.0)) : 0.45),
            const SizedBox(width: 3),
            _buildBar(widget.isAnimating ? (0.2 + 0.8 * ((val + 0.7) % 1.0)) : 0.6),
            const SizedBox(width: 3),
            _buildBar(widget.isAnimating ? (0.3 + 0.7 * ((val + 0.2) % 1.0)) : 0.35),
          ],
        );
      },
    );
  }

  Widget _buildBar(double factor) {
    return Container(
      width: 3.5,
      height: widget.height * factor.clamp(0.2, 1.0),
      decoration: BoxDecoration(
        color: widget.waveColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
