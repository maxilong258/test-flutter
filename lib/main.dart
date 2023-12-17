import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_of_my_test/components/loading_screen.dart';
import 'package:flutter_of_my_test/routes/index.dart';
import 'package:flutter_of_my_test/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_of_my_test/services/auth/bloc/auth_event.dart';
import 'package:flutter_of_my_test/services/auth/bloc/auth_state.dart';
import 'package:flutter_of_my_test/services/auth/firebase_auth_provider.dart';
import 'package:flutter_of_my_test/views/forgot_password_view.dart';
import 'package:flutter_of_my_test/views/login.dart';
import 'package:flutter_of_my_test/views/notes/notes.dart';
import 'package:flutter_of_my_test/views/register.dart';
import 'package:flutter_of_my_test/views/verify_email.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const Home(),
      ),
      routes: routes,
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state.isLoading) {
        LoadingScreen().show(
          context: context,
          text: state.loadingText ?? 'Please wait a moment',
        );
      } else {
        LoadingScreen().hide();
      }
    }, builder: (BuildContext context, state) {
      if (state is AuthStateLoggedIn) {
        return const Notes();
      } else if (state is AuthStateNeedsVerification) {
        return const VerifyEmail();
      } else if (state is AuthStateLoggedOut) {
        return const Login();
      } else if (state is AuthStateForgotPassowrd) {
        return const ForgotPasswordView();
      } else if (state is AuthStateRegistering) {
        return const Register();
      } else {
        return const Scaffold(body: CircularProgressIndicator());
      }
    });

    // return FutureBuilder(
    //   future: AuthService.firebase().initialize(),
    //   builder: (context, snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.done:
    //         final user = AuthService.firebase().currentUser;
    //         if (user == null) {
    //           return const Login();
    //         }
    //         if (!user.isEmailVerified) {
    //           return const VerifyEmail();
    //         }
    //         return const Notes();
    //       default:
    //         return const CircularProgressIndicator();
    //     }
    //   },
    // );
  }
}
