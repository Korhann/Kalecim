import 'dart:core';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/comment_section.dart';
import 'package:kiralik_kaleci/commentspage.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/messagepage.dart';
import 'package:kiralik_kaleci/apptRequest.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/selleraddpage.dart';
import 'package:kiralik_kaleci/sellermainpage.dart';
import 'package:kiralik_kaleci/sharedvalues.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'package:quickalert/quickalert.dart';

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

  // Future<bool>? checkUserRentedBefore;
  Future<bool>? checkIfSameUser;
  TextStyle linkStyle = TextStyle(color: Colors.green);

//   Map<String, Color> _cardColors = {
//   'primary': const Color(0xFFCD7F32), // Default bronze
//   'secondary': const Color(0xFFB8860B),
//   'accent': const Color(0xFF8B4513),
// };

  @override
  void initState() {
    super.initState();
    _daysNameFuture = _getDaysName(widget.sellerUid);
    // checkUserRentedBefore = checkIfUserInRentedUsers();
    checkIfSameUser = checkIfSameUserIsSeller();
  }

  Future<bool> checkIfSameUserIsSeller() async {
    return widget.sellerUid != currentUserUid;
  }

  Future<bool> checkIfUserInRentedUsers() async{
    try {
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance
    .collection('Users')
    .doc(widget.sellerUid)
    .collection('rentedUsers')
    .doc(currentUserUid)
    .get();

    return documentSnapshot.exists;
    } catch (e) {
      return false;
    }
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
                          // burada kart rengini ayarla
                          color: userorseller ? sellergrey : Colors.white,
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

                                  Row(
                                    children: [
                                      showNameSurname(sellerDetails: widget.sellerDetails),
                                      const Spacer(),
                                      AverageRating(
                                        sellerUid: widget.sellerUid,
                                        // onCardColorsChanged: (colors) {
                                        // _cardColors = colors;
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: height * 0.007),
                                  
                                  showCityDistrict(sellerDetails: widget.sellerDetails),

                                  // check if user posted a gig
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance.collection('Users').doc(widget.sellerUid).snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || !snapshot.data!.exists) {
                                        return SizedBox();
                                      }
                                      
                                      final data = snapshot.data!.data();
                                      if (data == null) {
                                        return SizedBox();
                                      }
                                      
                                      final sellerDetailsMap = data as Map<String, dynamic>;
                                      
                                      // Check if sellerDetails exists and is not null
                                      if (!sellerDetailsMap.containsKey('sellerDetails') || sellerDetailsMap['sellerDetails'] == null) {
                                        return SizedBox();
                                      }
                                      
                                      final nestedSellerDetails = sellerDetailsMap['sellerDetails'] as Map<String, dynamic>?;
                                      
                                      // Additional null check
                                      if (nestedSellerDetails == null) {
                                        return SizedBox();
                                      }
                                      
                                      final bool hasGig = nestedSellerDetails.containsKey('sellerGig') && 
                                                         nestedSellerDetails['sellerGig'] != null && 
                                                         (nestedSellerDetails['sellerGig'] as String).trim().isNotEmpty;
                                      
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
                                                
                                                // Check if document exists
                                                if (!snapshot.data!.exists) {
                                                  return const Text('Kullanıcı bulunamadı');
                                                }
                                                
                                                // Check if data is null
                                                final data = snapshot.data!.data();
                                                if (data == null) {
                                                  return const Text('Kullanıcı bilgisi bulunamadı');
                                                }
                                                
                                                // Safe casting with null check
                                                final userData = data as Map<String, dynamic>?;
                                                if (userData == null) {
                                                  return const Text('Kullanıcı bilgisi bulunamadı');
                                                }
                                                
                                                // Check if sellerDetails exists
                                                if (!userData.containsKey('sellerDetails') || userData['sellerDetails'] == null) {
                                                  return const Text('Kullanıcı artık mevcut değil');
                                                }
                                                
                                                // Safe access to sellerDetails
                                                final sellerDetails = userData['sellerDetails'] as Map<String, dynamic>?;
                                                if (sellerDetails == null) {
                                                  return const Text('Kullanıcı artık mevcut değil');
                                                }
                                                
                                                // Check if selectedHoursByDay exists
                                                if (!sellerDetails.containsKey('selectedHoursByDay') || sellerDetails['selectedHoursByDay'] == null) {
                                                  return const Text('Saat bilgisi bulunamadı');
                                                }
                                                
                                                final selectedHoursByDay = sellerDetails['selectedHoursByDay'] as Map<String, dynamic>?;
                                                if (selectedHoursByDay == null) {
                                                  return const Text('Saat bilgisi bulunamadı');
                                                }
                                                
                                                // Clear existing data
                                                days.clear();
                                                hoursByDay.clear();
                                                hourColors.clear();
                                                
                                                final now = DateTime.now().toUtc().add(const Duration(hours: 3));
                                                final int currentDayIndex = now.weekday - 1;
                                                
                                                // Process the hours data
                                                for (int i = 0; i < orderedDays.length; i++) {
                                                  final day = orderedDays[i];
                                                  if (!selectedHoursByDay.containsKey(day)) continue;
                                                  
                                                  final hourListData = selectedHoursByDay[day];
                                                  if (hourListData == null) continue;
                                                  
                                                  List<dynamic> hourList = hourListData is List ? hourListData : [];
                                                  if (hourList.isEmpty) continue;
                                                  
                                                  days.add(day);
                                                  List<String> hourTitles = [];
                                                  
                                                  for (var hour in hourList) {
                                                    try {
                                                      final hourMap = hour as Map<String, dynamic>;
                                                      final String title = hourMap['title'] ?? '';
                                                      final bool istaken = hourMap['istaken'] ?? false;
                                                      final String? takenby = hourMap['takenby'];
                                                      
                                                      if (title.isEmpty) continue;
                                                      
                                                      final String startTime = title.split('-')[0];
                                                      final String dayHourKey = '$day $title';
                                                      List<String> nightTitles = ['00:00-01:00','01:00-02:00','02:00-03:00'];
                                                      bool isNightHour = nightTitles.contains(title);

                                                      dayChecker(i, currentDayIndex, now, startTime, dayHourKey, takenby ?? '', day, title, hourTitles, isNightHour, istaken, hours);
                                                    } catch (e) {
                                                      // Skip invalid hour data
                                                      continue;
                                                    }
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
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Yorumlar",
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: userorseller ? Colors.white : Colors.black,
                                          ),
                                          textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                                        ),
                                        const SizedBox(width: 20),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(widget.sellerUid)
                                              .collection('rentedUsers')
                                              .where('comment', isNotEqualTo: null)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            int commentCount = 0;
                                            
                                            if (snapshot.hasData) {
                                              // Count only documents that have non-empty comments
                                              commentCount = snapshot.data!.docs.where((doc) {
                                                final data = doc.data() as Map<String, dynamic>;
                                                return data['comment'] != null && data['comment'].toString().trim().isNotEmpty;
                                              }).length;
                                            }
                                            
                                            return RichText(
                                              text: TextSpan(
                                                text: '$commentCount yorumu gör',
                                                style: linkStyle,
                                                recognizer: TapGestureRecognizer()..onTap = () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => CommentsPage(sellerUid: widget.sellerUid, checkIfSameUser: checkIfSameUser!)
                                                    )
                                                  );
                                                }
                                              )
                                            );
                                          },
                                        ),
                                        const Spacer(),

                                        FutureBuilder<bool>(
                                          future: checkIfSameUser,
                                          builder: (context,snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const SizedBox.shrink(); // Don't show anything while loading
                                            }
                                            if (snapshot.hasError) {
                                              return const SizedBox.shrink(); // Don't show on error
                                            }
                                            if (snapshot.hasData && snapshot.data == true) {
                                              return Ratings(
                                                sellerUid: widget.sellerUid,
                                                currentUserUid: currentUserUid!,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          }
                                        )
                                      ],
                                    )
                                  ),
                                  CommentSection(sellerUid: widget.sellerUid),

                                  FutureBuilder<bool>(
                                    future: checkIfSameUser,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const SizedBox.shrink(); // Don't show anything while loading
                                      }
                                      if (snapshot.hasError) {
                                        return const SizedBox.shrink(); // Don't show on error
                                      }
                                      // Only show comment box if user has rented before
                                      if (snapshot.hasData && snapshot.data == true) {
                                        return SimpleCommentBox(
                                          sellerUid: widget.sellerUid,
                                          checkIfSameUser: checkIfSameUser!,
                                        );
                                      }
                                      // Don't show comment box if user hasn't rented
                                      return const SizedBox.shrink();
                                    }
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

