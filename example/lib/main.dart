import 'package:flutter/material.dart';
import 'package:scroll/scroll.dart' as scroll;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // platform: TargetPlatform.iOS,
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final double offsetToArmed = 80;
  final scroll.IScrollController iScrollController = scroll.IScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: scroll.Scroll(
        controller: iScrollController,
        offsetToArmed: offsetToArmed,
        headerBuilder: (scroll.ScrollValue value, double ratio) {
          scroll.ScrollRefreshIndicatorStatus state = value.refreshIndicatorStatus;
          String content = '';
          if (state.drag) {
            content = '??????????????????';
          }
          if (state.armed) {
            content = '??????????????????';
          }
          if (state.refreshing) {
            content = '???????????????';
          }
          if (state.done) {
            content = '????????????';
          }
          if (state.error) {
            content = '????????????';
          }
          if (state.hiding) {
            content = '?????????';
          }
          return Transform.translate(
            offset: Offset(0, -(offsetToArmed - ratio * offsetToArmed)),
            child: Container(
              color: Colors.grey,
              child: Center(
                child: Text(content),
              ),
            ),
          );
        },
        footerBuilder: (scroll.ScrollValue value) {
          scroll.ScrollLoadIndicatorStatus state = value.loadIndicatorStatus;

          String content = '';
          if (state.loading) {
            content = '?????????';
          }
          if (state.done) {
            content = '????????????';
          }
          if (state.error) {
            content = '????????????';
          }
          return Center(child: Text(content));
        },
        onRefresh: () async {
          await Future.delayed(Duration(milliseconds: 2000));
        },
        onLoad: () async {
          await Future.delayed(Duration(milliseconds: 2000));
          throw 1;
        },
        // child: ListView.builder(
        //   primary: false,
        //   shrinkWrap: true,
        //   itemBuilder: (context, index) => ListTile(title: Text(index.toString())),
        //   itemCount: 20,
        // )
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListTile(title: Text(index.toString())),
            childCount: 50,
          ),
        ),
      ),
    );
  }
}
