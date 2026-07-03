import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'journal_list_view.dart';

class JournalView extends StatefulWidget {
  const JournalView({super.key});

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  final TextEditingController controller = TextEditingController();

  late Box box;

  String selectedMood = "😊";

  final moods = ["😊", "😌", "😔", "😢", "😡"];

  final guideTexts = [
    "Bagaimana hari kamu hari ini?",
    "Apa yang kamu rasakan sekarang?",
    "Apakah ada hal yang mengganggu pikiranmu?",
    "Apa hal baik yang terjadi hari ini?",
  ];

  String guideText = "";

  @override
  void initState() {
    super.initState();
    box = Hive.box('journals');
    guideText = guideTexts.first;
  }

  void saveJournal() {
    final text = controller.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jurnal tidak boleh kosong")),
      );
      return;
    }

    final data = {
      "title": "Jurnal ${DateTime.now().day}/${DateTime.now().month}",
      "content": text,
      "mood": selectedMood,
      "date": DateTime.now().toIso8601String(),
    };

    box.add(data);

    controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Jurnal tersimpan"),
      behavior: SnackBarBehavior.floating, // 🔥 FIX
      margin: EdgeInsets.all(12),
      duration: Duration(seconds: 2),
    ),
  );

    setState(() {});
  }

  void openList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const JournalListView(),
      ),
    );
  }

  void changeGuide() {
    setState(() {
      guideText = (guideTexts..shuffle()).first;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jurnal Harian"),
        backgroundColor: const Color(0xFF2E66E7),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // GUIDE
            GestureDetector(
              onTap: changeGuide,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Theme.of(context).cardColor 
                      : const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text("💬 $guideText"),
              ),
            ),

            const SizedBox(height: 15),

            // MOOD SELECTOR
            Column(
              children: [
                const Text(
                  "Bagaimana perasaanmu hari ini?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: moods.map((m) {
                    final isSelected = selectedMood == m;

                    return GestureDetector(
                      onTap: () {
                        setState(() => selectedMood = m);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2E66E7)
                              : (Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey.shade800 
                                  : Colors.grey.shade200),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.blue, width: 2)
                              : null,
                        ),
                        child: Text(
                          m,
                          style: TextStyle(
                            fontSize: 22,
                            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 6),

                Text(
                  "Mood terpilih: $selectedMood",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // INPUT
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: "Tulis jurnal kamu di sini...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveJournal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E66E7),
                  foregroundColor: Colors.white, // 🔥 FIX TEXT WARNA
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Simpan Jurnal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ),

            const SizedBox(height: 10),

            // OPEN LIST
            TextButton(
              onPressed: openList,
              child: const Text("Jurnal Kamu"),
            ),
          ],
        ),
      ),
    );
  }
}