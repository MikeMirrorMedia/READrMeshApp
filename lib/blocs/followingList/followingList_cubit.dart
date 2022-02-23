import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readr/helpers/errorHelper.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/publisher.dart';
import 'package:readr/services/personalFileService.dart';

part 'followingList_state.dart';

class FollowingListCubit extends Cubit<FollowingListState> {
  FollowingListCubit() : super(FollowingListInitial());
  final PersonalFileService _personalFileService = PersonalFileService();

  fetchFollowingList(
      {required Member viewMember, required Member currentMember}) async {
    try {
      emit(FollowingListLoaded(
          followingMemberList: await _personalFileService.fetchFollowingList(
              viewMember, currentMember),
          followPublisherList: await _personalFileService.fetchFollowPublisher(
            viewMember,
          )));
    } catch (e) {
      emit(FollowingListError(determineException(e)));
    }
  }

  loadMore({
    required Member viewMember,
    required Member currentMember,
    required int skip,
  }) async {
    try {
      emit(FollowingListLoadMoreSuccess(await _personalFileService
          .fetchFollowingList(viewMember, currentMember, skip: skip)));
    } catch (e) {
      emit(FollowingListLoadMoreFailed(determineException(e)));
    }
  }
}