import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class VndRow extends MultiChildRenderObjectWidget {
  VndRow({super.children, super.key});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _VndRowRenderObject();
}

class _VndRowParentData extends ContainerBoxParentData<RenderBox> {}

class _VndRowRenderObject extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _VndRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _VndRowParentData> {
  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToFirstActualBaseline(baseline);

  @override
  double computeMaxIntrinsicHeight(double width) =>
      firstChild?.getMaxIntrinsicHeight(width) ??
      super.computeMaxIntrinsicHeight(width);

  @override
  double computeMaxIntrinsicWidth(double height) {
    RenderBox? child = firstChild;
    var width = .0;
    while (child != null) {
      final childParentData = child.parentData! as _VndRowParentData;
      width += child.getMaxIntrinsicWidth(height);
      child = childParentData.nextSibling;
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      firstChild?.getMinIntrinsicHeight(width) ??
      super.computeMinIntrinsicHeight(width);

  @override
  double computeMinIntrinsicWidth(double height) =>
      firstChild?.getMinIntrinsicWidth(height) ??
      super.computeMinIntrinsicWidth(height);

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      _performLayout(firstChild, constraints, _performLayoutDry);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  void performLayout() =>
      size = _performLayout(firstChild, constraints, _performLayoutLayouter);

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _VndRowParentData) {
      child.parentData = _VndRowParentData();
    }
  }

  static Size _performLayout(
    RenderBox? firstChild,
    BoxConstraints constraints,
    Size Function(RenderBox renderBox, BoxConstraints constraints) layouter,
  ) {
    final childrenData = <_VndRowParentData>[];
    final childrenSizes = <Size>[];

    RenderBox? child = firstChild;
    var childConstraints = const BoxConstraints();
    double? height;
    var totalWidth = .0;
    while (child != null) {
      final childData = child.parentData! as _VndRowParentData;
      final childSize = layouter(child, childConstraints);
      childrenData.add(childData);
      childrenSizes.add(childSize);
      totalWidth += childSize.width;

      if (height == null) {
        // take the first child's height as our height
        // then enforce it to all other children
        height = childSize.height;
        childConstraints = childConstraints.tighten(height: height);
      }

      child = childData.nextSibling;
    }

    if (height == null) {
      // no children?!
      return constraints.smallest;
    }

    final size = constraints.constrain(Size(totalWidth, height));
    var x = size.width;
    if (totalWidth < size.width) {
      x -= (size.width - totalWidth) / 2;
    }

    for (var i = childrenData.length - 1; i >= 0; i--) {
      final childData = childrenData[i];
      final childSize = childrenSizes[i];
      final childX = x - childSize.width;
      final childY = (size.height - childSize.height) / 2;
      childData.offset = Offset(childX, childY);
      x = childX;
    }

    return size;
  }

  static Size _performLayoutDry(
    RenderBox renderBox,
    BoxConstraints constraints,
  ) =>
      renderBox.getDryLayout(constraints);

  static Size _performLayoutLayouter(
    RenderBox renderBox,
    BoxConstraints constraints,
  ) {
    renderBox.layout(constraints, parentUsesSize: true);
    return renderBox.size;
  }
}
