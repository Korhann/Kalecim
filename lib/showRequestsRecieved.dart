import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/connectivityWithBackButton.dart';
import 'package:kiralik_kaleci/shimmers.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:kiralik_kaleci/styles/designs.dart';

class RequestsReceived extends StatefulWidget {
  final List<dynamic> gigRequesters;
  final String docId;
  const RequestsReceived({super.key, required this.gigRequesters, required this.docId});

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

            return GigRequestsView(name:name, requestId: requestId, status: status ,timestamp:timestamp, uid:uid, docId: widget.docId, index:index);
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
  final int index;
  const GigRequestsView({
    super.key,
    required this.name,
    required this.requestId,
    required this.status,
    required this.timestamp,
    required this.uid,
    required this.docId,
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
    return Card(
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () async{
                    await acceptKeeperRequest(widget.docId, widget.requestId ,widget.index);
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Kabul Et'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () async{
                    await declineKeeperRequest(widget.docId, widget.requestId ,widget.index);
                  },
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reddet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // todo: userGig e requests diye collection sonrada bunları requestId si ile birlikte kullanmak daha mı mantıklı
  Future<void> acceptKeeperRequest(String docId,String requestId ,int index) async {
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

  Future<void> declineKeeperRequest(String docId,String requestId,int index) async {
    try {
      await _firestore
      .collection('Users')
      .doc(currentuser)
      .collection('userGig')
      .doc(widget.docId)
      .collection('requests')
      .doc(requestId)
      .update({
        'requestFromKeeper.status' : 'declined'
      });
    } catch (e) {
      print('Error declining the keeper request $e');
    }
  } 
}
