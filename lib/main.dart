import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';

import 'CustomCircleAvatar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      //return LayoutBuilder
      builder: (context, constraints) {
        return OrientationBuilder(
          //return OrientationBuilder
          builder: (context, orientation) {
            //initialize SizerUtil()
            SizerUtil().init(constraints, orientation); //initialize SizerUtil
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Leaderboard',
              theme: ThemeData.light(),
              home: MyHomePage(),
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Firestore firestore = Firestore.instance;
  List<DocumentSnapshot> leaders = [];
  bool isLoading = false;
  bool hasMore = true;
  int documentLimit = 30;
  DocumentSnapshot lastDocument;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //getData();
    getLeaders();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.20;
      if (maxScroll - currentScroll <= delta) {
        getLeaders();
      }
    });
  }

  Future<dynamic> getData() async {
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection("leaderboard")
        .document('ufc-257')
        .collection('leaderboard')
        .getDocuments();
    /*
    var a = querySnapshot.documents[0];
    print(a.data["ledger"]["584"]["win"].toString());
    */
    for (int i = 0; i < querySnapshot.documents.length; i++) {
      var a = querySnapshot.documents[i];
      print(
          "${a.data["id"]} position is : ${a.data["pos"]} and user is: ${a.documentID}");
    }
  }

  getLeaders() async {
    if (!hasMore) {
      print('No More leaders');
      return;
    }
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDocument == null) {
      querySnapshot = await firestore
          .collection("leaderboard")
          .document('ufc-257')
          .collection('leaderboard')
          .orderBy('pos')
          .limit(documentLimit)
          .getDocuments();
    } else {
      querySnapshot = await firestore
          .collection("leaderboard")
          .document('ufc-257')
          .collection('leaderboard')
          .orderBy('pos')
          .startAfterDocument(lastDocument)
          .limit(documentLimit)
          .getDocuments();
      print(1);
    }
    if (querySnapshot.documents.length < documentLimit) {
      hasMore = false;
    }
    lastDocument = querySnapshot.documents[querySnapshot.documents.length - 1];
    leaders.addAll(querySnapshot.documents);
    setState(() {
      isLoading = false;
    });
    print("Data is: ${leaders[1].documentID}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Pagination with Firestore'),
      ),
      body: Column(children: [
        Container(
          height: 30.0,
          child: Row(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(4.0),
                  width: 10.0.w,
                  child: Text("Pos")),
              Container(
                  padding: EdgeInsets.all(4.0),
                  width: 40.0.w,
                  child: Text("Player")),
              Container(
                  //padding: EdgeInsets.all(4.0),
                  width: 10.0.w,
                  child: Text("W")),
              Container(
                  //padding: EdgeInsets.all(4.0),
                  width: 10.0.w,
                  child: Text("L")),
              Container(
                  //padding: EdgeInsets.all(4.0),
                  width: 12.0.w,
                  child: Text("Acc")),
              Container(
                  //padding: EdgeInsets.all(2.0),
                  width: 18.0.w,
                  child: Text("vs Vegas")),
            ],
          ),
        ),
        Expanded(
          child: leaders.length == 0
              ? Center(
                  child: Text('No Data...'),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: leaders.length,
                  itemBuilder: (context, index) {
                    var winPercentage = (leaders[index].data['wins'] /
                        (leaders[index].data['losses'] +
                            leaders[index].data['wins']) *
                        100);
                    String finalValue = winPercentage.toString();
                    String percentage =
                        finalValue.substring(0, finalValue.indexOf('.'));
                    // print("$percentage");
                    return Row(
                      children: <Widget>[
                        Container(
                            width: 10.0.w,
                            child: Text(
                              leaders[index].data['pos'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                          width: 37.0.w,
                          child: Stack(
                            children: <Widget>[
                              Container(
                                  width: 10.0.w,
                                  height: 10.0.w,
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 3.0.w, 0.0, 0.0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: new CustomCircleAvatar(
                                          image: new NetworkImage(
                                              "https://via.placeholder.com/50"),
                                          initials: "Dog",
                                          circleBackground:
                                              Colors.blueAccent))),
                              Container(
                                  margin:
                                      EdgeInsets.fromLTRB(7.0.w, 0.0, 0.0, 0.0),
                                  //alignment: Alignment.centerLeft,
                                  child: ListTile(
                                    title: Text("Player A"),
                                    /*
                                      subtitle: Transform.translate(
                                          offset: Offset(0, -5),
                                          child: Text("3 steak won"))*/
                                  ))
                            ],
                          ),
                        ),
                        Container(
                            width: 10.0.w,
                            child: Text(
                              leaders[index].data['wins'].toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                            width: 10.0.w,
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 1.0.w, 0.0),
                            child: Text(
                              leaders[index].data['losses'].toString(),
                              textAlign: TextAlign.center,
                            )),
                        Container(
                            width: 14.0.w,
                            padding:
                                EdgeInsets.fromLTRB(2.0.w, 0.0, 0.0.w, 0.0),
                            child: Text(
                              "$percentage%",
                              textAlign: TextAlign.center,
                            )),
                        Container(
                            width: 16.0.w,
                            padding:
                                EdgeInsets.fromLTRB(1.0.w, 0.0, 1.0.w, 0.0),
                            child: Text(
                              leaders[index].data['vegas'].toString(),
                              textAlign: TextAlign.center,
                            ))
                      ],
                    );
                  },
                ),
        ),
        isLoading ? CircularProgressIndicator() : Container()
      ]),
    );
  }
}
