// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PodcastSubscriptionsTable extends PodcastSubscriptions
    with TableInfo<$PodcastSubscriptionsTable, PodcastSubscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastSubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rssMeta = const VerificationMeta('rss');
  @override
  late final GeneratedColumn<String> rss = GeneratedColumn<String>(
      'rss', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
      'author', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
      'image', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, rss, description, author, image];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_subscriptions';
  @override
  VerificationContext validateIntegrity(
      Insertable<PodcastSubscription> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('rss')) {
      context.handle(
          _rssMeta, rss.isAcceptableOrUnknown(data['rss']!, _rssMeta));
    } else if (isInserting) {
      context.missing(_rssMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('author')) {
      context.handle(_authorMeta,
          author.isAcceptableOrUnknown(data['author']!, _authorMeta));
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PodcastSubscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastSubscription(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      rss: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rss'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image'])!,
    );
  }

  @override
  $PodcastSubscriptionsTable createAlias(String alias) {
    return $PodcastSubscriptionsTable(attachedDatabase, alias);
  }
}

class PodcastSubscription extends DataClass
    implements Insertable<PodcastSubscription> {
  final int id;
  final String title;
  final String rss;
  final String description;
  final String author;
  final String image;
  const PodcastSubscription(
      {required this.id,
      required this.title,
      required this.rss,
      required this.description,
      required this.author,
      required this.image});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['rss'] = Variable<String>(rss);
    map['description'] = Variable<String>(description);
    map['author'] = Variable<String>(author);
    map['image'] = Variable<String>(image);
    return map;
  }

  PodcastSubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return PodcastSubscriptionsCompanion(
      id: Value(id),
      title: Value(title),
      rss: Value(rss),
      description: Value(description),
      author: Value(author),
      image: Value(image),
    );
  }

  factory PodcastSubscription.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastSubscription(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      rss: serializer.fromJson<String>(json['rss']),
      description: serializer.fromJson<String>(json['description']),
      author: serializer.fromJson<String>(json['author']),
      image: serializer.fromJson<String>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'rss': serializer.toJson<String>(rss),
      'description': serializer.toJson<String>(description),
      'author': serializer.toJson<String>(author),
      'image': serializer.toJson<String>(image),
    };
  }

  PodcastSubscription copyWith(
          {int? id,
          String? title,
          String? rss,
          String? description,
          String? author,
          String? image}) =>
      PodcastSubscription(
        id: id ?? this.id,
        title: title ?? this.title,
        rss: rss ?? this.rss,
        description: description ?? this.description,
        author: author ?? this.author,
        image: image ?? this.image,
      );
  PodcastSubscription copyWithCompanion(PodcastSubscriptionsCompanion data) {
    return PodcastSubscription(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      rss: data.rss.present ? data.rss.value : this.rss,
      description:
          data.description.present ? data.description.value : this.description,
      author: data.author.present ? data.author.value : this.author,
      image: data.image.present ? data.image.value : this.image,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastSubscription(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('rss: $rss, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, rss, description, author, image);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastSubscription &&
          other.id == this.id &&
          other.title == this.title &&
          other.rss == this.rss &&
          other.description == this.description &&
          other.author == this.author &&
          other.image == this.image);
}

class PodcastSubscriptionsCompanion
    extends UpdateCompanion<PodcastSubscription> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> rss;
  final Value<String> description;
  final Value<String> author;
  final Value<String> image;
  const PodcastSubscriptionsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.rss = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.image = const Value.absent(),
  });
  PodcastSubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String rss,
    required String description,
    required String author,
    required String image,
  })  : title = Value(title),
        rss = Value(rss),
        description = Value(description),
        author = Value(author),
        image = Value(image);
  static Insertable<PodcastSubscription> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? rss,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? image,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (rss != null) 'rss': rss,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (image != null) 'image': image,
    });
  }

  PodcastSubscriptionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? rss,
      Value<String>? description,
      Value<String>? author,
      Value<String>? image}) {
    return PodcastSubscriptionsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      rss: rss ?? this.rss,
      description: description ?? this.description,
      author: author ?? this.author,
      image: image ?? this.image,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rss.present) {
      map['rss'] = Variable<String>(rss.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastSubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('rss: $rss, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $PodcastSubscriptionsTable podcastSubscriptions =
      $PodcastSubscriptionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [podcastSubscriptions];
}

typedef $$PodcastSubscriptionsTableCreateCompanionBuilder
    = PodcastSubscriptionsCompanion Function({
  Value<int> id,
  required String title,
  required String rss,
  required String description,
  required String author,
  required String image,
});
typedef $$PodcastSubscriptionsTableUpdateCompanionBuilder
    = PodcastSubscriptionsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> rss,
  Value<String> description,
  Value<String> author,
  Value<String> image,
});

