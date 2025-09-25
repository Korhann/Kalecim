
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class Showalert {
  final BuildContext context;
  final String text;

  Showalert({required this.context, required this.text});

  Future<void> showSuccessAlert() async{
    QuickAlert.show(
      context: context,
      text: text,
      type: QuickAlertType.success,
      confirmBtnText: 'Tamam',
      title: 'Başarılı',
    );
  }
  Future<void> showErrorAlert() async{
    QuickAlert.show(context: context, text: text,type: QuickAlertType.error,confirmBtnText: 'Tamam',title: 'Bir şeyler ters gitti');
  }
void showUpgradeAlert() async {
  QuickAlert.show(
    context: context,
    barrierDismissible: false,
    text: text,
    type: QuickAlertType.info,
    confirmBtnText: 'Güncelle',
    title: 'Yeni bir sürüm mevcut',
    onConfirmBtnTap: () async {
      const appStoreUrl = 'https://apps.apple.com/app/idYOUR_APP_ID'; // Replace with your real App Store URL
      if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
        await launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
      }
    },
  );
}
}