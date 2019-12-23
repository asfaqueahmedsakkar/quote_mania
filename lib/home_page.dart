import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quote_mania/all_quotes.dart';
import 'package:quote_mania/widget/page_indicator.dart';
import 'package:quote_mania/widget/shareable_section.dart';
import 'dart:ui' as painting;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animationController;
  double page = 0.0;
  DocumentSnapshot documentToShow;
  GlobalKey _shareableSectionKey;

  @override
  void initState() {
    _pageController = new PageController(viewportFraction: 0.66);
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 250));
    _animationController.value = 0;

    _pageController.addListener(() {
      page = _pageController.page;
    });
    _shareableSectionKey = new GlobalKey();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: Text(
              "Latest",
              style: GoogleFonts.raleway(
                fontSize: 24.0,
                fontWeight: FontWeight.w300,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream:
                  Firestore.instance.collection("quotes").limit(5).snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    PageView(
                      physics: BouncingScrollPhysics(),
                      controller: _pageController,
                      children: List.generate(
                          snapshot.data.documents.length + 1, (index) {
                        if (index == snapshot.data.documents.length)
                          return Center(
                            child: AnimatedBuilder(
                                animation: _pageController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    origin: Offset(
                                        ((page ?? 0.0) - index).clamp(-1, 1) *
                                            120.0,
                                        160.0),
                                    angle: pi *
                                        (index - (page ?? 0.0)).clamp(-1, 1) *
                                        0.04,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      width: 240.0,
                                      height: 320.0,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: 80.0,
                                            height: 80.0,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey[400],
                                                  width: 1.0,
                                                )),
                                            child: RawMaterialButton(
                                              focusElevation: 0.0,
                                              highlightElevation: 0.0,
                                              elevation: 0.0,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AllQuotes()));
                                              },
                                              constraints:
                                                  BoxConstraints.expand(),
                                              fillColor: Colors.grey[100],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(48.0),
                                              ),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                size: 32.0,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 24.0,
                                          ),
                                          Text(
                                            "VIEW ALL",
                                            style: GoogleFonts.openSans(
                                              fontSize: 12.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          );

                        return _quoteAnimatedView(
                          snapshot.data.documents[index],
                          index,
                        );
                      }),
                    ),
                    Positioned(
                      child: AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) => PageIndicator(
                          page: page ?? 0,
                          pageLength: snapshot.data.documents.length + 1,
                        ),
                      ),
                      bottom: 80.0,
                    ),
                  ],
                );
              }),
        ),
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double padding = (16 * _animationController.value);
            return _animationController.value == 0.0
                ? Container()
                : AnimatedQuoteView(
                    shareableSectionKey: _shareableSectionKey,
                    animationController: _animationController,
                    documentToShow: documentToShow,
                    padding: padding,
                  );
          },
        )
      ],
    );
  }

  Center _quoteAnimatedView(DocumentSnapshot snapshot, int index) {
    return Center(
      child: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          return Transform.rotate(
            origin: Offset(((page ?? 0.0) - index).clamp(-1, 1) * 120.0, 160.0),
            angle: pi * (index - (page ?? 0.0)).clamp(-1, 1) * 0.04,
            child: GestureDetector(
              child: QuoteView(
                snapshot: snapshot,
              ),
              onTap: () {
                documentToShow = snapshot;
                _animationController.forward();
              },
            ),
          );
        },
      ),
    );
  }
}

class AnimatedQuoteView extends StatelessWidget {
  const AnimatedQuoteView({
    Key key,
    @required AnimationController animationController,
    @required this.documentToShow,
    this.padding,
    this.shareableSectionKey,
  })  : _animationController = animationController,
        super(key: key);

  final AnimationController _animationController;
  final DocumentSnapshot documentToShow;
  final double padding;
  final GlobalKey shareableSectionKey;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _animationController.reverse(),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaY: 2.5,
          sigmaX: 2.5,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            color: Colors.black26,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 60.0,
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 240.0 + 80 * _animationController.value,
                      height: 320 + 100 * _animationController.value,
                      child: Stack(
                        children: <Widget>[
                          RepaintBoundary(
                            key: shareableSectionKey,
                            child: ShareableSection(
                                documentToShow: documentToShow,
                                animationController: _animationController,
                                padding: padding),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () async {
                                  RenderRepaintBoundary boundary =
                                      shareableSectionKey.currentContext
                                          .findRenderObject();
                                  painting.Image image =
                                      await boundary.toImage(pixelRatio: 3.0);
                                  ByteData pngBytes = await image.toByteData(
                                      format: ImageByteFormat.png);
                                  Share.file(
                                      "quote",
                                      "quote.png",
                                      pngBytes.buffer.asUint8List(),
                                      'image/png');
                                },
                                iconSize: 1 + 24 * _animationController.value,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuoteView extends StatelessWidget {
  final DocumentSnapshot snapshot;

  const QuoteView({
    Key key,
    this.snapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: CachedNetworkImageProvider(
            snapshot["author_image"],
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.9),
            BlendMode.srcATop,
          ),
        ),
      ),
      width: 240.0,
      height: 320.0,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  snapshot["quote"],
                  style: GoogleFonts.openSans(
                    fontSize: 18.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 6,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 4.0,
          ),
          Text(
            ("- ${snapshot["author"]}").toUpperCase(),
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
