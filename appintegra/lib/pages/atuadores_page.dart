import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:appintegra/config.dart';

class AtuadoresPage extends StatefulWidget {
  const AtuadoresPage({super.key});

  @override
  State<AtuadoresPage> createState() => _AtuadoresPageState();
}

class _AtuadoresPageState extends State<AtuadoresPage> {
  static const _tempoLimite = Duration(seconds: 8);

  Color statusCor = Colors.red;
  num? temperatura;
  num? umidade;
  int? bomba;
  num? sensorUmidSolo;
  num? pH;
  bool carregando = false;

  /// Mensagem mostrada quando a API não responde.
  String? erro;

  num? _numero(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll(',', '.'));
    return null;
  }

  String _semApi(String acao) =>
      'Não foi possível $acao em ${Config.apiUrl} — a API está fora do ar?';

  /// GET /dados: {"temperatura", "umidade", "sensor_umidsolo", "pH", "bomba"}.
  Future<void> _leitura() async {
    setState(() {
      carregando = true;
      erro = null;
    });
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/dados'))
          .timeout(_tempoLimite);
      if (response.statusCode != 200) {
        throw Exception('a API respondeu ${response.statusCode}');
      }
      final dados = json.decode(utf8.decode(response.bodyBytes));
      if (dados is! Map) throw Exception('resposta inesperada da API');
      if (!mounted) return;
      setState(() {
        temperatura = _numero(dados['temperatura']);
        umidade = _numero(dados['umidade']);
        sensorUmidSolo = _numero(dados['sensor_umidsolo']);
        pH = _numero(dados['pH'] ?? dados['ph']);
        bomba = _numero(dados['bomba'])?.toInt();
        if (bomba != null) {
          statusCor = bomba == 1 ? Colors.green : Colors.red;
        }
      });
    } catch (e) {
      debugPrint('Erro ao ler /dados: $e');
      if (!mounted) return;
      setState(() => erro = _semApi('ler os sensores'));
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  /// POST /bomba com {"estado": 1} liga e {"estado": 0} desliga.
  Future<void> _enviarBomba(int estado) async {
    setState(() => erro = null);
    try {
      final response = await http
          .post(
            Uri.parse('${Config.apiUrl}/bomba'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'estado': estado}),
          )
          .timeout(_tempoLimite);
      if (response.statusCode != 200) {
        throw Exception('a API respondeu ${response.statusCode}');
      }
      if (!mounted) return;
      setState(() {
        bomba = estado;
        statusCor = estado == 1 ? Colors.green : Colors.red;
      });
    } catch (e) {
      debugPrint('Erro ao acionar a bomba: $e');
      if (!mounted) return;
      setState(() => erro = _semApi('acionar a bomba'));
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
      body: SingleChildScrollView(
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
                  color: statusCor.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusCor.withOpacity(0.9),
                      statusCor.withOpacity(0.7),
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
                      statusCor == Colors.green ? "LIGADA" : "DESLIGADA",
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
                      onPressed: () => _enviarBomba(1),
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
                      onPressed: () => _enviarBomba(0),
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
                icon: carregando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 24),
                label: const Text(
                  'Atualizar Dados',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: carregando ? null : _leitura,
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

            // Aviso quando a API não responde
            if (erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.black87),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          erro!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
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
                                const Icon(Icons.thermostat,
                                    size: 20, color: Colors.red),
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
                                const Icon(Icons.opacity,
                                    size: 20, color: Colors.blue),
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
                                const Icon(Icons.grass,
                                    size: 20, color: Colors.green),
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
                                const Icon(Icons.science,
                                    size: 20, color: Colors.purple),
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
