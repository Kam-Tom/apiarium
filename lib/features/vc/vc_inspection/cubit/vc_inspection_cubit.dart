// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import '../../../../shared/services/services.dart';

// // Define the states
// enum VcInspectionStatus { initializing, ready, error }

// class VcInspectionState {
//   final VcInspectionStatus status;
//   final String statusMessage;

//   VcInspectionState({
//     this.status = VcInspectionStatus.initializing,
//     this.statusMessage = '',
//   });

//   VcInspectionState copyWith({
//     VcInspectionStatus? status,
//     String? statusMessage,
//   }) {
//     return VcInspectionState(
//       status: status ?? this.status,
//       statusMessage: statusMessage ?? this.statusMessage,
//     );
//   }
// }

// typedef VoiceCommandHandler = void Function(String command);

// class VcInspectionCubit extends Cubit<VcInspectionState> {
//   final VcService vcService;
//   final BuildContext context;
  
//   final List<VoiceCommandHandler> _commandHandlers = [];

//   VcInspectionCubit({required this.vcService, required this.context}) 
//       : super(VcInspectionState(statusMessage: 'vc.initializing'.tr())) {
//     _initialize();
//   }

//   Future<void> _initialize() async {
//     try {
//       final success = await vcService.initialize(
//         onModelStatusChange: (status) {
//           emit(state.copyWith(statusMessage: status));
//         },
//       );

//       if (success) {
//         vcService.setResultHandler(_masterResultHandler);
//         vcService.startListening();
//         emit(state.copyWith(
//           status: VcInspectionStatus.ready,
//         ));
//       } else {
//         emit(state.copyWith(
//           status: VcInspectionStatus.error,
//           statusMessage: 'vc.init_failed'.tr(),
//         ));
//       }
//     } catch (e) {
//       emit(state.copyWith(
//         status: VcInspectionStatus.error,
//         statusMessage: 'Error: $e',
//       ));
//     }
//   }

//   void _masterResultHandler(String result) {
  
//     for (var handler in _commandHandlers) {
//       handler(result);
//     }
//   }

//   // Register a new command handler
//   void registerCommandHandler(VoiceCommandHandler handler) {
//     if (!_commandHandlers.contains(handler)) {
//       _commandHandlers.add(handler);
//     }
//   }

//   // Unregister a command handler
//   void unregisterCommandHandler(VoiceCommandHandler handler) {
//     _commandHandlers.remove(handler);
//   }

//   void retry() {
//     emit(state.copyWith(
//       status: VcInspectionStatus.initializing, 
//       statusMessage: 'vc.initializing'.tr()
//     ));
//     _initialize();
//   }

//   @override
//   Future<void> close() {
//     vcService.stopListening();
//     vcService.removeResultHandler();
//     vcService.dispose();
//     return super.close();
//   }
// }
