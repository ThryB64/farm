import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppLayout({
    Key? key,
    required this.child,
    required this.title,
    this.actions,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          // Logo/nom ferme à gauche
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.agriculture,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Text(
            'GAEC de la BARADE',
            style: AppTheme.h2,
          ),
        ],
      ),
      actions: [
        // Avatar utilisateur + bouton paramètres à droite
        Container(
          margin: const EdgeInsets.only(right: AppTheme.spacingM),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primary,
            child: const Text(
              'T',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Paramètres',
        ),
        // Actions personnalisées
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: child,
    );
  }
}