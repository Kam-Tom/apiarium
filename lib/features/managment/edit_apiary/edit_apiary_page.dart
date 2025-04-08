import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/edit_apiary_view.dart';
import 'package:apiarium/shared/repositories/apiary_repository.dart';
import 'package:apiarium/shared/repositories/hive_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditApiaryPage extends StatelessWidget {
  final String? apiaryId;
  
  const EditApiaryPage({this.apiaryId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditApiaryBloc(
        apiaryRepository: context.read<ApiaryRepository>(),
        hiveRepository: context.read<HiveRepository>(),
      )..add(EditApiaryLoadData(apiaryId: apiaryId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Apiary'),
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
        body: const EditApiaryView(),
      ),
    );
  }
}
