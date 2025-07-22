// import 'package:apiarium/features/raport/inspection/inspection.dart';
// import 'package:apiarium/features/raport/harvest/harvest.dart';
// import 'package:apiarium/features/raport/treatment/treatment.dart';
// import 'package:apiarium/features/raport/feeding/feeding.dart';
// import 'package:apiarium/features/raport/raport_view.dart';
// import 'package:apiarium/shared/shared.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class RaportPage extends StatelessWidget {
//   const RaportPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => InspectionBloc(
//           apiaryService: context.read<ApiaryService>(),
//           reportService: context.read<ReportService>(),
//         )..add(LoadApiariesEvent())),
//         BlocProvider(create: (context) => HarvestBloc(
//           // apiaryRepository: context.read<ApiaryRepository>(),
//           // harvestRepository: context.read<HarvestRepository>(),
//         )),
//         BlocProvider(create: (context) => TreatmentBloc(
//           // apiaryRepository: context.read<ApiaryRepository>(),
//           // treatmentRepository: context.read<TreatmentRepository>(),
//         )),
//         BlocProvider(create: (context) => FeedingBloc(
//           // apiaryRepository: context.read<ApiaryRepository>(),
//           // feedingRepository: context.read<FeedingRepository>(),
//         )),
//       ],
//       child: const RaportView(),
//     );
//   }
// }
