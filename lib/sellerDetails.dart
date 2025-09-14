import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/apptRequest.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/sellerHomepage.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/showAlert.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SellerDetailsPage extends StatefulWidget {
  const SellerDetailsPage({
    super.key,
    required this.sellerDetails,
    required this.sellerUid,
    required this.wherFrom
  });

  final Map<String, dynamic> sellerDetails;
  final String sellerUid;
  final String wherFrom;

  @override
  State<SellerDetailsPage> createState() => _SellerDetailsPageState();
}

class _SellerDetailsPageState extends State<SellerDetailsPage> {

  // kullanıcı saatleri ile ilgili kısım
  List<String> days = [];
  String? day;
  Map<String, List<String>> hoursByDay = {};
  Map<String,bool> hourIsTaken = {};
  Map<String, Color> hourColors = {};
  String? _selectedDay;
  String? _selectedHour;
  String? _selectedField;
  List<String> orderedDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  bool isLoading = true;
  final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  bool isEmpty = false;
  late Future<void> _daysNameFuture;
  List<String> hours = []; 
  //bool hasGig = false;

  @override
  void initState() {
    super.initState();
    _daysNameFuture = _getDaysName(widget.sellerUid);
    //hasGig = checkIfSellerHasGig();
  }

  bool checkIfSellerHasGig() {
    try {
      final gig = widget.sellerDetails['sellerGig'];
      if (gig == null || gig is! String || gig.trim().isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e,stack) {
      reportErrorToCrashlytics(
        e, 
        stack,
        reason: 'sellerDetails error for user $currentUserUid'
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // eğer kullanıcı hiç ilan açmamış ise
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;
    if (widget.sellerDetails.isEmpty) {
      return Scaffold(
        appBar: AppBar( 
          backgroundColor: userorseller ? sellerbackground : background,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black),
          ),
        ),
        body: Container(
          width: width,
          color: sellerbackground,
          child: Column(
            children: [
              SizedBox(height: height * 0.030),
              Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Henüz bir ilanınız bulunmamaktadır',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: height * 0.030),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SellerAddPage())
                );
              },
              style: GlobalStyles.buttonPrimary(context),
              child: Text(
                'İlan ver',
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: userorseller ? Colors.white : Colors.black,
                ),
              )
            )
          ],
          ),
        )
      );
    }

    var imageUrl = widget.sellerDetails['imageUrls'][0];

    return ConnectivityWithBackButton(
      child: FutureBuilder<void>(
        future: _daysNameFuture,
        builder: (context,snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            switch (widget.wherFrom){
              case 'fromSomewhere' || 'fromSuccess':
                return SellerDetailsDarkShimmer();
              default:
                return SellerDetailsShimmer();
            } 
          }

          final width = MediaQuery.sizeOf(context).width;
          final height = MediaQuery.sizeOf(context).height;

          return Scaffold(
          appBar: AppBar(
          backgroundColor: userorseller ? sellerbackground : background,
          leading: IconButton(
            onPressed: () {
              switch (widget.wherFrom) {
                case 'fromSuccess':
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SellerMainPage(index: 0)));
                default:
                  Navigator.pop(context);
              }
            },
            icon: Icon(Icons.arrow_back, color: userorseller ? Colors.white: Colors.black),
          ),
        ),
          body: Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height * 0.60
              ),
              child: SingleChildScrollView(
                child: Container(
                height: height,
                color: userorseller ? sellerbackground : background,
                child: Column(  
                  children: [
                    SizedBox(height: height * 0.025),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),  
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          color: userorseller ? sellergrey: Colors.white,
                          height: height * 0.60,
                          width: width,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: showImage(imageUrl: imageUrl, sellerDetails: widget.sellerDetails, sellerUid: widget.sellerUid, width: width, height: height, whereFrom: widget.wherFrom,)
                                  ),
                                  SizedBox(height: height * 0.020),
                                  
                                  showNameSurname(sellerDetails: widget.sellerDetails),
                                  
                                  SizedBox(height: height * 0.007),
                                  
                                  showCityDistrict(sellerDetails: widget.sellerDetails),

                                  // check if user posted a gig
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance.collection('Users').doc(widget.sellerUid).snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) return SizedBox();
                                        final sellerDetailsMap = snapshot.data!.data() as Map<String, dynamic>;
                                        final nestedSellerDetails = sellerDetailsMap['sellerDetails'] as Map<String, dynamic>?;
                                        
                                        final bool hasGig = nestedSellerDetails != null && nestedSellerDetails['sellerGig'] != null && (nestedSellerDetails['sellerGig'] as String).trim().isNotEmpty;
                                        
                                        return Column(
                                          children: [
                                            if (hasGig) SizedBox(height: height * 0.020),
                                            if (hasGig) showGig(sellerDetails: nestedSellerDetails),
                                            ],
                                          );
                                      },
                                    ),

                                  SizedBox(height: height * 0.005),

                                  // burada kullanıcı saha seçmemiş ise ilk sahayı ata
                                  SellerFields(
                                    selectedField: _selectedField ?? widget.sellerDetails['fields'][0],
                                    sellerDetails: widget.sellerDetails,
                                    onFieldChanged: (newField) {
                                      setState(() {
                                        _selectedField = newField;
                                      });
                                    }, 
                                    width: width,
                                    ),
                                  SizedBox(height: height * 0.010),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Saatler",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: userorseller ? Colors.white : Colors.black,
                                          ),
                                          textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                                        ),
                                        SizedBox(height: height * 0.010),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            //todo: Gece saatleri sıkıntılı çalışıyor ve _getDaysName de de aynı kod çalışıyor, hangisi boş anla
                                            StreamBuilder<DocumentSnapshot>(
                                              stream: _stream(),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  return const Center(child: CircularProgressIndicator());
                                                }
                                                final userData = snapshot.data!.data() as Map<String, dynamic>;
                                                final selectedHoursByDay = userData['sellerDetails']?['selectedHoursByDay'] as Map<String, dynamic>?;
                                                if (selectedHoursByDay == null) {
                                                  return const Text('Saat bilgisi bulunamadı');
                                                }
                                                
                                                days.clear();
                                                hoursByDay.clear();
                                                hourColors.clear();
                                                
                                                final now = DateTime.now().toUtc().add(const Duration(hours: 3));
                                                final int currentDayIndex = now.weekday - 1;
                                                
                                                for (int i = 0; i < orderedDays.length; i++) {
                                                  final day = orderedDays[i];
                                                  if (!selectedHoursByDay.containsKey(day)) continue;
                                                    List<dynamic> hourList = selectedHoursByDay[day];
                                                    
                                                    if (hourList.isEmpty) continue;
                                                      days.add(day);
                                                      List<String> hourTitles = [];
                                                      for (var hour in hourList) {
                                                        final hourMap = hour as Map<String, dynamic>;
                                                        final String title = hourMap['title'];
                                                        final bool istaken = hourMap['istaken'];
                                                        final String? takenby = hourMap['takenby'];
                                                        final String startTime = title.split('-')[0];
                                                        final String dayHourKey = '$day $title';
                                                        List<String> nightTitles = ['00:00-01:00','01:00-02:00','02:00-03:00'];
                                                        bool isNightHour = nightTitles.contains(title);

                                                      
                                                        dayChecker(i, currentDayIndex, now, startTime, dayHourKey, takenby!, day, title, hourTitles, isNightHour, istaken, hours);
                                                      }
                                                      
                                                  }
                                                  
                                                return DayHourListView(
                                                  width: width,
                                                  heigth: height,
                                                  days: days,
                                                  hoursByDay: hoursByDay,
                                                  hourColors: hourColors,
                                                  selectedDay: _selectedDay,
                                                  selectedHour: _selectedHour,
                                                  userorseller: userorseller,
                                                  onDaySelected: (selectedDay) {
                                                    setState(() {
                                                      _selectedDay = selectedDay;
                                                    });
                                                  },
                                                  onHourSelected: (selectedHour) {
                                                    setState(() {
                                                      _selectedHour = selectedHour;
                                                    });
                                                  },
                                                  onClearSelection: () {
                                                    setState(() {
                                                      _selectedDay = null;
                                                      _selectedHour = null;
                                                      hourColors.forEach((key, value) {
                                                        if (value != Colors.grey.shade600 && value != Colors.green) {
                                                          hourColors[key] = Colors.cyan;
                                                        }
                                                      });
                                                    });
                                                  },
                                                );
                                              }),
                                        ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.015),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: showInfoAppointments(width: width, height: height)
                          ),
                          SizedBox(width: 10),
                          ChatButton(
                            sellerUid: widget.sellerUid,
                            width: width,
                            height: height,
                            currentUser: currentUserUid
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.030),
                    PaymentButton(
                      selectedDay: _selectedDay,
                      selectedHour: _selectedHour,
                      selectedField: _selectedField,
                      currentUserUid: currentUserUid,
                      sellerUid: widget.sellerUid,
                      sellerDetails: widget.sellerDetails
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
          )
        );
        }
      ),
    );
  }
  
  void dayChecker(int i, int currentDayIndex, final now, String startTime, String dayHourKey, String takenby, String day, String title, List<String> hourTitles, bool isNightHour, bool istaken, List<String> hours) {
    if (isNightHour) {
      // Mark as taken if istaken is true
      if (istaken) {
        hourColors[dayHourKey] = takenby == currentUserUid ? Colors.green : Colors.grey.shade600;
      } else {
        bool isPastNightHour = i < currentDayIndex && isPastNightHours(now, startTime);
        if (isPastNightHour) {
          hourColors[dayHourKey] = takenby == currentUserUid ? Colors.green : Colors.grey.shade600;
        } else {
          hourColors[dayHourKey] = Colors.cyan;
        }
      }
      hourTitles.add(title);
      // shows the hours in order
      showHoursInOrder(hourTitles);

      hoursByDay[day] = hourTitles;
    } else {
      bool isPastDay = i < currentDayIndex;
      bool sameDay = i == currentDayIndex;
      bool isPastHour = isStartTimePast(now, startTime, isNightHour) && sameDay;
      if (istaken || isPastDay || isPastHour) {
        hourColors[dayHourKey] = takenby == currentUserUid ? Colors.green : Colors.grey.shade600;
        if (isPastDay) {
          markPastDayAsTaken(userId: widget.sellerUid, day: day, title: title);
        } else if (isPastHour) {
          markSingleHourAsTaken(userId: widget.sellerUid, day: day, title: title);
        }
      } else {
        hourColors[dayHourKey] = Colors.cyan;
      }
      hourTitles.add(title);
      // shows the hours in order
      showHoursInOrder(hourTitles);
    }
    hoursByDay[day] = hourTitles;
  }

  void showHoursInOrder(List<String> hourTitles) {
  hourTitles.sort((a, b) {
    // Extract start hour and minute
    int startHourA = int.parse(a.split(':')[0]);
    int startHourB = int.parse(b.split(':')[0]);

    // Night hours: 00, 01, 02
    bool isNightA = startHourA == 0 || startHourA == 1;
    bool isNightB = startHourB == 0 || startHourB == 1;

    if (isNightA && !isNightB) {
      return 1; // Night hours go after normal hours
    } else if (!isNightA && isNightB) {
      return -1; // Normal hours go before night hours
    } else if (isNightA && isNightB) {
      // Both are night hours, sort 00, 01, 02
      return startHourA.compareTo(startHourB);
    } else {
      // Both are normal hours, sort as usual
      return startHourA.compareTo(startHourB);
    }
  });
}

  Stream<DocumentSnapshot> _stream() {
    return FirebaseFirestore.instance
    .collection('Users')
    .doc(widget.sellerUid)
    .snapshots();
  }

  //todo: Burayada saate göre geçme mantığını uygula
   Future<void> _getDaysName(String userId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("Users").doc(userId).get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.isNotEmpty && data.containsKey('sellerDetails')) {
          Map<String, dynamic> sellerDetails = data['sellerDetails'];
          if (sellerDetails.containsKey('selectedHoursByDay')) {
            Map<String, dynamic> selectedHoursByDay = sellerDetails['selectedHoursByDay'];

            List<String> userDays = orderedDays.where((day) {
              return selectedHoursByDay.containsKey(day) && selectedHoursByDay[day].isNotEmpty;
            }).toList();

            if (mounted) {
              setState(() {
                days.clear();
                days.addAll(userDays);
                hoursByDay.clear(); // Clean up for another user
                hourColors.clear(); // Reset hourColors for new data
              });
            }
          }
        }
      }
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'sellerDetails _getDaysName error for user $userId',
      );
    }
  }
