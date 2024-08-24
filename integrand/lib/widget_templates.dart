import "package:flutter/material.dart";
import 'package:integrand/consts.dart';

class ExpandableListItem extends StatefulWidget {
  const ExpandableListItem(
    {
      super.key,
      this.child,
      this.expandedChild,
      required this.unexpandedHeight,
      required this.expandedHeight,
      this.durationMs = 100,
      this.curve = Curves.easeOut, 
      this.spacing = 10,
      this.borderWidth = 1,
      this.borderRadius = 5,
      this.highlighted = false,
    }
  );

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
          color: widget.highlighted ? null : primaryColor,
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
                  height: widget.unexpandedHeight - 2, // Border radius of 5 causes 2 pixels to be hidden?
                  decoration: BoxDecoration(
                    borderRadius: _expanded ? BorderRadius.only(
                      topLeft: Radius.circular(widget.borderRadius),
                      topRight: Radius.circular(widget.borderRadius),
                    ) : BorderRadius.circular(widget.borderRadius),
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
                      color: highlightColor,
                    ),
                    child: widget.expandedChild,
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
