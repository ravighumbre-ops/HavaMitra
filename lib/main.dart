import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const HavaMitraApp());
}

const double villageLat = 19.130057;
const double villageLon = 76.469843;

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
        throw Exception('हवामान सेवा उपलब्ध नाही.');
      }

      final result =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        weather = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error =
            'हवामान मिळाले नाही. इंटरनेट तपासा आणि पुन्हा प्रयत्न करा.';
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
    if (c >= 80 && c <= 82) return 'पावसाच्या सरी';
    if (c >= 95) return 'मेघगर्जना';
    return 'हवामान बदलते आहे';
  }

  String dayLabel(String value) {
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    return '${d.day}/${d.month}/${d.year}';
  }

  String timeLabel(String value) {
    final d = DateTime.tryParse(value);
    if (d == null) return value;
    return '${d.hour.toString().padLeft(2, '0')}:00';
  }

  Widget sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 25),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget infoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHome() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (weather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off,
                size: 55,
                color: Colors.teal,
              ),
              const SizedBox(height: 12),
              Text(error ?? 'माहिती उपलब्ध नाही'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: loadWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('पुन्हा प्रयत्न करा'),
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

    final dt = daily['time'] as List;
    final maxT = daily['temperature_2m_max'] as List;
    final minT = daily['temperature_2m_min'] as List;
    final rainSum = daily['precipitation_sum'] as List;
    final rainProb =
        daily['precipitation_probability_max'] as List;
    final dailyCodes = daily['weather_code'] as List;

    final now = DateTime.now();
    int start = 0;

    for (int i = 0; i < times.length; i++) {
      final t = DateTime.tryParse(times[i].toString());
      if (t != null && !t.isBefore(now)) {
        start = i;
        break;
      }
    }

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
                  const Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.teal,
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'वाघाळा, ता. पाथरी, जि. परभणी',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${(current['temperature_2m'] as num).round()}°C',
                    style: const TextStyle(
                      fontSize: 43,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    weatherText(current['weather_code']),
                    style: const TextStyle(fontSize: 18),
                  ),
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
          sectionTitle('सध्याची स्थिती', Icons.thermostat),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              infoCard(
                'आर्द्रता',
                '${current['relative_humidity_2m']}%',
                Icons.water_drop,
              ),
              infoCard(
                'वाऱ्याचा वेग',
                '${current['wind_speed_10m']} किमी/तास',
                Icons.air,
              ),
            ],
          ),
          sectionTitle(
            'पुढील तासांचा अंदाज',
            Icons.schedule,
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
                  '${timeLabel(times[i].toString())} • '
                  '${weatherText(codes[i])}',
                ),
                subtitle: Text(
                  'पावसाची शक्यता: ${probs[i] ?? 0}%\n'
                  'पाऊस: ${rain[i] ?? 0} मिमी',
                ),
                isThreeLine: true,
                trailing: Text(
                  '${(temps[i] as num).round()}°C\n'
                  '${winds[i]} किमी/तास',
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          sectionTitle(
            'पुढील 10 दिवसांचा अंदाज',
            Icons.calendar_month,
          ),
          for (int i = 0; i < dt.length; i++)
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.wb_cloudy_outlined,
                  color: Colors.teal,
                ),
                title: Text(
                  '${dayLabel(dt[i].toString())}\n'
                  '${weatherText(dailyCodes[i])}',
                ),
                subtitle: Text(
                  'पावसाची शक्यता: ${rainProb[i] ?? 0}%\n'
                  'पावसाचे प्रमाण: ${rainSum[i] ?? 0} मिमी',
                ),
                isThreeLine: true,
                trailing: Text(
                  '${(maxT[i] as num).round()}° / '
                  '${(minT[i] as num).round()}°C',
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'महत्त्वाचे: हा संगणकीय हवामान अंदाज आहे. '
                'स्थानिक पाऊस व अधिकृत हवामान इशारे '
                'वेगळे असू शकतात.',
              ),
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
        initialZoom: 10,
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
              height: 65,
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 34,
                  ),
                  Text(
                    'वाघाळा',
                    style: TextStyle(
                      backgroundColor: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget buildTraditional() {
    const sayings = [
      {
        'title': 'मृग आणि आर्द्रा',
        'saying': 'मृग करी झाडाझाड, आर्द्रा न पडे कोय.',
        'meaning':
            'मृगात वारा आणि आर्द्रेत पाऊस न पडणे '
            'हे पावसाच्या कमतरतेचे पारंपरिक लक्षण मानले जाते.',
      },
      {
        'title': 'पुनर्वसू आणि पुष्य',
        'saying': 'पुनर्वसु न पडे काही, पुष्य जाय कोरडा.',
        'meaning':
            'या काळात पाऊस न झाल्यास शेतीला फटका '
            'बसू शकतो, अशी लोकमान्यता आहे.',
      },
      {
        'title': 'उत्तरा आणि हस्त',
        'saying': 'उत्तरा पडे चार दिन, हस्त न पडे कोय.',
        'meaning':
            'उत्तरा नक्षत्रात पाऊस होऊन हस्त कोरडा '
            'गेल्यास पाणीटंचाईची शक्यता मानली जाते.',
      },
      {
        'title': 'स्वाती नक्षत्र',
        'saying': 'पडल्या साई स्वाती, तर पिकतील माणिक मोती.',
        'meaning':
            'स्वातीतील पावसाला समृद्धीशी जोडणारी '
            'पारंपरिक लोकमान्यता.',
      },
      {
        'title': 'हस्त नक्षत्र',
        'saying': 'पडेल हस्त तर कुळंबी मस्त.',
        'meaning':
            'हस्त नक्षत्रातील पाऊस शेतीसाठी '
            'लाभदायक मानला जातो.',
      },
      {
        'title': 'रोहिणी आणि मृग',
        'saying': 'रोहिणीने घातले आंडे, मृगाने भिजवली पाठ.',
        'meaning':
            'रोहिणीतील परिस्थिती व मृगातील पावसावरून '
            'पुढील पावसाचा अंदाज बांधण्याची लोकपरंपरा.',
      },
    ];

    const signs = [
      {
        'title': 'मुंग्या अंडी घेऊन जाताना दिसणे',
        'meaning':
            'काही लोकपरंपरांत याला पावसाचा संकेत मानतात.',
      },
      {
        'title': 'बेडकांचे आवाज वाढणे',
        'meaning':
            'पावसाळ्यातील वातावरणाशी संबंधित पारंपरिक निरीक्षण.',
      },
      {
        'title': 'ढगांचा रंग व वाऱ्याची दिशा',
        'meaning':
            'ढग व वारा यांचे निरीक्षण करा; अधिकृत अंदाजाशी तुलना करा.',
      },
      {
        'title': 'चंद्राभोवती वलय',
        'meaning':
            'काही लोकपरंपरांत याचा पावसाशी संबंध जोडला जातो; '
            'यावरून पाऊस निश्चित सांगता येत नाही.',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: Colors.teal.shade50,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🌾 पारंपरिक पाऊस-अंदाज',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'नक्षत्रे, सहदेव भाडळीतील म्हणी आणि '
                  'निसर्गातील पारंपरिक संकेत.',
                ),
                SizedBox(height: 8),
                Text(
                  'ही माहिती लोकपरंपरेसाठी आहे. '
                  'ती वैज्ञानिक पाऊस-भविष्यवाणी नाही.',
                ),
              ],
            ),
          ),
        ),
        sectionTitle(
          'सहदेव भाडळीतील म्हणी',
          Icons.auto_stories,
        ),
        for (final item in sayings)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“${item['saying']}”',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item['meaning']!),
                ],
              ),
            ),
          ),
        sectionTitle(
          'निसर्गातील पारंपरिक संकेत',
          Icons.nature,
        ),
        for (final sign in signs)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.cloud_outlined,
                color: Colors.teal,
                size: 30,
              ),
              title: Text(sign['title']!),
              subtitle: Text(sign['meaning']!),
            ),
          ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'शेतीविषयक महत्त्वाचे निर्णय घेण्यापूर्वी '
              'आधुनिक हवामान अंदाज आणि अधिकृत इशारे तपासा.',
            ),
          ),
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
          if (tab == 0)
            IconButton(
              onPressed: loading ? null : loadWeather,
              icon: const Icon(Icons.refresh),
              tooltip: 'हवामान रिफ्रेश करा',
            ),
        ],
      ),
      body: IndexedStack(
        index: tab,
        children: [
          buildHome(),
          buildMap(),
          buildTraditional(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) {
          setState(() => tab = value);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud),
            selectedIcon: Icon(Icons.cloud_done),
            label: 'हवामान',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'नकाशा',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'पारंपरिक अंदाज',
          ),
        ],
      ),
    );
  }
}

