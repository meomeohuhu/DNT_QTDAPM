class VietQRGenerator {
  // Standard Bank configuration for FreshFarm e-commerce system
  static const String bankId = 'MB'; // MBBank (Ngân hàng Quân Đội)
  static const String accountNumber = '098765432123';
  static const String accountName = 'FRESHFARM CORP';

  /// Generates the standard VietQR image URL compatible with all Vietnamese banking apps
  static String getQuickImageUrl({
    required num amount,
    required String orderId,
    String? memo,
  }) {
    final info = Uri.encodeComponent(memo ?? 'FF $orderId');
    final name = Uri.encodeComponent(accountName);
    return 'https://img.vietqr.io/image/$bankId-$accountNumber-compact.png?amount=${amount.toInt()}&addInfo=$info&accountName=$name';
  }

  /// Generates standard payload string for raw QR code scanner
  static String getPayloadString({
    required num amount,
    required String orderId,
  }) {
    final amtStr = amount.toInt().toString();
    return '00020101021238540010A000000727012400069704220110${accountNumber}0208QRIBFTTA5303704540${amtStr.length}$amtStr'
        '5802VN62${(orderId.length + 4).toString().padLeft(2, '0')}080${orderId.length}${orderId}6304';
  }
}
