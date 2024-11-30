import 'package:flutter/material.dart';
import 'package:school_manager/utils/extensions/timeofday_extension.dart';

class TimePickerAction extends StatefulWidget{
  const TimePickerAction({
    super.key,
    required this.initialTime,
    required this.onChanged,
  });

  final TimeOfDay initialTime;
  final Function(TimeOfDay time) onChanged;

  @override
  State<TimePickerAction> createState() => _TimepickerActionState();
}

class _TimepickerActionState extends State<TimePickerAction> {
  late TimeOfDay selectedTime = widget.initialTime;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        TimeOfDay? newTime = await showTimePicker(
          context: context,
          initialTime: selectedTime,
        );
        
        if (newTime == null){
          return;
        }
        
        setState(() {
          widget.onChanged(newTime);
          selectedTime = newTime;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Text('${selectedTime.hour}:${selectedTime.minuteStartingWithZero()}', style: const TextStyle(fontSize: 16),),
      ),
    );
  }
}
