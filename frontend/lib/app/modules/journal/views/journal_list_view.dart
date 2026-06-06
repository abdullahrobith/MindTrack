import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class JournalListView extends StatefulWidget {
  const JournalListView({super.key});

  @override
  State<JournalListView> createState() => _JournalListViewState();
}

class _JournalListViewState extends State<JournalListView> {
  late Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('journals');
  }

  @override
  Widget build(BuildContext context) {
    final journals = box.values.toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Jurnal Kamu"),
        backgroundColor: const Color(0xFF2E66E7),
      ),

      body: journals.isEmpty
          ? const Center(
              child: Text("Belum ada jurnal"),
            )
          : ListView.builder(
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final item = journals[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Text(item["mood"] ?? "😊"),
                    title: Text(item["title"] ?? "-"),
                    subtitle: Text(item["content"].toString()),

                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(item["title"]),
                          content: Text(item["content"]),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                      );
                    },

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),

                      onPressed: () {
                        setState(() {
                          box.deleteAt(
                            box.length - 1 - index, // 🔥 karena list di-reverse
                          );
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}