import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TripDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> ride;

  const TripDetailsScreen({super.key, required this.ride});

  @override
  ConsumerState<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends ConsumerState<TripDetailsScreen> {
  final StateProvider<bool> isLoadingProvider =
      StateProvider<bool>((ref) => true);

  Map<String, dynamic> combinedData = {};

  @override
  void initState() {
    super.initState();
    _fetchDriverInfoAndMerge();
  }

  Future<void> _fetchDriverInfoAndMerge() async {
    try {
      final driverId = widget.ride['DriverId'];
      if (driverId == null) throw 'DriverId is missing in ride data';

      final driverSnap = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();

      final driverData = driverSnap.data();
      if (driverData == null) throw 'Driver not found in Firestore';

      // Merge ride + driver
      combinedData = {
        ...widget.ride,
        'DriverName': "${driverData['firstName']} ${driverData['lastName']}",
        'VehicleType': driverData['VehicleType'] ?? '',
        'DriverPhoto': driverData['ProfilePic'] ?? '',
      };
    } catch (e) {
      combinedData = Map<String, dynamic>.from(widget.ride);
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  String getTripDurationFormatted(Map<String, dynamic> ride) {
    final start = ride['StartTime'];
    final end = ride['EndTime'];

    if (start is! Timestamp) return 'Invalid start time';
    if (end is! Timestamp) return 'end time not available';

    final startTime = start.toDate();
    final endTime = end.toDate();

    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr${minutes > 0 ? ' $minutes min' : ''}';
    }
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isLoadingProvider);
    final DateTime startDateTime =
        DateTime.tryParse(widget.ride['DateTime']?.toString() ?? '') ??
            DateTime.now();
    final DateTime endTime = startDateTime.add(const Duration(minutes: 25));

    return Scaffold(
        backgroundColor: Themes.white0(context),
        appBar: _buildAppBar(context),
        body: isLoading
            ? Center(child: LoadingCircle(true, context))
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _driverWelcomeContainer(),
                      SizedBox(height: 16.h),
                      _buildLocationContainer(),
                      SizedBox(height: 16.h),
                      _buildTripTimeCard(startDateTime, endTime),
                      SizedBox(height: 16.h),
                      _buildPaymentAndAmountRow(),
                      SizedBox(height: 16.h),
                      _buildVehicleAndStatsRow(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ));
  }

  Widget _buildLocationContainer() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: _createGradientBox(
        colors: [Themes.black3(context), Themes.black2(context)],
      ),
      child: Column(
        children: [
          _buildLocationRow(
            icon: Icons.location_on_outlined,
            title: 'Pickup Location',
            address:
                combinedData['pickup_address'] ?? 'Unknown pickup location',
            color: Themes.tree_green,
          ),
          SizedBox(height: 20.h),
          const Divider(),
          SizedBox(height: 20.h),
          _buildLocationRow(
            icon: Icons.location_on_outlined,
            title: 'Drop Location',
            address:
                combinedData['dropoff_address'] ?? 'Unknown dropoff location',
            color: Themes.fire_red,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required String title,
    required String address,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'outfit',
                  color: Themes.white0(context).withValues(alpha: 0.7),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                address,
                style: TextStyle(
                  fontFamily: 'outfit',
                  color: Themes.white0(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _driverWelcomeContainer() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: boxShadow(context),
      ),
      child: Row(
        children: [
          _buildDriverAvatar(),
          SizedBox(width: 16.w),
          _buildDriverInfo(),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildDriverAvatar() {
    final imageUrl = combinedData['DriverPhoto'];

    final bool hasValidImage =
        imageUrl != null && imageUrl is String && imageUrl.trim().isNotEmpty;

    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Themes.gray3(context).withValues(alpha: 0.2), width: 2.w),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: hasValidImage
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person, size: 32);
                },
              )
            : const Icon(Icons.person, size: 32),
      ),
    );
  }

  Widget _buildDriverInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Driver',
            style: TextStyle(
              fontSize: 14.sp,
              color: Themes.gray3(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            combinedData['DriverName'] ?? 'Unknown Driver',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Themes.black0(context), size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_horiz, color: Themes.black0(context), size: 22),
          onPressed: () {},
        ),
      ],
    );
  }

  BoxDecoration _createGradientBox({required List<Color> colors}) {
    return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: boxShadow(context));
  }

  Widget _buildTripTimeCard(DateTime startDateTime, DateTime endTime) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Themes.fire_red.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTripDurationHeader(),
          SizedBox(height: 20.h),
          _buildStartEndTimeRow(),
        ],
      ),
    );
  }

  Widget _buildTripDurationHeader() {
    final durationText =
        getTripDurationFormatted(combinedData); // calling the function

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trip Duration',
          style: TextStyle(
            fontFamily: 'outfit',
            color: Colors.black54,
            fontSize: 14.sp,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Themes.black0(context).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            durationText,
            style: TextStyle(
              fontFamily: 'outfit',
              color: Themes.black0(context),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartEndTimeRow() {
    final start = widget.ride['StartTime'];
    final end = widget.ride['EndTime'];

    final startTime = start is Timestamp ? start.toDate() : null;
    final endTime = end is Timestamp ? end.toDate() : null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Started', style: Themes.SmallContainerText(context)),
              SizedBox(height: 8.h),
              Text(
                startTime != null
                    ? DateFormat('h:mm a').format(startTime)
                    : 'N/A',
                style: Themes.headline3(context),
              ),
            ],
          ),
        ),
        Container(
          width: 1.w,
          height: 40.h,
          color: Themes.black0(context).withValues(alpha: 0.2),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ended', style: Themes.SmallContainerText(context)),
                SizedBox(height: 8.h),
                Text(
                  endTime != null
                      ? DateFormat('h:mm a').format(endTime)
                      : 'Not ended',
                  style: Themes.headline3(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentAndAmountRow() {
    final fareAmount = _parseFareAmount();

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.credit_card,
            label: 'Payment',
            value: combinedData['PaymentMethod'] ?? 'Cash',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.receipt_outlined,
            label: 'Amount',
            value: '₹$fareAmount',
          ),
        ),
      ],
    );
  }

  String _parseFareAmount() {
    try {
      final rawFare = combinedData['FareAmount'] ?? '0';
      final double fare = double.parse(rawFare.toString());
      return fare.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Widget _buildVehicleAndStatsRow() {
    final vehicleType = (combinedData['VehicleType'] ?? '').toString();

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon:
                vehicleType == 'Bike' ? Icons.motorcycle : Icons.directions_car,
            label: 'Vehicle',
            value: combinedData['VehicleType'] ?? 'Unknown',
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: combinedData['Rating'] ?? '4.8',
            subtitle: 'Excellent',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: boxShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Themes.selected_red,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Themes.fire_red, size: 20),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'outfit',
              color: Themes.gray3(context),
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'outfit',
              color: Themes.black0(context),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'outfit',
                color: Themes.gray3(context),
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
