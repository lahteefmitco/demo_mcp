import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../models/auth_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.session,
    required this.onSessionUpdated,
    super.key,
  });

  final AuthSession session;
  final Future<void> Function(AuthSession session) onSessionUpdated;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final AuthApi _authApi = AuthApi();
  bool _isSavingName = false;
  bool _isRequestingEmailChange = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.user.name);
    _emailController = TextEditingController(text: widget.session.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    if (_isSavingName || _nameController.text.trim().length < 2) {
      return;
    }

    setState(() {
      _isSavingName = true;
    });

    try {
      final user = await _authApi.updateProfile(
        token: widget.session.token,
        name: _nameController.text.trim(),
      );
      if (!mounted) {
        return;
      }

      await widget.onSessionUpdated(widget.session.copyWith(user: user));
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name updated')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingName = false;
        });
      }
    }
  }

  Future<void> _requestEmailChange() async {
    if (_isRequestingEmailChange || !_emailController.text.contains('@')) {
      return;
    }

    setState(() {
      _isRequestingEmailChange = true;
    });

    try {
      final message = await _authApi.requestEmailChange(
        token: widget.session.token,
        email: _emailController.text.trim(),
      );
      if (!mounted) {
        return;
      }

      await widget.onSessionUpdated(
        widget.session.copyWith(
          user: widget.session.user.copyWith(
            pendingEmail: _emailController.text.trim(),
          ),
        ),
      );
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingEmailChange = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.session.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Account', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _isSavingName ? null : _saveName,
            child: Text(_isSavingName ? 'Saving...' : 'Update name'),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _isRequestingEmailChange ? null : _requestEmailChange,
            child: Text(
              _isRequestingEmailChange
                  ? 'Sending...'
                  : 'Send email change verification',
            ),
          ),
          if (user.pendingEmail != null && user.pendingEmail!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Pending email verification: ${user.pendingEmail}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
            ),
          ],
        ],
      ),
    );
  }
}
