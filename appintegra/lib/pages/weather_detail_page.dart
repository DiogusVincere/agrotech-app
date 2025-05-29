import 'package:appintegra/pages/home.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Clima'),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Voltar corretamente
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(city,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Data: $date', style: const TextStyle(fontSize: 16)),
              Text('Horário: $time', style: const TextStyle(fontSize: 16)),
              const Divider(height: 30),
              Text('Temperatura atual: $temperature',
                  style: const TextStyle(fontSize: 20)),
              Text('Mínima: $minTemp', style: const TextStyle(fontSize: 18)),
              Text('Máxima: $maxTemp', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text('Céu: $description', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              Center(
                child: Image.network(
                  'https://assets.hgbrasil.com/weather/icons/conditions/$iconId.svg',
                  width: 120,
                  height: 120,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