// TODO: Kontrol et geçmiş saatler ilk açılınca renk değiştiriyor mu diye
Future<void> markPastDayAsTaken({required String userId,required String day,required String title}) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    List<dynamic> data = userDoc.data()?['sellerDetails']['selectedHoursByDay'][day] ?? [];
    bool needsUpdate = false;
    List<dynamic> updatedData = data.map((hour) {
      if (hour['istaken'] == false) {
        needsUpdate = true;
        return {
          'title': hour['title'],
          'istaken': true,
          'takenby': 'empty'
        };
      } else {
        return hour;
      }
    }).toList();

    if (needsUpdate) {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'sellerDetails.selectedHoursByDay.$day': updatedData
      });
    }
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'sellerDetails markPastDayAsTaken error for user $userId',
    );
  }
}
}

Future<void> markSingleHourAsTaken({required String userId, required String day, required String title}) async {
  try {
    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    List<dynamic> data = userDoc.data()?['sellerDetails']['selectedHoursByDay'][day] ?? [];

    List<dynamic> updatedData = data.map((hour) {
      if (hour['title'] == title && hour['istaken'] == false) {
        return {
          'title': hour['title'],
          'istaken': true,
          'takenby': 'empty',
        };
      }
      return hour;
    }).toList();

    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'sellerDetails.selectedHoursByDay.$day': updatedData,
    });
  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'sellerDetails markSingleHourAsTaken error for user $userId',
    );
  }
}

