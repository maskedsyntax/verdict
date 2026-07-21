import 'package:flutter/material.dart';
import 'package:verdict/app/verdict_theme.dart';

class BrutalBox extends StatelessWidget {
  const BrutalBox({
    required this.child,
    super.key,
    this.color = VerdictPalette.white,
    this.padding = const EdgeInsets.all(16),
    this.shadowOffset = 5,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double shadowOffset;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: VerdictPalette.ink, width: 3),
      boxShadow: [
        BoxShadow(
          color: VerdictPalette.ink,
          offset: Offset(shadowOffset, shadowOffset),
        ),
      ],
    ),
    child: child,
  );
}

class BrutalButton extends StatelessWidget {
  const BrutalButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.color = VerdictPalette.pink,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: VerdictPalette.ink, width: 3),
            boxShadow: const [
              BoxShadow(color: VerdictPalette.ink, offset: Offset(4, 4)),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(label, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class BrutalIconButton extends StatelessWidget {
  const BrutalIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
    this.color = VerdictPalette.white,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      label: tooltip,
      button: true,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: VerdictPalette.ink, width: 3),
            boxShadow: const [
              BoxShadow(color: VerdictPalette.ink, offset: Offset(3, 3)),
            ],
          ),
          child: Icon(icon, size: 21),
        ),
      ),
    ),
  );
}
