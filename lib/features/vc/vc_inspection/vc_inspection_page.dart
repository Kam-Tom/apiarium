import 'package:apiarium/shared/utils/language_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/raport/inspection/bloc/inspection_bloc.dart';
import '../../../shared/services/services.dart';
import '../../../shared/utils/shared_prefs_helper.dart';
import 'vc_inspection_view.dart';

class VcInspectionPage extends StatefulWidget {
  const VcInspectionPage({super.key});

  @override
  State<VcInspectionPage> createState() => _VcInspectionPageState();
}

class _VcInspectionPageState extends State<VcInspectionPage> {
  bool _isInitializing = true;
  String _initStatus = 'Initializing voice control...';
  bool _initError = false;
  late final VcService _vcService;
  
  @override
  void initState() {
    super.initState();
    _initializeVoiceControl();
    _vcService = context.read<VcService>();
  }
  
  @override
  void dispose() {
    _vcService.stopListening();
    _vcService.dispose();
    super.dispose();
  }
  
  Future<void> _initializeVoiceControl() async {
    final vcService = context.read<VcService>();
    
    try {
      // Initialize the voice control service with simpler approach
      final success = await vcService.initialize(
        onModelStatusChange: (status) {
          setState(() {
            _initStatus = status;
          });
        },
      );
      
      if (success) {
        vcService.startListening();
        setState(() {
          _isInitializing = false;
        });
      } else {
        setState(() {
          _isInitializing = false;
          _initError = true;
          _initStatus = 'Failed to initialize voice control. Please select a model in Voice Control settings.';
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _initError = true;
        _initStatus = 'Error: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Voice Inspection'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(_initStatus),
            ],
          ),
        ),
      );
    }
    
    if (_initError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Voice Inspection'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _initStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = false;
                    _initStatus = 'Initializing voice control...';
                  });
                  _initializeVoiceControl();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    
    return BlocProvider(
      create: (context) => InspectionBloc(
        apiaryService: context.read<ApiaryService>(),
        reportService: context.read<ReportService>(),
      )..add(LoadApiariesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Voice Inspection'),
        ),
        body: VcInspectionView(vcService: _vcService),
      ),
    );
  }
}
