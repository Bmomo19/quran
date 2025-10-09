import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Getters
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;

  // Initialiser les écouteurs
  void initialize() {
    // Écouter les changements de durée
    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
    });

    // Écouter les changements de position
    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
    });

    // Écouter la fin de la lecture
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _position = Duration.zero;
    });
  }

  // Jouer un audio depuis une URL
  Future<void> play(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
      _isPlaying = true;
    } catch (e) {
      throw Exception('Erreur lors de la lecture: $e');
    }
  }

  // Pause
  Future<void> pause() async {
    await _audioPlayer.pause();
    _isPlaying = false;
  }

  // Reprendre
  Future<void> resume() async {
    await _audioPlayer.resume();
    _isPlaying = true;
  }

  // Arrêter
  Future<void> stop() async {
    await _audioPlayer.stop();
    _isPlaying = false;
    _position = Duration.zero;
  }

  // Chercher une position spécifique
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Changer la vitesse de lecture
  Future<void> setPlaybackRate(double rate) async {
    await _audioPlayer.setPlaybackRate(rate);
  }

  // Définir le volume (0.0 à 1.0)
  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  // Nettoyer les ressources
  void dispose() {
    _audioPlayer.dispose();
  }
}