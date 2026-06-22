import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageIndexProvider = StateNotifierProvider<PageIndexNotifier, int>((ref) {
  return PageIndexNotifier();
});

class PageIndexNotifier extends StateNotifier<int> {
  PageIndexNotifier() : super(0);

  void setPageIndex(int index) {
    state = index;
  }
}
