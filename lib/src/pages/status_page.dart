import 'package:band_names/src/services/socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('${socketProvider.getServerStatus}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            socketProvider.emit('message', arguments: {'nombre': 'Flutter'}),
        child: Icon(Icons.message),
      ),
    );
  }
}
