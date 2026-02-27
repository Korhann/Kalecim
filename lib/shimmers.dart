import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';
import 'package:shimmer/shimmer.dart';

class SellerGridShimmer extends StatelessWidget {
  const SellerGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: 6, // showing 6 shimmer cards
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 15,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    height: 15,
                    width: 60,
                    color: Colors.grey[400],
                  ),
                  const Spacer(),
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MessagesShimmer extends StatelessWidget {
  const MessagesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          height: 24,
          width: 120,
          color: userorseller ? sellerbackground : Colors.grey.shade300,
        ),
        backgroundColor: userorseller ? sellerbackground :Colors.white,
        centerTitle: true,
      ),
      backgroundColor: userorseller ? sellerbackground :Colors.white,
      body: ListView.builder(
        itemCount: 8, // number of shimmer items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: userorseller ? sellerbackground : Colors.grey.shade300,
            highlightColor: userorseller ? Colors.grey.shade700 : Colors.grey.shade100,
            child: ListTile(
              leading: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: userorseller ? sellerbackground : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              title: Container(
                height: 14,
                width: double.infinity,
                color: userorseller ? sellerbackground : Colors.grey.shade300,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              subtitle: Container(
                height: 10,
                width: double.infinity,
                color: userorseller ? sellerbackground : Colors.grey.shade300,
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppointmentsShimmer extends StatelessWidget {
  const AppointmentsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : Colors.white,
      ),
      backgroundColor: userorseller ? sellerbackground : background,
      body: Padding(
        padding: EdgeInsets.only(top: 40),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          itemCount: 4, // show 4 shimmer items
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Shimmer.fromColors(
                  baseColor: userorseller ? sellergrey : Colors.grey.shade300,
                  highlightColor: userorseller ? Colors.grey.shade700 : Colors.grey.shade100,
                  child: Container(
                    color: userorseller ? sellerbackground :Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Surname Placeholder
                          Container(
                            height: 16,
                            width: 150,
                            color: userorseller ? sellergrey : Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                          // Day + Hour Placeholder
                          Container(
                            height: 14,
                            width: 100,
                            color: userorseller ? sellergrey : Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                          ),
                          // Location row
                          Row(
                            children: [
                              Container(
                                height: 14,
                                width: 14,
                                color: userorseller ? sellergrey : Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Container(
                                height: 14,
                                width: 80,
                                color: userorseller ? sellergrey :  Colors.white,
                              ),
                              const Spacer(),
                              Container(
                                height: 30,
                                width: 60,
                                color: userorseller ? sellergrey : Colors.white,
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Approve/Reject buttons shimmer if needed
                          Container(
                            height: 35,
                            width: double.infinity,
                            color: userorseller ? sellergrey : Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
class FavouritesShimmer extends StatelessWidget {
  const FavouritesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(10),
      itemCount: 5, // Show shimmer for 5 items
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: ListTile(
              contentPadding: const EdgeInsets.all(15),
              leading: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              title: Container(
                height: 16,
                width: 120,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
              ),
              subtitle: Container(
                height: 14,
                width: 80,
                color: Colors.white,
              ),
              trailing: Container(
                width: 15,
                height: 15,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
class ApprovedFieldsShimmer extends StatelessWidget {
  const ApprovedFieldsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
      ),
      backgroundColor: background,
      body: ListView.builder(
        itemCount: 6, // You can adjust the placeholder count
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,  // Keep it clean on a white background
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Container(
                  height: 16,
                  width: 150,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
class SellerDetailsShimmer extends StatelessWidget {
  const SellerDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: userorseller ? sellerbackground : background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200, width: double.infinity, color: Colors.white), // image placeholder
              const SizedBox(height: 20),
              Container(height: 20, width: 150, color: Colors.white), // name placeholder
              const SizedBox(height: 10),
              Container(height: 20, width: 100, color: Colors.white), // location placeholder
              const SizedBox(height: 30),
              Container(height: 40, width: double.infinity, color: Colors.white), // fields list placeholder
              const SizedBox(height: 20),
              Container(height: 200, width: double.infinity, color: Colors.white), // hours list placeholder
            ],
          ),
        ),
      ),
    );
  }
}
class SellerDetailsDarkShimmer extends StatelessWidget {
  const SellerDetailsDarkShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userorseller ? sellerbackground : background,
      appBar: AppBar(
        backgroundColor: sellerbackground,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Shimmer.fromColors(
          baseColor: sellergrey,
          highlightColor: Colors.grey.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 200, width: double.infinity, color: sellergrey), // image placeholder
              const SizedBox(height: 20),
              Container(height: 20, width: 150, color: sellergrey), // name placeholder
              const SizedBox(height: 10),
              Container(height: 20, width: 100, color: sellergrey), // location placeholder
              const SizedBox(height: 30),
              Container(height: 40, width: double.infinity, color: sellergrey), // fields list placeholder
              const SizedBox(height: 20),
              Container(height: 200, width: double.infinity, color: sellergrey), // hours list placeholder
            ],
          ),
        ),
      ),
    );
  }
}
class SellerAddPageShimmer extends StatelessWidget {
  const SellerAddPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerbackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: sellerbackground,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: Container(height: 45, width: 180, color: sellergrey),
        ),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: sellergrey,
          highlightColor: Colors.grey.shade700,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerLabel(width: 140),
                const SizedBox(height: 10),
                Container(height: 110, width: double.infinity, color: sellergrey),

                const SizedBox(height: 30),
                _shimmerLabel(width: 100),
                const SizedBox(height: 10),
                Container(height: 60, width: double.infinity, color: sellergrey),

                const SizedBox(height: 40),
                _shimmerLabel(width: 80),
                const SizedBox(height: 15),
                Container(height: 60, width: double.infinity, color: sellergrey),

                const SizedBox(height: 20),
                _shimmerLabel(width: 110),
                const SizedBox(height: 15),
                Container(height: 60, width: double.infinity, color: sellergrey),

                const SizedBox(height: 10),
                _shimmerList(height: 30),

                const SizedBox(height: 30),
                _shimmerLabel(width: 80),
                const SizedBox(height: 20),
                _shimmerDayHourRow(),

                const SizedBox(height: 20),
                _shimmerLabel(width: 60),
                const SizedBox(height: 10),
                Container(height: 60, width: double.infinity, color: sellergrey),

                const SizedBox(height: 10),
                Container(height: 40, width: double.infinity, color: sellergrey),

                const SizedBox(height: 40),
                Center(
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      color: sellergrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shimmerLabel({required double width}) {
    return Container(height: 20, width: width, color: sellergrey);
  }

  Widget _shimmerList({required double height}) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            color: sellergrey,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _shimmerDayHourRow() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, __) => Column(
          children: [
            Container(height: 20, width: 70, color: sellergrey),
            const SizedBox(height: 8),
            Container(height: 90, width: 70, color: sellergrey),
          ],
        ),
      ),
    );
  }
}

class KeeperRequestsShimmer extends StatelessWidget {
  const KeeperRequestsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: width,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: width * 0.4,
                            height: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: width * 0.25,
                            height: 12,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
class ShareGigCreationShimmer extends StatelessWidget {
  const ShareGigCreationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(7, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Container(
                width: width,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
class ShareGigViewShimmer extends StatelessWidget {
  const ShareGigViewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 22, width: width * 0.5, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 16)),
              Container(height: 16, width: width * 0.3, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 12)),
              Container(height: 16, width: width * 0.4, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 12)),
              Container(height: 16, width: width * 0.25, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 12)),
              Row(
                children: [
                  Container(height: 36, width: 36, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Container(height: 16, width: width * 0.2, color: Colors.grey.shade300),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

