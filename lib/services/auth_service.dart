// QuestMate Authentication Service
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final bool isFirebaseEnabled;
  FirebaseAuth? _auth;

  AuthService({this.isFirebaseEnabled = false}) {
    if (isFirebaseEnabled) {
      _auth = FirebaseAuth.instance;
    }
  }

  User? get currentUser => _auth?.currentUser;

  Stream<User?> authStateChanges() {
    if (!isFirebaseEnabled || _auth == null) {
      return Stream.value(null);
    }
    return _auth!.authStateChanges();
  }

  Future<UserCredential?> signInWithGoogle() async {
    if (!isFirebaseEnabled || _auth == null) {
      // Firebase가 초기화되지 않았으면 로그인 불가
      throw Exception('Firebase가 초기화되지 않았습니다. Firebase 설정을 완료해주세요.');
    }

    final GoogleSignInAccount? account = await GoogleSignIn().signIn();
    if (account == null) return null;

    final auth = await account.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );

    return await _auth!.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!isFirebaseEnabled) return;
    
    await GoogleSignIn().signOut();
    await _auth?.signOut();
  }
}
