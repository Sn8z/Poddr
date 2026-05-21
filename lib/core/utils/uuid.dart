import 'dart:math';
import 'dart:typed_data';

String generateUuidV4() {
  final random = Random.secure();
  final bytes = Uint8List(16);
  for (int i = 0; i < 16; i++) {
    bytes[i] = random.nextInt(256);
  }
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  return '${_hex(bytes, 0, 4)}-${_hex(bytes, 4, 2)}-${_hex(bytes, 6, 2)}-${_hex(bytes, 8, 2)}-${_hex(bytes, 10, 6)}';
}

String _hex(Uint8List bytes, int offset, int length) {
  return bytes
      .sublist(offset, offset + length)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}
