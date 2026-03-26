import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../app_state/providers/app_state_provider.dart';

class AmbientTrackOption {
  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final IconData icon;

  const AmbientTrackOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.icon,
  });
}

class AmbientSoundProvider extends ChangeNotifier {
  AmbientSoundProvider({
    AudioPlayer? audioPlayer,
  }) : _audioPlayer = audioPlayer ?? AudioPlayer(playerId: 'ambient_focus_loop') {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static const List<AmbientTrackOption> tracks = [
    AmbientTrackOption(
      id: 'rain',
      title: 'Rain',
      subtitle: 'Soft rainfall for longer, calmer focus blocks.',
      assetPath: 'audio/rain_loop.wav',
      icon: Icons.water_drop_rounded,
    ),
    AmbientTrackOption(
      id: 'forest',
      title: 'Forest',
      subtitle: 'Light breeze and distant birds for natural focus.',
      assetPath: 'audio/forest_loop.wav',
      icon: Icons.forest_rounded,
    ),
  ];

  final AudioPlayer _audioPlayer;

  AppStateProvider? _appStateProvider;
  String? _boundUserId;
  String _selectedTrackId = '';
  double _volume = 0.6;
  bool _isPlaying = false;
  bool _isBusy = false;
  String? _errorMessage;

  String get selectedTrackId => _selectedTrackId;
  double get volume => _volume;
  bool get isPlaying => _isPlaying;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  AmbientTrackOption? get selectedTrack => _trackById(_selectedTrackId);

  void attachAppState(AppStateProvider appStateProvider) {
    final previousUserId = _boundUserId;
    final previousTrackId = _selectedTrackId;

    _appStateProvider = appStateProvider;
    _boundUserId = appStateProvider.activeUserId;
    _selectedTrackId = appStateProvider.ambientSoundPreference.selectedTrackId;
    _volume = appStateProvider.ambientSoundPreference.volume.clamp(0.0, 1.0);
    _audioPlayer.setVolume(_volume);

    final userChanged = previousUserId != _boundUserId;
    final trackChanged = previousTrackId != _selectedTrackId;

    if (userChanged) {
      _audioPlayer.stop();
      _isPlaying = false;
      _errorMessage = null;
    } else if (_isPlaying && trackChanged) {
      playTrack(_selectedTrackId);
    }

    notifyListeners();
  }

  Future<void> playTrack(String trackId) async {
    final track = _trackById(trackId);
    if (track == null) {
      return;
    }

    _isBusy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTrackId = track.id;
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(track.assetPath));
      _isPlaying = true;
      await _appStateProvider?.updateAmbientSoundPreference(
        selectedTrackId: track.id,
      );
    } catch (_) {
      _isPlaying = false;
      _errorMessage = 'Ambient audio is unavailable right now.';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> togglePlayback() async {
    if (_selectedTrackId.isEmpty) {
      await playTrack(tracks.first.id);
      return;
    }

    if (_isPlaying) {
      await stopPlayback();
      return;
    }

    await playTrack(_selectedTrackId);
  }

  Future<void> selectTrack(String trackId) async {
    if (trackId == _selectedTrackId && !_isPlaying) {
      await playTrack(trackId);
      return;
    }

    _selectedTrackId = trackId;
    await _appStateProvider?.updateAmbientSoundPreference(
      selectedTrackId: trackId,
    );

    if (_isPlaying) {
      await playTrack(trackId);
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {
      // Ignore audio stop failures and keep the UI responsive.
    }

    _isPlaying = false;
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    await _appStateProvider?.updateAmbientSoundPreference(volume: _volume);
    notifyListeners();
  }

  AmbientTrackOption? _trackById(String trackId) {
    for (final track in tracks) {
      if (track.id == trackId) {
        return track;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
