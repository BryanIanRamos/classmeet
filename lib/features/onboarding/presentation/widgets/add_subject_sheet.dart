import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/inputs/app_text_field.dart';
import '../../../../core/widgets/layout/app_sheet.dart';

/// Provisional "Add another subject" sheet (GAP-22): the design has no target
/// for the dashed row of frame 97. A name field and an Add button; pops with
/// the trimmed name.
Future<String?> showAddSubjectSheet(BuildContext context) {
  return showAppSheet<String>(
    context,
    builder: (context) => const AddSubjectSheet(),
  );
}

class AddSubjectSheet extends StatefulWidget {
  const AddSubjectSheet({super.key});

  @override
  State<AddSubjectSheet> createState() => _AddSubjectSheetState();
}

class _AddSubjectSheetState extends State<AddSubjectSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _name => _controller.text.trim();

  void _submit() {
    if (_name.isEmpty) return;
    Navigator.pop(context, _name);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AppSheet(
        title: 'Add another subject',
        onClose: () => Navigator.pop(context),
        footer: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => AppButton(
            label: 'Add',
            expand: true,
            onPressed: _name.isEmpty ? null : _submit,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
          child: AppTextField(
            controller: _controller,
            label: 'Subject name',
            placeholder: 'e.g. Operating Systems',
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
      ),
    );
  }
}
