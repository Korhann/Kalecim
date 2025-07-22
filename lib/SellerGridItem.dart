import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

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
    var imageUrl = sellerDetails['imageUrls'][0] ?? "";
    var city = sellerDetails['city'] ?? "";
    var district = sellerDetails['district'] ?? "";

    return GestureDetector(
      onTap: () => onTap(sellerUid),
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.zero,
        elevation: 0,
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Padding(
          padding: EdgeInsets.all(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
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
