import 'dart:io';
import 'package:flutter/material.dart';
import 'package:notes_app/services/history_service.dart';
import 'package:open_file/open_file.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<String>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = _historyService.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              await _historyService.clearHistory();
              _refreshHistory();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No history found.".tr()));
          }

          final history = snapshot.data!;

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final filePath = history[index];
              final file = File(filePath);
              
              // Si le fichier a été supprimé manuellement du dossier Download
              if (!file.existsSync()) {
                return const SizedBox.shrink();
              }

              final fileName = filePath.split('/').last;
              
              // Extraction du nom du semestre depuis le nom du fichier
              // Nom attendu : UniNotes_Semestre_X_TIMESTAMP.pdf
              final parts = fileName.split('_');
              String displayTitle = fileName;
              if (parts.length >= 2) {
                displayTitle = parts.sublist(1, parts.length - 1).join(' ').replaceAll('.pdf', '');
              }

              // Récupération de la date réelle du fichier sur le système
              final DateTime lastModified = file.lastModifiedSync();
              final String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(lastModified);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                  title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(formattedDate),
                  onTap: () => OpenFile.open(filePath),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () async {
                      await _historyService.removeFromHistory(filePath);
                      _refreshHistory();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
