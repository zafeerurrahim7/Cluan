///   Author: Zafeer Ur Rahim
///   Date: 11/11/2025
///   Description: Screen to add a new Cluan.
///                Has three text fields clue, answer, date and three buttons
///                Add, Clear, Test Addition. Uses Provider to talk to the model.
///                LLM: None
///   Bugs: None known
///   Reflection: I wanted to add stuff from this class to another class just make it look nicer,
///               due to time constraint i kept it this way.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cluan.dart';

/// AddCluanWidget
/// A stateful widget that lets the user type a new clue, answer, and date,
/// then add it to the list. The date is optional.
class AddCluanWidget extends StatefulWidget {
  const AddCluanWidget({super.key});

  // Creates the state object that holds the controllers and button logic.
  @override
  State<AddCluanWidget> createState() => _AddCluanWidgetState();
}

/// Class: _AddCluanWidgetState
/// Owns controllers for the three TextFields and the button handlers.
class _AddCluanWidgetState extends State<AddCluanWidget> {
  /// Text controllers for input fields.
  final clueCtrl = TextEditingController();
  final answerCtrl = TextEditingController();
  final dateCtrl = TextEditingController();

  /// Clean up controllers to avoid leaks.
  @override
  void dispose() {
    clueCtrl.dispose();
    answerCtrl.dispose();
    dateCtrl.dispose();
    super.dispose();
  }

  /// Parse a date string
  /// Returns null if blank or invalid
  DateTime? _parseDate(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    try {
      final parts = t.split('-');
      if (parts.length != 3) return null;
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  /// Try to add the new Cluan via the model.
  /// Shows a short message on success or if the answer is too short.
  Future<void> _add() async {
    final ok = await context.read<CluansModel>().addCluan(
      clue: clueCtrl.text,
      answer: answerCtrl.text.toUpperCase(),
      date: _parseDate(dateCtrl.text),
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added')));
      _clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer must be at least 3 characters')),
      );
    }
  }

  // Clear all text fields.
  void _clear() {
    clueCtrl.clear();
    answerCtrl.clear();
    dateCtrl.clear();
  }

  // Quickly insert a sample row to test the Add button.
  Future<void> _testAddition() async {
    await context.read<CluansModel>().addCluan(
      clue: 'Sample clue about planets and rings',
      answer: 'SATURN',
      date: null,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sample added')));
  }

  // Build the page: three text fields + three buttons.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Cluan')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            TextField(
              controller: clueCtrl,
              decoration: const InputDecoration(labelText: 'Clue'),
              maxLines: 2,
            ),
            TextField(
              controller: answerCtrl,
              decoration: const InputDecoration(
                labelText: 'Answer (3–15 chars)',
              ),
            ),
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                labelText: 'Date (optional: yyyy-mm-dd)',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  label: const Text('Add a Cluan'),
                ),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                TextButton.icon(
                  onPressed: _testAddition,
                  icon: const Icon(Icons.science),
                  label: const Text('Test Addition'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
