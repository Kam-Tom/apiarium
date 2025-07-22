import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/edit_hive_view.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditHivePage extends StatelessWidget {
  final String? hiveId;
  final bool hideLocation;
  final String? queenId;

  const EditHivePage({
    this.hiveId,
    this.hideLocation = false,
    this.queenId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditHiveBloc(
        queenService: getIt<QueenService>(),
        apiaryService: getIt<ApiaryService>(),
        hiveService: getIt<HiveService>(),
      )..add(EditHiveLoadData(hiveId: hiveId, queenId: queenId)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            hiveId == null
                ? 'edit_hive.create'.tr()
                : 'edit_hive.edit'.tr(),
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
        body: EditHiveView(hideLocation: hideLocation),
      ),
    );
  }
}