// import 'package:flutter/material.dart';
// import 'package:apiarium/shared/services/vosk_service.dart';

// class VCPage extends StatefulWidget {
//   const VCPage({super.key});

//   @override
//   State<VCPage> createState() => _VCPageState();
// }

// class _VCPageState extends State<VCPage> {
//   final VoskService _voiceControlService = VoskService();
  
//   bool _isInitializing = true;
//   bool _isListening = false;
//   String _lastCommand = '';
//   String _currentSpeech = '';
//   String _recognizedText = ''; // This will store the final recognition result
//   String _error = '';
//   double _downloadProgress = 0.0;
  
//   // Debug information
//   String _modelStatus = 'Not initialized';
//   String _recognizerStatus = 'Not initialized';
//   String _rawPartialResult = '';
//   String _rawFinalResult = '';

//   @override
//   void initState() {
//     super.initState();
//     _initializeVoiceControl();
//   }

//   Future<void> _initializeVoiceControl() async {
//     // Setup command handler
//     _voiceControlService.setCommandHandler((command) {
//       setState(() {
//         _lastCommand = command;
//         // Don't reset current speech when command is recognized
//       });
      
//       // Handle commands
//       switch(command.toLowerCase()) {
//         case 'start':
//         case 'rozpocznij':
//           _showSnackBar('Rozpoczęto działanie');
//           break;
//         case 'stop':
//         case 'zatrzymaj':
//           _showSnackBar('Zatrzymano działanie');
//           break;
//         case 'change color':
//         case 'zmień kolor':
//           _showSnackBar('Zmieniam kolor');
//           break;        
//         case 'jeden':
//           _showSnackBar('Zmieniam kolor');
//           break;
//         // Add more commands here
//       }
//     });
    
//     // Setup result handler for final speech recognition
//     _voiceControlService.setResultHandler((resultText) {
//       setState(() {
//         _recognizedText = resultText;
//       });
//     });
    
//     // Setup partial result handler for live speech feedback
//     _voiceControlService.setPartialResultHandler((partialText) {
//       setState(() {
//         _currentSpeech = partialText;
//       });
//     });
    
//     // Add raw result handlers
//     _voiceControlService.setRawPartialResultHandler((raw) {
//       setState(() {
//         _rawPartialResult = raw;
//       });
//     });
    
//     _voiceControlService.setRawResultHandler((raw) {
//       setState(() {
//         _rawFinalResult = raw;
//       });
//     });

//     try {
//       // Load model with fake progress updates (since vosk doesn't provide progress)
//       // This simulates loading progress
//       _simulateDownloadProgress();
      
//       setState(() {
//         _modelStatus = 'Loading...';
//       });
      
//       // Real initialization
//       await _voiceControlService.initialize(
//         modelUrl: 'https://alphacephei.com/vosk/models/vosk-model-small-pl-0.22.zip',
//         modelId: 'vosk-model-small-pl-0.22',
//         onModelStatusChange: (status) {
//           setState(() {
//             _modelStatus = status;
//           });
//         },
//         onRecognizerStatusChange: (status) {
//           setState(() {
//             _recognizerStatus = status;
//           });
//         }
//       );
      
//       // Set available commands
//       await _voiceControlService.setCommands([
//         'start', 'rozpocznij',
//         'stop', 'zatrzymaj',
//         'change color', 'zmień kolor',
//         'jeden', 'test'
//       ]);
      
//       setState(() {
//         _isInitializing = false;
//         _downloadProgress = 1.0;
//       });
//     } catch (e) {
//       setState(() {
//         _isInitializing = false;
//         _error = e.toString();
//       });
//     }
//   }
  
//   // Simulate download progress since Vosk doesn't provide progress callbacks
//   void _simulateDownloadProgress() {
//     Future.delayed(Duration.zero, () {
//       setState(() {
//         _downloadProgress = 0.1;
//       });
//     });
    
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (_isInitializing) setState(() { _downloadProgress = 0.3; });
//     });
    
//     Future.delayed(const Duration(milliseconds: 600), () {
//       if (_isInitializing) setState(() { _downloadProgress = 0.5; });
//     });
    
//     Future.delayed(const Duration(milliseconds: 900), () {
//       if (_isInitializing) setState(() { _downloadProgress = 0.7; });
//     });
    
//     Future.delayed(const Duration(milliseconds: 1200), () {
//       if (_isInitializing) setState(() { _downloadProgress = 0.9; });
//     });
//   }

