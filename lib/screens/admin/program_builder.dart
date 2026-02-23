import 'package:flutter/material.dart';

class ProgramBuilder extends StatefulWidget {
  const ProgramBuilder({super.key});

  @override
  State<ProgramBuilder> createState() => _ProgramBuilderState();
}

class _ProgramBuilderState extends State<ProgramBuilder> {
  final _dayNameController = TextEditingController();
  final List<Map<String, dynamic>> exercises = [];

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final setsController = TextEditingController();
        final videoController = TextEditingController();

        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Egzersiz Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Egzersiz Adi'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  hintText: 'Set x Tekrar (ornek: 4x10)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: videoController,
                decoration: const InputDecoration(
                  hintText: 'YouTube Video Linki',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Iptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  exercises.add({
                    'name': nameController.text,
                    'sets': setsController.text,
                    'video': videoController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Program Olustur'),
        backgroundColor: const Color(0xFFE94560),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dayNameController,
              decoration: const InputDecoration(
                hintText: 'Gun Adi (ornek: Pazartesi - Gogus)',
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Egzersizler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('Egzersiz Ekle'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final ex = exercises[index];
                  return Card(
                    color: const Color(0xFF16213E),
                    child: ListTile(
                      title: Text(ex['name']),
                      subtitle: Text(ex['sets']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            exercises.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Kaydetme islemi (simdilik sadece goster)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Program kaydedildi!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                ),
                child: const Text('KAYDET'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
