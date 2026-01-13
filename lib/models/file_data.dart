/// Represents file data that can be provided to FormIO components.
///
/// Supports multiple input formats:
/// - File bytes as [Uint8List] (in-memory data)
/// - File bytes as [List<int>]
/// - File path as [String]
///
/// At least one of [bytes], [path], or [bytesAsIntList] must be provided.
library;

import 'dart:typed_data';

class FileData {
  /// File name (required)
  final String name;

  /// File bytes (Uint8List format)
  final Uint8List? bytes;

  /// File path on the file system
  final String? path;

  /// Optional MIME type (e.g., 'image/jpeg', 'application/pdf')
  final String? mimeType;

  const FileData({
    required this.name,
    this.bytes,
    this.path,
    this.mimeType,
  }) : assert(
          bytes != null || path != null,
          'Either bytes or path must be provided',
        );

  /// Creates a FileData from a List<int>
  factory FileData.fromIntList({
    required String name,
    required List<int> bytes,
    String? mimeType,
  }) {
    return FileData(
      name: name,
      bytes: Uint8List.fromList(bytes),
      mimeType: mimeType,
    );
  }

  /// Creates a FileData from a file path
  factory FileData.fromPath({
    required String name,
    required String path,
    String? mimeType,
  }) {
    return FileData(
      name: name,
      path: path,
      mimeType: mimeType,
    );
  }

  /// Creates a FileData from Uint8List
  factory FileData.fromBytes({
    required String name,
    required Uint8List bytes,
    String? mimeType,
  }) {
    return FileData(
      name: name,
      bytes: bytes,
      mimeType: mimeType,
    );
  }

  @override
  String toString() => 'FileData(name: $name, hasBytes: ${bytes != null}, path: $path, mimeType: $mimeType)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FileData && other.name == name && other.bytes == bytes && other.path == path && other.mimeType == mimeType;
  }

  @override
  int get hashCode {
    return name.hashCode ^ bytes.hashCode ^ path.hashCode ^ mimeType.hashCode;
  }
}
