/// Utility class for formatting prices in Indonesian Rupiah format
class PriceFormatter {
  /// Formats a price string or number to Indonesian Rupiah format
  /// Example: formatPrice("15000") returns "Rp 15.000"
  /// Example: formatPrice(15000.0) returns "Rp 15.000"
  static String formatPrice(dynamic price) {
    if (price == null) return 'Rp 0';
    
    String cleanPrice;
    
    // Handle different input types
    if (price is String) {
      // Remove any existing currency symbols and clean the string
      cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    } else if (price is num) {
      cleanPrice = price.toString();
    } else {
      return 'Rp 0';
    }
    
    try {
      // Parse the price as a double
      double priceValue = double.parse(cleanPrice);
      
      // Format with thousands separator
      String formattedPrice = priceValue.toStringAsFixed(0);
      
      // Add thousands separator (dots for Indonesian format)
      formattedPrice = formattedPrice.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]}.',
      );
      
      return 'Rp $formattedPrice';
    } catch (e) {
      // If parsing fails, return a safe default
      return 'Rp 0';
    }
  }
  
  /// Formats a price with decimal places if needed
  /// Example: formatPriceWithDecimals(15000.50) returns "Rp 15.000,50"
  static String formatPriceWithDecimals(dynamic price, {int decimals = 2}) {
    if (price == null) return 'Rp 0';
    
    String cleanPrice;
    
    // Handle different input types
    if (price is String) {
      cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    } else if (price is num) {
      cleanPrice = price.toString();
    } else {
      return 'Rp 0';
    }
    
    try {
      double priceValue = double.parse(cleanPrice);
      
      // Format with specified decimal places
      String formattedPrice = priceValue.toStringAsFixed(decimals);
      
      // Split integer and decimal parts
      List<String> parts = formattedPrice.split('.');
      String integerPart = parts[0];
      String decimalPart = parts.length > 1 ? parts[1] : '';
      
      // Add thousands separator to integer part
      integerPart = integerPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match match) => '${match[1]}.',
      );
      
      // Return formatted price with Indonesian decimal separator (comma)
      if (decimals > 0 && decimalPart.isNotEmpty && decimalPart != '00') {
        return 'Rp $integerPart,$decimalPart';
      } else {
        return 'Rp $integerPart';
      }
    } catch (e) {
      return 'Rp 0';
    }
  }
  
  /// Parses a formatted price string back to double
  /// Example: parsePrice("Rp 15.000") returns 15000.0
  static double parsePrice(String formattedPrice) {
    try {
      // Remove currency symbol and thousands separators
      String cleanPrice = formattedPrice
          .replaceAll('Rp', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      
      return double.parse(cleanPrice);
    } catch (e) {
      return 0.0;
    }
  }
}
