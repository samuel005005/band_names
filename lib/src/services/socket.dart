import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServetStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServetStatus _serverStatus = ServetStatus.Connecting;
  final _url = 'https://band-names-server-2.herokuapp.com/';
  IO.Socket _socket;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    if (this._socket != null) return;

    this._socket = IO.io(
      this._url,
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true
      },
    );
    this._socket.connect();
    this._socket.on('connect', (_) {
      _serverStatus = ServetStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      _serverStatus = ServetStatus.Offline;
      notifyListeners();
    });
  }

  ServetStatus get getServerStatus => _serverStatus;

  void emit(String event, {dynamic arguments}) =>
      this._socket.emit(event, arguments ?? {});

  void subscribe(String event, Function function) =>
      this._socket.on(event, function);

  void unsubscribe(String event, Function function) =>
      this._socket.off(event, function);
}
