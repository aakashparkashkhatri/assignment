import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatefulWidget {
  final NetworkImage image;
  final String initials;
  final Color circleBackground;
  final int msAnimationDuration;

  CustomCircleAvatar(
      {@required this.image,
      @required this.initials,
      @required this.circleBackground,
      this.msAnimationDuration});

  @override
  _CustomCircleAvatarState createState() => _CustomCircleAvatarState();
}

class _CustomCircleAvatarState extends State<CustomCircleAvatar> {
  bool _imgSuccess = false;

  @override
  initState() {
    super.initState();
    // Add listeners to this class
    ImageStreamListener listener =
        ImageStreamListener(_setImage, onError: _setError);

    widget.image.resolve(ImageConfiguration()).addListener(listener);
  }

  void _setImage(ImageInfo image, bool sync) {
    setState(() => _imgSuccess = true);
  }

  void _setError(dynamic dyn, StackTrace st) {
    setState(() => _imgSuccess = false);
    dispose();
  }

  Widget _CustomCircleAvatar() {
    return Container(
        decoration: BoxDecoration(color: widget.circleBackground),
        child: Center(child: Text(widget.initials)));
  }

  Widget _avatarImage() {
    return CircleAvatar(
        backgroundImage: widget.image,
        backgroundColor: widget.circleBackground);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: widget.msAnimationDuration ?? 500),
      child: _imgSuccess ? _avatarImage() : _CustomCircleAvatar(),
    );
  }
}
