import 'package:clup_application/api/information_provider.dart';
import 'package:clup_application/api/ticket_handler.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../configs.dart';

class StoreViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.popAndPushNamed(context, '/map');
          return true;
        },
        child: FutureBuilder(
            future: getSelectedStore(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              Map store = snapshot.data;

              return LayoutBuilder(builder: (context, constraints) {
                return Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: constraints.constrainWidth(600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDescription(context, store),
                        SizedBox(height: 10),
                        _buildComingSoon(context),
                        SizedBox(height: 10),
                        _buildQueueButton(context),
                      ],
                    ),
                  ),
                );
              });
            }),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Store View'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.popAndPushNamed(context, '/map');
        },
      ),
      actions: [
        IconButton(icon: Icon(Icons.share), onPressed: () {}),
        IconButton(
          icon: Icon(Icons.star_outline_rounded),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildQueueButton(BuildContext context) {
    return FlatButton(
      height: 100,
      minWidth: double.infinity,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Wrap(
        children: [
          Text(
            'Join the Queue',
            style: Theme.of(context).textTheme.headline6.copyWith(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, top: 4),
            child: FaIcon(
              FontAwesomeIcons.arrowRight,
              color: Colors.white,
            ),
          ),
        ],
      ),
      color: clupRed,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => VirtualQueueAlert(),
        );
      },
    );
  }

  Widget _buildComingSoon(context) {
    return Expanded(
      child: Opacity(
        opacity: 0.5,
        child: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Reserve an Entrance \nComing soon!',
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Map store) {
    return RichText(
      text: TextSpan(
        text: store['chain_name'] + '\n',
        style: Theme.of(context).textTheme.headline4.copyWith(fontSize: 30),
        children: [
          TextSpan(
            text: 'OPEN' + '\n',
            style: Theme.of(context)
                .textTheme
                .headline4
                .copyWith(color: Colors.greenAccent, fontSize: 34),
          ),
          TextSpan(
            text: store['city'] + '\n',
            style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 24),
          ),
          TextSpan(
            text: store['address'],
            style: Theme.of(context).textTheme.headline5.copyWith(fontSize: 24),
          ),
        ],
      ),
    );
  }
}

class VirtualQueueAlert extends StatelessWidget {
  const VirtualQueueAlert({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Do you want to join the Virtual Queue?"),
      // content: SingleChildScrollView(
      //   child: RichText(
      //     text: TextSpan(
      //       text: 'People in queue:\n',
      //       style: Theme.of(context).textTheme.button,
      //       children: [
      //         TextSpan(
      //           text: '23\n',
      //           style: Theme.of(context)
      //               .textTheme
      //               .bodyText1
      //               .copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
      //         ),
      //         TextSpan(
      //           text: 'Estimated waiting time:\n',
      //         ),
      //         TextSpan(
      //           text: '35 minutes\n',
      //           style: Theme.of(context)
      //               .textTheme
      //               .bodyText1
      //               .copyWith(fontWeight: FontWeight.bold, color: Colors.red),
      //         ),
      //         TextSpan(
      //           text: 'Do you want to join the virtual queue?',
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      actions: [
        FlatButton(
          child: Text("CANCEL"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text("OK", style: TextStyle(color: Colors.black)),
          onPressed: () async {
            Map store = await getSelectedStore();
            List result = await createTicket(store['store_id']);

            if (!result[0]) {
              showDialog(
                context: context,
                builder: (builder) => AlertDialog(
                  title: Text('Error'),
                  content: Text(result[1]),
                  actions: [
                    FlatButton(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
              );
            }

            Navigator.pushNamed(context, '/store/ticket');
          },
        )
      ],
    );
  }
}
