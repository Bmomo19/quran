import 'package:flutter/material.dart';

class AudioButton extends StatefulWidget {
  final bool isPlaying;
  final Future<String> Function() getAudioUrl;
  final Future<void> Function(String url) play;
  final Future<void> Function() pause;

  const AudioButton({
    super.key,
    required this.isPlaying,
    required this.getAudioUrl,
    required this.play,
    required this.pause,
  });

  @override
  State<AudioButton> createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {
  bool isLoadingAudio = false;
  String? _currentAudioUrl;

  Future<void> _toggleAudio() async {
    if (widget.isPlaying) {
      await widget.pause();
    } else {
      try {
        setState(() => isLoadingAudio = true);

        _currentAudioUrl ??= await widget.getAudioUrl();
        await widget.play(_currentAudioUrl!);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur audio: $e')));
      } finally {
        setState(() => isLoadingAudio = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: isLoadingAudio
          ? SizedBox(
              key: const ValueKey('loader'),
              width: 50,
              height: 50,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : IconButton(
              key: ValueKey(widget.isPlaying ? 'pause' : 'play'),
              onPressed: _toggleAudio,
              icon: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
    );
  }
}
