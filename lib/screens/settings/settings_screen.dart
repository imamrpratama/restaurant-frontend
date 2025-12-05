import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isEnabling2FA = false;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? '),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFC8181),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _toggle2FA() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user?.google2faEnabled == true) {
      await _disable2FA();
    } else {
      await _enable2FA();
    }
  }

  Future<void> _enable2FA() async {
    setState(() => _isEnabling2FA = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.enable2FA();

    setState(() => _isEnabling2FA = false);

    if (!mounted) return;

    if (result != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _Enable2FADialog(
          qrCodeSvg: result['qr_code_svg'],
          secret: result['secret'],
          recoveryCodes: List<String>.from(result['recovery_codes']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to enable 2FA'),
          backgroundColor: const Color(0xFFFC8181),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  Future<void> _disable2FA() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _Disable2FADialog(),
    );

    if (result == null || !mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.disable2FA(
      password: result['password']!,
      otp: result['otp']!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '2FA disabled successfully'
                : authProvider.errorMessage ?? 'Failed to disable 2FA',
          ),
          backgroundColor:
              success ? const Color(0xFF48BB78) : const Color(0xFFFC8181),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            final user = authProvider.user;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: user?.avatar != null
                            ? ClipOval(
                                child: Image.network(
                                  user!.avatar!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Center(
                                child: Text(
                                  user?.name[0].toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Security Section
                Text(
                  'Security',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                ),
                const SizedBox(height: 16),

                // 2FA Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: user?.google2faEnabled == true
                            ? const Color(0xFF48BB78).withOpacity(0.1)
                            : const Color(0xFF718096).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.security_rounded,
                        color: user?.google2faEnabled == true
                            ? const Color(0xFF48BB78)
                            : const Color(0xFF718096),
                      ),
                    ),
                    title: Text(
                      'Two-Factor Authentication',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        user?.google2faEnabled == true
                            ? 'Enabled - Extra security for your account'
                            : 'Disabled - Secure your account with 2FA',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    trailing: _isEnabling2FA
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Switch(
                            value: user?.google2faEnabled ?? false,
                            onChanged: (_) => _toggle2FA(),
                            activeColor: const Color(0xFF48BB78),
                          ),
                  ),
                ),
                const SizedBox(height: 32),

                // Actions Section
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3748),
                      ),
                ),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFC8181),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Enable 2FA Dialog with Recovery Codes
class _Enable2FADialog extends StatefulWidget {
  final String qrCodeSvg;
  final String secret;
  final List<String> recoveryCodes;

  const _Enable2FADialog({
    required this.qrCodeSvg,
    required this.secret,
    required this.recoveryCodes,
  });

  @override
  State<_Enable2FADialog> createState() => _Enable2FADialogState();
}

class _Enable2FADialogState extends State<_Enable2FADialog> {
  final _otpController = TextEditingController();
  bool _isVerifying = false;
  int _step = 1; // 1: QR Code, 2: Recovery Codes, 3: Verify

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter 6-digit code'),
          backgroundColor: const Color(0xFFFC8181),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.confirm2FA(_otpController.text);

    setState(() => _isVerifying = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('2FA enabled successfully! '),
          backgroundColor: const Color(0xFF48BB78),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid code'),
          backgroundColor: const Color(0xFFFC8181),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
    }
  }

  void _copyRecoveryCodes() {
    Clipboard.setData(
      ClipboardData(text: widget.recoveryCodes.join('\n')),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recovery codes copied to clipboard'),
        backgroundColor: const Color(0xFF48BB78),
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
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text('Setup 2FA - Step $_step of 3'),
      content: SingleChildScrollView(
        child: _step == 1
            ? _buildQRCodeStep()
            : _step == 2
                ? _buildRecoveryCodesStep()
                : _buildVerifyStep(),
      ),
      actions: [
        if (_step > 1)
          TextButton(
            onPressed: () => setState(() => _step--),
            child: const Text('Back'),
          ),
        if (_step < 3)
          ElevatedButton(
            onPressed: () => setState(() => _step++),
            child: const Text('Next'),
          ),
        if (_step == 3) ...[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isVerifying ? null : _confirm,
            child: _isVerifying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm'),
          ),
        ],
      ],
    );
  }

  Widget _buildQRCodeStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '1.  Scan this QR code with your authenticator app (Google Authenticator, Authy, Microsoft Authenticator, etc.)',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: SvgPicture.string(
            utf8.decode(base64.decode(widget.qrCodeSvg)),
            width: 200,
            height: 200,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '2. Or enter this key manually:',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.secret,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.secret));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Secret copied!')),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecoveryCodesStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFED8936).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFED8936).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFED8936),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Save these recovery codes in a safe place! ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFED8936),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'These codes can be used to access your account if you lose your phone.  Each code can only be used once.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: widget.recoveryCodes.map((code) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _copyRecoveryCodes,
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copy All Codes'),
        ),
      ],
    );
  }

  Widget _buildVerifyStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter the 6-digit code from your authenticator app to complete setup:',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _otpController,
          decoration: const InputDecoration(
            hintText: '000000',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
      ],
    );
  }
}

// Disable 2FA Dialog
class _Disable2FADialog extends StatefulWidget {
  const _Disable2FADialog();

  @override
  State<_Disable2FADialog> createState() => _Disable2FADialogState();
}

class _Disable2FADialogState extends State<_Disable2FADialog> {
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFC8181).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xFFFC8181),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Disable 2FA')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'To disable 2FA, please enter your password and current OTP code:',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'OTP Code',
              hintText: '000000',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_passwordController.text.isEmpty ||
                _otpController.text.length != 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please fill all fields'),
                ),
              );
              return;
            }
            Navigator.pop(context, {
              'password': _passwordController.text,
              'otp': _otpController.text,
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFC8181),
          ),
          child: const Text('Disable'),
        ),
      ],
    );
  }
}
