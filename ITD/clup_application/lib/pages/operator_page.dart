import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:clup_application/api/operator_utils.dart';
import 'package:clup_application/configs.dart';
import 'package:clup_application/pages/map_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OperatorPage extends StatefulWidget {
  @override
  _OperatorPageState createState() => _OperatorPageState();
}

class _OperatorPageState extends State<OperatorPage> {
  Timer timer;
  Map _queueStatus;
  String _error;

  @override
  void initState() {
    super.initState();

    _updateQueue();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => _updateQueue());
  }

  void _updateQueue() async {
    var result = await getQueueStatus();

    print(result[1]);

    if (result[0]) {
      setState(() {
        _error = null;
        _queueStatus = result[1];
      });
    } else {
      setState(() => _error = result[1]);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _buttonStyle = Theme.of(context)
        .textTheme
        .headline6
        .copyWith(color: Colors.white, fontSize: 30);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Operator Page')),
      drawer: CLupDrawer(),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: _error != null
                  ? Center(
                      child: Text(
                        _error,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _queueStatus == null
                                ? Center(child: CircularProgressIndicator())
                                : _buildQueueListView(),
                            _queueStatus == null
                                ? Center(child: CircularProgressIndicator())
                                : _buildCalledListView(),
                          ],
                        ),
                        _buildCallButton(_buttonStyle),
                        if (!kIsWeb) QrScanButton(buttonStyle: _buttonStyle),
                        _buildManualInsertionButton(),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(style) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        color: clupRed,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FlatButton.icon(
        icon: FaIcon(FontAwesomeIcons.userCheck, size: 40, color: Colors.white),
        label: Text(' Call Next Person', style: style),
        onPressed: () async {
          var result = await callFirstInQueue();

          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );

          print(result);
          _updateQueue();
        },
      ),
    );
  }

  Widget _buildQueueListView() {
    int queueLength = _queueStatus['queue_length'];
    List tickets = _queueStatus['queued_call_numbers'];

    return Column(
      children: [
        Text('Tickets in Queue', style: Theme.of(context).textTheme.headline6),
        Container(
          decoration: BoxDecoration(
            color: clupBlue1,
            borderRadius: BorderRadius.circular(10),
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5 - 10,
          padding: EdgeInsets.all(10),
          child: Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: queueLength,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: clupYellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ticket #${tickets[index].toString()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalledListView() {
    int queueLength = _queueStatus['called_tickets'];
    List tickets = _queueStatus['called_call_numbers'];

    return Column(
      children: [
        Text('Called Tickets', style: Theme.of(context).textTheme.headline6),
        Container(
          decoration: BoxDecoration(
            color: clupBlue1,
            borderRadius: BorderRadius.circular(10),
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5 - 10,
          padding: EdgeInsets.all(10),
          child: Scrollbar(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: queueLength,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Ticket #${tickets[index].toString()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInsertionButton() {
    TextEditingController controller = TextEditingController();

    TextStyle textBoxTheme = TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w500,
      fontSize: 22,
      color: clupBlue2,
    );

    TextField codeField = TextField(
      style: textBoxTheme,
      controller: controller,
      cursorColor: clupBlue1,
      decoration: InputDecoration(
        focusedBorder: new UnderlineInputBorder(
          borderSide: BorderSide(color: clupBlue1, width: 2),
        ),
        labelText: "Manual Scan Ticket Code",
        focusColor: Colors.green,
      ),
    );

    return Container(
      height: 100,
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: codeField,
          ),
          FloatingActionButton(
            backgroundColor: clupRed,
            child: FaIcon(FontAwesomeIcons.check),
            onPressed: () async {
              await callTicketID(context, controller.text);
            },
          ),
        ],
      ),
    );
  }
}

class QrScanButton extends StatelessWidget {
  const QrScanButton({
    Key key,
    @required TextStyle buttonStyle,
  })  : buttonStyle = buttonStyle,
        super(key: key);

  final TextStyle buttonStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        color: clupOrange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: FlatButton.icon(
        icon: FaIcon(FontAwesomeIcons.qrcode, size: 40, color: Colors.white),
        label: Text('  Scan QR Code', style: buttonStyle),
        onPressed: () async {
          final ticketID = await scan();

          await callTicketID(context, ticketID);
        },
      ),
    );
  }

  Future scan() async {
    ScanResult scanResult = await BarcodeScanner.scan();

    return scanResult.rawContent;
  }
}

Future callTicketID(BuildContext context, ticketID) async {
  List result = await acceptTicket(ticketID);

  if (result[0]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Valid Ticket',
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: Text('Accepted entrance with TicketID: $ticketID'),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  } else {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Invalid Ticket',
          style: TextStyle(color: Colors.red),
        ),
        content: Text(result[1].toString()),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
