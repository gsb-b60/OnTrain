import 'package:flutter/material.dart';
import 'package:ontrain/core/constrants/app_colors.dart';
import 'package:ontrain/data/object/pt.dart';

class FavoriteIconBtn extends StatefulWidget {
  const FavoriteIconBtn({
    super.key,
    required this.pt,
  });

  final PT pt;

  @override
  State<FavoriteIconBtn> createState() => _FavoriteIconBtnState();
}

class _FavoriteIconBtnState extends State<FavoriteIconBtn> {
  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      color: AppColors.aquaTeal,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.greyAqua,
      ),
      iconSize: 16,
      visualDensity: VisualDensity.compact,
      onPressed: () {
        setState(() {
          widget.pt.isFavorite = !(widget.pt.isFavorite ?? false);
        });
      },
      icon: Icon(widget.pt.isFavorite ? Icons.favorite : Icons.favorite_border),
    );
  }
}