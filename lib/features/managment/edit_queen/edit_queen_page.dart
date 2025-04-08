import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/edit_queen_view.dart';
import 'package:apiarium/shared/repositories/queen_breed_repository.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditQueenPage extends StatelessWidget {
  final String? queenId;
  final bool skipSaving;
  final bool hideLocation;
  
  const EditQueenPage({
    this.queenId, 
    this.skipSaving = false,
    this.hideLocation = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditQueenBloc(
        queenRepository: context.read<QueenRepository>(),
        breedRepository: context.read<QueenBreedRepository>(),
        apiaryRepository: context.read<ApiaryRepository>(),
        hiveRepository: context.read<HiveRepository>(),
        skipSaving: skipSaving,
        hideLocation: hideLocation,
      )..add(EditQueenLoadData(queenId: queenId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(queenId == null ? 'Create Queen' : 'Edit Queen'),
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
        body: const EditQueenView(),
      ),
    );
  }
}
