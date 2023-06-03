import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../contant.dart';

class ImageView extends StatefulWidget {
  final String img;

  const ImageView({Key? key, required this.img}) : super(key: key);

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.black,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: "${widget.img}",
            placeholder: (context, url) => Center(
              child: Container(
                width: 20,
                height: 20,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulse,
                  colors: [Colors.green, primaryColor, Colors.black],

                  /// Optional, The color collections
                  strokeWidth: 2,

                  /// Optional, The stroke of the line, only applicable to widget which contains line
                ),
              ),
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
