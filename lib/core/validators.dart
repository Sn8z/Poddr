bool isValidUrl(String url, {bool requireHttps = false}) {
  try {
    final uri = Uri.parse(url);
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    if (requireHttps && uri.scheme != 'https') return false;
    if (uri.host.isEmpty) return false;
    return true;
  } catch (_) {
    return false;
  }
}
