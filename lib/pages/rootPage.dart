import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/pages/community/communityPage.dart';
import 'package:readr/pages/latest/latestPage.dart';
import 'package:readr/pages/personalFile/personalFilePage.dart';
import 'package:readr/pages/personalFile/visitorPersonalFile.dart';
import 'package:readr/pages/readr/readrPage.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:upgrader/upgrader.dart';

class RootPage extends GetView<RootPageController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RootPageController>(
      builder: (controller) {
        if (controller.isInitialized) {
          return UpgradeAlert(
            upgrader: Upgrader(
              minAppVersion: controller.minAppVersion,
              messages: UpdateMessages(),
              dialogStyle: Platform.isAndroid
                  ? UpgradeDialogStyle.material
                  : UpgradeDialogStyle.cupertino,
            ),
            child: _buildBody(context),
          );
        }
        return Container(
          color: const Color.fromRGBO(4, 13, 44, 1),
          child: Image.asset(
            splashIconPng,
            scale: 4,
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    List<Widget> bodyList = [
      CommunityPage(),
      LatestPage(),
      ReadrPage(),
      Obx(
        () {
          if (Get.find<UserService>().isMember.isTrue) {
            return PersonalFilePage(
              viewMember: Get.find<UserService>().currentUser,
              isFromBottomTab: true,
            );
          }

          return const VisitorPersonalFile();
        },
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          elevation: 10,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          currentIndex: controller.tabIndex.value,
          onTap: (index) => controller.changeTabIndex(index),
          selectedItemColor: bottomNavigationBarSelectedColor,
          unselectedItemColor: bottomNavigationBarUnselectedColor,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const SizedBox(
                height: 24,
                child: Icon(CupertinoIcons.bubble_left_bubble_right),
              ),
              activeIcon: const SizedBox(
                height: 24,
                child: Icon(CupertinoIcons.bubble_left_bubble_right_fill),
              ),
              label: 'communityTab'.tr,
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: SvgPicture.asset(
                  latestPageDefaultSvg,
                  width: 23,
                  height: 20,
                ),
              ),
              activeIcon: SizedBox(
                height: 24,
                child: SvgPicture.asset(
                  latestPageActiveSvg,
                  width: 23,
                  height: 20,
                ),
              ),
              label: 'latestTab'.tr,
            ),
            BottomNavigationBarItem(
              icon: Container(
                height: 24,
                margin: const EdgeInsets.only(bottom: 1.5),
                child: SvgPicture.asset(
                  readrPageDefaultSvg,
                  width: 22,
                  height: 22,
                ),
              ),
              activeIcon: Container(
                height: 24,
                margin: const EdgeInsets.only(bottom: 1.5),
                child: SvgPicture.asset(
                  readrPageActiveSvg,
                  width: 22,
                  height: 22,
                ),
              ),
              label: 'READr',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                height: 24,
                child: Obx(
                  () {
                    if (Get.find<UserService>().isMember.isFalse) {
                      return const Icon(
                        CupertinoIcons.person_solid,
                        size: 20,
                        color: readrBlack87,
                      );
                    } else {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfilePhotoWidget(
                            Get.find<UserService>().currentUser,
                            11,
                            hideBorder: true,
                          ),
                          Obx(
                            () {
                              if (controller.haveNewFeature.isTrue) {
                                return Container(
                                  width: 12,
                                  height: 12,
                                  margin: const EdgeInsets.only(
                                    left: 14,
                                    bottom: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
              label: 'personalFileTab'.tr,
            ),
          ],
        ),
      ),
      body: Obx(
        () => bodyList[controller.tabIndex.value],
      ),
    );
  }
}
