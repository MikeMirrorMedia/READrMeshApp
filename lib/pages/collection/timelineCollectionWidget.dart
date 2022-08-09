import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readr/controller/collection/collectionPageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/collection.dart';
import 'package:readr/models/timelineStory.dart';
import 'package:readr/pages/collection/shared/timelineItemWidget.dart';

class TimelineCollectionWidget extends GetView<CollectionPageController> {
  final Collection collection;
  const TimelineCollectionWidget(this.collection);

  @override
  String get tag => collection.id;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: collectionBackgroundColor,
      child: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => TimelineItemWidget(
            controller.collectionPicks[index] as TimelineStory,
            previousTimelineStory: index == 0
                ? null
                : controller.collectionPicks[index - 1] as TimelineStory,
          ),
          separatorBuilder: (context, index) => const SizedBox(
            height: 8,
          ),
          itemCount: controller.collectionPicks.length,
        ),
      ),
    );
  }
}
