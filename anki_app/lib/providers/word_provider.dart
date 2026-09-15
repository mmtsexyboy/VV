import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';

class WordProvider with ChangeNotifier {
  static const String _storageKey = 'anki_words_v1';
  static const String _themeKey = 'anki_dark_theme';

  List<Word> _words = [];
  Word? _currentWord;
  bool _isDarkTheme = true;
  bool _isLoading = true;

  List<Word> get words => List.unmodifiable(_words);
  Word? get currentWord => _currentWord;
  bool get isDarkTheme => _isDarkTheme;
  bool get isLoading => _isLoading;

  WordProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkTheme = prefs.getBool(_themeKey) ?? true;

      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _words = jsonList.map((j) => Word.fromJson(j as Map<String, dynamic>)).toList();
      } else {
        // Initial sample words if empty
        _words = [
          Word(
            id: '1',
            word: 'Endless',
            translation: 'بی‌پایان / همیشگی',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          Word(
            id: '2',
            word: 'Perseverance',
            translation: 'پشتکار / استقامت',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Word(
            id: '3',
            word: 'Serendipity',
            translation: 'کشف خوش‌انجام / سرنوشت خوب',
            createdAt: DateTime.now(),
          ),
        ];
        await _saveWordsToPrefs();
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _selectNextWord();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveWordsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _words.map((w) => w.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  void toggleTheme(bool value) async {
    _isDarkTheme = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  /// Selects the next best word for review using Spaced Repetition + Memory Decay algorithm.
  void _selectNextWord() {
    if (_words.isEmpty) {
      _currentWord = null;
      return;
    }

    if (_words.length == 1) {
      _currentWord = _words.first;
      return;
    }

    // Sort candidates by urgency score (highest urgency first)
    final candidates = List<Word>.from(_words);
    candidates.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));

    // To prevent showing the exact same word twice in a row (if more than 1 word exists)
    Word chosen = candidates.first;
    if (chosen.id == _currentWord?.id && candidates.length > 1) {
      // Pick second candidate or weighted random among top 3
      final randomIndex = Random().nextInt(min(3, candidates.length - 1)) + 1;
      chosen = candidates[randomIndex];
    }

    _currentWord = chosen;
  }

  /// Mark current word as known
  Future<void> markCurrentAsKnown() async {
    if (_currentWord == null) return;
    _currentWord!.markAsKnown();
    await _saveWordsToPrefs();
    _selectNextWord();
    notifyListeners();
  }

  /// Mark current word as forgotten
  Future<void> markCurrentAsForgotten() async {
    if (_currentWord == null) return;
    _currentWord!.markAsForgotten();
    await _saveWordsToPrefs();
    _selectNextWord();
    notifyListeners();
  }

  /// Add a new word
  Future<void> addWord(String wordText, String translationText) async {
    final newWord = Word(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      word: wordText.trim(),
      translation: translationText.trim(),
      createdAt: DateTime.now(),
    );
    _words.add(newWord);
    await _saveWordsToPrefs();
    _currentWord = newWord;
    notifyListeners();
  }

  /// Edit word
  Future<void> updateWord(String id, String newWord, String newTranslation) async {
    final index = _words.indexWhere((w) => w.id == id);
    if (index != -1) {
      _words[index] = _words[index].copyWith(
        word: newWord.trim(),
        translation: newTranslation.trim(),
      );
      await _saveWordsToPrefs();
      if (_currentWord?.id == id) {
        _currentWord = _words[index];
      }
      notifyListeners();
    }
  }

  /// Delete word
  Future<void> deleteWord(String id) async {
    _words.removeWhere((w) => w.id == id);
    await _saveWordsToPrefs();
    if (_currentWord?.id == id) {
      _selectNextWord();
    }
    notifyListeners();
  }

  /// Export all words to JSON string
  String exportJson() {
    final jsonList = _words.map((w) => w.toJson()).toList();
    return jsonEncode(jsonList);
  }

  /// Import words from JSON string
  Future<bool> importJson(String jsonStr) async {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonStr);
      final imported = jsonList.map((j) => Word.fromJson(j as Map<String, dynamic>)).toList();

      // Merge or replace (Merge based on ID/Word)
      final Map<String, Word> wordMap = {for (var w in _words) w.word.toLowerCase(): w};
      for (var item in imported) {
        wordMap[item.word.toLowerCase()] = item;
      }

      _words = wordMap.values.toList();
      await _saveWordsToPrefs();
      _selectNextWord();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }
}
