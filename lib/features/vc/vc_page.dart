import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/vc_bloc.dart';
import 'vc_view.dart';
import '../../shared/services/services.dart';

class VCPage extends StatelessWidget {
  const VCPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VcBloc(
        vcService: context.read<VcService>(),
        userService: context.read<UserService>(),
      )..add(CheckVcModelStatus()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Voice Control'),
        ),
        body: const VCView(),
      ),
    );
  }
}
