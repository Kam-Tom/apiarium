import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../features/raport/inspection/bloc/inspection_bloc.dart';
import '../../../shared/services/services.dart';
import 'cubit/vc_inspection_cubit.dart';
import 'vc_inspection_view.dart';
import 'widgets/vc_initializing_screen.dart';
import 'widgets/vc_error_screen.dart';

class VcInspectionPage extends StatelessWidget {
  const VcInspectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => VcInspectionCubit(
            vcService: context.read<VcService>(),
            context: context,
          ),
        ),
        BlocProvider(
          create: (context) => InspectionBloc(
            apiaryService: context.read<ApiaryService>(),
            reportService: context.read<ReportService>(),
          )..add(const LoadApiariesEvent(autoSelectApiary: false)),
        ),
      ],
      child: BlocBuilder<VcInspectionCubit, VcInspectionState>(
        builder: (context, state) {
          if (state.status == VcInspectionStatus.initializing) {
            return VcInitializingScreen(statusMessage: state.statusMessage);
          }

          if (state.status == VcInspectionStatus.error) {
            return VcErrorScreen(
              errorMessage: state.statusMessage,
              onRetry: () => context.read<VcInspectionCubit>().retry(),
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Row(
                children: [
                  const Text('vc.commands.back', style: TextStyle(color: Colors.white)).tr(),
                  const SizedBox(width: 8),
                  const Icon(Icons.mic, color: Colors.blue, size: 16),
                ],
              ),
            ),
            body: VcInspectionView(),
          );
        },
      ),
    );
  }
}
