import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/src/pages/home_page.dart';
import 'package:band_names/src/pages/status_page.dart';
import 'package:band_names/src/services/socket.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => SocketService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(),
          'status': (_) => StatusPage(),
        },
      ),
    );
  }
}
