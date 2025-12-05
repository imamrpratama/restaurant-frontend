import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

class Verify2FAScreen extends StatefulWidget {
  const Verify2FAScreen({Key? key}) : super(key: key);

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final _otpController = TextEditingController();
  final _recoveryCodeController = TextEditingController();
  bool _useRecoveryCode = false;

  @override
  void dispose() {
    _otpController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success;
    if (_useRecoveryCode) {
      if (_recoveryCodeController.text.isEmpty) {
        _showError('Please enter recovery code');
        return;
      }
      success = await authProvider.verifyRecoveryCode(
        _recoveryCodeController.text.trim(),
      );
    } else {
      if (_otpController.text.length != 6) {
        _showError('Please enter 6-digit code');
        return;
      }
      success = await authProvider.verify2FA(_otpController.text);
    }

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      _showError(authProvider.errorMessage ?? 'Verification failed');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFC8181),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.logout();
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 50,
                    color: Color(0xFF667EEA),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Two-Factor Authentication',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _useRecoveryCode
                      ? 'Enter your recovery code'
                      : 'Enter the 6-digit code from your authenticator app',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Input Field
                if (_useRecoveryCode)
                  TextFormField(
                    controller: _recoveryCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Recovery Code',
                      hintText: 'XXXXXXXXXX',
                      prefixIcon: Icon(Icons.vpn_key_rounded),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Fa-f0-9]')),
                    ],
                  )
                else
                  TextFormField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: 'OTP Code',
                      hintText: '000000',
                      prefixIcon: Icon(Icons.pin_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                const SizedBox(height: 32),

                // Verify Button
                Consumer<AuthProvider>(
                  builder: (context, provider, _) {
                    return ElevatedButton(
                      onPressed: provider.isLoading ? null : _verify,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Verify'),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Toggle Recovery Code
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _useRecoveryCode = !_useRecoveryCode;
                      _otpController.clear();
                      _recoveryCodeController.clear();
                    });
                  },
                  icon: Icon(
                    _useRecoveryCode
                        ? Icons.phone_android_rounded
                        : Icons.vpn_key_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _useRecoveryCode
                        ? 'Use authenticator code instead'
                        : 'Lost your phone? Use recovery code',
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF667EEA),
                  ),
                ),

                const SizedBox(height: 16),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF667EEA),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _useRecoveryCode
                              ? 'Each recovery code can only be used once'
                              : 'Open your authenticator app to get the code',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF667EEA),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
