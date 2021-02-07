import 'package:clup_application/main.dart';
import 'package:flutter/material.dart';
import '../configs.dart';

class SignupPage extends StatefulWidget {
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
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _surnameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: _customButton(context, 'Register', clupRed, onPressed: () async {
          if (_passwordController.text != _confirmPasswordController.text) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Passwords do not match'),
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );

            return;
          }

          await write(key: 'register_email', value: _emailController.text);
          await write(key: 'register_pwd', value: _passwordController.text);
          await write(
            key: 'register_fullname',
            value: '${_nameController.text} ${_surnameController.text}',
          );

          Navigator.pushNamed(context, '/signup/confirm');
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CustomScrollView(
          slivers: [
            _buildAppbar(context),
            SliverList(
              // Setup sliver list for correct scrolling
              delegate: SliverChildListDelegate(
                [_buildContent(context)],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Creates all the component of the inside of the page
  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Column(
              children: [
                _customTextField('Email', _emailController,
                    autofillHints: AutofillHints.email),
                SizedBox(height: 2),
                _customTextField('Password', _passwordController,
                    autofillHints: AutofillHints.newPassword, isPassword: true),
                SizedBox(height: 2),
                _customTextField('Confirm Password', _confirmPasswordController,
                    autofillHints: AutofillHints.newPassword, isPassword: true),
              ],
            ),
          ],
        ),
        SizedBox(height: 40),
        Column(
          children: [
            _customTextField('Name', _nameController,
                autofillHints: AutofillHints.namePrefix),
            SizedBox(height: 2),
            _customTextField('Surname', _surnameController,
                autofillHints: AutofillHints.nameSuffix),
            SizedBox(height: 2),
          ],
        ),
      ],
    );
  }

  /// Creates the app bar
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

  Widget _customTextField(text, controller,
      {isPassword = false, autofillHints}) {
    var border = UnderlineInputBorder(
      borderSide: BorderSide(color: clupBlue2, width: 0.5),
    );

    return Material(
      child: AutofillGroup(
        child: TextField(
          controller: controller,
          autofocus: false,
          obscureText: isPassword,
          autofillHints: [autofillHints],
          style: SignupPage.textBoxTheme,
          cursorColor: clupBlue1,
          decoration: InputDecoration(
            focusedBorder: border,
            enabledBorder: border,
            labelStyle: SignupPage.labelTheme,
            labelText: text,
          ),
        ),
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
}
