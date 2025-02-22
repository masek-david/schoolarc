import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveShowcase extends StatefulWidget {
  const AdaptiveShowcase({super.key});

  @override
  State<AdaptiveShowcase> createState() => _AdaptiveShowcaseState();
}

class _AdaptiveShowcaseState extends State<AdaptiveShowcase> {
  bool switchValue = false;
  double sliderValue = 0.5;
  DateTime date = DateTime.now();

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Adaptive widgets'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoSwitch(
              value: switchValue,
              onChanged: (value) {
                setState(() {
                  switchValue = value;
                });
              },
            ),
            Switch(
              value: switchValue,
              onChanged: (value) {
                setState(() {
                  switchValue = value;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoSlider(
              value: sliderValue,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
            Slider(
              value: sliderValue,
              onChanged: (value) {
                setState(() {
                  sliderValue = value;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              onPressed: () {
                showCupertinoDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('This is a cupertino dialog'),
                      actions: [
                        CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Dialog'),
            ),
            OutlinedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('This is a material dialog'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Dialog'),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoButton(
              onPressed: () {
                _showDialog(CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    setState(() {
                      date = value;
                    });
                  },
                ));
              },
              child: Text('Date picker'),
            ),
            OutlinedButton(
              onPressed: () async {
                final newate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(0),
                  lastDate: DateTime(5000),
                );

                if (newate != null) {
                  setState(() {
                    date = newate;
                  });
                }
              },
              child: Text('Date picker'),
            ),
          ],
        ),
      ],
    );
  }
}
