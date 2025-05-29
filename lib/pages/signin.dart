import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:second_project/admin/admin_signin.dart';
import 'package:second_project/data/local/DatabaseListPage.dart';
import 'package:second_project/data/local/db_helper.dart';
import 'package:second_project/pages/bottomnav.dart';
import 'package:second_project/pages/signup.dart';
import 'package:second_project/database/shared_preferences.dart';
import 'package:second_project/widget/support_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  final helper = SharedPreferenceHelper();

  @override
  void initState() {
    super.initState();
    _loadRememberMeData();
  }

  Future<void> _loadRememberMeData() async {
    final savedEmail = await helper.getRememberMeEmail();
    final savedRememberMeState = await helper.getRememberMeCheckboxState();

    setState(() {
      if (savedEmail != null && savedRememberMeState) {
        emailController.text = savedEmail;
        _rememberMe = savedRememberMeState;
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> hasInternet() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  Future<void> userLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        final online = await hasInternet();

        if (online) {
          await _onlineLogin(email, password);
        } else {
          await _offlineLogin(email, password);
        }
      } catch (e) {
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _onlineLogin(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        _showErrorSnackBar('Login failed. Please try again.');
        return;
      }

      if (!user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        _showWarningSnackBar('Please verify your email before logging in.');
        return;
      }

      // Save user data locally
      final db = await DBHelper.instance.getDB();
      final result = await db.query(
        "users",
        where: "email = ?",
        whereArgs: [user.email],
      );

      int? userId;
      if (result.isEmpty) {
        userId = await db.insert("users", {
          'name': user.displayName ?? 'User',
          'email': user.email,
          'image': '',
        });
      } else {
        userId = result.first['id'] as int?;
      }

      if (userId != null) {
        await helper.saveUserId(userId.toString());

        // Handle 'Remember Me' preference
        if (_rememberMe) {
          await helper.saveRememberMeEmail(email);
          await helper.saveRememberMeCheckboxState(true);
        } else {
          await helper.clearRememberMeData();
        }

        _showSuccessSnackBar('Logged In Successfully');
        _navigateToHome();
      } else {
        _showErrorSnackBar('Error saving user data locally.');
        await FirebaseAuth.instance.signOut();
      }
    } on FirebaseAuthException catch (error) {
      String errorMessage;
      switch (error.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later.';
          break;
        default:
          errorMessage = 'Login failed. Please check your credentials.';
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<void> _offlineLogin(String email, String password) async {
    final db = await DBHelper.instance.getDB();
    final result = await db.query(
      "users",
      where: "email = ?",
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      int? userId = result.first['id'] as int?;
      if (userId != null) {
        await helper.saveUserId(userId.toString());

        if (_rememberMe) {
          await helper.saveRememberMeEmail(email);
          await helper.saveRememberMeCheckboxState(true);
        } else {
          await helper.clearRememberMeData();
        }

        _showSuccessSnackBar('Logged In (Offline Mode)');
        _navigateToHome();
      } else {
        _showErrorSnackBar('Error retrieving local user data.');
      }
    } else {
      _showErrorSnackBar('No matching account found offline.');
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNav()),
      );
    }
  }

  Future<void> resetPassword() async {
    final resetEmailController = TextEditingController(
      text: emailController.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: "Enter your email",
              hintText: "example@gmail.com",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();

                if (email.isEmpty || !email.contains('@')) {
                  _showErrorSnackBar('Please enter a valid email.');
                  return;
                }

                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                    email: email,
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                    _showSuccessSnackBar(
                      'Password reset email sent. Check your inbox.',
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    Navigator.of(context).pop();
                    _showErrorSnackBar(
                      e.message ?? 'Failed to send reset email.',
                    );
                  }
                }
              },
              child: const Text("Send Reset Link"),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showWarningSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/logo/ToolKit_logo.png",
                        height: 190,
                        width: 190,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "SignIn to ToolKit Nepal",
                        style: AppWidget.boldTextFieldStyle(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Welcome! Please enter your login credentials to continue.",
                        textAlign: TextAlign.center,
                        style: AppWidget.lightTextFieldStyle(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Email", style: AppWidget.semiboldTextFieldStyle()),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      decoration: const BoxDecoration(color: Color(0xFFF4F5F9)),
                      child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email cannot be empty';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your email",
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Password", style: AppWidget.semiboldTextFieldStyle()),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.only(left: 20.0),
                      decoration: const BoxDecoration(color: Color(0xFFF4F5F9)),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password cannot be empty";
                          }
                          if (value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter your password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.black,
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: resetPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _isLoading ? null : userLogin,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap:
                              _isLoading
                                  ? null
                                  : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const Signup(),
                                      ),
                                    );
                                  },
                          child: const Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Login as Admin? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap:
                              _isLoading
                                  ? null
                                  : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AdminSignin(),
                                      ),
                                    );
                                  },
                          child: const Text(
                            "Admin",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "View Database? ",
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap:
                              _isLoading
                                  ? null
                                  : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => const DatabaseListPage(),
                                      ),
                                    );
                                  },
                          child: const Text(
                            "Database",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
