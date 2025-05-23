import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/shared/services/vc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/vc_inspection_cubit.dart';
import 'dart:math' as math;

// Extension to convert int to ordinal key - same as in hive section
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
}

class VcApiarySection extends StatefulWidget {
  const VcApiarySection({super.key});

  @override
  State<VcApiarySection> createState() => _VcApiarySectionState();
}

class _VcApiarySectionState extends State<VcApiarySection> {
  late final VcInspectionCubit _vcCubit;
  late final VcService _vcService;

  @override
  void initState() {
    super.initState();
    _vcCubit = context.read<VcInspectionCubit>();
    _vcService = context.read<VcService>();
    _vcCubit.registerCommandHandler(_handleVoiceResult);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _vcService.speak('vc.select_apiary'.tr());
      }
    });
  }

  void _handleVoiceResult(String result) {
    final lowerResult = result.toLowerCase();
    final apiaries = context.read<InspectionBloc>().state.apiaries;

    // Only allow "first apiary", "second apiary", etc.
    for (int i = 1; i <= math.min(20, apiaries.length); i++) {
      final ordinalInWords = 'vc.ordinal.${i.toOrdinalKey()}'.tr().toLowerCase();
      final apiaryWord = 'vc.apiary'.tr().toLowerCase();
      if (lowerResult.contains('$ordinalInWords $apiaryWord')) {
        if (i <= apiaries.length) {
          _selectApiary(apiaries[i - 1]);
        }
        return;
      }
    }
  }

  void _selectApiary(dynamic apiary) {
    _vcService.speak('${apiary.name} ${'vc.selected'.tr()}');
    context.read<InspectionBloc>().add(SelectApiaryEvent(apiary.id));
  }

  @override
  void dispose() {
    _vcCubit.unregisterCommandHandler(_handleVoiceResult);
    super.dispose();
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InspectionBloc, InspectionState>(
      builder: (context, state) {
        return Container(
          color: Colors.red,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with description
              _buildHeader(),
              
              // Apiary List
              Expanded(
                child: ListView.builder(
                  itemCount: state.apiaries.length,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemBuilder: (context, index) {
                    final apiary = state.apiaries[index];
                    final ordinalName = (index + 1).toOrdinalValue(context);
                    final apiaryColor = apiary.color ?? Colors.grey.shade400;
          
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: apiaryColor.withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Circle with number - using apiaryColor for background with opacity
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: apiaryColor.withOpacity(0.15), // Semi-transparent color
                                    border: Border.all(
                                      color: apiaryColor, // Full color border
                                      width: 1.8,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      (index + 1).toString(),
                                      style: TextStyle(
                                        color: apiaryColor, // Use apiaryColor for number
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                
                                // Content section
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Apiary name - white text
                                      Text(
                                        apiary.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      
                                      // Info row with hive count and location side by side
                                      Row(
                                        children: [
                                          // Hive count
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.grid_view,
                                                size: 13,
                                                color: Colors.white70,
                                              ),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${apiary.hiveCount} ${apiary.hiveCount == 1 ? 'vc.hive'.tr() : 'vc.hives'.tr()}',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          // Spacer or separator
                                          if (apiary.location != null && apiary.location!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Container(
                                                height: 10,
                                                width: 1,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          
                                          // Location if available
                                          if (apiary.location != null && apiary.location!.isNotEmpty)
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 13,
                                                    color: Colors.white70,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Expanded(
                                                    child: Text(
                                                      apiary.location!,
                                                      style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 13,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Voice command at the bottom - no border
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.mic,
                                  size: 12,
                                  color: Colors.amber, // Yellow microphone
                                ),
                                const SizedBox(width: 4),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _capitalizeFirstLetter(ordinalName),
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: " ",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'vc.apiary'.tr(),
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'vc.select_apiary'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          
          // Voice command description - using tr() properly
          Row(
            children: [
              const Icon(
                Icons.mic,
                color: Colors.amber,
                size: 14,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13),
                    children: [
                      TextSpan(
                        text: "${'vc.say'.tr()} ",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      TextSpan(
                        text: _capitalizeFirstLetter('vc.ordinal.first'.tr()),
                        style: const TextStyle(color: Colors.amber),
                      ),
                      const TextSpan(
                        text: "/",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextSpan(
                        text: _capitalizeFirstLetter('vc.ordinal.second'.tr()),
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      const TextSpan(
                        text: "/... ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextSpan(
                        text: 'vc.apiary'.tr(),
                        style: const TextStyle(color: Colors.amber),
                      ),
                      TextSpan(
                        text: " ${'vc.to_select_apiary'.tr()}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade900,
          ),
        ],
      ),
    );
  }
}