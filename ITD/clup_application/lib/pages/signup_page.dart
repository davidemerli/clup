import 'package:flutter/material.dart';

const clupRed = Color(0xFFF76C5E);
const clupBlue1 = Color(0xFF586BA4);
const clupBlue2 = Color(0xFF1E2848);

class SignupPage extends StatelessWidget {
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: _customButton(context, 'Register', clupRed, onPressed: () {
          Navigator.pushNamed(context, '/signup/confirm');
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CustomScrollView(
          slivers: [
            _buildAppbar(context),
            SliverList(
              delegate: SliverChildListDelegate(
                [buildContent(context)],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Column(
              children: [
                _customTextField('Email'),
                SizedBox(height: 2),
                _customTextField('Password'),
                SizedBox(height: 2),
                _customTextField('Confirm Password'),
              ],
            ),
          ],
        ),
        SizedBox(height: 40),
        Column(
          children: [
            _customTextField('Name', autofillHints: AutofillHints.name),
            SizedBox(height: 2),
            _customTextField('Surname', autofillHints: AutofillHints.birthday),
            SizedBox(height: 2),
          ],
        ),
      ],
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

  _customTextField(text, {isPassword = false, autofillHints}) {
    var border = UnderlineInputBorder(
      borderSide: BorderSide(color: clupBlue2, width: 0.5),
    );

    return Material(
      child: AutofillGroup(
        child: TextField(
          autofocus: false,
          obscureText: isPassword,
          autofillHints: [autofillHints],
          style: textBoxTheme,
          cursorColor: clupBlue1,
          decoration: InputDecoration(
            focusedBorder: border,
            enabledBorder: border,
            labelStyle: labelTheme,
            labelText: text,
            //   focusColor: Colors.green,
          ),
        ),
      ),
    );
  }

  _customButton(context, text, color, {onPressed, icon}) {
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
