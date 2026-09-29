import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/user_profile.dart';

class SikoAvatar extends StatefulWidget {
  const SikoAvatar({
    super.key,
    this.imageBase64,
    this.imagePath,
    this.preset = AvatarPreset.robotNeon,
    this.mode = AvatarAnimationMode.idle,
    this.size = 180,
    this.showBody = true,
  });

  final String? imageBase64;
  final String? imagePath;
  final AvatarPreset preset;
  final AvatarAnimationMode mode;
  final double size;
  final bool showBody;

  @override
  State<SikoAvatar> createState() => _SikoAvatarState();
}

class _SikoAvatarState extends State<SikoAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Uint8List? get _customBytes {
    final raw = widget.imageBase64;
    if (raw == null || raw.isEmpty) return null;
    try {
      return base64Decode(raw);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value * math.pi * 2;
        final active = widget.mode != AvatarAnimationMode.idle;
        final bob = (active ? 3.8 : 1.4) * math.sin(t);
        final tilt = widget.mode == AvatarAnimationMode.thinking
            ? math.sin(t * 0.8) * 0.015
            : widget.mode == AvatarAnimationMode.listening
                ? -0.015 + math.sin(t) * 0.006
                : math.sin(t * 0.5) * 0.005;
        final pulse = active ? 1 + (math.sin(t) + 1) * 0.018 : 1.0;

        return Transform.translate(
          offset: Offset(0, bob),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(scale: pulse, child: child),
          ),
        );
      },
      child: _buildAvatar(context),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final custom = widget.preset == AvatarPreset.customPhoto ? _customBytes : null;
    if (widget.preset == AvatarPreset.customPhoto && custom == null) {
      return _buildPresetAvatar(context, AvatarPreset.robotNeon);
    }
    final hasLegacyImage = widget.imagePath != null && widget.imagePath!.isNotEmpty;

    if (custom != null) {
      return _photoAvatar(custom, context);
    }

    return _buildPresetAvatar(context, widget.preset, hasLegacyImage: hasLegacyImage);
  }

  Widget _buildPresetAvatar(BuildContext context, AvatarPreset preset, {bool hasLegacyImage = false}) {
    return Semantics(
      label: 'Siko avatar',
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _InteractiveAvatarPainter(
          preset: preset,
          mode: widget.mode,
          t: _controller.value,
          accent: Theme.of(context).colorScheme.primary,
          showBody: widget.showBody,
          hasLegacyImage: hasLegacyImage,
        ),
      ),
    );
  }

  Widget _photoAvatar(Uint8List bytes, BuildContext context) {
    final active = widget.mode != AvatarAnimationMode.idle;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ],
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: active ? 32 : 20,
                spreadRadius: active ? 7 : 2,
                color: Theme.of(context).colorScheme.primary.withOpacity(.22),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(widget.size * .035),
          child: ClipOval(
            child: Image.memory(
              bytes,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.person_off_rounded, size: 64),
            ),
          ),
        ),
        IgnorePointer(
          child: Container(
            width: widget.size * .91,
            height: widget.size * .91,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(.45),
                width: 2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withOpacity(.22), Colors.transparent],
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            bottom: widget.size * .07,
            right: widget.size * .07,
            child: _StateBadge(mode: widget.mode),
          ),
      ],
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.mode});
  final AvatarAnimationMode mode;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mode) {
      AvatarAnimationMode.listening => Icons.mic_rounded,
      AvatarAnimationMode.thinking => Icons.more_horiz_rounded,
      AvatarAnimationMode.speaking => Icons.graphic_eq_rounded,
      AvatarAnimationMode.idle => Icons.chat_bubble_rounded,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(blurRadius: 8, spreadRadius: 1)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    );
  }
}

class _InteractiveAvatarPainter extends CustomPainter {
  const _InteractiveAvatarPainter({
    required this.preset,
    required this.mode,
    required this.t,
    required this.accent,
    required this.showBody,
    required this.hasLegacyImage,
  });

  final AvatarPreset preset;
  final AvatarAnimationMode mode;
  final double t;
  final Color accent;
  final bool showBody;
  final bool hasLegacyImage;

