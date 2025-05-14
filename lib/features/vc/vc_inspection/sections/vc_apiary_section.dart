import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:apiarium/shared/services/vc_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/vc_inspection_cubit.dart';

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
    
    final positions = {
      'vc.numbers.one'.tr().toLowerCase(): 0,
      'vc.numbers.two'.tr().toLowerCase(): 1,
      'vc.numbers.three'.tr().toLowerCase(): 2,
      'vc.numbers.four'.tr().toLowerCase(): 3,
      'vc.numbers.five'.tr().toLowerCase(): 4,
      'vc.numbers.six'.tr().toLowerCase(): 5,
      'vc.numbers.seven'.tr().toLowerCase(): 6,
      'vc.numbers.eight'.tr().toLowerCase(): 7,
      'vc.numbers.nine'.tr().toLowerCase(): 8,
      'vc.numbers.ten'.tr().toLowerCase(): 9,
      'vc.numbers.eleven'.tr().toLowerCase(): 10,
      'vc.numbers.twelve'.tr().toLowerCase(): 11,
      'vc.numbers.thirteen'.tr().toLowerCase(): 12,
      'vc.numbers.fourteen'.tr().toLowerCase(): 13,
      'vc.numbers.fifteen'.tr().toLowerCase(): 14,
      'vc.numbers.sixteen'.tr().toLowerCase(): 15,
      'vc.numbers.seventeen'.tr().toLowerCase(): 16,
      'vc.numbers.eighteen'.tr().toLowerCase(): 17,
      'vc.numbers.nineteen'.tr().toLowerCase(): 18,
      'vc.numbers.twenty'.tr().toLowerCase(): 19,
      'vc.numbers.twentyone'.tr().toLowerCase(): 20,
      'vc.numbers.twentytwo'.tr().toLowerCase(): 21,
      'vc.numbers.twentythree'.tr().toLowerCase(): 22,
      'vc.numbers.twentyfour'.tr().toLowerCase(): 23,
      'vc.numbers.twentyfive'.tr().toLowerCase(): 24,
    };
    
    for (final entry in positions.entries) {
      if (lowerResult.contains(entry.key)) {
        final index = entry.value;
        if (index < apiaries.length) {
          final apiary = apiaries[index];
          _vcService.speak('${apiary.name} ${'vc.selected'.tr()}');
          context.read<InspectionBloc>().add(SelectApiaryEvent(apiary.id));
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
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "vc.select_apiary".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "vc.speak_number".tr(),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 32),
              Flexible(
                child: ListView.builder(
                  itemCount: state.apiaries.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final apiary = state.apiaries[index];
                    final position = _getPositionText(index);
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: apiary.color?.withOpacity(0.5) ?? Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2C2C2E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.mic,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        position,
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        ": ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        apiary.name,
                                        style: TextStyle(
                                          color: apiary.color ?? Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (apiary.location != null && apiary.location!.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined, 
                                          size: 14, 
                                          color: Colors.grey
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            apiary.location!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.grid_view, 
                                        size: 14, 
                                        color: Colors.grey
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${apiary.hiveCount} ${apiary.hiveCount == 1 ? 'vc.hive'.tr() : 'vc.hives'.tr()}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
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
  
  String _getPositionText(int index) {
    switch (index) {
      case 0: return "vc.numbers.one".tr();
      case 1: return "vc.numbers.two".tr();
      case 2: return "vc.numbers.three".tr();
      case 3: return "vc.numbers.four".tr();
      case 4: return "vc.numbers.five".tr();
      case 5: return "vc.numbers.six".tr();
      case 6: return "vc.numbers.seven".tr();
      case 7: return "vc.numbers.eight".tr();
      case 8: return "vc.numbers.nine".tr();
      case 9: return "vc.numbers.ten".tr();
      case 10: return "vc.numbers.eleven".tr();
      case 11: return "vc.numbers.twelve".tr();
      case 12: return "vc.numbers.thirteen".tr();
      case 13: return "vc.numbers.fourteen".tr();
      case 14: return "vc.numbers.fifteen".tr();
      case 15: return "vc.numbers.sixteen".tr();
      case 16: return "vc.numbers.seventeen".tr();
      case 17: return "vc.numbers.eighteen".tr();
      case 18: return "vc.numbers.nineteen".tr();
      case 19: return "vc.numbers.twenty".tr();
      case 20: return "vc.numbers.twentyone".tr();
      case 21: return "vc.numbers.twentytwo".tr();
      case 22: return "vc.numbers.twentythree".tr();
      case 23: return "vc.numbers.twentyfour".tr();
      case 24: return "vc.numbers.twentyfive".tr();
      default: return (index + 1).toString();
    }
  }
}