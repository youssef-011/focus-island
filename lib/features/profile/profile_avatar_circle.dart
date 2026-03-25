import 'package:flutter/material.dart';

import 'profile_avatar_options.dart';

class ProfileAvatarCircle extends StatelessWidget {
  final String avatarId;
  final double radius;

  const ProfileAvatarCircle({
    super.key,
    required this.avatarId,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final option = ProfileAvatarOptions.byId(avatarId);

    return CircleAvatar(
      radius: radius,
      backgroundColor: option.backgroundColor,
      child: Icon(
        option.icon,
        color: option.iconColor,
        size: radius,
      ),
    );
  }
}
