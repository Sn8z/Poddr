class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized access']);
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Resource not found']);
}

class ServerErrorException extends ApiException {
  final int statusCode;
  ServerErrorException(this.statusCode,
      [super.message = 'Internal server error']);
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Network communication failure']);
}

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);
  @override
  String toString() => 'DownloadException: $message';
}

class DownloadCancelledException extends DownloadException {
  DownloadCancelledException([super.message = 'Download was cancelled']);
}

class DownloadFailedException extends DownloadException {
  final int? statusCode;
  DownloadFailedException(this.statusCode, [super.message = 'Download failed']);
}

class InsufficientSpaceException extends DownloadException {
  InsufficientSpaceException([super.message = 'Insufficient storage space']);
}
