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
          // Logo mini (pictogramme tracteur)
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
          // Nom de la ferme
          Text(
            'GAEC de la BARADE',
            style: AppTheme.h2,
          ),
        ],
      ),
      actions: [
        // Champ de recherche (optionnel desktop)
        if (MediaQuery.of(context).size.width > 768) ...[
          Container(
            width: 300,
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher parcelles, cellules...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
              ),
            ),
          ),
        ],
        // Icône paramètres
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Paramètres',
        ),
        // Profil (avatar cercle)
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
        // Aide
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.help_outline),
          tooltip: 'Aide',
        ),
        // Actions personnalisées
        if (actions != null) ...actions!,
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.pageMarginDesktop,
      ),
      child: child,
    );
  }
}

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        boxShadow: AppTheme.cardShadow,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.surface,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,
        selectedLabelStyle: AppTheme.meta,
        unselectedLabelStyle: AppTheme.meta,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.landscape_outlined),
            activeIcon: Icon(Icons.landscape),
            label: 'Parcelles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Cellules',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'Plus',
          ),
        ],
      ),
    );
  }
}

class Sidebar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isCollapsed;

  const Sidebar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isCollapsed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCollapsed ? 80 : 240,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Logo et nom (si pas collapsed)
          if (!isCollapsed) ...[
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Expanded(
                    child: Text(
                      'GAEC de la BARADE',
                      style: AppTheme.h3,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          
          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingS),
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Accueil',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.landscape_outlined,
                  activeIcon: Icons.landscape,
                  label: 'Parcelles',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view,
                  label: 'Cellules',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.local_shipping_outlined,
                  activeIcon: Icons.local_shipping,
                  label: 'Chargements',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.eco_outlined,
                  activeIcon: Icons.eco,
                  label: 'Variétés',
                  index: 4,
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Paramètres',
                  index: 5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = currentIndex == index;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? AppTheme.spacingM : AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusChip),
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppTheme.primary : AppTheme.textMuted,
                  size: 20,
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppTheme.spacingM),
                  Text(
                    label,
                    style: AppTheme.body.copyWith(
                      color: isActive ? AppTheme.primary : AppTheme.textMuted,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
