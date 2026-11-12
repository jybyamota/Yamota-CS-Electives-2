import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const githubOAuthRedirectUrl = 'io.supabase.cs_elective_2://login-callback/';

class GitHubAuthButton extends StatefulWidget {
  const GitHubAuthButton({super.key, this.showLabel = false});

  final bool showLabel;

  @override
  State<GitHubAuthButton> createState() => _GitHubAuthButtonState();
}

class _GitHubAuthButtonState extends State<GitHubAuthButton> {
  bool _isLoading = false;

  Future<void> _handleTap(User? user) async {
    setState(() => _isLoading = true);

    try {
      final auth = Supabase.instance.client.auth;
      if (user == null) {
        final launched = await auth.signInWithOAuth(
          OAuthProvider.github,
          redirectTo: kIsWeb ? Uri.base.origin : githubOAuthRedirectUrl,
        );
        if (!launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open GitHub sign-in.')),
          );
        }
      } else {
        await auth.signOut();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GitHub authentication failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final user = snapshot.data?.session?.user ?? auth.currentUser;
        final label = user == null ? 'Continue with GitHub' : 'Sign out';
        final icon = user == null ? Icons.code : Icons.logout;
        final iconWidget = _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon);

        if (widget.showLabel) {
          return SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : () => _handleTap(user),
              icon: iconWidget,
              label: Text(_isLoading ? 'Opening GitHub...' : label),
            ),
          );
        }

        return IconButton(
          tooltip: user == null ? 'Sign in with GitHub' : 'Sign out',
          onPressed: _isLoading ? null : () => _handleTap(user),
          icon: _isLoading
              ? iconWidget
              : Icon(user == null ? Icons.login : icon),
        );
      },
    );
  }
}
