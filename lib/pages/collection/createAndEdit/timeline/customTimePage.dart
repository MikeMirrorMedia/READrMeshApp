import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:readr/controller/collection/createAndEdit/editTimelinePageController.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/timelineCollectionPick.dart';
import 'package:readr/pages/collection/createAndEdit/collectionStoryItem.dart';

enum TimeLevel {
  year,
  month,
  day,
  time,
}

class CustomTimePage extends GetView<EditTimelinePageController> {
  final TimelineCollectionPick timelineStory;
  const CustomTimePage(this.timelineStory);

  @override
  Widget build(BuildContext context) {
    controller.year.value = timelineStory.customYear!;
    controller.month.value = timelineStory.customMonth;
    controller.day.value = timelineStory.customDay;
    controller.time.value = timelineStory.customTime;
    controller.sectionTitleController.text = timelineStory.summary ?? '';

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: meshGray,
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0.5,
          leadingWidth: 75,
          leading: TextButton(
            child: Text(
              'cancel'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 18,
                color: readrBlack50,
              ),
            ),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'customTime'.tr,
            style: const TextStyle(
              fontSize: 18,
              color: readrBlack,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'save'.tr,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                timelineStory.customYear = controller.year.value;
                timelineStory.customMonth = controller.month.value;
                timelineStory.customDay = controller.day.value;
                timelineStory.customTime = controller.time.value;
                if (controller.sectionTitleController.text.isNotEmpty) {
                  timelineStory.summary =
                      controller.sectionTitleController.text;
                } else {
                  timelineStory.summary = null;
                }

                int itemIndex = controller.timelineStoryList.indexWhere(
                    (element) => element.news.id == timelineStory.news.id);
                controller.timelineStoryList[itemIndex] = timelineStory;
                controller.sortListByTime();
                controller.timelineStoryList.refresh();

                Get.back();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(
              parent: NeverScrollableScrollPhysics()),
          child: Column(
            children: [
              _customTimeBlock(context),
              _sectionTitleBlock(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customTimeBlock(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        border: Border.all(
          color: const Color.fromRGBO(218, 220, 227, 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: CollectionStoryItem(
              timelineStory.news,
              inCustomTime: true,
            ),
          ),
          const Divider(
            color: Color.fromRGBO(218, 220, 227, 1),
            thickness: 1,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: _buildButton(context, TimeLevel.year),
          ),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: _buildButton(context, TimeLevel.month)),
                const SizedBox(
                  width: 20,
                ),
                Flexible(child: _buildButton(context, TimeLevel.day)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: _buildButton(context, TimeLevel.time),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitleBlock(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
        border: Border.all(
          color: const Color.fromRGBO(218, 220, 227, 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'blockTitle'.tr,
            style: const TextStyle(
              fontSize: 16,
              color: readrBlack87,
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            'blockTitleDescription'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: readrBlack50,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Obx(
            () => TextField(
              controller: controller.sectionTitleController,
              focusNode: controller.sectionTitleFocusNode,
              style: const TextStyle(
                fontSize: 16,
                color: readrBlack87,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  bottom: 8,
                ),
                hintText: 'blockTitleHint'.tr,
                hintStyle: const TextStyle(
                  color: readrBlack30,
                  fontSize: 16,
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: readrBlack66,
                  ),
                ),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white10,
                  ),
                ),
                suffix: (controller.showClearTextButton.isFalse)
                    ? null
                    : GestureDetector(
                        onTap: () {
                          controller.sectionTitleController.clear();
                          controller.showClearTextButton.value = false;
                        },
                        child: const Icon(
                          Icons.cancel,
                          color: readrBlack87,
                          size: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, TimeLevel level) {
    String label;
    switch (level) {
      case TimeLevel.year:
        label = 'year'.tr;
        break;
      case TimeLevel.month:
        label = 'month'.tr;
        break;
      case TimeLevel.day:
        label = 'date'.tr;
        break;
      case TimeLevel.time:
        label = 'time'.tr;
        break;
    }
    return Obx(
      () {
        bool isActive = true;
        String contentText;
        switch (level) {
          case TimeLevel.year:
            contentText = controller.year.value.toString();
            break;
          case TimeLevel.month:
            contentText = controller.month.value?.toString() ?? '';
            break;
          case TimeLevel.day:
            contentText = controller.day.value?.toString() ?? '';
            if (controller.month.value == null) {
              isActive = false;
              contentText = 'selectMonthFirst'.tr;
            }
            break;
          case TimeLevel.time:
            if (controller.day.value == null) {
              isActive = false;
              contentText = 'selectMonthAndDateFirst'.tr;
            } else if (controller.time.value == null) {
              contentText = '';
            } else {
              contentText = DateFormat('HH:mm').format(controller.time.value!);
            }
            break;
        }
        return GestureDetector(
          onTap: () async {
            FocusManager.instance.primaryFocus?.unfocus();
            if (isActive) {
              await _showPicker(context, level);
            }
          },
          child: Container(
            width: double.maxFinite,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : const Color(0xffE0E0E0),
              border: const Border(
                bottom: BorderSide(color: readrBlack10),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isActive ? readrBlack87 : readrBlack20,
                  ),
                ),
                const Spacer(),
                Text(
                  contentText,
                  style: TextStyle(
                    fontSize: 16,
                    color: isActive ? readrBlack87 : readrBlack20,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(
                  width: 3,
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 13,
                  color: isActive ? readrBlack30 : readrBlack20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPicker(
    BuildContext context,
    TimeLevel level,
  ) async {
    String title;
    Widget picker;
    List<int> timeRange = [];
    int chooseIndex = 0;
    Function()? clear;
    Function()? set;
    switch (level) {
      case TimeLevel.year:
        title = 'selectYear'.tr;
        timeRange = List<int>.generate(1031, (index) => 1970 + index);
        set = () => controller.year.value = timeRange[chooseIndex];
        chooseIndex =
            timeRange.indexWhere((element) => element == controller.year.value);
        break;
      case TimeLevel.month:
        title = 'selectMonth'.tr;
        timeRange = List<int>.generate(12, (index) => 1 + index);
        set = () => controller.month.value = timeRange[chooseIndex];
        clear = () {
          controller.month.value = null;
          controller.day.value = null;
          controller.time.value = null;
        };
        if (controller.month.value != null) {
          chooseIndex = timeRange
              .indexWhere((element) => element == controller.month.value);
        }
        break;
      case TimeLevel.day:
        title = 'selectDate'.tr;
        timeRange = List<int>.generate(
            DateTime(controller.year.value, controller.month.value! + 1, 0).day,
            (index) => 1 + index);
        set = () => controller.day.value = timeRange[chooseIndex];
        clear = () {
          controller.day.value = null;
          controller.time.value = null;
        };
        if (controller.day.value != null) {
          chooseIndex = timeRange
              .indexWhere((element) => element == controller.day.value);
        }
        break;
      case TimeLevel.time:
        title = 'selectTime'.tr;
        clear = () => controller.time.value = null;
        break;
    }

    if (level == TimeLevel.time) {
      List<int> hour = List<int>.generate(24, (index) => index);
      List<int> minutes = List<int>.generate(60, (index) => index);
      int hourIndex = 0;
      int minutesIndex = 0;
      set = () => controller.time.value = DateTime(
            controller.year.value,
            controller.month.value!,
            controller.day.value!,
            hour[hourIndex],
            minutes[minutesIndex],
          );
      if (controller.time.value != null) {
        hourIndex = hour
            .indexWhere((element) => element == controller.time.value!.hour);
        minutesIndex = minutes
            .indexWhere((element) => element == controller.time.value!.minute);
      }
      picker = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: CupertinoPicker.builder(
              itemExtent: 35,
              onSelectedItemChanged: (index) => hourIndex = index,
              scrollController:
                  FixedExtentScrollController(initialItem: hourIndex),
              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                background: readrBlack10,
              ),
              itemBuilder: (context, index) {
                String text;
                if (hour[index] < 10) {
                  text = '0${hour[index].toString()}';
                } else {
                  text = hour[index].toString();
                }
                return Text(
                  text,
                  style: const TextStyle(
                    fontSize: 23,
                    color: readrBlack87,
                  ),
                );
              },
              childCount: hour.length,
            ),
          ),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 30,
              color: readrBlack,
            ),
          ),
          Expanded(
            child: CupertinoPicker.builder(
              itemExtent: 35,
              onSelectedItemChanged: (index) => minutesIndex = index,
              scrollController:
                  FixedExtentScrollController(initialItem: minutesIndex),
              selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                background: readrBlack10,
              ),
              itemBuilder: (context, index) {
                String text;
                if (minutes[index] < 10) {
                  text = '0${minutes[index].toString()}';
                } else {
                  text = minutes[index].toString();
                }
                return Text(
                  text,
                  style: const TextStyle(
                    fontSize: 23,
                    color: readrBlack87,
                  ),
                );
              },
              childCount: minutes.length,
            ),
          ),
        ],
      );
    } else {
      picker = CupertinoPicker.builder(
        itemExtent: 35,
        onSelectedItemChanged: (index) => chooseIndex = index,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          background: readrBlack10,
        ),
        scrollController: FixedExtentScrollController(initialItem: chooseIndex),
        itemBuilder: (context, index) => Text(
          timeRange[index].toString(),
          style: const TextStyle(
            fontSize: 23,
            color: readrBlack87,
          ),
        ),
        childCount: timeRange.length,
      );
    }

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(6.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              child: AppBar(
                toolbarHeight: 52,
                centerTitle: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: level == TimeLevel.year
                    ? null
                    : TextButton(
                        onPressed: () {
                          if (clear != null) {
                            clear();
                          }
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          'clear'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: readrBlack,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (set != null) {
                        set();
                      }
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      alignment: Alignment.centerRight,
                    ),
                    child: Text(
                      'setUp'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 216,
              child: picker,
            ),
          ],
        ),
      ),
    );
  }
}