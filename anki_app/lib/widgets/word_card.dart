import 'package:flutter/material.dart';
import '../models/word.dart';

class WordCard extends StatefulWidget {
  final Word word;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    this.onTap,
  });

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> with SingleTickerProviderStateMixin {
  bool _showTranslation = false;

  @override
  void didUpdateWidget(covariant WordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.id != widget.word.id) {
      _showTranslation = false;
    }
  }

  void _toggleReveal() {
    setState(() {
      _showTranslation = !_showTranslation;
    });
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _toggleReveal,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2638) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.primary.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Top Indicator Accent
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 6,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Retention / Urgency Status Tag
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : theme.colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.word.reviewCount == 0
                              ? 'جدید'
                              : 'تکرار: ${widget.word.reviewCount}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Word Text
                    Text(
                      widget.word.word,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider or Reveal Hint
                    AnimatedCrossFade(
                      firstChild: Column(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: isDark ? Colors.white38 : Colors.black38,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لمس کنید تا ترجمه نمایان شود',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                      secondChild: Column(
                        children: [
                          Divider(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            thickness: 1.5,
                            indent: 40,
                            endIndent: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.word.translation,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      crossFadeState: _showTranslation
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
