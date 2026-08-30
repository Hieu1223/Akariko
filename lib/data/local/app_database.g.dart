// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TabsTableTable extends TabsTable
    with TableInfo<$TabsTableTable, TabRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TabsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('about:blank'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _faviconUrlMeta = const VerificationMeta(
    'faviconUrl',
  );
  @override
  late final GeneratedColumn<String> faviconUrl = GeneratedColumn<String>(
    'favicon_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _screenshotPathMeta = const VerificationMeta(
    'screenshotPath',
  );
  @override
  late final GeneratedColumn<String> screenshotPath = GeneratedColumn<String>(
    'screenshot_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastActiveAtMeta = const VerificationMeta(
    'lastActiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveAt = GeneratedColumn<DateTime>(
    'last_active_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    faviconUrl,
    screenshotPath,
    createdAt,
    lastActiveAt,
    isPinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tabs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TabRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('favicon_url')) {
      context.handle(
        _faviconUrlMeta,
        faviconUrl.isAcceptableOrUnknown(data['favicon_url']!, _faviconUrlMeta),
      );
    }
    if (data.containsKey('screenshot_path')) {
      context.handle(
        _screenshotPathMeta,
        screenshotPath.isAcceptableOrUnknown(
          data['screenshot_path']!,
          _screenshotPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('last_active_at')) {
      context.handle(
        _lastActiveAtMeta,
        lastActiveAt.isAcceptableOrUnknown(
          data['last_active_at']!,
          _lastActiveAtMeta,
        ),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TabRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      faviconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}favicon_url'],
      ),
      screenshotPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}screenshot_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastActiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_at'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
    );
  }

  @override
  $TabsTableTable createAlias(String alias) {
    return $TabsTableTable(attachedDatabase, alias);
  }
}

