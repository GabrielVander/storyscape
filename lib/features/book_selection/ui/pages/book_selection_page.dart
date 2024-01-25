import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:storyscape/core/routing/routes.dart';

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

class BookUrlField extends HookWidget {
  const BookUrlField({required this.onFinished, super.key});

  final void Function(String) onFinished;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = useTextEditingController();

    return TextField(
      controller: controller,
      onEditingComplete: () => onFinished(controller.value.text),
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: 'bookSelection.urlFieldLabel'.tr(),
        suffixIcon:
            IconButton(onPressed: () => onFinished(controller.value.text), icon: const Icon(Icons.arrow_forward)),
      ),
    );
  }
}
