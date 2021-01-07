import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/src/models/band.dart';
import 'package:band_names/src/services/socket.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bans = [];

  @override
  void initState() {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    socketProvider.subscribe('active-bands', _handleActiveBand);
    super.initState();
  }

  void _handleActiveBand(dynamic payload) {
    this.bans =
        (payload['bands'] as List).map((band) => Band.fromMap(band)).toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    socketProvider.unsubscribe('active-bands', () {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketProvider.getServerStatus == ServetStatus.Online
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red[300])
            //
            ,
          )
        ],
        title: Text(
          "Band Name",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => _bandTile(bans[index]),
              itemCount: bans.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
        elevation: 1,
      ),
    );
  }

  Widget _bandTile(Band band) {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (_) =>
          socketProvider.emit('delete-band', arguments: {'id': band.id}),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: EdgeInsets.only(left: 8.0),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Delete band",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      child: ListTile(
          leading: CircleAvatar(
            child: Text(band.name.substring(0, 2)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text(
            '${band.votes}',
            style: TextStyle(fontSize: 20),
          ),
          onTap: () =>
              socketProvider.emit('vote-band', arguments: {'id': band.id})),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("New band name:"),
          content: TextField(
            controller: textController,
          ),
          actions: <Widget>[
            MaterialButton(
              onPressed: () => this.addBandToList(textController.text),
              child: Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
            ),
          ],
        ),
      );
    }
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Text("New band name:"),
        content: CupertinoTextField(
          controller: textController,
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Add'),
            onPressed: () => this.addBandToList(textController.text),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Dismiss'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void addBandToList(String name) {
    final socketProvider = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketProvider.emit('add-band', arguments: {'name': name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    this.bans.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    final List<Color> colorList = [
      Colors.blue,
      Colors.blue[400],
      Colors.red,
      Colors.red[400],
      Colors.green,
      Colors.green[400],
    ];
    return Container(
      padding: EdgeInsets.all(20),
      width: double.infinity,
      height: 250,
      child: (dataMap != null && dataMap.isNotEmpty)
          ? PieChart(
              dataMap: dataMap,
              animationDuration: Duration(milliseconds: 800),
              // chartLegendSpacing: 32,
              // chartRadius: MediaQuery.of(context).size.width / 3.2,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring,
              ringStrokeWidth: 32,
              centerText: "Bands",
              legendOptions: LegendOptions(
                showLegendsInRow: false,
                legendPosition: LegendPosition.right,
                showLegends: true,
                legendShape: BoxShape.circle,
                legendTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: false,
                showChartValuesOutside: false,
              ),
            )
          : Container(),
    );
  }
}
