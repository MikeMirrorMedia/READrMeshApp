import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:readr/blocs/editorChoice/bloc.dart';
import 'package:readr/blocs/editorChoice/events.dart';
import 'package:readr/blocs/editorChoice/states.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/openProjectHelper.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/editorChoiceItem.dart';
import 'package:readr/pages/shared/editorChoice/carouselDisplayWidget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BuildEditorChoiceCarousel extends StatefulWidget {
  @override
  _BuildEditorChoiceCarouselState createState() =>
      _BuildEditorChoiceCarouselState();
}

class _BuildEditorChoiceCarouselState extends State<BuildEditorChoiceCarousel> {
  @override
  void initState() {
    _loadEditorChoice();
    super.initState();
  }

  _loadEditorChoice() {
    context.read<EditorChoiceBloc>().add(FetchEditorChoiceList());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditorChoiceBloc, EditorChoiceState>(
        builder: (BuildContext context, EditorChoiceState state) {
      if (state.status == EditorChoiceStatus.error) {
        final error = state.error;
        print('EditorChoiceError: ${error.message}');
        return Container();
      }
      if (state.status == EditorChoiceStatus.loaded) {
        List<EditorChoiceItem> editorChoiceList = state.editorChoiceList;

        if (editorChoiceList.isEmpty) {
          return Container();
        }
        return EditorChoiceCarousel(
          editorChoiceList: editorChoiceList,
          aspectRatio: 4 / 3.2,
        );
      }

      // state is Init, loading, or other
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
                  highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 18,
                    left: 19,
                  ),
                  child: SvgPicture.asset(
                    logoSimplifySvg,
                  ),
                ),
              ],
            ),
            Shimmer.fromColors(
              baseColor: const Color.fromRGBO(0, 9, 40, 0.15),
              highlightColor: const Color.fromRGBO(0, 9, 40, 0.1),
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.0),
                      child: Container(
                        height: 32,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      width: double.infinity,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.0),
                      child: Container(
                        height: 32,
                        width: (MediaQuery.of(context).size.width - 40) * 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class EditorChoiceCarousel extends StatefulWidget {
  final List<EditorChoiceItem> editorChoiceList;
  final double aspectRatio;
  const EditorChoiceCarousel({
    required this.editorChoiceList,
    this.aspectRatio = 16 / 9,
  });

  @override
  _EditorChoiceCarouselState createState() => _EditorChoiceCarouselState();
}

class _EditorChoiceCarouselState extends State<EditorChoiceCarousel> {
  final PageController _carouselController = PageController();
  int _current = 0;
  final double aspectRatio = 16 / 9;
  late PausableTimer timer;
  static const _fadeInDurationLong = 4000;
  static const _fadeInDurationShort = 500;
  int _fadeInDuration = _fadeInDurationShort;
  final ChromeSafariBrowser browser = ChromeSafariBrowser();
  bool _timerIsStart = true;

  @override
  void initState() {
    super.initState();
    if (widget.editorChoiceList.isNotEmpty) {
      timer =
          PausableTimer(const Duration(seconds: 5), () => _changeToNextPage());
      timer.start();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.editorChoiceList.isNotEmpty) timer.cancel();
  }

  _changeToNextPage() {
    if (_current == widget.editorChoiceList.length - 1) {
      _current = 0;
      _fadeInDuration = _fadeInDurationLong;
    } else {
      _current++;
      _fadeInDuration = _fadeInDurationShort;
    }
    _carouselController.animateToPage(
      _current,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return widget.editorChoiceList.isEmpty
        ? Container()
        : VisibilityDetector(
            key: const Key('editorChoice'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage < 15) {
                timer.pause();
                _timerIsStart = false;
              } else if (!_timerIsStart) {
                timer.reset();
                timer.start();
                _timerIsStart = true;
              }
            },
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: GestureDetector(
                      onTap: () async {
                        EditorChoiceItem editorChoiceItem =
                            widget.editorChoiceList.elementAt(_current);
                        if (editorChoiceItem.isProject) {
                          OpenProjectHelper()
                              .phaseByEditorChoiceItem(editorChoiceItem);
                        } else {
                          if (editorChoiceItem.id != null) {
                            AutoRouter.of(context)
                                .push(StoryRoute(id: editorChoiceItem.id!));
                          } else if (editorChoiceItem.link != null) {
                            await browser.open(
                              url: Uri.parse(editorChoiceItem.link!),
                              options: ChromeSafariBrowserClassOptions(
                                android: AndroidChromeCustomTabsOptions(),
                                ios: IOSSafariOptions(
                                    barCollapsingEnabled: true),
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        color: Colors.black,
                        child: Stack(
                          children: [
                            FadeIn(
                              key: UniqueKey(),
                              duration: Duration(milliseconds: _fadeInDuration),
                              child: Container(
                                color: Colors.black,
                                child: _displayImage(
                                    width,
                                    widget.editorChoiceList
                                        .elementAt(_current)),
                              ),
                            ),
                            if (widget.editorChoiceList
                                .elementAt(_current)
                                .isProject)
                              Container(
                                alignment: Alignment.topRight,
                                margin: const EdgeInsets.only(
                                  top: 16,
                                  right: 12,
                                ),
                                child: _displayTag(),
                              ),
                            Container(
                              padding: const EdgeInsets.only(
                                top: 18,
                                left: 19,
                              ),
                              child: SvgPicture.asset(
                                logoSimplifySvg,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (TapDownDetails e) {
                      timer.cancel();
                    },
                    onTapUp: (TapUpDetails e) {
                      timer = PausableTimer(const Duration(seconds: 5),
                          () => _changeToNextPage());
                      timer.start();
                    },
                    child: ExpandablePageView.builder(
                      itemCount: widget.editorChoiceList.length,
                      itemBuilder: (context, index) {
                        return CarouselDisplayWidget(
                          editorChoiceItem:
                              widget.editorChoiceList.elementAt(index),
                          width: width,
                        );
                      },
                      controller: _carouselController,
                      onPageChanged: (index) {
                        if (index == 0) {
                          _fadeInDuration = _fadeInDurationShort;
                        }
                        timer.cancel();
                        setState(() {
                          _current = index;
                        });
                        timer = PausableTimer(const Duration(seconds: 5),
                            () => _changeToNextPage());
                        timer.start();
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.editorChoiceList.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => _carouselController.animateToPage(
                          entry.key,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        ),
                        child: Container(
                          width: 8.0,
                          height: 8.0,
                          margin: const EdgeInsets.only(
                            top: 24.0,
                            left: 4.0,
                            right: 4.0,
                            bottom: 16,
                          ),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _current == entry.key
                                  ? const Color(0xff04295E)
                                  : Colors.black12),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          );
  }

  Widget _displayImage(double width, EditorChoiceItem editorChoiceItem) {
    return editorChoiceItem.photoUrl == null
        ? SvgPicture.asset(defaultImageSvg)
        : CachedNetworkImage(
            height: 300,
            width: width,
            imageUrl: editorChoiceItem.photoUrl!,
            placeholder: (context, url) => Container(
              height: width / aspectRatio,
              width: width,
              color: Colors.grey,
            ),
            errorWidget: (context, url, error) => Container(
              height: width / aspectRatio,
              width: width,
              color: Colors.grey,
              child: const Icon(Icons.error),
            ),
            fit: BoxFit.cover,
          );
  }

  Widget _displayTag() {
    return Container(
      decoration: BoxDecoration(
        color: editorChoiceTagColor,
        borderRadius: BorderRadiusDirectional.circular(2),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        child: Text(
          '專題',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
