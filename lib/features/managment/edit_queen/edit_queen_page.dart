import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/edit_queen_view.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditQueenPage extends StatelessWidget {
  final String? queenId;
  final bool hideLocation;

  const EditQueenPage({
    this.queenId,
    this.hideLocation = false,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditQueenBloc(
        queenService: getIt<QueenService>(),
        apiaryService: getIt<ApiaryService>(),
        hiveService: getIt<HiveService>(),
        queenId: queenId,
        hideLocation: hideLocation,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            queenId == null
                ? 'edit_queen.create'.tr()
                : 'edit_queen.edit'.tr(),
          ),
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