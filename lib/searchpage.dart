import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/SellerGridItem.dart';
import 'package:kiralik_kaleci/appointmentspage.dart';
import 'package:kiralik_kaleci/filterpage.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/responsiveTexts.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';
import 'sellerDetails.dart';
import 'sharedvalues.dart';


class GetUserData extends StatefulWidget {
  const GetUserData({super.key});

  @override
  State<GetUserData> createState() => _GetUserDataState();
}

class _GetUserDataState extends State<GetUserData> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _userStream;

  String? nameFilter, cityFilter, districtFilter, fieldFilter, daysFilter;
  int? minFilter = 0, maxFilter = 0;

  bool isLoading = true;

  // for the lazy loading of the gridview
  final ScrollController _scrollController = ScrollController();
  List<QueryDocumentSnapshot<Map<String, dynamic>>> sellers = [];
  bool hasMore = true;
  DocumentSnapshot? lastDoc;
  static const int batchSize = 10;
  late Query<Map<String,dynamic>> globalquery;

  bool queryGiven = false;


  @override
  void initState() {
    super.initState();
    getUserStream();
    _fetchSellers();
    _scrollController.addListener(_onScroll);
    userorseller = false;
    
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchSellers() async {
    if (isLoading || !hasMore) return;
    setState(() => isLoading = true);

    // if query is changed in apply filters, does not enter here
    if (!queryGiven) {
      globalquery = _firestore
      .collection("Users")
      .where('sellerDetails', isNotEqualTo: null)
      .orderBy('sellerDetails.sellerFullName')
      .limit(batchSize);
    }

    if (lastDoc != null) {
      globalquery = globalquery.startAfterDocument(lastDoc!);
    }

    final snapshot = await globalquery.get();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
      sellers.addAll(snapshot.docs);
    }
    if (snapshot.docs.length < batchSize) {
      hasMore = false;
    }
    setState(() => isLoading = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _fetchSellers();
    }
  }

  Future<void> getUserStream() async {
    try {
      _userStream = _firestore
        .collection("Users")
        .where('sellerDetails', isNotEqualTo: null)
        .snapshots();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, stack) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      await reportErrorToCrashlytics(e, stack, reason: 'Search page getUserStream error for the user ${FirebaseAuth.instance.currentUser!.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  final height = MediaQuery.sizeOf(context).height;
  final bannerHeight = width * 0.3;

  return SafeArea(
    child: Scaffold(
      backgroundColor: background,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: Column(
          children: [
            _HeaderSection(
              onFilterTap: _navigateToFilterPage,
              onNotificationTap: _navigateToAppsPage,
              width: width,
              height: height,
            ),
            ImageSliderDemo(width: width, height: bannerHeight),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading && sellers.isEmpty
                  ? SellerGridShimmer()
                  : sellers.isEmpty
                      ? _EmptyState()
                      : _SellerGrid(
                          docs: sellers,
                          onCardTap: _handleCardTap,
                          isLoading: isLoading,
                          scrollController: _scrollController,
                          hasMore: hasMore,
                        ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void _navigateToFilterPage() async {
    final filters = await Navigator.push(
      context,
      _createRoute(FilterPage(selectedDay: daysFilter)),
    );
    runFilters(filters);
  }

  void _navigateToAppsPage() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AppointmentsPage(whereFrom: 'homePage')));
    } catch (e, stack) {
      reportErrorToCrashlytics(e, stack, reason: 'failed navigation to appsPage');
    }
  }

  void _handleCardTap(BuildContext context, Map<String, dynamic> sellerDetails,String sellerUid) {
    try {
      sharedValues.sellerUid = sellerUid;
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerDetailsPage(
            sellerDetails: sellerDetails, sellerUid: sellerUid, wherFrom: '',),
      ),
    );
    } catch (e, stack) {
      reportErrorToCrashlytics(e, stack, reason: 'Search page card tap error ${FirebaseAuth.instance.currentUser!.uid}');
    }
  }

  void runFilters(final filter) {
    if (filter != null) {
      setState(() {
        nameFilter = filter['nameFilter'];
        cityFilter = filter['cityFilter'];
        districtFilter = filter['districtFilter'];
        daysFilter = filter['daysFilter'];
        fieldFilter = filter['fieldFilter'];
        minFilter = filter['minFilter'];
        maxFilter = filter['maxFilter'];
      });
      applyFilter();
    }
  }

  void applyFilter() async{
  Query<Map<String, dynamic>> query = _firestore.collection('Users');

  try {
    if (nameFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.sellerFullName', isEqualTo: nameFilter);
  }
  if (cityFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.city', isEqualTo: cityFilter);
  }
  if (districtFilter?.isNotEmpty == true) {
    query = query.where('sellerDetails.district', isEqualTo: districtFilter);
  }
  // if both selected use querytags
  if (fieldFilter?.isNotEmpty == true && daysFilter?.isNotEmpty == true) {
    String queryTag = '${fieldFilter}_$daysFilter';
    query = query.where('sellerDetails.queryTags', arrayContains: queryTag);
  }
  if (fieldFilter?.isNotEmpty == true && daysFilter == null) {
    query = query.where('sellerDetails.fields', arrayContains: fieldFilter);
  }
  if (daysFilter?.isNotEmpty == true && fieldFilter == null) {
    query = query.where('sellerDetails.chosenDays', arrayContains: daysFilter);
  }
  if (minFilter != null && maxFilter != null) {
    query = query.where('sellerDetails.sellerPrice', isGreaterThanOrEqualTo: minFilter!).where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter!);
  } else if (minFilter != null) {
    query = query.where('sellerDetails.sellerPrice', isGreaterThanOrEqualTo: minFilter!);
  } else if (maxFilter != null) {
    query = query.where('sellerDetails.sellerPrice', isLessThanOrEqualTo: maxFilter!);
  }

  query = query.orderBy('sellerDetails.sellerFullName').limit(batchSize);  

  setState(() {
    globalquery = query;
    sellers.clear();
    lastDoc = null;
    hasMore = true;
    isLoading = false;
    queryGiven = true;
  });
  _fetchSellers();
  } catch (e, stack) {
    reportErrorToCrashlytics(e, stack, reason: 'Searchpage filters error ${FirebaseAuth.instance.currentUser!.uid}');
  }
}

  Route _createRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onNotificationTap;
  final double width;
  final double height;

  const _HeaderSection({required this.onFilterTap, required this.onNotificationTap, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {

      final iconSize = width * 0.06;
      return Container(
        width: width,
        height: height * 0.07,
        color: background,  
        padding: const EdgeInsets.only(top: 15),
        child: Row(
          children: [
            Text(
              "Kalecilerimiz",
              style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black),
              textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
            ),
            const SizedBox(width: 10),
            Icon(Icons.handshake, size: iconSize),
            const Spacer(),
            GestureDetector(
              onTap: onNotificationTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(Icons.notifications, size: iconSize, color: Colors.black),
                  ),
                  StreamBuilder<int>(
                    stream: getUnreadCount(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == 0) {
                        return SizedBox();
                      }
                      return Positioned(
                        right: 5, // Adjust position
                        top: -3,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            snapshot.data.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child:
                    Image.asset('lib/icons/setting.png', width: iconSize, height: MediaQuery.sizeOf(context).width * 0.05),
              ),
            ),
          ],
        ),
      );
  }

  Stream<int> getUnreadCount() {
    final String currentUser = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
      .collection('Users')
      .doc(currentUser)
      .collection('appointmentbuyer')
      .where('appointmentDetails.status', whereIn: ['approved', 'rejected'])
      .where('appointmentDetails.paymentStatus', isEqualTo: 'waiting')
      .where('appointmentDetails.isSeen', isEqualTo: false) 
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
      
  }  
}




