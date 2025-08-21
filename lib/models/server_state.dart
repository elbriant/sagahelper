enum DataState {
  fetching,
  hasUpdate,
  upToDate,
  downloading,
  error,
}

class ServerState {
  String? version;
  DataState state;
  String? folderSize;

  ServerState({
    this.version,
    this.state = DataState.fetching,
    this.folderSize,
  });

  ServerState copyWith({
    String? version,
    DataState? state,
    String? folderSize,
  }) {
    return ServerState(
      version: version ?? this.version,
      state: state ?? this.state,
      folderSize: folderSize ?? this.folderSize,
    );
  }
}
