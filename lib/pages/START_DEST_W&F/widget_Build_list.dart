import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zion3/global/paths.dart';
import 'package:zion3/models/predection_model.dart';
import 'package:zion3/theme.dart';

class StartDestListTile extends StatelessWidget {
  final PredectionModel predectionModeldata;
  final Function(PredectionModel) onSelected;
  final bool isPickUpActive;
  const StartDestListTile({
    super.key,
    required this.predectionModeldata,
    required this.onSelected,
    required this.isPickUpActive,
  });
  _handleTap() {
    onSelected(predectionModeldata);
  }

  @override
  Widget build(BuildContext context) {
    {
      return GestureDetector(
        onTap: _handleTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0.h),
          decoration: BoxDecoration(
            color: Themes.white0(context),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: SvgPicture.asset(
                  isPickUpActive ? green_map_marker : red_map_marker,
                  height: 40.h,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      predectionModeldata.main_text ?? '',
                      style: Themes.subtitle(context).copyWith(
                          color: Themes.black0(context),
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          height: 1.3),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      predectionModeldata.sec_text ?? '',
                      style: Themes.bodyText1(context).copyWith(
                        color: Themes.gray44(context),
                        fontSize: 14.sp,
                        height: 1.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
