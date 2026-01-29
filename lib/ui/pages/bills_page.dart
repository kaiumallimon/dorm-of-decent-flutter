import 'package:dorm_of_decents/ui/widgets/custom_page_header.dart';
import 'package:flutter/material.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {},
          child: Column(
            children: [
              CustomPageHeader(
                theme: theme,
                title: 'Bills',
                subtitle: 'Track your bills',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