  bool get isRobot => preset.name.startsWith('robot');
  bool get isFemale => preset.name.startsWith('woman');
  bool get isHijab => preset == AvatarPreset.womanHijabLight || preset == AvatarPreset.womanHijabDark;
  bool get isDarkSkin => preset == AvatarPreset.womanDark || preset == AvatarPreset.womanHijabDark || preset == AvatarPreset.manDark;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final active = mode != AvatarAnimationMode.idle;
    final motion = math.sin(t * math.pi * 2);
    final eyeShift = mode == AvatarAnimationMode.thinking ? motion * s * .018 :
        mode == AvatarAnimationMode.listening ? s * .008 : 0;
    final mouthOpen = mode == AvatarAnimationMode.speaking ? (.025 + (motion + 1) * .025) * s : .016 * s;

    final bg = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withOpacity(.34),
          accent.withOpacity(.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: c, radius: s * .52));
    canvas.drawCircle(c, s * .50, bg);

    if (isRobot) {
      _paintRobot(canvas, size, c, motion, eyeShift, mouthOpen, active);
    } else {
      _paintHuman(canvas, size, c, motion, eyeShift, mouthOpen, active);
    }

    if (hasLegacyImage) {
      final p = Paint()..color = accent.withOpacity(.35);
      canvas.drawCircle(Offset(s * .82, s * .18), s * .035, p);
    }

    if (mode == AvatarAnimationMode.thinking) {
      for (int i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(s * (.73 + i * .06), s * (.78 - (i % 2) * .02)),
          s * (.018 + i * .004),
          Paint()..color = accent.withOpacity(.75),
        );
      }
    }

    if (mode == AvatarAnimationMode.listening) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .014
        ..color = accent.withOpacity(.50);
      canvas.drawCircle(c, s * .46, ring);
    }
  }

  void _paintRobot(Canvas canvas, Size size, Offset c, double motion, double eyeShift, double mouthOpen, bool active) {
    final s = size.width;
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          preset == AvatarPreset.robotClassic ? const Color(0xFFE6E8F1) : const Color(0xFFEAF8FF),
          const Color(0xFFADB5CF),
        ],
      ).createShader(Rect.fromLTWH(s * .2, s * .25, s * .6, s * .55));
    final dark = Paint()..color = const Color(0xFF22283A);
    final glow = Paint()
      ..shader = RadialGradient(colors: [accent, accent.withOpacity(.30)])
          .createShader(Rect.fromCircle(center: c, radius: s * .2));

    if (showBody) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(s * .27, s * .64, s * .46, s * .28), Radius.circular(s * .10)),
        Paint()..color = const Color(0xFF30384E),
      );
      final armPaint = Paint()..color = const Color(0xFF8D96B0);
      final double armOffset =
    (motion * s * 0.022).toDouble();

final double leftArmY =
    (s * (0.62 + armOffset / s)).toDouble();

final double rightArmY =
    (s * (0.62 - armOffset / s)).toDouble();

_drawArm(
  canvas,
  Offset(
    (s * 0.23).toDouble(),
    (s * 0.71).toDouble(),
  ),
  Offset(
    (s * 0.08).toDouble(),
    leftArmY,
  ),
  armPaint,
  false,
);

