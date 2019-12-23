import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareableSection extends StatefulWidget {
  const ShareableSection({
    Key key,
    @required this.documentToShow,
    @required AnimationController animationController,
    @required this.padding,
  })  : _animationController = animationController,
        super(key: key);

  final DocumentSnapshot documentToShow;
  final AnimationController _animationController;
  final double padding;

  @override
  _ShareableSectionState createState() => _ShareableSectionState();
}

class _ShareableSectionState extends State<ShareableSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            widget.documentToShow["author_image"],
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.srcATop,
          ),
        ),
      ),
      width: 240.0 + 80 * widget._animationController.value,
      height: 320 + 100 * widget._animationController.value,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          Text(
            "MOTIVATION",
            style: GoogleFonts.openSans(
              textStyle: TextStyle(letterSpacing: 2.0),
              fontSize: 12.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 2.0,
                  backgroundColor: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 2.0,
                  backgroundColor: Colors.grey,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: CircleAvatar(
                  radius: 2.0,
                  backgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: widget.padding,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        widget.documentToShow["quote"],
                        style: GoogleFonts.openSans(
                          fontSize: 18.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 6 +
                            (6 * widget._animationController.value).round(),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: widget.padding,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(
            ("- ${widget.documentToShow["author"]}").toUpperCase(),
            style: GoogleFonts.openSans(
              textStyle: TextStyle(letterSpacing: 1.0),
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
