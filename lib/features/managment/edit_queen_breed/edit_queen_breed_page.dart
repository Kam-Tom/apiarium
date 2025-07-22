import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_bloc.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_event.dart';
import 'package:apiarium/features/managment/edit_queen_breed/edit_queen_breed_view.dart';
import 'package:apiarium/shared/shared.dart';

class EditQueenBreedPage extends StatelessWidget {
  final String? breedId;
  
  const EditQueenBreedPage({
    super.key,
    this.breedId,
  });

  @override
  Widget build(BuildContext context) {    return BlocProvider(
      create: (context) => EditQueenBreedBloc(
        queenService: getIt<QueenService>(),
        userRepository: getIt<UserRepository>(),
      )..add(EditQueenBreedLoadData(breedId: breedId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(breedId == null ? 'Create Queen Breed' : 'Edit Queen Breed'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.amber.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),          actions: [
            // Remove save button from app bar
          ],
        ),
        body: const EditQueenBreedView(),
      ),
    );
  }
}