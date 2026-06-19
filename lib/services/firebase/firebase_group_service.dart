import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';

class FirebaseGroupService {
  final _db = FirebaseDatabase.instance;

  Future<Group> getGroup() async {
    final user = currentUserId;
    final db = FirebaseDatabase.instance;

    final groupId = await getGroupId();
    if (groupId == null) {
      throw GroupException(.notMemberOfAnyGroup);
    }
    // todo this group doesnt exist how?
    // final groupSnapshot = await db.ref('groups/$groupId').get();
    // if (!groupSnapshot.exists) {
    //   leaveGroup();
    //   throw ServiceException('This group doesn\'t exist');
    // }

    final groupNameSnapshot = await db.ref('groups/$groupId/n').get();
    final groupName = groupNameSnapshot.value as String? ?? '';

    final groupMembersSnapshot = await db.ref('groups/$groupId/u').get();
    final membersIds = {
      for (var snap in groupMembersSnapshot.children)
        snap.key!: snap.value as bool?,
    };

    // add the group owner to users
    membersIds[groupId] = true;
    // check if you have permission
    if (membersIds[user] == false) {
      throw GroupException(.waitingForApproval);
    }
    // check if you have been removed
    if (membersIds[user] == null) {
      leaveGroup();
      throw GroupException(.removedFromGroup);
    }

    final List<Future> futures = [];

    // Map of userId to Member
    final Map<String, Member> members = {};
    // Map of subjectId to subject
    final Map<String, Subject> subjectsMap = {};
    final List<GroupHomeworkData> hws = [];
    final List<GroupExamData> exams = [];

    membersIds.forEach((memberId, memberState) {
      // members
      futures.add(
        db.ref('users/$memberId/n').get().then((snapshot) {
          members[memberId] = Member(
            memberId,
            snapshot.value as String? ?? '',
            waitingForApproval: memberState == false,
            isYou: memberId == user,
            isOwner: memberId == groupId,
          );
        }),
      );
      // if the user is waiting for approval or its you, dont fetch
      if (memberState != true || memberId == user) return;

      // // Subjects - dont need to save the member
      // futures.add(
      //   db
      //       .ref('users/$memberId/s')
      //       .orderByChild('sh')
      //       .equalTo(true)
      //       .get()
      //       .then((snapshot) {
      //     for (var subject in snapshot.children) {
      //       if (subject.key == null) continue;
      //       final map = Map<String, dynamic>.from(subject.value as Map);
      //       map['sh'] = null;
      //       map.putIfAbsent('id', () => subject.key);
      //       subjectsMap[subject.key!] = Subject.fromFireJson(map);
      //     }
      //   }),
      // );

      // // Homework
      // futures.add(
      //   db
      //       .ref('users/$memberId/h')
      //       .orderByChild('sh')
      //       .startAt(now)
      //       .get()
      //       .then((snapshot) {
      //     for (var hw in snapshot.children) {
      //       final map = Map<String, dynamic>.from(hw.value as Map);
      //       map['id'] = hw.key;
      //       map['c'] = false;
      //       map['memberId'] = memberId;
      //       hws.add(GroupHomeworkData.fromJson(map));
      //     }
      //   }),
      // );

      // // Exams
      // futures.add(
      //   db
      //       .ref('users/$memberId/e')
      //       .orderByChild('sh')
      //       .startAt(now)
      //       .get()
      //       .then((snapshot) {
      //     for (var exam in snapshot.children) {
      //       final map = Map<String, dynamic>.from(exam.value as Map);
      //       map['id'] = exam.key;
      //       map['memberId'] = memberId;
      //       exams.add(GroupExamData.fromJson(map));
      //     }
      //   }),
      // );
    });

    await Future.wait(futures);
    // now we have all subjects and homeworks/exams (these have only their subjectId)
    final List<GroupTask> tasks = [];

    for (var exam in exams) {
      final member = members[exam.memberId];
      // just to be safe
      if (member != null) {
        tasks.add(exam.convert(subjectsMap[exam.exam.subjectId], member));
      }
    }

    for (var hw in hws) {
      final member = members[hw.memberId];
      // just to be safe
      if (member != null) {
        tasks.add(hw.convert(subjectsMap[hw.hw.subjectId], member));
      }
    }

    return Group(
      groupId: groupId,
      groupName: groupName,
      members: members.values.toList(),
      tasks: tasks,
    );
  }

  /// Throws logged out message if current user is null
  String get currentUserId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw AuthException(.loggedOut, exceptionAction: .cloudsyncLogin);
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
      throw GroupException(.leaveOldGroup);
    }

    // todo check that group exists
    // final group = await _db.ref('groups/$groupId').get();
    // if (!group.exists) {
    //   throw ServiceException('Could\'t find this group');
    // }

    final user = currentUserId;
    // set for approval in the group
    await _db.ref('groups/$groupId/u/$user').set(false);
    // set the group id inside the profile
    await _db.ref('users/$user/g').set(groupId);
  }

  Future<void> leaveGroup() async {
    final currentGroup = await getGroupId();
    if (currentGroup == null) {
      throw GroupException(.notMemberOfAnyGroup);
    }
    final user = currentUserId;
    if (currentGroup == user) {
      throw GroupException(.cantLeaveYourGroup);
    }

    await _db.ref('groups/$currentGroup/u/$user').set(null);
    // set the group id inside the profile
    await _db.ref('users/$user/g').set(null);
  }

  Future<void> createGroup({required String name}) async {
    final currentGroup = await getGroupId();
    if (currentGroup != null) {
      throw GroupException(.leaveOldGroup);
    }
    final user = currentUserId;
    await _db.ref('groups/$user/n').set(name);
    // set the group id inside the profile
    await _db.ref('users/$user/g').set(user);
  }

  Future<void> changeGroupName({required String name}) async {
    final currentGroup = await getGroupId();
    final user = currentUserId;
    if (currentGroup != user) {
      throw GroupException(.cantChangeName);
    }
    // todo check that the group exists
    await _db.ref('groups/$user/n').set(name);
  }

  Future<void> deleteGroup() async {
    await _db.ref('users/$currentUserId/g').set(null);
    await _db.ref('groups/$currentUserId').set(null);
  }

  /// Call only if owner
  Future<void> approveJoin(String userId) async {
    // no need to check if this user is owner,
    // firebase rules wouldnt let you if you arent / the value isnt already false
    await _db.ref('groups/$currentUserId/u/$userId').set(true);
  }

  /// Call only if owner
  Future<void> removeFromGroup(String userId) async {
    await _db.ref('groups/$currentUserId/u/$userId').set(null);
  }
}
