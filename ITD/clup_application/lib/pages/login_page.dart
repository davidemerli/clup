import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:clup_application/api/authentication.dart';
import 'package:clup_application/api/ticket_handler.dart';
import 'package:flutter/material.dart';

import '../configs.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _loginFailed = false;
  String _errorMessage;

  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');

  TextEditingController ipController = TextEditingController(text: CLUP_URL);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _isLoading ? null : _buildBottombar(),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, builder) {
          double width = builder.constrainWidth(600);

          return Scrollbar(
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildLogo(),
                              _buildHeaderText(),
                              _buildTextFields(),
                              _buildForgotPwdButton(),
                              _buildLoginButton(),
                              _buildAlternativeLogin()
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  /// Creates the logo on the page
  Widget _buildLogo() {
    double logoWidth = MediaQuery.of(context).size.width * 0.5;

    return Container(
      padding: EdgeInsets.only(right: logoWidth * 0.125),
      width: logoWidth,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset('assets/clup_logo_nobg.png'),
      ),
    );
  }

  /// Creats the header Sign In text
  Widget _buildHeaderText() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign In',
            style: Theme.of(context).textTheme.headline4,
          ),
          Text(
            'Please Sign-In to use CLup services',
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }

  /// Creates the forgot password button (currently disabled)
  Widget _buildForgotPwdButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.left,
        ),
        onPressed: null,
      ),
    );
  }

  /// Creates login button
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: _button(
        context,
        'Login',
        clupRed,
        onPressed: _tryLoggingIn,
      ),
    );
  }

  /// Tries to login and changes the state of the page accordingly
  /// TODO: write better error messages
  _tryLoggingIn() async {
    CLUP_URL = ipController.text;

    setState(() => _isLoading = true);

    List result = await attemptLogin(
      emailController.text,
      passwordController.text,
    );

    bool success = result[0];

    if (success) {
      if (await isUser()) {
        List result = await updateTicketInfo();

        if (result[0] && result[1] != null) {
          Navigator.popAndPushNamed(context, '/store/ticket');
        } else {
          Navigator.popAndPushNamed(context, '/map');
        }
      } else if (await isOperator()) {
        Navigator.popAndPushNamed(context, '/operator_page');
      }
    }

    setState(() {
      _isLoading = false;
      _loginFailed = !success;

      if (_loginFailed) {
        _errorMessage = result[1];
      }
    });
  }

  /// Creates Email/Password textfields
  Widget _buildTextFields() {
    TextStyle labelTheme = TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: clupRed,
    );

    TextStyle textBoxTheme = TextStyle(
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w500,
      fontSize: 22,
      color: clupBlue2,
    );

    var emailField = TextField(
      style: textBoxTheme,
      controller: emailController,
      cursorColor: clupBlue1,
      decoration: InputDecoration(
        focusedBorder: new UnderlineInputBorder(
          borderSide: BorderSide(color: clupBlue1, width: 2),
        ),
        labelStyle: labelTheme,
        labelText: "Email",
        focusColor: Colors.green,
      ),
    );

    var passwordField = TextField(
      obscureText: true,
      style: textBoxTheme,
      controller: passwordController,
      decoration: InputDecoration(
        focusedBorder: new UnderlineInputBorder(
          borderSide: BorderSide(color: clupBlue1, width: 2),
        ),
        labelStyle: labelTheme,
        labelText: "Password",
      ),
    );

    var ipField = TextField(
      style: textBoxTheme,
      controller: ipController,
      decoration: InputDecoration(
        focusedBorder: new UnderlineInputBorder(
          borderSide: BorderSide(color: clupBlue1, width: 2),
        ),
        labelStyle: labelTheme,
        labelText: "Server IP",
      ),
    );

    return Column(children: [
      emailField,
      passwordField,
      ipField,
      if (_loginFailed)
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _errorMessage,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        )
    ]);
  }

  /// Creates the bottom bar with the sign in button
  Widget _buildBottombar() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: FlatButton(
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: Theme.of(context).textTheme.button,
            children: [
              TextSpan(
                text: "Sign Up ",
                style: Theme.of(context)
                    .textTheme
                    .button
                    .copyWith(fontWeight: FontWeight.bold, color: clupRed),
              )
            ],
          ),
        ),
        onPressed: () => Navigator.pushNamed(context, '/signup'),
      ),
    );
  }

  /// Creates a custom button
  Widget _button(context, text, color, {icon, size = 20.0, onPressed}) {
    var border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    );

    var theme = Theme.of(context).textTheme.headline6.copyWith(
          fontSize: size,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        );

    if (icon != null) {
      return FlatButton.icon(
        disabledColor: color.withAlpha(100),
        icon: icon,
        height: 40,
        label: Text(text, style: theme),
        onPressed: onPressed,
        color: color,
        shape: border,
      );
    } else {
      return FlatButton(
        height: 40,
        disabledColor: color.withAlpha(100),
        child: Text(text, style: theme),
        onPressed: onPressed,
        color: color,
        shape: border,
      );
    }
  }

  /// Creates alternative login buttons, currently disabled
  Widget _buildAlternativeLogin() {
    final twitterButton = _button(
      context,
      'Twitter',
      twitterColor,
      icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
      size: 16.0,
    );

    final facebookButton = _button(context, 'Facebook', facebookColor,
        icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
        size: 16.0,
        onPressed: null);

    final googleButton = _button(context, 'Google', googleColor,
        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
        size: 16.0,
        onPressed: null);

    return Column(
      children: [
        const SizedBox(height: 10.0),
        Text(
          'or Log-In with an existing account',
          style: Theme.of(context).textTheme.button,
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(child: twitterButton),
            const SizedBox(width: 10),
            Expanded(child: facebookButton),
            const SizedBox(width: 20),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const SizedBox(width: 20),
            Expanded(child: googleButton),
            const SizedBox(width: 20),
          ],
        ),
      ],
    );
  }
}
