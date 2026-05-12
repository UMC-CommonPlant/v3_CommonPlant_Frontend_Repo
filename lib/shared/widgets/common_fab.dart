import 'package:commonplant_frontend/core/theme/app_radius.dart';
import 'package:commonplant_frontend/core/theme/app_sizes.dart';
import 'package:commonplant_frontend/core/theme/app_spacing.dart';
import 'package:commonplant_frontend/core/theme/app_text_styles.dart';
import 'package:commonplant_frontend/core/theme/app_theme_tokens.dart';
import 'package:flutter/material.dart';

const commonFabBarrierColor = Color(0x99000000);

class CommonFab extends StatelessWidget {
  const CommonFab({
    super.key,
    required this.child,
    this.onPressed,
    this.size = AppSizes.fabSize,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return SizedBox(
      width: size,
      height: size,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor ?? tokens.brandPrimary,
        foregroundColor: foregroundColor ?? tokens.onBrand,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: child,
      ),
    );
  }
}

class CommonFabDialAction {
  const CommonFabDialAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;
}

class CommonFabDial extends StatefulWidget {
  const CommonFabDial({super.key, required this.child, required this.actions});

  final Widget child;
  final List<CommonFabDialAction> actions;

  @override
  State<CommonFabDial> createState() => _CommonFabDialState();
}

class _CommonFabDialState extends State<CommonFabDial> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showOverlay() {
    if (_overlayEntry != null) {
      return;
    }

    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {});
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CommonFab(onPressed: _showOverlay, child: widget.child),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final tokens =
        Theme.of(context).extension<AppThemeTokens>() ?? AppThemeTokens.light;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hideOverlay,
            child: const ColoredBox(color: commonFabBarrierColor),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.bottomRight,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ...widget.actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.x12),
                    child: Semantics(
                      button: true,
                      label: action.label,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _invokeAction(action),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              action.label,
                              style: AppTextStyles.size16Bold.copyWith(
                                color: tokens.onBrand,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x12),
                            CommonFab(
                              size: AppSizes.miniFabSize,
                              backgroundColor: tokens.surfaceBase,
                              foregroundColor: tokens.textHeadline,
                              onPressed: () => _invokeAction(action),
                              child: action.icon,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                CommonFab(onPressed: _hideOverlay, child: widget.child),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _invokeAction(CommonFabDialAction action) {
    _hideOverlay();
    action.onPressed();
  }
}
