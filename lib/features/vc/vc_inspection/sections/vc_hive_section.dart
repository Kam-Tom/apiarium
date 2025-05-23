import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/shared/domain/models/apiary.dart';
import 'package:apiarium/shared/domain/models/hive.dart';
import 'package:apiarium/shared/services/vc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/vc_inspection_cubit.dart';
import 'dart:math' as math;

// Update the extension to use Easy Localization properly for both genders
extension IntToOrdinalExtension on int {
  String toOrdinalKey() {
    switch(this) {
      case 1: return 'first';
      case 2: return 'second';
      case 3: return 'third';
      case 4: return 'fourth';
      case 5: return 'fifth';
      case 6: return 'sixth';
      case 7: return 'seventh';
      case 8: return 'eighth';
      case 9: return 'ninth';
      case 10: return 'tenth';
      case 11: return 'eleventh';
      case 12: return 'twelfth';
      case 13: return 'thirteenth';
      case 14: return 'fourteenth';
      case 15: return 'fifteenth';
      case 16: return 'sixteenth';
      case 17: return 'seventeenth';
      case 18: return 'eighteenth';
      case 19: return 'nineteenth';
      case 20: return 'twentieth';
      default: return this.toString();
    }
  }
  
  String toOrdinalValue(BuildContext context) {
    return 'vc.ordinal.${this.toOrdinalKey()}'.tr();
  }
  
  // Add a method for hive-specific ordinals that use the correct gender form
  String toHiveOrdinalValue(BuildContext context) {
    return 'vc.ordinal_hive.${this.toOrdinalKey()}'.tr();
  }
}

class VcHiveSection extends StatefulWidget {
  const VcHiveSection({super.key});

  @override
  State<VcHiveSection> createState() => _VcHiveSectionState();
}

class _VcHiveSectionState extends State<VcHiveSection> {
  late final VcInspectionCubit _vcCubit;
  late final VcService _vcService;

  @override
  void initState() {
    super.initState();

    _vcCubit = context.read<VcInspectionCubit>();
    _vcService = context.read<VcService>();

    _vcCubit.registerCommandHandler(_handleVoiceResult);
  }
  
