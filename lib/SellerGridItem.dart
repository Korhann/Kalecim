import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/responsive/responsivedesign.dart';
import 'package:kiralik_kaleci/sellerDetails.dart';
import 'package:kiralik_kaleci/utils/crashlytics_helper.dart';

class SellerGridItem extends StatelessWidget {
  final Map<String, dynamic> sellerDetails;
  final String sellerUid;
  final Function(String) onTap;

  const SellerGridItem({
    super.key,
    required this.sellerDetails,
    required this.sellerUid,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var fullName = sellerDetails['sellerFullName'] ?? "Bilinmeyen";
    var imageUrls = sellerDetails['imageUrls'] as List<dynamic>? ?? [];
    var imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : "";
    var city = sellerDetails['city'] ?? "";
    var district = sellerDetails['district'] ?? "";

    return GestureDetector(
      onTap: () => onTap(sellerUid),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Main image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        height: 160,
                        width: MediaQuery.sizeOf(context).width,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Colors.white),
                        errorWidget: (context, url, error) => Container(color: Colors.white),
                      ),
                    ),
                    // Rating overlay
                    Positioned(
                      top: 8,
                      left: 8,
                      child: AverageRatingCompact(sellerUid: sellerUid),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "$city, $district",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AverageRatingCompact extends StatelessWidget {
  final String sellerUid;
  
  const AverageRatingCompact({super.key, required this.sellerUid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(sellerUid)
          .snapshots(),
      builder: (context, snapshot) {
        double averageRating = 0;
        int numberOfRatings = 0;

        if (snapshot.hasData && snapshot.data!.exists) {
          try {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final sellerDetails = data['sellerDetails'] as Map<String, dynamic>?;
            final ratinginfo = sellerDetails?['ratinginfo'] as Map<String, dynamic>?;
            
            if (ratinginfo != null) {
              averageRating = (ratinginfo['averageRating'] ?? 0).toDouble();
              numberOfRatings = ratinginfo['numberOfRatings'] ?? 0;
            }
          } catch (e) {
            // Handle error silently for overlay
          }
        }

        // Don't show anything if no ratings
        if (numberOfRatings == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.yellow,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                '($numberOfRatings)',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


