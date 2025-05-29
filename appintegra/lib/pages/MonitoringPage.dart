import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:8000'; 

class SensorData {
  final String title;
  final String value;
  final String status;
  final Color statusColor;
  final IconData icon;

  SensorData({
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.icon,
  });
}

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final List<SensorData> sensores = [
    SensorData(
      title: 'Sensor de umidade',
      value: '80%',
      status: 'Bom',
      statusColor: Colors.green,
      icon: Icons.opacity, // Ícone de gota de água
    ),
    SensorData(
      title: 'Sensor do ar',
      value: '25 ºC',
      status: 'Bom',
      statusColor: Colors.green,
      icon: Icons.air, // Ícone de ar/vento
    ),
    SensorData(
      title: 'Sensor do solo',
      value: '80%',
      status: 'Bom',
      statusColor: Colors.green,
      icon: Icons.grass, // Ícone de grama/planta
    ),
    SensorData(
      title: 'Sensor de temperatura',
      value: '2',
      status: 'Ruim',
      statusColor: Colors.red,
      icon: Icons.thermostat, // Ícone de termômetro
    ),
  ];

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
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: sensores.length,
                itemBuilder: (context, index) {
                  final sensor = sensores[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalheSensorScreen(sensor: sensor),
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
                          child: Icon(sensor.icon, color: Colors.green),
                        ),
                        title: Text(
                          sensor.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
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
          ],
        ),
      ),
    );
  }
}

class DetalheSensorScreen extends StatefulWidget {
  final SensorData sensor;
  
  const DetalheSensorScreen({super.key, required this.sensor});

  @override
  State<DetalheSensorScreen> createState() => _DetalheSensorScreenState();
}

class _DetalheSensorScreenState extends State<DetalheSensorScreen> {
  Future<void> _leitura() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/dados'));
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5EE),
      appBar: AppBar(
        title: Text(widget.sensor.title),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                widget.sensor.icon,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Valor: ${widget.sensor.value}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Status: ${widget.sensor.status}",
              style: TextStyle(
                fontSize: 16,
                color: widget.sensor.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}