import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';

class CountPage extends StatefulWidget {
  const CountPage({
    super.key,
    required this.exams,
    required this.hws,
  });

  final List<Homework> hws;
  final List<Exam> exams;

  @override
  State<CountPage> createState() => _CountPageState();
}

class _CountPageState extends State<CountPage> {
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
    for (int i = 2; i <= 4; i++) {
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
                'Another year flew by.',
                style: text.headlineMedium,
              )),
          _animatedText(
              2,
              Text(
                'Now let\'s see how you did:',
                style: text.headlineMedium,
              )),
          _animatedText(
              3,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'You had ',
                      style: text.bodyLarge,
                    ),
                    TextSpan(
                      text: widget.exams.length.toString(),
                      style: text.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' exams',
                      style: text.bodyLarge,
                    ),
                  ],
                ),
              ),
              margin: const EdgeInsets.only(top: 48)),
          _animatedText(
              4,
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'And ',
                      style: text.bodyLarge,
                    ),
                    TextSpan(
                      text: widget.hws.length.toString(),
                      style: text.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: ' pieces of homework',
                      style: text.bodyLarge,
                    ),
                  ],
                ),
              ),
              margin: const EdgeInsets.only(top: 16)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
