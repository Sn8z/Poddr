// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PodcastSubscriptionTable extends PodcastSubscription
    with TableInfo<$PodcastSubscriptionTable, PodcastSubscriptionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastSubscriptionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _rssMeta = const VerificationMeta('rss');
  @override
  late final GeneratedColumn<String> rss = GeneratedColumn<String>(
      'rss', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
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
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subscribedAtMeta =
      const VerificationMeta('subscribedAt');
  @override
  late final GeneratedColumn<DateTime> subscribedAt = GeneratedColumn<DateTime>(
      'subscribed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, rss, title, description, author, imageUrl, subscribedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_subscription';
  @override
  VerificationContext validateIntegrity(
      Insertable<PodcastSubscriptionData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('rss')) {
      context.handle(
          _rssMeta, rss.isAcceptableOrUnknown(data['rss']!, _rssMeta));
    } else if (isInserting) {
      context.missing(_rssMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
          _subscribedAtMeta,
          subscribedAt.isAcceptableOrUnknown(
              data['subscribed_at']!, _subscribedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PodcastSubscriptionData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastSubscriptionData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rss: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rss'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      author: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      subscribedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}subscribed_at'])!,
    );
  }

  @override
  $PodcastSubscriptionTable createAlias(String alias) {
    return $PodcastSubscriptionTable(attachedDatabase, alias);
  }
}

