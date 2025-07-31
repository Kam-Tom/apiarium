// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'add_spending_dialog_cubit.dart';

// class AddSpendingDialogView extends StatelessWidget {
//   final bool showUnitPrice;
//   final bool showNotes;
//   final bool showAttachments;
//   final String? initialApiaryId;
//   final String? initialApiaryName;
//   final String type;

//   const AddSpendingDialogView({
//     super.key,
//     this.showUnitPrice = false,
//     this.showNotes = false,
//     this.showAttachments = false,
//     this.initialApiaryId,
//     this.initialApiaryName,
//     this.type = 'expense',
//   });

//   Future<void> _pickImage(BuildContext context, AddSpendingDialogCubit cubit, List<String>? currentAttachments) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       final updated = [...?currentAttachments, pickedFile.path];
//       cubit.updateField('attachments', updated);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => AddSpendingDialogCubit(
//         initial: AddSpendingDialogState(
//           apiaryId: initialApiaryId,
//           apiaryName: initialApiaryName,
//           type: type,
//         ),
//       ),
//       child: BlocBuilder<AddSpendingDialogCubit, AddSpendingDialogState>(
//         builder: (context, state) {
//           final cubit = context.read<AddSpendingDialogCubit>();
//           return AlertDialog(
//             title: Text('${'spending.add_title'.tr()} $type'),
//             content: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   if (showUnitPrice)
//                     TextField(
//                       decoration: InputDecoration(labelText: 'spending.unit_price'.tr()),
//                       keyboardType: TextInputType.number,
//                       onChanged: (v) => cubit.updateField('unitPrice', double.tryParse(v)),
//                     ),
//                   if (showNotes)
//                     TextField(
//                       decoration: InputDecoration(labelText: 'spending.notes'.tr()),
//                       onChanged: (v) => cubit.updateField('notes', v),
//                     ),
//                   if (showAttachments)
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () => _pickImage(context, cubit, state.attachments),
//                           child: Text('spending.add_attachment'.tr()),
//                         ),
//                         if (state.attachments != null && state.attachments!.isNotEmpty)
//                           Wrap(
//                             spacing: 8,
//                             children: state.attachments!
//                               .map((path) => Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: SizedBox(
//                                   width: 60,
//                                   height: 60,
//                                   child: Image.file(File(path), fit: BoxFit.cover),
//                                 ),
//                               ))
//                               .toList(),
//                           ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('common.no'.tr()),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // TODO: Validate and save using StorageService
//                   Navigator.pop(context);
//                 },
//                 child: Text('common.save'.tr()),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
