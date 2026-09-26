import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';

class HwNotiferMock extends Notifier<Map<String, HomeworkData>>
    with Mock
    implements HwNotifier {}

class ExamNotiferMock extends Notifier<Map<String, ExamData>>
    with Mock
    implements ExamNotifier {}