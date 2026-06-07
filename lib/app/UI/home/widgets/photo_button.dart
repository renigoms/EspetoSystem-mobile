import 'package:espetosystem/app/UI/home/components/modal_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PhotoButton extends StatelessWidget {
  const PhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => openPhotoOptions(context),
      child: SizedBox(
        width: 31,
        height: 31,
        child: SvgPicture.asset(
          'assets/icons/camera.svg',
          width: 31,
          height: 31,
        ),
      ),
    );
  }
}
