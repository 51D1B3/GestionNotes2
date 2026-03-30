import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const _historyKey = 'pdf_history';

  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> addToHistory(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    if (!history.contains(filePath)) {
      history.insert(0, filePath);
      await prefs.setStringList(_historyKey, history);
    }
  }

  Future<void> removeFromHistory(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.remove(filePath);
    await prefs.setStringList(_historyKey, history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