class $$PodcastSubscriptionsTableFilterComposer
    extends Composer<_$Database, $PodcastSubscriptionsTable> {
  $$PodcastSubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rss => $composableBuilder(
      column: $table.rss, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnFilters(column));
}

class $$PodcastSubscriptionsTableOrderingComposer
    extends Composer<_$Database, $PodcastSubscriptionsTable> {
  $$PodcastSubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rss => $composableBuilder(
      column: $table.rss, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get image => $composableBuilder(
      column: $table.image, builder: (column) => ColumnOrderings(column));
}

class $$PodcastSubscriptionsTableAnnotationComposer
    extends Composer<_$Database, $PodcastSubscriptionsTable> {
  $$PodcastSubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get rss =>
      $composableBuilder(column: $table.rss, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);
}

class $$PodcastSubscriptionsTableTableManager extends RootTableManager<
    _$Database,
    $PodcastSubscriptionsTable,
    PodcastSubscription,
    $$PodcastSubscriptionsTableFilterComposer,
    $$PodcastSubscriptionsTableOrderingComposer,
    $$PodcastSubscriptionsTableAnnotationComposer,
    $$PodcastSubscriptionsTableCreateCompanionBuilder,
    $$PodcastSubscriptionsTableUpdateCompanionBuilder,
    (
      PodcastSubscription,
      BaseReferences<_$Database, $PodcastSubscriptionsTable,
          PodcastSubscription>
    ),
    PodcastSubscription,
    PrefetchHooks Function()> {
  $$PodcastSubscriptionsTableTableManager(
      _$Database db, $PodcastSubscriptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastSubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastSubscriptionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastSubscriptionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> rss = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> image = const Value.absent(),
          }) =>
              PodcastSubscriptionsCompanion(
            id: id,
            title: title,
            rss: rss,
            description: description,
            author: author,
            image: image,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String rss,
            required String description,
            required String author,
            required String image,
          }) =>
              PodcastSubscriptionsCompanion.insert(
            id: id,
            title: title,
            rss: rss,
            description: description,
            author: author,
            image: image,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PodcastSubscriptionsTableProcessedTableManager
    = ProcessedTableManager<
        _$Database,
        $PodcastSubscriptionsTable,
        PodcastSubscription,
        $$PodcastSubscriptionsTableFilterComposer,
        $$PodcastSubscriptionsTableOrderingComposer,
        $$PodcastSubscriptionsTableAnnotationComposer,
        $$PodcastSubscriptionsTableCreateCompanionBuilder,
        $$PodcastSubscriptionsTableUpdateCompanionBuilder,
        (
          PodcastSubscription,
          BaseReferences<_$Database, $PodcastSubscriptionsTable,
              PodcastSubscription>
        ),
        PodcastSubscription,
        PrefetchHooks Function()>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$PodcastSubscriptionsTableTableManager get podcastSubscriptions =>
      $$PodcastSubscriptionsTableTableManager(_db, _db.podcastSubscriptions);
}
