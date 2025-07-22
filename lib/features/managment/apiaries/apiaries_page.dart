import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_view.dart';
import 'package:apiarium/features/managment/apiaries/bloc/apiaries_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApiariesPage extends StatelessWidget {
  const ApiariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApiariesBloc(
        apiaryService: getIt<ApiaryService>(),
      )..add(const LoadApiaries()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('apiaries.apiaries'.tr()),
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
          body: const ApiariesView(),
          floatingActionButton: _buildFAB(context),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await context.push(AppRouter.editApiary);
        if (context.mounted) {
          context.read<ApiariesBloc>().add(const LoadApiaries());
        }
      },
      backgroundColor: Colors.amber,
      child: const Icon(Icons.add),
    );
  }

}
