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

const Object _undefined = Object();

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
    Object? version = _undefined,
    DataState? state,
    Object? folderSize = _undefined,
  }) {
    return ServerState(
      server: server ?? this.server,
      version: version == _undefined ? this.version : (version as String?),
      state: state ?? this.state,
      folderSize: folderSize == _undefined ? this.folderSize : (folderSize as String?),
    );
  }
}
