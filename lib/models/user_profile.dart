enum UserGender { male, female }

enum AvatarPreset {
  robotNeon,
  robotClassic,
  robotFriendly,
  womanLight,
  womanDark,
  womanHijabLight,
  womanHijabDark,
  manLight,
  manDark,
  customPhoto,
}

class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.assistantName,
    required this.learningLanguage,
    required this.englishVariant,
    required this.avatarPreset,
    this.avatarBase64,
    this.avatarPath,
  });

  final String firstName;
  final String lastName;
  final UserGender gender;
  final String assistantName;
  final String learningLanguage;
  final String englishVariant;
  final AvatarPreset avatarPreset;
  final String? avatarBase64;
  final String? avatarPath;

  String get userName => [firstName.trim(), lastName.trim()]
      .where((e) => e.isNotEmpty)
      .join(' ');

  String get safeAssistantName => assistantName.trim().isEmpty ? 'سيكو' : assistantName.trim();

  bool get isFemale => gender == UserGender.female;

  String get learnVerb => isFemale ? 'اتعلمي' : 'اتعلم';
  String get chooseVerb => isFemale ? 'اختاري' : 'اختار';
  String get practiceVerb => isFemale ? 'مارسي' : 'مارس';

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    UserGender? gender,
    String? assistantName,
    String? learningLanguage,
    String? englishVariant,
    AvatarPreset? avatarPreset,
    String? avatarBase64,
    String? avatarPath,
    bool clearAvatarData = false,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      assistantName: assistantName ?? this.assistantName,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      englishVariant: englishVariant ?? this.englishVariant,
      avatarPreset: avatarPreset ?? this.avatarPreset,
      avatarBase64: clearAvatarData ? null : (avatarBase64 ?? this.avatarBase64),
      avatarPath: clearAvatarData ? null : (avatarPath ?? this.avatarPath),
    );
  }

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender.name,
        'userName': userName, // backward compatibility with older builds
        'assistantName': safeAssistantName,
        'learningLanguage': learningLanguage,
        'englishVariant': englishVariant,
        'avatarPreset': avatarPreset.name,
        'avatarBase64': avatarBase64,
        'avatarPath': avatarPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final legacyName = json['userName'] as String? ?? '';
    final parts = legacyName.trim().split(RegExp(r'\s+'));
    final first = (json['firstName'] as String?)?.trim() ??
        (parts.isNotEmpty ? parts.first : '');
    final last = (json['lastName'] as String?)?.trim() ??
        (parts.length > 1 ? parts.sublist(1).join(' ') : '');

    final rawGender = json['gender'] as String? ?? 'male';
    final gender = UserGender.values.firstWhere(
      (value) => value.name == rawGender,
      orElse: () => UserGender.male,
    );

    final rawPreset = json['avatarPreset'] as String? ?? AvatarPreset.robotNeon.name;
    final preset = AvatarPreset.values.firstWhere(
      (value) => value.name == rawPreset,
      orElse: () => AvatarPreset.robotNeon,
    );

    return UserProfile(
      firstName: first,
      lastName: last,
      gender: gender,
      assistantName: (json['assistantName'] as String?)?.trim().isNotEmpty == true
          ? (json['assistantName'] as String).trim()
          : 'سيكو',
      learningLanguage: json['learningLanguage'] as String? ?? 'English',
      englishVariant: json['englishVariant'] as String? ?? 'American',
      avatarPreset: preset,
      avatarBase64: json['avatarBase64'] as String?,
      avatarPath: json['avatarPath'] as String?,
    );
  }
}
