import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_glass_card.dart';
import '../providers/ambient_sound_provider.dart';

class AmbientSoundsScreen extends StatelessWidget {
  const AmbientSoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ambientProvider = context.watch<AmbientSoundProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ambient Sounds'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.screenHorizontalPadding),
        physics: const BouncingScrollPhysics(),
        children: [
          CustomGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Focus Soundscape',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ambientProvider.selectedTrack == null
                      ? 'Pick a gentle loop and keep your session calm.'
                      : '${ambientProvider.selectedTrack!.title} is ready for your next focus block.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: ambientProvider.isBusy
                            ? null
                            : ambientProvider.togglePlayback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: Icon(
                          ambientProvider.isPlaying
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                        ),
                        label: Text(
                          ambientProvider.isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: ambientProvider.isBusy
                            ? null
                            : ambientProvider.stopPlayback,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.stop_circle_outlined),
                        label: const Text('Stop'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.accentMint,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: ambientProvider.volume,
                        min: 0,
                        max: 1,
                        divisions: 10,
                        label: '${(ambientProvider.volume * 100).round()}%',
                        activeColor: AppColors.lightGreen,
                        inactiveColor: Colors.white12,
                        onChanged: ambientProvider.isBusy
                            ? null
                            : (value) {
                                context
                                    .read<AmbientSoundProvider>()
                                    .setVolume(value);
                              },
                      ),
                    ),
                  ],
                ),
                if (ambientProvider.errorMessage != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    ambientProvider.errorMessage!,
                    style: const TextStyle(
                      color: AppColors.warning,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Soundscapes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...AmbientSoundProvider.tracks.map(
            (track) => _AmbientTrackCard(track: track),
          ),
        ],
      ),
    );
  }
}

class _AmbientTrackCard extends StatelessWidget {
  const _AmbientTrackCard({
    required this.track,
  });

  final AmbientTrackOption track;

  @override
  Widget build(BuildContext context) {
    final ambientProvider = context.watch<AmbientSoundProvider>();
    final isSelected = ambientProvider.selectedTrackId == track.id;
    final isPlaying = isSelected && ambientProvider.isPlaying;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.lightGreen : Colors.white24,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        onTap: ambientProvider.isBusy
            ? null
            : () => context.read<AmbientSoundProvider>().playTrack(track.id),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryGreen.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            track.icon,
            color: isSelected ? AppColors.accentMint : Colors.white70,
          ),
        ),
        title: Text(
          track.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            track.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          children: [
            if (isPlaying)
              const Icon(
                Icons.graphic_eq_rounded,
                color: AppColors.accentMint,
              ),
            TextButton(
              onPressed: ambientProvider.isBusy
                  ? null
                  : () => context.read<AmbientSoundProvider>().playTrack(
                        track.id,
                      ),
              child: Text(isPlaying ? 'Playing' : 'Play'),
            ),
          ],
        ),
      ),
    );
  }
}
