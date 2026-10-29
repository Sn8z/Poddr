abstract class PoddrException implements Exception {
  String get message;
  String get userMessage;
}

class ApiException implements PoddrException {
  @override
  final String message;

  @override
  final String userMessage;

  ApiException(this.message, {String? userMessage})
      : userMessage = userMessage ?? 'Something went wrong. Please try again.';

  @override
  String toString() => '$runtimeType: $message';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized access'])
      : super(
          userMessage: 'Your credentials are invalid. Please sign in again.',
        );
}

class NotFoundException extends ApiException {
  NotFoundException([super.message = 'Resource not found'])
      : super(
          userMessage: 'This podcast is no longer available.',
        );
}

class ServerErrorException extends ApiException {
  final int statusCode;

  ServerErrorException(
    this.statusCode, [
    super.message = 'Internal server error',
  ]) : super(
          userMessage: 'The server is having trouble. Please try again later.',
        );
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'Network communication failure'])
      : super(
          userMessage: 'Check your connection and try again.',
        );
}

class DownloadException implements PoddrException {
  @override
  final String message;

  @override
  final String userMessage;

  DownloadException(this.message, {String? userMessage})
      : userMessage = userMessage ?? 'The download failed. Please try again.';

  @override
  String toString() => '$runtimeType: $message';
}

class DownloadCancelledException extends DownloadException {
  DownloadCancelledException([super.message = 'Download was cancelled'])
      : super(userMessage: 'Download cancelled.');
}

class DownloadFailedException extends DownloadException {
  final int? statusCode;

  DownloadFailedException(this.statusCode, [String message = 'Download failed'])
      : super(message, userMessage: _userMessageFor(statusCode));

  static String _userMessageFor(int? statusCode) {
    if (statusCode == 404) {
      return 'This episode is no longer available.';
    }
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return 'This episode could not be downloaded.';
    }
    return 'The download failed. Check your connection and try again.';
  }
}

class InsufficientSpaceException extends DownloadException {
  InsufficientSpaceException([super.message = 'Insufficient storage space'])
      : super(
          userMessage:
              'There is not enough storage space to download this episode.',
        );
}

String friendlyErrorMessage(Object error) {
  if (error is PoddrException) return error.userMessage;
  return 'Something went wrong. Please try again.';
}
