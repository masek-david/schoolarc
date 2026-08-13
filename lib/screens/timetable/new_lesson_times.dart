import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

class NewLessonTimes extends StatefulWidget {
  const NewLessonTimes({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
    this.initialName,
    this.delete,
  });

  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final String? initialName;
  final void Function()? delete;

  @override
  State<NewLessonTimes> createState() => _NewLessonTimesState();
}

class _NewLessonTimesState extends State<NewLessonTimes> {
  late TimeOfDay? startTime = widget.initialStartTime;
  late TimeOfDay? endTime = widget.initialEndTime;
  late final nameController = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return AlertDialog(
      title: Text(loc.createNewTimes),
      actions: [
        if (widget.delete != null)
          DialogActionButton(
            isDestructiveAction: true,
            text: loc.deleteThisLesson,
            onPressed: () {
              widget.delete!();
              Navigator.pop(context);
            },
          ),
        DialogActionButton(
          text: loc.save,
          isDefaultAction: true,
          onPressed: startTime != null && endTime != null
              ? () {
                  Navigator.pop(
                    context,
                    LessonTimes(
                      startTime: startTime!,
                      endTime: endTime!,
                      name: nameController.text,
                    ),
                  );
                }
              : () {},
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: loc.name),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.beginningTime),
              M3ETextButton(
                child: Text(startTime?.format(context) ?? loc.select),
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: startTime ?? TimeOfDay.now(),
                  ).then((value) {
                    setState(() {
                      startTime = value;
                    });
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(loc.endingTime),
              M3ETextButton(
                child: Text(endTime?.format(context) ?? loc.select),
                onPressed: () {
                  showTimePicker(
                    context: context,
                    initialTime: endTime ?? TimeOfDay.now(),
                  ).then((value) {
                    setState(() {
                      endTime = value;
                    });
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
