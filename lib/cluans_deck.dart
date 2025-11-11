///   Author: Zafeer Ur Rahim
///   Date: 14/10/2025
///   Description: UI helpers for the Cluans app.
///                Contains: CluansBar (AppBar), CluansList (ListView), CluanTile (row).
///                Buttons call the model using context.read \<CluansModel>().
///                LLM: None
///   Changes: delete on hold
///   Bugs: None known
///   Reflection: It was a chalenge but splitting the widgets made it readable and easier to implement.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cluan.dart';

/// Class: CluansBar
/// Top app bar for the screen.
/// Provides sort by clue, sort by answer length.
/// Uses context.read so this widget does not rebuild on changes.
class CluansBar extends StatelessWidget implements PreferredSizeWidget {
  const CluansBar({super.key});

  /// AppBar must report its height to the framework.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  /// Build the app bar with two sort buttons.
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Cluans'),
      actions: [
        IconButton(
          tooltip: 'Sort by Clue',
          icon: const Icon(Icons.sort_by_alpha),
          onPressed: () => context.read<CluansModel>().sortByClue(),
        ),
        IconButton(
          tooltip: 'Sort by Answer Length',
          icon: const Icon(Icons.stacked_bar_chart),
          onPressed: () => context.read<CluansModel>().sortByAnswerLength(),
        ),
      ],
    );
  }
}

/// Class: CluanTile
/// One row in the list.
class CluanTile extends StatelessWidget {
  final Cluan cluan;
  //final List <Cluan> cluanAnswer;
  const CluanTile({super.key, required this.cluan});

  /// Build the ListView between rows.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cluan.clue),
      subtitle: Text(
        '${cluan.answer} • ${cluan.weekdayFull} • ${cluan.dateFormat}',
      ),
      trailing: Text('${cluan.answer.length}'),
    );
  }
}

/// Class: RemoveAt
/// A wrapper that listens for a long-press on a Cluan.
/// If held for 2 seconds, deletes that Cluan from Supabase through the model.
class RemoveAt extends StatefulWidget {
  final int index;
  final Cluan cluan;
  const RemoveAt({super.key, required this.index, required this.cluan});

  @override
  State<RemoveAt> createState() => _RemoveAtState();
}

class _RemoveAtState extends State<RemoveAt> {
  bool _isHolding = false;

  Future<void> _handleLongPress() async {
    setState(() => _isHolding = true);

    // Wait for 2 seconds of continuous hold
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    if (_isHolding) {
      // Delete this cluan from Supabase
      await context.read<CluansModel>().removeAt(widget.index);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('"${widget.cluan.clue}" deleted')));
    }
  }

  void _cancelHold() {
    setState(() => _isHolding = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _handleLongPress(),
      onLongPressEnd: (_) => _cancelHold(),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: _isHolding ? 0.5 : 1.0,
        child: ListTile(
          title: Text(widget.cluan.clue),
          subtitle: Text(
            '${widget.cluan.answer} • ${widget.cluan.weekdayFull} • ${widget.cluan.dateFormat}',
          ),
        ),
      ),
    );
  }
}

/// Class: CluansList
/// One row in the list.
/// Gets a list of Cluan items from the parent.
class CluansList extends StatelessWidget {
  final List<Cluan> items;
  const CluansList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return RemoveAt(index: index, cluan: items[index]);
      },
    );
  }
}