_drawArm(
  canvas,
  Offset(
    (s * 0.77).toDouble(),
    (s * 0.71).toDouble(),
  ),
  Offset(
    (s * 0.92).toDouble(),
    rightArmY,
  ),
  armPaint,
  true,
);
    }

    canvas.drawCircle(Offset(c.dx, c.dy + s * .01), s * .30, body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, c.dy), width: s * .48, height: s * .34),
        Radius.circular(s * .10),
      ),
      Paint()..color = const Color(0xFF252B3D),
    );

    final eyeY = c.dy - s * .045;
    canvas.drawCircle(Offset(c.dx - s * .105 + eyeShift, eyeY), s * .046, glow);
    canvas.drawCircle(Offset(c.dx + s * .105 + eyeShift, eyeY), s * .046, glow);

    final mouthRect = Rect.fromCenter(center: Offset(c.dx, c.dy + s * .09), width: s * .12, height: mouthOpen);
    canvas.drawRRect(RRect.fromRectAndRadius(mouthRect, Radius.circular(s * .025)), dark);

    final antenna = Paint()
      ..color = dark.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .014
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx, s * .23), Offset(c.dx, s * .13), antenna);
    canvas.drawCircle(Offset(c.dx, s * .115), s * .028, glow);
    canvas.drawCircle(Offset(s * .22, s * .48), s * .035, glow);
    canvas.drawCircle(Offset(s * .78, s * .48), s * .035, glow);

    if (active) {
      final shine = Paint()..color = Colors.white.withOpacity(.22);
      canvas.drawOval(Rect.fromLTWH(s * .28, s * .30, s * .20, s * .09), shine);
    }
  }

  void _paintHuman(Canvas canvas, Size size, Offset c, double motion, double eyeShift, double mouthOpen, bool active) {
    final s = size.width;
    final skin = isDarkSkin ? const Color(0xFF855B49) : const Color(0xFFF0BE9A);
    final skinShade = isDarkSkin ? const Color(0xFF5C3B30) : const Color(0xFFC78667);
    final hair = isDarkSkin ? const Color(0xFF211B1B) : const Color(0xFF4B362A);
    final outfit = isFemale ? const Color(0xFF7A5AF8) : const Color(0xFF3164C7);
    final handPaint = Paint()..color = skin;

    if (showBody) {
      final shoulder = RRect.fromRectAndRadius(
        Rect.fromLTWH(s * .20, s * .62, s * .60, s * .32),
        Radius.circular(s * .18),
      );
      canvas.drawRRect(shoulder, Paint()..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [outfit.withOpacity(.92), outfit.withOpacity(.58)],
      ).createShader(shoulder.outerRect));

      final wave = mode == AvatarAnimationMode.speaking || mode == AvatarAnimationMode.listening;
      final leftHandY = wave ? s * (.58 + motion * .055) : s * .74;
      final rightHandY = wave ? s * (.55 - motion * .045) : s * .74;
      _drawArm(canvas, Offset(s * .25, s * .73), Offset(s * .10, leftHandY), Paint()..color = outfit, false);
      _drawArm(canvas, Offset(s * .75, s * .73), Offset(s * .90, rightHandY), Paint()..color = outfit, true);
      canvas.drawCircle(Offset(s * .10, leftHandY), s * .045, handPaint);
      canvas.drawCircle(Offset(s * .90, rightHandY), s * .045, handPaint);
      _drawFinger(canvas, Offset(s * .90, rightHandY), motion);
    }

    final neck = RRect.fromRectAndRadius(Rect.fromLTWH(s * .44, s * .48, s * .12, s * .17), Radius.circular(s * .04));
    canvas.drawRRect(neck, Paint()..color = skinShade);

    final head = Rect.fromLTWH(s * .27, s * .20, s * .46, s * .44);
    final headPaint = Paint()..shader = RadialGradient(
      center: const Alignment(-.3, -.45),
      radius: 1.0,
      colors: [skin.withOpacity(.98), skinShade.withOpacity(.98)],
    ).createShader(head);
    canvas.drawOval(head, headPaint);

    if (isHijab) {
      final hijabColor = preset == AvatarPreset.womanHijabDark ? const Color(0xFF26344B) : const Color(0xFFF0F0F5);
      final scarf = Path()
        ..moveTo(s * .24, s * .56)
        ..quadraticBezierTo(s * .22, s * .24, s * .50, s * .16)
        ..quadraticBezierTo(s * .79, s * .24, s * .76, s * .56)
        ..quadraticBezierTo(s * .50, s * .70, s * .24, s * .56)
        ..close();
      canvas.drawPath(scarf, Paint()..color = hijabColor);
      canvas.drawOval(Rect.fromLTWH(s * .30, s * .24, s * .40, s * .35), headPaint);
      canvas.drawArc(Rect.fromLTWH(s * .25, s * .16, s * .50, s * .50), .15, 2.85, false, Paint()
        ..color = hijabColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .08);
    } else {
      final hairPath = Path()
        ..moveTo(s * .26, s * .39)
        ..quadraticBezierTo(s * .22, s * .17, s * .50, s * .13)
        ..quadraticBezierTo(s * .79, s * .16, s * .74, s * .39)
        ..lineTo(s * .69, s * .27)
        ..quadraticBezierTo(s * .50, s * .19, s * .31, s * .27)
        ..close();
      canvas.drawPath(hairPath, Paint()..color = hair);
      if (isFemale) {
        canvas.drawOval(Rect.fromLTWH(s * .20, s * .28, s * .16, s * .34), Paint()..color = hair);
        canvas.drawOval(Rect.fromLTWH(s * .64, s * .28, s * .16, s * .34), Paint()..color = hair);
      }
    }

    final eyeY = s * .39;
    final eye = Paint()..color = const Color(0xFF2B2430);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * .40 + eyeShift, eyeY), width: s * .055, height: s * .035), eye);
    canvas.drawOval(Rect.fromCenter(center: Offset(s * .60 + eyeShift, eyeY), width: s * .055, height: s * .035), eye);

    final brow = Paint()
      ..color = hair
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .013
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(s * .34, s * .34), Offset(s * .44, s * .33), brow);
    canvas.drawLine(Offset(s * .56, s * .33), Offset(s * .66, s * .34), brow);

    final mouth = Rect.fromCenter(center: Offset(s * .50, s * .49), width: s * .11, height: mouthOpen);
    canvas.drawRRect(RRect.fromRectAndRadius(mouth, Radius.circular(s * .018)), Paint()..color = const Color(0xFF713E42));

    if (active) {
      canvas.drawOval(Rect.fromLTWH(s * .32, s * .25, s * .12, s * .05), Paint()..color = Colors.white.withOpacity(.18));
    }

    // Small animated "video call" sparkle.
    if (mode == AvatarAnimationMode.speaking) {
      canvas.drawCircle(Offset(s * .84, s * .23), s * .022, Paint()..color = accent.withOpacity(.9));
      canvas.drawCircle(Offset(s * .88, s * .27), s * .012, Paint()..color = accent.withOpacity(.65));
    }
  }

  void _drawArm(
  Canvas canvas,
  Offset from,
  Offset to,
  Paint paint,
  bool mirrored,
) {
  final double width = math.max<double>(
    4.0,
    paint.strokeWidth == 0.0
        ? 12.0
        : paint.strokeWidth,
  );

  final Paint armPaint = Paint()
    ..color = paint.color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;

  canvas.drawLine(from, to, armPaint);
  canvas.drawCircle(
    to,
    width * 0.46,
    armPaint,
  );
}

  void _drawFinger(Canvas canvas, Offset hand, double motion) {
  final p = Paint()
    ..color = const Color(0xFF855B49)
    ..strokeWidth = 2.1
    ..strokeCap = StrokeCap.round;

  for (int i = 0; i < 3; i++) {
    final double dx = (i - 1) * 5.0;

    canvas.drawLine(
      hand + Offset(dx, -3.0),
      hand + Offset(
        dx + motion * 2.0,
        -12.0 - i * 2.0,
      ),
      p,
    );
  }
}

  @override
  bool shouldRepaint(covariant _InteractiveAvatarPainter oldDelegate) =>
      oldDelegate.preset != preset ||
      oldDelegate.mode != mode ||
      oldDelegate.t != t ||
      oldDelegate.accent != accent ||
      oldDelegate.showBody != showBody ||
      oldDelegate.hasLegacyImage != hasLegacyImage;
}

