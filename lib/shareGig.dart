// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/showRequestsRecieved.dart';
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
  String? docIdToUpdate;

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

  String currentuser = FirebaseAuth.instance.currentUser!.uid;
  late String docId;

  Stream<QuerySnapshot> gigStream() {
    return _firestore
        .collection('Users')
        .doc(currentuser)
        .collection('userGig')
        .snapshots();
  }

  Stream<QuerySnapshot> gigRequestersStream() {
    return _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('userGig')
      .doc(docId)
      .collection('requests')
      .snapshots();
  }

  Future<bool> checkIfUserHasGig() async {
    try {
      final gigSnapshot = await _firestore
          .collection('Users')
          .doc(currentuser)
          .collection('userGig')
          .get();

      if (gigSnapshot.docs.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking the gig $e');
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    //todo: eğer ilan sayfanın içindeyken silinmiş ise boş bir sayfa gösteriyor çöz
    return FutureBuilder<bool>(
        future: checkIfUserHasGig(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu'));
          }
          final hasGig = snapshot.data ?? false;
          if (hasGig) {
            return ConnectivityWithBackButton(
              child: StreamBuilder<QuerySnapshot>(
                  stream: gigStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: ShareGigViewShimmer(),
                      );
                    }
                    final gigs = snapshot.data!.docs;
                    return Scaffold(
                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        title: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: GlobalStyles.textStyle(
                            text: 'İlanınız',
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
                      body: ListView.builder(
                        itemCount: gigs.length,
                        itemBuilder: (context, index) {
                          final gigData = gigs[index].data() as Map<String, dynamic>;
                          docId = gigs[index].id;

                          final day = gigData['userGig']['day'];
                          final district = gigData['userGig']['district'];
                          final field = gigData['userGig']['field'];
                          final hour = gigData['userGig']['hour'];
                          final name = gigData['userGig']['name'];
                          final price = gigData['userGig']['price'];
                          final province = gigData['userGig']['province'];
                          final gigOwner = gigData['userGig']['gigOwner'];

                          // todo: aşşağıdaki kısımları gigRequester için alınıcak
                          return StreamBuilder<QuerySnapshot>(
                            stream: gigRequestersStream(),
                            builder: (context, requestSnapshot) {
                              if (!requestSnapshot.hasData) {
                                return const SizedBox();
                              }
                              final requests = requestSnapshot.data!.docs;
                              final requesterLength = requests.length;

                              final gigRequesters = requests.map((doc) {
                                final data = doc.data() as Map<String,dynamic>;
                                final requestsData = data['requestFromKeeper'];
                                return {
                                  'requestId': doc.id,
                                  'fullName': requestsData['fullName'],
                                  'paymentStatus': requestsData['paymentstatus'],
                                  'status': requestsData['status'],
                                  'timestamp': requestsData['timestamp'],
                                  'uid': requestsData['uid'],
                                };
                              }).toList();
                              return GigView(
                                day: day,
                                district: district,
                                field: field,
                                name: name,
                                hour: hour,
                                province: province,
                                price: price,
                                gigOwner: gigOwner,
                                gigRequesters: gigRequesters,
                                requesterLength: requesterLength,
                                docId: docId,
                              );
                            }
                          );
                        },
                      ),
                    );
                  }),
            );
          } else {
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
                                  // ignore: deprecated_member_use
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
                            controller: nameController,
                            showErrorName: showErrorName),
                        SizedBox(height: height * 0.03),

                        // gün bilgisi
                        DayText(),
                        SizedBox(height: height * 0.01),
                        DayField(
                          selectedDay: selectedDayEnum,
                          onDaySelected: (value) {
                            setState(() {
                              selectedDayEnum = value;
                              selectedDay = value?.label;
                            });
                          },
                        ),
                        SizedBox(height: height * 0.03),

                        // saat bilgisi
                        HourText(),
                        SizedBox(height: height * 0.01),
                        HourPicker(
                          selectedHour: selectedHourEnum,
                          onHourSelected: (value) {
                            setState(() {
                              selectedHourEnum = value;
                              selectedHour = value?.label;
                            });
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
                                if (await InternetConnection()
                                    .hasInternetAccess) {
                                  await _insertUserGig();
                                } else {
                                  if (mounted) {
                                    Showalert(context: context, text: 'Ooops...')
                                        .showErrorAlert();
                                  }
                                }
                              } catch (e) {
                                if (mounted) {
                                  Showalert(
                                          context: context,
                                          text:
                                              'Tüm alanları doldurduğunuza emin misiniz?')
                                      .showErrorAlert();
                                }
                              }
                            },
                            child: GlobalStyles.textStyle(
                                text: 'Onayla',
                                context: context,
                                size: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }

  Future<void> _insertUserGig() async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference collectionReference = _firestore.collection('Users');
    try {
      Map<String, dynamic> gigInfo = {
        'name': nameController.text,
        'day': selectedDay,
        'hour': selectedHour,
        'province': provinceController.text,
        'district': districtController.text,
        'field': fieldController.text,
        'price': priceController.text,
        'gigOwner': currentUserUid,
        'timestamp': DateTime.now().toUtc(),
        'requestSenderUids': []
      };

      if (_formKey.currentState!.validate()) {
        bool dayPassed = await checkIf24HoursPassed();
        // bir gün geçmiş mi diye kontrol ediyor
        if (dayPassed == false) {
          Showalert(context: context, text: 'Yeni ilan için 24 saat geçmesi gerekmektedir').showErrorAlert();
          clearAllFields();
        } else {
          await collectionReference
              .doc(currentUserUid)
              .collection('userGig')
              .doc(docIdToUpdate)
              .set({'userGig': gigInfo});

          Showalert(context: context, text: 'İlan başarı ile gönderlimiştir')
              .showSuccessAlert();
          clearAllFields();
        }
      } else {
        Showalert(
                context: context,
                text: 'Tüm alanları doldurduğunuza emin misiniz!')
            .showErrorAlert();
      }
    } catch (e) {
      if (mounted) {
        Showalert(context: context, text: 'Ooops...').showErrorAlert();
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  Future<bool> checkIf24HoursPassed() async {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    DateTime? gigTime;
    DateTime? now;
    try {
      // db den önceki olan gig i al ve time stamp bak
      QuerySnapshot<Map<String, dynamic>> userGigDoc = await _firestore
          .collection('Users')
          .doc(currentUserUid)
          .collection('userGig')
          .get();
      if (userGigDoc.docs.isEmpty) {
        return true;
      }
      for (final doc in userGigDoc.docs) {
        docIdToUpdate = doc.id;
        Map<String, dynamic> gigdetails = doc.data();
        if (gigdetails.isNotEmpty && gigdetails.containsKey('userGig')) {
          final userGig = gigdetails['userGig'] as Map<String, dynamic>;
          final ts = userGig['timestamp'];
          // 24 saat geçmiş mi diye bak öyle döndür
          if (ts != null && ts is Timestamp) {
            gigTime = ts.toDate();
            now = DateTime.now().toUtc();
            final difference = now.difference(gigTime);
            return difference.inHours >= 24;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error is $e');
      }
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

class DayField extends StatelessWidget {
  final Days? selectedDay;
  final ValueChanged<Days?> onDaySelected;
  const DayField(
      {super.key, required this.selectedDay, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Days>(
      value: selectedDay,
      items: Days.values.map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text(day.label),
        );
      }).toList(),
      onChanged: onDaySelected,
      validator: (value) {
        if (value == null) {
          return 'Gün seçmelisiniz!';
        }
        return null;
      },
      decoration: InputDecoration(
          labelText: 'Gün Seçiniz', border: OutlineInputBorder()),
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

class HourPicker extends StatelessWidget {
  final HourSlot? selectedHour;
  final ValueChanged<HourSlot?> onHourSelected;
  const HourPicker(
      {super.key, required this.selectedHour, required this.onHourSelected});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<HourSlot>(
      value: selectedHour, // Use parent's value
      items: HourSlot.values.map((hour) {
        return DropdownMenuItem(
          value: hour,
          child: Text(hour.label),
        );
      }).toList(),
      onChanged: onHourSelected,
      validator: (value) {
        if (value == null) {
          return 'Saat seçmelisiniz!';
        }
        return null;
      },
      decoration:
          InputDecoration(labelText: 'Saatler', border: OutlineInputBorder()),
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
        style: GoogleFonts.inter(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(
            hintText: 'İl', showError: showErrorProvince));
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
        style: GoogleFonts.inter(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(
            hintText: 'İlçe', showError: showErrorDistrict));
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
        style: GoogleFonts.inter(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.w300),
        decoration: GlobalStyles.inputDecoration1(
            hintText: 'Halı Saha', showError: showErrorField));
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
  const PriceField(
      {super.key, required this.controller, required this.showErrorPrice});

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
      style: GoogleFonts.inter(
          color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          suffixText: 'TL',
          suffixStyle: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black)),
    );
  }
}

class GigView extends StatelessWidget {
  final String day;
  final String district;
  final String field;
  final String hour;
  final String name;
  final String price;
  final String province;
  final String gigOwner;
  final int requesterLength;
  final List<dynamic> gigRequesters;
  final String docId;
  const GigView({
      super.key,
      required this.day,
      required this.district,
      required this.field,
      required this.hour,
      required this.name,
      required this.price,
      required this.province,
      required this.gigOwner,
      required this.requesterLength,
      required this.gigRequesters,
      required this.docId,
    });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sports_soccer, color: Colors.blueGrey, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    field,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (requesterLength > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.remove_red_eye_sharp, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '$requesterLength',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$price ₺',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  day,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                const SizedBox(width: 18),
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  hour,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
              ],
            ),
            SizedBox(height: height * 0.010),
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.red[400]),
                const SizedBox(width: 6),
                Text(
                  '$province, $district',
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
              ],
            ),
            // SizedBox(height: height * 0.010),
            Row(
              children: [
                Icon(Icons.person, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  name,
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // todo: Eğer istek yoksa ok çıkmayacak
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RequestsReceived(
                          gigRequesters: gigRequesters,
                          docId: docId,
                          selectedDay: day,
                          selectedHour: hour,
                          selectedField: field,
                          selectedPrice:price
                        )
                      )
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(Icons.arrow_forward, size: 22, color: green)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
