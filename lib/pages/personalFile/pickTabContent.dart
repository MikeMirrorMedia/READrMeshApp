import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/personalFile/pickTabController.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/personalFile/pickCommentItem.dart';
import 'package:readr/pages/shared/newsListItemWidget.dart';
import 'package:readr/services/commentService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PickTabContent extends GetView<PickTabController> {
  final Member viewMember;
  const PickTabContent({
    required this.viewMember,
  });

  @override
  Widget build(BuildContext context) {
    Get.put(
        PickTabController(PersonalFileService(), CommentService(), viewMember));
    return Obx(
      () {
        if (controller.isError.isTrue) {
          return ErrorPage(
            error: controller.error,
            onPressed: () => controller.fetchPickList(),
            hideAppbar: true,
          );
        } else if (controller.isLoading.isFalse) {
          if (controller.storyPickList.isEmpty) {
            return _emptyWidget();
          }
          return _buildContent();
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget() {
    bool isMine =
        Get.find<UserService>().currentUser.memberId == viewMember.memberId;
    return Container(
      color: homeScreenBackgroundColor,
      child: Center(
        child: Text(
          isMine ? '這裡還空空的\n趕緊將喜愛的新聞加入精選吧' : '這個人還沒有精選新聞',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: readrBlack30,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
          child: const Text(
            '精選文章',
            style: TextStyle(
              color: readrBlack87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildPickStoryList(),
      ],
    );
  }

  Widget _buildPickStoryList() {
    return Obx(
      () => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemBuilder: (context, index) {
          if (index == controller.storyPickList.length) {
            if (controller.isNoMore.isTrue) {
              return Container();
            }

            return VisibilityDetector(
              key: const Key('pickTab'),
              onVisibilityChanged: (visibilityInfo) {
                var visiblePercentage = visibilityInfo.visibleFraction * 100;
                if (visiblePercentage > 50 &&
                    controller.isLoadingMore.isFalse) {
                  controller.fetchMoreStoryPick();
                }
              },
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          var pick = controller.storyPickList[index];

          if (pick.pickComment != null) {
            return Column(
              children: [
                NewsListItemWidget(
                  pick.story!,
                  isInMyPersonalFile: viewMember.memberId ==
                      Get.find<UserService>().currentUser.memberId,
                ),
                const SizedBox(
                  height: 12,
                ),
                PickCommentItem(
                  comment: pick.pickComment!,
                  isMyComment: Get.find<UserService>().currentUser.memberId ==
                      viewMember.memberId,
                  pickControllerTag: pick.story!.controllerTag,
                ),
              ],
            );
          }
          return NewsListItemWidget(
            pick.story!,
            isInMyPersonalFile: viewMember.memberId ==
                Get.find<UserService>().currentUser.memberId,
          );
        },
        separatorBuilder: (context, index) {
          if (index == controller.storyPickList.length - 1) {
            return const SizedBox(
              height: 36,
            );
          }
          return const Padding(
            padding: EdgeInsets.only(top: 16, bottom: 20),
            child: Divider(
              color: readrBlack10,
              thickness: 1,
              height: 1,
            ),
          );
        },
        itemCount: controller.storyPickList.length + 1,
      ),
    );
  }
}
