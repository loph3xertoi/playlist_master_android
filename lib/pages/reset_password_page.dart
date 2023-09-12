import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/app_state.dart';
import '../widgets/reset_pass_form.dart';

class ResetPassPage extends StatelessWidget {
  const ResetPassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    MyAppState appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset password', style: textTheme.labelLarge),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onSecondary),
      ),
      body: SignupForm(),
    );
  }
}
