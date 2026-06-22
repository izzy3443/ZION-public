import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/models/predection_model.dart';

final isStartDestLoading = StateProvider.autoDispose<bool>((ref) => false);

final placeSuggestionsProvider =
    StateProvider.autoDispose<List<PredectionModel>>(
  (ref) => [],
);
