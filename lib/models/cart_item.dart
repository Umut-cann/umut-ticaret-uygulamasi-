
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  // Seçilen varyasyonlar (renk, beden vb.) eklenebilir
  // final String? selectedColor;
  // final String? selectedSize;

  CartItem({
    required this.product,
    this.quantity = 1,
    // this.selectedColor,
    // this.selectedSize,
  });

  double get totalPrice => product.price * quantity;
}
