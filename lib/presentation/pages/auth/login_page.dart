import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_field.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/feature_icon.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email = '';
  String _pw = '';
  bool _showPw = false;
  bool _gLoading = false;

  bool get _valid => _email.contains('@') && _pw.length >= 4;

  Future<void> _loginWithGoogle() async {
    setState(() => _gLoading = true);
    try {
      debugPrint('[Auth] Google sign-in: memulai...');
      final googleSignIn = GoogleSignIn();
      // Keluar dari sesi Google yang ter-cache agar dialog pilih akun selalu muncul
      await googleSignIn.signOut();
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[Auth] Google sign-in: dibatalkan user');
        setState(() => _gLoading = false);
        return;
      }
      debugPrint('[Auth] Google sign-in: akun dipilih → ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      debugPrint(
          '[Auth] Google auth: accessToken=${googleAuth.accessToken != null ? "OK" : "NULL"}, '
          'idToken=${googleAuth.idToken != null ? "OK" : "NULL"}');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('[Auth] Firebase sign-in OK → uid=${userCredential.user?.uid}');

      final idToken = await userCredential.user?.getIdToken();
      debugPrint(
          '[Auth] Firebase ID token: ${idToken != null ? "OK (${idToken.length} chars)" : "NULL"}');

      if (idToken != null && mounted) {
        debugPrint('[Auth] Kirim token ke backend → POST /v1/auth/verify-token');
        context.read<AuthBloc>().add(AuthLoginWithFirebase(idToken));
      }
    } catch (e, st) {
      debugPrint('[Auth] Google sign-in ERROR: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Google gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _gLoading = false);
    }
  }

  Future<void> _loginWithEmail() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email,
        password: _pw,
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null && mounted) {
        context.read<AuthBloc>().add(AuthLoginWithFirebase(idToken));
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login gagal.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthNeedsVerification) {
          context.go('/2fa/smtp');
        } else if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(
          children: [
            // Premium background decorative blobs
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.04),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet.withOpacity(0.04),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                      onPressed: () => context.go('/'),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(26, 16, 26, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppLogo(size: 46),
                          const SizedBox(height: 24),
                          const Text(
                            'Masuk ke Akun',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Masukkan email dan kata sandi Anda',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Google sign in button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              final loading = state is AuthLoading || _gLoading;
                              return GestureDetector(
                                onTap: loading ? null : _loginWithGoogle,
                                child: Container(
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.line, width: 1.2),
                                    boxShadow: AppColors.shadowSoft,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: loading
                                        ? const [
                                            SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.2,
                                                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Menghubungkan…',
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ]
                                        : const [
                                            _GoogleIcon(),
                                            SizedBox(width: 12),
                                            Text(
                                              'Lanjut dengan Google',
                                              style: TextStyle(
                                                fontFamily: 'PlusJakartaSans',
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.ink,
                                              ),
                                            ),
                                          ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: AppColors.line, thickness: 1.2)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  'atau email',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.slate400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: AppColors.line, thickness: 1.2)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AppField(
                            label: 'Email',
                            value: _email,
                            onChanged: (v) => setState(() => _email = v),
                            placeholder: 'nama@email.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(DkgIcons.mail, size: 20),
                          ),
                          const SizedBox(height: 16),
                          AppField(
                            label: 'Kata sandi',
                            value: _pw,
                            onChanged: (v) => setState(() => _pw = v),
                            obscureText: !_showPw,
                            placeholder: 'Min. 6 karakter',
                            prefixIcon: const Icon(DkgIcons.lock, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(_showPw ? DkgIcons.eyeOff : DkgIcons.eye,
                                  size: 20, color: AppColors.slate400),
                              onPressed: () => setState(() => _showPw = !_showPw),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Lupa kata sandi?',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) => AppButton(
                              label: 'Masuk',
                              onPressed: _valid ? _loginWithEmail : null,
                              isLoading: state is AuthLoading,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Belum punya akun? ',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate500,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/register'),
                                child: const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 21,
      height: 21,
      child: Image.network(
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.g_mobiledata_rounded, size: 24, color: Colors.red),
      ),
    );
  }
}
