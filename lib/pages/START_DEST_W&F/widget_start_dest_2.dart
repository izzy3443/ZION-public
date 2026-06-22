import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/models/predection_model.dart';

import 'package:zion3/pages/START_DEST_W&F/util_start_dest.dart';
import 'package:zion3/pages/START_DEST_W&F/provider_start_dest.dart';

import 'package:zion3/theme.dart';

class StartDestSuggestionsList extends ConsumerWidget {
  final String placeholder;
  final Function(PredectionModel) onSelectPlace;
  final VoidCallback onIdleSelect;
  final bool isPickupActive;

  const StartDestSuggestionsList({
    super.key,
    required this.placeholder,
    required this.onSelectPlace,
    required this.onIdleSelect,
    required this.isPickupActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeSuggestions = ref.watch(placeSuggestionsProvider);
    final loading = ref.watch(isStartDestLoading);

    if (loading) {
      return Center(child: LoadingCircle(true, context));
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: placeSuggestions.isEmpty ? 2 : placeSuggestions.length + 1,
      itemBuilder: (context, index) {
        if (placeSuggestions.isEmpty) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Start typing to search for\nyour $placeholder\n',
                      style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: 24.sp,
                        letterSpacing: -1.5,
                        fontWeight: FontWeight.w500,
                        color: Themes.fire_red,
                      ),
                    ),
                    TextSpan(
                      text: 'Enter More Then 3 Letters',
                      style: TextStyle(
                        fontFamily: 'outfit',
                        fontSize: 24.sp,
                        letterSpacing: -1.5,
                        fontWeight: FontWeight.w500,
                        color: Themes.black0(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return idle_list_items(onSelected: onIdleSelect);
        }

        if (index == placeSuggestions.length) {
          return idle_list_items(onSelected: onIdleSelect);
        }

        final place = placeSuggestions[index];
        return StartDestListTile(
          predectionModeldata: place,
          onSelected: onSelectPlace,
          isPickUpActive: isPickupActive,
        );
      },
    );
  }
}
