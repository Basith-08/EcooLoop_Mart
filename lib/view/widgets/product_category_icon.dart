import 'package:flutter/material.dart';

IconData resolveProductCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'ikon minyak':
      return Icons.water_drop;
    case 'ikon beras':
      return Icons.rice_bowl;
    case 'ikon gula':
      return Icons.grain;
    case 'ikon telur':
      return Icons.egg;
    case 'ikon mie':
      return Icons.ramen_dining;
    default:
      return Icons.shopping_bag;
  }
}

