import 'package:clup_application/api/authentication.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final clupRed = Color(0xFFF76C5E);
final clupBlue1 = Color(0xFF586BA4);
final clupBlue2 = Color(0xFF1E2848);

final twitterColor = Color(0xFF1DA1F2);
final facebookColor = Color(0xFF4267B2);
final googleColor = Color(0xFFDB4437);

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _loginFailed = false;
  String _errorMessage;

  TextEditingController emailController =
      TextEditingController(text: 'succoso.meme@kek.it');
  TextEditingController passwordController =
      TextEditingController(text: '___1eAe1___');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _buildBottombar(),
      body: Center(
        child: SafeArea(
          child: Scrollbar(
            child: Center(
              child: Stack(
                children: [
                  Padding(
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
                  if (_isLoading) _buildLoginIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildLoginIndicator() {
    return Container(
      color: Colors.white70,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.71,
      child: Center(
        child: Container(
          height: 50.0,
          width: 50.0,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            valueColor: AlwaysStoppedAnimation(clupBlue1),
          ),
        ),
      ),
    );
  }

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

  Widget _buildForgotPwdButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: FlatButton(
        child: Text(
          'Forgot Password?',
          style: TextStyle(fontSize: 14),
          textAlign: TextAlign.left,
        ),
        onPressed: () {},
      ),
    );
  }

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

  _tryLoggingIn() async {
    setState(() => _isLoading = true);

    List result = await attemptLogin(
      emailController.text,
      passwordController.text,
    );

    bool success = result[0];

    await Future.delayed(Duration(seconds: 1));

    if (success) {
      Navigator.popAndPushNamed(context, '/map');
    }

    setState(() {
      _isLoading = false;
      _loginFailed = !success;

      if (_loginFailed) {
        _errorMessage = result[1];
      }
    });
  }

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

    return Column(children: [
      emailField,
      passwordField,
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

  Padding _buildBottombar() {
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

  _button(context, text, color, {icon, size = 20.0, onPressed}) {
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
        icon: icon,
        height: 40,
        label: Text(text, style: theme),
        onPressed: onPressed ?? () {},
        color: color,
        shape: border,
      );
    } else {
      return FlatButton(
        height: 40,
        child: Text(text, style: theme),
        onPressed: onPressed ?? () {},
        color: color,
        shape: border,
      );
    }
  }

  _buildAlternativeLogin() {
    final twitterButton = _button(context, 'Twitter', twitterColor,
        icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.white),
        size: 16.0);

    final facebookButton = _button(context, 'Facebook', facebookColor,
        icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.white),
        size: 16.0,
        onPressed: () => Navigator.pushNamed(context, '/store/ticket'));

    final googleButton = _button(context, 'Google', googleColor,
        icon: const FaIcon(FontAwesomeIcons.google, color: Colors.white),
        size: 16.0,
        onPressed: () async => print(await getAccessToken()));

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
        SizedBox(
          width: MediaQuery.of(context).size.width - 100,
          child: googleButton,
        ),
      ],
    );
  }
}