class PodcastSubscriptionData extends DataClass
    implements Insertable<PodcastSubscriptionData> {
  final int id;
  final String rss;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final DateTime subscribedAt;
  const PodcastSubscriptionData(
      {required this.id,
      required this.rss,
      required this.title,
      required this.description,
      required this.author,
      required this.imageUrl,
      required this.subscribedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rss'] = Variable<String>(rss);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['author'] = Variable<String>(author);
    map['image_url'] = Variable<String>(imageUrl);
    map['subscribed_at'] = Variable<DateTime>(subscribedAt);
    return map;
  }

  PodcastSubscriptionCompanion toCompanion(bool nullToAbsent) {
    return PodcastSubscriptionCompanion(
      id: Value(id),
      rss: Value(rss),
      title: Value(title),
      description: Value(description),
      author: Value(author),
      imageUrl: Value(imageUrl),
      subscribedAt: Value(subscribedAt),
    );
  }

  factory PodcastSubscriptionData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastSubscriptionData(
      id: serializer.fromJson<int>(json['id']),
      rss: serializer.fromJson<String>(json['rss']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      author: serializer.fromJson<String>(json['author']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      subscribedAt: serializer.fromJson<DateTime>(json['subscribedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rss': serializer.toJson<String>(rss),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'author': serializer.toJson<String>(author),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
    };
  }

  PodcastSubscriptionData copyWith(
          {int? id,
          String? rss,
          String? title,
          String? description,
          String? author,
          String? imageUrl,
          DateTime? subscribedAt}) =>
      PodcastSubscriptionData(
        id: id ?? this.id,
        rss: rss ?? this.rss,
        title: title ?? this.title,
        description: description ?? this.description,
        author: author ?? this.author,
        imageUrl: imageUrl ?? this.imageUrl,
        subscribedAt: subscribedAt ?? this.subscribedAt,
      );
  PodcastSubscriptionData copyWithCompanion(PodcastSubscriptionCompanion data) {
    return PodcastSubscriptionData(
      id: data.id.present ? data.id.value : this.id,
      rss: data.rss.present ? data.rss.value : this.rss,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      author: data.author.present ? data.author.value : this.author,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastSubscriptionData(')
          ..write('id: $id, ')
          ..write('rss: $rss, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('subscribedAt: $subscribedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, rss, title, description, author, imageUrl, subscribedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastSubscriptionData &&
          other.id == this.id &&
          other.rss == this.rss &&
          other.title == this.title &&
          other.description == this.description &&
          other.author == this.author &&
          other.imageUrl == this.imageUrl &&
          other.subscribedAt == this.subscribedAt);
}

class PodcastSubscriptionCompanion
    extends UpdateCompanion<PodcastSubscriptionData> {
  final Value<int> id;
  final Value<String> rss;
  final Value<String> title;
  final Value<String> description;
  final Value<String> author;
  final Value<String> imageUrl;
  final Value<DateTime> subscribedAt;
  const PodcastSubscriptionCompanion({
    this.id = const Value.absent(),
    this.rss = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.subscribedAt = const Value.absent(),
  });
  PodcastSubscriptionCompanion.insert({
    this.id = const Value.absent(),
    required String rss,
    required String title,
    required String description,
    required String author,
    required String imageUrl,
    this.subscribedAt = const Value.absent(),
  })  : rss = Value(rss),
        title = Value(title),
        description = Value(description),
        author = Value(author),
        imageUrl = Value(imageUrl);
  static Insertable<PodcastSubscriptionData> custom({
    Expression<int>? id,
    Expression<String>? rss,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? imageUrl,
    Expression<DateTime>? subscribedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rss != null) 'rss': rss,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
    });
  }

  PodcastSubscriptionCompanion copyWith(
      {Value<int>? id,
      Value<String>? rss,
      Value<String>? title,
      Value<String>? description,
      Value<String>? author,
      Value<String>? imageUrl,
      Value<DateTime>? subscribedAt}) {
    return PodcastSubscriptionCompanion(
      id: id ?? this.id,
      rss: rss ?? this.rss,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      subscribedAt: subscribedAt ?? this.subscribedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rss.present) {
      map['rss'] = Variable<String>(rss.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<DateTime>(subscribedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastSubscriptionCompanion(')
          ..write('id: $id, ')
          ..write('rss: $rss, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('subscribedAt: $subscribedAt')
          ..write(')'))
        .toString();
  }
}

class $ListeningHistoryTable extends ListeningHistory
    with TableInfo<$ListeningHistoryTable, ListeningHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeningHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _podcastTitleMeta =
      const VerificationMeta('podcastTitle');
  @override
  late final GeneratedColumn<String> podcastTitle = GeneratedColumn<String>(
      'podcast_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _podcastRSSMeta =
      const VerificationMeta('podcastRSS');
  @override
  late final GeneratedColumn<String> podcastRSS = GeneratedColumn<String>(
      'podcast_r_s_s', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isFinishedMeta =
      const VerificationMeta('isFinished');
  @override
  late final GeneratedColumn<bool> isFinished = GeneratedColumn<bool>(
      'is_finished', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_finished" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _listenedAtMeta =
      const VerificationMeta('listenedAt');
  @override
  late final GeneratedColumn<DateTime> listenedAt = GeneratedColumn<DateTime>(
      'listened_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        audioUrl,
        title,
        description,
        imageUrl,
        podcastTitle,
        podcastRSS,
        position,
        duration,
        isFinished,
        listenedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listening_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<ListeningHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('podcast_title')) {
      context.handle(
          _podcastTitleMeta,
          podcastTitle.isAcceptableOrUnknown(
              data['podcast_title']!, _podcastTitleMeta));
    } else if (isInserting) {
      context.missing(_podcastTitleMeta);
    }
    if (data.containsKey('podcast_r_s_s')) {
      context.handle(
          _podcastRSSMeta,
          podcastRSS.isAcceptableOrUnknown(
              data['podcast_r_s_s']!, _podcastRSSMeta));
    } else if (isInserting) {
      context.missing(_podcastRSSMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('is_finished')) {
      context.handle(
          _isFinishedMeta,
          isFinished.isAcceptableOrUnknown(
              data['is_finished']!, _isFinishedMeta));
    }
    if (data.containsKey('listened_at')) {
      context.handle(
          _listenedAtMeta,
          listenedAt.isAcceptableOrUnknown(
              data['listened_at']!, _listenedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListeningHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      podcastTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}podcast_title'])!,
      podcastRSS: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}podcast_r_s_s'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      isFinished: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_finished'])!,
      listenedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}listened_at'])!,
    );
  }

  @override
  $ListeningHistoryTable createAlias(String alias) {
    return $ListeningHistoryTable(attachedDatabase, alias);
  }
}

class ListeningHistoryData extends DataClass
    implements Insertable<ListeningHistoryData> {
  final int id;
  final String audioUrl;
  final String title;
  final String description;
  final String imageUrl;
  final String podcastTitle;
  final String podcastRSS;
  final int position;
  final int duration;
  final bool isFinished;
  final DateTime listenedAt;
  const ListeningHistoryData(
      {required this.id,
      required this.audioUrl,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.podcastTitle,
      required this.podcastRSS,
      required this.position,
      required this.duration,
      required this.isFinished,
      required this.listenedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['audio_url'] = Variable<String>(audioUrl);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['image_url'] = Variable<String>(imageUrl);
    map['podcast_title'] = Variable<String>(podcastTitle);
    map['podcast_r_s_s'] = Variable<String>(podcastRSS);
    map['position'] = Variable<int>(position);
    map['duration'] = Variable<int>(duration);
    map['is_finished'] = Variable<bool>(isFinished);
    map['listened_at'] = Variable<DateTime>(listenedAt);
    return map;
  }

  ListeningHistoryCompanion toCompanion(bool nullToAbsent) {
    return ListeningHistoryCompanion(
      id: Value(id),
      audioUrl: Value(audioUrl),
      title: Value(title),
      description: Value(description),
      imageUrl: Value(imageUrl),
      podcastTitle: Value(podcastTitle),
      podcastRSS: Value(podcastRSS),
      position: Value(position),
      duration: Value(duration),
      isFinished: Value(isFinished),
      listenedAt: Value(listenedAt),
    );
  }

  factory ListeningHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListeningHistoryData(
      id: serializer.fromJson<int>(json['id']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      podcastTitle: serializer.fromJson<String>(json['podcastTitle']),
      podcastRSS: serializer.fromJson<String>(json['podcastRSS']),
      position: serializer.fromJson<int>(json['position']),
      duration: serializer.fromJson<int>(json['duration']),
      isFinished: serializer.fromJson<bool>(json['isFinished']),
      listenedAt: serializer.fromJson<DateTime>(json['listenedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'podcastTitle': serializer.toJson<String>(podcastTitle),
      'podcastRSS': serializer.toJson<String>(podcastRSS),
      'position': serializer.toJson<int>(position),
      'duration': serializer.toJson<int>(duration),
      'isFinished': serializer.toJson<bool>(isFinished),
      'listenedAt': serializer.toJson<DateTime>(listenedAt),
    };
  }

  ListeningHistoryData copyWith(
          {int? id,
          String? audioUrl,
          String? title,
          String? description,
          String? imageUrl,
          String? podcastTitle,
          String? podcastRSS,
          int? position,
          int? duration,
          bool? isFinished,
          DateTime? listenedAt}) =>
      ListeningHistoryData(
        id: id ?? this.id,
        audioUrl: audioUrl ?? this.audioUrl,
        title: title ?? this.title,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        podcastTitle: podcastTitle ?? this.podcastTitle,
        podcastRSS: podcastRSS ?? this.podcastRSS,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        isFinished: isFinished ?? this.isFinished,
        listenedAt: listenedAt ?? this.listenedAt,
      );
  ListeningHistoryData copyWithCompanion(ListeningHistoryCompanion data) {
    return ListeningHistoryData(
      id: data.id.present ? data.id.value : this.id,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      podcastTitle: data.podcastTitle.present
          ? data.podcastTitle.value
          : this.podcastTitle,
      podcastRSS:
          data.podcastRSS.present ? data.podcastRSS.value : this.podcastRSS,
      position: data.position.present ? data.position.value : this.position,
      duration: data.duration.present ? data.duration.value : this.duration,
      isFinished:
          data.isFinished.present ? data.isFinished.value : this.isFinished,
      listenedAt:
          data.listenedAt.present ? data.listenedAt.value : this.listenedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryData(')
          ..write('id: $id, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('podcastRSS: $podcastRSS, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('isFinished: $isFinished, ')
          ..write('listenedAt: $listenedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, audioUrl, title, description, imageUrl,
      podcastTitle, podcastRSS, position, duration, isFinished, listenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningHistoryData &&
          other.id == this.id &&
          other.audioUrl == this.audioUrl &&
          other.title == this.title &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.podcastTitle == this.podcastTitle &&
          other.podcastRSS == this.podcastRSS &&
          other.position == this.position &&
          other.duration == this.duration &&
          other.isFinished == this.isFinished &&
          other.listenedAt == this.listenedAt);
}

class ListeningHistoryCompanion extends UpdateCompanion<ListeningHistoryData> {
  final Value<int> id;
  final Value<String> audioUrl;
  final Value<String> title;
  final Value<String> description;
  final Value<String> imageUrl;
  final Value<String> podcastTitle;
  final Value<String> podcastRSS;
  final Value<int> position;
  final Value<int> duration;
  final Value<bool> isFinished;
  final Value<DateTime> listenedAt;
  const ListeningHistoryCompanion({
    this.id = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.podcastTitle = const Value.absent(),
    this.podcastRSS = const Value.absent(),
    this.position = const Value.absent(),
    this.duration = const Value.absent(),
    this.isFinished = const Value.absent(),
    this.listenedAt = const Value.absent(),
  });
  ListeningHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String audioUrl,
    required String title,
    required String description,
    required String imageUrl,
    required String podcastTitle,
    required String podcastRSS,
    this.position = const Value.absent(),
    required int duration,
    this.isFinished = const Value.absent(),
    this.listenedAt = const Value.absent(),
  })  : audioUrl = Value(audioUrl),
        title = Value(title),
        description = Value(description),
        imageUrl = Value(imageUrl),
        podcastTitle = Value(podcastTitle),
        podcastRSS = Value(podcastRSS),
        duration = Value(duration);
  static Insertable<ListeningHistoryData> custom({
    Expression<int>? id,
    Expression<String>? audioUrl,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? podcastTitle,
    Expression<String>? podcastRSS,
    Expression<int>? position,
    Expression<int>? duration,
    Expression<bool>? isFinished,
    Expression<DateTime>? listenedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (podcastTitle != null) 'podcast_title': podcastTitle,
      if (podcastRSS != null) 'podcast_r_s_s': podcastRSS,
      if (position != null) 'position': position,
      if (duration != null) 'duration': duration,
      if (isFinished != null) 'is_finished': isFinished,
      if (listenedAt != null) 'listened_at': listenedAt,
    });
  }

  ListeningHistoryCompanion copyWith(
      {Value<int>? id,
      Value<String>? audioUrl,
      Value<String>? title,
      Value<String>? description,
      Value<String>? imageUrl,
      Value<String>? podcastTitle,
      Value<String>? podcastRSS,
      Value<int>? position,
      Value<int>? duration,
      Value<bool>? isFinished,
      Value<DateTime>? listenedAt}) {
    return ListeningHistoryCompanion(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      podcastRSS: podcastRSS ?? this.podcastRSS,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isFinished: isFinished ?? this.isFinished,
      listenedAt: listenedAt ?? this.listenedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (podcastTitle.present) {
      map['podcast_title'] = Variable<String>(podcastTitle.value);
    }
    if (podcastRSS.present) {
      map['podcast_r_s_s'] = Variable<String>(podcastRSS.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (isFinished.present) {
      map['is_finished'] = Variable<bool>(isFinished.value);
    }
    if (listenedAt.present) {
      map['listened_at'] = Variable<DateTime>(listenedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryCompanion(')
          ..write('id: $id, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('podcastRSS: $podcastRSS, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('isFinished: $isFinished, ')
          ..write('listenedAt: $listenedAt')
          ..write(')'))
        .toString();
  }
}

class $OfflineEpisodesTable extends OfflineEpisodes
    with TableInfo<$OfflineEpisodesTable, OfflineEpisode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineEpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _podcastTitleMeta =
      const VerificationMeta('podcastTitle');
  @override
  late final GeneratedColumn<String> podcastTitle = GeneratedColumn<String>(
      'podcast_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _podcastRSSMeta =
      const VerificationMeta('podcastRSS');
  @override
  late final GeneratedColumn<String> podcastRSS = GeneratedColumn<String>(
      'podcast_r_s_s', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeMeta =
      const VerificationMeta('fileSize');
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
      'file_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _downloadedAtMeta =
      const VerificationMeta('downloadedAt');
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
      'downloaded_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        audioUrl,
        localPath,
        title,
        description,
        imageUrl,
        podcastTitle,
        podcastRSS,
        duration,
        fileSize,
        downloadedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_episodes';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineEpisode> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('audio_url')) {
      context.handle(_audioUrlMeta,
          audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta));
    } else if (isInserting) {
      context.missing(_audioUrlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('podcast_title')) {
      context.handle(
          _podcastTitleMeta,
          podcastTitle.isAcceptableOrUnknown(
              data['podcast_title']!, _podcastTitleMeta));
    } else if (isInserting) {
      context.missing(_podcastTitleMeta);
    }
    if (data.containsKey('podcast_r_s_s')) {
      context.handle(
          _podcastRSSMeta,
          podcastRSS.isAcceptableOrUnknown(
              data['podcast_r_s_s']!, _podcastRSSMeta));
    } else if (isInserting) {
      context.missing(_podcastRSSMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(_fileSizeMeta,
          fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta));
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
          _downloadedAtMeta,
          downloadedAt.isAcceptableOrUnknown(
              data['downloaded_at']!, _downloadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OfflineEpisode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineEpisode(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      audioUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}audio_url'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url'])!,
      podcastTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}podcast_title'])!,
      podcastRSS: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}podcast_r_s_s'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      fileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size'])!,
      downloadedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}downloaded_at'])!,
    );
  }

  @override
  $OfflineEpisodesTable createAlias(String alias) {
    return $OfflineEpisodesTable(attachedDatabase, alias);
  }
}

class OfflineEpisode extends DataClass implements Insertable<OfflineEpisode> {
  final int id;
  final String audioUrl;
  final String localPath;
  final String title;
  final String description;
  final String imageUrl;
  final String podcastTitle;
  final String podcastRSS;
  final int duration;
  final int fileSize;
  final DateTime downloadedAt;
  const OfflineEpisode(
      {required this.id,
      required this.audioUrl,
      required this.localPath,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.podcastTitle,
      required this.podcastRSS,
      required this.duration,
      required this.fileSize,
      required this.downloadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['audio_url'] = Variable<String>(audioUrl);
    map['local_path'] = Variable<String>(localPath);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['image_url'] = Variable<String>(imageUrl);
    map['podcast_title'] = Variable<String>(podcastTitle);
    map['podcast_r_s_s'] = Variable<String>(podcastRSS);
    map['duration'] = Variable<int>(duration);
    map['file_size'] = Variable<int>(fileSize);
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    return map;
  }

  OfflineEpisodesCompanion toCompanion(bool nullToAbsent) {
    return OfflineEpisodesCompanion(
      id: Value(id),
      audioUrl: Value(audioUrl),
      localPath: Value(localPath),
      title: Value(title),
      description: Value(description),
      imageUrl: Value(imageUrl),
      podcastTitle: Value(podcastTitle),
      podcastRSS: Value(podcastRSS),
      duration: Value(duration),
      fileSize: Value(fileSize),
      downloadedAt: Value(downloadedAt),
    );
  }

  factory OfflineEpisode.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineEpisode(
      id: serializer.fromJson<int>(json['id']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      localPath: serializer.fromJson<String>(json['localPath']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      podcastTitle: serializer.fromJson<String>(json['podcastTitle']),
      podcastRSS: serializer.fromJson<String>(json['podcastRSS']),
      duration: serializer.fromJson<int>(json['duration']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'localPath': serializer.toJson<String>(localPath),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'podcastTitle': serializer.toJson<String>(podcastTitle),
      'podcastRSS': serializer.toJson<String>(podcastRSS),
      'duration': serializer.toJson<int>(duration),
      'fileSize': serializer.toJson<int>(fileSize),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
    };
  }

  OfflineEpisode copyWith(
          {int? id,
          String? audioUrl,
          String? localPath,
          String? title,
          String? description,
          String? imageUrl,
          String? podcastTitle,
          String? podcastRSS,
          int? duration,
          int? fileSize,
          DateTime? downloadedAt}) =>
      OfflineEpisode(
        id: id ?? this.id,
        audioUrl: audioUrl ?? this.audioUrl,
        localPath: localPath ?? this.localPath,
        title: title ?? this.title,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        podcastTitle: podcastTitle ?? this.podcastTitle,
        podcastRSS: podcastRSS ?? this.podcastRSS,
        duration: duration ?? this.duration,
        fileSize: fileSize ?? this.fileSize,
        downloadedAt: downloadedAt ?? this.downloadedAt,
      );
  OfflineEpisode copyWithCompanion(OfflineEpisodesCompanion data) {
    return OfflineEpisode(
      id: data.id.present ? data.id.value : this.id,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      podcastTitle: data.podcastTitle.present
          ? data.podcastTitle.value
          : this.podcastTitle,
      podcastRSS:
          data.podcastRSS.present ? data.podcastRSS.value : this.podcastRSS,
      duration: data.duration.present ? data.duration.value : this.duration,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineEpisode(')
          ..write('id: $id, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localPath: $localPath, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('podcastRSS: $podcastRSS, ')
          ..write('duration: $duration, ')
          ..write('fileSize: $fileSize, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, audioUrl, localPath, title, description,
      imageUrl, podcastTitle, podcastRSS, duration, fileSize, downloadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineEpisode &&
          other.id == this.id &&
          other.audioUrl == this.audioUrl &&
          other.localPath == this.localPath &&
          other.title == this.title &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.podcastTitle == this.podcastTitle &&
          other.podcastRSS == this.podcastRSS &&
          other.duration == this.duration &&
          other.fileSize == this.fileSize &&
          other.downloadedAt == this.downloadedAt);
}

class OfflineEpisodesCompanion extends UpdateCompanion<OfflineEpisode> {
  final Value<int> id;
  final Value<String> audioUrl;
  final Value<String> localPath;
  final Value<String> title;
  final Value<String> description;
  final Value<String> imageUrl;
  final Value<String> podcastTitle;
  final Value<String> podcastRSS;
  final Value<int> duration;
  final Value<int> fileSize;
  final Value<DateTime> downloadedAt;
  const OfflineEpisodesCompanion({
    this.id = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.localPath = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.podcastTitle = const Value.absent(),
    this.podcastRSS = const Value.absent(),
    this.duration = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.downloadedAt = const Value.absent(),
  });
  OfflineEpisodesCompanion.insert({
    this.id = const Value.absent(),
    required String audioUrl,
    required String localPath,
    required String title,
    required String description,
    required String imageUrl,
    required String podcastTitle,
    required String podcastRSS,
    required int duration,
    required int fileSize,
    this.downloadedAt = const Value.absent(),
  })  : audioUrl = Value(audioUrl),
        localPath = Value(localPath),
        title = Value(title),
        description = Value(description),
        imageUrl = Value(imageUrl),
        podcastTitle = Value(podcastTitle),
        podcastRSS = Value(podcastRSS),
        duration = Value(duration),
        fileSize = Value(fileSize);
  static Insertable<OfflineEpisode> custom({
    Expression<int>? id,
    Expression<String>? audioUrl,
    Expression<String>? localPath,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? podcastTitle,
    Expression<String>? podcastRSS,
    Expression<int>? duration,
    Expression<int>? fileSize,
    Expression<DateTime>? downloadedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (localPath != null) 'local_path': localPath,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (podcastTitle != null) 'podcast_title': podcastTitle,
      if (podcastRSS != null) 'podcast_r_s_s': podcastRSS,
      if (duration != null) 'duration': duration,
      if (fileSize != null) 'file_size': fileSize,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
    });
  }

  OfflineEpisodesCompanion copyWith(
      {Value<int>? id,
      Value<String>? audioUrl,
      Value<String>? localPath,
      Value<String>? title,
      Value<String>? description,
      Value<String>? imageUrl,
      Value<String>? podcastTitle,
      Value<String>? podcastRSS,
      Value<int>? duration,
      Value<int>? fileSize,
      Value<DateTime>? downloadedAt}) {
    return OfflineEpisodesCompanion(
      id: id ?? this.id,
      audioUrl: audioUrl ?? this.audioUrl,
      localPath: localPath ?? this.localPath,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      podcastRSS: podcastRSS ?? this.podcastRSS,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (podcastTitle.present) {
      map['podcast_title'] = Variable<String>(podcastTitle.value);
    }
    if (podcastRSS.present) {
      map['podcast_r_s_s'] = Variable<String>(podcastRSS.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineEpisodesCompanion(')
          ..write('id: $id, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('localPath: $localPath, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('podcastRSS: $podcastRSS, ')
          ..write('duration: $duration, ')
          ..write('fileSize: $fileSize, ')
          ..write('downloadedAt: $downloadedAt')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final int color;
  const Tag({required this.id, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
    };
  }

  Tag copyWith({int? id, String? name, int? color}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int color,
  })  : name = Value(name),
        color = Value(color);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<int>? color}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionTagsTable extends SubscriptionTags
    with TableInfo<$SubscriptionTagsTable, SubscriptionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _subscriptionIdMeta =
      const VerificationMeta('subscriptionId');
  @override
  late final GeneratedColumn<int> subscriptionId = GeneratedColumn<int>(
      'subscription_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES podcast_subscription (id) ON DELETE CASCADE'));
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES tags (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [subscriptionId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_tags';
  @override
  VerificationContext validateIntegrity(Insertable<SubscriptionTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('subscription_id')) {
      context.handle(
          _subscriptionIdMeta,
          subscriptionId.isAcceptableOrUnknown(
              data['subscription_id']!, _subscriptionIdMeta));
    } else if (isInserting) {
      context.missing(_subscriptionIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {subscriptionId, tagId};
  @override
  SubscriptionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionTag(
      subscriptionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subscription_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $SubscriptionTagsTable createAlias(String alias) {
    return $SubscriptionTagsTable(attachedDatabase, alias);
  }
}

class SubscriptionTag extends DataClass implements Insertable<SubscriptionTag> {
  final int subscriptionId;
  final int tagId;
  const SubscriptionTag({required this.subscriptionId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['subscription_id'] = Variable<int>(subscriptionId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  SubscriptionTagsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionTagsCompanion(
      subscriptionId: Value(subscriptionId),
      tagId: Value(tagId),
    );
  }

  factory SubscriptionTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionTag(
      subscriptionId: serializer.fromJson<int>(json['subscriptionId']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'subscriptionId': serializer.toJson<int>(subscriptionId),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  SubscriptionTag copyWith({int? subscriptionId, int? tagId}) =>
      SubscriptionTag(
        subscriptionId: subscriptionId ?? this.subscriptionId,
        tagId: tagId ?? this.tagId,
      );
  SubscriptionTag copyWithCompanion(SubscriptionTagsCompanion data) {
    return SubscriptionTag(
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionTag(')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(subscriptionId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionTag &&
          other.subscriptionId == this.subscriptionId &&
          other.tagId == this.tagId);
}

class SubscriptionTagsCompanion extends UpdateCompanion<SubscriptionTag> {
  final Value<int> subscriptionId;
  final Value<int> tagId;
  final Value<int> rowid;
  const SubscriptionTagsCompanion({
    this.subscriptionId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionTagsCompanion.insert({
    required int subscriptionId,
    required int tagId,
    this.rowid = const Value.absent(),
  })  : subscriptionId = Value(subscriptionId),
        tagId = Value(tagId);
  static Insertable<SubscriptionTag> custom({
    Expression<int>? subscriptionId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionTagsCompanion copyWith(
      {Value<int>? subscriptionId, Value<int>? tagId, Value<int>? rowid}) {
    return SubscriptionTagsCompanion(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<int>(subscriptionId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionTagsCompanion(')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PoddrDatabase extends GeneratedDatabase {
  _$PoddrDatabase(QueryExecutor e) : super(e);
  $PoddrDatabaseManager get managers => $PoddrDatabaseManager(this);
  late final $PodcastSubscriptionTable podcastSubscription =
      $PodcastSubscriptionTable(this);
  late final $ListeningHistoryTable listeningHistory =
      $ListeningHistoryTable(this);
  late final $OfflineEpisodesTable offlineEpisodes =
      $OfflineEpisodesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $SubscriptionTagsTable subscriptionTags =
      $SubscriptionTagsTable(this);
  late final Index idxHistoryListenedAt = Index('idx_history_listened_at',
      'CREATE INDEX idx_history_listened_at ON listening_history (listened_at)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        podcastSubscription,
        listeningHistory,
        offlineEpisodes,
        tags,
        subscriptionTags,
        idxHistoryListenedAt
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('podcast_subscription',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subscription_tags', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tags',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subscription_tags', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$PodcastSubscriptionTableCreateCompanionBuilder
    = PodcastSubscriptionCompanion Function({
  Value<int> id,
  required String rss,
  required String title,
  required String description,
  required String author,
  required String imageUrl,
  Value<DateTime> subscribedAt,
});
typedef $$PodcastSubscriptionTableUpdateCompanionBuilder
    = PodcastSubscriptionCompanion Function({
  Value<int> id,
  Value<String> rss,
  Value<String> title,
  Value<String> description,
  Value<String> author,
  Value<String> imageUrl,
  Value<DateTime> subscribedAt,
});

final class $$PodcastSubscriptionTableReferences extends BaseReferences<
    _$PoddrDatabase, $PodcastSubscriptionTable, PodcastSubscriptionData> {
  $$PodcastSubscriptionTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubscriptionTagsTable, List<SubscriptionTag>>
      _subscriptionTagsRefsTable(_$PoddrDatabase db) =>
          MultiTypedResultKey.fromTable(db.subscriptionTags,
              aliasName: $_aliasNameGenerator(db.podcastSubscription.id,
                  db.subscriptionTags.subscriptionId));

  $$SubscriptionTagsTableProcessedTableManager get subscriptionTagsRefs {
    final manager = $$SubscriptionTagsTableTableManager(
            $_db, $_db.subscriptionTags)
        .filter((f) => f.subscriptionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subscriptionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PodcastSubscriptionTableFilterComposer
    extends Composer<_$PoddrDatabase, $PodcastSubscriptionTable> {
  $$PodcastSubscriptionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rss => $composableBuilder(
      column: $table.rss, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> subscriptionTagsRefs(
      Expression<bool> Function($$SubscriptionTagsTableFilterComposer f) f) {
    final $$SubscriptionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscriptionTags,
        getReferencedColumn: (t) => t.subscriptionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTagsTableFilterComposer(
              $db: $db,
              $table: $db.subscriptionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PodcastSubscriptionTableOrderingComposer
    extends Composer<_$PoddrDatabase, $PodcastSubscriptionTable> {
  $$PodcastSubscriptionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rss => $composableBuilder(
      column: $table.rss, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get author => $composableBuilder(
      column: $table.author, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$PodcastSubscriptionTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $PodcastSubscriptionTable> {
  $$PodcastSubscriptionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rss =>
      $composableBuilder(column: $table.rss, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get subscribedAt => $composableBuilder(
      column: $table.subscribedAt, builder: (column) => column);

  Expression<T> subscriptionTagsRefs<T extends Object>(
      Expression<T> Function($$SubscriptionTagsTableAnnotationComposer a) f) {
    final $$SubscriptionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscriptionTags,
        getReferencedColumn: (t) => t.subscriptionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.subscriptionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PodcastSubscriptionTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $PodcastSubscriptionTable,
    PodcastSubscriptionData,
    $$PodcastSubscriptionTableFilterComposer,
    $$PodcastSubscriptionTableOrderingComposer,
    $$PodcastSubscriptionTableAnnotationComposer,
    $$PodcastSubscriptionTableCreateCompanionBuilder,
    $$PodcastSubscriptionTableUpdateCompanionBuilder,
    (PodcastSubscriptionData, $$PodcastSubscriptionTableReferences),
    PodcastSubscriptionData,
    PrefetchHooks Function({bool subscriptionTagsRefs})> {
  $$PodcastSubscriptionTableTableManager(
      _$PoddrDatabase db, $PodcastSubscriptionTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastSubscriptionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastSubscriptionTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastSubscriptionTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> rss = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<DateTime> subscribedAt = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion(
            id: id,
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            subscribedAt: subscribedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rss,
            required String title,
            required String description,
            required String author,
            required String imageUrl,
            Value<DateTime> subscribedAt = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion.insert(
            id: id,
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            subscribedAt: subscribedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PodcastSubscriptionTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({subscriptionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subscriptionTagsRefs) db.subscriptionTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subscriptionTagsRefs)
                    await $_getPrefetchedData<PodcastSubscriptionData,
                            $PodcastSubscriptionTable, SubscriptionTag>(
                        currentTable: table,
                        referencedTable: $$PodcastSubscriptionTableReferences
                            ._subscriptionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PodcastSubscriptionTableReferences(db, table, p0)
                                .subscriptionTagsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subscriptionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PodcastSubscriptionTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $PodcastSubscriptionTable,
    PodcastSubscriptionData,
    $$PodcastSubscriptionTableFilterComposer,
    $$PodcastSubscriptionTableOrderingComposer,
    $$PodcastSubscriptionTableAnnotationComposer,
    $$PodcastSubscriptionTableCreateCompanionBuilder,
    $$PodcastSubscriptionTableUpdateCompanionBuilder,
    (PodcastSubscriptionData, $$PodcastSubscriptionTableReferences),
    PodcastSubscriptionData,
    PrefetchHooks Function({bool subscriptionTagsRefs})>;
typedef $$ListeningHistoryTableCreateCompanionBuilder
    = ListeningHistoryCompanion Function({
  Value<int> id,
  required String audioUrl,
  required String title,
  required String description,
  required String imageUrl,
  required String podcastTitle,
  required String podcastRSS,
  Value<int> position,
  required int duration,
  Value<bool> isFinished,
  Value<DateTime> listenedAt,
});
typedef $$ListeningHistoryTableUpdateCompanionBuilder
    = ListeningHistoryCompanion Function({
  Value<int> id,
  Value<String> audioUrl,
  Value<String> title,
  Value<String> description,
  Value<String> imageUrl,
  Value<String> podcastTitle,
  Value<String> podcastRSS,
  Value<int> position,
  Value<int> duration,
  Value<bool> isFinished,
  Value<DateTime> listenedAt,
});

class $$ListeningHistoryTableFilterComposer
    extends Composer<_$PoddrDatabase, $ListeningHistoryTable> {
  $$ListeningHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get podcastTitle => $composableBuilder(
      column: $table.podcastTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get podcastRSS => $composableBuilder(
      column: $table.podcastRSS, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFinished => $composableBuilder(
      column: $table.isFinished, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get listenedAt => $composableBuilder(
      column: $table.listenedAt, builder: (column) => ColumnFilters(column));
}

class $$ListeningHistoryTableOrderingComposer
    extends Composer<_$PoddrDatabase, $ListeningHistoryTable> {
  $$ListeningHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get podcastTitle => $composableBuilder(
      column: $table.podcastTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get podcastRSS => $composableBuilder(
      column: $table.podcastRSS, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFinished => $composableBuilder(
      column: $table.isFinished, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get listenedAt => $composableBuilder(
      column: $table.listenedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListeningHistoryTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $ListeningHistoryTable> {
  $$ListeningHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get podcastTitle => $composableBuilder(
      column: $table.podcastTitle, builder: (column) => column);

  GeneratedColumn<String> get podcastRSS => $composableBuilder(
      column: $table.podcastRSS, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<bool> get isFinished => $composableBuilder(
      column: $table.isFinished, builder: (column) => column);

  GeneratedColumn<DateTime> get listenedAt => $composableBuilder(
      column: $table.listenedAt, builder: (column) => column);
}

class $$ListeningHistoryTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $ListeningHistoryTable,
    ListeningHistoryData,
    $$ListeningHistoryTableFilterComposer,
    $$ListeningHistoryTableOrderingComposer,
    $$ListeningHistoryTableAnnotationComposer,
    $$ListeningHistoryTableCreateCompanionBuilder,
    $$ListeningHistoryTableUpdateCompanionBuilder,
    (
      ListeningHistoryData,
      BaseReferences<_$PoddrDatabase, $ListeningHistoryTable,
          ListeningHistoryData>
    ),
    ListeningHistoryData,
    PrefetchHooks Function()> {
  $$ListeningHistoryTableTableManager(
      _$PoddrDatabase db, $ListeningHistoryTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeningHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeningHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeningHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> audioUrl = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> podcastTitle = const Value.absent(),
            Value<String> podcastRSS = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<bool> isFinished = const Value.absent(),
            Value<DateTime> listenedAt = const Value.absent(),
          }) =>
              ListeningHistoryCompanion(
            id: id,
            audioUrl: audioUrl,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            position: position,
            duration: duration,
            isFinished: isFinished,
            listenedAt: listenedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String audioUrl,
            required String title,
            required String description,
            required String imageUrl,
            required String podcastTitle,
            required String podcastRSS,
            Value<int> position = const Value.absent(),
            required int duration,
            Value<bool> isFinished = const Value.absent(),
            Value<DateTime> listenedAt = const Value.absent(),
          }) =>
              ListeningHistoryCompanion.insert(
            id: id,
            audioUrl: audioUrl,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            position: position,
            duration: duration,
            isFinished: isFinished,
            listenedAt: listenedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListeningHistoryTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $ListeningHistoryTable,
    ListeningHistoryData,
    $$ListeningHistoryTableFilterComposer,
    $$ListeningHistoryTableOrderingComposer,
    $$ListeningHistoryTableAnnotationComposer,
    $$ListeningHistoryTableCreateCompanionBuilder,
    $$ListeningHistoryTableUpdateCompanionBuilder,
    (
      ListeningHistoryData,
      BaseReferences<_$PoddrDatabase, $ListeningHistoryTable,
          ListeningHistoryData>
    ),
    ListeningHistoryData,
    PrefetchHooks Function()>;
typedef $$OfflineEpisodesTableCreateCompanionBuilder = OfflineEpisodesCompanion
    Function({
  Value<int> id,
  required String audioUrl,
  required String localPath,
  required String title,
  required String description,
  required String imageUrl,
  required String podcastTitle,
  required String podcastRSS,
  required int duration,
  required int fileSize,
  Value<DateTime> downloadedAt,
});
typedef $$OfflineEpisodesTableUpdateCompanionBuilder = OfflineEpisodesCompanion
    Function({
  Value<int> id,
  Value<String> audioUrl,
  Value<String> localPath,
  Value<String> title,
  Value<String> description,
  Value<String> imageUrl,
  Value<String> podcastTitle,
  Value<String> podcastRSS,
  Value<int> duration,
  Value<int> fileSize,
  Value<DateTime> downloadedAt,
});

class $$OfflineEpisodesTableFilterComposer
    extends Composer<_$PoddrDatabase, $OfflineEpisodesTable> {
  $$OfflineEpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get podcastTitle => $composableBuilder(
      column: $table.podcastTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get podcastRSS => $composableBuilder(
      column: $table.podcastRSS, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => ColumnFilters(column));
}

class $$OfflineEpisodesTableOrderingComposer
    extends Composer<_$PoddrDatabase, $OfflineEpisodesTable> {
  $$OfflineEpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get audioUrl => $composableBuilder(
      column: $table.audioUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get podcastTitle => $composableBuilder(
      column: $table.podcastTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get podcastRSS => $composableBuilder(
      column: $table.podcastRSS, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get duration => $composableBuilder(
      column: $table.duration, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSize => $composableBuilder(
      column: $table.fileSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$OfflineEpisodesTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $OfflineEpisodesTable> {
  $$OfflineEpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get podcastTitle => $composableBuilder(
      column: $table.podcastTitle, builder: (column) => column);

  GeneratedColumn<String> get podcastRSS => $composableBuilder(
      column: $table.podcastRSS, builder: (column) => column);

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
      column: $table.downloadedAt, builder: (column) => column);
}

class $$OfflineEpisodesTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $OfflineEpisodesTable,
    OfflineEpisode,
    $$OfflineEpisodesTableFilterComposer,
    $$OfflineEpisodesTableOrderingComposer,
    $$OfflineEpisodesTableAnnotationComposer,
    $$OfflineEpisodesTableCreateCompanionBuilder,
    $$OfflineEpisodesTableUpdateCompanionBuilder,
    (
      OfflineEpisode,
      BaseReferences<_$PoddrDatabase, $OfflineEpisodesTable, OfflineEpisode>
    ),
    OfflineEpisode,
    PrefetchHooks Function()> {
  $$OfflineEpisodesTableTableManager(
      _$PoddrDatabase db, $OfflineEpisodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineEpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineEpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineEpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> audioUrl = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<String> podcastTitle = const Value.absent(),
            Value<String> podcastRSS = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<int> fileSize = const Value.absent(),
            Value<DateTime> downloadedAt = const Value.absent(),
          }) =>
              OfflineEpisodesCompanion(
            id: id,
            audioUrl: audioUrl,
            localPath: localPath,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            duration: duration,
            fileSize: fileSize,
            downloadedAt: downloadedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String audioUrl,
            required String localPath,
            required String title,
            required String description,
            required String imageUrl,
            required String podcastTitle,
            required String podcastRSS,
            required int duration,
            required int fileSize,
            Value<DateTime> downloadedAt = const Value.absent(),
          }) =>
              OfflineEpisodesCompanion.insert(
            id: id,
            audioUrl: audioUrl,
            localPath: localPath,
            title: title,
            description: description,
            imageUrl: imageUrl,
            podcastTitle: podcastTitle,
            podcastRSS: podcastRSS,
            duration: duration,
            fileSize: fileSize,
            downloadedAt: downloadedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineEpisodesTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $OfflineEpisodesTable,
    OfflineEpisode,
    $$OfflineEpisodesTableFilterComposer,
    $$OfflineEpisodesTableOrderingComposer,
    $$OfflineEpisodesTableAnnotationComposer,
    $$OfflineEpisodesTableCreateCompanionBuilder,
    $$OfflineEpisodesTableUpdateCompanionBuilder,
    (
      OfflineEpisode,
      BaseReferences<_$PoddrDatabase, $OfflineEpisodesTable, OfflineEpisode>
    ),
    OfflineEpisode,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String name,
  required int color,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> color,
});

final class $$TagsTableReferences
    extends BaseReferences<_$PoddrDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubscriptionTagsTable, List<SubscriptionTag>>
      _subscriptionTagsRefsTable(_$PoddrDatabase db) =>
          MultiTypedResultKey.fromTable(db.subscriptionTags,
              aliasName:
                  $_aliasNameGenerator(db.tags.id, db.subscriptionTags.tagId));

  $$SubscriptionTagsTableProcessedTableManager get subscriptionTagsRefs {
    final manager =
        $$SubscriptionTagsTableTableManager($_db, $_db.subscriptionTags)
            .filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subscriptionTagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagsTableFilterComposer extends Composer<_$PoddrDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  Expression<bool> subscriptionTagsRefs(
      Expression<bool> Function($$SubscriptionTagsTableFilterComposer f) f) {
    final $$SubscriptionTagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscriptionTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTagsTableFilterComposer(
              $db: $db,
              $table: $db.subscriptionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends Composer<_$PoddrDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> subscriptionTagsRefs<T extends Object>(
      Expression<T> Function($$SubscriptionTagsTableAnnotationComposer a) f) {
    final $$SubscriptionTagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.subscriptionTags,
        getReferencedColumn: (t) => t.tagId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubscriptionTagsTableAnnotationComposer(
              $db: $db,
              $table: $db.subscriptionTags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TagsTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool subscriptionTagsRefs})> {
  $$TagsTableTableManager(_$PoddrDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            color: color,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int color,
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            color: color,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TagsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({subscriptionTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subscriptionTagsRefs) db.subscriptionTags
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subscriptionTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, SubscriptionTag>(
                        currentTable: table,
                        referencedTable: $$TagsTableReferences
                            ._subscriptionTagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TagsTableReferences(db, table, p0)
                                .subscriptionTagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.tagId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, $$TagsTableReferences),
    Tag,
    PrefetchHooks Function({bool subscriptionTagsRefs})>;
typedef $$SubscriptionTagsTableCreateCompanionBuilder
    = SubscriptionTagsCompanion Function({
  required int subscriptionId,
  required int tagId,
  Value<int> rowid,
});
typedef $$SubscriptionTagsTableUpdateCompanionBuilder
    = SubscriptionTagsCompanion Function({
  Value<int> subscriptionId,
  Value<int> tagId,
  Value<int> rowid,
});

final class $$SubscriptionTagsTableReferences extends BaseReferences<
    _$PoddrDatabase, $SubscriptionTagsTable, SubscriptionTag> {
  $$SubscriptionTagsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PodcastSubscriptionTable _subscriptionIdTable(_$PoddrDatabase db) =>
      db.podcastSubscription.createAlias($_aliasNameGenerator(
          db.subscriptionTags.subscriptionId, db.podcastSubscription.id));

  $$PodcastSubscriptionTableProcessedTableManager get subscriptionId {
    final $_column = $_itemColumn<int>('subscription_id')!;

    final manager =
        $$PodcastSubscriptionTableTableManager($_db, $_db.podcastSubscription)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriptionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagsTable _tagIdTable(_$PoddrDatabase db) => db.tags
      .createAlias($_aliasNameGenerator(db.subscriptionTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagsTableTableManager($_db, $_db.tags)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SubscriptionTagsTableFilterComposer
    extends Composer<_$PoddrDatabase, $SubscriptionTagsTable> {
  $$SubscriptionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PodcastSubscriptionTableFilterComposer get subscriptionId {
    final $$PodcastSubscriptionTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subscriptionId,
        referencedTable: $db.podcastSubscription,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PodcastSubscriptionTableFilterComposer(
              $db: $db,
              $table: $db.podcastSubscription,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableFilterComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionTagsTableOrderingComposer
    extends Composer<_$PoddrDatabase, $SubscriptionTagsTable> {
  $$SubscriptionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PodcastSubscriptionTableOrderingComposer get subscriptionId {
    final $$PodcastSubscriptionTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.subscriptionId,
            referencedTable: $db.podcastSubscription,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PodcastSubscriptionTableOrderingComposer(
                  $db: $db,
                  $table: $db.podcastSubscription,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableOrderingComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionTagsTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $SubscriptionTagsTable> {
  $$SubscriptionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PodcastSubscriptionTableAnnotationComposer get subscriptionId {
    final $$PodcastSubscriptionTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.subscriptionId,
            referencedTable: $db.podcastSubscription,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PodcastSubscriptionTableAnnotationComposer(
                  $db: $db,
                  $table: $db.podcastSubscription,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.tagId,
        referencedTable: $db.tags,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TagsTableAnnotationComposer(
              $db: $db,
              $table: $db.tags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionTagsTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $SubscriptionTagsTable,
    SubscriptionTag,
    $$SubscriptionTagsTableFilterComposer,
    $$SubscriptionTagsTableOrderingComposer,
    $$SubscriptionTagsTableAnnotationComposer,
    $$SubscriptionTagsTableCreateCompanionBuilder,
    $$SubscriptionTagsTableUpdateCompanionBuilder,
    (SubscriptionTag, $$SubscriptionTagsTableReferences),
    SubscriptionTag,
    PrefetchHooks Function({bool subscriptionId, bool tagId})> {
  $$SubscriptionTagsTableTableManager(
      _$PoddrDatabase db, $SubscriptionTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> subscriptionId = const Value.absent(),
            Value<int> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionTagsCompanion(
            subscriptionId: subscriptionId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int subscriptionId,
            required int tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionTagsCompanion.insert(
            subscriptionId: subscriptionId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubscriptionTagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({subscriptionId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (subscriptionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subscriptionId,
                    referencedTable: $$SubscriptionTagsTableReferences
                        ._subscriptionIdTable(db),
                    referencedColumn: $$SubscriptionTagsTableReferences
                        ._subscriptionIdTable(db)
                        .id,
                  ) as T;
                }
                if (tagId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.tagId,
                    referencedTable:
                        $$SubscriptionTagsTableReferences._tagIdTable(db),
                    referencedColumn:
                        $$SubscriptionTagsTableReferences._tagIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SubscriptionTagsTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $SubscriptionTagsTable,
    SubscriptionTag,
    $$SubscriptionTagsTableFilterComposer,
    $$SubscriptionTagsTableOrderingComposer,
    $$SubscriptionTagsTableAnnotationComposer,
    $$SubscriptionTagsTableCreateCompanionBuilder,
    $$SubscriptionTagsTableUpdateCompanionBuilder,
    (SubscriptionTag, $$SubscriptionTagsTableReferences),
    SubscriptionTag,
    PrefetchHooks Function({bool subscriptionId, bool tagId})>;

class $PoddrDatabaseManager {
  final _$PoddrDatabase _db;
  $PoddrDatabaseManager(this._db);
  $$PodcastSubscriptionTableTableManager get podcastSubscription =>
      $$PodcastSubscriptionTableTableManager(_db, _db.podcastSubscription);
  $$ListeningHistoryTableTableManager get listeningHistory =>
      $$ListeningHistoryTableTableManager(_db, _db.listeningHistory);
  $$OfflineEpisodesTableTableManager get offlineEpisodes =>
      $$OfflineEpisodesTableTableManager(_db, _db.offlineEpisodes);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$SubscriptionTagsTableTableManager get subscriptionTags =>
      $$SubscriptionTagsTableTableManager(_db, _db.subscriptionTags);
}