bool isStartTimePast(DateTime now, String startTime, bool isNightHour) {
  final nowInMinutes = now.hour * 60 + now.minute;

  final parts = startTime.split(':');
  final startHour = int.parse(parts[0]);
  final startMinute = int.parse(parts[1]);
  final startInMinutes = startHour * 60 + startMinute;

  // Gece saati ise ertesi günmüş gibi davranıyor
  if (isNightHour) return false;

  return nowInMinutes >= startInMinutes;
}

bool isPastNightHours(DateTime now, String startTime) {
  final nowInMinutes = now.hour * 60 + now.minute;

  final parts = startTime.split(':');
  final startHour = int.parse(parts[0]);
  final startMinute = int.parse(parts[1]);
  final startInMinutes = startHour * 60 + startMinute;

  return nowInMinutes >= startInMinutes;
}



class SellerFields extends StatefulWidget {
  final String selectedField;
  final Map<String, dynamic> sellerDetails;
  final ValueChanged<String> onFieldChanged;
  final double width;

  const SellerFields({
    super.key,
    required this.selectedField,
    required this.sellerDetails,
    required this.onFieldChanged,
    required this.width
  });

  @override
  State<SellerFields> createState() => _SellerFieldsState();
}

class _SellerFieldsState extends State<SellerFields> {
  String _selectedField = '';

