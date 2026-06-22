import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion3/UI/Loading_UI.dart';

import 'package:zion3/pages/START_DEST_W&F/controller_start_dest.dart';

class SuggestionsLoadingBar extends ConsumerWidget {
  const SuggestionsLoadingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(isSuggestionsLoading);
    if (!loading) return const SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: LoadingLine(true, context),
    );
  }
}
