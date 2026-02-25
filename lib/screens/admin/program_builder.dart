import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../models/program.dart';
import '../../services/database_service.dart';
import '../../core/theme/app_theme.dart';

class ProgramBuilder extends StatefulWidget {
  final Program? program;

  const ProgramBuilder({super.key, this.program});

  @override
  State<ProgramBuilder> createState() => _ProgramBuilderState();
}

class _ProgramBuilderState extends State<ProgramBuilder> {
  final _dayNameController = TextEditingController();
  final List<Map<String, dynamic>> exercises = [];
  final DatabaseService _db = DatabaseService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.program != null) {
      _dayNameController.text = widget.program!.name;
      for (var ex in widget.program!.exercises) {
        exercises.add({
          'name': ex.name,
          'sets': ex.sets,
          'videoId': ex.videoId,
          'video': ex.videoId != null
              ? 'https://youtube.com/watch?v=${ex.videoId}'
              : '',
        });
      }
    }
  }

  @override
  void dispose() {
    _dayNameController.dispose();
    super.dispose();
  }

  String? extractVideoId(String url) {
    if (url.isEmpty) return null;
    final regExp = RegExp(
      r".*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*",
      multiLine: false,
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null &&
        match.group(1) != null &&
        match.group(1)!.length == 11) {
      return match.group(1);
    }
    return null;
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final setsController = TextEditingController();
        final videoController = TextEditingController();
        String? previewVideoId;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Egzersiz Ekle'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Egzersiz Adı',
                        prefixIcon: Icon(Icons.fitness_center_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: setsController,
                      decoration: const InputDecoration(
                        hintText: 'Set x Tekrar (örnek: 4x10)',
                        prefixIcon: Icon(Icons.repeat_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: videoController,
                      decoration: const InputDecoration(
                        hintText: 'YouTube Video Linki',
                        prefixIcon: Icon(Icons.play_circle_outline_rounded),
                      ),
                      onChanged: (value) {
                        final videoId = extractVideoId(value);
                        setDialogState(() {
                          previewVideoId = videoId;
                        });
                      },
                    ),
                    if (previewVideoId != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                'https://img.youtube.com/vi/$previewVideoId/0.jpg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.broken_image_rounded,
                                    size: 48,
                                    color: Colors.white24,
                                  );
                                },
                              ),
                              Container(
                                color: Colors.black45,
                                child: const Icon(
                                  Icons.play_circle_filled_rounded,
                                  size: 48,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İPTAL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      setState(() {
                        exercises.add({
                          'name': nameController.text,
                          'sets': setsController.text,
                          'video': videoController.text,
                          'videoId': extractVideoId(videoController.text),
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 44),
                  ),
                  child: const Text('EKLE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveProgram() async {
    if (_dayNameController.text.isEmpty || exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen program adı ve en az bir egzersiz girin!'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final coachId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

      final programId =
          widget.program?.id ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final programCreatedAt = widget.program?.createdAt ?? DateTime.now();

      final program = Program(
        id: programId,
        name: _dayNameController.text.trim(),
        coachId: coachId,
        exercises: exercises
            .map(
              (e) => Exercise(
                name: e['name'],
                sets: e['sets'],
                videoId: e['videoId'],
              ),
            )
            .toList(),
        createdAt: programCreatedAt,
      );

      await _db.addProgram(program);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Program başarıyla kaydedildi!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.program != null ? 'PROGRAM DÜZENLE' : 'PROGRAM OLUŞTUR',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  'Program Detayları',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Günün ismini ve yapılacak hareketleri belirleyin.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                TextField(
                  controller: _dayNameController,
                  decoration: const InputDecoration(
                    hintText: 'Program Adı (Örn: Pazartesi - Göğüs)',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'EGZERSİZLER',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    TextButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
                        size: 20,
                      ),
                      label: const Text('YENİ EKLE'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (exercises.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxl,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center_rounded,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.2),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Henüz egzersiz eklenmedi.',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final ex = exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            ex['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            ex['sets'],
                            style: const TextStyle(color: AppColors.primary),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                exercises.removeAt(index);
                              });
                            },
                          ),
                          onTap: ex['videoId'] != null
                              ? () => _playVideoPreview(context, ex['videoId'])
                              : null,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
            ),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: AppTheme.primaryGradient,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: Size.zero,
                ),
                child: _isSaving
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : const Text('PROGRAMI KAYDET'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _playVideoPreview(BuildContext context, String videoId) {
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        origin: 'https://www.youtube-nocookie.com',
      ),
    );

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
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
                    fontWeight: FontWeight.bold,
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
