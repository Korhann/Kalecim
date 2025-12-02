import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class ShareGigPage extends StatefulWidget {
  const ShareGigPage({super.key});

  @override
  State<ShareGigPage> createState() => _ShareGigPageState();
}

class _ShareGigPageState extends State<ShareGigPage> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  String? selectedDay;
  String? selectedHour;

  Days? selectedDayEnum;
  HourSlot? selectedHourEnum;

  TextEditingController nameController = TextEditingController();
  bool showErrorName = false;

  TextEditingController provinceController = TextEditingController();
  bool showErrorProvince = false;

  TextEditingController districtController = TextEditingController();
  bool showErrorDistrict = false;

  TextEditingController fieldController = TextEditingController();
  bool showErrorField = false;

  TextEditingController priceController = TextEditingController();
  bool showErrorPrice = false;

  @override
  void initState() { 
    super.initState();
    // checkIf24HoursPassed();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    // bütün textfieldlara sadece text girilebilsin

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: GlobalStyles.textStyle(
            text: 'İlan ver',
            context: context,
            size: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        backgroundColor: background,
        centerTitle: true,
      ),
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      child: Center(
                        child: Text(
                          'İlan verin, kaleciler başvursun!\nMaç bilgilerinizi paylaşın, teklif alın.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // isim soyisim bilgisi
                NameText(),
                SizedBox(height: height * 0.01),
                NameField(
                    controller: nameController, showErrorName: showErrorName),
                SizedBox(height: height * 0.03),

                // gün bilgisi
                DayText(),
                SizedBox(height: height * 0.01),
                DayField(
                  selectedDay: selectedDayEnum,
                  onDaySelected: (value) {
                    selectedDayEnum = value;
                    selectedDay = value?.label;
                  },
                ),
                SizedBox(height: height * 0.03),

                // saat bilgisi
                HourText(),
                SizedBox(height: height * 0.01),
                HourPicker(
                  selectedHour: selectedHourEnum,
                  onHourSelected: (value) {
                    selectedHourEnum = value;
                    selectedHour = value?.label;
                  },
                ),
                SizedBox(height: height * 0.03),

                // il bilgisi
                ProvinceText(),
                SizedBox(height: height * 0.01),
                ProvinceField(
                    controller: provinceController,
                    showErrorProvince: showErrorProvince),
                SizedBox(height: height * 0.03),

                // ilçe bilgisi
                DistrictText(),
                SizedBox(height: height * 0.01),
                DistrictField(
                    controller: districtController,
                    showErrorDistrict: showErrorDistrict),
                SizedBox(height: height * 0.03),

                // halısaha bilgisi
                FieldText(),
                SizedBox(height: height * 0.01),
                FieldInfo(
                    controller: fieldController,
                    showErrorField: showErrorField),
                SizedBox(height: height * 0.03),

                // fiyat bilgisi
                PriceText(),
                SizedBox(height: height * 0.01),
                PriceField(
                  controller: priceController,
                  showErrorPrice: showErrorPrice),
                SizedBox(height: height * 0.03),

                // Onayla butonu
                Center(
                  child: ElevatedButton(
                    style: GlobalStyles.buttonPrimary(context),
                    onPressed: () async {
                      try {
                        if (await InternetConnection().hasInternetAccess) {
                          await _insertUserGig();
                        } else {
                          if (mounted) {
                            Showalert(context: context, text: 'Ooops...').showErrorAlert();
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          Showalert(context: context, text: 'Tüm alanları doldurduğunuza emin misiniz?').showErrorAlert();
                        }
                      }
                    }, 
                    child: GlobalStyles.textStyle(text: 'Onayla', context: context, size: 24, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _insertUserGig() async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collectionReference = _firestore.collection('Users');
    try {
    Map<String,dynamic> gigInfo = {
      'name': nameController.text,
      'day': selectedDay,
      'hour': selectedHour,
      'province': provinceController.text,
      'district': districtController.text,
      'field': fieldController.text,
      'price': priceController.text,
      'timestamp': DateTime.now().toUtc()
    };

    if (_formKey.currentState!.validate()) {
      // todo: buraya 24 saat geçmeden yeni ilan veremezsiniz diye bir alan koyucam
      bool dayPassed = await checkIf24HoursPassed();
      // bir gün geçmiş mi diye kontrol ediyor
      if (dayPassed == false) {
        Showalert(context: context, text: 'Yeni ilan için 24 saat geçmesi gerekmektedir').showErrorAlert();
      } else {
        await collectionReference.doc(currentUserUid).collection('userGig').add({
          'userGig': gigInfo
        });
      
      Showalert(context: context, text: 'İlan başarı ile gönderlimiştir').showSuccessAlert();
      clearAllFields();
      }
    } else {
      Showalert(context: context, text: 'Tüm alanları doldurduğunuza emin misiniz!').showErrorAlert();
    }
    } catch (e) {
      if (mounted) {
        Showalert(context: context, text: 'Ooops...').showErrorAlert();
      }
    }
  }

  Future<bool> checkIf24HoursPassed() async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    DateTime? gigTime;
    DateTime? now;
    try {
      // db den önceki olan gig i al ve time stamp bak
      QuerySnapshot<Map<String,dynamic>> userGigDoc = await _firestore.collection('Users').doc(currentUserUid).collection('userGig').get();
      if (userGigDoc.docs.isEmpty){return true;}
      for (final doc in userGigDoc.docs) {
        Map<String,dynamic> gigdetails = doc.data();
        if (gigdetails.isNotEmpty && gigdetails.containsKey('userGig')) {
          final userGig = gigdetails['userGig'] as Map<String,dynamic>;
          final ts = userGig['timestamp'];
          // 24 saat geçmiş mi diye bak öyle döndür
          if (ts != null && ts is Timestamp) {
            gigTime = ts.toDate();
            now = DateTime.now().toUtc();
            final difference = now.difference(gigTime);
            print('difference is $difference');
            return difference.inHours >= 24;
          }
        }
      }
    } catch (e) {
      print('Error is $e');
    }
    return true;
  }

  void clearAllFields() {
    if (mounted) {
      setState(() {
        nameController.clear();
        selectedDayEnum = null;
        selectedHourEnum = null;
        selectedDay = null;
        selectedHour = null;
        provinceController.clear();
        districtController.clear();
        fieldController.clear();
        priceController.clear();
      });
    }
  }
}

class NameText extends StatelessWidget {
  const NameText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'Ad Soyad',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final bool showErrorName;
  const NameField(
      {required this.controller, required this.showErrorName, super.key});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        validator: (name) {
          if (name == null || name.isEmpty) {
            return "Boş Bırakılamaz !";
          }
          return null;
        },
        style: GoogleFonts.inter(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(
            hintText: 'Ad Soyad', showError: showErrorName));
  }
}


class DayText extends StatelessWidget {
  const DayText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'Gün Seçiniz',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

enum Days {
  d1('Pazartesi'),
  d2('Salı'),
  d3('Çarşamba'),
  d4('Perşembe'),
  d5('Cuma'),
  d6('Cumartesi'),
  d7('Pazar');

  final String label;
  const Days(this.label);
}

class DayField extends StatefulWidget {
  final Days? selectedDay;
  final ValueChanged<Days?> onDaySelected;
  const DayField({super.key, required this.selectedDay ,required this.onDaySelected});

  @override
  State<DayField> createState() => _DayFieldState();
}

class _DayFieldState extends State<DayField> {
  Days? selectedDay;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Days>(
      value: widget.selectedDay,
      items: Days.values.map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text(day.label),
        );
      }).toList(),
      onChanged: widget.onDaySelected,
      validator: (value) {
        if (value == null) {
          return 'Gün seçmelisiniz!';
        }
        return null;
      },
      decoration: InputDecoration(labelText: 'Gün Seçiniz', border: OutlineInputBorder()),
    );
  }
}

