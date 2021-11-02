import 'package:flutter/material.dart';

class QuoteByWidget extends StatelessWidget {
  final String quote;
  final String? quoteBy;
  final double textSize;
  const QuoteByWidget({required this.quote, this.quoteBy, this.textSize = 20});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      padding: const EdgeInsets.only(top: 8, left: 32, right: 32, bottom: 32),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            size: 60,
            color: Colors.black12,
          ),
          const SizedBox(
            height: 16,
          ),
          SizedBox(
            width: width,
            child: Text(
              quote,
              style: const TextStyle(
                fontSize: 20,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (quoteBy != null && quoteBy != '') ...[
            const SizedBox(
              height: 16,
            ),
            Container(
              width: width,
              alignment: Alignment.centerRight,
              child: Text(
                '—— $quoteBy',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}