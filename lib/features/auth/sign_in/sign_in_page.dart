import 'package:flutter/material.dart';
import 'package:apiarium/core/core.dart';
import 'sign_in_view.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backgroundHoneycomb),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SignInView()),
    );
  }
}
