import 'package:flutter/material.dart';

class TopMenuAvatarItem extends StatelessWidget {
  const TopMenuAvatarItem({
    super.key,
    this.imageUrl,
    this.isSelected = false,
    this.text,
    this.onPressed,
  });
  final bool isSelected;
  final String? imageUrl;
  final String? text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => onPressed?.call(),
        child: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
          child:
              (imageUrl == null && text != null)
                  ? Text(text!.substring(0, 1))
                  : null,
        ),
      ),
    );
  }
}
