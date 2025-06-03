import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AtuadoresPage extends StatefulWidget {
  const AtuadoresPage({super.key});

  @override
  State<AtuadoresPage> createState() => _TelaacionamentoState();
}

class _TelaacionamentoState extends State<AtuadoresPage> {
  final bool status = false;
  Color status_cor = Colors.red;
  int? temperatura;
  int? umidade;
  int? bomba;
  int? sensorUmidSolo;
  int? pH;
  
  Future<void> _leitura() async {
    final response = await http.get(Uri.parse('https://apimobile-production-8d8b.up.railway.app/dados'));
    print(response.body);
    final dados = json.decode(response.body);
    setState(() {
      temperatura = (dados["temperatura"]);
      umidade = (dados["umidade"]);
      sensorUmidSolo = (dados["sensor_umidsolo"]);
      pH = (dados["pH"]);
      bomba = dados["bomba"];
      print(temperatura);
      print(umidade);
      print(sensorUmidSolo);
      print(pH);
      print(bomba);
    });
  }

  Future<void> _ligarBomba() async {
    try {
      final response = await http.post(
        Uri.parse('https://apimobile-production-8d8b.up.railway.app/bomba'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': 1}),
      );

      if (response.statusCode == 200) {
        setState(() {
          status_cor = Colors.green;
        });
        print("Bomba ligada com sucesso!");
      } else {
        print("Erro ao ligar a bomba: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição: $e");
    }
  }

  Future<void> _desligarBomba() async {
    try {
      final response = await http.post(
        Uri.parse('https://apimobile-production-8d8b.up.railway.app/bomba'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'estado': 0}),
      );

      if (response.statusCode == 200) {
        setState(() {
          status_cor = Colors.red;
        });
        print("Bomba desligada com sucesso!");
      } else {
        print("Erro ao ligar a bomba: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro na requisição: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Controle de Atuadores',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card de Status da Bomba
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: status_cor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      status_cor.withOpacity(0.9),
                      status_cor.withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.water_drop,
                      size: 50,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Bomba de Irrigação",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      status_cor == Colors.green ? "LIGADA" : "DESLIGADA",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Botões de Controle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 24),
                      label: const Text(
                        'Ligar',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _ligarBomba,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.stop, size: 24),
                      label: const Text(
                        'Desligar',
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _desligarBomba,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Botão de Leitura
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text(
                  'Atualizar Dados',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: _leitura,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            
            // Exibição dos dados (opcional)
            if (temperatura != null || umidade != null || pH != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dados dos Sensores:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (temperatura != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.thermostat, size: 20, color: Colors.red),
                                const SizedBox(width: 8),
                                Text('Temperatura: $temperatura°C'),
                              ],
                            ),
                          ),
                        if (umidade != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.opacity, size: 20, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text('Umidade do Ar: $umidade%'),
                              ],
                            ),
                          ),
                        if (sensorUmidSolo != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.grass, size: 20, color: Colors.green),
                                const SizedBox(width: 8),
                                Text('Umidade do Solo: $sensorUmidSolo%'),
                              ],
                            ),
                          ),
                        if (pH != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.science, size: 20, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text('Nível de pH: $pH'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}