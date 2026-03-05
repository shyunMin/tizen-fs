import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tizen_fs/l10n/app_localizations.dart';
import 'package:tizen_fs/styles/app_style.dart';

Stream<String> _xmpChunkStream(
  String path, {
  required int linesPerChunk,
}) async* {
  final lower = (String s) => s.toLowerCase();
  final src = File(
    path,
  ).openRead().transform(utf8.decoder).transform(const LineSplitter());

  var inXmp = false;
  var buf = StringBuffer();
  var count = 0;

  await for (final line in src) {
    final ll = lower(line);

    if (!inXmp) {
      final openIdx = ll.indexOf('<xmp');
      if (openIdx >= 0) {
        final gt = ll.indexOf('>', openIdx);
        final after = gt >= 0 ? line.substring(gt + 1) : '';
        if (after.isNotEmpty) {
          buf.writeln(after);
          if (++count % linesPerChunk == 0) {
            yield buf.toString();
            buf.clear();
          }
        }
        inXmp = true;
      }
      continue;
    }

    final closeIdx = ll.indexOf('</xmp>');
    if (closeIdx >= 0) {
      final before = line.substring(0, closeIdx);
      if (before.isNotEmpty) {
        buf.writeln(before);
        count++;
      }
      if (buf.isNotEmpty) {
        yield buf.toString();
        buf.clear();
      }
      count = 0;
      inXmp = false;
      continue;
    }

    buf.writeln(line);
    if (++count % linesPerChunk == 0) {
      yield buf.toString();
      buf.clear();
    }
  }

  if (inXmp && buf.isNotEmpty) yield buf.toString();
}

class OpenSourceLicensePopup extends StatefulWidget {
  const OpenSourceLicensePopup({super.key});

  @override
  State<OpenSourceLicensePopup> createState() => _OpenSourceLicensePopupState();
}

class _OpenSourceLicensePopupState extends State<OpenSourceLicensePopup> {
  static const _path = '/usr/share/license.html';
  static const _linesPerChunk = 50;
  final FocusNode _focusNode = FocusNode();
  final List<String> _chunks = [];
  bool _loading = true;
  String? _error;
  ScrollController _scrollController = ScrollController();
  double _offset = 0;
  StreamSubscription<String>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _listen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _listen() {
    _streamSubscription = _xmpChunkStream(
      _path,
      linesPerChunk: _linesPerChunk,
    ).listen(
      (c) => setState(() => _chunks.add(c)),
      onError:
          (e) => setState(() {
            _error = '$e';
            _loading = false;
          }),
      onDone: () => setState(() => _loading = false),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _focusNode.dispose();
    _scrollController.dispose();
    _chunks.clear();
    super.dispose();
  }

  KeyEventResult onKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape ||
          event.physicalKey == PhysicalKeyboardKey.escape) {
        Navigator.pop(context);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _offset = _offset > 260 ? _offset - 260 : 0;
        _scrollController.animateTo(
          _offset,
          duration: $style.times.fast,
          curve: Curves.easeInOut,
        );
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _offset += 260;
        _scrollController.animateTo(
          _offset,
          duration: $style.times.fast,
          curve: Curves.easeInOut,
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).openSourceLicense),
      ),
      body:
          _error != null
              ? Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              )
              : _loading && _chunks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Focus(
                focusNode: _focusNode,
                onKeyEvent: onKeyEvent,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: _chunks.length + (_loading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (_loading && i == _chunks.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFF101010),
                      child: SelectableText(
                        _chunks[i],
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
