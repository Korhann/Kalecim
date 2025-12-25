import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
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
      const appStoreUrl = 'https://apps.apple.com/tr/app/kalecim/id6749082384?l=tr';
      if (await canLaunchUrl(Uri.parse(appStoreUrl))) {
        await launchUrl(Uri.parse(appStoreUrl), mode: LaunchMode.externalApplication);
      }
    },
    );
  }
  Future<void> navigateAlert() async{
    QuickAlert.show(
      context: context, 
      text: text,
      type: QuickAlertType.warning,
      confirmBtnText: 'Tamam',
      cancelBtnText: 'Vazgeç',
      title: 'İlan oluşturun',
      onConfirmBtnTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellerAddPage()));
      },
    );
  }
}