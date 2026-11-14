import 'package:flutter/material.dart';
import '../models/word_model.dart';
import 'widgets/word_detail_view.dart';

class WordDetailScreen extends StatelessWidget {
  final WordModel word;

  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          word.word,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: WordDetailView(word: word),
    );
  }
}