import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../models/program.dart';
import '../../services/database_service.dart';
import '../../core/theme/app_theme.dart';
import 'program_builder.dart';

class ProgramList extends StatelessWidget {
  const ProgramList({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final coachId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    return Scaffold(
      appBar: AppBar(title: const Text('PROGRAMLARIM')),
      body: StreamBuilder<List<Program>>(
        stream: db.getPrograms(coachId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final programs = snapshot.data!;

          if (programs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Henüz program oluşturmadınız',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.eliteShadow, AppColors.emeraldGlow],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        title: Text(
                          program.name.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${program.exercises.length} EGZERSİZ',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        onTap: () => _showProgramDetail(context, program),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Programı Sil'),
                                content: const Text(
                                  'Bu programı silmek istediğinize emin misiniz?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('İPTAL'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      db.deleteProgram(program.id);
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text('SİL'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProgramBuilder(program: program),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProgramDetail(BuildContext context, Program program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      program.name.toUpperCase(),
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: program.exercises.length,
                  itemBuilder: (context, index) {
                    final ex = program.exercises[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: ListTile(
                        leading: ex.videoId != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      'https://img.youtube.com/vi/${ex.videoId}/0.jpg',
                                      width: 80,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      width: 80,
                                      height: 60,
                                      color: Colors.black26,
                                      child: const Icon(
                                        Icons.play_arrow_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: 80,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.fitness_center_rounded),
                              ),
                        title: Text(
                          ex.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          ex.sets,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: ex.videoId != null
                            ? () => _playVideo(context, ex.videoId!)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _playVideo(BuildContext context, String videoId) {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        origin: 'https://www.youtube-nocookie.com',
        showVideoAnnotations: false,
      ),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(controller: controller),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'KAPAT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
