import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../services/avatar_service.dart';
import '../services/profile_store.dart';
import '../widgets/siko_avatar.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key, this.editMode = false});
  final bool editMode;

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _assistant = TextEditingController();
  String _learningLanguage = 'English';
  String _englishVariant = 'American';
  UserGender _gender = UserGender.male;
  AvatarPreset _preset = AvatarPreset.robotNeon;
  String? _avatarBase64;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = ProfileStore.instance.profile;
    if (existing != null) {
      _first.text = existing.firstName;
      _last.text = existing.lastName;
      _assistant.text = existing.assistantName == 'سيكو' ? '' : existing.assistantName;
      _learningLanguage = existing.learningLanguage;
      _englishVariant = existing.englishVariant;
      _gender = existing.gender;
      _preset = existing.avatarPreset;
      _avatarBase64 = existing.avatarBase64;
    }
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _assistant.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final result = await const AvatarService().pickAndEncodeAvatar();
    if (!mounted || result == null) return;
    setState(() {
      _avatarBase64 = result;
      _preset = AvatarPreset.customPhoto;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحميل الصورة واستخدامها كأفاتار 🎉')));
  }

  void _suggestGenderAvatar() {
    if (_gender == UserGender.female) {
      setState(() { _preset = AvatarPreset.womanHijabLight; _avatarBase64 = null; });
    } else {
      setState(() { _preset = AvatarPreset.manLight; _avatarBase64 = null; });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final assistant = _assistant.text.trim().isEmpty ? 'سيكو' : _assistant.text.trim();
    await ProfileStore.instance.save(
      UserProfile(
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        gender: _gender,
        assistantName: assistant,
        learningLanguage: _learningLanguage,
        englishVariant: _englishVariant,
        avatarPreset: _preset,
        avatarBase64: _avatarBase64,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (widget.editMode) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final assistantPreview = _assistant.text.trim().isEmpty ? 'سيكو' : _assistant.text.trim();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(.11),
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.secondary.withOpacity(.08),
              ],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 34),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.editMode ? 'تخصيص حسابك' : 'خلّينا نجهّز عالم سيكو',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (widget.editMode)
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('كل اختيار هنا هيأثر على طريقة كلام سيكو، شكل الأفاتار، وطريقة ظهور المحتوى لك.'),
                  const SizedBox(height: 18),
                  Center(
                    child: SikoAvatar(
                      imageBase64: _avatarBase64,
                      preset: _preset,
                      size: 200,
                      mode: AvatarAnimationMode.idle,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(child: Text('مرحبًا بـ $assistantPreview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
                  const SizedBox(height: 18),
                  _SectionCard(
                    title: 'بياناتك',
                    icon: Icons.person_rounded,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _first,
                                decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline_rounded)),
                                validator: (v) => v == null || v.trim().isEmpty ? 'اكتب الاسم' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _last,
                                decoration: const InputDecoration(labelText: 'اللقب / اسم العائلة', prefixIcon: Icon(Icons.badge_outlined)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<UserGender>(
                          value: _gender,
                          decoration: const InputDecoration(labelText: 'النوع', prefixIcon: Icon(Icons.wc_rounded)),
                          items: const [
                            DropdownMenuItem(value: UserGender.male, child: Text('ذكر')),
                            DropdownMenuItem(value: UserGender.female, child: Text('أنثى')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _gender = v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'المساعد الذكي',
                    icon: Icons.smart_toy_rounded,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _assistant,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'اسم المساعد (اختياري)',
                            hintText: 'سيكو',
                            prefixIcon: Icon(Icons.auto_awesome_rounded),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('اتركها فارغة وسيكون الاسم الافتراضي: سيكو.'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'التعلّم',
                    icon: Icons.school_rounded,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _learningLanguage,
                          decoration: const InputDecoration(labelText: 'اللغة التي تتعلمها', prefixIcon: Icon(Icons.language_rounded)),
                          items: const [
                            DropdownMenuItem(value: 'English', child: Text('English')),
                            DropdownMenuItem(value: 'French', child: Text('Français')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _learningLanguage = v);
                          },
                        ),
                        const SizedBox(height: 12),
                        if (_learningLanguage == 'English')
                          DropdownButtonFormField<String>(
                            value: _englishVariant,
                            decoration: const InputDecoration(labelText: 'نوع الإنجليزية', prefixIcon: Icon(Icons.record_voice_over_outlined)),
                            items: const [
                              DropdownMenuItem(value: 'American', child: Text('American English 🇺🇸')),
                              DropdownMenuItem(value: 'British', child: Text('British English 🇬🇧')),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _englishVariant = v);
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'شكل الأفاتار',
                    icon: Icons.view_in_ar_rounded,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _suggestGenderAvatar,
                                icon: const Icon(Icons.auto_fix_high_rounded),
                                label: Text(_gender == UserGender.female ? 'اقتراح أفاتار أنثى' : 'اقتراح أفاتار ذكر'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: _pickPhoto,
                                icon: const Icon(Icons.add_a_photo_rounded),
                                label: const Text('استخدم صورة'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: avatarOptions.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: .82,
                          ),
                          itemBuilder: (context, index) {
                            final option = avatarOptions[index];
                            final selected = _preset == option.preset;
                            return InkWell(
                              onTap: () => setState(() { _preset = option.preset; if (option.preset != AvatarPreset.customPhoto) _avatarBase64 = null; }),
                              borderRadius: BorderRadius.circular(18),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(.55),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(child: SikoAvatar(preset: option.preset, size: 72, mode: selected ? AvatarAnimationMode.speaking : AvatarAnimationMode.idle, showBody: false)),
                                    const SizedBox(height: 4),
                                    Text(option.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                    Text(option.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('الصورة المرفوعة تعمل كأفاتار مخصص متحرك الآن، وتم تجهيز التصميم لإضافة تحويل الصورة إلى شخصية 3D حقيقية بخدمة AI لاحقًا دون تغيير واجهة التطبيق.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.rocket_launch_rounded),
                    label: Text(widget.editMode ? 'حفظ التعديلات' : 'ابدأ مع سيكو'),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900))]),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
