class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Unauthorized access']) : super(message);
}

class NotFoundException extends ApiException {
  NotFoundException([String message = 'Resource not found']) : super(message);
}

class ServerErrorException extends ApiException {
  final int statusCode;
  ServerErrorException(this.statusCode, [String message = 'Internal server error']) : super(message);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Network communication failure']) : super(message);
}

class DownloadException implements Exception {
  final String message;
  DownloadException(this.message);
  @override
  String toString() => 'DownloadException: $message';
}

class DownloadCancelledException extends DownloadException {
  DownloadCancelledException([String message = 'Download was cancelled']) : super(message);
}

class DownloadFailedException extends DownloadException {
  final int? statusCode;
  DownloadFailedException(this.statusCode, [String message = 'Download failed']) : super(message);
}

class InsufficientSpaceException extends DownloadException {
  InsufficientSpaceException([String message = 'Insufficient storage space']) : super(message);
}
