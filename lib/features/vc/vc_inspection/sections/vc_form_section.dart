import 'package:apiarium/shared/services/vc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../cubit/vc_inspection_cubit.dart';

class VcFormSection extends StatefulWidget {
  const VcFormSection({super.key});

  @override
  State<VcFormSection> createState() => _VcFormSectionState();
}

class _VcFormSectionState extends State<VcFormSection> {
  int _currentIndex = 0;
  late final VcInspectionCubit _vcCubit;
  late final VcService _vcService;
  
  final List<Map<String, dynamic>> _formInputs = [
    {
      'type': 'boolean',
      'label': 'Queen spotted',
      'icon': Icons.emoji_nature,
      'value': true,
      'style': 'yesno',
    },
    {
      'type': 'boolean',
      'label': 'Honey stores present',
      'icon': Icons.local_drink_outlined, 
      'value': false,
      'style': 'truefalse',
    },
    {
      'type': 'scale',
      'label': 'Colony strength',
      'icon': Icons.group_outlined,
      'value': 3,
      'maxValue': 5,
      'labels': ['Very weak', 'Weak', 'Average', 'Strong', 'Very strong'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _vcCubit = context.read<VcInspectionCubit>();
    _vcService = context.read<VcService>();
    _vcCubit.registerCommandHandler(_handleVoiceResult);
  }

  @override
  void dispose() {
    _vcCubit.unregisterCommandHandler(_handleVoiceResult);
    super.dispose();
  }

  void _handleVoiceResult(String result) {
    final lowerResult = result.toLowerCase();
    
    // Handle navigation commands
    if (lowerResult.contains('vc.form.next'.tr().toLowerCase()) || 
        lowerResult.contains('następny') || 
        lowerResult.contains('dalej')) {
      _navigateNext();
      return;
    }
    
    if (lowerResult.contains('vc.form.previous'.tr().toLowerCase()) || 
        lowerResult.contains('poprzedni') || 
        lowerResult.contains('wstecz')) {
      _navigatePrevious();
      return;
    }
    
    if (lowerResult.contains('vc.form.finish'.tr().toLowerCase()) || 
        lowerResult.contains('zakończ') || 
        lowerResult.contains('koniec')) {
      _vcService.speak('vc.form.form_completed'.tr());
      return;
    }
    
    // Handle input-specific commands for current input
    final currentInput = _formInputs[_currentIndex];
    if (currentInput['type'] == 'boolean') {
      _handleBooleanCommands(lowerResult, currentInput);
    } else if (currentInput['type'] == 'scale') {
      _handleScaleCommands(lowerResult, currentInput);
    }
  }

  void _navigateNext() {
    if (_currentIndex < _formInputs.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _announceCurrentInput();
    } else {
      _vcService.speak('vc.form.last_input'.tr());
    }
  }

  void _navigatePrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _announceCurrentInput();
    } else {
      _vcService.speak('vc.form.first_input'.tr());
    }
  }

  void _announceCurrentInput() {
    final currentInput = _formInputs[_currentIndex];
    _vcService.speak(currentInput['label']);
  }

  void _handleBooleanCommands(String result, Map<String, dynamic> input) {
    final style = input['style'];
    
    if (style == 'yesno') {
      if (result.contains('vc.form.yes'.tr().toLowerCase()) || result.contains('tak')) {
        setState(() {
          input['value'] = true;
        });
        _vcService.speak('vc.form.yes_selected'.tr());
      } else if (result.contains('vc.form.no'.tr().toLowerCase()) || result.contains('nie')) {
        setState(() {
          input['value'] = false;
        });
        _vcService.speak('vc.form.no_selected'.tr());
      }
    } else if (style == 'truefalse') {
      if (result.contains('vc.form.true'.tr().toLowerCase()) || result.contains('prawda')) {
        setState(() {
          input['value'] = true;
        });
        _vcService.speak('vc.form.true_selected'.tr());
      } else if (result.contains('vc.form.false'.tr().toLowerCase()) || result.contains('fałsz')) {
        setState(() {
          input['value'] = false;
        });
        _vcService.speak('vc.form.false_selected'.tr());
      }
    }
    
    if (result.contains('vc.form.skip'.tr().toLowerCase()) || result.contains('pomiń')) {
      _vcService.speak('vc.form.skipped'.tr());
      _navigateNext();
    }
  }

