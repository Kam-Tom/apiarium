import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/edit_hive_view.dart';
import 'package:apiarium/shared/repositories/apiary_repository.dart';
import 'package:apiarium/shared/repositories/hive_repository.dart';
import 'package:apiarium/shared/repositories/queen_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditHivePage extends StatelessWidget {
  final String? hiveId;
  final bool skipSaving;
  final bool hideLocation;
  
  const EditHivePage({
    this.hiveId, 
    this.skipSaving = false,
    this.hideLocation = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditHiveBloc(
        queenRepository: context.read<QueenRepository>(),
        apiaryRepository: context.read<ApiaryRepository>(),
        hiveRepository: context.read<HiveRepository>(),
        skipSaving: skipSaving,
        hideLocation: hideLocation,
      )..add(EditHiveLoadData(hiveId: hiveId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(hiveId == null ? 'Create Hive' : 'Edit Hive'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.amber.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const EditHiveView(),
      ),
    );
  }
}
