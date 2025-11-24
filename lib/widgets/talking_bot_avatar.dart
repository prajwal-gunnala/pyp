import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animated bot avatar that syncs with speech
/// Uses a single Lottie animation with frame ranges:
/// - Idle: 0.0 to 0.3 (30% of animation)
/// - Talking: 0.3 to 1.0 (70% of animation)
class TalkingBotAvatar extends StatefulWidget {
  final bool isSpeaking;
  final double size;

  const TalkingBotAvatar({
    Key? key,
    required this.isSpeaking,
    this.size = 100,
  }) : super(key: key);

  @override
  State<TalkingBotAvatar> createState() => _TalkingBotAvatarState();
}

class _TalkingBotAvatarState extends State<TalkingBotAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Animation loop duration
    );

    // Start with idle animation
    _playIdleAnimation();
  }

  @override
  void didUpdateWidget(TalkingBotAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // When speaking state changes, switch animations
    if (widget.isSpeaking != oldWidget.isSpeaking) {
      if (widget.isSpeaking) {
        _playTalkingAnimation();
      } else {
        _playIdleAnimation();
      }
    }
  }

  /// Play the idle animation (frames 0.0 to 0.3)
  void _playIdleAnimation() {
    _controller.stop();
    _controller.value = 0.0;
    _controller.repeat(min: 0.0, max: 0.3);
  }

  /// Play the talking animation (frames 0.3 to 1.0)
  void _playTalkingAnimation() {
    _controller.stop();
    _controller.value = 0.3;
    _controller.repeat(min: 0.3, max: 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: const Color(0xFFDBC59C).withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Lottie.asset(
        'assets/Talking Character.json',
        controller: _controller,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback if Lottie file fails to load
          return Icon(
            Icons.record_voice_over,
            size: widget.size * 0.6,
            color: const Color(0xFF5D4E37),
          );
        },
      ),
    );
  }
}
