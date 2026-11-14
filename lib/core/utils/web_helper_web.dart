// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

bool get isWebPlatform => true;

String get currentHref => html.window.location.href;

void openBrowserUrl(String url, {String target = '_blank'}) {
  html.window.open(url, target);
}

class WebPopupHandle {
  final html.WindowBase? _window;
  WebPopupHandle(this._window);

  void close() {
    try {
      _window?.close();
    } catch (_) {}
  }

  void setLocation(String url) {
    try {
      _window?.location.href = url;
    } catch (_) {
      html.window.open(url, '_blank');
    }
  }
}

WebPopupHandle? openPopup(
  String url, {
  String name = 'auren_meta_oauth',
  String features = 'width=650,height=820,left=250,top=80,resizable=yes,scrollbars=yes',
}) {
  try {
    final win = html.window.open(url, name, features);
    return WebPopupHandle(win);
  } catch (e) {
    debugPrint('openPopup error: $e');
    return null;
  }
}

StreamSubscription<dynamic>? listenWindowMessage(void Function(dynamic data) onMessage) {
  try {
    return html.window.onMessage.listen((event) {
      onMessage(event.data);
    });
  } catch (e) {
    debugPrint('listenWindowMessage error: $e');
    return null;
  }
}

bool handleOAuthPopupClose({String message = 'AUREN_INSTAGRAM_CONNECTED'}) {
  try {
    final opener = html.window.opener;
    if (opener != null && !opener.closed!) {
      opener.postMessage(message, '*');
      html.window.close();
      return true;
    }
  } catch (e) {
    debugPrint('handleOAuthPopupClose error: $e');
  }
  return false;
}

void pickMediaFile({
  String? type,
  required void Function(String fileBase64, String fileName, String mimeType) onLoaded,
}) {
  final uploadInput = html.FileUploadInputElement();
  if (type == 'audio') {
    uploadInput.accept = 'audio/*';
  } else if (type == 'image') {
    uploadInput.accept = 'image/*';
  } else if (type == 'video') {
    uploadInput.accept = 'video/*';
  } else if (type == 'file') {
    uploadInput.accept = '.pdf,.doc,.docx,.xls,.xlsx,.txt';
  } else {
    uploadInput.accept = 'image/*,video/*,audio/*,.pdf,.doc,.docx';
  }
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((e) {
        final result = reader.result as String?;
        if (result != null && result.isNotEmpty) {
          final mime = file.type.isNotEmpty ? file.type : 'application/octet-stream';
          onLoaded(result, file.name, mime);
        }
      });
    }
  });
}

class PlatformAudioPlayer {
  html.AudioElement? _audio;

  void play(String url, {required VoidCallback onEnded, required VoidCallback onError}) {
    _audio?.pause();
    _audio = html.AudioElement(url);
    _audio?.onEnded.listen((_) => onEnded());
    _audio?.onError.listen((_) => onError());
    _audio?.play();
  }

  void pause() {
    _audio?.pause();
  }

  void dispose() {
    _audio?.pause();
    _audio = null;
  }
}

PlatformAudioPlayer createAudioPlayer() => PlatformAudioPlayer();