enum CardType { bronze, silver, gold, rareBronze, rareSilver, rareGold }

CardType getCardType(double averageRating, int numberOfRatings) {
  // Minimum ratings required for each tier
  const int minRatingsForSilver = 10;
  const int minRatingsForGold = 25;
  const int minRatingsForRare = 50;

  // Rating thresholds
  const double bronzeThreshold = 3.0;
  const double silverThreshold = 4.0;
  const double goldThreshold = 4.5;

  // No ratings or very few ratings
  if (numberOfRatings == 0) {
    return CardType.bronze; // Default for new sellers
  }

  // Rare cards (high volume + high quality)
  if (numberOfRatings >= minRatingsForRare) {
    if (averageRating >= goldThreshold) {
      return CardType.rareGold; // 50+ ratings, 4.5+ average
    } else if (averageRating >= silverThreshold) {
      return CardType.rareSilver; // 50+ ratings, 4.0+ average
    } else {
      return CardType.rareBronze; // 50+ ratings, below 4.0 average
    }
  }

  // Gold tier (premium quality)
  if (numberOfRatings >= minRatingsForGold && averageRating >= goldThreshold) {
    return CardType.gold; // 25+ ratings, 4.5+ average
  }

  // Silver tier (good quality)
  if (numberOfRatings >= minRatingsForSilver && averageRating >= silverThreshold) {
    return CardType.silver; // 10+ ratings, 4.0+ average
  }

  // Bronze tier (basic or low ratings)
  return CardType.bronze; // Everything else
}

