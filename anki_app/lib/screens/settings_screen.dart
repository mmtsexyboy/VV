import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../widgets/add_word_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _searchQuery = '';

  void _exportData(BuildContext context, WordProvider provider) {
    final jsonStr = provider.exportJson();
    // ignore: deprecated_member_use
    Share.share(
      jsonStr,
      subject: 'Anki_Backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
  }

  Future<void> _importData(BuildContext context, WordProvider provider) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result != null && result.isNotEmpty && result.first.path != null) {
        final file = File(result.first.path!);
        final content = await file.readAsString();
        final success = await provider.importJson(content);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'داده‌ها با موفقیت وارد شدند'
                    : 'خطا در خواندن یا ساختار فایل',
              ),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا در فراخوانی فایل: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context, WordProvider provider, Word word) {
    showDialog(
      context: context,
      builder: (ctx) => AddWordDialog(
        initialWord: word.word,
        initialTranslation: word.translation,
        onSubmit: (newWord, newTranslation) {
          provider.updateWord(word.id, newWord, newTranslation);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WordProvider>(context);
    final theme = Theme.of(context);
    final words = provider.words.where((w) {
      final q = _searchQuery.toLowerCase();
      return w.word.toLowerCase().contains(q) || w.translation.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات و کلمات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dark Theme Toggle & Backup section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: provider.isDarkTheme,
                  title: const Text('تم تاریک (Dark Theme)'),
                  subtitle: const Text('حالت شب برای کاهش خستگی چشم'),
                  secondary: Icon(
                    provider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
                    color: theme.colorScheme.primary,
                  ),
                  onChanged: (val) => provider.toggleTheme(val),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _exportData(context, provider),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('پشتیبان‌گیری (Export)'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _importData(context, provider),
                        icon: const Icon(Icons.download),
                        label: const Text('بازیابی (Import)'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو در لیست کلمات...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // Words List
          Expanded(
            child: words.isEmpty
                ? const Center(child: Text('کلمه‌ای یافت نشد'))
                : ListView.builder(
                    itemCount: words.length,
                    itemBuilder: (context, index) {
                      final item = words[index];
                      return ListTile(
                        title: Text(
                          item.word,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.translation),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => _showEditDialog(context, provider, item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                provider.deleteWord(item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
