import 'package:flutter_test/flutter_test.dart';
import 'package:anki_app/models/word.dart';

void main() {
  group('Word Model & Retention Algorithm Tests', () {
    test('Retention score calculation', () {
      final word = Word(
        id: '1',
        word: 'Test',
        translation: 'تست',
        createdAt: DateTime.now(),
      );

      expect(word.estimatedRetention, closeTo(1.0, 0.05));
    });

    test('Marking as known updates intervals and review count', () {
      final word = Word(
        id: '1',
        word: 'Test',
        translation: 'تست',
        createdAt: DateTime.now(),
      );

      word.markAsKnown();
      expect(word.reviewCount, equals(1));
      expect(word.intervalDays, equals(1.0));
    });

    test('Marking as forgotten resets interval drastically', () {
      final word = Word(
        id: '1',
        word: 'Test',
        translation: 'تست',
        createdAt: DateTime.now(),
        reviewCount: 2,
        intervalDays: 5.0,
      );

      word.markAsForgotten();
      expect(word.lapses, equals(1));
      expect(word.intervalDays, lessThan(5.0));
    });
  });
}