//   Future<void> _toggleListening() async {
//     try {
//       if (_isListening) {
//         await _voiceControlService.stopListening();
//         setState(() {
//           _currentSpeech = ''; // Clear partial speech when stopping
//           // Keep the last recognized text visible
//         });
//       } else {
//         await _voiceControlService.startListening(
//           onError: (error) {
//             setState(() {
//               _error = error;
//             });
//           }
//         );
//         setState(() {
//           _recognizedText = ''; // Clear recognized text when starting new session
//         });
//       }
      
//       setState(() {
//         _isListening = !_isListening;
//       });
//     } catch (e) {
//       _showSnackBar('Error: ${e.toString()}');
//     }
//   }
  
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message))
//     );
//   }

//   @override
//   void dispose() {
//     _voiceControlService.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isInitializing) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Sterowanie głosowe')),
//         body: SingleChildScrollView(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Pobieranie modelu rozpoznawania mowy...',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 const SizedBox(height: 10),
//                 Text('Model: $_modelStatus'),
//                 Text('Recognizer: $_recognizerStatus'),
//                 const SizedBox(height: 20),
//                 SizedBox(
//                   width: 200,
//                   child: LinearProgressIndicator(value: _downloadProgress),
//                 ),
//                 const SizedBox(height: 10),
//                 Text('${(_downloadProgress * 100).toInt()}%'),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
    
//     if (_error.isNotEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Sterowanie głosowe')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.error_outline, size: 64, color: Colors.red),
//               const SizedBox(height: 16),
//               const Text(
//                 'Wystąpił błąd:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 32),
//                 child: Text(_error, textAlign: TextAlign.center),
//               ),
//               Text('Model: $_modelStatus'),
//               Text('Recognizer: $_recognizerStatus'),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _initializeVoiceControl,
//                 child: const Text('Spróbuj ponownie'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sterowanie głosowe'),
//         actions: [
//           IconButton(
//             icon: Icon(_isListening ? Icons.mic : Icons.mic_off),
//             onPressed: _toggleListening,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Debug info
//             const Text(
//               'Debug Info:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Model: $_modelStatus'),
//                   Text('Recognizer: $_recognizerStatus'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
            
//             const Text(
//               'Status nasłuchiwania:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: _isListening ? Colors.green.shade100 : Colors.red.shade100,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     _isListening ? Icons.mic : Icons.mic_off,
//                     color: _isListening ? Colors.green : Colors.red,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     _isListening ? 'Nasłuchuję...' : 'Zatrzymane',
//                     style: TextStyle(
//                       color: _isListening ? Colors.green.shade700 : Colors.red.shade700,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Live speech recognition display
//             const SizedBox(height: 24),
//             const Text(
//               'Mówisz teraz: (rozpoznawanie częściowe)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue.shade200),
//               ),
//               child: Text(
//                 _currentSpeech.isEmpty ? '...' : _currentSpeech,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
            
//             // Raw partial result for debugging
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Text(
//                 'Raw partial: $_rawPartialResult',
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ),
            
//             // Final recognition result display
//             const SizedBox(height: 24),
//             const Text(
//               'Rozpoznany tekst: (wynik końcowy)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.purple.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.purple.shade200),
//               ),
//               child: Text(
//                 _recognizedText.isEmpty ? '...' : _recognizedText,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
            
//             // Raw final result for debugging
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.grey.shade300),
//               ),
//               child: Text(
//                 'Raw final: $_rawFinalResult',
//                 style: const TextStyle(fontSize: 12, color: Colors.grey),
//               ),
//             ),
            
//             const SizedBox(height: 24),
//             const Text(
//               'Ostatnie rozpoznane polecenie:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 _lastCommand.isEmpty ? 'Brak poleceń' : _lastCommand,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Dostępne polecenia:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             _buildCommandsCard(),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _toggleListening,
//         backgroundColor: _isListening ? Colors.red : Colors.green,
//         child: Icon(_isListening ? Icons.stop : Icons.mic),
//       ),
//     );
//   }
  
//   Widget _buildCommandsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             _CommandItem(command: 'start / rozpocznij', description: 'Rozpocznij działanie'),
//             SizedBox(height: 8),
//             _CommandItem(command: 'stop / zatrzymaj', description: 'Zatrzymaj działanie'),
//             SizedBox(height: 8),
//             _CommandItem(command: 'change color / zmień kolor', description: 'Zmieniam kolor'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CommandItem extends StatelessWidget {
//   final String command;
//   final String description;
  
//   const _CommandItem({
//     required this.command,
//     required this.description,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Icon(Icons.keyboard_voice, size: 16),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 command,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               Text(
//                 description,
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }