import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:readr/helpers/dataConstants.dart';

class CollectionDeletedPage extends StatelessWidget {
  const CollectionDeletedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: GetPlatform.isIOS,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'collection'.tr,
          style: const TextStyle(
            fontSize: 18,
            color: readrBlack,
          ),
        ),
      ),
      backgroundColor: homeScreenBackgroundColor,
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(collectionDeletedSvg),
            const SizedBox(
              height: 20,
            ),
            Text(
              'collectionDeletedTitle'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: readrBlack87,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              'collectionDeletedDescription'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: readrBlack66,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
