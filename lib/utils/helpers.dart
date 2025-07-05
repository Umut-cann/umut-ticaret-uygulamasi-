
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount, {String locale = 'tr_TR', String symbol = '₺'}) {
    // Negatif olmayan değerler için formatlama
    final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 2);
    return format.format(amount.abs()); // Mutlak değeri al
  }

  static String formatDate(DateTime date, {String format = 'dd MMMM yyyy, HH:mm', String locale = 'tr_TR'}) { // Daha okunaklı format
     final formatter = DateFormat(format, locale);
     return formatter.format(date);
  }

   static Color colorFromHex(String hexColor) {
     hexColor = hexColor.toUpperCase().replaceAll("#", "");
     if (hexColor.length == 6) {
       hexColor = "FF$hexColor";
     }
     if (hexColor.length == 8) {
       try {
          return Color(int.parse(hexColor, radix: 16));
       } catch(e){
          print("Error parsing hex color: $hexColor, Error: $e");
          return Colors.grey; // Hata durumunda
       }
     }
     print("Invalid hex color format: $hexColor");
     return Colors.grey; // Geçersiz format
   }
}

