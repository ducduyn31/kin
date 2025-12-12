/// Masks a phone number for safe logging, showing only the last 4 digits.
/// Example: "+1234567890" becomes "******7890"
String maskPhoneNumber(String phoneNumber) {
  if (phoneNumber.length <= 4) {
    return '****';
  }
  final lastFour = phoneNumber.substring(phoneNumber.length - 4);
  return '******$lastFour';
}
