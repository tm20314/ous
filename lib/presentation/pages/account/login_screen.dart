// login_screen.dart

// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ous/infrastructure/tutorial_service.dart';
import 'package:ous/main.dart';
import 'package:ous/presentation/widgets/login/login_buttons.dart';
import 'package:ous/presentation/widgets/login/login_logo.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends ConsumerState<Login> {
  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authServiceProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // ログイン画面からの戻るボタンを無効化
        return;
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const HelloOus(),
                  Container(
                    padding: const EdgeInsets.only(
                      top: 200,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      children: <Widget>[
                        GoogleSignInButton(authService: authService),
                        SizedBox(height: 20.h),
                        if (!kIsWeb && Platform.isIOS)
                          AppleSignInButton(authService: authService),
                        SizedBox(height: 20.h),
                        GuestSignInButton(authService: authService),
                        SizedBox(height: 20.h),
                        const PrivacyPolicyButton(),
                      ],
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

  @override
  void initState() {
    super.initState();
    TutorialService.showTutorialIfNeeded(context);

    // スプラッシュ画面を削除し、ステータスバーを表示
    FlutterNativeSplash.remove();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
}
