import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class RequestsReceived extends StatefulWidget {
  final List<dynamic> gigRequesters;
  final String docId;
  final String price;
  const RequestsReceived({super.key, required this.gigRequesters, required this.docId, required this.price});

  @override
  State<RequestsReceived> createState() => _RequestsReceivedState();
}

class _RequestsReceivedState extends State<RequestsReceived> {
  
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWithBackButton(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: GlobalStyles.textStyle(
              text: 'Randevu talepleri',
              context: context,
              size: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          backgroundColor: background,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black)),
        ),
        backgroundColor: background,
        body: ListView.builder(
          itemCount: widget.gigRequesters.length,
          itemBuilder: (context,index) {
            final requestId = widget.gigRequesters[index]['requestId'];
            final name = widget.gigRequesters[index]['fullName'];
            final status = widget.gigRequesters[index]['status'];
            final timestamp = widget.gigRequesters[index]['timestamp'];
            final uid = widget.gigRequesters[index]['uid'];

            return GigRequestsView(name:name, requestId: requestId, status: status ,timestamp:timestamp, uid:uid, docId: widget.docId, price: widget.price,index:index);
          }
        ),
      ),
    );
  }
}

class GigRequestsView extends StatefulWidget {
  final String name;
  final String requestId;
  final String status;
  final Timestamp timestamp;
  final String uid;
  final String docId;
  final String price;
  final int index;
  const GigRequestsView({
    super.key,
    required this.name,
    required this.requestId,
    required this.status,
    required this.timestamp,
    required this.uid,
    required this.docId,
    required this.price,
    required this.index
  });

  @override
  State<GigRequestsView> createState() => _GigRequestsViewState();
}

class _GigRequestsViewState extends State<GigRequestsView> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentuser = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async{
        Map<String,dynamic> sellerDetails = await getSellerDetails();
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => 
            SellerDetailsPage(
              sellerDetails: sellerDetails,
              sellerUid: widget.uid,
              wherFrom: 'fromRequestsRecieved'
            )
          )
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.green[700], size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await paymentFlow(widget.docId, widget.requestId, widget.index);
                    }, 
                    style: GlobalStyles.buttonPrimary(context),
                    child: Row(
                      children: [
                        
                        Text(
                        'Ödeme ₺${widget.price}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        ),
                      ]
                    )
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String,dynamic>> getSellerDetails() async {
    try {
      DocumentReference docref = _firestore
      .collection('Users')
      .doc(widget.uid);

      DocumentSnapshot snapshot = await docref.get();
      if (!snapshot.exists) {
        return {};
      }
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.containsKey('sellerDetails')) {
        return Map<String,dynamic>.from(data['sellerDetails']);
      } 
      return {};
    } catch (e) {
      print('Error getting the seller details $e');
      return {};
    }
  }

  Future<void> paymentFlow(String docId,String requestId ,int index) async {
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('userGig')
      .doc(widget.docId)
      .collection('requests')
      .doc(requestId)
      .update({
        'requestFromKeeper.status': 'approved'
      });

    } catch (e) {
      print('Error accepting the keeper request $e');
    }
  } 
}
