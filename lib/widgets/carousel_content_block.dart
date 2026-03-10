import 'package:flutter/material.dart';
import 'package:tizen_fs/models/immersive_carosel_model.dart';
import 'package:tizen_fs/styles/app_style.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';

class ContentBlock extends StatelessWidget {
  final ImmersiveCarouselContent item;
  final bool isFocused;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onButtonPressed;

  const ContentBlock({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.isFocused,
    this.onTap,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 600,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              child: Text(
                item.overline,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              width: 700,
              child: Text(
                item.description,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            AnimatedSize(
              duration: $style.times.fast,
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: isFocused ? 28 : 0),
                  AnimatedOpacity(
                    opacity: isFocused ? 1.0 : 0.0,
                    duration: $style.times.med,
                    curve: Curves.easeInOut,
                    child: SizedBox(
                      height: isFocused ? 40 : 0,
                      child:
                          (item.url.isNotEmpty)
                              ? ElevatedButton(
                                onPressed: isFocused ? onButtonPressed : null,
                                focusNode:
                                    isFocused
                                        ? null
                                        : AlwaysDisabledFocusNode(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlphaF(isFocused ? 0.9 : 0.15),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  _getLocalizedText(context, item.buttonText),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedText(BuildContext context, String rawText) {
    final l10n = AppLocalizations.of(context);
    switch (rawText) {
      case 'Watch Now':
        return l10n.watchNow;
      default:
        return rawText;
    }
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
