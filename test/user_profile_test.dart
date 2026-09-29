import 'package:flutter_test/flutter_test.dart';
import 'package:siko_ai/models/user_profile.dart';

void main() {
  test('UserProfile round-trips through json', () {
    const profile = UserProfile(
      firstName: 'محمد',
      lastName: 'سلطان',
      gender: UserGender.male,
      assistantName: 'سيكو',
      learningLanguage: 'English',
      englishVariant: 'American',
      avatarPreset: AvatarPreset.robotNeon,
    );

    final decoded = UserProfile.fromJson(profile.toJson());
    expect(decoded.userName, 'محمد سلطان');
    expect(decoded.assistantName, 'سيكو');
    expect(decoded.gender, UserGender.male);
    expect(decoded.avatarPreset, AvatarPreset.robotNeon);
  });
}