class TabRow extends DataClass implements Insertable<TabRow> {
  final String id;
  final String url;
  final String title;
  final String? faviconUrl;
  final String? screenshotPath;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isPinned;
  const TabRow({
    required this.id,
    required this.url,
    required this.title,
    this.faviconUrl,
    this.screenshotPath,
    required this.createdAt,
    required this.lastActiveAt,
    required this.isPinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || faviconUrl != null) {
      map['favicon_url'] = Variable<String>(faviconUrl);
    }
    if (!nullToAbsent || screenshotPath != null) {
      map['screenshot_path'] = Variable<String>(screenshotPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_active_at'] = Variable<DateTime>(lastActiveAt);
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  TabsTableCompanion toCompanion(bool nullToAbsent) {
    return TabsTableCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      faviconUrl: faviconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(faviconUrl),
      screenshotPath: screenshotPath == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotPath),
      createdAt: Value(createdAt),
      lastActiveAt: Value(lastActiveAt),
      isPinned: Value(isPinned),
    );
  }

  factory TabRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabRow(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      faviconUrl: serializer.fromJson<String?>(json['faviconUrl']),
      screenshotPath: serializer.fromJson<String?>(json['screenshotPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastActiveAt: serializer.fromJson<DateTime>(json['lastActiveAt']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'faviconUrl': serializer.toJson<String?>(faviconUrl),
      'screenshotPath': serializer.toJson<String?>(screenshotPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastActiveAt': serializer.toJson<DateTime>(lastActiveAt),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  TabRow copyWith({
    String? id,
    String? url,
    String? title,
    Value<String?> faviconUrl = const Value.absent(),
    Value<String?> screenshotPath = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isPinned,
  }) => TabRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    faviconUrl: faviconUrl.present ? faviconUrl.value : this.faviconUrl,
    screenshotPath: screenshotPath.present
        ? screenshotPath.value
        : this.screenshotPath,
    createdAt: createdAt ?? this.createdAt,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    isPinned: isPinned ?? this.isPinned,
  );
  TabRow copyWithCompanion(TabsTableCompanion data) {
    return TabRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      faviconUrl: data.faviconUrl.present
          ? data.faviconUrl.value
          : this.faviconUrl,
      screenshotPath: data.screenshotPath.present
          ? data.screenshotPath.value
          : this.screenshotPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastActiveAt: data.lastActiveAt.present
          ? data.lastActiveAt.value
          : this.lastActiveAt,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('screenshotPath: $screenshotPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    faviconUrl,
    screenshotPath,
    createdAt,
    lastActiveAt,
    isPinned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TabRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.faviconUrl == this.faviconUrl &&
          other.screenshotPath == this.screenshotPath &&
          other.createdAt == this.createdAt &&
          other.lastActiveAt == this.lastActiveAt &&
          other.isPinned == this.isPinned);
}

class TabsTableCompanion extends UpdateCompanion<TabRow> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String?> faviconUrl;
  final Value<String?> screenshotPath;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastActiveAt;
  final Value<bool> isPinned;
  final Value<int> rowid;
  const TabsTableCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.screenshotPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabsTableCompanion.insert({
    required String id,
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.faviconUrl = const Value.absent(),
    this.screenshotPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastActiveAt = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<TabRow> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? faviconUrl,
    Expression<String>? screenshotPath,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastActiveAt,
    Expression<bool>? isPinned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (faviconUrl != null) 'favicon_url': faviconUrl,
      if (screenshotPath != null) 'screenshot_path': screenshotPath,
      if (createdAt != null) 'created_at': createdAt,
      if (lastActiveAt != null) 'last_active_at': lastActiveAt,
      if (isPinned != null) 'is_pinned': isPinned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? title,
    Value<String?>? faviconUrl,
    Value<String?>? screenshotPath,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastActiveAt,
    Value<bool>? isPinned,
    Value<int>? rowid,
  }) {
    return TabsTableCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      screenshotPath: screenshotPath ?? this.screenshotPath,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isPinned: isPinned ?? this.isPinned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (faviconUrl.present) {
      map['favicon_url'] = Variable<String>(faviconUrl.value);
    }
    if (screenshotPath.present) {
      map['screenshot_path'] = Variable<String>(screenshotPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastActiveAt.present) {
      map['last_active_at'] = Variable<DateTime>(lastActiveAt.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabsTableCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('faviconUrl: $faviconUrl, ')
          ..write('screenshotPath: $screenshotPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastActiveAt: $lastActiveAt, ')
          ..write('isPinned: $isPinned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryTableTable extends HistoryTable
    with TableInfo<$HistoryTableTable, HistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _visitedAtMeta = const VerificationMeta(
    'visitedAt',
  );
  @override
  late final GeneratedColumn<DateTime> visitedAt = GeneratedColumn<DateTime>(
    'visited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, title, visitedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('visited_at')) {
      context.handle(
        _visitedAtMeta,
        visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      visitedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
    );
  }

  @override
  $HistoryTableTable createAlias(String alias) {
    return $HistoryTableTable(attachedDatabase, alias);
  }
}

class HistoryRow extends DataClass implements Insertable<HistoryRow> {
  final String id;
  final String url;
  final String title;
  final DateTime visitedAt;
  const HistoryRow({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['visited_at'] = Variable<DateTime>(visitedAt);
    return map;
  }

  HistoryTableCompanion toCompanion(bool nullToAbsent) {
    return HistoryTableCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      visitedAt: Value(visitedAt),
    );
  }

  factory HistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryRow(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      visitedAt: serializer.fromJson<DateTime>(json['visitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'visitedAt': serializer.toJson<DateTime>(visitedAt),
    };
  }

  HistoryRow copyWith({
    String? id,
    String? url,
    String? title,
    DateTime? visitedAt,
  }) => HistoryRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    visitedAt: visitedAt ?? this.visitedAt,
  );
  HistoryRow copyWithCompanion(HistoryTableCompanion data) {
    return HistoryRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitedAt: $visitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, title, visitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.visitedAt == this.visitedAt);
}

class HistoryTableCompanion extends UpdateCompanion<HistoryRow> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> title;
  final Value<DateTime> visitedAt;
  final Value<int> rowid;
  const HistoryTableCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HistoryTableCompanion.insert({
    required String id,
    required String url,
    this.title = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url);
  static Insertable<HistoryRow> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<DateTime>? visitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? title,
    Value<DateTime>? visitedAt,
    Value<int>? rowid,
  }) {
    return HistoryTableCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      visitedAt: visitedAt ?? this.visitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<DateTime>(visitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTableTable extends BookmarksTable
    with TableInfo<$BookmarksTableTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _folderMeta = const VerificationMeta('folder');
  @override
  late final GeneratedColumn<String> folder = GeneratedColumn<String>(
    'folder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, url, title, folder, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookmarkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('folder')) {
      context.handle(
        _folderMeta,
        folder.isAcceptableOrUnknown(data['folder']!, _folderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      folder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BookmarksTableTable createAlias(String alias) {
    return $BookmarksTableTable(attachedDatabase, alias);
  }
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  final String id;
  final String url;
  final String title;
  final String folder;
  final DateTime createdAt;
  const BookmarkRow({
    required this.id,
    required this.url,
    required this.title,
    required this.folder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    map['folder'] = Variable<String>(folder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BookmarksTableCompanion toCompanion(bool nullToAbsent) {
    return BookmarksTableCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      folder: Value(folder),
      createdAt: Value(createdAt),
    );
  }

  factory BookmarkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      folder: serializer.fromJson<String>(json['folder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'folder': serializer.toJson<String>(folder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BookmarkRow copyWith({
    String? id,
    String? url,
    String? title,
    String? folder,
    DateTime? createdAt,
  }) => BookmarkRow(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    folder: folder ?? this.folder,
    createdAt: createdAt ?? this.createdAt,
  );
  BookmarkRow copyWithCompanion(BookmarksTableCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      folder: data.folder.present ? data.folder.value : this.folder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('folder: $folder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, url, title, folder, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.folder == this.folder &&
          other.createdAt == this.createdAt);
}

class BookmarksTableCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String> folder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BookmarksTableCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.folder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksTableCompanion.insert({
    required String id,
    required String url,
    this.title = const Value.absent(),
    this.folder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url);
  static Insertable<BookmarkRow> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? folder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (folder != null) 'folder': folder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String>? title,
    Value<String>? folder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BookmarksTableCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      folder: folder ?? this.folder,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (folder.present) {
      map['folder'] = Variable<String>(folder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksTableCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('folder: $folder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DictionaryEntriesTableTable extends DictionaryEntriesTable
    with TableInfo<$DictionaryEntriesTableTable, DictionaryEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DictionaryEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _headwordMeta = const VerificationMeta(
    'headword',
  );
  @override
  late final GeneratedColumn<String> headword = GeneratedColumn<String>(
    'headword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _posMeta = const VerificationMeta('pos');
  @override
  late final GeneratedColumn<String> pos = GeneratedColumn<String>(
    'pos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _meaningsJsonMeta = const VerificationMeta(
    'meaningsJson',
  );
  @override
  late final GeneratedColumn<String> meaningsJson = GeneratedColumn<String>(
    'meanings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _sourcePackMeta = const VerificationMeta(
    'sourcePack',
  );
  @override
  late final GeneratedColumn<String> sourcePack = GeneratedColumn<String>(
    'source_pack',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    headword,
    reading,
    pos,
    meaningsJson,
    sourcePack,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dictionary_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DictionaryEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('headword')) {
      context.handle(
        _headwordMeta,
        headword.isAcceptableOrUnknown(data['headword']!, _headwordMeta),
      );
    } else if (isInserting) {
      context.missing(_headwordMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    }
    if (data.containsKey('pos')) {
      context.handle(
        _posMeta,
        pos.isAcceptableOrUnknown(data['pos']!, _posMeta),
      );
    }
    if (data.containsKey('meanings_json')) {
      context.handle(
        _meaningsJsonMeta,
        meaningsJson.isAcceptableOrUnknown(
          data['meanings_json']!,
          _meaningsJsonMeta,
        ),
      );
    }
    if (data.containsKey('source_pack')) {
      context.handle(
        _sourcePackMeta,
        sourcePack.isAcceptableOrUnknown(data['source_pack']!, _sourcePackMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DictionaryEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DictionaryEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      headword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}headword'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      pos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos'],
      )!,
      meaningsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meanings_json'],
      )!,
      sourcePack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_pack'],
      )!,
    );
  }

  @override
  $DictionaryEntriesTableTable createAlias(String alias) {
    return $DictionaryEntriesTableTable(attachedDatabase, alias);
  }
}

class DictionaryEntryRow extends DataClass
    implements Insertable<DictionaryEntryRow> {
  final String id;
  final String headword;
  final String reading;
  final String pos;
  final String meaningsJson;
  final String sourcePack;
  const DictionaryEntryRow({
    required this.id,
    required this.headword,
    required this.reading,
    required this.pos,
    required this.meaningsJson,
    required this.sourcePack,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['headword'] = Variable<String>(headword);
    map['reading'] = Variable<String>(reading);
    map['pos'] = Variable<String>(pos);
    map['meanings_json'] = Variable<String>(meaningsJson);
    map['source_pack'] = Variable<String>(sourcePack);
    return map;
  }

  DictionaryEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return DictionaryEntriesTableCompanion(
      id: Value(id),
      headword: Value(headword),
      reading: Value(reading),
      pos: Value(pos),
      meaningsJson: Value(meaningsJson),
      sourcePack: Value(sourcePack),
    );
  }

  factory DictionaryEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DictionaryEntryRow(
      id: serializer.fromJson<String>(json['id']),
      headword: serializer.fromJson<String>(json['headword']),
      reading: serializer.fromJson<String>(json['reading']),
      pos: serializer.fromJson<String>(json['pos']),
      meaningsJson: serializer.fromJson<String>(json['meaningsJson']),
      sourcePack: serializer.fromJson<String>(json['sourcePack']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'headword': serializer.toJson<String>(headword),
      'reading': serializer.toJson<String>(reading),
      'pos': serializer.toJson<String>(pos),
      'meaningsJson': serializer.toJson<String>(meaningsJson),
      'sourcePack': serializer.toJson<String>(sourcePack),
    };
  }

  DictionaryEntryRow copyWith({
    String? id,
    String? headword,
    String? reading,
    String? pos,
    String? meaningsJson,
    String? sourcePack,
  }) => DictionaryEntryRow(
    id: id ?? this.id,
    headword: headword ?? this.headword,
    reading: reading ?? this.reading,
    pos: pos ?? this.pos,
    meaningsJson: meaningsJson ?? this.meaningsJson,
    sourcePack: sourcePack ?? this.sourcePack,
  );
  DictionaryEntryRow copyWithCompanion(DictionaryEntriesTableCompanion data) {
    return DictionaryEntryRow(
      id: data.id.present ? data.id.value : this.id,
      headword: data.headword.present ? data.headword.value : this.headword,
      reading: data.reading.present ? data.reading.value : this.reading,
      pos: data.pos.present ? data.pos.value : this.pos,
      meaningsJson: data.meaningsJson.present
          ? data.meaningsJson.value
          : this.meaningsJson,
      sourcePack: data.sourcePack.present
          ? data.sourcePack.value
          : this.sourcePack,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntryRow(')
          ..write('id: $id, ')
          ..write('headword: $headword, ')
          ..write('reading: $reading, ')
          ..write('pos: $pos, ')
          ..write('meaningsJson: $meaningsJson, ')
          ..write('sourcePack: $sourcePack')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, headword, reading, pos, meaningsJson, sourcePack);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DictionaryEntryRow &&
          other.id == this.id &&
          other.headword == this.headword &&
          other.reading == this.reading &&
          other.pos == this.pos &&
          other.meaningsJson == this.meaningsJson &&
          other.sourcePack == this.sourcePack);
}

class DictionaryEntriesTableCompanion
    extends UpdateCompanion<DictionaryEntryRow> {
  final Value<String> id;
  final Value<String> headword;
  final Value<String> reading;
  final Value<String> pos;
  final Value<String> meaningsJson;
  final Value<String> sourcePack;
  final Value<int> rowid;
  const DictionaryEntriesTableCompanion({
    this.id = const Value.absent(),
    this.headword = const Value.absent(),
    this.reading = const Value.absent(),
    this.pos = const Value.absent(),
    this.meaningsJson = const Value.absent(),
    this.sourcePack = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DictionaryEntriesTableCompanion.insert({
    required String id,
    required String headword,
    this.reading = const Value.absent(),
    this.pos = const Value.absent(),
    this.meaningsJson = const Value.absent(),
    this.sourcePack = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       headword = Value(headword);
  static Insertable<DictionaryEntryRow> custom({
    Expression<String>? id,
    Expression<String>? headword,
    Expression<String>? reading,
    Expression<String>? pos,
    Expression<String>? meaningsJson,
    Expression<String>? sourcePack,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (headword != null) 'headword': headword,
      if (reading != null) 'reading': reading,
      if (pos != null) 'pos': pos,
      if (meaningsJson != null) 'meanings_json': meaningsJson,
      if (sourcePack != null) 'source_pack': sourcePack,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DictionaryEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? headword,
    Value<String>? reading,
    Value<String>? pos,
    Value<String>? meaningsJson,
    Value<String>? sourcePack,
    Value<int>? rowid,
  }) {
    return DictionaryEntriesTableCompanion(
      id: id ?? this.id,
      headword: headword ?? this.headword,
      reading: reading ?? this.reading,
      pos: pos ?? this.pos,
      meaningsJson: meaningsJson ?? this.meaningsJson,
      sourcePack: sourcePack ?? this.sourcePack,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (headword.present) {
      map['headword'] = Variable<String>(headword.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (pos.present) {
      map['pos'] = Variable<String>(pos.value);
    }
    if (meaningsJson.present) {
      map['meanings_json'] = Variable<String>(meaningsJson.value);
    }
    if (sourcePack.present) {
      map['source_pack'] = Variable<String>(sourcePack.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DictionaryEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('headword: $headword, ')
          ..write('reading: $reading, ')
          ..write('pos: $pos, ')
          ..write('meaningsJson: $meaningsJson, ')
          ..write('sourcePack: $sourcePack, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTableTable extends DecksTable
    with TableInfo<$DecksTableTable, DecksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _cardCountMeta = const VerificationMeta(
    'cardCount',
  );
  @override
  late final GeneratedColumn<int> cardCount = GeneratedColumn<int>(
    'card_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt, cardCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DecksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('card_count')) {
      context.handle(
        _cardCountMeta,
        cardCount.isAcceptableOrUnknown(data['card_count']!, _cardCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DecksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DecksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      cardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_count'],
      )!,
    );
  }

  @override
  $DecksTableTable createAlias(String alias) {
    return $DecksTableTable(attachedDatabase, alias);
  }
}

class DecksTableData extends DataClass implements Insertable<DecksTableData> {
  final String id;
  final String name;
  final DateTime createdAt;
  final int cardCount;
  const DecksTableData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.cardCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['card_count'] = Variable<int>(cardCount);
    return map;
  }

  DecksTableCompanion toCompanion(bool nullToAbsent) {
    return DecksTableCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      cardCount: Value(cardCount),
    );
  }

  factory DecksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DecksTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      cardCount: serializer.fromJson<int>(json['cardCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'cardCount': serializer.toJson<int>(cardCount),
    };
  }

  DecksTableData copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? cardCount,
  }) => DecksTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    cardCount: cardCount ?? this.cardCount,
  );
  DecksTableData copyWithCompanion(DecksTableCompanion data) {
    return DecksTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      cardCount: data.cardCount.present ? data.cardCount.value : this.cardCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DecksTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('cardCount: $cardCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, cardCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DecksTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.cardCount == this.cardCount);
}

class DecksTableCompanion extends UpdateCompanion<DecksTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> cardCount;
  final Value<int> rowid;
  const DecksTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksTableCompanion.insert({
    required String id,
    required String name,
    this.createdAt = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<DecksTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? cardCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (cardCount != null) 'card_count': cardCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<int>? cardCount,
    Value<int>? rowid,
  }) {
    return DecksTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      cardCount: cardCount ?? this.cardCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cardCount.present) {
      map['card_count'] = Variable<int>(cardCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('cardCount: $cardCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTableTable extends FlashcardsTable
    with TableInfo<$FlashcardsTableTable, FlashcardsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('word'),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _dueMeta = const VerificationMeta('due');
  @override
  late final GeneratedColumn<DateTime> due = GeneratedColumn<DateTime>(
    'due',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _stabilityMeta = const VerificationMeta(
    'stability',
  );
  @override
  late final GeneratedColumn<double> stability = GeneratedColumn<double>(
    'stability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _elapsedDaysMeta = const VerificationMeta(
    'elapsedDays',
  );
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
    'elapsed_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scheduledDaysMeta = const VerificationMeta(
    'scheduledDays',
  );
  @override
  late final GeneratedColumn<int> scheduledDays = GeneratedColumn<int>(
    'scheduled_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
    'lapses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('New'),
  );
  static const VerificationMeta _lastReviewMeta = const VerificationMeta(
    'lastReview',
  );
  @override
  late final GeneratedColumn<DateTime> lastReview = GeneratedColumn<DateTime>(
    'last_review',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    type,
    content,
    reading,
    meaning,
    extraJson,
    due,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    reps,
    lapses,
    state,
    lastReview,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashcardsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    if (data.containsKey('due')) {
      context.handle(
        _dueMeta,
        due.isAcceptableOrUnknown(data['due']!, _dueMeta),
      );
    }
    if (data.containsKey('stability')) {
      context.handle(
        _stabilityMeta,
        stability.isAcceptableOrUnknown(data['stability']!, _stabilityMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
        _elapsedDaysMeta,
        elapsedDays.isAcceptableOrUnknown(
          data['elapsed_days']!,
          _elapsedDaysMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_days')) {
      context.handle(
        _scheduledDaysMeta,
        scheduledDays.isAcceptableOrUnknown(
          data['scheduled_days']!,
          _scheduledDaysMeta,
        ),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('lapses')) {
      context.handle(
        _lapsesMeta,
        lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('last_review')) {
      context.handle(
        _lastReviewMeta,
        lastReview.isAcceptableOrUnknown(data['last_review']!, _lastReviewMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      )!,
      due: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due'],
      )!,
      stability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      elapsedDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_days'],
      )!,
      scheduledDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_days'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      lapses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lapses'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      lastReview: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_review'],
      ),
    );
  }

  @override
  $FlashcardsTableTable createAlias(String alias) {
    return $FlashcardsTableTable(attachedDatabase, alias);
  }
}

class FlashcardsTableData extends DataClass
    implements Insertable<FlashcardsTableData> {
  final String id;
  final String deckId;
  final String type;
  final String content;
  final String reading;
  final String meaning;
  final String extraJson;
  final DateTime due;
  final double stability;
  final double difficulty;
  final int elapsedDays;
  final int scheduledDays;
  final int reps;
  final int lapses;
  final String state;
  final DateTime? lastReview;
  const FlashcardsTableData({
    required this.id,
    required this.deckId,
    required this.type,
    required this.content,
    required this.reading,
    required this.meaning,
    required this.extraJson,
    required this.due,
    required this.stability,
    required this.difficulty,
    required this.elapsedDays,
    required this.scheduledDays,
    required this.reps,
    required this.lapses,
    required this.state,
    this.lastReview,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['type'] = Variable<String>(type);
    map['content'] = Variable<String>(content);
    map['reading'] = Variable<String>(reading);
    map['meaning'] = Variable<String>(meaning);
    map['extra_json'] = Variable<String>(extraJson);
    map['due'] = Variable<DateTime>(due);
    map['stability'] = Variable<double>(stability);
    map['difficulty'] = Variable<double>(difficulty);
    map['elapsed_days'] = Variable<int>(elapsedDays);
    map['scheduled_days'] = Variable<int>(scheduledDays);
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || lastReview != null) {
      map['last_review'] = Variable<DateTime>(lastReview);
    }
    return map;
  }

  FlashcardsTableCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsTableCompanion(
      id: Value(id),
      deckId: Value(deckId),
      type: Value(type),
      content: Value(content),
      reading: Value(reading),
      meaning: Value(meaning),
      extraJson: Value(extraJson),
      due: Value(due),
      stability: Value(stability),
      difficulty: Value(difficulty),
      elapsedDays: Value(elapsedDays),
      scheduledDays: Value(scheduledDays),
      reps: Value(reps),
      lapses: Value(lapses),
      state: Value(state),
      lastReview: lastReview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReview),
    );
  }

  factory FlashcardsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardsTableData(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String>(json['content']),
      reading: serializer.fromJson<String>(json['reading']),
      meaning: serializer.fromJson<String>(json['meaning']),
      extraJson: serializer.fromJson<String>(json['extraJson']),
      due: serializer.fromJson<DateTime>(json['due']),
      stability: serializer.fromJson<double>(json['stability']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      scheduledDays: serializer.fromJson<int>(json['scheduledDays']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      state: serializer.fromJson<String>(json['state']),
      lastReview: serializer.fromJson<DateTime?>(json['lastReview']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String>(content),
      'reading': serializer.toJson<String>(reading),
      'meaning': serializer.toJson<String>(meaning),
      'extraJson': serializer.toJson<String>(extraJson),
      'due': serializer.toJson<DateTime>(due),
      'stability': serializer.toJson<double>(stability),
      'difficulty': serializer.toJson<double>(difficulty),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'scheduledDays': serializer.toJson<int>(scheduledDays),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'state': serializer.toJson<String>(state),
      'lastReview': serializer.toJson<DateTime?>(lastReview),
    };
  }

  FlashcardsTableData copyWith({
    String? id,
    String? deckId,
    String? type,
    String? content,
    String? reading,
    String? meaning,
    String? extraJson,
    DateTime? due,
    double? stability,
    double? difficulty,
    int? elapsedDays,
    int? scheduledDays,
    int? reps,
    int? lapses,
    String? state,
    Value<DateTime?> lastReview = const Value.absent(),
  }) => FlashcardsTableData(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    type: type ?? this.type,
    content: content ?? this.content,
    reading: reading ?? this.reading,
    meaning: meaning ?? this.meaning,
    extraJson: extraJson ?? this.extraJson,
    due: due ?? this.due,
    stability: stability ?? this.stability,
    difficulty: difficulty ?? this.difficulty,
    elapsedDays: elapsedDays ?? this.elapsedDays,
    scheduledDays: scheduledDays ?? this.scheduledDays,
    reps: reps ?? this.reps,
    lapses: lapses ?? this.lapses,
    state: state ?? this.state,
    lastReview: lastReview.present ? lastReview.value : this.lastReview,
  );
  FlashcardsTableData copyWithCompanion(FlashcardsTableCompanion data) {
    return FlashcardsTableData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      reading: data.reading.present ? data.reading.value : this.reading,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
      due: data.due.present ? data.due.value : this.due,
      stability: data.stability.present ? data.stability.value : this.stability,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      elapsedDays: data.elapsedDays.present
          ? data.elapsedDays.value
          : this.elapsedDays,
      scheduledDays: data.scheduledDays.present
          ? data.scheduledDays.value
          : this.scheduledDays,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      state: data.state.present ? data.state.value : this.state,
      lastReview: data.lastReview.present
          ? data.lastReview.value
          : this.lastReview,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsTableData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('extraJson: $extraJson, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    type,
    content,
    reading,
    meaning,
    extraJson,
    due,
    stability,
    difficulty,
    elapsedDays,
    scheduledDays,
    reps,
    lapses,
    state,
    lastReview,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardsTableData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.type == this.type &&
          other.content == this.content &&
          other.reading == this.reading &&
          other.meaning == this.meaning &&
          other.extraJson == this.extraJson &&
          other.due == this.due &&
          other.stability == this.stability &&
          other.difficulty == this.difficulty &&
          other.elapsedDays == this.elapsedDays &&
          other.scheduledDays == this.scheduledDays &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.state == this.state &&
          other.lastReview == this.lastReview);
}

class FlashcardsTableCompanion extends UpdateCompanion<FlashcardsTableData> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> type;
  final Value<String> content;
  final Value<String> reading;
  final Value<String> meaning;
  final Value<String> extraJson;
  final Value<DateTime> due;
  final Value<double> stability;
  final Value<double> difficulty;
  final Value<int> elapsedDays;
  final Value<int> scheduledDays;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<String> state;
  final Value<DateTime?> lastReview;
  final Value<int> rowid;
  const FlashcardsTableCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsTableCompanion.insert({
    required String id,
    required String deckId,
    this.type = const Value.absent(),
    required String content,
    this.reading = const Value.absent(),
    this.meaning = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.due = const Value.absent(),
    this.stability = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.scheduledDays = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.state = const Value.absent(),
    this.lastReview = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       content = Value(content);
  static Insertable<FlashcardsTableData> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? type,
    Expression<String>? content,
    Expression<String>? reading,
    Expression<String>? meaning,
    Expression<String>? extraJson,
    Expression<DateTime>? due,
    Expression<double>? stability,
    Expression<double>? difficulty,
    Expression<int>? elapsedDays,
    Expression<int>? scheduledDays,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<String>? state,
    Expression<DateTime>? lastReview,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (reading != null) 'reading': reading,
      if (meaning != null) 'meaning': meaning,
      if (extraJson != null) 'extra_json': extraJson,
      if (due != null) 'due': due,
      if (stability != null) 'stability': stability,
      if (difficulty != null) 'difficulty': difficulty,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (scheduledDays != null) 'scheduled_days': scheduledDays,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (state != null) 'state': state,
      if (lastReview != null) 'last_review': lastReview,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? type,
    Value<String>? content,
    Value<String>? reading,
    Value<String>? meaning,
    Value<String>? extraJson,
    Value<DateTime>? due,
    Value<double>? stability,
    Value<double>? difficulty,
    Value<int>? elapsedDays,
    Value<int>? scheduledDays,
    Value<int>? reps,
    Value<int>? lapses,
    Value<String>? state,
    Value<DateTime?>? lastReview,
    Value<int>? rowid,
  }) {
    return FlashcardsTableCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      type: type ?? this.type,
      content: content ?? this.content,
      reading: reading ?? this.reading,
      meaning: meaning ?? this.meaning,
      extraJson: extraJson ?? this.extraJson,
      due: due ?? this.due,
      stability: stability ?? this.stability,
      difficulty: difficulty ?? this.difficulty,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      scheduledDays: scheduledDays ?? this.scheduledDays,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      state: state ?? this.state,
      lastReview: lastReview ?? this.lastReview,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    if (due.present) {
      map['due'] = Variable<DateTime>(due.value);
    }
    if (stability.present) {
      map['stability'] = Variable<double>(stability.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (scheduledDays.present) {
      map['scheduled_days'] = Variable<int>(scheduledDays.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (lastReview.present) {
      map['last_review'] = Variable<DateTime>(lastReview.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsTableCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('reading: $reading, ')
          ..write('meaning: $meaning, ')
          ..write('extraJson: $extraJson, ')
          ..write('due: $due, ')
          ..write('stability: $stability, ')
          ..write('difficulty: $difficulty, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('scheduledDays: $scheduledDays, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('state: $state, ')
          ..write('lastReview: $lastReview, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogsTableTable extends ReviewLogsTable
    with TableInfo<$ReviewLogsTableTable, ReviewLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _prevStateJsonMeta = const VerificationMeta(
    'prevStateJson',
  );
  @override
  late final GeneratedColumn<String> prevStateJson = GeneratedColumn<String>(
    'prev_state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _newStateJsonMeta = const VerificationMeta(
    'newStateJson',
  );
  @override
  late final GeneratedColumn<String> newStateJson = GeneratedColumn<String>(
    'new_state_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardId,
    rating,
    reviewedAt,
    prevStateJson,
    newStateJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_logs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReviewLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    if (data.containsKey('prev_state_json')) {
      context.handle(
        _prevStateJsonMeta,
        prevStateJson.isAcceptableOrUnknown(
          data['prev_state_json']!,
          _prevStateJsonMeta,
        ),
      );
    }
    if (data.containsKey('new_state_json')) {
      context.handle(
        _newStateJsonMeta,
        newStateJson.isAcceptableOrUnknown(
          data['new_state_json']!,
          _newStateJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewLogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      )!,
      prevStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_state_json'],
      )!,
      newStateJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_state_json'],
      )!,
    );
  }

  @override
  $ReviewLogsTableTable createAlias(String alias) {
    return $ReviewLogsTableTable(attachedDatabase, alias);
  }
}

class ReviewLogsTableData extends DataClass
    implements Insertable<ReviewLogsTableData> {
  final String id;
  final String cardId;
  final String rating;
  final DateTime reviewedAt;
  final String prevStateJson;
  final String newStateJson;
  const ReviewLogsTableData({
    required this.id,
    required this.cardId,
    required this.rating,
    required this.reviewedAt,
    required this.prevStateJson,
    required this.newStateJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['rating'] = Variable<String>(rating);
    map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    map['prev_state_json'] = Variable<String>(prevStateJson);
    map['new_state_json'] = Variable<String>(newStateJson);
    return map;
  }

  ReviewLogsTableCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogsTableCompanion(
      id: Value(id),
      cardId: Value(cardId),
      rating: Value(rating),
      reviewedAt: Value(reviewedAt),
      prevStateJson: Value(prevStateJson),
      newStateJson: Value(newStateJson),
    );
  }

  factory ReviewLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogsTableData(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      rating: serializer.fromJson<String>(json['rating']),
      reviewedAt: serializer.fromJson<DateTime>(json['reviewedAt']),
      prevStateJson: serializer.fromJson<String>(json['prevStateJson']),
      newStateJson: serializer.fromJson<String>(json['newStateJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'rating': serializer.toJson<String>(rating),
      'reviewedAt': serializer.toJson<DateTime>(reviewedAt),
      'prevStateJson': serializer.toJson<String>(prevStateJson),
      'newStateJson': serializer.toJson<String>(newStateJson),
    };
  }

  ReviewLogsTableData copyWith({
    String? id,
    String? cardId,
    String? rating,
    DateTime? reviewedAt,
    String? prevStateJson,
    String? newStateJson,
  }) => ReviewLogsTableData(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    rating: rating ?? this.rating,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    prevStateJson: prevStateJson ?? this.prevStateJson,
    newStateJson: newStateJson ?? this.newStateJson,
  );
  ReviewLogsTableData copyWithCompanion(ReviewLogsTableCompanion data) {
    return ReviewLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      prevStateJson: data.prevStateJson.present
          ? data.prevStateJson.value
          : this.prevStateJson,
      newStateJson: data.newStateJson.present
          ? data.newStateJson.value
          : this.newStateJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsTableData(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('prevStateJson: $prevStateJson, ')
          ..write('newStateJson: $newStateJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, rating, reviewedAt, prevStateJson, newStateJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogsTableData &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.rating == this.rating &&
          other.reviewedAt == this.reviewedAt &&
          other.prevStateJson == this.prevStateJson &&
          other.newStateJson == this.newStateJson);
}

class ReviewLogsTableCompanion extends UpdateCompanion<ReviewLogsTableData> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<String> rating;
  final Value<DateTime> reviewedAt;
  final Value<String> prevStateJson;
  final Value<String> newStateJson;
  final Value<int> rowid;
  const ReviewLogsTableCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.prevStateJson = const Value.absent(),
    this.newStateJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewLogsTableCompanion.insert({
    required String id,
    required String cardId,
    required String rating,
    this.reviewedAt = const Value.absent(),
    this.prevStateJson = const Value.absent(),
    this.newStateJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       rating = Value(rating);
  static Insertable<ReviewLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<String>? rating,
    Expression<DateTime>? reviewedAt,
    Expression<String>? prevStateJson,
    Expression<String>? newStateJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (rating != null) 'rating': rating,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (prevStateJson != null) 'prev_state_json': prevStateJson,
      if (newStateJson != null) 'new_state_json': newStateJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<String>? rating,
    Value<DateTime>? reviewedAt,
    Value<String>? prevStateJson,
    Value<String>? newStateJson,
    Value<int>? rowid,
  }) {
    return ReviewLogsTableCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      rating: rating ?? this.rating,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      prevStateJson: prevStateJson ?? this.prevStateJson,
      newStateJson: newStateJson ?? this.newStateJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    if (prevStateJson.present) {
      map['prev_state_json'] = Variable<String>(prevStateJson.value);
    }
    if (newStateJson.present) {
      map['new_state_json'] = Variable<String>(newStateJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('rating: $rating, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('prevStateJson: $prevStateJson, ')
          ..write('newStateJson: $newStateJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadItemsTableTable extends DownloadItemsTable
    with TableInfo<$DownloadItemsTableTable, DownloadItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('downloading'),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    filePath,
    status,
    progress,
    totalBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DownloadItemsTableTable createAlias(String alias) {
    return $DownloadItemsTableTable(attachedDatabase, alias);
  }
}

class DownloadItemsTableData extends DataClass
    implements Insertable<DownloadItemsTableData> {
  final String id;
  final String url;
  final String? filePath;
  final String status;
  final double progress;
  final int totalBytes;
  final DateTime createdAt;
  const DownloadItemsTableData({
    required this.id,
    required this.url,
    this.filePath,
    required this.status,
    required this.progress,
    required this.totalBytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    map['total_bytes'] = Variable<int>(totalBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DownloadItemsTableCompanion toCompanion(bool nullToAbsent) {
    return DownloadItemsTableCompanion(
      id: Value(id),
      url: Value(url),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      status: Value(status),
      progress: Value(progress),
      totalBytes: Value(totalBytes),
      createdAt: Value(createdAt),
    );
  }

  factory DownloadItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      totalBytes: serializer.fromJson<int>(json['totalBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<String>(url),
      'filePath': serializer.toJson<String?>(filePath),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'totalBytes': serializer.toJson<int>(totalBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DownloadItemsTableData copyWith({
    String? id,
    String? url,
    Value<String?> filePath = const Value.absent(),
    String? status,
    double? progress,
    int? totalBytes,
    DateTime? createdAt,
  }) => DownloadItemsTableData(
    id: id ?? this.id,
    url: url ?? this.url,
    filePath: filePath.present ? filePath.value : this.filePath,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    totalBytes: totalBytes ?? this.totalBytes,
    createdAt: createdAt ?? this.createdAt,
  );
  DownloadItemsTableData copyWithCompanion(DownloadItemsTableCompanion data) {
    return DownloadItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadItemsTableData(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, url, filePath, status, progress, totalBytes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadItemsTableData &&
          other.id == this.id &&
          other.url == this.url &&
          other.filePath == this.filePath &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.totalBytes == this.totalBytes &&
          other.createdAt == this.createdAt);
}

class DownloadItemsTableCompanion
    extends UpdateCompanion<DownloadItemsTableData> {
  final Value<String> id;
  final Value<String> url;
  final Value<String?> filePath;
  final Value<String> status;
  final Value<double> progress;
  final Value<int> totalBytes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DownloadItemsTableCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.filePath = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadItemsTableCompanion.insert({
    required String id,
    required String url,
    this.filePath = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       url = Value(url);
  static Insertable<DownloadItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? url,
    Expression<String>? filePath,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<int>? totalBytes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (filePath != null) 'file_path': filePath,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? url,
    Value<String?>? filePath,
    Value<String>? status,
    Value<double>? progress,
    Value<int>? totalBytes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DownloadItemsTableCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      filePath: filePath ?? this.filePath,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalBytes: totalBytes ?? this.totalBytes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('filePath: $filePath, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NewsSourcesTableTable extends NewsSourcesTable
    with TableInfo<$NewsSourcesTableTable, NewsSourcesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewsSourcesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, feedUrl, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'news_sources_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NewsSourcesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NewsSourcesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NewsSourcesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $NewsSourcesTableTable createAlias(String alias) {
    return $NewsSourcesTableTable(attachedDatabase, alias);
  }
}

class NewsSourcesTableData extends DataClass
    implements Insertable<NewsSourcesTableData> {
  final String id;
  final String name;
  final String feedUrl;
  final DateTime addedAt;
  const NewsSourcesTableData({
    required this.id,
    required this.name,
    required this.feedUrl,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['feed_url'] = Variable<String>(feedUrl);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  NewsSourcesTableCompanion toCompanion(bool nullToAbsent) {
    return NewsSourcesTableCompanion(
      id: Value(id),
      name: Value(name),
      feedUrl: Value(feedUrl),
      addedAt: Value(addedAt),
    );
  }

  factory NewsSourcesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NewsSourcesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  NewsSourcesTableData copyWith({
    String? id,
    String? name,
    String? feedUrl,
    DateTime? addedAt,
  }) => NewsSourcesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    feedUrl: feedUrl ?? this.feedUrl,
    addedAt: addedAt ?? this.addedAt,
  );
  NewsSourcesTableData copyWithCompanion(NewsSourcesTableCompanion data) {
    return NewsSourcesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NewsSourcesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, feedUrl, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NewsSourcesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.feedUrl == this.feedUrl &&
          other.addedAt == this.addedAt);
}

class NewsSourcesTableCompanion extends UpdateCompanion<NewsSourcesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> feedUrl;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const NewsSourcesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NewsSourcesTableCompanion.insert({
    required String id,
    required String name,
    required String feedUrl,
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       feedUrl = Value(feedUrl);
  static Insertable<NewsSourcesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? feedUrl,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NewsSourcesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? feedUrl,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return NewsSourcesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      feedUrl: feedUrl ?? this.feedUrl,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewsSourcesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NewsArticlesTableTable extends NewsArticlesTable
    with TableInfo<$NewsArticlesTableTable, NewsArticlesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NewsArticlesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linkMeta = const VerificationMeta('link');
  @override
  late final GeneratedColumn<String> link = GeneratedColumn<String>(
    'link',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceId,
    title,
    link,
    publishedAt,
    summary,
    isRead,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'news_articles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NewsArticlesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('link')) {
      context.handle(
        _linkMeta,
        link.isAcceptableOrUnknown(data['link']!, _linkMeta),
      );
    } else if (isInserting) {
      context.missing(_linkMeta);
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NewsArticlesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NewsArticlesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      link: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}link'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
    );
  }

  @override
  $NewsArticlesTableTable createAlias(String alias) {
    return $NewsArticlesTableTable(attachedDatabase, alias);
  }
}

class NewsArticlesTableData extends DataClass
    implements Insertable<NewsArticlesTableData> {
  final String id;
  final String sourceId;
  final String title;
  final String link;
  final DateTime? publishedAt;
  final String summary;
  final bool isRead;
  const NewsArticlesTableData({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.link,
    this.publishedAt,
    required this.summary,
    required this.isRead,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source_id'] = Variable<String>(sourceId);
    map['title'] = Variable<String>(title);
    map['link'] = Variable<String>(link);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['summary'] = Variable<String>(summary);
    map['is_read'] = Variable<bool>(isRead);
    return map;
  }

  NewsArticlesTableCompanion toCompanion(bool nullToAbsent) {
    return NewsArticlesTableCompanion(
      id: Value(id),
      sourceId: Value(sourceId),
      title: Value(title),
      link: Value(link),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      summary: Value(summary),
      isRead: Value(isRead),
    );
  }

  factory NewsArticlesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NewsArticlesTableData(
      id: serializer.fromJson<String>(json['id']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      title: serializer.fromJson<String>(json['title']),
      link: serializer.fromJson<String>(json['link']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      summary: serializer.fromJson<String>(json['summary']),
      isRead: serializer.fromJson<bool>(json['isRead']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sourceId': serializer.toJson<String>(sourceId),
      'title': serializer.toJson<String>(title),
      'link': serializer.toJson<String>(link),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'summary': serializer.toJson<String>(summary),
      'isRead': serializer.toJson<bool>(isRead),
    };
  }

  NewsArticlesTableData copyWith({
    String? id,
    String? sourceId,
    String? title,
    String? link,
    Value<DateTime?> publishedAt = const Value.absent(),
    String? summary,
    bool? isRead,
  }) => NewsArticlesTableData(
    id: id ?? this.id,
    sourceId: sourceId ?? this.sourceId,
    title: title ?? this.title,
    link: link ?? this.link,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    summary: summary ?? this.summary,
    isRead: isRead ?? this.isRead,
  );
  NewsArticlesTableData copyWithCompanion(NewsArticlesTableCompanion data) {
    return NewsArticlesTableData(
      id: data.id.present ? data.id.value : this.id,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      title: data.title.present ? data.title.value : this.title,
      link: data.link.present ? data.link.value : this.link,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      summary: data.summary.present ? data.summary.value : this.summary,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NewsArticlesTableData(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('link: $link, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('summary: $summary, ')
          ..write('isRead: $isRead')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceId, title, link, publishedAt, summary, isRead);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NewsArticlesTableData &&
          other.id == this.id &&
          other.sourceId == this.sourceId &&
          other.title == this.title &&
          other.link == this.link &&
          other.publishedAt == this.publishedAt &&
          other.summary == this.summary &&
          other.isRead == this.isRead);
}

class NewsArticlesTableCompanion
    extends UpdateCompanion<NewsArticlesTableData> {
  final Value<String> id;
  final Value<String> sourceId;
  final Value<String> title;
  final Value<String> link;
  final Value<DateTime?> publishedAt;
  final Value<String> summary;
  final Value<bool> isRead;
  final Value<int> rowid;
  const NewsArticlesTableCompanion({
    this.id = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.title = const Value.absent(),
    this.link = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NewsArticlesTableCompanion.insert({
    required String id,
    required String sourceId,
    required String title,
    required String link,
    this.publishedAt = const Value.absent(),
    this.summary = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourceId = Value(sourceId),
       title = Value(title),
       link = Value(link);
  static Insertable<NewsArticlesTableData> custom({
    Expression<String>? id,
    Expression<String>? sourceId,
    Expression<String>? title,
    Expression<String>? link,
    Expression<DateTime>? publishedAt,
    Expression<String>? summary,
    Expression<bool>? isRead,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceId != null) 'source_id': sourceId,
      if (title != null) 'title': title,
      if (link != null) 'link': link,
      if (publishedAt != null) 'published_at': publishedAt,
      if (summary != null) 'summary': summary,
      if (isRead != null) 'is_read': isRead,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NewsArticlesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? sourceId,
    Value<String>? title,
    Value<String>? link,
    Value<DateTime?>? publishedAt,
    Value<String>? summary,
    Value<bool>? isRead,
    Value<int>? rowid,
  }) {
    return NewsArticlesTableCompanion(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      title: title ?? this.title,
      link: link ?? this.link,
      publishedAt: publishedAt ?? this.publishedAt,
      summary: summary ?? this.summary,
      isRead: isRead ?? this.isRead,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (link.present) {
      map['link'] = Variable<String>(link.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NewsArticlesTableCompanion(')
          ..write('id: $id, ')
          ..write('sourceId: $sourceId, ')
          ..write('title: $title, ')
          ..write('link: $link, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('summary: $summary, ')
          ..write('isRead: $isRead, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PasswordEntriesTableTable extends PasswordEntriesTable
    with TableInfo<$PasswordEntriesTableTable, PasswordEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PasswordEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteUrlMeta = const VerificationMeta(
    'siteUrl',
  );
  @override
  late final GeneratedColumn<String> siteUrl = GeneratedColumn<String>(
    'site_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _encryptedPasswordMeta = const VerificationMeta(
    'encryptedPassword',
  );
  @override
  late final GeneratedColumn<String> encryptedPassword =
      GeneratedColumn<String>(
        'encrypted_password',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    siteUrl,
    username,
    encryptedPassword,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'password_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PasswordEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('site_url')) {
      context.handle(
        _siteUrlMeta,
        siteUrl.isAcceptableOrUnknown(data['site_url']!, _siteUrlMeta),
      );
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    }
    if (data.containsKey('encrypted_password')) {
      context.handle(
        _encryptedPasswordMeta,
        encryptedPassword.isAcceptableOrUnknown(
          data['encrypted_password']!,
          _encryptedPasswordMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPasswordMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PasswordEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PasswordEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      siteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_url'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      encryptedPassword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_password'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PasswordEntriesTableTable createAlias(String alias) {
    return $PasswordEntriesTableTable(attachedDatabase, alias);
  }
}

class PasswordEntriesTableData extends DataClass
    implements Insertable<PasswordEntriesTableData> {
  final String id;
  final String siteUrl;
  final String username;
  final String encryptedPassword;
  final String notes;
  final DateTime updatedAt;
  const PasswordEntriesTableData({
    required this.id,
    required this.siteUrl,
    required this.username,
    required this.encryptedPassword,
    required this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['site_url'] = Variable<String>(siteUrl);
    map['username'] = Variable<String>(username);
    map['encrypted_password'] = Variable<String>(encryptedPassword);
    map['notes'] = Variable<String>(notes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PasswordEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return PasswordEntriesTableCompanion(
      id: Value(id),
      siteUrl: Value(siteUrl),
      username: Value(username),
      encryptedPassword: Value(encryptedPassword),
      notes: Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory PasswordEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PasswordEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      siteUrl: serializer.fromJson<String>(json['siteUrl']),
      username: serializer.fromJson<String>(json['username']),
      encryptedPassword: serializer.fromJson<String>(json['encryptedPassword']),
      notes: serializer.fromJson<String>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'siteUrl': serializer.toJson<String>(siteUrl),
      'username': serializer.toJson<String>(username),
      'encryptedPassword': serializer.toJson<String>(encryptedPassword),
      'notes': serializer.toJson<String>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PasswordEntriesTableData copyWith({
    String? id,
    String? siteUrl,
    String? username,
    String? encryptedPassword,
    String? notes,
    DateTime? updatedAt,
  }) => PasswordEntriesTableData(
    id: id ?? this.id,
    siteUrl: siteUrl ?? this.siteUrl,
    username: username ?? this.username,
    encryptedPassword: encryptedPassword ?? this.encryptedPassword,
    notes: notes ?? this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PasswordEntriesTableData copyWithCompanion(
    PasswordEntriesTableCompanion data,
  ) {
    return PasswordEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      siteUrl: data.siteUrl.present ? data.siteUrl.value : this.siteUrl,
      username: data.username.present ? data.username.value : this.username,
      encryptedPassword: data.encryptedPassword.present
          ? data.encryptedPassword.value
          : this.encryptedPassword,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PasswordEntriesTableData(')
          ..write('id: $id, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, siteUrl, username, encryptedPassword, notes, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PasswordEntriesTableData &&
          other.id == this.id &&
          other.siteUrl == this.siteUrl &&
          other.username == this.username &&
          other.encryptedPassword == this.encryptedPassword &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class PasswordEntriesTableCompanion
    extends UpdateCompanion<PasswordEntriesTableData> {
  final Value<String> id;
  final Value<String> siteUrl;
  final Value<String> username;
  final Value<String> encryptedPassword;
  final Value<String> notes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PasswordEntriesTableCompanion({
    this.id = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.username = const Value.absent(),
    this.encryptedPassword = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PasswordEntriesTableCompanion.insert({
    required String id,
    this.siteUrl = const Value.absent(),
    this.username = const Value.absent(),
    required String encryptedPassword,
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       encryptedPassword = Value(encryptedPassword);
  static Insertable<PasswordEntriesTableData> custom({
    Expression<String>? id,
    Expression<String>? siteUrl,
    Expression<String>? username,
    Expression<String>? encryptedPassword,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (siteUrl != null) 'site_url': siteUrl,
      if (username != null) 'username': username,
      if (encryptedPassword != null) 'encrypted_password': encryptedPassword,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PasswordEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? siteUrl,
    Value<String>? username,
    Value<String>? encryptedPassword,
    Value<String>? notes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PasswordEntriesTableCompanion(
      id: id ?? this.id,
      siteUrl: siteUrl ?? this.siteUrl,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (siteUrl.present) {
      map['site_url'] = Variable<String>(siteUrl.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (encryptedPassword.present) {
      map['encrypted_password'] = Variable<String>(encryptedPassword.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PasswordEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('username: $username, ')
          ..write('encryptedPassword: $encryptedPassword, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TabsTableTable tabsTable = $TabsTableTable(this);
  late final $HistoryTableTable historyTable = $HistoryTableTable(this);
  late final $BookmarksTableTable bookmarksTable = $BookmarksTableTable(this);
  late final $DictionaryEntriesTableTable dictionaryEntriesTable =
      $DictionaryEntriesTableTable(this);
  late final $DecksTableTable decksTable = $DecksTableTable(this);
  late final $FlashcardsTableTable flashcardsTable = $FlashcardsTableTable(
    this,
  );
  late final $ReviewLogsTableTable reviewLogsTable = $ReviewLogsTableTable(
    this,
  );
  late final $DownloadItemsTableTable downloadItemsTable =
      $DownloadItemsTableTable(this);
  late final $NewsSourcesTableTable newsSourcesTable = $NewsSourcesTableTable(
    this,
  );
  late final $NewsArticlesTableTable newsArticlesTable =
      $NewsArticlesTableTable(this);
  late final $PasswordEntriesTableTable passwordEntriesTable =
      $PasswordEntriesTableTable(this);
  late final Index idxDictHeadword = Index(
    'idx_dict_headword',
    'CREATE INDEX idx_dict_headword ON dictionary_entries_table (headword)',
  );
  late final Index idxDictReading = Index(
    'idx_dict_reading',
    'CREATE INDEX idx_dict_reading ON dictionary_entries_table (reading)',
  );
  late final BrowserDao browserDao = BrowserDao(this as AppDatabase);
  late final DictionaryDao dictionaryDao = DictionaryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tabsTable,
    historyTable,
    bookmarksTable,
    dictionaryEntriesTable,
    decksTable,
    flashcardsTable,
    reviewLogsTable,
    downloadItemsTable,
    newsSourcesTable,
    newsArticlesTable,
    passwordEntriesTable,
    idxDictHeadword,
    idxDictReading,
  ];
}

typedef $$TabsTableTableCreateCompanionBuilder =
    TabsTableCompanion Function({
      required String id,
      Value<String> url,
      Value<String> title,
      Value<String?> faviconUrl,
      Value<String?> screenshotPath,
      Value<DateTime> createdAt,
      Value<DateTime> lastActiveAt,
      Value<bool> isPinned,
      Value<int> rowid,
    });
typedef $$TabsTableTableUpdateCompanionBuilder =
    TabsTableCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String> title,
      Value<String?> faviconUrl,
      Value<String?> screenshotPath,
      Value<DateTime> createdAt,
      Value<DateTime> lastActiveAt,
      Value<bool> isPinned,
      Value<int> rowid,
    });

class $$TabsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TabsTableTable> {
  $$TabsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screenshotPath => $composableBuilder(
    column: $table.screenshotPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TabsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TabsTableTable> {
  $$TabsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screenshotPath => $composableBuilder(
    column: $table.screenshotPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TabsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TabsTableTable> {
  $$TabsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get faviconUrl => $composableBuilder(
    column: $table.faviconUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get screenshotPath => $composableBuilder(
    column: $table.screenshotPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActiveAt => $composableBuilder(
    column: $table.lastActiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);
}

class $$TabsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TabsTableTable,
          TabRow,
          $$TabsTableTableFilterComposer,
          $$TabsTableTableOrderingComposer,
          $$TabsTableTableAnnotationComposer,
          $$TabsTableTableCreateCompanionBuilder,
          $$TabsTableTableUpdateCompanionBuilder,
          (TabRow, BaseReferences<_$AppDatabase, $TabsTableTable, TabRow>),
          TabRow,
          PrefetchHooks Function()
        > {
  $$TabsTableTableTableManager(_$AppDatabase db, $TabsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TabsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TabsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TabsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> faviconUrl = const Value.absent(),
                Value<String?> screenshotPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActiveAt = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabsTableCompanion(
                id: id,
                url: url,
                title: title,
                faviconUrl: faviconUrl,
                screenshotPath: screenshotPath,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
                isPinned: isPinned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> faviconUrl = const Value.absent(),
                Value<String?> screenshotPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastActiveAt = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabsTableCompanion.insert(
                id: id,
                url: url,
                title: title,
                faviconUrl: faviconUrl,
                screenshotPath: screenshotPath,
                createdAt: createdAt,
                lastActiveAt: lastActiveAt,
                isPinned: isPinned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TabsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TabsTableTable,
      TabRow,
      $$TabsTableTableFilterComposer,
      $$TabsTableTableOrderingComposer,
      $$TabsTableTableAnnotationComposer,
      $$TabsTableTableCreateCompanionBuilder,
      $$TabsTableTableUpdateCompanionBuilder,
      (TabRow, BaseReferences<_$AppDatabase, $TabsTableTable, TabRow>),
      TabRow,
      PrefetchHooks Function()
    >;
typedef $$HistoryTableTableCreateCompanionBuilder =
    HistoryTableCompanion Function({
      required String id,
      required String url,
      Value<String> title,
      Value<DateTime> visitedAt,
      Value<int> rowid,
    });
typedef $$HistoryTableTableUpdateCompanionBuilder =
    HistoryTableCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String> title,
      Value<DateTime> visitedAt,
      Value<int> rowid,
    });

class $$HistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryTableTable> {
  $$HistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);
}

class $$HistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HistoryTableTable,
          HistoryRow,
          $$HistoryTableTableFilterComposer,
          $$HistoryTableTableOrderingComposer,
          $$HistoryTableTableAnnotationComposer,
          $$HistoryTableTableCreateCompanionBuilder,
          $$HistoryTableTableUpdateCompanionBuilder,
          (
            HistoryRow,
            BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryRow>,
          ),
          HistoryRow,
          PrefetchHooks Function()
        > {
  $$HistoryTableTableTableManager(_$AppDatabase db, $HistoryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryTableCompanion(
                id: id,
                url: url,
                title: title,
                visitedAt: visitedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                Value<String> title = const Value.absent(),
                Value<DateTime> visitedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HistoryTableCompanion.insert(
                id: id,
                url: url,
                title: title,
                visitedAt: visitedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HistoryTableTable,
      HistoryRow,
      $$HistoryTableTableFilterComposer,
      $$HistoryTableTableOrderingComposer,
      $$HistoryTableTableAnnotationComposer,
      $$HistoryTableTableCreateCompanionBuilder,
      $$HistoryTableTableUpdateCompanionBuilder,
      (
        HistoryRow,
        BaseReferences<_$AppDatabase, $HistoryTableTable, HistoryRow>,
      ),
      HistoryRow,
      PrefetchHooks Function()
    >;
typedef $$BookmarksTableTableCreateCompanionBuilder =
    BookmarksTableCompanion Function({
      required String id,
      required String url,
      Value<String> title,
      Value<String> folder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableTableUpdateCompanionBuilder =
    BookmarksTableCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String> title,
      Value<String> folder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BookmarksTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookmarksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folder => $composableBuilder(
    column: $table.folder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookmarksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTableTable> {
  $$BookmarksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get folder =>
      $composableBuilder(column: $table.folder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BookmarksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTableTable,
          BookmarkRow,
          $$BookmarksTableTableFilterComposer,
          $$BookmarksTableTableOrderingComposer,
          $$BookmarksTableTableAnnotationComposer,
          $$BookmarksTableTableCreateCompanionBuilder,
          $$BookmarksTableTableUpdateCompanionBuilder,
          (
            BookmarkRow,
            BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarkRow>,
          ),
          BookmarkRow,
          PrefetchHooks Function()
        > {
  $$BookmarksTableTableTableManager(
    _$AppDatabase db,
    $BookmarksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> folder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksTableCompanion(
                id: id,
                url: url,
                title: title,
                folder: folder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                Value<String> title = const Value.absent(),
                Value<String> folder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksTableCompanion.insert(
                id: id,
                url: url,
                title: title,
                folder: folder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookmarksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTableTable,
      BookmarkRow,
      $$BookmarksTableTableFilterComposer,
      $$BookmarksTableTableOrderingComposer,
      $$BookmarksTableTableAnnotationComposer,
      $$BookmarksTableTableCreateCompanionBuilder,
      $$BookmarksTableTableUpdateCompanionBuilder,
      (
        BookmarkRow,
        BaseReferences<_$AppDatabase, $BookmarksTableTable, BookmarkRow>,
      ),
      BookmarkRow,
      PrefetchHooks Function()
    >;
typedef $$DictionaryEntriesTableTableCreateCompanionBuilder =
    DictionaryEntriesTableCompanion Function({
      required String id,
      required String headword,
      Value<String> reading,
      Value<String> pos,
      Value<String> meaningsJson,
      Value<String> sourcePack,
      Value<int> rowid,
    });
typedef $$DictionaryEntriesTableTableUpdateCompanionBuilder =
    DictionaryEntriesTableCompanion Function({
      Value<String> id,
      Value<String> headword,
      Value<String> reading,
      Value<String> pos,
      Value<String> meaningsJson,
      Value<String> sourcePack,
      Value<int> rowid,
    });

class $$DictionaryEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTableTable> {
  $$DictionaryEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaningsJson => $composableBuilder(
    column: $table.meaningsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePack => $composableBuilder(
    column: $table.sourcePack,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DictionaryEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTableTable> {
  $$DictionaryEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get headword => $composableBuilder(
    column: $table.headword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pos => $composableBuilder(
    column: $table.pos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaningsJson => $composableBuilder(
    column: $table.meaningsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePack => $composableBuilder(
    column: $table.sourcePack,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DictionaryEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DictionaryEntriesTableTable> {
  $$DictionaryEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get headword =>
      $composableBuilder(column: $table.headword, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get pos =>
      $composableBuilder(column: $table.pos, builder: (column) => column);

  GeneratedColumn<String> get meaningsJson => $composableBuilder(
    column: $table.meaningsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourcePack => $composableBuilder(
    column: $table.sourcePack,
    builder: (column) => column,
  );
}

class $$DictionaryEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DictionaryEntriesTableTable,
          DictionaryEntryRow,
          $$DictionaryEntriesTableTableFilterComposer,
          $$DictionaryEntriesTableTableOrderingComposer,
          $$DictionaryEntriesTableTableAnnotationComposer,
          $$DictionaryEntriesTableTableCreateCompanionBuilder,
          $$DictionaryEntriesTableTableUpdateCompanionBuilder,
          (
            DictionaryEntryRow,
            BaseReferences<
              _$AppDatabase,
              $DictionaryEntriesTableTable,
              DictionaryEntryRow
            >,
          ),
          DictionaryEntryRow,
          PrefetchHooks Function()
        > {
  $$DictionaryEntriesTableTableTableManager(
    _$AppDatabase db,
    $DictionaryEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DictionaryEntriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DictionaryEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DictionaryEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> headword = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> pos = const Value.absent(),
                Value<String> meaningsJson = const Value.absent(),
                Value<String> sourcePack = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DictionaryEntriesTableCompanion(
                id: id,
                headword: headword,
                reading: reading,
                pos: pos,
                meaningsJson: meaningsJson,
                sourcePack: sourcePack,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String headword,
                Value<String> reading = const Value.absent(),
                Value<String> pos = const Value.absent(),
                Value<String> meaningsJson = const Value.absent(),
                Value<String> sourcePack = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DictionaryEntriesTableCompanion.insert(
                id: id,
                headword: headword,
                reading: reading,
                pos: pos,
                meaningsJson: meaningsJson,
                sourcePack: sourcePack,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DictionaryEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DictionaryEntriesTableTable,
      DictionaryEntryRow,
      $$DictionaryEntriesTableTableFilterComposer,
      $$DictionaryEntriesTableTableOrderingComposer,
      $$DictionaryEntriesTableTableAnnotationComposer,
      $$DictionaryEntriesTableTableCreateCompanionBuilder,
      $$DictionaryEntriesTableTableUpdateCompanionBuilder,
      (
        DictionaryEntryRow,
        BaseReferences<
          _$AppDatabase,
          $DictionaryEntriesTableTable,
          DictionaryEntryRow
        >,
      ),
      DictionaryEntryRow,
      PrefetchHooks Function()
    >;
typedef $$DecksTableTableCreateCompanionBuilder =
    DecksTableCompanion Function({
      required String id,
      required String name,
      Value<DateTime> createdAt,
      Value<int> cardCount,
      Value<int> rowid,
    });
typedef $$DecksTableTableUpdateCompanionBuilder =
    DecksTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<int> cardCount,
      Value<int> rowid,
    });

class $$DecksTableTableFilterComposer
    extends Composer<_$AppDatabase, $DecksTableTable> {
  $$DecksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DecksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTableTable> {
  $$DecksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTableTable> {
  $$DecksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get cardCount =>
      $composableBuilder(column: $table.cardCount, builder: (column) => column);
}

class $$DecksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTableTable,
          DecksTableData,
          $$DecksTableTableFilterComposer,
          $$DecksTableTableOrderingComposer,
          $$DecksTableTableAnnotationComposer,
          $$DecksTableTableCreateCompanionBuilder,
          $$DecksTableTableUpdateCompanionBuilder,
          (
            DecksTableData,
            BaseReferences<_$AppDatabase, $DecksTableTable, DecksTableData>,
          ),
          DecksTableData,
          PrefetchHooks Function()
        > {
  $$DecksTableTableTableManager(_$AppDatabase db, $DecksTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksTableCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                cardCount: cardCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksTableCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                cardCount: cardCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DecksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTableTable,
      DecksTableData,
      $$DecksTableTableFilterComposer,
      $$DecksTableTableOrderingComposer,
      $$DecksTableTableAnnotationComposer,
      $$DecksTableTableCreateCompanionBuilder,
      $$DecksTableTableUpdateCompanionBuilder,
      (
        DecksTableData,
        BaseReferences<_$AppDatabase, $DecksTableTable, DecksTableData>,
      ),
      DecksTableData,
      PrefetchHooks Function()
    >;
typedef $$FlashcardsTableTableCreateCompanionBuilder =
    FlashcardsTableCompanion Function({
      required String id,
      required String deckId,
      Value<String> type,
      required String content,
      Value<String> reading,
      Value<String> meaning,
      Value<String> extraJson,
      Value<DateTime> due,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> elapsedDays,
      Value<int> scheduledDays,
      Value<int> reps,
      Value<int> lapses,
      Value<String> state,
      Value<DateTime?> lastReview,
      Value<int> rowid,
    });
typedef $$FlashcardsTableTableUpdateCompanionBuilder =
    FlashcardsTableCompanion Function({
      Value<String> id,
      Value<String> deckId,
      Value<String> type,
      Value<String> content,
      Value<String> reading,
      Value<String> meaning,
      Value<String> extraJson,
      Value<DateTime> due,
      Value<double> stability,
      Value<double> difficulty,
      Value<int> elapsedDays,
      Value<int> scheduledDays,
      Value<int> reps,
      Value<int> lapses,
      Value<String> state,
      Value<DateTime?> lastReview,
      Value<int> rowid,
    });

class $$FlashcardsTableTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTableTable> {
  $$FlashcardsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FlashcardsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTableTable> {
  $$FlashcardsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get due => $composableBuilder(
    column: $table.due,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stability => $composableBuilder(
    column: $table.stability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lapses => $composableBuilder(
    column: $table.lapses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FlashcardsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTableTable> {
  $$FlashcardsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);

  GeneratedColumn<DateTime> get due =>
      $composableBuilder(column: $table.due, builder: (column) => column);

  GeneratedColumn<double> get stability =>
      $composableBuilder(column: $table.stability, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
    column: $table.elapsedDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scheduledDays => $composableBuilder(
    column: $table.scheduledDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReview => $composableBuilder(
    column: $table.lastReview,
    builder: (column) => column,
  );
}

class $$FlashcardsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FlashcardsTableTable,
          FlashcardsTableData,
          $$FlashcardsTableTableFilterComposer,
          $$FlashcardsTableTableOrderingComposer,
          $$FlashcardsTableTableAnnotationComposer,
          $$FlashcardsTableTableCreateCompanionBuilder,
          $$FlashcardsTableTableUpdateCompanionBuilder,
          (
            FlashcardsTableData,
            BaseReferences<
              _$AppDatabase,
              $FlashcardsTableTable,
              FlashcardsTableData
            >,
          ),
          FlashcardsTableData,
          PrefetchHooks Function()
        > {
  $$FlashcardsTableTableTableManager(
    _$AppDatabase db,
    $FlashcardsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> extraJson = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsTableCompanion(
                id: id,
                deckId: deckId,
                type: type,
                content: content,
                reading: reading,
                meaning: meaning,
                extraJson: extraJson,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                reps: reps,
                lapses: lapses,
                state: state,
                lastReview: lastReview,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                Value<String> type = const Value.absent(),
                required String content,
                Value<String> reading = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String> extraJson = const Value.absent(),
                Value<DateTime> due = const Value.absent(),
                Value<double> stability = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> elapsedDays = const Value.absent(),
                Value<int> scheduledDays = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int> lapses = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime?> lastReview = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsTableCompanion.insert(
                id: id,
                deckId: deckId,
                type: type,
                content: content,
                reading: reading,
                meaning: meaning,
                extraJson: extraJson,
                due: due,
                stability: stability,
                difficulty: difficulty,
                elapsedDays: elapsedDays,
                scheduledDays: scheduledDays,
                reps: reps,
                lapses: lapses,
                state: state,
                lastReview: lastReview,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FlashcardsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FlashcardsTableTable,
      FlashcardsTableData,
      $$FlashcardsTableTableFilterComposer,
      $$FlashcardsTableTableOrderingComposer,
      $$FlashcardsTableTableAnnotationComposer,
      $$FlashcardsTableTableCreateCompanionBuilder,
      $$FlashcardsTableTableUpdateCompanionBuilder,
      (
        FlashcardsTableData,
        BaseReferences<
          _$AppDatabase,
          $FlashcardsTableTable,
          FlashcardsTableData
        >,
      ),
      FlashcardsTableData,
      PrefetchHooks Function()
    >;
typedef $$ReviewLogsTableTableCreateCompanionBuilder =
    ReviewLogsTableCompanion Function({
      required String id,
      required String cardId,
      required String rating,
      Value<DateTime> reviewedAt,
      Value<String> prevStateJson,
      Value<String> newStateJson,
      Value<int> rowid,
    });
typedef $$ReviewLogsTableTableUpdateCompanionBuilder =
    ReviewLogsTableCompanion Function({
      Value<String> id,
      Value<String> cardId,
      Value<String> rating,
      Value<DateTime> reviewedAt,
      Value<String> prevStateJson,
      Value<String> newStateJson,
      Value<int> rowid,
    });

class $$ReviewLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ReviewLogsTableTable> {
  $$ReviewLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevStateJson => $composableBuilder(
    column: $table.prevStateJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newStateJson => $composableBuilder(
    column: $table.newStateJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReviewLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ReviewLogsTableTable> {
  $$ReviewLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevStateJson => $composableBuilder(
    column: $table.prevStateJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newStateJson => $composableBuilder(
    column: $table.newStateJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReviewLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReviewLogsTableTable> {
  $$ReviewLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prevStateJson => $composableBuilder(
    column: $table.prevStateJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newStateJson => $composableBuilder(
    column: $table.newStateJson,
    builder: (column) => column,
  );
}

class $$ReviewLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReviewLogsTableTable,
          ReviewLogsTableData,
          $$ReviewLogsTableTableFilterComposer,
          $$ReviewLogsTableTableOrderingComposer,
          $$ReviewLogsTableTableAnnotationComposer,
          $$ReviewLogsTableTableCreateCompanionBuilder,
          $$ReviewLogsTableTableUpdateCompanionBuilder,
          (
            ReviewLogsTableData,
            BaseReferences<
              _$AppDatabase,
              $ReviewLogsTableTable,
              ReviewLogsTableData
            >,
          ),
          ReviewLogsTableData,
          PrefetchHooks Function()
        > {
  $$ReviewLogsTableTableTableManager(
    _$AppDatabase db,
    $ReviewLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<String> prevStateJson = const Value.absent(),
                Value<String> newStateJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsTableCompanion(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewedAt: reviewedAt,
                prevStateJson: prevStateJson,
                newStateJson: newStateJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required String rating,
                Value<DateTime> reviewedAt = const Value.absent(),
                Value<String> prevStateJson = const Value.absent(),
                Value<String> newStateJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReviewLogsTableCompanion.insert(
                id: id,
                cardId: cardId,
                rating: rating,
                reviewedAt: reviewedAt,
                prevStateJson: prevStateJson,
                newStateJson: newStateJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReviewLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReviewLogsTableTable,
      ReviewLogsTableData,
      $$ReviewLogsTableTableFilterComposer,
      $$ReviewLogsTableTableOrderingComposer,
      $$ReviewLogsTableTableAnnotationComposer,
      $$ReviewLogsTableTableCreateCompanionBuilder,
      $$ReviewLogsTableTableUpdateCompanionBuilder,
      (
        ReviewLogsTableData,
        BaseReferences<
          _$AppDatabase,
          $ReviewLogsTableTable,
          ReviewLogsTableData
        >,
      ),
      ReviewLogsTableData,
      PrefetchHooks Function()
    >;
typedef $$DownloadItemsTableTableCreateCompanionBuilder =
    DownloadItemsTableCompanion Function({
      required String id,
      required String url,
      Value<String?> filePath,
      Value<String> status,
      Value<double> progress,
      Value<int> totalBytes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DownloadItemsTableTableUpdateCompanionBuilder =
    DownloadItemsTableCompanion Function({
      Value<String> id,
      Value<String> url,
      Value<String?> filePath,
      Value<String> status,
      Value<double> progress,
      Value<int> totalBytes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DownloadItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadItemsTableTable> {
  $$DownloadItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadItemsTableTable> {
  $$DownloadItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadItemsTableTable> {
  $$DownloadItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DownloadItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadItemsTableTable,
          DownloadItemsTableData,
          $$DownloadItemsTableTableFilterComposer,
          $$DownloadItemsTableTableOrderingComposer,
          $$DownloadItemsTableTableAnnotationComposer,
          $$DownloadItemsTableTableCreateCompanionBuilder,
          $$DownloadItemsTableTableUpdateCompanionBuilder,
          (
            DownloadItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $DownloadItemsTableTable,
              DownloadItemsTableData
            >,
          ),
          DownloadItemsTableData,
          PrefetchHooks Function()
        > {
  $$DownloadItemsTableTableTableManager(
    _$AppDatabase db,
    $DownloadItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadItemsTableCompanion(
                id: id,
                url: url,
                filePath: filePath,
                status: status,
                progress: progress,
                totalBytes: totalBytes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String url,
                Value<String?> filePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int> totalBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DownloadItemsTableCompanion.insert(
                id: id,
                url: url,
                filePath: filePath,
                status: status,
                progress: progress,
                totalBytes: totalBytes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadItemsTableTable,
      DownloadItemsTableData,
      $$DownloadItemsTableTableFilterComposer,
      $$DownloadItemsTableTableOrderingComposer,
      $$DownloadItemsTableTableAnnotationComposer,
      $$DownloadItemsTableTableCreateCompanionBuilder,
      $$DownloadItemsTableTableUpdateCompanionBuilder,
      (
        DownloadItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $DownloadItemsTableTable,
          DownloadItemsTableData
        >,
      ),
      DownloadItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$NewsSourcesTableTableCreateCompanionBuilder =
    NewsSourcesTableCompanion Function({
      required String id,
      required String name,
      required String feedUrl,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$NewsSourcesTableTableUpdateCompanionBuilder =
    NewsSourcesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> feedUrl,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

class $$NewsSourcesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NewsSourcesTableTable> {
  $$NewsSourcesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NewsSourcesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NewsSourcesTableTable> {
  $$NewsSourcesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NewsSourcesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewsSourcesTableTable> {
  $$NewsSourcesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$NewsSourcesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NewsSourcesTableTable,
          NewsSourcesTableData,
          $$NewsSourcesTableTableFilterComposer,
          $$NewsSourcesTableTableOrderingComposer,
          $$NewsSourcesTableTableAnnotationComposer,
          $$NewsSourcesTableTableCreateCompanionBuilder,
          $$NewsSourcesTableTableUpdateCompanionBuilder,
          (
            NewsSourcesTableData,
            BaseReferences<
              _$AppDatabase,
              $NewsSourcesTableTable,
              NewsSourcesTableData
            >,
          ),
          NewsSourcesTableData,
          PrefetchHooks Function()
        > {
  $$NewsSourcesTableTableTableManager(
    _$AppDatabase db,
    $NewsSourcesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewsSourcesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewsSourcesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NewsSourcesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsSourcesTableCompanion(
                id: id,
                name: name,
                feedUrl: feedUrl,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String feedUrl,
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsSourcesTableCompanion.insert(
                id: id,
                name: name,
                feedUrl: feedUrl,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NewsSourcesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NewsSourcesTableTable,
      NewsSourcesTableData,
      $$NewsSourcesTableTableFilterComposer,
      $$NewsSourcesTableTableOrderingComposer,
      $$NewsSourcesTableTableAnnotationComposer,
      $$NewsSourcesTableTableCreateCompanionBuilder,
      $$NewsSourcesTableTableUpdateCompanionBuilder,
      (
        NewsSourcesTableData,
        BaseReferences<
          _$AppDatabase,
          $NewsSourcesTableTable,
          NewsSourcesTableData
        >,
      ),
      NewsSourcesTableData,
      PrefetchHooks Function()
    >;
typedef $$NewsArticlesTableTableCreateCompanionBuilder =
    NewsArticlesTableCompanion Function({
      required String id,
      required String sourceId,
      required String title,
      required String link,
      Value<DateTime?> publishedAt,
      Value<String> summary,
      Value<bool> isRead,
      Value<int> rowid,
    });
typedef $$NewsArticlesTableTableUpdateCompanionBuilder =
    NewsArticlesTableCompanion Function({
      Value<String> id,
      Value<String> sourceId,
      Value<String> title,
      Value<String> link,
      Value<DateTime?> publishedAt,
      Value<String> summary,
      Value<bool> isRead,
      Value<int> rowid,
    });

class $$NewsArticlesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NewsArticlesTableTable> {
  $$NewsArticlesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NewsArticlesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NewsArticlesTableTable> {
  $$NewsArticlesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get link => $composableBuilder(
    column: $table.link,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NewsArticlesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NewsArticlesTableTable> {
  $$NewsArticlesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get link =>
      $composableBuilder(column: $table.link, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);
}

class $$NewsArticlesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NewsArticlesTableTable,
          NewsArticlesTableData,
          $$NewsArticlesTableTableFilterComposer,
          $$NewsArticlesTableTableOrderingComposer,
          $$NewsArticlesTableTableAnnotationComposer,
          $$NewsArticlesTableTableCreateCompanionBuilder,
          $$NewsArticlesTableTableUpdateCompanionBuilder,
          (
            NewsArticlesTableData,
            BaseReferences<
              _$AppDatabase,
              $NewsArticlesTableTable,
              NewsArticlesTableData
            >,
          ),
          NewsArticlesTableData,
          PrefetchHooks Function()
        > {
  $$NewsArticlesTableTableTableManager(
    _$AppDatabase db,
    $NewsArticlesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NewsArticlesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NewsArticlesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NewsArticlesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> link = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsArticlesTableCompanion(
                id: id,
                sourceId: sourceId,
                title: title,
                link: link,
                publishedAt: publishedAt,
                summary: summary,
                isRead: isRead,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sourceId,
                required String title,
                required String link,
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NewsArticlesTableCompanion.insert(
                id: id,
                sourceId: sourceId,
                title: title,
                link: link,
                publishedAt: publishedAt,
                summary: summary,
                isRead: isRead,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NewsArticlesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NewsArticlesTableTable,
      NewsArticlesTableData,
      $$NewsArticlesTableTableFilterComposer,
      $$NewsArticlesTableTableOrderingComposer,
      $$NewsArticlesTableTableAnnotationComposer,
      $$NewsArticlesTableTableCreateCompanionBuilder,
      $$NewsArticlesTableTableUpdateCompanionBuilder,
      (
        NewsArticlesTableData,
        BaseReferences<
          _$AppDatabase,
          $NewsArticlesTableTable,
          NewsArticlesTableData
        >,
      ),
      NewsArticlesTableData,
      PrefetchHooks Function()
    >;
typedef $$PasswordEntriesTableTableCreateCompanionBuilder =
    PasswordEntriesTableCompanion Function({
      required String id,
      Value<String> siteUrl,
      Value<String> username,
      required String encryptedPassword,
      Value<String> notes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PasswordEntriesTableTableUpdateCompanionBuilder =
    PasswordEntriesTableCompanion Function({
      Value<String> id,
      Value<String> siteUrl,
      Value<String> username,
      Value<String> encryptedPassword,
      Value<String> notes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PasswordEntriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $PasswordEntriesTableTable> {
  $$PasswordEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PasswordEntriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PasswordEntriesTableTable> {
  $$PasswordEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PasswordEntriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PasswordEntriesTableTable> {
  $$PasswordEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get siteUrl =>
      $composableBuilder(column: $table.siteUrl, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get encryptedPassword => $composableBuilder(
    column: $table.encryptedPassword,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PasswordEntriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PasswordEntriesTableTable,
          PasswordEntriesTableData,
          $$PasswordEntriesTableTableFilterComposer,
          $$PasswordEntriesTableTableOrderingComposer,
          $$PasswordEntriesTableTableAnnotationComposer,
          $$PasswordEntriesTableTableCreateCompanionBuilder,
          $$PasswordEntriesTableTableUpdateCompanionBuilder,
          (
            PasswordEntriesTableData,
            BaseReferences<
              _$AppDatabase,
              $PasswordEntriesTableTable,
              PasswordEntriesTableData
            >,
          ),
          PasswordEntriesTableData,
          PrefetchHooks Function()
        > {
  $$PasswordEntriesTableTableTableManager(
    _$AppDatabase db,
    $PasswordEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PasswordEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PasswordEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PasswordEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> siteUrl = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> encryptedPassword = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PasswordEntriesTableCompanion(
                id: id,
                siteUrl: siteUrl,
                username: username,
                encryptedPassword: encryptedPassword,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> siteUrl = const Value.absent(),
                Value<String> username = const Value.absent(),
                required String encryptedPassword,
                Value<String> notes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PasswordEntriesTableCompanion.insert(
                id: id,
                siteUrl: siteUrl,
                username: username,
                encryptedPassword: encryptedPassword,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PasswordEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PasswordEntriesTableTable,
      PasswordEntriesTableData,
      $$PasswordEntriesTableTableFilterComposer,
      $$PasswordEntriesTableTableOrderingComposer,
      $$PasswordEntriesTableTableAnnotationComposer,
      $$PasswordEntriesTableTableCreateCompanionBuilder,
      $$PasswordEntriesTableTableUpdateCompanionBuilder,
      (
        PasswordEntriesTableData,
        BaseReferences<
          _$AppDatabase,
          $PasswordEntriesTableTable,
          PasswordEntriesTableData
        >,
      ),
      PasswordEntriesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TabsTableTableTableManager get tabsTable =>
      $$TabsTableTableTableManager(_db, _db.tabsTable);
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db, _db.historyTable);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(_db, _db.bookmarksTable);
  $$DictionaryEntriesTableTableTableManager get dictionaryEntriesTable =>
      $$DictionaryEntriesTableTableTableManager(
        _db,
        _db.dictionaryEntriesTable,
      );
  $$DecksTableTableTableManager get decksTable =>
      $$DecksTableTableTableManager(_db, _db.decksTable);
  $$FlashcardsTableTableTableManager get flashcardsTable =>
      $$FlashcardsTableTableTableManager(_db, _db.flashcardsTable);
  $$ReviewLogsTableTableTableManager get reviewLogsTable =>
      $$ReviewLogsTableTableTableManager(_db, _db.reviewLogsTable);
  $$DownloadItemsTableTableTableManager get downloadItemsTable =>
      $$DownloadItemsTableTableTableManager(_db, _db.downloadItemsTable);
  $$NewsSourcesTableTableTableManager get newsSourcesTable =>
      $$NewsSourcesTableTableTableManager(_db, _db.newsSourcesTable);
  $$NewsArticlesTableTableTableManager get newsArticlesTable =>
      $$NewsArticlesTableTableTableManager(_db, _db.newsArticlesTable);
  $$PasswordEntriesTableTableTableManager get passwordEntriesTable =>
      $$PasswordEntriesTableTableTableManager(_db, _db.passwordEntriesTable);
}
