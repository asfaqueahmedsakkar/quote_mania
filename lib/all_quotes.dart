import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllQuotes extends StatefulWidget {
  @override
  _AllQuotesState createState() => _AllQuotesState();
}

class _AllQuotesState extends State<AllQuotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "QUOTES",
          style: GoogleFonts.raleway(
            fontSize: 24.0,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection("quotes").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 4.0),
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot dataSnapshot = snapshot.data.documents[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white24,
                  ),
                  padding: EdgeInsets.all(12.0),
                  margin: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        dataSnapshot["quote"],
                        style: GoogleFonts.openSans(
                            fontSize: 18.0,
                            textStyle: TextStyle(color: Colors.white)),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        softWrap: true,
                        maxLines: 2,
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          ("- ${dataSnapshot["author"]}").toUpperCase(),
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                            fontSize: 14.0,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
