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

  // Lista com URLs das imagens do carrossel
  final List<String> imageUrls = [
    'https://picsum.photos/id/237/400/250',
    'https://picsum.photos/id/238/400/250',
    'https://picsum.photos/id/239/400/250',
  ];

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    const apiKey = '***REMOVIDO***'; // substitua pela sua
    final url = 'https://api.hgbrasil.com/weather?key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Log completo do JSON recebido da API
        print('Resposta completa da API:');
        print(data);

        final result = data['results'];

        // Log das informações específicas que você usa
        print('Cidade: ${result['city']}');
        print('Temperatura atual: ${result['temp']}ºC');
        print('Temperatura mínima: ${result['forecast'][0]['min']}ºC');
        print('Temperatura máxima: ${result['forecast'][0]['max']}ºC');
        print('Descrição: ${result['description']}');
        print('Data: ${result['date']}');
        print('Hora: ${result['time']}');
        print('Ícone ID: ${result['img_id']}');

        setState(() {
          city = result['city']; // cidade dinâmica com base no IP
          temperature = '${result['temp']}ºC';
          minTemp = '${result['forecast'][0]['min']}ºC';
          maxTemp = '${result['forecast'][0]['max']}ºC';
          description = result['description'];
          date = result['date'];
          time = result['time'];
          iconId = result['img_id'];
        });
      } else {
        print('Erro na requisição: status code ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar clima: $e');
    }
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
      // Caso algo dê errado, retorna vazio
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
            // Carrossel de imagens atualizado com imagens reais
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: imageUrls.length,
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
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
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
            // Card do tempo com navegação
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
                    // Título e hora
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
                      child: iconId.isNotEmpty
                          ? Image.network(
                              'https://assets.hgbrasil.com/weather/icons/conditions/$iconId.png',
                              width: 80,
                              height: 80,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.cloud,
                                      color: Colors.white, size: 60),
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
