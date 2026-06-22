import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/theme.dart';

Widget reusableListItem({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  required BuildContext context,
  VoidCallback? onTap,
  Widget? trailing,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
              _buildIcon(icon, iconColor),
              SizedBox(width: 14.w),
              _buildText(title, subtitle, context),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildIcon(IconData icon, Color color) {
  return Container(
    width: 44.w,
    height: 44.h,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Icon(
      icon,
      color: color,
      size: 24,
    ),
  );
}

Widget _buildText(String title, String subtitle, BuildContext context) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Themes.MidContainerText(context),
          overflow: TextOverflow.ellipsis, // ✅ Prevents title overflow
          maxLines: 1,
        ),
        SizedBox(height: 3.h),
        Text(
          subtitle,
          style: Themes.SmallContainerText(context),
          overflow: TextOverflow.ellipsis, // ✅ Prevents subtitle overflow
          maxLines: 1, // ✅ Ensures only one line is shown
        ),
      ],
    ),
  );
}

List<BoxShadow> boxShadow(BuildContext context) {
  return [
    BoxShadow(
      color: Themes.black0(context).withValues(alpha: 0.07),
      spreadRadius: 1,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
}