  @override
  void initState() {
    super.initState();
    _selectedField = widget.selectedField;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
          border: Border.all(color: Colors.grey.shade300), // Subtle border
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedField,
            isExpanded: true, // Ensures full width
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
            items: widget.sellerDetails['fields'].map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedField = value;
                });
                widget.onFieldChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}



class showImage extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> sellerDetails;
  final String sellerUid;
  final double width;
  final double height;
  final String whereFrom;

  const showImage({
    super.key,
    required this.imageUrl,
    required this.sellerDetails,
    required this.sellerUid,
    required this.width,
    required this.height,
    required this.whereFrom
  });

  @override
  State<showImage> createState() => _showImageState();
}

class _showImageState extends State<showImage> {
  final user = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final imageHeight = widget.height * 0.30;

    return Stack(
      children: [
        Image.network(
          widget.imageUrl,
          height: imageHeight,
          width: widget.width,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'lib/images/imageDefault.jpg',
              fit: BoxFit.contain,
              height: imageHeight,
              width: widget.width,
            );
          },
        ),
        // delete icon
        if (widget.whereFrom == 'fromSomewhere' || widget.whereFrom == 'fromSuccess')
        Positioned(
          top: 15,
          left: 25, 
          child: GestureDetector(
            onTap: () {
              _showMyDialog();
            },
            child: Icon(
              Icons.delete,
              color: Colors.red,
              size: widget.width * 0.08,
            ),
          ),
        ),
        // Favorite icon
        Positioned(
          top: 15,
          right: 25,
          child: buildFavoriteIcon(),
        ),
      ],
    );
  }
  Widget buildFavoriteIcon() {
  final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUserUid)
      .collection('favourites')
      .where('sellerUid', isEqualTo: widget.sellerUid)
      .snapshots(),
    builder: (context, snapshot) {
      bool isFavorited = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

      return GestureDetector(
        onTap: () async {
          if (isFavorited) {
            // Remove from favorites
            for (var doc in snapshot.data!.docs) {
              await doc.reference.delete();
            }
          } else {
            // Add to favorites
            widget.sellerDetails['sellerUid'] = widget.sellerUid;
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(currentUserUid)
                .collection('favourites')
                .add(widget.sellerDetails);
          }
        },
        child: Icon(
          Icons.favorite,
          color: isFavorited ? Colors.red : Colors.grey,
          size: widget.width * 0.08,
        ),
      );
    },
  );
}

  // void _toggleFavorite(Map<String, dynamic> sellerDetails, String sellerUid) async {
  //   final String? currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  //   try {
  //     if (currentUserUid != null && currentUserUid.isNotEmpty) {
  //     if (_isFavorited) {
  //       // Remove from favorites
  //       QuerySnapshot snapshot = await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(currentUserUid)
  //           .collection('favourites')
  //           .where('sellerUid', isEqualTo: sellerUid)
  //           .get();
  //       for (var doc in snapshot.docs) {
  //         await doc.reference.delete();
  //         print('its deleted');
  //       }
  //       setState(() {
  //         _isFavorited = false;
  //       });
  //     } else {
  //       // Add to favorites
  //       sellerDetails['sellerUid'] = sellerUid;
  //       await FirebaseFirestore.instance
  //           .collection('Users')
  //           .doc(currentUserUid)
  //           .collection('favourites')
  //           .add(sellerDetails);
  //       setState(() {
  //         _isFavorited = true;
  //         print('added again');
  //       });
  //     }
  //   }
  //   } catch (e, stack) {
  //     await reportErrorToCrashlytics(e, stack, reason: 'SellerDetails _toggleFavorite error for user $currentUserUid');
  //   }
  // }

  Future<void> _showMyDialog() async {
  if (Platform.isIOS) {
    // iOS style dialog
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('İlanı Sil'),
          content: const Text('İlanı silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Sil'),
              onPressed: () async{
                // delete the post
                await deletePost();
              },
            ),
          ],
        );
      },
    );
  } else {
    // Android style dialog
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text('Hesabınızı silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () async{
                // delete the post
                await deletePost();
              },
            ),
          ],
        );
      },
    );
  }
}
  Future<void> deletePost() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.green,
              backgroundColor: Colors.grey,
            ),
          );
        }
      );
    try {
      await FirebaseFirestore.instance
        .collection('Users')
        .doc(user)
        .update({
          'sellerDetails': FieldValue.delete()
        });
        Navigator.of(context).pop(); // Close loading dialog
        //await Showalert(context: context, text: 'İlanınız başarı ile silinmiştir').showSuccessAlert();
        QuickAlert.show(
          context: context,
          text: 'İlanınız başarı ile silinmiştir',
          title: 'Başarılı',
          confirmBtnText: 'Tamam',
          type: QuickAlertType.success, onConfirmBtnTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => SellerMainPage(index: 0)),
            );
        });
        // await Future.delayed(const Duration(seconds: 1)); 
        // Navigator.of(context).pop();
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => SellerMainPage(index: 0)),
        // );
    } catch (e, stack) {
        //await Showalert(context: context, text: 'Ooopps...').showErrorAlert();
        await reportErrorToCrashlytics(e, stack, reason: 'SellerDetails deletion of post error $user');
    }
  }
}
class showNameSurname extends StatelessWidget {
  final Map<String,dynamic> sellerDetails;
  const showNameSurname({required this.sellerDetails,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Text(
            "${sellerDetails['sellerFullName']}",
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: userorseller ? Colors.white : Colors.black,
            ),
            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
          ),
        ],
      ),
    );
  }
}
class showCityDistrict extends StatelessWidget {
  final Map<String,dynamic> sellerDetails;
  const showCityDistrict({required this.sellerDetails,super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        "${sellerDetails['city']} ,${sellerDetails['district']}",
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w300,
          color: userorseller ? Colors.white : Colors.black,
        ),
        textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
      ),
    );
  }
}

