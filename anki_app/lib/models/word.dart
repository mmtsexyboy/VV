import 'dart:math';

class Word {
  final String id;
  final String word;
  final String translation;
  final DateTime createdAt;
  DateTime? lastReviewedAt;
  int reviewCount;
  int lapses;
  double intervalDays;
  double easeFactor;

  Word({
    required this.id,
    required this.word,
    required this.translation,
    required this.createdAt,
    this.lastReviewedAt,
    this.reviewCount = 0,
    this.lapses = 0,
    this.intervalDays = 0.1,
    this.easeFactor = 2.5,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'reviewCount': reviewCount,
      'lapses': lapses,
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
    };
  }

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      translation: json['translation'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      intervalDays: (json['intervalDays'] as num?)?.toDouble() ?? 0.1,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
    );
  }

  /// Calculates estimated memory retention (0.0 to 1.0) based on Ebbinghaus forgetting curve.
  double get estimatedRetention {
    final now = DateTime.now();
    final referenceTime = lastReviewedAt ?? createdAt;
    final elapsedHours = now.difference(referenceTime).inMinutes / 60.0;
    final stabilityHours = intervalDays * 24.0;

    if (stabilityHours <= 0) return 0.0;
    // R = e^(-t/S)
    final retention = exp(-elapsedHours / stabilityHours);
    return retention.clamp(0.0, 1.0);
  }

  /// Calculates urgency score. Lower retention = higher urgency to review.
  /// Unseen words get high priority if they have waited enough time.
  double get urgencyScore {
    final ret = estimatedRetention;
    double score = 1.0 - ret;
    if (reviewCount == 0) {
      score += 0.35; // boost new words
    }
    return score;
  }

  void markAsKnown() {
    reviewCount++;
    easeFactor = (easeFactor + 0.15).clamp(1.3, 3.5);

    if (reviewCount == 1) {
      intervalDays = 1.0;
    } else if (reviewCount == 2) {
      intervalDays = 3.0;
    } else {
      intervalDays = intervalDays * easeFactor;
    }
    lastReviewedAt = DateTime.now();
  }

  void markAsForgotten() {
    lapses++;
    reviewCount++;
    easeFactor = (easeFactor - 0.2).clamp(1.3, 3.5);
    // Shorten interval drastically for review soon
    intervalDays = max(0.01, intervalDays * 0.25);
    lastReviewedAt = DateTime.now();
  }

  Word copyWith({
    String? word,
    String? translation,
  }) {
    return Word(
      id: id,
      word: word ?? this.word,
      translation: translation ?? this.translation,
      createdAt: createdAt,
      lastReviewedAt: lastReviewedAt,
      reviewCount: reviewCount,
      lapses: lapses,
      intervalDays: intervalDays,
      easeFactor: easeFactor,
    );
  }
}
