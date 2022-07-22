import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'dataConstants.g.dart';

/// url link
const readrMail = 'readr@readr.tw';
const youtubeLink = 'https://www.youtube.com/';
const readrProjectLink = 'https://www.readr.tw/';

/// assets
const String error400Svg = 'assets/image/error404.svg';
const String error500Svg = 'assets/image/error500.svg';
const String noInternetSvg = 'assets/image/noInternet.svg';
const String defaultImageSvg = 'assets/image/defaultImage.svg';
const String tabNoContentPng = 'assets/image/tabNoContent.png';
const String googleLogoSvg = 'assets/icon/googleLogo.svg';
const String noFollowingSvg = 'assets/image/noFollowing.svg';
const String latestNewsEmptySvg = 'assets/image/latestNewsEmpty.svg';
const String splashIconPng = 'assets/icon/splashIcon.png';
const String welcomeScreenLogoSvg = 'assets/image/welcomeScreenLogo.svg';
const String appBarIconSvg = 'assets/icon/appBarIcon.svg';
const String personalFileArrowSvg = 'assets/icon/personalFileArrow.svg';
const String readrPageActiveSvg = 'assets/icon/readrPageActive.svg';
const String readrPageDefaultSvg = 'assets/icon/readrPageDefault.svg';
const String collectionDeleteHintSvg = 'assets/image/collectionDeleteHint.svg';
const String collectionDeletedSvg = 'assets/image/collectionDeleted.svg';
const String latestPageActiveSvg = 'assets/icon/latestPageActive.svg';
const String latestPageDefaultSvg = 'assets/icon/latestPageDefault.svg';
const String threeStarSvg = 'assets/image/threeStar.svg';

//json
const serviceAccountCredentialsJson =
    'assets/json/serviceAccountCredentials.json';

/// color
const Color themeColor = Color(0xffFFFFFF);
const Color appBarColor = Color(0xffFFFFFF);
const Color tabBarColor = Color(0xffFFFFFF);
const Color tabBarSelectedColor = Color.fromRGBO(0, 9, 40, 0.87);
const Color editorChoiceTagColor = Color.fromRGBO(0, 9, 40, 0.66);
const Color editorChoiceBackgroundColor = Color(0xffFFFFFF);
const Color bottomNavigationBarSelectedColor = Color.fromRGBO(0, 9, 40, 0.87);
const Color bottomNavigationBarUnselectedColor = Color.fromRGBO(0, 9, 40, 0.5);
const Color readrBlack = Color.fromRGBO(0, 9, 40, 1);
const Color readrBlack87 = Color.fromRGBO(0, 9, 40, 0.87);
const Color readrBlack66 = Color.fromRGBO(0, 9, 40, 0.66);
const Color readrBlack50 = Color.fromRGBO(0, 9, 40, 0.5);
const Color readrBlack30 = Color.fromRGBO(0, 9, 40, 0.3);
const Color readrBlack20 = Color.fromRGBO(0, 9, 40, 0.2);
const Color readrBlack10 = Color.fromRGBO(0, 9, 40, 0.1);

const Color storyWidgetColor = Color(0xff04295E);
const Color storySummaryFrameColor = storyWidgetColor;
const Color blockquoteColor = Color.fromRGBO(0, 9, 40, 0.1);
const Color annotationColor = readrBlack87;
const Color homeScreenBackgroundColor = Color.fromRGBO(246, 246, 251, 1);

// enum
enum PickObjective {
  story,
  comment,
  collection,
}

enum PickState {
  public,
  friend,
  private,
}

enum PickKind {
  bookmark,
  collect,
  read,
}

enum CommentTransparency {
  public,
  friend,
  private,
}

enum CollectionFormat {
  folder,
  timeline,
}

enum CollectionPublic {
  private,
  public,
  wiki,
}

enum CollectionStatus {
  publish,
  draft,
  delete,
}

enum FollowObjective {
  member,
  publisher,
  collection,
}

@HiveType(typeId: 3)
enum NotifyType {
  @HiveField(0)
  comment,

  @HiveField(1)
  follow,

  @HiveField(2)
  like,

  @HiveField(3)
  pickCollection,

  @HiveField(4)
  commentCollection,

  @HiveField(5)
  createCollection,
}
