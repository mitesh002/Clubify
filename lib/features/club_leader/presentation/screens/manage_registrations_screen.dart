import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class ManageRegistrationsScreen extends StatelessWidget {
  const ManageRegistrationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Registrations removed. Manage membership requests instead.'),
      ),
    );
  }
}
