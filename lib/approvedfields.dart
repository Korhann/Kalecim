import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kiralik_kaleci/approvedfield.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class ApprovedFields extends StatefulWidget {
  const ApprovedFields({super.key});

  @override
  State<ApprovedFields> createState() => _ApprovedFieldsState();
}

class _ApprovedFieldsState extends State<ApprovedFields> {

  List<ApprovedField> approvedFields = [];

  late Future<void> getFields;

  @override
  void initState() { 
    super.initState();
    getFields = getApprovedFields();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWithBackButton(
      child: FutureBuilder(
        future: getFields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.only(top: 30),
              child: ApprovedFieldsShimmer()
            );
          }
        return Scaffold(
        appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white : Colors.black),
        ),
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: approvedFields.isEmpty ? const Center(child: CircularProgressIndicator())
      // : ListView.builder(
      //   itemCount: approvedFields.expand((field) => field.fields).length,
      //   itemBuilder: (context, index) {
      //     List<String> allFields = approvedFields.expand((field) => field.fields).toList();
      //     return showCardFields(allFields: allFields, index: index);
      //   },
      // ),
      : Center(child: GlobalStyles.textStyle(text: 'Çok Yakında...', context: context, size: 25, fontWeight: FontWeight.bold, color: Colors.black))
    );
        }
      ) ,
    );
  }
  Future<void> getApprovedFields() async {
    await ApprovedField.approvedFields();
    var localDb = await Hive.openBox<ApprovedField>('approved_fields');
    setState(() {
      approvedFields = localDb.values.toList();
    });
  }
}
class showCardFields extends StatelessWidget {
  final List<String> allFields;
  final int index;
  const showCardFields({
    Key? key,
    required this.allFields,
    required this.index
  });

  @override
  Widget build(BuildContext context) {
    return Card(
            color: userorseller ? sellerbackground : Colors.white,
            child: ListTile(
              title: Text(
                allFields[index],
                textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              ),
              leading: Icon(Icons.sports_soccer_outlined, size: MediaQuery.sizeOf(context).width*0.06,),
            ),
          );
  }
}
