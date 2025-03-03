import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ous/domain/user_providers.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/gen/user_data.dart';
import 'package:ous/infrastructure/user_repository.dart';

class MyPageEdit extends ConsumerWidget {
  final ImagePicker _picker = ImagePicker();
  MyPageEdit({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsyncValue = ref.watch(userStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント情報編集'),
      ),
      body: userDataAsyncValue.when(
        data: (userData) {
          final nameController =
              TextEditingController(text: userData?.displayName);
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
        final imageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(XFile(croppedImage.path));
        if (imageUrl != null) {
          await ref.read(userRepositoryProvider).updateUser(
                userData?.uid ?? '',
                photoURL: imageUrl,
              );
          ref.refresh(userStreamProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('プロフィール画像が更新されました。')),
          );
        }
      }
    }
  }
}
