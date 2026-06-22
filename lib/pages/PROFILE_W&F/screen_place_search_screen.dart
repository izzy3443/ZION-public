import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/TextField.dart';
import 'package:zion3/UI/snackBar.dart';

import 'package:zion3/models/address_model.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/models/predection_model.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/HOMEPAGE_W&F/controller_homePage.dart';
import 'package:zion3/pages/PROFILE_W&F/controller_place_search_screen.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/PROFILE_W&F/screen_custom_place_save.dart';
import 'package:zion3/pages/START_DEST_W&F/controller_start_dest.dart';
import 'package:zion3/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define providers
final PlaceSuggestionsProvider =
    StateProvider.autoDispose<List<PredectionModel>>(
  (ref) => [],
);

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class PlaceSearchScreen extends ConsumerStatefulWidget {
  final String? PlaceName; // HOME or Work etc
  final bool CustomPlaceName;

  const PlaceSearchScreen({
    super.key,
    this.PlaceName,
    required this.CustomPlaceName,
  });

  @override
  ConsumerState<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends ConsumerState<PlaceSearchScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ref.invalidate(isLoadingProvider);
    searchController.dispose();
    super.dispose();
  }

  Future<void> selectPlace(PredectionModel model) async {
    ref.read(isLoadingProvider.notifier).state = true;

    searchController.text = model.main_text!;
    FocusScope.of(context).unfocus();

    try {
      final placeModel = await fetchPlaceIdDetails(
        model.place_id!,
        model.sec_text!,
      );

      if (!mounted) return;

      ref.read(isLoadingProvider.notifier).state = false;

      if (widget.CustomPlaceName) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddPlaceDetailsScreen(
              model: placeModel,
            ),
          ),
        );
      } else {
        await saveAddressSavedPlaces(
          ref,
          widget.PlaceName!,
          placeModel,
        );

        if (!mounted) return;
        Navigator.pop(context);
      }

      ref.read(PlaceSuggestionsProvider.notifier).update((_) => []);
    } catch (e) {
      if (!mounted) return;

      ref.read(isLoadingProvider.notifier).state = false;
      showCustomSnackBar(context, "Unexpected error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(PlaceSuggestionsProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Scaffold(
      backgroundColor: Themes.white0(context),
      appBar: AppBar(
        backgroundColor: Themes.white0(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Themes.black0(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add ${widget.PlaceName ?? 'Place'}',
          style: Themes.headline2(context).copyWith(
            fontSize: 24.sp,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0.r),
            child: textField(searchController, context, 'Search for a place',
                onChanged: TextFieldValueChange, icon: Icons.search),
          ),
          // Show suggestions or recent places based on search state

          isLoading
              ? LoadingCircle(true, context)
              : Expanded(
                  child: suggestions.isEmpty
                      ? SingleChildScrollView(
                          child: _buildRecentPlaces(
                              ref.watch(UserProvider)!.recentPlaces))
                      : _buildSearchSuggestions(suggestions),
                ),
        ],
      ),
    );
  }

  TextFieldValueChange(value) {
    // Debounce to avoid too many API calls

    try {
      fetchPlaceSuggestions(value, ref, context, PlaceSuggestionsProvider);
    } catch (e) {
      showCustomSnackBar(context, e.toString());
    }
  }

  Widget _buildRecentPlaces(List<AddressModel> recentPlaces) {
    return buildRecentList(recentPlaces, context, onTap: function);
  }

  function(AddressModel SuggestionPlace) {
    PredectionModel model = PredectionModel.fromMap(SuggestionPlace.toMap());

    selectPlace(
      model,
    );
  }

  Widget _buildSearchSuggestions(List<PredectionModel> suggestions) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(12.r),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _buildModernSearchResult(
          suggestion.main_text ?? 'Unknown',
          suggestion.sec_text ?? 'No address',
          Themes.fire_red,
          isFavorite: false,
          onTap: () => selectPlace(
            suggestion,
          ),
        );
      },
    );
  }

  Widget _buildModernSearchResult(
    String name,
    String address,
    Color color, {
    bool isFavorite = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Themes.white0(context),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: boxShadow(context),
          ),
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    isFavorite ? Icons.star : Icons.location_on,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Themes.black0(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        address,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Themes.gray3(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
