import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/user_profile.dart';
import '../services/profile_store.dart';
import '../services/theme_store.dart';
import '../widgets/siko_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Text('الإعدادات', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SikoAvatar(imageBase64: profile.avatarBase64, imagePath: profile.avatarPath, preset: profile.avatarPreset, size: 76, showBody: false),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(profile.userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('المساعد: ${profile.safeAssistantName}'),
                    const SizedBox(height: 3),
                    Text(profile.gender == UserGender.female ? 'النوع: أنثى' : 'النوع: ذكر', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
                IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.edit_outlined)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: ThemeStore.instance,
          builder: (context, _) => Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(ThemeStore.instance.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                  title: const Text('مظهر التطبيق'),
                  subtitle: Text(ThemeStore.instance.isDark ? 'الوضع الليلي' : 'الوضع النهاري'),
                ),
                SwitchListTile(
                  value: ThemeStore.instance.isDark,
                  onChanged: ThemeStore.instance.setDark,
                  title: const Text('الوضع الليلي'),
                  secondary: const Icon(Icons.brightness_6_rounded),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.psychology_alt_rounded),
                title: const Text('الذكاء الاصطناعي'),
                subtitle: Text(AppConfig.geminiApiKey.isEmpty ? 'Demo حالياً — يمكنك ربط API لاحقًا' : 'Gemini API مفعل'),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.mic_none_rounded),
                title: Text('الصوت'),
                subtitle: Text('Speech-to-Text و Text-to-Speech باستخدام خدمات الجهاز.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.view_in_ar_rounded),
                title: Text('نظام الأفاتار'),
                subtitle: Text('أشكال متعددة + صورة شخصية مخصصة + حالات تفاعل: استماع، تفكير، كلام.'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded),
                title: const Text('تحويل الصورة إلى 3D'),
                subtitle: const Text('واجهة المشروع مجهزة لهذه الخطوة، وتحتاج مزود AI لتوليد نموذج 3D حقيقي.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('عن سيكو'),
              content: const Text('Siko AI — مساعد ذكي عربي الأولوية لتعلم اللغات والمحادثة، مع أفاتار متحرك وواجهة قابلة للتوسع إلى 3D وAI متقدم.'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))],
            ),
          ),
          icon: const Icon(Icons.info_outline_rounded),
          label: const Text('حول المشروع'),
        ),
      ],
    );
  }
}
