import 'package:clip_shadow/clip_shadow.dart';
import 'package:clup_application/api/information_provider.dart';
import 'package:clup_application/api/ticket_handler.dart';
import 'package:clup_application/main.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';
import '../configs.dart';

class TicketPage extends StatefulWidget {
  @override
  _TicketPageState createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  Timer timer;
  Map _ticket, store;

  String _error;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(Duration(seconds: 10), (Timer t) async {
      var result = await updateTicketInfo();

      if (result[0]) {
        if (_ticket != null && result[1] == null) {
          Navigator.popAndPushNamed(context, '/map');

          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (builder) => AlertDialog(
              title: Text('Ticket expired or deleted or used'),
              actions: [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          );

          dispose();
        } else {
          if (result[1]['called_on'] != null) {
            showDialog(
              context: context,
              builder: (builder) => AlertDialog(
                title: Text('You have been called!'),
                content: Text('Please approach the entrance'),
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            );
          }

          setState(() => _ticket = result[1]);
        }
      } else {
        setState(() => _error = result[1]);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    try {
      super.dispose();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: FutureBuilder(
          future: Future(() async {
            return [await getSelectedStore(), await getTicket()];
          }),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            store = snapshot.data[0];
            _ticket = snapshot.data[1];

            var expireDate = DateTime.parse(_ticket['expires_on']);

            return SafeArea(
              child: Center(
                child: _buildTicket(expireDate),
              ),
            );
          },
        ),
      ),
    );
  }

  ClipShadow _buildTicket(DateTime expireDate) {
    return ClipShadow(
      boxShadow: _buildTicketShadow(),
      clipper: TicketClipper(),
      child: LayoutBuilder(builder: (context, constraints) {
        Size ticketSize = constraints
            .constrainSizeAndAttemptToPreserveAspectRatio(Size(1000, 1600));
        return Container(
          width: ticketSize.width - 40,
          height: ticketSize.height - 40,
          decoration: _buildTicketDecoration(),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _buildTitle(context, store),
                  _buildValidityDescription(context, store, _ticket),
                ],
              ),
              Positioned(
                top: (ticketSize.height - 40) * 0.45,
                child: _buildMiddleDecoration(
                  context,
                  ticketSize.width,
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: FlatButton(
                  child: Text(
                    'Cancel Ticket',
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .copyWith(color: clupRed),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => CancelTicketAlert(
                        fatherWidget: this,
                      ),
                    );
                  },
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_error != null)
                    Text(
                      _error,
                      style: TextStyle(color: Colors.red),
                    ),
                  CustomQRViewer(ticket: _ticket),
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text(
                      _ticket['ticket_id'].toString().padLeft(10, '0'),
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 40),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: TimerWidget(date: expireDate),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  BoxDecoration _buildTicketDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        )
      ],
    );
  }

  List<BoxShadow> _buildTicketShadow() {
    return [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 5,
        blurRadius: 7,
        offset: Offset(0, 3),
      )
    ];
  }

  Widget _buildValidityDescription(context, store, ticket) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: 'Queue Position: ',
              style: Theme.of(context).textTheme.headline6,
              children: [
                TextSpan(
                  text: '${ticket["line_position"]}',
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(color: Colors.red, fontSize: 32),
                ),
              ],
            ),
          ),
          Text('#${ticket["call_number"]}',
              style: Theme.of(context)
                  .textTheme
                  .headline5
                  .copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildTitle(context, store) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: clupBlue1,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            store['chain_name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontSize: 34, color: Colors.white),
          ),
          Text(
            store['city'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(fontSize: 22, color: Colors.white),
          ),
          Text(
            store['address'],
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleDecoration(context, width) {
    return Center(child: DotWidget(totalWidth: width));
  }
}

class CustomQRViewer extends StatefulWidget {
  const CustomQRViewer({
    Key key,
    @required this.ticket,
  }) : super(key: key);

  final Map ticket;

  @override
  _CustomQRViewerState createState() => _CustomQRViewerState();
}

class _CustomQRViewerState extends State<CustomQRViewer> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: GestureDetector(
            onTap: () => setState(() => open = !open),
            child: AnimatedContainer(
              width: MediaQuery.of(context).size.height * (open ? 0.5 : 0.2),
              color: Colors.white.withAlpha(open ? 255 : 0),
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 200),
              child: QrImage(
                data: widget.ticket['ticket_id'].toString(),
                version: QrVersions.auto,
              ),
            ),
          ),
        ),
        if (!open)
          Center(
            heightFactor: 3.5,
            child: FlatButton(
              onPressed: () => setState(() => open = !open),
              child: Container(
                decoration: BoxDecoration(
                  color: clupRed.withAlpha(220),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  ' Tap to enlarge ',
                  style: Theme.of(context)
                      .textTheme
                      .headline5
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
  final cutPerc = 0.45;

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * cutPerc - 20)
      ..lineTo(size.width - 20, size.height * cutPerc)
      ..lineTo(size.width, size.height * cutPerc + 20)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * cutPerc + 20)
      ..lineTo(20, size.height * cutPerc)
      ..lineTo(0, size.height * cutPerc - 20);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 9, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DotWidget extends StatelessWidget {
  final double totalWidth, dashWidth, emptyWidth, dashHeight;

  final Color dashColor;

  const DotWidget({
    this.totalWidth = 300,
    this.dashWidth = 10,
    this.emptyWidth = 5,
    this.dashHeight = 2,
    this.dashColor = Colors.black,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        totalWidth ~/ (dashWidth + emptyWidth),
        (_) => Container(
          width: dashWidth,
          height: dashHeight,
          color: dashColor,
          margin: EdgeInsets.only(left: emptyWidth / 2, right: emptyWidth / 2),
        ),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final DateTime date;

  const TimerWidget({
    Key key,
    @required this.date,
  }) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer _timer;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      setState(() {
        _currentDate = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validFor = widget.date.difference(_currentDate).inSeconds;

    final message = validFor > 0
        ? 'Expires in: ${validFor ~/ 60}:${(validFor % 60).toString().padLeft(2, '0')}'
        : 'Ticket Expired';

    return Container(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headline6.copyWith(
            fontSize: 30,
            color: validFor > 0 ? Colors.greenAccent : Colors.red),
      ),
    );
  }
}

class CancelTicketAlert extends StatelessWidget {
  const CancelTicketAlert({
    Key key,
    @required this.fatherWidget,
  }) : super(key: key);

  final _TicketPageState fatherWidget;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Do you really want to cancel the ticket?"),
      actions: [
        FlatButton(
          child: Text("Keep ticket"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text("Confirm Delete", style: TextStyle(color: Colors.red)),
          onPressed: () async {
            await cancelTicket();
            await write(key: 'ticket', value: null);
            Navigator.popAndPushNamed(context, '/map');
            fatherWidget.dispose();
          },
        )
      ],
    );
  }
}
