import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/edit_apiary_view.dart';
import 'package:apiarium/shared/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/core/theme/app_theme.dart';

class EditApiaryPage extends StatelessWidget {
  final String? apiaryId;
  
  const EditApiaryPage({this.apiaryId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EditApiaryBloc(
        apiaryService: getIt<ApiaryService>(),
        hiveService: getIt<HiveService>(),
        queenService: getIt<QueenService>(),
      )..add(EditApiaryLoadData(apiaryId: apiaryId)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(
            apiaryId == null
                ? 'edit_apiary.create'.tr()
                : 'edit_apiary.edit'.tr(),
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
        body: const EditApiaryView(),
      ),
    );
  }
}
