import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

void main() {
  runApp(const FragilityApp());
}

class FragilityApp extends StatelessWidget {
  const FragilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Fragility Index',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  // Controllers for 12 input fields
  final Map<String, TextEditingController> controllers = {
    'c1_security_apparatus': TextEditingController(),
    'c2_factionalized_elites': TextEditingController(),
    'c3_group_grievance': TextEditingController(),
    'e1_economy': TextEditingController(),
    'e2_economic_inequality': TextEditingController(),
    'e3_human_flight': TextEditingController(),
    'p1_state_legitimacy': TextEditingController(),
    'p2_public_services': TextEditingController(),
    'p3_human_rights': TextEditingController(),
    's1_demographic_pressures': TextEditingController(),
    's2_refugees_idps': TextEditingController(),
    'x1_external_intervention': TextEditingController(),
  };

  double? fragilityScore;
  String? riskLevel;
  String? modelUsed;
  bool isLoading = false;
  String? errorMessage;

  // API URL - Production (Render)
  final String apiUrl = 'https://fragility-api.onrender.com/predict';
  // For local testing use: 'http://10.0.2.2:8000/predict' (Android Emulator)

  // Pre-fill with South Sudan example data (My case study)
  void loadSouthSudanExample() {
    setState(() {
      controllers['c1_security_apparatus']!.text = '9.7';
      controllers['c2_factionalized_elites']!.text = '9.7';
      controllers['c3_group_grievance']!.text = '8.6';
      controllers['e1_economy']!.text = '8.6';
      controllers['e2_economic_inequality']!.text = '9.4';
      controllers['e3_human_flight']!.text = '6.5';
      controllers['p1_state_legitimacy']!.text = '9.8';
      controllers['p2_public_services']!.text = '9.8';
      controllers['p3_human_rights']!.text = '9.3';
      controllers['s1_demographic_pressures']!.text = '9.7';
      controllers['s2_refugees_idps']!.text = '10.0';
      controllers['x1_external_intervention']!.text = '9.4';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Loaded South Sudan example data'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> makePrediction() async {
    // Validation
    for (var entry in controllers.entries) {
      if (entry.value.text.isEmpty) {
        setState(() => errorMessage = 'Please fill in all 12 indicators');
        return;
      }
    }

    for (var entry in controllers.entries) {
      double? value = double.tryParse(entry.value.text);
      if (value == null || value < 0 || value > 10) {
        setState(
          () => errorMessage = 'All values must be between 0.0 and 10.0',
        );
        return;
      }
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      fragilityScore = null;
      riskLevel = null;
    });

    try {
      Map<String, dynamic> requestBody = {
        'c1_security_apparatus': double.parse(
          controllers['c1_security_apparatus']!.text,
        ),
        'c2_factionalized_elites': double.parse(
          controllers['c2_factionalized_elites']!.text,
        ),
        'c3_group_grievance': double.parse(
          controllers['c3_group_grievance']!.text,
        ),
        'e1_economy': double.parse(controllers['e1_economy']!.text),
        'e2_economic_inequality': double.parse(
          controllers['e2_economic_inequality']!.text,
        ),
        'e3_human_flight': double.parse(controllers['e3_human_flight']!.text),
        'p1_state_legitimacy': double.parse(
          controllers['p1_state_legitimacy']!.text,
        ),
        'p2_public_services': double.parse(
          controllers['p2_public_services']!.text,
        ),
        'p3_human_rights': double.parse(controllers['p3_human_rights']!.text),
        's1_demographic_pressures': double.parse(
          controllers['s1_demographic_pressures']!.text,
        ),
        's2_refugees_idps': double.parse(controllers['s2_refugees_idps']!.text),
        'x1_external_intervention': double.parse(
          controllers['x1_external_intervention']!.text,
        ),
      };

      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fragilityScore = data['fragility_score'].toDouble();
          riskLevel = data['risk_level'];
          modelUsed = data['model_used'];
          errorMessage = null;
        });
      } else {
        final error = jsonDecode(response.body);
        setState(() => errorMessage = error['detail'] ?? 'Prediction failed');
      }
    } catch (e) {
      setState(
        () => errorMessage =
            'Connection failed. Ensure API is running at:\n$apiUrl',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color getRiskColor(String risk) {
    switch (risk) {
      case 'Sustainable':
        return Colors.green;
      case 'Stable':
        return Colors.blue;
      case 'Warning':
        return Colors.orange;
      case 'Alert':
        return Colors.deepOrange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Beautiful App Bar
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'State Fragility Index',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade900,
                      Colors.indigo.shade600,
                      Colors.blue.shade800,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.public, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mission Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.indigo.shade50],
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.indigo),
                          const SizedBox(height: 8),
                          Text(
                            'Predicting state fragility to foster enduring peace and sustainable development',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.indigo.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Load Button
                  ElevatedButton.icon(
                    onPressed: loadSouthSudanExample,
                    icon: const Icon(Icons.download),
                    label: const Text('Load South Sudan Example Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Input Sections
                  _buildSectionTitle('Cohesion Indicators', Icons.groups),
                  _buildInputCard([
                    _buildInputField(
                      'c1_security_apparatus',
                      'Security Apparatus',
                      Icons.security,
                    ),
                    _buildInputField(
                      'c2_factionalized_elites',
                      'Factionalized Elites',
                      Icons.people_outline,
                    ),
                    _buildInputField(
                      'c3_group_grievance',
                      'Group Grievance',
                      Icons.warning_amber,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _buildSectionTitle('Economic Indicators', Icons.trending_up),
                  _buildInputCard([
                    _buildInputField(
                      'e1_economy',
                      'Economic Decline',
                      Icons.trending_down,
                    ),
                    _buildInputField(
                      'e2_economic_inequality',
                      'Uneven Development',
                      Icons.balance,
                    ),
                    _buildInputField(
                      'e3_human_flight',
                      'Human Flight & Brain Drain',
                      Icons.flight_takeoff,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _buildSectionTitle(
                    'Political Indicators',
                    Icons.account_balance,
                  ),
                  _buildInputCard([
                    _buildInputField(
                      'p1_state_legitimacy',
                      'State Legitimacy',
                      Icons.gavel,
                    ),
                    _buildInputField(
                      'p2_public_services',
                      'Public Services',
                      Icons.miscellaneous_services,
                    ),
                    _buildInputField(
                      'p3_human_rights',
                      'Human Rights',
                      Icons.accessibility_new,
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _buildSectionTitle('Social Indicators', Icons.terrain),
                  _buildInputCard([
                    _buildInputField(
                      's1_demographic_pressures',
                      'Demographic Pressures',
                      Icons.trending_up,
                    ),
                    _buildInputField(
                      's2_refugees_idps',
                      'Refugees & IDPs',
                      Icons.people,
                    ),
                    _buildInputField(
                      'x1_external_intervention',
                      'External Intervention',
                      Icons.public,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Predict Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : makePrediction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                      ),
                      child: isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Analyzing...',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.analytics, size: 28),
                                SizedBox(width: 12),
                                Text(
                                  'PREDICT FRAGILITY',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Error Message
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Results Section
                  if (fragilityScore != null) ...[
                    const SizedBox(height: 24),
                    _buildResultCard(),
                  ],

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInputField(String key, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controllers[key],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          hintText: '0.0 - 10.0',
          prefixIcon: Icon(icon, color: Colors.indigo.shade400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.indigo.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final color = getRiskColor(riskLevel!);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Gauge visualization
            SizedBox(
              height: 150,
              child: CustomPaint(
                size: const Size(200, 150),
                painter: GaugePainter(score: fragilityScore!, color: color),
              ),
            ),

            const SizedBox(height: 16),

            // Score
            Text(
              fragilityScore!.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const Text(
              'Fragility Score',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Risk Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                riskLevel!.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            if (modelUsed != null) ...[
              const SizedBox(height: 12),
              Text(
                'Model: $modelUsed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Custom Gauge Painter for visual appeal
class GaugePainter extends CustomPainter {
  final double score;
  final Color color;

  GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / 120) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      valuePaint,
    );

    // Needle
    final needleAngle = math.pi + sweepAngle;
    final needlePaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final needleEnd = Offset(
      center.dx + (radius - 30) * math.cos(needleAngle),
      center.dy + (radius - 30) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, 8, Paint()..color = Colors.black87);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
