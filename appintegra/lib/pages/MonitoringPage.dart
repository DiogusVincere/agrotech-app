import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:appintegra/config.dart';

/// Leitura de um sensor já formatada para a tela.
class SensorData {
  final String title;
  final String value;
  final String status;
  final Color statusColor;
  final IconData icon;

  const SensorData({
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}

/// Leituras mostradas quando a API não responde (modo demonstração).
const Map<String, num> leiturasDeExemplo = {
  'temperatura': 25,
  'umidade': 65,
  'sensor_umidsolo': 48,
  'pH': 6.4,
};

num? _numero(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v.replaceAll(',', '.'));
  return null;
}

String _formatar(num v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

/// Classifica a leitura: dentro da faixa boa = Bom; dentro da faixa aceitável =
/// Atenção; fora = Ruim; sem leitura = Sem leitura.
(String, Color) _avaliar(num? v,
    {required num bomMin,
    required num bomMax,
    required num aceitavelMin,
    required num aceitavelMax}) {
  if (v == null) return ('Sem leitura', Colors.grey);
  if (v >= bomMin && v <= bomMax) return ('Bom', Colors.green);
  if (v >= aceitavelMin && v <= aceitavelMax) return ('Atenção', Colors.orange);
  return ('Ruim', Colors.red);
}

SensorData _sensor(String titulo, num? v, String unidade, IconData icone,
    (String, Color) avaliacao) {
  return SensorData(
    title: titulo,
    value: v == null ? '--' : '${_formatar(v)}$unidade',
    status: avaliacao.$1,
    statusColor: avaliacao.$2,
    icon: icone,
  );
}

/// Converte o JSON de `GET /dados` da API
/// ({"temperatura", "umidade", "sensor_umidsolo", "pH", "bomba"})
/// nos quatro cartões da tela. As faixas são as de um cultivo comum e servem
/// só para colorir o status; ajuste conforme a cultura.
List<SensorData> montarSensores(Map<String, dynamic> dados) {
  final temperatura = _numero(dados['temperatura']);
  final umidadeAr = _numero(dados['umidade']);
  final umidadeSolo = _numero(dados['sensor_umidsolo']);
  final ph = _numero(dados['pH'] ?? dados['ph']);

  return [
    _sensor(
      'Umidade do ar',
      umidadeAr,
      '%',
      Icons.opacity,
      _avaliar(umidadeAr,
          bomMin: 40, bomMax: 80, aceitavelMin: 30, aceitavelMax: 90),
    ),
    _sensor(
      'Temperatura do ar',
      temperatura,
      ' ºC',
      Icons.thermostat,
      _avaliar(temperatura,
          bomMin: 15, bomMax: 32, aceitavelMin: 10, aceitavelMax: 38),
    ),
    _sensor(
      'Umidade do solo',
      umidadeSolo,
      '%',
      Icons.grass,
      _avaliar(umidadeSolo,
          bomMin: 40, bomMax: 100, aceitavelMin: 25, aceitavelMax: 100),
    ),
    _sensor(
      'pH do solo',
      ph,
      '',
      Icons.science,
      _avaliar(ph,
          bomMin: 5.5, bomMax: 7.5, aceitavelMin: 5.0, aceitavelMax: 8.0),
    ),
  ];
}

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  List<SensorData> sensores = const [];
  bool carregando = true;

  /// Verdadeiro quando a lista mostra `leiturasDeExemplo`.
  bool dadosDeExemplo = false;
  String motivoExemplo = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.apiUrl}/dados'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) {
        throw Exception('a API respondeu ${response.statusCode}');
      }
      final dados = json.decode(utf8.decode(response.bodyBytes));
      if (dados is! Map) throw Exception('resposta inesperada da API');
      _mostrar(Map<String, dynamic>.from(dados), exemplo: false);
    } catch (e) {
      debugPrint('Erro ao ler /dados: $e');
      _mostrar(
        Map<String, dynamic>.from(leiturasDeExemplo),
        exemplo: true,
        motivo: 'API fora do ar (${Config.apiUrl})',
      );
    }
  }

  void _mostrar(Map<String, dynamic> dados,
      {required bool exemplo, String motivo = ''}) {
    if (!mounted) return;
    setState(() {
      sensores = montarSensores(dados);
      dadosDeExemplo = exemplo;
      motivoExemplo = motivo;
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sensores',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Atualizar leituras',
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: carregando ? null : _carregar,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aperte no sensor para ver mais informações',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            if (dadosDeExemplo) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
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
                        'Dados de exemplo — $motivoExemplo',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _carregar,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: sensores.length,
                        itemBuilder: (context, index) {
                          final sensor = sensores[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetalheSensorScreen(
                                    sensor: sensor,
                                    dadosDeExemplo: dadosDeExemplo,
                                    motivoExemplo: motivoExemplo,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      Icon(sensor.icon, color: Colors.green),
                                ),
                                title: Text(
                                  sensor.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Text(sensor.value),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sensor.statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    sensor.status,
                                    style: TextStyle(
                                      color: sensor.statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetalheSensorScreen extends StatelessWidget {
  final SensorData sensor;
  final bool dadosDeExemplo;
  final String motivoExemplo;

  const DetalheSensorScreen({
    super.key,
    required this.sensor,
    this.dadosDeExemplo = false,
    this.motivoExemplo = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          sensor.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
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
              // Cartão com ícone do sensor
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA8E063), Color(0xFF56AB2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    sensor.icon,
                    size: 90,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Cartão com informações
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Valor do Sensor",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sensor.value,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Status Atual",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: sensor.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          sensor.status,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: sensor.statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'As leituras são atualizadas na lista de sensores '
                '(ícone no topo ou arrastando a lista para baixo).',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
