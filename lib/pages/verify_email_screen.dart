// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mpit/pages/home_screen.dart';
import 'package:mpit/scripts/snack_bar.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    // ignore: avoid_print
    print(isEmailVerified);

    if (isEmailVerified) timer?.cancel();
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));

      setState(() => canResendEmail = true);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      if (mounted) {
        SnackBarService.showSnackBar(
          context,
          '$e',
          //'Неизвестная ошибка! Попробуйте еще раз или обратитесь в поддержку.',
          true,
        );
      }
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) => isEmailVerified
      ? const HomeScreen()
      : Scaffold(
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: const Text(
                      'Мы отправили вам\nписьмо с\nподтверждением на\nвашу почту',
                      style: TextStyle(
                          height: 1.3, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'montserrat'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 50),
                  ElevatedButton(
                    style: ButtonStyle(
                    elevation: MaterialStateProperty.all(5),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.white)),
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    child: SizedBox(
                      height: 34,
                      width: 345,
                      child: Center(
                        child: Text('Отправить еще раз',
                            style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'montserrat')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
}