enum HourSlot {
  h18_19('18:00-19:00'),
  h19_20('19:00-20:00'),
  h20_21('20:00-21:00'),
  h21_22('21:00-22:00'),
  h22_23('22:00-23:00'),
  h23_00('23:00-00:00'),
  h00_01('00:00-01:00'),
  h01_02('01:00-02:00');

  final String label;
  const HourSlot(this.label);
}

class HourText extends StatelessWidget {
  const HourText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'Saatler',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

class HourPicker extends StatefulWidget {
  final HourSlot? selectedHour;
  final ValueChanged<HourSlot?> onHourSelected;
  const HourPicker({super.key,required this.selectedHour ,required this.onHourSelected});

  @override
  State<HourPicker> createState() => _HourPickerState();
}

class _HourPickerState extends State<HourPicker> {
  HourSlot? selectedHour;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<HourSlot>(
      value: widget.selectedHour,
      items: HourSlot.values.map((hour) {
        return DropdownMenuItem(
          value: hour,
          child: Text(hour.label),
        );
      }).toList(),
      onChanged: widget.onHourSelected,
      validator: (value) {
        if (value == null) {
          return 'Saat seçmelisiniz!';
        }
        return null;
      },
      decoration: InputDecoration(labelText: 'Saatler', border: OutlineInputBorder()),
    );
  }
}

