import 'package:flutter/material.dart';

class BridgeLook {
  static const canvas = Color(0xFFF6F3EE);
  static const ink = Color(0xFF1B1A17);
  static const muted = Color(0xFF6E695F);
  static const line = Color(0xFFE4DED4);
  static const green = Color(0xFF0E7A55);

  static const display = TextStyle(
    fontFamily: 'Instrument Serif',
    fontSize: 42,
    height: 1.02,
    fontWeight: FontWeight.w400,
    color: ink,
    letterSpacing: -0.6,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: muted,
  );

  static const section = TextStyle(
    fontSize: 12,
    height: 1.2,
    letterSpacing: 1.3,
    fontWeight: FontWeight.w600,
    color: muted,
  );

  static const cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(18)),
    border: Border.fromBorderSide(BorderSide(color: line)),
    boxShadow: [
      BoxShadow(
        color: Color(0x12000000),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ],
  );

  static ThemeData theme() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ink,
        primary: ink,
        surface: Colors.white,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: muted),
        hintStyle: const TextStyle(color: Color(0xFFA39E94)),
        helperStyle: const TextStyle(color: muted),
        border: _fieldBorder(line),
        enabledBorder: _fieldBorder(line),
        focusedBorder: _fieldBorder(ink, width: 1.4),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: line),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ink),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
}

class BridgeTopBar extends StatelessWidget {
  const BridgeTopBar({super.key, this.actionLabel, this.onAction});

  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (Navigator.canPop(context))
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: BridgeLook.ink),
              ),
            ),
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BridgeLook.ink,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          const Text('Message Bridge',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: BridgeLook.ink)),
          const Spacer(),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: BridgeLook.ink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFC4BFB6),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: const StadiumBorder(),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: Text(actionLabel!),
            ),
        ],
      );
}

class BridgePhoto extends StatelessWidget {
  const BridgePhoto({super.key});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: const AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(
            image: AssetImage('assets/images/desk.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      );
}
