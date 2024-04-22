import 'package:deep_work/bloc/auth/auth_bloc.dart';
import 'package:deep_work/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWidget extends StatefulWidget {
  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Sidebar(),
            Expanded(
              child: ui.ProfileScreen(
                providers: [ui.EmailAuthProvider()],
                actions: [
                  ui.SignedOutAction((context) {
                    Navigator.pushReplacementNamed(context, '/sign-in');
                    BlocProvider.of<AuthBloc>(context).add(SignedOut());
                  }),
                ],
              ),
            )
          ],
        ),
        // Add your profile UI components here
      ),
    );
  }
}
