import 'package:school_manager/services/home_widget_service.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void myCallbackDispatcher() {
  Workmanager().executeTask(
    (taskName, inputData) async {
      if (taskName == 'widget') {
        await completeHwBackground(Uri.parse(inputData?['data']));
      }
      return Future.value(true);
    },
  );
}
