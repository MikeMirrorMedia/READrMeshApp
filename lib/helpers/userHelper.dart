import 'package:firebase_auth/firebase_auth.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/visitorService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  UserHelper._internal();

  factory UserHelper() => _instance;

  static late final UserHelper _instance = UserHelper._internal();

  static UserHelper get instance => _instance;

  final MemberService _memberService = MemberService();
  final VisitorService _visitorService = VisitorService();

  bool _isInitialized = false;
  late Member _member;

  bool get isMember => FirebaseAuth.instance.currentUser != null;

  bool get isVisitor => FirebaseAuth.instance.currentUser == null;

  bool get isInitialized => _isInitialized;

  List<Member> _localFollowingMemberList = [];
  List<Publisher> _localFollowingPublisherList = [];

  List<Publisher> get localPublisherList => _localFollowingPublisherList;

  // if want to use member, must call fetchUserData() once
  Member get currentUser => _member;

  Future<void> fetchUserData({Member? member}) async {
    if (member != null) {
      _member = member;
    } else if (isMember) {
      var memberData = await _memberService.fetchMemberData();
      if (memberData != null) {
        _member = memberData;
      } else {
        await FirebaseAuth.instance.signOut();
        _member = await _visitorService.fetchMemberData();
      }
    } else {
      _member = await _visitorService.fetchMemberData();
    }
    _isInitialized = true;
    _localFollowingMemberList = [];
    _localFollowingPublisherList = [];
    _localFollowingMemberList.addAll(_member.following);
    _localFollowingPublisherList.addAll(_member.followingPublisher);
  }

  bool isFollowingMember(Member member) {
    if (!_isInitialized) {
      return false;
    } else {
      for (var following in _member.following) {
        if (following.memberId == member.memberId) {
          member.isFollowing = true;
          return true;
        }
      }
      return false;
    }
  }

  Future<bool> addFollowingMember(String memberId) async {
    List<Member>? newFollowingList;

    newFollowingList = await _memberService.addFollowingMember(memberId);

    if (newFollowingList != null) {
      _member.following = newFollowingList;
      syncFollowing();
      return true;
    } else {
      syncFollowing();
      return false;
    }
  }

  Future<bool> removeFollowingMember(String memberId) async {
    List<Member>? newFollowingList;

    newFollowingList = await _memberService.removeFollowingMember(memberId);

    if (newFollowingList != null) {
      _member.following = newFollowingList;
      syncFollowing();
      return true;
    } else {
      syncFollowing();
      return false;
    }
  }

  bool isFollowingPublisher(Publisher publisher) {
    if (!_isInitialized) {
      return false;
    } else {
      for (var following in _member.followingPublisher) {
        if (following.id == publisher.id) {
          return true;
        }
      }
      return false;
    }
  }

  Future<bool> addFollowPublisher(String publisherId) async {
    List<Publisher>? newFollowingList;
    if (isMember) {
      newFollowingList = await _memberService.addFollowPublisher(publisherId);
    } else {
      newFollowingList = await _visitorService.addFollowPublisher(publisherId);
    }

    if (newFollowingList != null) {
      _member.followingPublisher = newFollowingList;
      syncFollowing();
      return true;
    } else {
      syncFollowing();
      return false;
    }
  }

  Future<bool> removeFollowPublisher(String publisherId) async {
    List<Publisher>? newFollowingList;
    if (isMember) {
      newFollowingList =
          await _memberService.removeFollowPublisher(publisherId);
    } else {
      newFollowingList =
          await _visitorService.removeFollowPublisher(publisherId);
    }

    if (newFollowingList != null) {
      _member.followingPublisher = newFollowingList;
      syncFollowing();
      return true;
    } else {
      syncFollowing();
      return false;
    }
  }

  Future<void> addVisitorFollowing() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> followingPublisherIds =
        prefs.getStringList('followingPublisherIds') ?? [];
    if (followingPublisherIds.isNotEmpty) {
      List<Future> futureList = [];
      for (var publisherId in followingPublisherIds) {
        futureList.add(_memberService.addFollowPublisher(publisherId));
      }
      await Future.wait(futureList);
    }
    await UserHelper.instance.fetchUserData();
  }

  // local following list

  bool isLocalFollowingMember(Member member) {
    return _localFollowingMemberList
        .any((element) => element.memberId == member.memberId);
  }

  bool isLocalFollowingPublisher(Publisher publisher) {
    return _localFollowingPublisherList
        .any((element) => element.id == publisher.id);
  }

  void updateLocalFollowingMember(Member member) {
    int index = _localFollowingMemberList
        .indexWhere((element) => element.memberId == member.memberId);
    if (index == -1) {
      _localFollowingMemberList.add(member);
    } else {
      _localFollowingMemberList.removeAt(index);
    }
  }

  void updateLocalFollowingPublisher(Publisher publisher) {
    int index = _localFollowingPublisherList
        .indexWhere((element) => element.id == publisher.id);
    if (index == -1) {
      _localFollowingPublisherList.add(publisher);
    } else {
      _localFollowingPublisherList.removeAt(index);
    }
  }

  void syncFollowing() {
    _localFollowingMemberList = [];
    _localFollowingPublisherList = [];
    _localFollowingMemberList.addAll(_member.following);
    _localFollowingPublisherList.addAll(_member.followingPublisher);
  }

  // pick data
  final Map<String, PickedItem> _newsPickedMap = {};

  void updateNewsPickedMap(String newsId, PickedItem? item) {
    if (item != null) {
      _newsPickedMap.update(
        newsId,
        (value) => item,
        ifAbsent: () => item,
      );
    } else {
      _newsPickedMap.remove(newsId);
    }
  }

  bool isNewsPicked(String newsId) {
    if (isVisitor) return false;
    return _newsPickedMap.containsKey(newsId);
  }

  PickedItem? getNewsPickedItem(String newsId) {
    return _newsPickedMap[newsId];
  }
}

class PickedItem {
  String pickId;
  int pickCount;
  int commentCount;
  String? pickCommentId;
  PickedItem({
    required this.pickId,
    required this.pickCount,
    required this.commentCount,
    this.pickCommentId,
  });
}
