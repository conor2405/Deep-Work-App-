import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deep_work/bloc/auth/auth_bloc.dart';
import 'package:deep_work/bloc/goal/goal_bloc.dart';
import 'package:deep_work/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:deep_work/bloc/timer/timer_bloc.dart';
import 'package:deep_work/homepage.dart';
import 'package:deep_work/repo/firebase_auth_repo.dart';
import 'package:deep_work/repo/firestore_repo.dart';
import 'package:deep_work/reponsive_layout.dart';
import 'package:deep_work/timer_done_page.dart';
import 'package:deep_work/timer_page.dart';
import 'package:deep_work/widgets/charts_page.dart';
import 'package:deep_work/widgets/profile.dart';
import 'package:deep_work/widgets/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'utility/constants/firebase_options.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart' as ui;

// firebase analytics
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  /// Ensures that the Flutter widgets are initialized for the current application.
  /// This method should be called before using any Flutter widgets.
  /// It initializes the necessary bindings and prepares the application for widget rendering.
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  // FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);

  // HydratedBloc storage instance

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getTemporaryDirectory(),
  );

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
              lazy: false,
              create: (context) =>
                  TimerBloc(RepositoryProvider.of<FirestoreRepo>(context))),
          BlocProvider(
            lazy: false,
            create: (context) => LeaderboardBloc(
                timerBloc: BlocProvider.of<TimerBloc>(context),
                firestoreRepo: RepositoryProvider.of<FirestoreRepo>(context))
              ..add(LeaderboardInit()), // placeholder for now does nothing;
          ),
          BlocProvider(
              lazy: false,
              create: (context) =>
                  GoalBloc(RepositoryProvider.of<FirestoreRepo>(context))
                    ..add(GoalInit())),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Deep Work',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                    seedColor: Color.fromARGB(255, 0, 21, 255),
                    brightness: Brightness.dark),
                pageTransitionsTheme: const PageTransitionsTheme(builders: {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
                  TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
                  TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
                }),
              ),
              routes: {
                '/': (context) => ResponsiveLayout(
                    mobileLayout: MyHomePage(), desktopLayout: MyHomePage()),
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
                '/profile': (context) => ProfileWidget(),
                '/charts': (context) => ChartsPage(),
                '/settings': (context) => SettingsPage(),
                '/timer': (context) => TimerPage(),
                '/timer/confirm': (context) => TimerDonePage(),
              },
              initialRoute: BlocProvider.of<AuthBloc>(context).state
                      is Authenticated // uncomment this line to enable sign in
                  ? '/'
                  : '/sign-in',
            );
          },
        ),
      ),
    );
  }
}
