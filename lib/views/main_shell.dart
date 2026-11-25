import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import 'location_screen.dart';

class MainShellTabController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    if (index < 0 || index > 1 || index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    notifyListeners();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _tabController = MainShellTabController();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tabController,
      child: Consumer<MainShellTabController>(
        builder: (context, tabController, _) {
          final theme = Theme.of(context);
          final pillRadius = BorderRadius.circular(32);

          return Scaffold(
            body: IndexedStack(
              index: tabController.selectedIndex,
              children: const [HomeScreen(), LocationScreen()],
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: pillRadius,
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: ClipRRect(
                    borderRadius: pillRadius,
                    child: NavigationBar(
                      selectedIndex: tabController.selectedIndex,
                      onDestinationSelected: tabController.selectTab,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.cloud_outlined),
                          selectedIcon: Icon(Icons.cloud),
                          label: 'Cuaca',
                        ),
                        NavigationDestination(
                          icon: Icon(Icons.location_on_outlined),
                          selectedIcon: Icon(Icons.location_on),
                          label: 'Lokasi & Favorit',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
