import 'package:flutter/material.dart';
import 'package:kiralik_kaleci/globals.dart';
import 'package:kiralik_kaleci/styles/colors.dart';

class Imagezoomscreen extends StatelessWidget {
  final String imageUrl;
  const Imagezoomscreen({
    super.key,
    required this.imageUrl
  });

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: userorseller ? sellerbackground : background,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: Hero(
            tag: 'imageZoomHero',
            child: Image.network(imageUrl)
          ),
        ),
      ),
    );
  }
}