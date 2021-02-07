import 'package:clup_application/api/authentication.dart';
import 'package:clup_application/main.dart';
import 'package:flutter/material.dart';
import '../configs.dart';

class SignupConfirmPage extends StatelessWidget {
  static const TextStyle textBoxTheme = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w500,
    fontSize: 22,
    color: clupBlue2,
  );

  static const TextStyle labelTheme = TextStyle(
    fontFamily: 'Nunito',
    fontWeight: FontWeight.w500,
    fontSize: 18,
    color: clupRed,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _buildBottombar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: CustomScrollView(
          slivers: [
            _buildAppbar(context),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: const EdgeInsets.all(15),
                    color: Colors.grey[300],
                    child: FutureBuilder(
                      future: _buildContent(context),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        return snapshot.data;
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Creates the bottom bar
  Widget _buildBottombar(context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: _customButton(context, 'Confirm', clupRed, onPressed: () async {
        String email = await read(key: 'register_email');
        String pwd = await read(key: 'register_pwd');
        String fullName = await read(key: 'register_fullname');

        List result = await registerAccount(fullName, email, pwd);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result[0] ? 'Registration Successful' : 'Error'),
            content: result[0] ? null : Text(result[1].toString()),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  if (result[0]) {
                    Navigator.popUntil(context, ModalRoute.withName('/login'));
                    Navigator.pushNamed(context, '/login');
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  // Creates all the fields inside the page
  Future<Widget> _buildContent(BuildContext context) async {
    return Column(
      children: [
        _customTextField('Email', await read(key: 'register_email')),
        _customTextField('Full Name', await read(key: 'register_fullname')),
      ],
    );
  }

  /// Creates a custom textfield widget
  Widget _customTextField(label, text, [isPassword = false]) {
    return TextFormField(
      initialValue: text,
      enabled: false,
      obscureText: isPassword,
      style: textBoxTheme,
      cursorColor: clupBlue1,
      decoration: InputDecoration(
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        labelStyle: labelTheme,
        labelText: label,
      ),
    );
  }

  /// Creates a custom button widget
  Widget _customButton(context, text, color, {onPressed, icon}) {
    var theme = Theme.of(context).textTheme.headline6.copyWith(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );

    return FlatButton(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) icon,
          if (icon != null) SizedBox(width: 10),
          Text(text, style: theme),
        ],
      ),
      onPressed: onPressed ?? () {},
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  SliverAppBar _buildAppbar(BuildContext context) {
    var theme =
        Theme.of(context).textTheme.headline4.copyWith(color: Colors.black);

    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black, size: 40),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text('Sign Up', style: theme),
      pinned: true,
    );
  }
}
