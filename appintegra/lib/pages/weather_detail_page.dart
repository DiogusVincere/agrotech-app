import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class WeatherDetailPage extends StatelessWidget {
  final String city;
  final String temperature;
  final String minTemp;
  final String maxTemp;
  final String description;
  final String date;
  final String time;
  final String iconId;
  final String humidity;
  final String cloudiness;
  final String rain;
  final String windSpeed;
  final String windDirection;
  final String windCardinal;
  final String sunrise;
  final String sunset;
  final String moonPhase;
  final String conditionSlug;
  final String timezone;

  /// Verdadeiro quando os valores vieram do modo demonstração.
  final bool dadosDeExemplo;
  final String motivoExemplo;

  const WeatherDetailPage({
    super.key,
    required this.city,
    required this.temperature,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
    required this.date,
    required this.time,
    required this.iconId,
    required this.humidity,
    required this.cloudiness,
    required this.rain,
    required this.windSpeed,
    required this.windDirection,
    required this.windCardinal,
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.conditionSlug,
    required this.timezone,
    this.dadosDeExemplo = false,
    this.motivoExemplo = '',
  });

  String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    const textStyleTitle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );

    final textStyleSub = TextStyle(
      fontSize: 16,
      color: Colors.grey[600],
    );

    int hour = int.tryParse(time.split(':')[0]) ?? 12;
    String period = (hour >= 6 && hour < 18) ? 'dia' : 'noite';
    String descriptionKey = '${capitalize(description)}_$period';

    final Map<String, String> weatherIcons = {
      'Ensolarado_dia': 'images/clear_day.svg',
      'Limpo_dia': 'images/clear_day.svg',
      'Nublado_dia': 'images/cloudly_day.svg',
      'Parcialmente nublado_dia': 'images/cloudly_day.svg',
      'Chuva_dia': 'images/rain.svg',
      'Tempestade_dia': 'images/storm.svg',
      'Neve_dia': 'images/snow.svg',
      'Nevoeiro_dia': 'images/fog.svg',

      'Ensolarado_noite': 'images/clear_night.svg',
      'Limpo_noite': 'images/clear_night.svg',
      'Nublado_noite': 'images/cloudly_night.svg',
      'Parcialmente nublado_noite': 'images/cloudly_night.svg',
      'Chuva_noite': 'images/rain.svg',
      'Tempestade_noite': 'images/storm.svg',
      'Neve_noite': 'images/snow.svg',
      'Nevoeiro_noite': 'images/fog.svg',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Detalhes do Clima',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (dadosDeExemplo) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dados de exemplo — $motivoExemplo',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Text(city, style: textStyleTitle),
              const SizedBox(height: 6),
              Text('📅 $date   🕒 $time', style: textStyleSub),
              const SizedBox(height: 20),
              descriptionKey.isNotEmpty &&
                      weatherIcons.containsKey(descriptionKey)
                  ? SvgPicture.asset(
                      weatherIcons[descriptionKey]!,
                      width: 80,
                      height: 80,
                      placeholderBuilder: (context) =>
                          const CircularProgressIndicator(),
                    )
                  : const Icon(Icons.cloud, color: Colors.blueGrey, size: 60),
              const SizedBox(height: 20),
              Text(
                description.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                temperature,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 10),
              Text('Mín: $minTemp  |  Máx: $maxTemp', style: textStyleSub),
              const SizedBox(height: 20),
              Divider(),
              Text('🌦 Umidade: $humidity%', style: textStyleSub),
              Text('☁️ Nebulosidade: $cloudiness%', style: textStyleSub),
              Text('🌧 Chuva (últ. hora): $rain mm', style: textStyleSub),
              Text('💨 Vento: $windSpeed | Direção: $windDirection° ($windCardinal)', style: textStyleSub),
              Text('🌅 Nascer do Sol: $sunrise', style: textStyleSub),
              Text('🌇 Pôr do Sol: $sunset', style: textStyleSub),
              Text('🌙 Fase da Lua: $moonPhase', style: textStyleSub),
              Text('🕓 Fuso Horário: $timezone', style: textStyleSub),
            ],
          ),
        ),
      ),
    );
  }
}
