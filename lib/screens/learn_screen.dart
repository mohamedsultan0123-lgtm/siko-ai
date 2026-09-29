import 'package:flutter/material.dart';

import '../services/profile_store.dart';
import '../services/tts_service.dart';
import '../widgets/section_title.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, this.initialLanguage});
  final String? initialLanguage;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  late String _language;
  int _level = 1;
  final _tts = TtsService();

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage ?? ProfileStore.instance.profile!.learningLanguage;
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  String get _accent => ProfileStore.instance.profile!.englishVariant;

  String _ttsLocale() {
    if (_language == 'French') return 'fr-FR';
    return _accent == 'British' ? 'en-GB' : 'en-US';
  }

  Future<void> _play(String text) => _tts.speak(text, _ttsLocale());

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Row(
          children: [
            Expanded(child: Text('تعلم مع سيكو', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900))),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'French', child: Text('Français')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _language = value);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(_language == 'English' ? '${_accent} English • شرح بالعربي' : 'Français • شرح بالعربي'),
        const SizedBox(height: 22),
        _ProgressCard(level: _level),
        const SizedBox(height: 22),
        const SectionTitle('درس اليوم'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المستوى A${_level}', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(_language == 'English' ? 'التعريف بالنفس' : 'التعريف بالنفس بالفرنسية', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(_language == 'English'
                    ? 'Hello, my name is Mohammed. Nice to meet you.'
                    : 'Bonjour, je m’appelle Mohammed. Enchanté.', style: const TextStyle(fontSize: 18, height: 1.5)),
                const SizedBox(height: 8),
                Text('الشرح: سيكو يشرح الجملة بالعربي، ثم يخليك تسمعها وتكررها وتستخدمها في محادثة قصيرة مع تصحيح تدريجي.'),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _play(_language == 'English' ? 'Hello, my name is Mohammed. Nice to meet you.' : 'Bonjour, je m’appelle Mohammed. Enchanté.'),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: const Text('اسمع الجملة'),
                    ),
                    FilledButton.icon(
                      onPressed: () => setState(() => _level = _level >= 5 ? 1 : _level + 1),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('ابدأ التمرين'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        const SectionTitle('مسارات التعلم'),
        _LessonTile(icon: Icons.record_voice_over_outlined, title: 'النطق والاستماع', subtitle: 'اسمع، كرر، ثم احصل على تصحيح.'),
        _LessonTile(icon: Icons.menu_book_outlined, title: 'المفردات', subtitle: 'كلمات جديدة مع مراجعة متباعدة.'),
        _LessonTile(icon: Icons.rule_rounded, title: 'القواعد', subtitle: 'شرح بالعربي بأمثلة بسيطة.'),
        _LessonTile(icon: Icons.theater_comedy_outlined, title: 'مواقف واقعية', subtitle: 'مطعم، مطار، مقابلة عمل، اجتماع وغيرها.'),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    final progress = 0.2 + (level - 1) * 0.15;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [const Icon(Icons.insights_rounded), const SizedBox(width: 8), Text('تقدمك الحالي', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress.clamp(0, 1).toDouble(), minHeight: 10)),
            const SizedBox(height: 8),
            Text('Level A$level • ${ProfileStore.instance.profile!.chooseVerb} التمرين التالي ونطوّر المستوى بناءً على أدائك.'),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}