class ProvinceText extends StatelessWidget {
  const ProvinceText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'İl',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

class ProvinceField extends StatelessWidget {
  final TextEditingController controller;
  final bool showErrorProvince;
  const ProvinceField(
      {super.key, required this.controller, required this.showErrorProvince});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        validator: (province) {
          if (province == null || province.isEmpty) {
            return "Boş Bırakılamaz !";
          }
          return null;
        },
        style: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(hintText: 'İl', showError: showErrorProvince));
  }
}

class DistrictText extends StatelessWidget {
  const DistrictText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'İlçe',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

class DistrictField extends StatelessWidget {
  final TextEditingController controller;
  final bool showErrorDistrict;
  const DistrictField(
      {super.key, required this.controller, required this.showErrorDistrict});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        validator: (district) {
          if (district == null || district.isEmpty) {
            return "Boş Bırakılamaz !";
          }
          return null;
        },
        style: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(hintText: 'İlçe', showError: showErrorDistrict));
  }
}

class FieldText extends StatelessWidget {
  const FieldText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'Halı Saha',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

class FieldInfo extends StatelessWidget {
  final TextEditingController controller;
  final bool showErrorField;
  const FieldInfo(
      {super.key, required this.controller, required this.showErrorField});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        validator: (field) {
          if (field == null || field.isEmpty) {
            return "Boş Bırakılamaz !";
          }
          return null;
        },
        style: GoogleFonts.inter(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(hintText: 'Halı Saha', showError: showErrorField));
  }
}

class PriceText extends StatelessWidget {
  const PriceText({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalStyles.textStyle(
        text: 'Fiyat',
        context: context,
        size: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black);
  }
}

class PriceField extends StatelessWidget {
  final TextEditingController controller;
  final bool showErrorPrice;
  const PriceField({super.key, required this.controller, required this.showErrorPrice});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onTapOutside: (e) => FocusScope.of(context).unfocus(),
      keyboardType: TextInputType.number,
      maxLines: null,
      textInputAction: TextInputAction.done,
      validator: (price) {
        if (price == null || price.isEmpty) {
          return "Fiyat bilgisi girmelisiniz!";
        }
        final value = int.tryParse(price);
        if (value == null) {
          return 'Fiyat bilgisi girmelisiniz';
        }
        if (value < 250) {
          return "Fiyat 250 TL'den az olamaz!";
        } else {
          return null;
        }
      },
      style: GoogleFonts.inter(color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          suffixText: 'TL',
          suffixStyle: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }
}
