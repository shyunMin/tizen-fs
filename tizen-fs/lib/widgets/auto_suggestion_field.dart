import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:tizen_fs/providers/additional_feature_provider.dart';
import 'package:tizen_fs/widgets/blink_border.dart';

class AutoSuggestField extends StatefulWidget {
  const AutoSuggestField({
    super.key,
    required this.suggestions,
    this.onSelected,
    this.onSubmitted,
  });

  final List<String> suggestions;
  final Function(String)? onSelected;
  final Function(String)? onSubmitted;

  @override
  State<AutoSuggestField> createState() => AutoSuggestFieldState();
}

class AutoSuggestFieldState extends State<AutoSuggestField> {
  late FocusNode? _focusNode;

  final TextEditingController _controller = TextEditingController();

  void requestFocus() {
    _focusNode?.requestFocus();
  }

  void _onSubmitted(String action) {
    if (action.trim().isEmpty) return;
    widget.onSubmitted?.call(action);
    _controller.clear();

    _focusNode?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final aiFeature = context.read<AdditaionalFeatureProvider>().getFeature(
      'ai',
    );
    final isAiEnabled = aiFeature?.isEnabled ?? false;

    return TypeAheadField<String>(
      controller: _controller,
      builder: (context, controller, focusNode) {
        _focusNode = focusNode;
        _controller.clear();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          // 위젯 타입을 BlinkBorder로 고정하여 트리를 유지합니다.
          child: BlinkBorder(
            isAiMode: isAiEnabled, // 새 파라미터 추가 (아래 BlinkBorder 수정 참고)
            borderColor: Colors.grey.shade600,
            borderRadius: BorderRadius.circular(30),
            child: _getContent(context, controller, focusNode),
          ),
        );
      },
      suggestionsCallback: _getSuggestions,
      itemBuilder: (context, suggestion) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListTile(
            title: highlightTextDifference(
              suggestion: suggestion.toString(),
              input: _controller.text,
            ),
          ),
        );
      },
      onSelected: (suggestion) {
        _controller.text = suggestion;
        widget.onSelected?.call(suggestion);
      },
      hideOnLoading: true,
      hideOnEmpty: true,
      debounceDuration: const Duration(milliseconds: 100),
    );
  }

  Widget _getContent(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.none,
            decoration: const InputDecoration(
              hintText: 'Type any message',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
            onSubmitted: (value) {
              controller.text = '';
              _onSubmitted(value);
            },
          ),
        ),
        IconButton(
          autofocus: false,
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: () {
            _onSubmitted(controller.text);
            controller.text = '';
          },
        ),
      ],
    );
  }

  Future<List<String>> _getSuggestions(String input) async {
    if (input.isEmpty) {
      return List.empty();
    }

    return widget.suggestions
        .where((action) => action.toLowerCase().contains(input.toLowerCase()))
        .toList();
  }

  Widget highlightTextDifference({
    required String suggestion,
    required String input,
    TextStyle defaultStyle = const TextStyle(color: Colors.white),
    Color highlightColor = Colors.blue,
  }) {
    if (suggestion.isEmpty || input.isEmpty) {
      return Text(suggestion.isEmpty ? '' : suggestion, style: defaultStyle);
    }

    int maxLength = 0;
    int startIndex = -1;

    for (int i = 0; i < suggestion.length; i++) {
      for (int j = 0; j < input.length; j++) {
        int currentLength = 0;
        while (i + currentLength < suggestion.length &&
            j + currentLength < input.length &&
            suggestion[i + currentLength].toLowerCase() ==
                input[j + currentLength].toLowerCase()) {
          currentLength++;
        }

        if (currentLength > maxLength) {
          maxLength = currentLength;
          startIndex = i;
        }
      }
    }

    if (maxLength == 0) {
      return Text(suggestion, style: defaultStyle);
    }

    final String beforePart = suggestion.substring(0, startIndex);
    final String matchedPart = suggestion.substring(
      startIndex,
      startIndex + maxLength,
    );
    final String afterPart = suggestion.substring(startIndex + maxLength);

    return RichText(
      text: TextSpan(
        style: defaultStyle,
        children: <TextSpan>[
          TextSpan(text: beforePart),
          TextSpan(
            text: matchedPart,
            style: defaultStyle.copyWith(color: highlightColor),
          ),
          TextSpan(text: afterPart),
        ],
      ),
    );
  }
}
