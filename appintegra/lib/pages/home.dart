import 'package:appintegra/pages/weather_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String city = '';
  String temperature = '';
  String minTemp = '';
  String maxTemp = '';
  String description = '';
  String date = '';
  String time = '';
  String iconId = '';
  String period = ''; // dia ou noite
  String descriptionKey = ''; // Descrição + _dia ou _noite
  String humidity = '';
  String cloudiness = '';
  String rain = '';
  String windSpeed = '';
  String windDirection = '';
  String windCardinal = '';
  String sunrise = '';
  String sunset = '';
  String moonPhase = '';
  String conditionSlug = '';
  String timezone = '';

  final Map<String, String> weatherIcons = {
    // Dia
    'Ensolarado_dia': 'images/clear_day.svg',
    'limpo_dia': 'images/clear_day.svg',
    'tempo_limpo': 'images/clear_day.svg',
    'Nublado_dia': 'images/cloudly_day.svg',
    'Parcialmente nublado_dia': 'images/cloudly_day.svg',
    'Chuva_dia': 'images/rain.svg',
    'Tempestade_dia': 'images/storm.svg',
    'Neve_dia': 'images/snow.svg',
    'Nevoeiro_dia': 'images/fog.svg',

    // Noite
    'Ensolarado_noite': 'images/clear_night.svg',
    'Limpo_noite': 'images/clear_night.svg',
    'Nublado_noite': 'images/cloudly_night.svg',
    'Parcialmente nublado_noite': 'images/cloudly_night.svg',
    'Chuva_noite': 'images/rain.svg',
    'Tempestade_noite': 'images/storm.svg',
    'Neve_noite': 'images/snow.svg',
    'Nevoeiro_noite': 'images/fog.svg',
  };

  final List<String> imagePaths = [
    'images/carrossel1.png',
    'images/carrossel2.png',
    'images/carrossel3.png',
  ];

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = '***REMOVIDO***'; // Substitua pela sua
    final url = 'https://api.hgbrasil.com/weather?key=$apiKey'; //&woeid=455828

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['results'];

        setState(() {
          city = result['city'];
          temperature = '${result['temp']}ºC';
          minTemp = '${result['forecast'][0]['min']}ºC';
          maxTemp = '${result['forecast'][0]['max']}ºC';
          description = result['description'];
          date = result['date'];
          time = result['time'];
          iconId = result['img_id'];
          humidity = result['humidity']
              .toString(); // por exemplo, pode ser int, transforme em String
          cloudiness = result['clouds'].toString();
          rain = result['rain'].toString();
          windSpeed = result['wind_speed'].toString();
          windDirection = result['wind_direction'].toString();
          windCardinal = result['wind_cardinal']; // string tipo 'N', 'NE', etc.
          sunrise = result['sunrise'];
          sunset = result['sunset'];
          moonPhase = result['moon_phase'];
          conditionSlug = result['condition_slug'];
          timezone = result['timezone'];

          // Define se é dia ou noite com base na hora
          int hour = int.tryParse(time.split(':')[0]) ?? 12;
          period = (hour >= 6 && hour < 18) ? 'dia' : 'noite';

          // Cria a chave de descrição + período
          descriptionKey = '${capitalize(description)}_$period';
        });
      } else {
        print('Erro na requisição: status code ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar clima: $e');
    }
  }

  // Capitaliza a primeira letra da descrição
  String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  // Função para converter a data em nome do dia da semana em português
  String getDayName(String dateString) {
    try {
      final parts = dateString.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final date = DateTime(year, month, day);

      const days = [
        'Segunda-feira',
        'Terça-feira',
        'Quarta-feira',
        'Quinta-feira',
        'Sexta-feira',
        'Sábado',
        'Domingo',
      ];

      return days[date.weekday - 1];
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Center(
              child: Text(
                'AgroTech',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purpleAccent),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        imagePaths[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image,
                                size: 60, color: Colors.red),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WeatherDetailPage(
                            city: city,
                            temperature: temperature,
                            minTemp: minTemp,
                            maxTemp: maxTemp,
                            description: description,
                            date: date,
                            time: time,
                            iconId: iconId,
                            humidity: humidity, // <-- aqui
                            cloudiness: cloudiness,
                            rain: rain,
                            windSpeed: windSpeed,
                            windDirection: windDirection,
                            windCardinal: windCardinal,
                            sunrise: sunrise,
                            sunset: sunset,
                            moonPhase: moonPhase,
                            conditionSlug: conditionSlug,
                            timezone: timezone,
                          )),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF431A76), Color(0xFF6C28A9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
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
                              city,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${getDayName(date)}, $date',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      temperature,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$minTemp / $maxTemp',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: descriptionKey.isNotEmpty &&
                              weatherIcons.containsKey(descriptionKey)
                          ? SvgPicture.asset(
                              weatherIcons[descriptionKey]!,
                              width: 80,
                              height: 80,
                              placeholderBuilder: (context) =>
                                  const CircularProgressIndicator(),
                            )
                          : const Icon(Icons.cloud,
                              color: Colors.white, size: 60),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
