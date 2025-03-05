// Flutter imports:
// Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Project imports:
import 'package:ous/infrastructure/auth_service.dart';
import 'package:ous/main.dart';
import 'package:ous/presentation/pages/main_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppleSignInButton extends LoginButton {
  const AppleSignInButton({
    super.key,
    required super.authService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: getButtonStyle(context),
      onPressed: () async {
        try {
          debugPrint('Apple ログイン開始');
          final userCredential = await signIn();
          debugPrint('Apple ログイン結果: ${userCredential != null ? "成功" : "失敗"}');

          if (userCredential != null && context.mounted) {
            onSignInSuccess(context, ref);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appleでのログインに失敗しました')),
            );
          }
        } on Exception catch (e) {
          debugPrint('Apple ログイン例外: $e');
          if (!context.mounted) return;
          onSignInFailure(context, e);
        }
      },
      child: getButtonChild(context),
    );
  }

  @override
  Widget getButtonChild(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.apple,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        Text(
          'Appleでサインイン',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  ButtonStyle getButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      side: BorderSide(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );
  }

  @override
  String getFailureMessage(Exception e) {
    if (e is FirebaseAuthException) {
      return "Appleでのログインに失敗しました: ${e.message}";
    } else {
      return "Appleでのログインに失敗しました: $e";
    }
  }

  @override
  String getSuccessMessage() => "Appleでログインしました";

  @override
  Future<UserCredential?> signIn() => _authService.signInWithApple();
}

class ColorConstants {
  static const Color universityButtonTextColor =
      Color.fromARGB(255, 46, 96, 47);
}

class GoogleSignInButton extends LoginButton {
  const GoogleSignInButton({
    super.key,
    required super.authService,
  });

  @override
  Widget getButtonChild(BuildContext context) {
    return const Text(
      '大学のアカウントでサインイン',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: ColorConstants.universityButtonTextColor,
      ),
    );
  }

  @override
  ButtonStyle getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.lightGreen[300],
      fixedSize: const Size.fromWidth(double.maxFinite),
      shape: const StadiumBorder(),
    );
  }

  @override
  String getFailureMessage(Exception e) {
    if (e is FirebaseAuthException) {
      return "大学のアカウントでのログインに失敗しました: ${e.message}";
    } else {
      return "大学のアカウントでのログインに失敗しました: $e";
    }
  }

  @override
  String getSuccessMessage() => "大学のアカウントでログインしました";

  @override
  Future<UserCredential?> signIn() => _authService.signInWithGoogle();
}

class GuestSignInButton extends LoginButton {
  const GuestSignInButton({
    super.key,
    required super.authService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: getButtonStyle(context),
      onPressed: () async {
        await showConfirmationDialog(context, ref);
      },
      child: getButtonChild(context),
    );
  }

  @override
  Widget getButtonChild(BuildContext context) {
    return const Text(
      '会員登録せずに使う（ゲストモード）',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    );
  }

  @override
  ButtonStyle getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      fixedSize: const Size.fromWidth(double.maxFinite),
      shape: const StadiumBorder(),
    );
  }

  @override
  String getFailureMessage(Exception e) {
    if (e is FirebaseAuthException) {
      return "ゲストモードでのログインに失敗しました: ${e.message}";
    } else {
      return "ゲストモードでのログインに失敗しました: $e";
    }
  }

  @override
  String getSuccessMessage() => "ゲストモードでログインしました";

  @override
  Future<UserCredential?> signIn() => _authService.signInAnonymously();
}

abstract class LoginButton extends ConsumerWidget {
  final AuthService _authService;

  const LoginButton({super.key, required AuthService authService})
      : _authService = authService;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: getButtonStyle(context),
      onPressed: () async {
        try {
          final userCredential = await signIn();
          if (userCredential != null && context.mounted) {
            onSignInSuccess(context, ref);
          }
        } on Exception catch (e) {
          if (!context.mounted) return;

          onSignInFailure(context, e);
        }
      },
      child: getButtonChild(context),
    );
  }

  Widget getButtonChild(BuildContext context);

  ButtonStyle getButtonStyle(BuildContext context);

  String getFailureMessage(Exception e);

  String getSuccessMessage();

  void onSignInFailure(BuildContext context, Exception e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getFailureMessage(e))),
    );
  }

  void onSignInSuccess(BuildContext context, WidgetRef ref) async {
    // ログアウト状態をリセット
    await ref.read(authServiceProvider).resetLogoutState();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const MainScreen();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(getSuccessMessage())),
    );
  }

  Future<void> showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text(
            '大学のアカウント以外でログインしようとしています。一部機能が使えなかったりするけど大丈夫そ？\n\n※ゲストモードだと30日後にアカウントが消えます。',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('続ける'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final userCredential = await signIn();
        if (userCredential != null && context.mounted) {
          onSignInSuccess(context, ref);
        }
      } on Exception catch (e) {
        if (!context.mounted) return;

        onSignInFailure(context, e);
      }
    }
  }

  Future<UserCredential?> signIn();
}

class PrivacyPolicyButton extends StatelessWidget {
  const PrivacyPolicyButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launchUrlString(
          'https://tan-q-bot-unofficial.com/terms_of_service/',
        );
      },
      child: const Text(
        '利用規約はこちら',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
