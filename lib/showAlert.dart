
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

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
  void showErrorAlert() {
    QuickAlert.show(context: context, text: text,type: QuickAlertType.error,confirmBtnText: 'Tamam',title: 'Bir şeyler ters gitti');
  }
}