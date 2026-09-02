// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_list_entry.dart';

import 'package:hive/hive.dart';

// **************************************************************************
// HiveGenerator
// **************************************************************************

class WordListEntryAdapter extends TypeAdapter<WordListEntry> {
  @override
  final int typeId = 15;

  @override
  WordListEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WordListEntry(
      id: fields[0] as String,
      word: fields[1] as String,
      reading: fields[2] as String,
      meaning: fields[3] as String,
      websiteHost: fields[4] as String,
      createdAt: fields[5] as DateTime,
      lastReviewedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, WordListEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.reading)
      ..writeByte(3)
      ..write(obj.meaning)
      ..writeByte(4)
      ..write(obj.websiteHost)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastReviewedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordListEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
