import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Firebase 설정 나중에 활성화할 때 주석 해제
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/hive_service.dart';
import 'services/firebase_service.dart';
import 'providers/quest_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 파이어베아스 설정 나중에
  // 개발 중에는 주석 처리, 나중에 활성화하면 됨
  bool firebaseInitialized = false;
  try {
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    // firebaseInitialized = true;
  } catch (e) {
    firebaseInitialized = false;
  }

  final auth = AuthService(isFirebaseEnabled: firebaseInitialized);
  final hive = HiveService();
  final firebase = FirebaseService(isFirebaseEnabled: firebaseInitialized);

  final provider = QuestProvider(
    hive: hive,
    firebase: firebase,
    auth: auth,
  );

  await provider.init();

  runApp(QuestMateApp(auth: auth, provider: provider));
}

class QuestMateApp extends StatelessWidget {
  final AuthService auth;
  final QuestProvider provider;

  const QuestMateApp({
    Key? key,
    required this.auth,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: MaterialApp(
        title: "QuestMate",
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: HomeScreen(auth: auth),
      ),
    );
  }
}
