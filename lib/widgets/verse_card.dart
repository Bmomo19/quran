import 'package:flutter/material.dart';

class VerseCard extends StatelessWidget {
  final int verseNumber;
  final String verseText;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const VerseCard({
    super.key,
    required this.verseNumber,
    required this.verseText,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$verseNumber',
                  style: const TextStyle(
                    color: Color(0xFF00897B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: onBookmark,
                    color: Colors.grey,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: onShare,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            verseText,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 24,
              height: 2.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}