class showGig extends StatefulWidget {
  final Map<String, dynamic> sellerDetails;
  const showGig({required this.sellerDetails, super.key});

  @override
  _ShowGigState createState() => _ShowGigState();
}

class _ShowGigState extends State<showGig> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.sellerDetails['sellerGig'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            maxLines: isExpanded ? null : 2,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: userorseller ? Colors.white : Colors.black,
            ),
            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
          ),
          if (text.length > 100) // optional: only show if text is long
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Text(
                isExpanded ? 'daha az' : 'daha fazla',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}



class chooseCard extends StatelessWidget {
  final String field;
  final bool isSelected;
  final VoidCallback onTap;
  final bool userorseller;

  const chooseCard({
    super.key,
    required this.field,
    required this.isSelected,
    required this.onTap,
    required this.userorseller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: isSelected ? Colors.grey : green,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                field,
                style: TextStyle(
                  color: userorseller ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class DayHourListView extends StatelessWidget {
  final List<String> days;
  final Map<String, List<String>> hoursByDay;
  final Map<String, Color> hourColors;
  final String? selectedDay;
  final String? selectedHour;
  final bool userorseller;
  final ValueChanged<String> onDaySelected;
  final ValueChanged<String> onHourSelected;
  final VoidCallback onClearSelection;
  final double width;
  final double heigth;

  const DayHourListView({
    super.key,
    required this.days,
    required this.hoursByDay,
    required this.hourColors,
    required this.selectedDay,
    required this.selectedHour,
    required this.userorseller,
    required this.onDaySelected,
    required this.onHourSelected,
    required this.onClearSelection,
    required this.width,
    required this.heigth
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: heigth*0.6,
      width: double.infinity,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final hours = hoursByDay[day] ?? [];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: userorseller ? Colors.white : Colors.black,
                  ),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
                SizedBox(height: heigth * 0.007),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hours.map((hour) {
                      // Generate unique key for each hour
                      String dayHourKey = '$day $hour';
                      bool isSelected = selectedDay == day && selectedHour == hour;
                      bool isDisabled = hourColors[dayHourKey] == Colors.grey.shade600 || hourColors[dayHourKey] == Colors.grey || hourColors[dayHourKey] == Colors.green;
                      return GestureDetector(
                        // Only allow interaction if not disabled
                        onTap: !isDisabled
                            ? () {
                                onDaySelected(day);
                                onHourSelected(hour);
                      
                                hourColors.forEach((key, value) {
                                  if (value != Colors.grey.shade600 && value != Colors.green) {
                                    hourColors[key] = Colors.cyan;
                                  }
                                });
                      
                                hourColors[dayHourKey] = Colors.grey;
                              }
                            : null,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 3.0),
                                padding: const EdgeInsets.all(5),
                                color: isSelected ? Colors.grey : hourColors[dayHourKey] ?? Colors.cyan,
                                child: Text(
                                  hour,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: userorseller ? Colors.white : Colors.black,
                                  ),
                                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: onClearSelection,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: width*0.02,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
class showInfoAppointments extends StatelessWidget {
  final double width;
  final double height;
  const showInfoAppointments({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 15,
                              width: 15,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: width*0.020),
                          Text(
                            'Randevu saatin',
                            style: TextStyle(
                              color: userorseller ? Colors.white: Colors.black
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          )
                        ],
                      ),
                      SizedBox(height: height * 0.010),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 15,
                              width: 15,
                              color: Colors.cyan,
                            ),
                          ),
                          SizedBox(width: width * 0.020),
                          Text(
                            'Müsait',
                            style: TextStyle(
                              color: userorseller ? Colors.white: Colors.black
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          )
                        ],
                      ),
                      SizedBox(height: height * 0.010),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 15,
                              width: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: width*0.020),
                          Text(
                            'Alınmış veya geçmiş',
                            style: TextStyle(
                              color: userorseller ? Colors.white : Colors.black
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          )
                        ],
                      ),
                    ],
                  );
  }
}
class ChatButton extends StatelessWidget {
  final String sellerUid;
  final double width;
  final double height;
  final String? currentUser;
  
