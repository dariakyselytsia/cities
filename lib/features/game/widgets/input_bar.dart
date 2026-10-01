import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/theme.dart';

/// The bottom bar: hint (with how many are left), the city field and send.
///
/// The field stays editable while CityBot thinks, so the keyboard doesn't
/// close and reopen every turn; only sending and hints wait for
/// [canSend].
class InputBar extends StatelessWidget {
  const InputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.canSend,
    required this.hintsLeft,
    required this.onSubmit,
    required this.onHint,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool canSend;
  final int hintsLeft;
  final VoidCallback onSubmit;
  final VoidCallback onHint;

  @override
  Widget build(BuildContext context) {
    final canHint = canSend && hintsLeft > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: canHint ? onHint : null,
            tooltip: 'game.hint'.tr(),
            color: AppColors.purple,
            icon: Badge(
              label: Text('$hintsLeft'),
              backgroundColor: hintsLeft > 0
                  ? AppColors.purple
                  : AppColors.disabled,
              child: const Icon(Icons.lightbulb_outline_rounded),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.send,
              // Handling "send" here (not in onSubmitted) keeps the keyboard
              // open between turns.
              onEditingComplete: canSend ? onSubmit : () {},
              decoration: InputDecoration(hintText: 'game.enter_city'.tr()),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: canSend ? onSubmit : null,
            tooltip: 'game.send'.tr(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.disabled,
              disabledForegroundColor: Colors.white,
              fixedSize: const Size(48, 48),
            ),
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
