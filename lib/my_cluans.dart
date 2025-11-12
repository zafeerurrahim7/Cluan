///   Author: Zafeer Ur Rahim
///   Date: 11/11/2025
///   Description: Shows only the logged-in user's cluans.
///                Allows adding by taping +.
///                Allows delete by a long-press on cluan.
///                Allows user to logout.
///                LLM: None
///   Bugs: None known
///   Reflection: I learned how to pull only my rows using the logged-in user’s ID.
///               This was a bit challenging but going step by step through painters example
///               helped alot.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cluan.dart';
import 'add_cluan.dart';

/// Class MyCluansWidget
/// /// Shows only rows where user_id == current user.
class MyCluansWidget extends StatefulWidget {
  const MyCluansWidget({super.key});

  @override
  State<MyCluansWidget> createState() => _MyCluansWidgetState();
}

class _MyCluansWidgetState extends State<MyCluansWidget> {
  @override
  void initState() {
    super.initState();
    context.read<CluansModel>().loadMine();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CluansModel>();
    final mine = model.mine;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cluans'),
        actions: [
          IconButton(
            tooltip: 'Add cluan',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final ok = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const AddCluanWidget()),
              );
              if (ok == true) {
                // refresh ALL and MINE so other tabs update too
                final m = context.read<CluansModel>();
                await m.loadAll();
                await m.loadMine();
              }
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: mine.isEmpty
          ? const Center(
              child: Text('You have no cluans yet. Tap ⊕ to add one!'),
            )
          : ListView.builder(
              itemCount: mine.length,
              itemBuilder: (_, i) {
                final c = mine[i];
                final d =
                    '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-${c.date.day.toString().padLeft(2, '0')}';
                return GestureDetector(
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete this cluan?'),
                        content: Text('"${c.clue}"'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      // RLS enforces ownership
                      await context.read<CluansModel>().deleteMineAt(
                        i,
                      ); 
                    }
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(c.clue),
                      subtitle: Text('${c.answer} • $d'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
