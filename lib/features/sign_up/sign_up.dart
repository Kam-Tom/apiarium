import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Center(
        child: Text('test'.tr(), style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
