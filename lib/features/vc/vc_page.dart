import 'package:flutter/material.dart';
import 'package:apiarium/shared/services/vosk_service.dart';
import 'package:apiarium/shared/utils/logger.dart'; 

class VCPage extends StatefulWidget {
  const VCPage({super.key});

  @override
  State<VCPage> createState() => _VCPageState();
}

class _VCPageState extends State<VCPage> with SingleTickerProviderStateMixin {
  static const String _tag = 'VCPage';
  final VoskService _voiceControlService = VoskService();
  
  late AnimationController _rotationController;
  
  bool _isInitializing = true;
  bool _isListening = false;
  String _recognizedText = ''; 
  String _currentSpeech = ''; 
  String _error = '';
  
  Color _bgColor = Colors.blue.shade100;
  bool _isAnimating = false;
  bool _isGrammarEnabled = true;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _initializeVoiceControl();
  }

  Future<void> _initializeVoiceControl() async {
    _voiceControlService.setCommandHandler((command) {
      setState(() {
        _recognizedText = command;
      });
      
      switch(command.toLowerCase()) {
        case 'start':
        case 'rozpocznij':
          setState(() {
            _isAnimating = true;
            _bgColor = Colors.green.shade100;
          });
          break;
        case 'stop':
        case 'zatrzymaj':
          setState(() {
            _isAnimating = false;
            _bgColor = Colors.red.shade100;
          });
          break;
        case 'change color':
        case 'zmień kolor':
          _changeColor();
          break;
      }
    });
    
    _voiceControlService.setResultHandler((resultText) {
      setState(() {
        _recognizedText = resultText;
      });
    });
    
    _voiceControlService.setPartialResultHandler((partialText) {
      setState(() {
        _currentSpeech = partialText;
      });
    });

    try {
      Logger.i("Initializing voice control", tag: _tag);
      await _voiceControlService.initialize(
        modelUrl: 'https://alphacephei.com/vosk/models/vosk-model-small-pl-0.22.zip',
        modelId: 'vosk-model-small-pl-0.22',
        onModelStatusChange: null,
        onRecognizerStatusChange: null
      );
      
      await _enableGrammar();
      
      setState(() {
        _isInitializing = false;
      });
      Logger.i("Voice control initialized successfully", tag: _tag);
    } catch (e) {
      Logger.e("Failed to initialize voice control", tag: _tag, error: e);
      setState(() {
        _isInitializing = false;
        _error = e.toString();
      });
    }
  }
  
  Future<void> _enableGrammar() async {
    if (_isListening) {
      await _voiceControlService.stopListening();
      setState(() {
        _isListening = false;
        _currentSpeech = '';
      });
    }
    
    await _voiceControlService.setCommands([
      'start', 'rozpocznij',
      'stop', 'zatrzymaj',
      'change color', 'zmień kolor',
      'jeden', 'dwa', 'trzy', 'cztery', 'pięć', 'sześć', 'siedem', 'osiem', 'dziewięć', 'dziesięć',
      'tak', 'nie', 'może', 'proszę', 'dziękuję',
      'czerwony', 'zielony', 'niebieski', 'żółty', 'pomarańczowy',
      'dwadzieścia', 'trzydzieści', 'czterdzieści', 'pięćdziesiąt',
      'ząb', 'ściana', 'łóżko', 'źle', 'żaba', 'gęś', 'miąższ', 'jeść'
    ], enableGrammar: true);
    
    setState(() {
      _isGrammarEnabled = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gramatyka włączona - rozpoznawanie ograniczone'))
    );
  }
  
  Future<void> _disableGrammar() async {
    if (_isListening) {
      await _voiceControlService.stopListening();
      setState(() {
        _isListening = false;
        _currentSpeech = '';
      });
    }
    
    await _voiceControlService.setCommands([], enableGrammar: false);
    
    setState(() {
      _isGrammarEnabled = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gramatyka wyłączona - rozpoznawanie nieograniczone'))
    );
  }
  
  void _changeColor() {
    final List<Color> colors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.red.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
    ];
    
    int currentIndex = colors.indexWhere((color) => 
        color.value == _bgColor.value);
    if (currentIndex == -1) currentIndex = 0;
    
    int nextIndex = (currentIndex + 1) % colors.length;
    
    setState(() {
      _bgColor = colors[nextIndex];
    });
  }

  Future<void> _toggleListening() async {
    try {
      if (_isListening) {
        await _voiceControlService.stopListening();
        setState(() {
          _currentSpeech = '';
        });
      } else {
        await _voiceControlService.startListening(
          onError: (error) {
            setState(() {
              _error = error;
            });
          }
        );
        setState(() {
          _recognizedText = '';
        });
      }
      
      setState(() {
        _isListening = !_isListening;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'))
      );
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _voiceControlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sterowanie głosowe')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Wczytywanie modelu rozpoznawania mowy...',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }
    
    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sterowanie głosowe')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Wystąpił błąd:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(_error, textAlign: TextAlign.center),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _initializeVoiceControl,
                child: const Text('Spróbuj ponownie'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sterowanie głosowe'),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _bgColor,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isGrammarEnabled ? Colors.blue.shade200 : Colors.orange.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isGrammarEnabled 
                      ? "Gramatyka: Włączona" 
                      : "Gramatyka: Wyłączona",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                _isAnimating
                  ? RotationTransition(
                      turns: _rotationController,
                      child: _buildMicIcon(),
                    )
                  : _buildMicIcon(),
                  
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isListening ? null : _enableGrammar,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Z Gramatyką'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isGrammarEnabled ? Colors.blue : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 15),
                    ElevatedButton.icon(
                      onPressed: _isListening ? null : _disableGrammar,
                      icon: const Icon(Icons.language),
                      label: const Text('Bez Gramatyki'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isGrammarEnabled ? Colors.orange : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                if (_isListening && _currentSpeech.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          _currentSpeech,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        _recognizedText.isEmpty 
                          ? 'Powiedz coś...' 
                          : _recognizedText,
                        style: const TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isAnimating = true;
                          _bgColor = Colors.green.shade100;
                        });
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isAnimating = false;
                          _bgColor = Colors.red.shade100;
                        });
                      },
                      icon: const Icon(Icons.stop),
                      label: const Text('STOP'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        backgroundColor: _isListening ? Colors.red : Colors.green,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        tooltip: _isListening ? 'Zatrzymaj nasłuchiwanie' : 'Rozpocznij nasłuchiwanie',
      ),
    );
  }
  
  Widget _buildMicIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2
          )
        ]
      ),
      child: const Icon(Icons.mic, size: 50),
    );
  }
}