Map<String, Color> getCardColors(CardType cardType) {
  print(cardType);
  switch (cardType) {
    case CardType.bronze:
      return {
        'primary': const Color(0xFFCD7F32), // Bronze color
        'secondary': const Color(0xFFB8860B), // Dark goldenrod
        'accent': const Color(0xFF8B4513), // Saddle brown
      };
    case CardType.silver:
      return {
        'primary': const Color(0xFFC0C0C0), // Silver
        'secondary': const Color(0xFF808080), // Gray
        'accent': const Color(0xFF696969), // Dim gray
      };
    case CardType.gold:
      return {
        'primary': const Color(0xFFFFD700), // Gold
        'secondary': const Color(0xFFDAA520), // Goldenrod
        'accent': const Color(0xFFB8860B), // Dark goldenrod
      };
    case CardType.rareBronze:
      return {
        'primary': const Color(0xFFCD7F32), // Bronze
        'secondary': const Color(0xFF4B0082), // Indigo (rare effect)
        'accent': const Color(0xFF8B008B), // Dark magenta
      };
    case CardType.rareSilver:
      return {
        'primary': const Color(0xFFC0C0C0), // Silver
        'secondary': const Color(0xFF9400D3), // Violet (rare effect)
        'accent': const Color(0xFF4B0082), // Indigo
      };
    case CardType.rareGold:
      return {
        'primary': const Color(0xFFFFD700), // Gold
        'secondary': const Color(0xFFFF1493), // Deep pink (rare effect)
        'accent': const Color(0xFF8B008B), // Dark magenta
      };
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


class Ratings extends StatefulWidget {
  final String sellerUid;
  final String currentUserUid;
  const Ratings({
    super.key,
    required this.sellerUid,
    required this.currentUserUid,
  });

  @override
  State<Ratings> createState() => _RatingsState();
}

class _RatingsState extends State<Ratings> {

  // puanlama için
  double currentRating = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    showInitialRating();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: StarRating(
        // bunu sonrada 25 yapabilirsin
        size: 23.0,
        rating: currentRating,
        color: Colors.yellow,
        allowHalfRating: true,
        starCount: 5,
        onRatingChanged: (currentRating) => setState(() {
          this.currentRating = currentRating;
          // basınca 1 saniye yükleme barı oluştur ve puanlama yapılmıştır promptu çıkar
          insertRating();
          insertTotalandCountRating();
        })
      ),
    );
  }

  Future<void> showInitialRating() async {
    try {
      // Check if user has already rated this seller
      DocumentSnapshot<Map<String, dynamic>> ratingDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.sellerUid)
          .collection('ratings')
          .doc(widget.currentUserUid)
          .get();

      if (ratingDoc.exists) {
        final data = ratingDoc.data();
        if (data != null && data.containsKey('rating')) {
          setState(() {
            currentRating = (data['rating'] ?? 0).toDouble();
          });
        }
      } 
    } catch (e, stack) {
      await reportErrorToCrashlytics(
        e,
        stack,
        reason: 'showInitialRating error for seller ${widget.sellerUid} and user ${widget.currentUserUid}',
      );
      // Keep currentRating as 0 on error
      setState(() {
        currentRating = 0;
      });
    }
  }

  Future<void> insertRating() async {
    await FirebaseFirestore.instance
      .collection('Users')
      .doc(widget.sellerUid)
      .collection('ratings')
      .doc(widget.currentUserUid)
      .set({
        'raterUid': widget.currentUserUid,
        'rating': currentRating,
      });
  }
  Future<void> insertTotalandCountRating() async {
  try {
    // First, get all ratings for this seller
    QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.sellerUid)
        .collection('ratings')
        .get();

    if (ratingsSnapshot.docs.isEmpty) return;

    // Calculate total ratings and count
    double totalRatings = 0;
    int numberOfRatings = ratingsSnapshot.docs.length;

    for (var doc in ratingsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalRatings += (data['rating'] ?? 0).toDouble();
    }

    // Calculate average rating
    double averageRating = totalRatings / numberOfRatings;

    // Update the sellerDetails map with proper field syntax
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.sellerUid)
        .update({
          'sellerDetails.ratinginfo.totalRatings': totalRatings,
          'sellerDetails.ratinginfo.numberOfRatings': numberOfRatings,
          'sellerDetails.ratinginfo.averageRating': averageRating, // Also store average for easy access
        });

  } catch (e, stack) {
    await reportErrorToCrashlytics(
      e,
      stack,
      reason: 'insertTotalandCountRating error for seller ${widget.sellerUid}',
    );
  }
}
}

