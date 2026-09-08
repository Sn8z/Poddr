import 'package:poddr/core/log.dart';
import 'package:url_launcher/url_launcher.dart';

const String logName = 'ExternalLinks';

Future<bool> launchExternalUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    debug('Blocked external launch: unparseable URL $url', name: logName);
    return Future.value(false);
  }
  return launchExternalUri(uri);
}

Future<bool> launchExternalUri(Uri uri) async {
  const allowedSchemes = {'http', 'https', 'mailto'};
  final scheme = uri.scheme.toLowerCase();

  if (!allowedSchemes.contains(scheme)) {
    debug('Blocked external launch with scheme: $uri', name: logName);
    return false;
  }
  if (scheme != 'mailto' && uri.host.isEmpty) {
    debug('Blocked external launch: missing host', name: logName);
    return false;
  }
  if (!await canLaunchUrl(uri)) {
    debug('Cannot launch URL with scheme: $scheme', name: logName);
    return false;
  }

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (e) {
    error('Failed to launch URL $uri', name: logName);
    debug('Launch detail: $e', name: logName);
    return false;
  }
}
