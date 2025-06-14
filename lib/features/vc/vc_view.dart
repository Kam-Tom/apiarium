// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'bloc/vc_bloc.dart';
// import '../../shared/utils/language_models.dart';

// class VCView extends StatelessWidget {
//   const VCView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<VcBloc, VcState>(
//       listenWhen: (previous, current) => previous.status != current.status,
//       listener: (context, state) {
//         if (state.status == VcModelStatus.ready && state.wasDownloading) {
//           // Navigate to inspection page when download completes
//           Future.delayed(const Duration(seconds: 1), () {
//             if(context.mounted) {
//               context.go('/vc-inspection');
//             }
//           });
//         }
//       },
//       builder: (context, state) {
//         switch (state.status) {
//           case VcModelStatus.initial:
//           case VcModelStatus.checking:
//             return const Center(child: CircularProgressIndicator());
            
//           case VcModelStatus.notSet:
//           case VcModelStatus.downloading:
//             return _buildModelSelectionView(context, state);
            
//           case VcModelStatus.ready:
//             // Just show loading until navigation completes
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Preparing voice control...'),
//                 ],
//               ),
//             );
            
//           case VcModelStatus.error:
//             return _buildErrorView(context, state.errorMessage);
            
//           case VcModelStatus.disposed:
//             // TODO: Handle this case.
//             throw UnimplementedError();
//         }
//       },
//     );
//   }

//   Widget _buildModelSelectionView(BuildContext context, VcState state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Text(
//             'Voice Control Setup',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         const Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'Please download a language model to use voice control.',
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//         const SizedBox(height: 24),
//         Expanded(
//           child: _buildModelList(context, state),
//         ),
//         if (state.status == VcModelStatus.downloading)
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(state.downloadStatus ?? 'Downloading...'),
//                 const SizedBox(height: 8),
//                 const LinearProgressIndicator(),
//               ],
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildErrorView(BuildContext context, String? errorMessage) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 48, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             'Error: ${errorMessage ?? "Unknown error"}',
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             onPressed: () {
//               context.read<VcBloc>().add(CheckVcModelStatus());
//             },
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModelList(BuildContext context, VcState state) {
//     final models = langaugeModels();
//     final userLanguage = state.currentLanguage;
    
//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       itemCount: models.length,
//       itemBuilder: (context, index) {
//         final model = models[index];
//         final bool isCurrentLanguage = 
//             model['language']?.substring(0, 2) == userLanguage;
//         final bool isDownloadingThisModel = 
//             state.status == VcModelStatus.downloading && 
//             state.selectedModel?['id'] == model['id'];
        
//         // Determine if this language is compatible with UI
//         final bool isCompatibleWithUI = isCurrentLanguage;
        
//         return _buildModelCard(
//           context, 
//           model, 
//           isCurrentLanguage, 
//           isCompatibleWithUI,
//           isDownloadingThisModel,
//           userLanguage,
//           state.status == VcModelStatus.downloading
//         );
//       },
//     );
//   }

//   Widget _buildModelCard(
//     BuildContext context, 
//     Map<String, String> model, 
//     bool isCurrentLanguage, 
//     bool isCompatibleWithUI,
//     bool isDownloadingThisModel,
//     String userLanguage,
//     bool isAnyModelDownloading
//   ) {
//     return Card(
//       elevation: isCurrentLanguage ? 3 : 1,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//         side: isCurrentLanguage 
//             ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
//             : BorderSide.none,
//       ),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: Text(
//           model['flag'] ?? '🌐',
//           style: TextStyle(
//             fontSize: 32,
//             color: isCompatibleWithUI ? null : Colors.grey,
//           ),
//         ),
//         title: Text(
//           model['name'] ?? 'Unknown',
//           style: TextStyle(
//             fontWeight: isCurrentLanguage ? FontWeight.bold : FontWeight.normal,
//             fontSize: 16,
//             color: isCompatibleWithUI ? null : Colors.grey,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               'Size: ${model['size'] ?? 'Unknown'}',
//               style: TextStyle(
//                 color: isCompatibleWithUI ? null : Colors.grey,
//               ),
//             ),
//             if (isCurrentLanguage) 
//               Text(
//                 'Matches UI language',
//                 style: TextStyle(
//                   color: Theme.of(context).primaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             if (!isCompatibleWithUI) 
//               Text(
//                 'UI language is ${_getLanguageName(userLanguage)}',
//                 style: const TextStyle(
//                   color: Colors.grey,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//           ],
//         ),
//         trailing: isDownloadingThisModel 
//             ? const SizedBox(
//                 width: 24, 
//                 height: 24, 
//                 child: CircularProgressIndicator()
//               ) 
//             : ElevatedButton(
//                 onPressed: isAnyModelDownloading 
//                     ? null
//                     : () => _downloadModel(context, model),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isCompatibleWithUI ? null : Colors.grey[200],
//                 ),
//                 child: Text(
//                   'Download',
//                   style: TextStyle(
//                     color: isCompatibleWithUI ? null : Colors.grey,
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
  
//   String _getLanguageName(String languageCode) {
//     switch (languageCode) {
//       case 'en': return 'English';
//       case 'pl': return 'Polish';
//       case 'fr': return 'French';
//       case 'de': return 'German';
//       default: return languageCode;
//     }
//   }

//   void _downloadModel(BuildContext context, Map<String, String> model) {
//     context.read<VcBloc>().add(DownloadVcModel(modelInfo: model));
//   }
// }
