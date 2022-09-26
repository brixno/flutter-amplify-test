import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/material.dart';
import 'package:test1/sign_up_page.dart';
import 'package:test1/verfication_page.dart';
import 'amplifyconfiguration.dart';
import 'auth_service.dart';
import 'camera_flow.dart';
import 'login_page.dart';

void main() {
  runApp(MyApp());
}

// 1
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _amplify = Amplify;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _configureAmplify();
    _authService.checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Gallery App',
      theme: ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
      // 2
      home: StreamBuilder<AuthState>(
        // 2
          stream: _authService.authStateController.stream,
          builder: (context, snapshot) {
            // 3
            if (snapshot.hasData) {
              return Navigator(
                pages: [
                  // 4
                  // Show Login Page
                  if (snapshot.data?.authFlowStatus == AuthFlowStatus.login)
                    MaterialPage(child: LoginPage(didProvideCredentials: _authService.loginWithCredentials,shouldShowSignUp: _authService.showSignUp)),
                  // 5
                  // Show Sign Up Page
                  if (snapshot.data?.authFlowStatus == AuthFlowStatus.signUp)
                    MaterialPage(child: SignUpPage(didProvideCredentials: _authService.signUpWithCredentials,shouldShowLogin: _authService.showLogin)),

                  if (snapshot.data?.authFlowStatus == AuthFlowStatus.verification)
                    MaterialPage(child: VerificationPage(didProvideVerificationCode: _authService.verifyCode)),

                  if (snapshot.data?.authFlowStatus == AuthFlowStatus.session)
                    MaterialPage(child: CameraFlow(shouldLogOut: _authService.logOut))
                ],
                onPopPage: (route, result) => route.didPop(result),
              );
            } else {
              // 6
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  void _configureAmplify() async {
    var auth = AmplifyAuthCognito();
    var stor = AmplifyStorageS3();

    Amplify.addPlugin(auth);
    Amplify.addPlugin(stor);

    try {
      await Amplify.configure(amplifyconfig);
      print('Successfully configured Amplify 🎉');
    } catch (e) {
      print('Could not configure Amplify ☠️');
    }
  }
}