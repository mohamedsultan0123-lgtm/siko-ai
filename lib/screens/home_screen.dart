import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/profile_store.dart';
import '../widgets/feature_card.dart';
import '../widgets/siko_avatar.dart';
import 'chat_screen.dart';
import 'learn_screen.dart';
import 'settings_screen.dart';
import 'voice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  final _pages = const [
    _DashboardTab(),
    LearnScreen(),
    ChatScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(child: _pages[_index]),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded), label: 'التعلم'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_rounded), label: 'الدردشة'),
            NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune_rounded), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [scheme.primary.withOpacity(.10), scheme.surface, scheme.secondary.withOpacity(.06)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أهلاً ${profile.userName} 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('أنا ${profile.safeAssistantName} — موجود معاك في الكلام والتعلم.'),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person_outline_rounded)),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
              child: Column(
                children: [
                  SikoAvatar(
                    imageBase64: profile.avatarBase64,
                    imagePath: profile.avatarPath,
                    preset: profile.avatarPreset,
                    mode: AvatarAnimationMode.speaking,
                    size: 220,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(99)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_rounded, size: 15, color: scheme.primary),
                        const SizedBox(width: 7),
                        Text('المحادثة متاحة — اختار الطريقة اللي تحبها', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('جاهز تتكلم؟', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('صوت، كتابة، تعلم لغة، أو فضفضة عن يومك.', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceScreen())),
                        icon: const Icon(Icons.mic_rounded),
                        label: const Text('ابدأ صوت'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
                        icon: const Icon(Icons.chat_rounded),
                        label: const Text('ابدأ كتابة'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('ماذا تريد أن تفعل الآن؟', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          FeatureCard(
            title: '${profile.learnVerb} ${profile.learningLanguage == 'English' ? 'الإنجليزية' : 'الفرنسية'}',
            subtitle: profile.learningLanguage == 'English' ? '${profile.englishVariant} English • شرح بالعربي' : 'Français • شرح بالعربي',
            icon: Icons.translate_rounded,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LearnScreen(initialLanguage: profile.learningLanguage))),
          ),
          FeatureCard(
            title: 'احكي لي عن يومك',
            subtitle: 'محادثة طبيعية بصوت سيكو وردوده المتحركة',
            icon: Icons.forum_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceScreen(dayTalk: true))),
          ),
          FeatureCard(
            title: 'جرّب شكل الأفاتار',
            subtitle: 'روبوت، رجل، امرأة، محجبة أو صورة مخصصة',
            icon: Icons.view_in_ar_rounded,
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
    );
  }
}
