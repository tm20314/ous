import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ous/domain/upload_provider.dart';
import 'package:ous/domain/user_providers.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/gen/user_data.dart';
import 'package:ous/infrastructure/user_repository.dart';

class MyPageEdit extends ConsumerStatefulWidget {
  const MyPageEdit({super.key});

  @override
  MyPageEditState createState() => MyPageEditState();
}

class MyPageEditState extends ConsumerState<MyPageEdit> {
  final nameController = TextEditingController();
  String? errorMessage;
  String? successMessage;
  bool isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // ゲストユーザーかどうかを確認
    final isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? true;

    // ゲストの場合はエラー画面を表示
    if (isGuest) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('アカウント情報編集'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.icon.error.path,
                width: 150.0,
              ),
              const SizedBox(height: 20),
              const Text(
                'ゲストモードではアカウント情報を編集できません',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('戻る'),
              ),
            ],
          ),
        ),
      );
    }

    final userDataAsyncValue = ref.watch(userStreamProvider);

    // アップロード状態を監視
    final isUploading = ref.watch(uploadingProvider);

    // アップロード中はローディング表示
    if (isUploading) {
      return Scaffold(
        appBar: AppBar(title: const Text('アカウント情報編集')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('画像をアップロード中...'),
            ],
          ),
        ),
      );
    }

    // 通常の画面表示
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント情報編集'),
      ),
      body: userDataAsyncValue.when(
        data: (userData) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      clipBehavior: Clip.none,
                      fit: StackFit.expand,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading:
                                            const Icon(Icons.photo_library),
                                        title: const Text('ギャラリーから選択'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickAndCropImage(
                                            ImageSource.gallery,
                                            ref,
                                            userData,
                                            context,
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.photo_camera),
                                        title: const Text('カメラで撮影'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickAndCropImage(
                                            ImageSource.camera,
                                            ref,
                                            userData,
                                            context,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage: userData?.photoURL != ''
                                ? CachedNetworkImageProvider(
                                    userData?.photoURL ?? '',
                                  )
                                : null,
                            child: userData?.photoURL == ''
                                ? const Icon(Icons.person, size: 100)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: -25,
                          child: RawMaterialButton(
                            onPressed: () {},
                            elevation: 2.0,
                            fillColor: const Color(0xFFF5F6F9),
                            padding: const EdgeInsets.all(10.0),
                            shape: const CircleBorder(),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: nameController),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameController.text != userData?.displayName) {
                        await ref.read(userRepositoryProvider).updateUser(
                              userData?.uid ?? '',
                              name: nameController.text,
                            );

                        if (!context.mounted) return;
                        ref.refresh(userStreamProvider);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('名前が更新されました。')),
                        );
                        Navigator.of(context).pop(true);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('変更がありません。')),
                        );
                        Navigator.of(context).pop(false);
                      }
                    },
                    child: const Text('名前を保存'),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.icon.error.path,
                width: 150.0,
              ),
              Text('エラー: $error'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // エラーメッセージがあれば表示
    if (errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage!)),
        );
        setState(() {
          errorMessage = null;
        });
      });
    }

    // 成功メッセージがあれば表示
    if (successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage!)),
        );
        setState(() {
          successMessage = null;
        });
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 初期化処理
  }

  Future<void> _pickAndCropImage(
    ImageSource source,
    WidgetRef ref,
    UserData? userData,
    BuildContext context,
  ) async {
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 70, // 圧縮品質を70に設定
        maxWidth: 512, // 最大幅を512に設定
        maxHeight: 512, // 最大高さを512に設定
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '画像をトリミング',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            showCropGrid: false,
          ),
          IOSUiSettings(
            title: '画像をトリミング',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedImage != null) {
        // アップロード中状態をセット
        ref.read(uploadingProvider.notifier).state = true;

        try {
          final imageUrl = await ref
              .read(userRepositoryProvider)
              .uploadProfileImage(XFile(croppedImage.path));

          if (imageUrl != null) {
            await ref.read(userRepositoryProvider).updateUser(
                  userData?.uid ?? '',
                  photoURL: imageUrl,
                );
            ref.refresh(userStreamProvider);

            // コンテキストがまだ有効かチェック
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('プロフィール画像が更新されました。')),
              );
            }
          } else {
            // エラーメッセージをセット
            ref.read(uploadErrorProvider.notifier).state = '画像のアップロードに失敗しました。';
          }
        } catch (e) {
          // エラーメッセージをセット
          ref.read(uploadErrorProvider.notifier).state = '画像のアップロードに失敗しました: $e';
          print('画像アップロードエラー: $e');
        } finally {
          // アップロード中状態を解除
          ref.read(uploadingProvider.notifier).state = false;
        }
      }
    }
  }
}
