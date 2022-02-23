import 'package:extended_text/extended_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/member.dart';
import 'package:readr/pages/shared/ProfilePhotoWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:readr/services/commentService.dart';

class PickCommentItem extends StatefulWidget {
  final Comment comment;
  final Member member;
  final bool isExpanded;
  final bool isMyComment;
  const PickCommentItem({
    required this.comment,
    required this.member,
    this.isExpanded = false,
    this.isMyComment = false,
  });

  @override
  _PickCommentItemState createState() => _PickCommentItemState();
}

class _PickCommentItemState extends State<PickCommentItem> {
  bool _isExpanded = false;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    _isLiked = widget.comment.isLiked;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(0, 9, 40, 0.05),
        border: Border.all(
          color: Colors.black12,
          width: 0.5,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(6.0)),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _time(),
          const SizedBox(height: 12),
          _content(),
        ],
      ),
    );
  }

  Widget _time() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Row(
            children: [
              ProfilePhotoWidget(
                widget.comment.member,
                14,
              ),
              const SizedBox(width: 8),
              Timestamp(
                widget.comment.publishDate,
                textSize: 13,
              ),
              if (widget.isMyComment) ...[
                Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 0.0),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    '編輯留言',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.comment.likedCount.toString(),
                style: const TextStyle(
                  color: Color.fromRGBO(0, 9, 40, 0.66),
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: () async {
                  if (FirebaseAuth.instance.currentUser != null) {
                    // save origin state
                    bool originIsLiked = _isLiked;
                    int originLikeCount = widget.comment.likedCount;
                    // refresh UI first
                    setState(() {
                      if (_isLiked) {
                        widget.comment.likedCount--;
                      } else {
                        widget.comment.likedCount++;
                      }
                      _isLiked = !_isLiked;
                    });
                    CommentService commentService = CommentService();
                    int? newLikeCount;
                    if (originIsLiked) {
                      newLikeCount = await commentService.removeLike(
                        memberId: widget.member.memberId,
                        commentId: widget.comment.id,
                      );
                    } else {
                      newLikeCount = await commentService.addLike(
                        memberId: widget.member.memberId,
                        commentId: widget.comment.id,
                      );
                    }

                    // if return null mean failed
                    if (newLikeCount == null) {
                      widget.comment.likedCount = originLikeCount;
                      _isLiked = originIsLiked;
                    } else {
                      widget.comment.likedCount = newLikeCount;
                    }
                  }
                },
                iconSize: 18,
                padding: const EdgeInsets.all(0),
                constraints: const BoxConstraints(),
                icon: Icon(
                  _isLiked
                      ? Icons.favorite_outlined
                      : Icons.favorite_border_outlined,
                  color: _isLiked
                      ? Colors.red
                      : const Color.fromRGBO(0, 9, 40, 0.66),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _content() {
    return GestureDetector(
      onTap: () {
        if (!_isExpanded) {
          setState(() {
            _isExpanded = true;
          });
        }
      },
      child: ExtendedText(
        widget.comment.content,
        maxLines: _isExpanded ? null : 3,
        style: const TextStyle(
          color: Color.fromRGBO(0, 9, 40, 0.66),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        joinZeroWidthSpace: true,
        overflowWidget: TextOverflowWidget(
          position: TextOverflowPosition.end,
          child: RichText(
            text: const TextSpan(
              text: '... ',
              style: TextStyle(
                color: Color.fromRGBO(0, 9, 40, 0.66),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: '顯示更多',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}