  void _handleScaleCommands(String result, Map<String, dynamic> input) {
    // Handle scale values 1-5
    for (int i = 1; i <= 5; i++) {
      if (result.contains(i.toString()) || 
          result.contains('${'vc.form.strength'.tr()} $i'.toLowerCase()) ||
          result.contains('siła $i')) {
        setState(() {
          input['value'] = i;
        });
        final labels = input['labels'] as List<String>;
        _vcService.speak('${labels[i-1]} ${'vc.form.selected'.tr()}');
        return;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(child: _buildCompactInputDisplay()),
          _buildCompactFooter(),
        ],
      ),
    );
  }
  
  Widget _buildCompactInputDisplay() {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth * 0.8;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous input - can overflow top
        if (_currentIndex > 0)
          Opacity(
            opacity: 0.4,
            child: Transform.scale(
              scale: 0.85,
              child: Container(
                width: itemWidth,
                margin: const EdgeInsets.only(bottom: 20),
                child: _buildInputWidget(_formInputs[_currentIndex - 1], itemWidth: itemWidth),
              ),
            ),
          ),
        
        // Current input - always visible and centered
        Container(
          width: itemWidth,
          child: _buildInputWidget(_formInputs[_currentIndex], itemWidth: itemWidth),
        ),
        
        // Next input - can overflow bottom
        if (_currentIndex < _formInputs.length - 1)
          Opacity(
            opacity: 0.4,
            child: Transform.scale(
              scale: 0.85,
              child: Container(
                width: itemWidth,
                margin: const EdgeInsets.only(top: 20),
                child: _buildInputWidget(_formInputs[_currentIndex + 1], itemWidth: itemWidth),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompactFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.grey.shade900)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic, size: 12, color: Colors.amber),
          const SizedBox(width: 6),
          _buildCommandText('vc.form.next'.tr()),
          Text(" / ", style: TextStyle(color: Colors.white.withOpacity(0.6))),
          _buildCommandText('vc.form.previous'.tr()),
          Text(" / ", style: TextStyle(color: Colors.white.withOpacity(0.6))),
          _buildCommandText('vc.form.finish'.tr()),
        ],
      ),
    );
  }

  Widget _buildCommandText(String command) {
    return Text(
      command,
      style: const TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
    );
  }

  // Helper to render the correct input widget based on type
  Widget _buildInputWidget(Map<String, dynamic> inputData, {double? itemWidth}) {
    switch(inputData['type']) {
      case 'boolean':
        return _buildSimpleBooleanCard(
          label: inputData['label'],
          icon: inputData['icon'],
          value: inputData['value'],
          style: inputData['style'],
          width: itemWidth,
        );
      case 'scale':
        return _buildSimpleScaleCard(
          label: inputData['label'],
          icon: inputData['icon'],
          value: inputData['value'],
          labels: inputData['labels'],
          width: itemWidth,
        );
      default:
        return Container(); // Empty fallback
    }
  }

  Widget _buildSimpleBooleanCard({
    required String label,
    required IconData icon,
    required bool value,
    required String style,
    double? width,
  }) {
    final String trueText = style == "truefalse" ? "True" : "Yes";
    final String falseText = style == "truefalse" ? "False" : "No";
    final Color statusColor = value ? Colors.green : Colors.red.shade400;

    return Container(
      width: width,
      // Remove fixed height and let it size naturally
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Slightly reduced padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // Important: use minimum size
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    value ? trueText : falseText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16), // Fixed spacing instead of Spacer
            
            // Command options in a row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCompactCommand(
                  label: trueText, 
                  command: style == "truefalse" ? "true" : "yes",
                  isActive: value,
                  color: statusColor
                ),
                const SizedBox(width: 24),
                
                _buildCompactCommand(
                  label: falseText, 
                  command: style == "truefalse" ? "false" : "no",
                  isActive: !value,
                  color: statusColor
                ),
                const SizedBox(width: 24),
                
                _buildCompactCommand(
                  label: "Skip", 
                  command: "skip",
                  isActive: false,
                  color: Colors.grey
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCommand({
    required String label,
    required String command,
    required bool isActive,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.white54,
            fontSize: 15,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mic, size: 12, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              command,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSimpleScaleCard({
    required String label,
    required IconData icon,
    required int value,
    required List<String> labels,
    double? width,
  }) {
    final List<Color> scaleColors = [
      Colors.red.shade400,
      Colors.orange.shade300,
      Colors.amber,
      Colors.lightGreen.shade400,
      Colors.green.shade500,
    ];
    
    final Color valueColor = value <= scaleColors.length && value > 0
        ? scaleColors[value - 1] 
        : scaleColors.length > 2 ? scaleColors[2] : Colors.amber;

    return Container(
      width: width,
      // Remove fixed height
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12.0), // Slightly reduced padding
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use minimum vertical space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      labels[value - 1],
                      style: TextStyle(
                        color: valueColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16), // Fixed spacing instead of Spacer
          
          // Scale visualization - more compact
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final isSelected = index + 1 == value;
              final dotColor = scaleColors[index];
              
              return Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isSelected ? 16 : 12, // Smaller dots
                      height: isSelected ? 16 : 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? dotColor.withOpacity(0.3) : Colors.grey.shade800.withOpacity(0.5),
                        border: Border.all(
                          color: isSelected ? dotColor : Colors.grey.shade700,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: isSelected ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                          ),
                        ),
                      ) : null,
                    ),
                    if (index < 4)
                      Container(
                        width: 10,
                        height: 2,
                        color: index < value - 1 ? dotColor.withOpacity(0.5) : Colors.grey.shade800,
                      ),
                  ],
                ),
              );
            }),
          ),
          
          const SizedBox(height: 12), // Reduced spacing
          
          // Command hint
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.mic, size: 12, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  "strength 1-5",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}