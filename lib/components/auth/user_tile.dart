import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserInfoTile extends StatelessWidget {
  const UserInfoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Login'),
      trailing: IconButton(
        onPressed: () {
          context.push('/');
        },
        icon: const Icon(Icons.login_rounded),
      ),
    );
  }
}