enum AvatarAnimationMode { idle, thinking, listening, speaking }

class AvatarOption {
  const AvatarOption({required this.preset, required this.title, required this.subtitle, required this.icon});

  final AvatarPreset preset;
  final String title;
  final String subtitle;
  final IconData icon;
}

const avatarOptions = [
  AvatarOption(preset: AvatarPreset.robotNeon, title: 'روبوت Neon', subtitle: 'مستقبلي', icon: Icons.smart_toy_rounded),
  AvatarOption(preset: AvatarPreset.robotClassic, title: 'روبوت Classic', subtitle: 'هادئ واحترافي', icon: Icons.android_rounded),
  AvatarOption(preset: AvatarPreset.robotFriendly, title: 'روبوت Friendly', subtitle: 'اجتماعي', icon: Icons.sentiment_satisfied_alt_rounded),
  AvatarOption(preset: AvatarPreset.womanHijabLight, title: 'امرأة محجبة', subtitle: 'بشرة فاتحة', icon: Icons.face_3_rounded),
  AvatarOption(preset: AvatarPreset.womanHijabDark, title: 'امرأة محجبة', subtitle: 'بشرة داكنة', icon: Icons.face_3_rounded),
  AvatarOption(preset: AvatarPreset.womanLight, title: 'امرأة', subtitle: 'بشرة فاتحة', icon: Icons.face_2_rounded),
  AvatarOption(preset: AvatarPreset.womanDark, title: 'امرأة', subtitle: 'بشرة داكنة', icon: Icons.face_2_rounded),
  AvatarOption(preset: AvatarPreset.manLight, title: 'رجل', subtitle: 'بشرة فاتحة', icon: Icons.face_rounded),
  AvatarOption(preset: AvatarPreset.manDark, title: 'رجل', subtitle: 'بشرة داكنة', icon: Icons.face_rounded),
];