class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints constraints) {
        final iconSize = MediaQuery.sizeOf(context).width * 0.08;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: iconSize, color: Colors.grey.shade500),
              const SizedBox(height: 10),
              Text(
                'İlgili sonuç bulunamadı',
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black
                ),
                textScaler: TextScaler.linear(ScaleSize.textScaleFactor(context)),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _SellerGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final Function(BuildContext, Map<String, dynamic>, String) onCardTap;
  final bool isLoading;
  final ScrollController? scrollController;
  final bool hasMore;

  const _SellerGrid({
    required this.docs,
    required this.onCardTap,
    required this.isLoading,
    required this.scrollController,
    required this.hasMore
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        int crossAxisCount = width > 600 ? 3 : 2; 

        return GridView.builder(
          controller: scrollController,
          padding: EdgeInsets.zero,
          physics: const ScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.8 / 2.3,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var sellerDetails = docs[index]['sellerDetails'];
            var sellerUid = docs[index].id;
        
            return SellerGridItem(
              sellerDetails: sellerDetails,
              sellerUid: sellerUid,
              onTap: (uid) => onCardTap(context, sellerDetails, uid),
            );
          },
        );
      },
    );
  }
}

class ImageSliderDemo extends StatelessWidget {
  final double width;
  final double height;

  final List<String> bannerImages = [
    'lib/images/kalecimafis1.jpg',
    'lib/images/kalecimafis2.jpg'
  ];

  ImageSliderDemo({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
        return SizedBox(
          width: width,
          height: height,
          child: CarouselSlider(
            options: CarouselOptions(
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              autoPlay: true,
              height: height,
              padEnds: false,
            ),
            items: bannerImages.map((item) => 
              SizedBox(
                width: width,
                child: Image.asset(
                  item,
                  width: width,
                  fit: BoxFit.fill,
                ),
              ),
            ).toList(),
          ),
        );
  }
}


