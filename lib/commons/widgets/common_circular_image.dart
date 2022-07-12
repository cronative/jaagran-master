import 'package:flutter/material.dart';

class CommonCircularAvatar extends StatelessWidget {
  final double size;
  final String url;

  const CommonCircularAvatar({Key key, this.size, this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size,
      backgroundColor: Colors.transparent,
      child: CircleAvatar(
        radius: size,
        backgroundImage: NetworkImage(
          url,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundImage: AssetImage("assets/images/dp_circular_avatar.png"),
    );
  }
}
