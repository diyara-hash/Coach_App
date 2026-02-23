import 'package:flutter/material.dart';
import '../auth/login_screen.dart';

class AthleteHome extends StatefulWidget {
  final String athleteId;

  const AthleteHome({super.key, required this.athleteId});

  @override
  State<AthleteHome> createState() => _AthleteHomeState();
}

class _AthleteHomeState extends State<AthleteHome> {
  int selectedDay = 0;

  final List<Map<String, dynamic>> weeklyProgram = [
    {
      'day': 'Pazartesi',
      'muscle': 'Göğüs & Triceps',
      'exercises': [
        {'name': 'Bench Press', 'sets': '4x10', 'done': false},
        {'name': 'Incline Dumbbell Press', 'sets': '3x12', 'done': false},
        {'name': 'Cable Fly', 'sets': '3x15', 'done': false},
        {'name': 'Triceps Pushdown', 'sets': '4x12', 'done': false},
      ],
      'duration': '45 dk',
      'completed': 0,
      'total': 4,
    },
    {
      'day': 'Salı',
      'muscle': 'Sırt & Biceps',
      'exercises': [
        {'name': 'Deadlift', 'sets': '4x8', 'done': false},
        {'name': 'Lat Pulldown', 'sets': '4x12', 'done': false},
        {'name': 'Barbell Row', 'sets': '3x10', 'done': false},
        {'name': 'Dumbbell Curl', 'sets': '3x12', 'done': false},
      ],
      'duration': '50 dk',
      'completed': 0,
      'total': 4,
    },
    {
      'day': 'Çarşamba',
      'muscle': 'Bacak',
      'exercises': [
        {'name': 'Squat', 'sets': '4x10', 'done': false},
        {'name': 'Leg Press', 'sets': '3x12', 'done': false},
        {'name': 'Leg Curl', 'sets': '3x15', 'done': false},
        {'name': 'Calf Raise', 'sets': '4x20', 'done': false},
      ],
      'duration': '55 dk',
      'completed': 0,
      'total': 4,
    },
    {
      'day': 'Perşembe',
      'muscle': 'Omuz & Karın',
      'exercises': [
        {'name': 'Overhead Press', 'sets': '4x10', 'done': false},
        {'name': 'Lateral Raise', 'sets': '4x15', 'done': false},
        {'name': 'Face Pull', 'sets': '3x15', 'done': false},
        {'name': 'Plank', 'sets': '3x60 sn', 'done': false},
      ],
      'duration': '40 dk',
      'completed': 0,
      'total': 4,
    },
    {
      'day': 'Cuma',
      'muscle': 'Kol',
      'exercises': [
        {'name': 'Close Grip Bench', 'sets': '4x10', 'done': false},
        {'name': 'Barbell Curl', 'sets': '4x10', 'done': false},
        {'name': 'Skull Crusher', 'sets': '3x12', 'done': false},
        {'name': 'Hammer Curl', 'sets': '3x12', 'done': false},
      ],
      'duration': '35 dk',
      'completed': 0,
      'total': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final todayProgram = weeklyProgram[selectedDay];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFE94560),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Antrenmanım',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE94560), Color(0xFF0A0A0A)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE94560),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Haftalık Takvim
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: weeklyProgram.length,
                      itemBuilder: (context, index) {
                        final day = weeklyProgram[index];
                        final isSelected = index == selectedDay;

                        return GestureDetector(
                          onTap: () => setState(() => selectedDay = index),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE94560)
                                  : const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE94560)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  day['day'].substring(0, 3),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        (day['completed'] as int) ==
                                            (day['total'] as int)
                                        ? Colors.green
                                        : (day['completed'] as int) > 0
                                        ? Colors.orange
                                        : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bugünün Programı Kartı
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE94560).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  todayProgram['muscle'],
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE94560),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${todayProgram['duration']} • ${todayProgram['total']} egzersiz',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE94560).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: Color(0xFFE94560),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value:
                                (todayProgram['completed'] as int) /
                                (todayProgram['total'] as int),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFE94560),
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${todayProgram['completed']}/${todayProgram['total']} tamamlandı',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Egzersiz Listesi
                  const Text(
                    'Egzersizler',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  ...List.generate((todayProgram['exercises'] as List).length, (
                    index,
                  ) {
                    final exercise = (todayProgram['exercises'] as List)[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: exercise['done']
                              ? Colors.green.withOpacity(0.3)
                              : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: exercise['done']
                                  ? Colors.green.withOpacity(0.2)
                                  : const Color(0xFFE94560).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              exercise['done']
                                  ? Icons.check
                                  : Icons.fitness_center,
                              color: exercise['done']
                                  ? Colors.green
                                  : const Color(0xFFE94560),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise['name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: exercise['done']
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: exercise['done']
                                        ? Colors.grey
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  exercise['sets'],
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: exercise['done'],
                            onChanged: (value) {
                              setState(() {
                                exercise['done'] = value;
                                if (value == true) {
                                  todayProgram['completed']++;
                                } else {
                                  todayProgram['completed']--;
                                }
                              });
                            },
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Coach'a mesaj gönder
        },
        backgroundColor: const Color(0xFFE94560),
        icon: const Icon(Icons.chat),
        label: const Text('Coach\'a Yaz'),
      ),
    );
  }
}
