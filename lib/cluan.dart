///   Author: Zafeer Ur Rahim
///   Date: 4/11/2025
///   Description: A simple Flutter model file for the Cluans app.
///                It defines a Cluan class (holds clue, answer, and date)
///                and a CluansModel class (manages the list and sorting logic).
///                This file practices using ChangeNotifier and model structure.
///                LLM: I didnt use LLM for this class
///   Changes: Now instead of hard coded clues and answers it uses the database in supabase,
///            it converts answers to be uppercase when added.
///            Added loadMine() and deleteMineAt() to handle the My Cluans tab.
///   Bugs: None known
///   Reflection: Moving to a DB helped me practice async code and model design.
///               These changes further helped me practice handeling row level securities.
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global Supabase client
final supabase = Supabase.instance.client;

/// Class: Cluan
/// One row with id, clue, answer, and the created date.
class Cluan {
  final int? id;
  final String clue;
  final String answer;
  final DateTime date;
  final String? userId;

  static const int clueLength = 150;
  static const int answerLength = 21;

  /// Constructor:
  /// Limits clue to 150 chars and answer to 21 chars.
  Cluan({
    this.id,
    required String clue,
    required String answer,
    DateTime? date,
    this.userId,
  }) : clue = clue.length <= clueLength ? clue : clue.substring(0, clueLength),
       answer = answer.length <= answerLength
           ? answer
           : answer.substring(0, answerLength),
       date = date ?? DateTime.now();

  static const _weekdayFull = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get weekdayFull => _weekdayFull[date.weekday - 1];

  String get dateFormat {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}

/// Class: CluansModel
/// load all rows from Supabase
/// add a new row with uppercase answer
/// remove a row by index
/// sort locally by clue or answer length
/// compute a few simple stats for the Stats screen
class CluansModel extends ChangeNotifier {
  final List<Cluan> _items = [];

  /// Returns a copy of the list so UI can show data.
  List<Cluan> get items => List.unmodifiable(_items);
  int get length => _items.length;

  final List<Cluan> _mine = [];
  List<Cluan> get mine => List.unmodifiable(_mine);

  /// Load all rows from Supabase
  Future<void> loadAll() async {
    final rows = await supabase
        .from('cluans')
        .select()
        .order('created_at', ascending: false);

    _items
      ..clear()
      ..addAll(
        (rows as List).map((r) {
          final m = r as Map<String, dynamic>;
          final created = m['created_at'];
          final dt = created is String
              ? DateTime.parse(created)
              : (created is DateTime ? created : DateTime.now());
          return Cluan(
            id: m['id'] as int?,
            clue: (m['clue'] ?? '') as String,
            answer: (m['answer'] ?? '') as String,
            date: dt,
            userId: m['user_id'] as String?,
          );
        }),
      );
    notifyListeners();
  }
  
  /// Load only the logged-in user's Cluans
  Future<void> loadMine() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;

    final rows = await supabase
        .from('cluans')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    _mine
      ..clear()
      ..addAll(
        (rows as List).map((r) {
          final m = r as Map<String, dynamic>;
          final created = m['created_at'];
          final dt = created is String
              ? DateTime.parse(created)
              : (created is DateTime ? created : DateTime.now());
          return Cluan(
            id: m['id'] as int?,
            clue: (m['clue'] ?? '') as String,
            answer: (m['answer'] ?? '') as String,
            date: dt,
            userId: m['user_id'] as String?,
          );
        }),
      );
    notifyListeners();
  }

  /// Add a new Cluan to Supabase and refresh the list.
  Future<bool> addCluan({
    required String clue,
    required String answer,
    DateTime? date,
  }) async {
    final ans = answer.trim().toUpperCase();
    if (ans.length < 3) return false;

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return false;

    final safeClue = clue.length <= Cluan.clueLength
        ? clue
        : clue.substring(0, Cluan.clueLength);

    final safeAnswer = ans.length <= Cluan.answerLength
        ? ans
        : ans.substring(0, Cluan.answerLength);

    await supabase.from('cluans').insert({
      'clue': safeClue,
      'answer': safeAnswer,
      'created_at': (date ?? DateTime.now()).toIso8601String(),
      'user_id': uid,
    });

    await loadAll();
    return true;
  }

  /// Remove the row
  Future<void> removeAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    final id = _items[index].id;
    if (id != null) {
      await supabase.from('cluans').delete().eq('id', id);
      await loadAll();
      return;
    } else {
      _items.removeAt(index);
      notifyListeners();
    }
  }
  
  /// Deletes a Cluan created by the logged in user from My Cluans.
  /// RLS policies in Supabase ensure users can only delete their Cluan.
  Future<void> deleteMineAt(int index) async {
    if (index < 0 || index >= _mine.length) return;
    final id = _mine[index].id;
    if (id == null) return;
    await supabase
        .from('cluans')
        .delete()
        .eq('id', id); // RLS enforces ownership
    await loadAll();
    await loadMine();
  }

  /// Sorts list alphabetically by clue
  void sortByClue() {
    _items.sort(
      (a, b) =>
          a.clue.trim().toLowerCase().compareTo(b.clue.trim().toLowerCase()),
    );
    notifyListeners();
  }

  /// Sorts list by answer length
  void sortByAnswerLength() {
    _items.sort((a, b) => a.answer.length.compareTo(b.answer.length));
    notifyListeners();
  }

  List<int> _lens() => _items.map((e) => e.answer.length).toList();

  int? get minLength {
    final length = _lens();
    return length.isEmpty ? null : length.reduce(math.min);
  }

  int? get maxLength {
    final length = _lens();
    return length.isEmpty ? null : length.reduce(math.max);
  }

  double? get meanLength {
    final length = _lens();
    if (length.isEmpty) return null;
    final sum = length.fold<int>(0, (s, x) => s + x);
    return sum / length.length;
  }

  /// Sample standard deviation (n-1). Null if n < 2.
  double? get sampleStdDev {
    final length = _lens();
    if (length.length < 2) return null;
    final mu = meanLength!;
    final sumSq = length.fold<double>(0, (s, x) => s + (x - mu) * (x - mu));
    return math.sqrt(sumSq / (length.length - 1));
  }

  /// First on ties.
  Cluan? get shortest {
    if (_items.isEmpty) return null;
    return _items.reduce(
      (a, b) => (a.answer.length <= b.answer.length) ? a : b,
    );
  }

  /// First on ties.
  Cluan? get longest {
    if (_items.isEmpty) return null;
    return _items.reduce(
      (a, b) => (a.answer.length >= b.answer.length) ? a : b,
    );
  }
}