  const ChatButton({
    super.key,
    required this.sellerUid,
    required this.width,
    required this.height,
    required this.currentUser
  });


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () async{
        // Set shared state and navigate to the message page
        sharedValues.onTapped = true;
        bool paymentMade = await isPaymentMade();
        if (paymentMade) {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              sharedValues.onTapped = false;
              return MessagePage();  // Assuming MessagePage is already defined
            },
          ),
        );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sohbet etmek için ödeme yapmanız gerek'),
              backgroundColor: Colors.red,
            )
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: Colors.white,
          width: width*0.30,
          height: height*0.05,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.forward_to_inbox,
                  color: Colors.black,
                  size: width*0.06,
                ),
                SizedBox(width: 5),
                Text(
                  "Sohbet",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<bool> isPaymentMade() async {
    QuerySnapshot snapshots = await FirebaseFirestore.instance.collection('Users')
    .doc(currentUser)
    .collection('appointmentbuyer')
    .where('appointmentDetails.selleruid', isEqualTo: sellerUid)
    .where('appointmentDetails.paymentStatus', isEqualTo: 'done')
    .get();

    if (snapshots.docs.isEmpty) {
      return false;
    } else {
      return true;
    }
  }
}
class PaymentButton extends StatelessWidget {

  final String? selectedDay;
  final String? selectedHour;
  String? selectedField;
  final String? currentUserUid;
  final String sellerUid;
  final Map<String,dynamic> sellerDetails;

