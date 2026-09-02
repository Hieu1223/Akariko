// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_transcript.dart';

import 'package:hive/hive.dart';

// **************************************************************************
// HiveGenerator
// **************************************************************************

class VideoTranscriptSegmentAdapter extends TypeAdapter<VideoTranscriptSegment> {
  @override
  final int typeId = 16;

  @override
  VideoTranscriptSegment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoTranscriptSegment(
      start: fields[0] as double,
      end: fields[1] as double,
      text: fields[2] as String,
      tokens: fields[3] as List<String>,
    );
  }

  @override
  void write(BinaryWriter writer, VideoTranscriptSegment obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.tokens);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTranscriptSegmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CachedVideoTranscriptAdapter extends TypeAdapter<CachedVideoTranscript> {
  @override
  final int typeId = 17;

  @override
  CachedVideoTranscript read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedVideoTranscript(
      videoId: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
      segments: fields[3] as List<VideoTranscriptSegment>,
      cachedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedVideoTranscript obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.videoId)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.segments)
      ..writeByte(4)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedVideoTranscriptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
