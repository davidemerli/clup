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
                    // height: MediaQuery.of(context).size.height - 120,
                    child: _buildContent(context),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildBottombar(context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: _customButton(context, 'Confirm', clupRed, onPressed: () {
        Navigator.pushNamed(context, '/');
      }),
    );
  }

  Column _buildContent(BuildContext context) {
    return Column(
      children: [
        _customTextField('Email'),
        _customTextField('Name'),
        _customTextField('Surname'),
      ],
    );
  }

  _customTextField(text, [isPassword = false]) {
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
        labelText: text,
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
