import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/controller/comment/commentController.dart';
import 'package:readr/controller/comment/commentItemController.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/helpers/themes.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/pages/shared/comment/commentInputBox.dart';
import 'package:readr/pages/shared/comment/commentItem.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CommentBottomSheetWidget extends GetView<CommentController> {
  final Comment clickComment;
  final String controllerTag;
  final String? oldContent;
  final ItemScrollController _itemScrollController = ItemScrollController();

  CommentBottomSheetWidget({
    required this.clickComment,
    required this.controllerTag,
    this.oldContent,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        color: Theme.of(context).backgroundColor,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                color: Theme.of(context).backgroundColor,
                child: Icon(
                  Icons.expand_more_outlined,
                  color:
                      Theme.of(context).extension<CustomColors>()?.primary400,
                  size: 32,
                ),
              ),
            ),
            Flexible(
              child: Obx(
                () {
                  if (controller.isLoading.isTrue) {
                    return const SizedBox(
                      height: 150,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }

                  Timer.periodic(const Duration(microseconds: 1), (timer) {
                    if (_itemScrollController.isAttached) {
                      int index = controller.allComments.indexWhere(
                          (comment) => comment.id == clickComment.id);
                      if (index != -1) {
                        _itemScrollController.scrollTo(
                            index: index,
                            duration: const Duration(
                              microseconds: 1,
                            ));
                        Get.find<CommentItemController>(tag: clickComment.id)
                            .isExpanded(true);
                      } else {
                        Fluttertoast.showToast(
                          msg: "留言好像被刪除了...",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        Get.find<CommunityPageController>()
                            .fetchFollowingStoryAndCollection();
                      }
                      timer.cancel();
                    }
                  });

                  return _buildContent(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                child: Obx(
                  () => ScrollablePositionedList.separated(
                    itemCount: controller.allComments.length,
                    itemScrollController: _itemScrollController,
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return CommentItem(
                        key: ValueKey(controller.allComments[index].id),
                        comment: controller.allComments[index],
                        pickableItemControllerTag: controllerTag,
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      indent: 20,
                      endIndent: 20,
                    ),
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: CommentInputBox(
                commentControllerTag: controllerTag,
                oldContent: oldContent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
