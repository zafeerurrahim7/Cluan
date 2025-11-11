///   Author: Zafeer Ur Rahim
///   Date: 14/10/2025
///   Description: Main entry for the Cluans app.
///                Sets up ChangeNotifierProvider at the top.
///                LLM: None
///   Changes: supabase connectivity  
///   Bugs: None known
///   Reflection: I like how using diferent classes made my build and main shorter.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'cluan.dart';
import 'cluans_deck.dart';
import 'add_cluan.dart';
import 'stats.dart';

/// Function: main
/// Starts the app with a ChangeNotifierProvider.
/// Provides CluansModel to all widgets below.
void main() async{
   WidgetsFlutterBinding.ensureInitialized();

    const supabaseURL = 'https://pwuanklxfsscvhhymqsq.supabase.co';
    const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3dWFua2x4ZnNzY3ZoaHltcXNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3NDUwOTcsImV4cCI6MjA3NzMyMTA5N30.GF73cgI-a5tMEGkHedpCHzodgAhcH1j-4emrIN_vDKc';
  await Supabase.initialize(url: supabaseURL, anonKey: supabaseAnonKey);

  runApp(
    ChangeNotifierProvider(
      create: (_) => CluansModel()..loadAll(),
      child: const CluansApp(),
    ),
  );
}

/// Class: CluansApp
/// Root widget that creates a MaterialApp.
/// Home points to HomeScreen.
class CluansApp extends StatelessWidget {
  const CluansApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cluans On The Move!',
      //theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home:  HomeScreen(),
    );
  }
}

/// Class: HomeScreen
/// Statefull widget with bottom navigation state. 
/// displays List, Add, Stats.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// Class: CluansWidget
/// Uses context.watch to rebuild on model changes.
/// Rebuilds when the model calls notifyListeners().
class CluansWidget extends StatelessWidget {
  const CluansWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CluansModel>();
    return Scaffold(
      appBar: const CluansBar(),
      body: CluansList(items: model.items),
    );
  }
}

/// Class: _HomeScreenState
/// Stores the selected tab and builds the outer Scaffold,
/// by using a NavigationBar and an IndexedStack to preserve.
class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  // Tab pages shown by the NavigationBar.
  final pages = const [
    CluansWidget(), 
    AddCluanWidget(), 
    StatisticsWidget(), 
  ];
  
  /// Builds the outer Scaffold wrapping the tab content.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (position) => setState(() => selectedIndex = position),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
    );
  }
}
