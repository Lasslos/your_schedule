import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManualLoginScreen extends ConsumerWidget {
  const ManualLoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manueller Log-In"),
        centerTitle: true,
      ),
      body: const Placeholder(),
    );
  }
}
