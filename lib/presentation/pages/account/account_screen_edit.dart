import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ous/domain/upload_provider.dart';
import 'package:ous/domain/user_providers.dart';
import 'package:ous/gen/assets.gen.dart';
import 'package:ous/infrastructure/repositories/user_repository.dart';
import 'package:path/path.dart' as path;

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
  File? _imageFile;
  String? _currentPhotoURL;
  final UserRepository _userRepository = UserRepository();

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                                  leading: const Icon(Icons.photo_library),
                                  title: const Text('ギャラリーから選択'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickAndCropImage(
                                      ImageSource.gallery,
                                      ref,
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
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : (_currentPhotoURL != null &&
                                  _currentPhotoURL!.isNotEmpty
                              ? NetworkImage(_currentPhotoURL!) as ImageProvider
                              : const AssetImage('assets/icon/icon.png')),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          radius: 18,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '表示名',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('保存'),
                  ),
                ],
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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;
          setState(() {
            nameController.text = userData['displayName'] as String? ?? '';
            _currentPhotoURL = userData['photoURL'] as String?;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ユーザー情報の取得に失敗しました: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickAndCropImage(
    ImageSource source,
    WidgetRef ref,
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
          final imageUrl = await _uploadImage();

          if (imageUrl != null) {
            await _userRepository.updateProfileImageUrl(imageUrl);
            ref.refresh(userStreamProvider);

            // 画像URLが変更された場合は更新
            if (imageUrl != _currentPhotoURL) {
              await _userRepository.updateProfileImageUrl(imageUrl);
            }

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

  Future<void> _saveChanges() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名前を入力してください')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 画像をアップロードして新しいURLを取得
      final imageUrl = await _uploadImage();

      // ユーザー名を更新
      await _userRepository.updateUserName(nameController.text.trim());

      // 画像URLが変更された場合は更新
      if (imageUrl != null && imageUrl != _currentPhotoURL) {
        await _userRepository.updateProfileImageUrl(imageUrl);
      }

      // userStreamProvider を明示的に更新
      ref.invalidate(userStreamProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('プロフィールを更新しました')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('プロフィールの更新に失敗しました: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _currentPhotoURL;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final fileName = '${user.uid}_${path.basename(_imageFile!.path)}';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(fileName);

      await storageRef.putFile(_imageFile!);
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('画像のアップロードに失敗しました: $e')),
        );
      }
      return null;
    }
  }
}
