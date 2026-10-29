
import 'package:flutter/material.dart';

class ParamparikPausPage extends StatelessWidget {
  const ParamparikPausPage({super.key});

  static const sayings = [
    {
      'title': 'मृग आणि आर्द्रा',
      'saying': 'मृग करी झाडाझाड, आर्द्रा न पडे कोय.',
      'meaning':
          'मृगात वारा आणि आर्द्रेत पाऊस नसणे हे '
          'पारंपरिक मान्यतेनुसार पावसाच्या कमतरतेचे लक्षण.',
      'nakshatra': 'मृग, आर्द्रा',
    },
    {
      'title': 'पुनर्वसू आणि पुष्य',
      'saying': 'पुनर्वसु न पडे काही, पुष्य जाय कोरडा.',
      'meaning':
          'दोन्ही नक्षत्रांत पाऊस न झाल्यास शेतीला '
          'फटका बसू शकतो, अशी लोकमान्यता.',
      'nakshatra': 'पुनर्वसू, पुष्य',
    },
    {
      'title': 'उत्तरा आणि हस्त',
      'saying': 'उत्तरा पडे चार दिन, हस्त न पडे कोय.',
      'meaning':
          'उत्तरेत पाऊस होऊन हस्त कोरडा गेल्यास '
          'पाणीटंचाईची शक्यता मानली जाते.',
      'nakshatra': 'उत्तरा, हस्त',
    },
    {
      'title': 'स्वाती नक्षत्र',
      'saying': 'पडल्या साई स्वाती, तर पिकतील माणिक मोती.',
      'meaning':
          'स्वातीच्या पावसाला समृद्धीशी जोडणारी '
          'पारंपरिक म्हण.',
      'nakshatra': 'स्वाती',
    },
    {
      'title': 'हस्त नक्षत्र',
      'saying': 'पडेल हस्त तर कुळंबी मस्त.',
      'meaning':
          'हस्त नक्षत्रातील पाऊस शेतीसाठी लाभदायक '
          'मानला जातो.',
      'nakshatra': 'हस्त',
    },
    {
      'title': 'रोहिणी आणि मृग',
      'saying': 'रोहिणीने घातले आंडे, मृगाने भिजवली पाठ.',
      'meaning':
          'रोहिणीतील पावसाची स्थिती आणि मृगातील '
          'पावसावरून पुढील पावसाचा अंदाज बांधण्याची '
          'लोकपरंपरा.',
      'nakshatra': 'रोहिणी, मृग',
    },
  ];

  static const signs = [
    {
      'title': 'मुंग्या अंडी घेऊन जाताना दिसणे',
      'meaning': 'काही लोकपरंपरांत याला पावसाचा संकेत मानतात.',
      'icon': Icons.pest_control,
    },
    {
      'title': 'बेडकांचे मोठ्या प्रमाणात ओरडणे',
      'meaning': 'पावसाळ्यातील वातावरणाशी संबंधित पारंपरिक निरीक्षण.',
      'icon': Icons.nature,
    },
    {
      'title': 'चिमण्यांचे धुळीत अंघोळ करणे',
      'meaning': 'काही लोककथांमध्ये याचा पावसाशी संबंध जोडला जातो.',
      'icon': Icons.flutter_dash,
    },
    {
      'title': 'आकाशातील ढग व वाऱ्याची दिशा',
      'meaning': 'ढगांची वाढ आणि वाऱ्यातील बदल पाहा; प्रत्यक्ष पावसाचा अंदाज आधुनिक हवामान माहितीसोबत तपासा.',
      'icon': Icons.cloud,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'नक्षत्रे, सहदेव भाडळीतील म्हणी आणि '
                  'निसर्गातील पारंपरिक संकेत.',
                ),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'सहदेव भाडळीतील म्हणी',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '“${item['saying']}”',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item['meaning']!),
                  const SizedBox(height: 6),
                  Text(
                    'संबंधित नक्षत्र: ${item['nakshatra']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'निसर्गातील पारंपरिक संकेत',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        for (final sign in signs)
          Card(
            child: ListTile(
              leading: Icon(
                sign['icon'] as IconData,
                color: Colors.teal,
                size: 30,
              ),
              title: Text(sign['title'] as String),
              subtitle: Text(sign['meaning'] as String),
            ),
          ),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'महत्त्वाची सूचना: या नोंदी पारंपरिक '
              'लोकमान्यतांवर आधारित आहेत. त्यांची '
              'वैज्ञानिक अचूकता सिद्ध झालेली नाही. '
              'पेरणी, फवारणी किंवा सिंचनाचे निर्णय '
              'घेताना अधिकृत हवामान अंदाज व इशारे तपासा.',
            ),
          ),
        ),
      ],
    );
  }
}
