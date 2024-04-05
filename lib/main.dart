import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/bloc/auth/auth_bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/homepage.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utility/constants/firebase_options.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;

// firebase analytics
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  print(Firebase.app().name);
  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  print(FirebaseAuth.instance);
  FirebaseFirestore.setLoggingEnabled(true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => FirebaseAuthRepo(),
        ),
        RepositoryProvider(
          create: (context) => FirestoreRepo(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(RepositoryProvider.of<FirebaseAuthRepo>(context))
                  ..add(AuthInit()),
          ),
          BlocProvider(
            create: (context) =>
                LeaderboardBloc(), // placeholder for now does nothing;
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Deep Work',
              routes: {
                '/': (context) => const MyHomePage(title: 'Deep Work'),
                '/sign-in': (context) {
                  return ui.SignInScreen(
                    providers: [ui.EmailAuthProvider()],
                    actions: [
                      ui.AuthStateChangeAction<ui.SignedIn>((context, state) {
                        BlocProvider.of<AuthBloc>(context)
                            .add(AuthInit()); // reload the app
                        Navigator.pushReplacementNamed(context, '/');
                      }),
                    ],
                  );
                },
                '/profile': (context) {
                  return ui.ProfileScreen(
                    providers: [ui.EmailAuthProvider()],
                    actions: [
                      ui.SignedOutAction((context) {
                        Navigator.pushReplacementNamed(context, '/sign-in');
                        BlocProvider.of<AuthBloc>(context).add(SignedOut());
                      }),
                    ],
                  );
                },
              },
              initialRoute:
                  BlocProvider.of<AuthBloc>(context).state is Authenticated
                      ? '/'
                      : '/sign-in',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Color.fromARGB(255, 0, 6, 11)),
                useMaterial3: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
