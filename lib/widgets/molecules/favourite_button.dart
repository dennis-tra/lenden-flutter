import 'package:flutter/material.dart';

class FavouriteButton extends StatefulWidget {
  @override
  _FavouriteButtonState createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton>
    with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  double _duration = 1.0;
  double _circleTransformDuration = 0.333;
  Animation _circleAnimation;
  Animation _imageAnimation;
  Image _image = Image.asset("assets/clinking-beer-mugs.png");

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.forward();

    _circleAnimation = _createTweenSequence([
      _TweenSeqItem(0.0, 0.5, 10.0),
      _TweenSeqItem(0.5, 1.0, 10.0),
      _TweenSeqItem(1.0, 1.2, 10.0),
      _TweenSeqItem(1.2, 1.3, 10.0),
      _TweenSeqItem(1.3, 1.37, 10.0),
      _TweenSeqItem(1.37, 1.4, 10.0),
      _TweenSeqItem(1.4, 1.4, 40.0),
    ]).animate(_controller);

    _imageAnimation = _createTweenSequence([
      _TweenSeqItem(0.0, 0.0, 10.00),
      _TweenSeqItem(0.0, 1.2, 20.00),
      _TweenSeqItem(1.2, 1.25, 3.333),
      _TweenSeqItem(1.25, 1.2, 3.333),
      _TweenSeqItem(1.2, 0.9, 10.00),
      _TweenSeqItem(0.9, 0.875, 3.333),
      _TweenSeqItem(0.875, 0.875, 3.333),
      _TweenSeqItem(0.875, 0.9, 3.333),
      _TweenSeqItem(0.9, 1.013, 10.00),
      _TweenSeqItem(1.013, 1.025, 3.333),
      _TweenSeqItem(1.025, 1.013, 3.333),
      _TweenSeqItem(1.013, 0.96, 10.00),
      _TweenSeqItem(0.96, 0.95, 3.333),
      _TweenSeqItem(0.95, 0.96, 3.333),
      _TweenSeqItem(0.96, 0.99, 6.666),
      _TweenSeqItem(0.99, 1.0, 3.333),
    ]).animate(_controller);
  }

  TweenSequence<double> _createTweenSequence(List<_TweenSeqItem> items) {
    final sequence = items.map(
      (item) => TweenSequenceItem(
            tween: Tween(begin: item.begin, end: item.end),
            weight: item.weight,
          ),
    );

    return TweenSequence(sequence.toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decOpacity() {
    setState(() {
      _opacity = 0.4;
    });
  }

  void _resetOpacity() {
    setState(() {
      _opacity = 1.0;
    });
  }

  set duration(double duration) {
    _duration = duration;
    _controller.duration =
        Duration(milliseconds: (1000 * _circleTransformDuration).round());
    _circleTransformDuration = 0.333 * duration;
  }

  double get duration {
    return _duration;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Opacity(
          opacity: _opacity,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 160.0,
                height: 160.0,
              ),
              // ScaleTransition(
              //   scale: _circleAnimation,
              //   child: Container(
              //     width: 160.0,
              //     height: 160.0,
              //     decoration: BoxDecoration(
              //       color: Colors.blue,
              //       shape: BoxShape.circle,
              //     ),
              //   ),
              // ),
              ScaleTransition(
                scale: _imageAnimation,
                child: _image,
              ),
            ],
          ),
        ),
      ),
      onPanDown: (d) => _decOpacity(),
      onPanCancel: () => _resetOpacity(),
      onPanEnd: (d) => _resetOpacity(),
      onTapDown: (d) => _decOpacity(),
      onTapUp: (d) => _resetOpacity(),
      onTapCancel: () => _resetOpacity(),
      onTap: () {
        _controller.reset();
        _controller.forward();
      },
    );
  }
}

class _TweenSeqItem {
  final double begin;
  final double end;
  final double weight;
  _TweenSeqItem(this.begin, this.end, this.weight);
}
