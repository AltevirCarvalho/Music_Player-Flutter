import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_player/screens/home_page.dart';
import 'package:provider/provider.dart';

import 'controllers/controller.dart';
import 'controllers/music_controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AudioService.connect();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AudioService.connect();
        break;
      case AppLifecycleState.paused:
        AudioService.disconnect();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Controller>(
          create: (_) => Controller(),
        ),
        Provider<MusicController>(
          create: (_) => MusicController(),
        )
      ],
      child: MaterialApp(
        title: 'Músicas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Color(0xff121212),
          fontFamily: 'Serif',
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.black.withOpacity(0)),
        ),
        debugShowCheckedModeBanner: false,
        home: HomePage(),
      ),
    );
  }
}
