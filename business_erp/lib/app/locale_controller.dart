import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

final class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => const Locale('mr');

  void toggle() {
    state = Locale(state.languageCode == 'mr' ? 'en' : 'mr');
  }
}
