import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    required this.onUnlock,
    required this.biometricsAvailable,
    required this.onUseBiometrics,
    required this.isUnlockingWithBiometrics,
    super.key,
  });

  final Future<bool> Function(String pin) onUnlock;
  final bool biometricsAvailable;
  final Future<void> Function() onUseBiometrics;
  final bool isUnlockingWithBiometrics;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pinFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() {
        _errorText = 'Enter your 4-digit PIN.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final unlocked = await widget.onUnlock(pin);
    if (!mounted) {
      return;
    }

    if (unlocked) {
      _pinController.clear();
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorText = 'Incorrect PIN. Try again.';
    });
    _pinController.clear();
    _pinFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 36,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'App Locked',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your PIN to continue.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        textAlign: TextAlign.center,
                        obscureText: true,
                        obscuringCharacter: '•',
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          labelText: 'PIN',
                          errorText: _errorText,
                          border: const OutlineInputBorder(),
                          counterText: '',
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: Text(
                            _isSubmitting ? 'Unlocking...' : 'Unlock',
                          ),
                        ),
                      ),
                      if (widget.biometricsAvailable) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: widget.isUnlockingWithBiometrics
                                ? null
                                : widget.onUseBiometrics,
                            icon: const Icon(Icons.fingerprint),
                            label: Text(
                              widget.isUnlockingWithBiometrics
                                  ? 'Waiting for biometric check...'
                                  : 'Use biometrics',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
