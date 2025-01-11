import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

class PantauSholatScreen extends StatefulWidget {
  final Function(Map<String, bool>) onUpdate;
  final Map<String, String> prayerTimes; // Data waktu sholat dari WaktuSholatScreen
  final Map<String, bool> sholatMilestones; // Milestones sholat (bisa kosong)

  const PantauSholatScreen({
    super.key,
    required this.onUpdate,
    required this.prayerTimes,
    this.sholatMilestones = const {}, // Default jika tidak ada data
  });

  @override
  _PantauSholatScreenState createState() => _PantauSholatScreenState();
}

class _PantauSholatScreenState extends State<PantauSholatScreen> {
  Map<String, bool> todayLog = {
    'subuh': false,
    'dzuhur': false,
    'ashar': false,
    'maghrib': false,
    'isya': false,
  };
  List<Map<String, dynamic>> prayerLog = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("PrayerTimes diterima di PantauSholatScreen: ${widget.prayerTimes}");
    loadProgress();
  }

  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> validPrayerLog = prayerLog.map((log) {
      return {
        'date': log['date'] ?? DateTime.now().toString().split(' ')[0],
        'subuh': log['subuh'] == true,
        'dzuhur': log['dzuhur'] == true,
        'ashar': log['ashar'] == true,
        'maghrib': log['maghrib'] == true,
        'isya': log['isya'] == true,
      };
    }).toList();

    final jsonLog = json.encode(validPrayerLog);
    await prefs.setString('prayerLog', jsonLog);
  }

  Future<void> loadProgress() async {
  final prefs = await SharedPreferences.getInstance();
  final String? jsonLog = prefs.getString('prayerLog');
  final today = DateTime.now().toString().split(' ')[0]; // Tanggal hari ini

  if (jsonLog != null) {
    setState(() {
      prayerLog = List<Map<String, dynamic>>.from(json.decode(jsonLog)).map((log) {
        return {
          'date': log['date'] ?? today,
          'subuh': log['subuh'] == true,
          'dzuhur': log['dzuhur'] == true,
          'ashar': log['ashar'] == true,
          'maghrib': log['maghrib'] == true,
          'isya': log['isya'] == true,
        };
      }).toList();
    });

    // Cek apakah hari ini ada di log
    final todayIndex = prayerLog.indexWhere((log) => log['date'] == today);
    if (todayIndex == -1) {
      // Reset jika tidak ada data untuk hari ini
      setState(() {
        todayLog = {
          'subuh': false,
          'dzuhur': false,
          'ashar': false,
          'maghrib': false,
          'isya': false,
        };
        prayerLog.add({
          'date': today,
          ...todayLog,
        });
      });
    } else {
      // Load data hari ini ke `todayLog`
      setState(() {
        todayLog = {
          'subuh': prayerLog[todayIndex]['subuh'],
          'dzuhur': prayerLog[todayIndex]['dzuhur'],
          'ashar': prayerLog[todayIndex]['ashar'],
          'maghrib': prayerLog[todayIndex]['maghrib'],
          'isya': prayerLog[todayIndex]['isya'],
        };
      });
    }
  } else {
    // Jika log kosong, buat log baru untuk hari ini
    setState(() {
      prayerLog = [
        {
          'date': today,
          'subuh': false,
          'dzuhur': false,
          'ashar': false,
          'maghrib': false,
          'isya': false,
        }
      ];
      todayLog = {
        'subuh': false,
        'dzuhur': false,
        'ashar': false,
        'maghrib': false,
        'isya': false,
      };
    });
  }

  setState(() {
    isLoading = false;
  });
}

  bool isTimeValid(String prayerKey) {
    final now = DateTime.now();
    final currentPrayerTime = _getPrayerTime(prayerKey);
    final nextPrayerTime = _getNextPrayerTime(prayerKey);

    // Valid jika sekarang >= waktu sholat saat ini dan < waktu sholat berikutnya
    print("Validasi waktu untuk $prayerKey:");
    print("  Sekarang       : $now");
    print("  Waktu Sholat   : $currentPrayerTime");
    print("  Waktu Berikutnya: $nextPrayerTime");

    return now.isAfter(currentPrayerTime) && now.isBefore(nextPrayerTime);
  }

  DateTime _getPrayerTime(String prayerKey) {
    final now = DateTime.now();
    final prayerKeyCapitalized = prayerKey.capitalize(); // Pastikan format key sesuai
    final prayerTimeString = widget.prayerTimes[prayerKeyCapitalized] ?? "00:00";
    final prayerTimeParts = prayerTimeString.split(':');
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(prayerTimeParts[0]),
      int.parse(prayerTimeParts[1]),
    );
  }

  DateTime _getNextPrayerTime(String prayerKey) {
    final prayerOrder = ['subuh', 'dzuhur', 'ashar', 'maghrib', 'isya'];
    final currentIndex = prayerOrder.indexOf(prayerKey);

    // Jika ini adalah sholat terakhir (Isya), waktu berikutnya adalah Subuh hari berikutnya
    if (currentIndex == prayerOrder.length - 1) {
      return _getPrayerTime('subuh').add(const Duration(days: 1));
    }

    final nextPrayerKey = prayerOrder[currentIndex + 1];
    return _getPrayerTime(nextPrayerKey);
  }

  void updateLog(String prayer, bool value) {
    final today = DateTime.now().toString().split(' ')[0];

    setState(() {
      todayLog[prayer] = value;

      final todayIndex = prayerLog.indexWhere((log) => log['date'] == today);
      if (todayIndex != -1) {
        prayerLog[todayIndex] = {
          'date': today,
          ...todayLog,
        };
      } else {
        prayerLog.add({
          'date': today,
          ...todayLog,
        });
      }
    });

    widget.onUpdate(todayLog);

    saveProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pantau Sholat',
          style: GoogleFonts.poppins(
            color: const Color(0xFF004C7E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pantau Sholat Hari Ini',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...todayLog.entries.map((entry) {
                          IconData? icon;
                          switch (entry.key) {
                            case 'subuh':
                              icon = Icons.sunny;
                              break;
                            case 'dzuhur':
                              icon = Icons.access_time;
                              break;
                            case 'ashar':
                              icon = Icons.access_time_filled;
                              break;
                            case 'maghrib':
                              icon = Icons.nights_stay;
                              break;
                            case 'isya':
                              icon = Icons.brightness_2;
                              break;
                          }
                          return ListTile(
                            title: Row(
                              children: [
                                Icon(icon, color: Colors.teal),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key.capitalize(),
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ],
                            ),
                            trailing: CircleAvatar(
                              backgroundColor: entry.value
                                  ? const Color(0xFF2DDCBE)
                                  : Colors.grey[300],
                              child: Icon(
                                entry.value
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              if (isTimeValid(entry.key)) {
                                updateLog(entry.key, !entry.value);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Waktu untuk ${entry.key.capitalize()} telah berlalu atau belum waktunya.'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  PrayerChart(prayerLog: prayerLog), // Grafik
                ],
              ),
            ),
    );
  }
}

// Komponen Grafik
class PrayerChart extends StatelessWidget {
  final List<Map<String, dynamic>> prayerLog;

  const PrayerChart({super.key, required this.prayerLog});

  @override
  Widget build(BuildContext context) {
    List<_ChartData> chartData = prayerLog.where((data) {
      return data['date'] is String;
    }).map((data) {
      int completedPrayers = data.entries
          .where((entry) => entry.key != 'date' && entry.value == true)
          .length;
      return _ChartData(data['date'] as String, completedPrayers);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(),
        series: <CartesianSeries<_ChartData, String>>[
          ColumnSeries<_ChartData, String>(
            dataSource: chartData,
            xValueMapper: (_ChartData data, _) => data.date,
            yValueMapper: (_ChartData data, _) => data.completedPrayers,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: const Color(0xFF004C7E),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String date;
  final int completedPrayers;

  _ChartData(this.date, this.completedPrayers);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
