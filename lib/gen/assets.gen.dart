/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsIconGen {
  const $AssetsIconGen();

  /// File path: assets/icon/accounticon.jpg
  AssetGenImage get accounticon =>
      const AssetGenImage('assets/icon/accounticon.jpg');

  /// File path: assets/icon/book.png
  AssetGenImage get book => const AssetGenImage('assets/icon/book.png');

  /// File path: assets/icon/error.gif
  AssetGenImage get error => const AssetGenImage('assets/icon/error.gif');

  /// File path: assets/icon/found.gif
  AssetGenImage get found => const AssetGenImage('assets/icon/found.gif');

  /// File path: assets/icon/icon.png
  AssetGenImage get icon => const AssetGenImage('assets/icon/icon.png');

  /// File path: assets/icon/icon_dark.png
  AssetGenImage get iconDark =>
      const AssetGenImage('assets/icon/icon_dark.png');

  /// File path: assets/icon/logo.png
  AssetGenImage get logo => const AssetGenImage('assets/icon/logo.png');

  /// File path: assets/icon/lunch.gif
  AssetGenImage get lunch => const AssetGenImage('assets/icon/lunch.gif');

  /// File path: assets/icon/maintenance.gif
  AssetGenImage get maintenance =>
      const AssetGenImage('assets/icon/maintenance.gif');

  /// File path: assets/icon/news.png
  AssetGenImage get news => const AssetGenImage('assets/icon/news.png');

  /// File path: assets/icon/password.gif
  AssetGenImage get password => const AssetGenImage('assets/icon/password.gif');

  /// File path: assets/icon/rocket.gif
  AssetGenImage get rocket => const AssetGenImage('assets/icon/rocket.gif');

  /// File path: assets/icon/search.gif
  AssetGenImage get search => const AssetGenImage('assets/icon/search.gif');

  /// File path: assets/icon/update.png
  AssetGenImage get update => const AssetGenImage('assets/icon/update.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        accounticon,
        book,
        error,
        found,
        icon,
        iconDark,
        logo,
        lunch,
        maintenance,
        news,
        password,
        rocket,
        search,
        update
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/IMG_0669.jpg
  AssetGenImage get img0669 =>
      const AssetGenImage('assets/images/IMG_0669.jpg');

  /// File path: assets/images/Na_April_08.jpg
  AssetGenImage get naApril08 =>
      const AssetGenImage('assets/images/Na_April_08.jpg');

  /// File path: assets/images/faculty_of_biology_and_earth_science.jpg
  AssetGenImage get facultyOfBiologyAndEarthScience => const AssetGenImage(
      'assets/images/faculty_of_biology_and_earth_science.jpg');

  /// File path: assets/images/faculty_of_education.jpg
  AssetGenImage get facultyOfEducation =>
      const AssetGenImage('assets/images/faculty_of_education.jpg');

  /// File path: assets/images/faculty_of_engineering.jpg
  AssetGenImage get facultyOfEngineering =>
      const AssetGenImage('assets/images/faculty_of_engineering.jpg');

  /// File path: assets/images/faculty_of_information_science_and_technology.jpg
  AssetGenImage get facultyOfInformationScienceAndTechnology =>
      const AssetGenImage(
          'assets/images/faculty_of_information_science_and_technology.jpg');

  /// File path: assets/images/faculty_of_science.jpg
  AssetGenImage get facultyOfScience =>
      const AssetGenImage('assets/images/faculty_of_science.jpg');

  /// File path: assets/images/faculty_of_veterinary_medicine.jpg
  AssetGenImage get facultyOfVeterinaryMedicine =>
      const AssetGenImage('assets/images/faculty_of_veterinary_medicine.jpg');

  /// File path: assets/images/home.jpg
  AssetGenImage get home => const AssetGenImage('assets/images/home.jpg');

  /// File path: assets/images/homedark.jpeg
  AssetGenImage get homedark =>
      const AssetGenImage('assets/images/homedark.jpeg');

  /// File path: assets/images/mockup.PNG
  AssetGenImage get mockup => const AssetGenImage('assets/images/mockup.PNG');

  /// File path: assets/images/school_of_business_administration.jpg
  AssetGenImage get schoolOfBusinessAdministration => const AssetGenImage(
      'assets/images/school_of_business_administration.jpg');

  /// File path: assets/images/school_of_life_sciences.jpg
  AssetGenImage get schoolOfLifeSciences =>
      const AssetGenImage('assets/images/school_of_life_sciences.jpg');

  /// List of all assets
  List<AssetGenImage> get values => [
        img0669,
        naApril08,
        facultyOfBiologyAndEarthScience,
        facultyOfEducation,
        facultyOfEngineering,
        facultyOfInformationScienceAndTechnology,
        facultyOfScience,
        facultyOfVeterinaryMedicine,
        home,
        homedark,
        mockup,
        schoolOfBusinessAdministration,
        schoolOfLifeSciences
      ];
}

class Assets {
  const Assets._();

  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
