import 'package:dorm_of_decents/data/models/login_response.dart';
import 'package:dorm_of_decents/ui/pages/account/info_card.dart';
import 'package:flutter/material.dart';

class InfoCardsSection extends StatelessWidget {
  final UserData userData;

  const InfoCardsSection({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          InfoCard(
            icon: Icons.fingerprint_outlined,
            title: 'ID',
            value: userData.id,
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.work_outline,
            title: 'Role',
            value: userData.role.toUpperCase(),
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: userData.email,
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.shield_outlined,
            title: 'Account Status',
            value: 'Active',
          ),
        ],
      ),
    );
  }
}
