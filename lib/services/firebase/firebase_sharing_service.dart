import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/exams/exam_entity_id_model.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/homeworks/homework_entity_id_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';
// TODO translate

class MyUser {
  MyUser(
    this.id,
    this.name, {
    this.waitingForApproval = false,
    this.isLocal = false,
    this.isOwner = false,
  });
  final String name;
  final String id;
  final bool waitingForApproval;
  final bool isLocal;
  final bool isOwner;
}

class FirebaseSharingService {
  final _db = FirebaseDatabase.instance;

  /// returns map of all member of the group, and the tasks shared by them
  Future<Map<MyUser, List<Task>>> getSharedTasks() async {
    final user = currentUserId;
    final db = FirebaseDatabase.instance;

    final groupId = await getGroupId();
    if (groupId == null) {
      throw ServiceException('You aren\'t a member of any group');
    }
    final groupSnapshot = await db.ref('groups/$groupId').get();
    if (!groupSnapshot.exists) {
      throw ServiceException('This group doesn\'t exist');
    }

    final groupUsersIds = {
      for (var snap in groupSnapshot.child('u').children)
        snap.key!: snap.value as bool?
    };

    // add the group owner to users
    groupUsersIds[groupId] = true;
    // check if you have permission
    if (groupUsersIds[user] == false) {
      throw ServiceException('Waiting for approval');
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final List<Future> futures = [];

    // Map of userId to User
    final Map<String, MyUser> users = {};
    // Map of subjectId to subject
    final Map<String, Subject> subjectsMap = {};
    // Map of userId to hw
    final Map<String, List<HomeworkEntityWithID>> hws = {};
    // Map of userId to exam
    final Map<String, List<ExamEntityWithID>> exams = {};

    groupUsersIds.forEach((groupUserId, groupUserState) {
      // usernames
      futures.add(db.ref('users/$groupUserId/n').get().then(
        (snapshot) {
          users[groupUserId] = MyUser(
            groupUserId,
            snapshot.value as String? ?? '',
            waitingForApproval: groupUserState == false,
            isLocal: groupUserId == user,
            isOwner: groupUserId == groupId,
          );
        },
      ));
      // if the user is waiting for aproval or its you, dont fetch
      if (groupUserState == false || groupUserId == user) return;

      // Subjects - dont need to save the user
      futures.add(
        db
            .ref('users/$groupUserId/s')
            .orderByChild('sh')
            .equalTo(true)
            .get()
            .then((snapshot) {
          for (var subject in snapshot.children) {
            if (subject.key == null) continue;
            final map = Map<String, dynamic>.from(subject.value as Map);
            map['sh'] = null;
            map.putIfAbsent('id', () => subject.key);
            subjectsMap[subject.key!] = Subject.fromFireJson(map);
          }
        }),
      );

      // Homework
      futures.add(
        db
            .ref('users/$groupUserId/h')
            .orderByChild('sh')
            .startAt(now)
            .get()
            .then((snapshot) {
          for (var hw in snapshot.children) {
            final map = Map<String, dynamic>.from(hw.value as Map);
            map.putIfAbsent('id', () => hw.key);
            map['sh'] = null;
            map['c'] = false;
            hws
                .putIfAbsent(groupUserId, () => [])
                .add(HomeworkEntityWithID.fromFireJson(map));
          }
        }),
      );

      // Exams
      futures.add(
        db
            .ref('users/$groupUserId/e')
            .orderByChild('sh')
            .startAt(now)
            .get()
            .then((snapshot) {
          for (var exam in snapshot.children) {
            final map = Map<String, dynamic>.from(exam.value as Map);
            map.putIfAbsent('id', () => exam.key);
            map['sh'] = null;
            exams
                .putIfAbsent(groupUserId, () => [])
                .add(ExamEntityWithID.fromFireJson(map));
          }
        }),
      );
    });

    await Future.wait(futures);
    // now we have all subjects and homeworks/exams (these have only their subjectId)
    final Map<MyUser, List<Task>> tasks = {};

    users.forEach(
      (key, value) {
        tasks[value] = [];
      },
    );

    exams.forEach((userId, list) {
      final user = users[userId];
      if (user != null) {
        for (var element in list) {
          tasks
              .putIfAbsent(user, () => [])
              .add(element.convert(element.id, subjectsMap[element.subjectId]));
        }
      }
    });
    hws.forEach((userId, list) {
      final user = users[userId];
      if (user != null) {
        for (var element in list) {
          tasks
              .putIfAbsent(user, () => [])
              .add(element.convert(element.id, subjectsMap[element.subjectId]));
        }
      }
    });

    return tasks;
  }

  /// Throws logged out message if current user is null
  String get currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    final loc = getLocalization();

    if (user == null) {
      throw ServiceException(loc.loggedOut);
    }
    return user.uid;
  }

  /// Gets the id of the group saved under current user's profile
  Future<String?> getGroupId() async {
    final snapshot = await _db.ref('users/$currentUserId/g').get();
    return snapshot.value as String?;
  }

  Future<void> joinGroup(String groupId) async {
    final currentGroup = await getGroupId();
    if (currentGroup != null) {
      throw ServiceException('First leave the old group');
    }

    final group = await _db.ref('groups/$groupId').get();
    if (!group.exists) {
      throw ServiceException('Could\'t find this group');
    }

    final user = currentUserId;
    // set for approval in the group
    await _db.ref('groups/$groupId/u/$user').set(false);
    // set the group id inside the profile
    await _db.ref('users/$user/g').set(groupId);
  }

  Future<void> leaveGroup() async {
    final currentGroup = await getGroupId();
    if (currentGroup == null) {
      throw ServiceException('You aren\'t member of any group');
    }
    final user = currentUserId;
    if (currentGroup == user) {
      throw ServiceException(
          'You can\'t leave the group you created, you have to delete it');
    }

    await _db.ref('groups/$currentGroup/u/$user').set(null);
    // set the group id inside the profile
    await _db.ref('users/$user/g').set(null);
  }

  Future<void> createGroup({required String name}) async {
    final currentGroup = await getGroupId();
    if (currentGroup != null) {
      throw ServiceException('First leave the old group');
    }
    final user = currentUserId;
    // temporary bool, so its not empty
    await _db.ref('groups/$user/n').set(name);
    // set the group id inside the profile
    await _db.ref('users/$user/g').set(user);
  }

  Future<void> deleteGroup() async {
    await _db.ref('users/$currentUserId/g').set(null);
    await _db.ref('groups/$currentUserId').set(null);
  }

  /// Call only if owner
  Future<void> approveJoin(String userId) async {
    // just force it, firebase rules wouldnt let you if you arent owner/the value isnt already false
    await _db.ref('groups/$currentUserId/u/$userId').set(true);
  }

  /// Call only if owner
  Future<void> removeFromGroup(String userId) async {
    await _db.ref('groups/$currentUserId/u/$userId').set(null);
  }

  // /// Returns id of a group that contains user with [userId]
  // Future<String?> _searchForGroup(String userId) async {
  //   final groups = await FirebaseDatabase.instance.ref('groups').get();
  //   for (var group in groups.children) {
  //     print('checking group: ${group.key}');
  //     for (var user in group.child('u').children) {
  //       print('checking user: ${user.key} : ${user.value}');
  //       if (user.key == userId && user.value == true) {
  //         return group.key;
  //       }
  //     }
  //   }
  //   return null;
  // }
}
