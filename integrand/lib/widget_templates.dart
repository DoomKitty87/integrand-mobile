import "package:flutter/material.dart";
import 'package:integrand/consts.dart';

class ExpandableListItem extends StatefulWidget {
  const ExpandableListItem({
    super.key,
    this.child,
    this.expandedChild,
    required this.unexpandedHeight,
    required this.expandedHeight,
    this.durationMs = 200,
    this.curve = Curves.easeInOut,
    this.spacing = 10,
    this.borderWidth = 1,
    this.borderRadius = 5,
    this.highlighted = false,
  });

  final Widget? child;
  final Widget? expandedChild;
  final double unexpandedHeight;
  final double expandedHeight;
  final double durationMs;
  final Curve curve;
  final double spacing;
  final double borderWidth;
  final double borderRadius;
  final bool highlighted;

  @override
  State<ExpandableListItem> createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem> {
  bool _expanded = false;

  void _onTap() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
          margin: EdgeInsets.only(bottom: widget.spacing),
          height: _expanded ? widget.expandedHeight : widget.unexpandedHeight,
          duration: Duration(milliseconds: widget.durationMs.toInt()),
          curve: widget.curve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: widget.highlighted ? textGradient : null,
            color: highlightColor,
          ),
          padding: EdgeInsets.all(widget.borderWidth),
          child: Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              color: primaryColor,
            ),
            child: ClipRRect(
              child: Stack(
                children: [
                  Container(
                    height: widget.unexpandedHeight -
                        2, // Border radius of 5 causes 2 pixels to be hidden?
                    decoration: BoxDecoration(
                      borderRadius: _expanded
                          ? BorderRadius.only(
                              topLeft: Radius.circular(widget.borderRadius),
                              topRight: Radius.circular(widget.borderRadius),
                            )
                          : BorderRadius.circular(widget.borderRadius),
                      border: Border(
                        bottom: BorderSide(
                          color: highlightColor,
                          width: widget.borderWidth,
                        ),
                      ),
                      color: primaryColor,
                    ),
                    child: widget.child,
                  ),
                  Positioned(
                    top: widget.unexpandedHeight,
                    child: Container(
                      height: widget.expandedHeight - widget.unexpandedHeight,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(widget.borderRadius),
                          bottomRight: Radius.circular(widget.borderRadius),
                        ),
                      ),
                      child: widget.expandedChild,
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class IconButtonTemplate extends StatelessWidget {
  const IconButtonTemplate(
      {super.key,
      required this.icon,
      required this.size,
      required this.padding,
      this.onPressed});

  final IconData icon;
  final double size;
  final VoidCallback? onPressed;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size + padding * 2,
        width: size + padding * 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: highlightColor, width: 1),
        ),
        child: Center(
          child: Icon(icon, size: size, color: textColor),
        ),
      ),
    );
  }
}
