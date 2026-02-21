import 'package:flutter/foundation.dart' show immutable;
import 'package:sagahelper/providers/server_provider.dart';

enum DataState {
  unknown,
  fetching,
  hasUpdate,
  upToDate,
  downloading,
  error,
}

@immutable
class ServerState {
  final Server server;
  final String? version;
  final DataState state;
  final String? folderSize;

  const ServerState({
    required this.server,
    this.version,
    this.state = DataState.unknown,
    this.folderSize,
  });

  ServerState copyWith({
    Server? server,
    String? version,
    DataState? state,
    String? folderSize,
  }) {
    return ServerState(
      server: server ?? this.server,
      version: version ?? this.version,
      state: state ?? this.state,
      folderSize: folderSize ?? this.folderSize,
    );
  }
}
