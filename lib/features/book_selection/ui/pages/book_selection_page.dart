import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:storyscape/core/routing/routes.dart';
import 'package:storyscape/features/book_selection/ui/pages/book_url_field.dart';

class BookSelectionPage extends StatelessWidget {
  const BookSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bookSelection.pageTitle'.tr()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: BookUrlField(
            onFinished: (String url) => BookReadingRoute(url: url).push<void>(context),
          ),
        ),
      ),
    );
  }
}