  PaymentButton({
    super.key,
    required this.selectedDay,
    required this.selectedHour,
    required this.selectedField,
    required this.currentUserUid,
    required this.sellerUid,
    required this.sellerDetails
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
                        onPressed: () {
                          if (selectedField == null || selectedField!.isEmpty) {
                            selectedField = sellerDetails['fields'][0];
                          }
                          if (selectedDay == null || selectedHour == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Saat veya saha seçiniz'),
                                backgroundColor: Colors.red,
                              )
                            );
                          } else if (sellerUid == currentUserUid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kullanıcı kendini seçemez'),
                                backgroundColor: Colors.red,
                              )
                            );
                          }
                          else {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApptRequest(
                                sellerUid: sellerUid,
                                selectedDay: selectedDay!,
                                selectedHour: selectedHour!,
                                selectedField: selectedField!,
                                selectedPrice: getPriceValue(),
                              )
                            ),
                          );
                          }
                        },
                        style: GlobalStyles.buttonPrimary(context),
                        child: Text(
                          getPrice(),
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: userorseller ? Colors.white : Colors.black,
                          ),
                          textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                        ),
                      );
  }
  String getPrice() {
    if (selectedHour == '00:00-01:00' || selectedHour == '01:00-02:00') {
      return "Ödeme (₺${sellerDetails['sellerPriceMidnight']})";
    } else {
      return "Ödeme (₺${sellerDetails['sellerPrice']})";
    }
  }
  int getPriceValue() {
    if (selectedHour == '00:00-01:00' || selectedHour == '01:00-02:00') {
      return sellerDetails['sellerPriceMidnight'] ?? 0;
    } else {
      return sellerDetails['sellerPrice'] ?? 0;
    }
  }
}





