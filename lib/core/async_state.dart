sealed class AsyncState<T> {
  const AsyncState();
}

final class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

final class AsyncData<T> extends AsyncState<T> {
  const AsyncData(this.value);

  final T value;
}

final class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.message);

  final String message;
}
