// import 'package:apiarium/features/raport/inspection/inspection.dart';
// import 'package:apiarium/features/raport/harvest/harvest.dart';
// import 'package:apiarium/features/raport/treatment/treatment.dart';
// import 'package:apiarium/features/raport/feeding/feeding.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class RaportView extends StatefulWidget {
//   const RaportView({super.key});

//   @override
//   State<RaportView> createState() => _RaportViewState();
// }

// class _RaportViewState extends State<RaportView>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Hive Reports'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.amber.shade800, Colors.amber.shade500],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         bottom: TabBar(
//           controller: _tabController,
//           isScrollable: true,
//           indicatorColor: Colors.white,
//           indicatorWeight: 3,
//           labelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           unselectedLabelStyle: const TextStyle(
//             fontWeight: FontWeight.normal,
//           ),
//           tabs: const [
//             Tab(text: 'Inspection'),
//             Tab(text: 'Harvest'),
//             Tab(text: 'Treatment'),
//             Tab(text: 'Feeding'),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if(_tabController.index == 0) {
//             context.read<InspectionBloc>().add(SaveInspectionReport());
//             //ScaffoldMessenger.of(context).showSnackBar(
//             // const SnackBar(
//             //   content: Text('Send report functionality coming soon'),
//             // ));
//           } else if(_tabController.index == 1) {
//             //context.read<HarvestBloc>().add(SendHarvestReport());
//           } else if(_tabController.index == 2) {
//             //context.read<TreatmentBloc>().add(SendTreatmentReport());
//           } else if(_tabController.index == 3) {
//             //context.read<FeedingBloc>().add(SendFeedingReport());
//           }
//         },
//         backgroundColor: Colors.amber.shade700,
//         child: const Icon(Icons.send, color: Colors.white),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           InspectionPage(),
//           HarvestPage(),
//           TreatmentPage(),
//           FeedingPage(),
//         ],
//       ),
//     );
//   }
// }
