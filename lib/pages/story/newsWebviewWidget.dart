import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:readr/blocs/news/news_cubit.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/newsStoryItem.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/shared/bottomCard/bottomCardWidget.dart';
import 'package:readr/pages/story/storyAppBar.dart';
import 'package:readr/pages/story/storySkeletonScreen.dart';

class NewsWebviewWidget extends StatefulWidget {
  final NewsListItem news;
  const NewsWebviewWidget({
    required this.news,
  });

  @override
  _NewsWebviewWidgetState createState() => _NewsWebviewWidgetState();
}

class _NewsWebviewWidgetState extends State<NewsWebviewWidget> {
  bool _isLoading = true;
  late NewsStoryItem _newsStoryItem;
  bool _isPicked = false;
  final ValueNotifier<String> _inputValue = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
  }

  _fetchNewsData() async {
    context.read<NewsCubit>().fetchNewsData(newsId: widget.news.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewsCubit, NewsState>(
      builder: (context, state) {
        if (state is NewsError) {
          final error = state.error;
          print('NewsPageError: ${error.message}');

          return Column(
            children: [
              StoryAppBar(
                newsStoryItem: null,
                inputText: '',
                url: widget.news.url,
              ),
              Expanded(
                child: ErrorPage(
                  error: error,
                  onPressed: () => _fetchNewsData(),
                  hideAppbar: true,
                ),
              ),
            ],
          );
        }

        if (state is NewsLoaded) {
          _newsStoryItem = state.newsStoryItem;
          if (_newsStoryItem.myPickId != null) {
            _isPicked = true;
          }
          return _webViewWidget(context);
        }

        return StorySkeletonScreen(widget.news.url);
      },
    );
  }

  Widget _webViewWidget(BuildContext context) {
    String url = widget.news.url;
    InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          mediaPlaybackRequiresUserGesture: false,
          disableContextMenu: true,
        ),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
        ),
        ios: IOSInAppWebViewOptions(
          allowsInlineMediaPlayback: true,
          allowsLinkPreview: false,
          disableLongPressContextMenuOnLinks: true,
        ));
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _inputValue,
                builder: (context, String text, child) {
                  return StoryAppBar(
                    newsStoryItem: _newsStoryItem,
                    inputText: text,
                    url: widget.news.url,
                  );
                },
              ),
              Expanded(
                child: InAppWebView(
                  initialOptions: options,
                  initialUrlRequest: URLRequest(url: Uri.parse(url)),
                  onLoadStop: (controller, url) async {
                    await Future.delayed(const Duration(milliseconds: 150));
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
            ],
          ),
          BottomCardWidget(
            controllerTag: _newsStoryItem.controllerTag,
            onTextChanged: (value) => _inputValue.value = value,
            isPicked: _isPicked,
            title: _newsStoryItem.title,
            author: _newsStoryItem.source.title,
            id: _newsStoryItem.id,
            objective: PickObjective.story,
            allComments: _newsStoryItem.allComments,
            popularComments: _newsStoryItem.popularComments,
          ),
          _isLoading ? StorySkeletonScreen(widget.news.url) : Container(),
        ],
      ),
    );
  }
}