  void _handleVoiceResult(String result) {
    final lowerResult = result.toLowerCase();
    
    if (lowerResult.contains('vc.change_apiary'.tr().toLowerCase()) || 
        lowerResult.contains('vc.select_apiary'.tr().toLowerCase())) {
      _vcService.speak('vc.returning_to_apiary_selection'.tr());
      context.read<InspectionBloc>().add(const ResetApiaryEvent());
      return;
    }

    if (lowerResult.contains('vc.select_hive'.tr().toLowerCase())) {
      _vcService.speak('vc.returning_to_hive_selection'.tr());
      context.read<InspectionBloc>().add(const ResetHiveEvent());
      return;
    }

    // Handle hive selection by ordinal only
    final apiary = context.read<InspectionBloc>().state.selectedApiary;
    if (apiary != null && apiary.hives != null) {
      for (int i = 1; i <= math.min(20, apiary.hives!.length); i++) {
        // Simply use the translation key for hive ordinals
        final ordinalInWords = 'vc.ordinal_hive.${i.toOrdinalKey()}'.tr().toLowerCase();
        final hiveWord = 'vc.hive'.tr().toLowerCase();
        
        if (lowerResult.contains('$ordinalInWords $hiveWord')) {
          if (i <= apiary.hives!.length) {
            final targetHive = apiary.hives![i-1];
            context.read<InspectionBloc>().add(SelectHiveEvent(targetHive.id));
            
            // Use ordinal in the confirmation message
            final ordinal = i.toOrdinalValue(context);
            _vcService.speak('vc.select_ordinal_hive'.tr(args: [ordinal]));
          }
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    _vcCubit.unregisterCommandHandler(_handleVoiceResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspectionBloc, InspectionState>(
      builder: (context, state) {
        final Apiary? apiary = state.selectedApiary;
        final Hive? selectedHive = state.selectedHive;
        
        if (apiary == null) {
          return const Center(
            child: Text(
              "No apiary selected",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        
        return SingleChildScrollView(
          // Use SingleChildScrollView to prevent overflow
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important: don't expand unnecessarily
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple header row with all apiary info
              _buildApiaryRow(apiary),
              
              // Simplified hive selection with ordinal commands - fix the string construction
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Voice indicator icon for hive number command
                    const Icon(
                      Icons.mic,
                      color: Colors.amber,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    
                    // Show ordinal command as the main command - fix the formatting
                    Text(
                      "${_capitalizeFirstLetter((1).toHiveOrdinalValue(context))} ${'vc.hive'.tr()}",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    
                    // To fast select hint - fix the args formatting
                    Text(
                      // Use direct hive ordinal value instead of args
                      "${'vc.to_select'.tr()} ${(1).toHiveOrdinalValue(context).toLowerCase()} ${'vc.hive'.tr()}",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Row of hive indicators with status colors
              if (apiary.hives != null && apiary.hives!.isNotEmpty)
                Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: apiary.hives!.length,
                    itemBuilder: (context, index) {
                      final hive = apiary.hives![index];
                      final isSelected = selectedHive?.id == hive.id;
                      
                      // Simulate different states - you can replace with actual logic
                      final bool isInspected = index % 3 == 0; // Just for demo
                      
                      // Use hive color if available, otherwise use default colors
                      Color borderColor;
                      Color fillColor;
                      Color textColor;
                      
                      if (isInspected) {
                        borderColor = Colors.green;
                        fillColor = Colors.green.withOpacity(0.2);
                        textColor = Colors.green.shade300;
                      } else if (isSelected) {
                        borderColor = Colors.amber;
                        fillColor = hive.color != null 
                            ? hive.color!.withOpacity(0.15)
                            : Colors.amber.withOpacity(0.2);
                        textColor = hive.color != null ? hive.color! : Colors.amber;
                      } else {
                        borderColor = hive.color != null 
                            ? hive.color!.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3);
                        fillColor = hive.color != null 
                            ? hive.color!.withOpacity(0.1)
                            : Colors.black26;
                        textColor = hive.color != null ? hive.color! : Colors.white70;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 40,
                        height: 48,
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              // Inline selected hive details
              if (selectedHive != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  color: Colors.black26,
                  child: Row(
                    children: [
                      // Hive number indicator - using hive color
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: selectedHive.color != null 
                              ? selectedHive.color!.withOpacity(0.15)
                              : Colors.black45,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedHive.color != null 
                                ? selectedHive.color!.withOpacity(0.7)
                                : Colors.amber.withOpacity(0.5), 
                            width: 1
                          ),
                        ),
                        child: Center(
                          child: Text(
                            (apiary.hives!.indexWhere((h) => h.id == selectedHive.id) + 1).toString(),
                            style: TextStyle(
                              color: selectedHive.color ?? Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Hive name and details - using standard white text color
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedHive.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            // Show hive details (optional)
                            if (selectedHive.status != null)
                              Text(
                                selectedHive.status.name,
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Queen info with proper bee icon
                      if (selectedHive.queen != null) ...[
                        // Queen marking indicator
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: selectedHive.queen!.marked 
                                ? (selectedHive.queen!.markColor ?? Colors.grey.shade400) 
                                : Colors.grey.shade700.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade500, 
                              width: 0.5,
                            ),
                          ),
                          child: selectedHive.queen!.marked 
                              ? null 
                              : const Center(
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                        // Use a built-in icon that resembles a bee/insect
                        Icon(
                          Icons.emoji_nature, // Butterfly icon that looks like insect/nature
                          size: 16, 
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedHive.queen!.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildApiaryRow(Apiary apiary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.black87, width: 1)),
      ),
      child: Row(
        children: [
          // Voice indicator icon
          const Icon(
            Icons.mic,
            color: Colors.amber,
            size: 12,
          ),
          const SizedBox(width: 6),
          
          // "Change Apiary" text in amber
          Text(
            "vc.change_apiary".tr(),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              height: 14,
              width: 1,
              color: Colors.grey.shade700,
            ),
          ),
          
          // Apiary name
          Expanded(
            child: Text(
              apiary.name,
              style: TextStyle(
                color: apiary.color ?? Colors.white,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Hive count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "${apiary.hiveCount} ${apiary.hiveCount == 1 ? 'vc.hive'.tr() : 'vc.hives'.tr()}",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Capitalize first letter helper
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
