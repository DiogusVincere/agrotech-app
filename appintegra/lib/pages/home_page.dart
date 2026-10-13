import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:appintegra/config.dart';
import 'package:appintegra/pages/weather_detail_page.dart';

/// Chave da HG Brasil Weather, informada em tempo de compilação:
/// `flutter run --dart-define=HG_KEY=sua_chave`.
/// Vazia, o app entra em modo demonstração e mostra um clima de exemplo.
const apiKey = String.fromEnvironment('HG_KEY');

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

  /// Verdadeiro quando o cartão mostra dados de exemplo
  /// (sem chave da HG Brasil ou sem resposta da API).
  bool dadosDeExemplo = false;
  String motivoExemplo = '';

  final Map<String, String> weatherIcons = {
    // Dia
    'Ensolarado_dia': 'images/clear_day.svg',
    'Limpo_dia': 'images/clear_day.svg',
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
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchWeather());
  }

  Future<void> fetchWeather() async {
    if (apiKey.isEmpty) {
      _usarDadosDeExemplo('sem chave da HG Brasil (defina HG_KEY)');
      return;
    }

    final url = Uri.parse('${Config.hgWeatherUrl}?key=$apiKey');

    try {
      final response =
          await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        _usarDadosDeExemplo('a HG Brasil respondeu ${response.statusCode}');
        return;
      }
      final data = json.decode(utf8.decode(response.bodyBytes));
      final result = data is Map ? data['results'] : null;
      if (result is! Map) {
        _usarDadosDeExemplo('resposta inesperada da HG Brasil');
        return;
      }
      _aplicar(Map<String, dynamic>.from(result), exemplo: false);
    } catch (e) {
      debugPrint('Erro ao buscar clima: $e');
      _usarDadosDeExemplo('não foi possível consultar a HG Brasil');
    }
  }

  /// Preenche os campos da tela a partir do bloco `results` da HG Brasil
  /// (ou de um bloco de exemplo com as mesmas chaves).
  void _aplicar(Map<String, dynamic> r,
      {required bool exemplo, String motivo = ''}) {
    if (!mounted) return;
    String s(dynamic v) => v?.toString() ?? '';
    final forecast = r['forecast'];
    final Map hoje =
        (forecast is List && forecast.isNotEmpty && forecast.first is Map)
            ? forecast.first as Map
            : const {};

    setState(() {
      dadosDeExemplo = exemplo;
      motivoExemplo = motivo;
      city = s(r['city']);
      temperature = '${s(r['temp'])}ºC';
      minTemp = '${s(hoje['min'])}ºC';
      maxTemp = '${s(hoje['max'])}ºC';
      description = s(r['description']);
      date = s(r['date']);
      time = s(r['time']);
      iconId = s(r['img_id']);
      humidity = s(r['humidity']);
      cloudiness = s(r['clouds']);
      rain = s(r['rain']);
      windSpeed = s(r['wind_speed']);
      windDirection = s(r['wind_direction']);
      windCardinal = s(r['wind_cardinal']); // 'N', 'NE', etc.
      sunrise = s(r['sunrise']);
      sunset = s(r['sunset']);
      moonPhase = s(r['moon_phase']);
      conditionSlug = s(r['condition_slug']);
      timezone = s(r['timezone']);

      // Define se é dia ou noite com base na hora
      final hour = int.tryParse(time.split(':').first) ?? 12;
      period = (hour >= 6 && hour < 18) ? 'dia' : 'noite';

      // Cria a chave de descrição + período
      descriptionKey = '${capitalize(description)}_$period';
    });
  }

  /// Modo demonstração: um clima plausível, com a data e a hora de agora,
  /// para a tela não ficar vazia nem quebrar quando não há chave ou rede.
  void _usarDadosDeExemplo(String motivo) {
    final agora = DateTime.now();
    String dois(int n) => n.toString().padLeft(2, '0');
    _aplicar(
      {
        'city': 'Campinas, SP',
        'temp': 27,
        'description': 'Parcialmente nublado',
        'date': '${dois(agora.day)}/${dois(agora.month)}/${agora.year}',
        'time': '${dois(agora.hour)}:${dois(agora.minute)}',
        'img_id': '2',
        'humidity': 58,
        'clouds': 40,
        'rain': 0,
        'wind_speed': '12 km/h',
        'wind_direction': 135,
        'wind_cardinal': 'SE',
        'sunrise': '05:50 am',
        'sunset': '06:10 pm',
        'moon_phase': 'waxing_crescent',
        'condition_slug': 'cloudly_day',
        'timezone': 'America/Sao_Paulo',
        'forecast': [
          {'min': 18, 'max': 30},
        ],
      },
      exemplo: true,
      motivo: motivo,
    );
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
                            humidity: humidity,
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
                            dadosDeExemplo: dadosDeExemplo,
                            motivoExemplo: motivoExemplo,
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
                    if (dadosDeExemplo) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Dados de exemplo — $motivoExemplo',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
