
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const HavaMitraApp());
}

const villageLat = 19.130057;
const villageLon = 76.469843;

class HavaMitraApp extends StatelessWidget {
  const HavaMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'हवामित्र मराठी',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  Map<String, dynamic>? weather;
  bool loading = true;
  String? error;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final uri = Uri.https(
        'api.open-meteo.com',
        '/v1/forecast',
        {
          'latitude': '$villageLat',
          'longitude': '$villageLon',
          'timezone': 'Asia/Kolkata',
          'forecast_days': '10',
          'current':
              'temperature_2m,relative_humidity_2m,'
              'apparent_temperature,precipitation,'
              'weather_code,wind_speed_10m',
          'hourly':
              'temperature_2m,precipitation_probability,'
              'precipitation,relative_humidity_2m,'
              'wind_speed_10m,weather_code',
          'daily':
              'weather_code,temperature_2m_max,'
              'temperature_2m_min,precipitation_sum,'
              'precipitation_probability_max,'
              'wind_speed_10m_max',
        },
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('हवामान सेवा सध्या उपलब्ध नाही.');
      }

      final result =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;
      setState(() {
        weather = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'हवामान मिळाले नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.';
        loading = false;
      });
    }
  }

  String weatherText(dynamic code) {
    final c = (code as num?)?.toInt() ?? 0;
    if (c == 0) return 'निरभ्र आकाश';
    if (c <= 3) return 'ढगाळ हवामान';
    if (c == 45 || c == 48) return 'धुके';
    if (c >= 51 && c <= 57) return 'रिमझिम पाऊस';
    if (c >= 61 && c <= 67) return 'पाऊस';
    if (c >= 71 && c <= 77) return 'बर्फवृष्टी';
    if (c >= 80 && c <= 82) return 'सरी';
    if (c >= 95) return 'मेघगर्जना';
    return 'हवामान बदलते आहे';
  }

  String dayLabel(String value) {
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    return '${d.day}/${d.month}';
  }

  Widget infoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHome() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error ?? 'माहिती उपलब्ध नाही'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: loadWeather,
                child: const Text('पुन्हा प्रयत्न करा'),
              ),
            ],
          ),
        ),
      );
    }

    final current =
        weather!['current'] as Map<String, dynamic>;
    final hourly =
        weather!['hourly'] as Map<String, dynamic>;
    final daily =
        weather!['daily'] as Map<String, dynamic>;

    final times = hourly['time'] as List;
    final temps = hourly['temperature_2m'] as List;
    final probs =
        hourly['precipitation_probability'] as List;
    final rain = hourly['precipitation'] as List;
    final winds = hourly['wind_speed_10m'] as List;
    final codes = hourly['weather_code'] as List;

    final now = DateTime.now();
    int start = 0;
    for (int i = 0; i < times.length; i++) {
      final t = DateTime.tryParse(times[i].toString());
      if (t != null && !t.isBefore(now)) {
        start = i;
        break;
      }
    }

    final dt = daily['time'] as List;
    final maxT = daily['temperature_2m_max'] as List;
    final minT = daily['temperature_2m_min'] as List;
    final rainSum = daily['precipitation_sum'] as List;
    final rainProb =
        daily['precipitation_probability_max'] as List;
    final dailyCodes = daily['weather_code'] as List;

    return RefreshIndicator(
      onRefresh: loadWeather,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            color: Colors.teal.shade50,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'वाघाळा, ता. पाथरी, जि. परभणी',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(current['temperature_2m'] as num).round()}°C',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(weatherText(current['weather_code'])),
                  const SizedBox(height: 8),
                  Text(
                    'जाणवणारे तापमान: '
                    '${current['apparent_temperature']}°C',
                  ),
                  Text(
                    'सध्याचा पाऊस: '
                    '${current['precipitation']} मिमी',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'सध्याची स्थिती',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.45,
            children: [
              infoCard(
                'आर्द्रता',
                '${current['relative_humidity_2m']}%',
                Icons.water_drop,
              ),
              infoCard(
                'वारा',
                '${current['wind_speed_10m']} किमी/तास',
                Icons.air,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'पुढील तासांचा अंदाज',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (int i = start;
              i < start + 12 && i < times.length;
              i++)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.cloud_outlined,
                  color: Colors.teal,
                ),
                title: Text(
                  '${times[i].toString().substring(8, 13)}  •  '
                  '${weatherText(codes[i])}',
                ),
                subtitle: Text(
                  'पाऊस शक्यता: ${probs[i] ?? 0}%'
                  '  •  पाऊस: ${rain[i] ?? 0} मिमी',
                ),
                trailing: Text(
                  '${(temps[i] as num).round()}°C\n'
                  '${winds[i]} किमी/तास',
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'पुढील 10 दिवस',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          for (int i = 0; i < dt.length; i++)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.wb_cloudy_outlined,
                  color: Colors.teal,
                ),
                title: Text(
                  '${dayLabel(dt[i].toString())} — '
                  '${weatherText(dailyCodes[i])}',
                ),
                subtitle: Text(
                  'पावसाची शक्यता: ${rainProb[i] ?? 0}%'
                  ' • पाऊस: ${rainSum[i] ?? 0} मिमी',
                ),
                trailing: Text(
                  '${(maxT[i] as num).round()}° / '
                  '${(minT[i] as num).round()}°',
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'सूचना: हा अंदाज मॉडेलवर आधारित आहे. '
              'पेरणी, फवारणी किंवा काढणीपूर्वी स्थानिक '
              'हवामान इशारे तपासा.',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMap() {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(villageLat, villageLon),
        initialZoom: 9,
      ),
      children: [
        TileLayer(
          urlTemplate:
              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.havamitra.marathi',
        ),
        const MarkerLayer(
          markers: [
            Marker(
              point: LatLng(villageLat, villageLon),
              width: 130,
              height: 55,
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 32,
                  ),
                  Text(
                    'वाघाळा',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌦️ हवामित्र मराठी'),
        actions: [
          IconButton(
            onPressed: loadWeather,
            icon: const Icon(Icons.refresh),
            tooltip: 'हवामान रिफ्रेश करा',
          ),
        ],
      ),
      body: tab == 0 ? buildHome() : buildMap(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() => tab = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud),
            label: 'हवामान',
          ),
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'नकाशा',
          ),
        ],
      ),
    );
  }
}
