import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/tabStoryList/bloc.dart';
import 'package:readr/blocs/tabStoryList/events.dart';
import 'package:readr/blocs/tabStoryList/states.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/exceptions.dart';
import 'package:readr/models/storyListItemList.dart';
import 'package:readr/pages/home/homeStoryListItem.dart';
import 'package:readr/pages/home/homeStoryPjojectItem.dart';
import 'package:readr/pages/shared/tabContentNoResultWidget.dart';

class HomeTabContent extends StatefulWidget {
  final String categorySlug;
  const HomeTabContent({
    required this.categorySlug,
  });

  @override
  _HomeTabContentState createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  @override
  void initState() {
    if (widget.categorySlug == 'latest') {
      _fetchStoryList();
    } else {
      _fetchStoryListByCategorySlug();
    }
    super.initState();
  }

  _fetchStoryList() async {
    context.read<TabStoryListBloc>().add(FetchStoryList());
  }

  _fetchNextPage() async {
    context.read<TabStoryListBloc>().add(FetchNextPage());
  }

  _fetchStoryListByCategorySlug() async {
    context
        .read<TabStoryListBloc>()
        .add(FetchStoryListByCategorySlug(widget.categorySlug));
  }

  _fetchNextPageByCategorySlug() async {
    context
        .read<TabStoryListBloc>()
        .add(FetchNextPageByCategorySlug(widget.categorySlug));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabStoryListBloc, TabStoryListState>(
        builder: (BuildContext context, TabStoryListState state) {
      if (state.status == TabStoryListStatus.error) {
        final error = state.error;
        print('TabStoryListError: ${error.message}');
        if (error is NoInternetException) {
          return error.renderWidget(isNoButton: true, isColumn: true);
        }

        return error.renderWidget(isNoButton: true, isColumn: true);
      }
      if (state.status == TabStoryListStatus.loaded) {
        StoryListItemList mixedStoryList = state.mixedStoryList!;

        if (mixedStoryList.isEmpty) {
          return Center(
            child: TabContentNoResultWidget(),
          );
        }

        return _tabStoryList(
          mixedStoryList: mixedStoryList,
        );
      }

      if (state.status == TabStoryListStatus.loadingMore) {
        StoryListItemList mixedStoryList = state.mixedStoryList!;
        return _tabStoryList(
          mixedStoryList: mixedStoryList,
          isLoading: true,
        );
      }

      if (state.status == TabStoryListStatus.loadingMoreFail) {
        StoryListItemList mixedStoryList = state.mixedStoryList!;

        if (widget.categorySlug == 'latest') {
          _fetchNextPage();
        } else {
          _fetchNextPageByCategorySlug();
        }
        return _tabStoryList(
          mixedStoryList: mixedStoryList,
          isLoading: true,
        );
      }

      // state is Init, loading, or other
      return Center(
        child: Platform.isAndroid
            ? const CircularProgressIndicator(
                color: hightLightColor,
              )
            : const CupertinoActivityIndicator(),
      );
    });
  }

  Widget _tabStoryList({
    required StoryListItemList mixedStoryList,
    bool isLoading = false,
  }) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 24.0),
        itemBuilder: (BuildContext context, int index) {
          if (!isLoading &&
              index == mixedStoryList.length - 5 &&
              mixedStoryList.length < mixedStoryList.allStoryCount) {
            if (widget.categorySlug == 'latest') {
              _fetchNextPage();
            } else {
              _fetchNextPageByCategorySlug();
            }
          }
          Widget listItem;
          if (mixedStoryList[index].isProject) {
            listItem = HomeStoryPjojectItem(
              projectListItem: mixedStoryList[index],
            );
          } else {
            listItem = HomeStoryListItem(
              storyListItem: mixedStoryList[index],
            );
          }

          return Column(
            children: [
              listItem,
              if (index == mixedStoryList.length - 1 && isLoading)
                _loadMoreWidget(),
            ],
          );
        },
        itemCount: mixedStoryList.length,
      ),
    );
  }

  Widget _loadMoreWidget() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(child: CupertinoActivityIndicator()),
    );
  }
}