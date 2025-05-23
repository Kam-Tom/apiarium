import 'package:apiarium/features/raport/inspection/inspection.dart';
import 'package:apiarium/features/vc/vc_inspection/cubit/vc_inspection_cubit.dart';
import 'package:apiarium/features/vc/vc_inspection/sections/vc_apiary_section.dart';
import 'package:apiarium/features/vc/vc_inspection/sections/vc_form_section.dart';
import 'package:apiarium/features/vc/vc_inspection/sections/vc_hive_section.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VcInspectionView extends StatefulWidget {
  const VcInspectionView({super.key});

  @override
  State<VcInspectionView> createState() => _VcInspectionViewState();
}

class _VcInspectionViewState extends State<VcInspectionView> {
  late final VcInspectionCubit _vcCubit;

  @override
  void initState() {
    super.initState();
    _vcCubit = context.read<VcInspectionCubit>();
    _vcCubit.registerCommandHandler(_handleVoiceResult);
  }

  void _handleVoiceResult(String result) {

    Fluttertoast.cancel();

    Fluttertoast.showToast(
      msg: "Voice: $result",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.blue.withOpacity(0.8),
      textColor: Colors.white,
      fontSize: 16.0
    );

    if(result == 'vc.commands.back'.tr()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if(context.mounted) {
          Navigator.of(context).pop();
        }
      });

    }
  }
  
  @override
  void dispose() {
    _vcCubit.unregisterCommandHandler(_handleVoiceResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: BlocBuilder<InspectionBloc, InspectionState>(
        builder: (context, state) {
          if (state.selectedApiaryId != null && state.selectedApiary != null) {
            if (state.selectedHiveId != null && state.selectedHive != null) {
              // Simpler approach - let VcHiveSection take only what it needs
              return Column(
                children: [
                  // VcHiveSection will size itself based on its content
                  const VcHiveSection(),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade900),
                  // VcFormSection gets all remaining space
                  const Expanded(child: VcFormSection()),
                ],
              );
            } else {
              return const VcHiveSection();
            }
          } else if (state.apiaries.isNotEmpty) {
            return const VcApiarySection();
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }
        },
      ),
    );
  }
}

