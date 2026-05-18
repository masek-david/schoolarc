import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/utils/globals.dart';

class FinalPage extends StatefulWidget {
  const FinalPage({super.key});

  @override
  State<FinalPage> createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  int visibleIndex = 0;

  @override
  void initState() {
    super.initState();
    _showGradually();
  }

  Future<void> _showGradually() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        setState(() {
          visibleIndex = 1;
        });
      },
    );
    for (int i = 2; i <= 3; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          visibleIndex = i;
        });
      }
    }
  }

  Widget _animatedText(int index, Widget child, {EdgeInsets? margin}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 1000),
      child: AnimatedOpacity(
        opacity: visibleIndex >= index ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        child: visibleIndex >= index
            ? Padding(padding: margin ?? EdgeInsets.zero, child: child)
            : const SizedBox(height: 0, width: double.infinity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _animatedText(
              1,
              Text(
                'That\'s it for this year.',
                style: text.headlineMedium,
              )),
          _animatedText(
              2,
              Text(
                'Enjoy the summer break!',
                style: text.headlineMedium,
              ),
              margin: const EdgeInsets.only(top: 16)),
          _animatedText(
              3,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonM3E.filled(
                    onPressed: () {
                      settings.save(
                          Setting.recapShownForYear, DateTime.now().year);
                      Navigator.pop(context);
                    },
                    child: const Text('Exit'),
                  ),
                ],
              ),
              margin: const EdgeInsets.only(top: 64)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
