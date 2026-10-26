import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AssistantApp());
}

class AssistantApp extends StatelessWidget {
  const AssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
        ),
        useMaterial3: true,
      ),
      home: const AssistantHomePage(),
    );
  }
}

class AssistantHomePage extends StatefulWidget {
  const AssistantHomePage({super.key});

  @override
  State<AssistantHomePage> createState() => _AssistantHomePageState();
}

class _AssistantHomePageState extends State<AssistantHomePage> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  String _assistantStatus = "Standing by locally";

  @override
  void initState() {
    super.initState();
    _initTTS();
    _requestInitialPermissions();
  }

  Future<void> _requestInitialPermissions() async {
    await Permission.notification.request();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);

    _tts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _assistantStatus = "Speaking reply...";
      });
    });

    _tts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _assistantStatus = "Standing by locally";
      });
    });

    _tts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _assistantStatus = "TTS Error: $msg";
      });
    });
  }

  Future<void> _speakTest() async {
    const message = "System operational. Local privacy protocols active. Ready for background tasks.";
    await _tts.speak(message);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant Engine', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isSpeaking ? const Color(0xFF38BDF8).withOpacity(0.2) : const Color(0xFF1E293B),
                  border: Border.all(
                    color: _isSpeaking ? const Color(0xFF38BDF8) : Colors.white24,
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  _isSpeaking ? Icons.graphic_eq : Icons.mic_none,
                  size: 48,
                  color: _isSpeaking ? const Color(0xFF38BDF8) : Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _assistantStatus,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              FilledButton.icon(
                onPressed: _speakTest,
                icon: const Icon(Icons.volume_up),
                label: const Text('Test Local Voice Output'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
