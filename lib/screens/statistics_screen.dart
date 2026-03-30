import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/services/firestore_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirestoreService _service = FirestoreService();
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _prepareStats();
  }

  int _getMentionValue(String mention) {
    switch (mention) {
      case "Très bien": return 4;
      case "Bien": return 3;
      case "Assez bien": return 2;
      case "Passable": return 1;
      default: return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _prepareStats() async {
    final semestersSnapshot = await _service.getSemesters().first;
    final List<Map<String, dynamic>> semesterStats = [];

    for (var semesterDoc in semestersSnapshot.docs) {
      final subjectsSnapshot = await _service.getSubjects(semesterDoc.id).first;
      double totalWeightedIndices = 0;
      int totalCredits = 0;
      
      for (var doc in subjectsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        bool isManual = data['isManual'] ?? false;
        String mention = data['mention'] ?? 'Echec';
        int indice = _getMentionValue(mention);
        int credit = isManual ? 3 : 6;
        totalWeightedIndices += (indice * credit);
        totalCredits += credit;
      }

      double average = (totalCredits > 0) ? (totalWeightedIndices / totalCredits) : 0.0;
      semesterStats.add({
        'name': semesterDoc['name'],
        'average': average,
      });
    }
    return semesterStats;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text('Statistics'.tr(), style: const TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: isDark ? Colors.black : const Color(0xFF0A3D62),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF3CDEED)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data found.".tr(), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)));
          }

          final stats = snapshot.data!;
          double totalSum = stats.fold(0.0, (sum, item) => sum + item['average']);
          double totalAverage = totalSum / stats.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vue d'ensemble".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A2E36) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: const Color(0xFF3CDEED).withOpacity(0.3)) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text("${"Moyenne Générale".tr()} : ", style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                      ),
                      Text(totalAverage.toStringAsFixed(2), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A8E8))),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text("Barre de Progression".tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 15),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 4.0, 
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF0A2E36),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toStringAsFixed(2),
                              const TextStyle(color: Color(0xFF3CDEED), fontWeight: FontWeight.bold, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         bottomTitles: AxisTitles(
                           sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() < stats.length) {
                                  String name = stats[value.toInt()]['name'];
                                  if (name.contains("Semestre")) {
                                    name = name.replaceAll("Semestre", "S");
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(name, style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.black54)),
                                  );
                                }
                                return const SizedBox();
                            },
                            reservedSize: 25,
                           )
                         ),
                         leftTitles: AxisTitles(
                           sideTitles: SideTitles(
                             showTitles: true,
                             getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1), style: TextStyle(fontSize: 9, color: isDark ? Colors.white70 : Colors.black54)),
                             reservedSize: 25,
                           )
                         )
                      ),
                      gridData: FlGridData(
                        show: true, 
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: stats.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value['average'], 
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00A8E8), Color(0xFF3CDEED)],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ), 
                              width: 16, 
                              borderRadius: BorderRadius.circular(4)
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