class AverageRating extends StatefulWidget {
  final String sellerUid;
  const AverageRating({
    super.key,
    required this.sellerUid,
  });

  @override
  State<AverageRating> createState() => _AverageRatingState();
}

class _AverageRatingState extends State<AverageRating> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.sellerUid)
            .snapshots(),
        builder: (context, snapshot) {
          double averageRating = 0;
          int numberOfRatings = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            try {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              
              if (data.containsKey('sellerDetails')) {
                Map<String, dynamic> sellerDetails = data['sellerDetails'];
                
                if (sellerDetails.containsKey('ratinginfo')) {
                  Map<String, dynamic> ratinginfo = sellerDetails['ratinginfo'];
                  averageRating = (ratinginfo['averageRating'] ?? 0).toDouble();
                  numberOfRatings = ratinginfo['numberOfRatings'] ?? 0;

                  // CardType cardType = getCardType(averageRating, numberOfRatings);
                  // Map<String, Color> cardColors = getCardColors(cardType);

                  // WidgetsBinding.instance.addPostFrameCallback((_) {
                  //   if (widget.onCardColorsChanged != null) {
                  //     widget.onCardColorsChanged!(cardColors);
                  //   }
                  // });
                }
              }
            } catch (e, stack) {
              reportErrorToCrashlytics(
                e,
                stack,
                reason: 'AverageRating StreamBuilder error for seller ${widget.sellerUid}',
              );
            }
          }

          return Row(
            children: [
              StarRating(
                size: 20.0,
                rating: averageRating,
                color: Colors.yellow,
                allowHalfRating: true,
                starCount: 5,
              ),
              const SizedBox(width: 8),
              Text(
                numberOfRatings > 0 
                    ? '${averageRating.toStringAsFixed(1)} ($numberOfRatings)'
                    : '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: userorseller ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SimpleCommentBox extends StatelessWidget {
  final String sellerUid;
  final Future<bool> checkIfSameUser;
  
  const SimpleCommentBox({
    super.key,
    required this.sellerUid,
    required this.checkIfSameUser
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: userorseller ? sellergrey : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentsPage(
                sellerUid: sellerUid,
                checkIfSameUser: checkIfSameUser,
              )
            )
          );
        },
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: userorseller ? sellergrey.withOpacity(0.5) : Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Yorum yazın...',
                  style: TextStyle(
                    color: userorseller ? Colors.white70 : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.send, 
                color: Colors.white, 
                size: 20
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      height: heigth*0.37,
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
        if (sellerUid == currentUser) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kullanıcı kendisi ile sohbet edemez'),
              backgroundColor: Colors.red,
            )
          );
        } else {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              sharedValues.onTapped = false;
              return MessagePage();  
            },
          ),
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






