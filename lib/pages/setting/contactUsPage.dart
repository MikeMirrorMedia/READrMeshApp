import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  final String appVersion;
  final String platform;
  final String device;
  const ContactUsPage({
    required this.appVersion,
    required this.platform,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homeScreenBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          '聯絡我們',
          style: TextStyle(
            fontSize: 18,
            color: readrBlack,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: readrBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _introBlock(),
          Divider(
            color: Colors.grey[100],
            thickness: 1,
            height: 1,
          ),
          Container(
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _emailItem(context),
                Divider(
                  color: Colors.grey[100],
                  thickness: 1,
                  height: 1,
                ),
                _phoneItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _introBlock() {
    return Container(
      color: Colors.white,
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          SvgPicture.asset(
            welcomeScreenLogoSvg,
            width: 96,
            height: 40,
          ),
          const SizedBox(
            height: 24,
          ),
          const Text(
            '若有使用上的問題，請將截圖及問題描述寄至客服信箱，或撥打客服電話由專人為您服務\n（服務時間：星期一 ~ 星期五，10:00 ~ 18:00）',
            style: TextStyle(
              fontSize: 14,
              color: readrBlack66,
            ),
          )
        ],
      ),
    );
  }

  Widget _emailItem(BuildContext context) {
    return InkWell(
      onTap: () async {
        String currentTime =
            DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
        EmailContent email = EmailContent(
          to: [
            'readr@readr.tw',
          ],
          subject: 'READr Mesh 客服聯絡',
          body:
              '\n\n\nDate: $currentTime\nApp Version: $appVersion\nPlatform: $platform\nDevice: $device',
        );
        OpenMailAppResult result =
            await OpenMailApp.composeNewEmailInMailApp(emailContent: email);
        if (!result.didOpen && !result.canOpen) {
          showNoMailAppsDialog(context);
        } else if (!result.didOpen && result.canOpen) {
          showCupertinoModalPopup(
            context: context,
            builder: (context) => CupertinoActionSheet(
              actions: [
                for (var app in result.options)
                  CupertinoActionSheetAction(
                    onPressed: () {
                      OpenMailApp.composeNewEmailInSpecificMailApp(
                        mailApp: app,
                        emailContent: email,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      app.name == 'Apple Mail' ? '信件' : app.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                      ),
                    ),
                  ),
              ],
              cancelButton: CupertinoActionSheetAction(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          );
        }
      },
      child: Container(
        color: Colors.white,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '客服信箱',
              style: TextStyle(
                fontSize: 16,
                color: readrBlack87,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              'readr@readr.tw',
              style: TextStyle(
                fontSize: 16,
                color: readrBlack50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text("找不到信件 APP"),
        actions: <Widget>[
          PlatformDialogAction(
            child: const Text("確定"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _phoneItem() {
    return InkWell(
      onTap: () async {
        String url = 'tel:02-6633-3890';
        if (!await launchUrl(Uri.parse(url))) throw 'Could not launch $url';
      },
      child: Container(
        color: Colors.white,
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '客服電話',
              style: TextStyle(
                fontSize: 16,
                color: readrBlack87,
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              '(02) 6633-3890',
              style: TextStyle(
                fontSize: 16,
                color: readrBlack50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}