import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../widgets/word_card.dart';
import '../widgets/add_word_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddWordDialog(BuildContext context, WordProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AddWordDialog(
        onSubmit: (word, translation) {
          provider.addWord(word, translation);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WordProvider>(context);
    final theme = Theme.of(context);
    final currentWord = provider.currentWord;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Anki Endless',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentWord == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_motion_outlined,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'هیچ کلمه‌ای وجود ندارد!',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'با دکمه + کلمه جدید اضافه کنید',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      // Endless Card Display area
                      Expanded(
                        child: WordCard(
                          key: ValueKey(currentWord.id),
                          word: currentWord,
                        ),
                      ),

                      // Bottom Action Bar: [بلد نیستم] --- (+) Squircle --- [بلدم]
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // "بلد نیستم" (Don't Know) Button
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.markCurrentAsForgotten();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade700,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  icon: const Icon(Icons.close_rounded, size: 24),
                                  label: const Text(
                                    'بلد نیستم',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // (+) Squircle Floating Action Button
                            Material(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20), // Squircle shape
                              elevation: 4,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => _showAddWordDialog(context, provider),
                                child: const SizedBox(
                                  width: 58,
                                  height: 56,
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // "بلدم" (Know) Button
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    provider.markCurrentAsKnown();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981), // Emerald Green
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_rounded, size: 24),
                                  label: const Text(
                                    'بلدم',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
