import 'package:flutter/material.dart';
import 'search_tab.dart';
import 'favorites_tab.dart';
import 'history_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  // Global Keys to communicate across tabs in IndexedStack
  final GlobalKey<SearchTabState> _searchKey = GlobalKey();
  final GlobalKey<FavoritesTabState> _favKey = GlobalKey();
  final GlobalKey<HistoryTabState> _histKey = GlobalKey();

  void _searchFromHistory(String query) {
    setState(() {
      _currentIndex = 0;
    });
    _searchKey.currentState?.executeSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          SearchTab(key: _searchKey),
          if (_visitedTabs.contains(1))
            FavoritesTab(key: _favKey)
          else
            const SizedBox.shrink(),
          if (_visitedTabs.contains(2))
            HistoryTab(key: _histKey, onSelectQuery: _searchFromHistory)
          else
            const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          final wasVisited = _visitedTabs.contains(index);
          setState(() {
            _currentIndex = index;
            _visitedTabs.add(index);
          });
          if (wasVisited && index == 1) _favKey.currentState?.loadFavorites();
          if (wasVisited && index == 2) _histKey.currentState?.loadHistory();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Achọcha'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Mmasị',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Ncheta'),
        ],
      ),
    );
  }
}
