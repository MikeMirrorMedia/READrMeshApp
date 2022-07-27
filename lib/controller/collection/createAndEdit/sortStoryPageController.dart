import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/descriptionPageController.dart';
import 'package:readr/controller/collection/createAndEdit/inputTitlePageController.dart';
import 'package:readr/controller/personalFile/collectionTabController.dart';
import 'package:readr/controller/pick/pickableItemController.dart';
import 'package:readr/getxServices/pubsubService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/collectionStory.dart';
import 'package:readr/pages/collection/collectionPage.dart';
import 'package:readr/services/collectionService.dart';

class SortStoryPageController extends GetxController {
  final CollectionRepos collectionRepos;
  final isUpdating = false.obs;
  final List<CollectionStory> originalList;
  final collectionStoryList = <CollectionStory>[].obs;
  final Collection? collection;
  bool isFirstTimeEdit = true;
  final bool isEdit;
  bool hasChange = false;
  SortStoryPageController(
    this.collectionRepos,
    this.originalList,
    this.isEdit, {
    this.collection,
  });

  @override
  void onInit() {
    isFirstTimeEdit = Get.find<SharedPreferencesService>()
            .prefs
            .getBool('firstTimeEditCollection') ??
        true;
    ever(collectionStoryList, (callback) => _checkHasChange());
    collectionStoryList.assignAll(originalList);
    super.onInit();
  }

  @override
  void onReady() {
    if (isFirstTimeEdit && isEdit) {
      _showDeleteHint();
    }
    super.onReady();
  }

  void _checkHasChange() {
    if (collectionStoryList.length != originalList.length) {
      hasChange = true;
    } else {
      for (int i = 0; i < collectionStoryList.length; i++) {
        if (collectionStoryList[i].news.id != originalList[i].news.id) {
          hasChange = true;
          break;
        } else {
          hasChange = false;
        }
      }
    }
  }

  void createCollection() async {
    isUpdating.value = true;

    try {
      String imageId = await collectionRepos
          .createOgPhoto(
              ogImageUrlOrPath: Get.find<InputTitlePageController>()
                  .collectionOgUrlOrPath
                  .value)
          .timeout(
            const Duration(minutes: 1),
          );
      Collection newCollection = await collectionRepos
          .createCollection(
            title: Get.find<InputTitlePageController>().collectionTitle.value,
            ogImageId: imageId,
            collectionStory: collectionStoryList,
            description: Get.find<DescriptionPageController>()
                .collectionDescription
                .value,
          )
          .timeout(
            const Duration(minutes: 1),
          );

      Get.find<PubsubService>().addCollection(
        memberId: Get.find<UserService>().currentUser.memberId,
        collectionId: newCollection.id,
      );

      Get.lazyPut<PickableItemController>(
        () => PickableItemController(
          targetId: newCollection.id,
          objective: PickObjective.collection,
          controllerTag: newCollection.controllerTag,
        ),
        tag: newCollection.controllerTag,
        fenix: true,
      );
      if (Get.isRegistered<CollectionTabController>(
          tag: Get.find<UserService>().currentUser.memberId)) {
        Get.find<CollectionTabController>(
                tag: Get.find<UserService>().currentUser.memberId)
            .fetchCollecitionList();
      }
      Get.offUntil<GetPageRoute>(
        GetPageRoute(
          routeName: '/CollectionPage',
          page: () => CollectionPage(
            newCollection,
            isNewCollection: true,
          ),
        ),
        (route) {
          return route.settings.name == '/PersonalFilePage' || route.isFirst;
        },
      );
    } catch (e) {
      print('Create collection error: $e');
      isUpdating.value = false;
      Fluttertoast.showToast(
        msg: "建立失敗 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    isUpdating.value = false;
  }

  void updateCollectionPicks() async {
    isUpdating.value = true;
    List<CollectionStory> originItemList = [];
    originItemList.assignAll(originalList);
    List<CollectionStory> addItemList = [];
    List<CollectionStory> moveItemList = [];
    List<CollectionStory> deleteItemList = [];

    for (int i = 0; i < collectionStoryList.length; i++) {
      collectionStoryList[i].sortOrder = i;
      int originListIndex = originItemList.indexWhere(
          (element) => element.news.id == collectionStoryList[i].news.id);
      if (originListIndex == -1) {
        addItemList.add(collectionStoryList[i]);
      } else if (i != originListIndex) {
        moveItemList.add(collectionStoryList[i]);
        originItemList.removeAt(originListIndex);
      } else {
        originItemList.removeAt(originListIndex);
      }
    }

    if (originItemList.isNotEmpty) {
      deleteItemList.assignAll(originItemList);
    }

    List<Future> futureList = [];
    futureList.addIf(
      addItemList.isNotEmpty,
      collectionRepos.createCollectionPicks(
        collection: collection!,
        collectionStory: addItemList,
      ),
    );
    futureList.addIf(
      moveItemList.isNotEmpty,
      collectionRepos.updateCollectionPicksOrder(
        collectionId: collection!.id,
        collectionStory: moveItemList,
      ),
    );
    futureList.addIf(
      deleteItemList.isNotEmpty,
      collectionRepos.removeCollectionPicks(
        collectionStory: deleteItemList,
      ),
    );

    try {
      await Future.wait(futureList);
      await Get.find<CollectionPageController>(tag: collection!.id)
          .fetchCollectionData();
      Get.back();
    } catch (e) {
      print('Update collection picks error: $e');
      Fluttertoast.showToast(
        msg: "更新失敗 請稍後再試",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      isUpdating.value = false;
    }
  }

  void _showDeleteHint() async {
    await showGeneralDialog(
      context: Get.overlayContext!,
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                collectionDeleteHintSvg,
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                '向左滑可以刪除文章',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      GetPlatform.isIOS ? FontWeight.w500 : FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.find<SharedPreferencesService>()
                      .prefs
                      .setBool('firstTimeEditCollection', false);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 20,
                  ),
                  primary: Colors.white,
                ),
                child: const Text(
                  '我知道了',
                  style: TextStyle(
                    fontSize: 16,
                    color: readrBlack87,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
