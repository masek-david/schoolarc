import 'package:flutter/material.dart';

class WelcomeScreenEnd extends StatelessWidget {
  const WelcomeScreenEnd({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tutorial completed, you can now enjoy using the app.'),
              // Text('If you find any bugs or have some suggestions please contact me.'),
              const SizedBox(height: 50),
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context);
                },
                label: const Text('Go to app'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
