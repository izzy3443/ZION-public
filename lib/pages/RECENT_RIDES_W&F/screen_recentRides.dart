import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zion3/UI/Activity_card.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/RECENT_RIDES_W&F/screen_tripDetails.dart';
import 'package:zion3/theme.dart';

class DriverTripsHistoryPage extends ConsumerStatefulWidget {
  const DriverTripsHistoryPage({super.key});

  @override
  ConsumerState<DriverTripsHistoryPage> createState() =>
      _DriverTripsHistoryPageState();
}

class _DriverTripsHistoryPageState
    extends ConsumerState<DriverTripsHistoryPage> {
  final tripsProvider = StateProvider.autoDispose<
      List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
    (ref) => [],
  );

  final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => true);

  final totalDistanceProvider = StateProvider.autoDispose<double>((ref) => 0.0);

  final totalRidesProvider = StateProvider.autoDispose<int>((ref) => 0);
  String filter = "Today";
  final filters = ["Today", "This Week", "This Month"];

  @override
  void initState() {
    super.initState();
    _fetchTrips(); // Initial fetch
  }

  Future<void> _fetchTrips() async {
    ref.read(isLoadingProvider.notifier).state = true;

    final user = FirebaseAuth.instance.currentUser; //
    if (user == null) {
      debugPrint("User is not logged in.");
      ref.read(tripsProvider.notifier).state = [];
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }

    final uid = user.uid;
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (filter) {
      case "Today":
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        break;
      case "This Week":
        start = now.subtract(Duration(days: now.weekday - 1)); // Monday
        start = DateTime(start.year, start.month, start.day);
        end = start
            .add(const Duration(days: 7))
            .subtract(const Duration(milliseconds: 1));
        break;
      case "This Month":
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(milliseconds: 1));
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    }

    final snapshot = await FirebaseFirestore.instance
        .collection("trip_req")
        .where("UserId", isEqualTo: uid)
        .where("StartTime", isGreaterThanOrEqualTo: start)
        .where("StartTime", isLessThanOrEqualTo: end)
        .orderBy("StartTime", descending: true)
        .get();
    final docs = snapshot.docs;
    ref.read(tripsProvider.notifier).state = docs;
    ref.read(totalDistanceProvider.notifier).state = docs.fold(
      0.0,
      (sum, doc) {
        final distanceValue =
            doc.data().containsKey('Distance') ? doc['Distance'] : null;
        final distance = distanceValue is num
            ? distanceValue.toDouble()
            : double.tryParse(distanceValue?.toString() ?? '0') ?? 0.0;
        return sum + distance;
      },
    );
    ref.read(totalRidesProvider.notifier).state = docs.length;
    ref.read(isLoadingProvider.notifier).state = false;
    ref.read(tripsProvider.notifier).state = snapshot.docs;
    ref.read(isLoadingProvider.notifier).state = false;
  }

  @override
  Widget build(BuildContext context) {
    final trips = ref.watch(tripsProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final distance = ref.watch(totalDistanceProvider);
    final rides = ref.watch(totalRidesProvider);
    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
              child: Row(
                children: [
                  Expanded(
                    child: buildActivityCard(
                      title: 'Travelled',
                      value: "₹${distance.toStringAsFixed(2)}",
                      subtitle: filter,
                      icon: Icons.account_balance_wallet_outlined,
                      color: Themes.black4(context),
                      textColor: Themes.white0(context),
                      context: context,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: buildActivityCard(
                      title: 'Total Rides',
                      value: "$rides",
                      subtitle: filter,
                      icon: Icons.check_circle_outline,
                      color: Themes.cream1(context),
                      textColor: Themes.black0(context),
                      context: context,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0.w),
              child: _buildToggleButtons(),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: isLoading
                  ? Center(child: LoadingCircle(false, context))
                  : trips.isEmpty
                      ? const Center(child: Text("No trips found."))
                      : ListView.builder(
                          itemCount: trips.length,
                          itemBuilder: (context, index) {
                            final trip = trips[index].data();
                            return reusableListItem(
                              icon: Icons.location_on_outlined,
                              title: trip['dropoff_address'] ??
                                  'Unknown Drop Location',
                              subtitle: _formatTimeRange(trip),
                              iconColor: Themes.fire_red,
                              trailing: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "₹${double.tryParse(trip['FareAmount'].toString())?.toStringAsFixed(2) ?? '0.00'}",
                                  style: Themes.buttonText(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Themes.black0(context)),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TripDetailsScreen(ride: trip),
                                  ),
                                );
                              },
                              context: context,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(Map<String, dynamic> trip) {
    final start = (trip["StartTime"] as Timestamp).toDate();
    return DateFormat('MMM d').format(start);
  }

  Widget _buildToggleButtons() {
    return buildModernToggleButtons(
      options: filters,
      selectedOption: filter,
      onChanged: (selected) {
        setState(() {
          filter = selected;
          _fetchTrips();
        });
      },
      primaryColor: Themes.fire_red, // Your theme color
      backgroundColor:
          Themes.white1(context), // Light background or adjust as needed
    );
  }

  Widget buildModernToggleButtons({
    required List<String> options,
    required String selectedOption,
    required void Function(String) onChanged,
    Color? primaryColor,
    Color? backgroundColor,
  }) {
    return Builder(
      builder: (context) {
        const primary = Themes.fire_red;
        final bgColor = backgroundColor;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: boxShadow(context)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              final isSelected = option == selectedOption;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Themes.white0(context)
                            : Themes.gray3(context),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
