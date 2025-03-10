// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PodcastSubscriptionTable extends PodcastSubscription
    with TableInfo<$PodcastSubscriptionTable, PodcastSubscriptionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastSubscriptionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rssMeta = const VerificationMeta('rss');
  @override
  late final GeneratedColumn<String> rss = GeneratedColumn<String>(
      'rss', aliasedName, false,
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
      [rss, title, description, author, imageUrl, subscribedAt];
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
  Set<GeneratedColumn> get $primaryKey => {rss};
  @override
  PodcastSubscriptionData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastSubscriptionData(
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
  final String rss;
  final String title;
  final String description;
  final String author;
  final String imageUrl;
  final DateTime subscribedAt;
  const PodcastSubscriptionData(
      {required this.rss,
      required this.title,
      required this.description,
      required this.author,
      required this.imageUrl,
      required this.subscribedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
      'rss': serializer.toJson<String>(rss),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'author': serializer.toJson<String>(author),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'subscribedAt': serializer.toJson<DateTime>(subscribedAt),
    };
  }

  PodcastSubscriptionData copyWith(
          {String? rss,
          String? title,
          String? description,
          String? author,
          String? imageUrl,
          DateTime? subscribedAt}) =>
      PodcastSubscriptionData(
        rss: rss ?? this.rss,
        title: title ?? this.title,
        description: description ?? this.description,
        author: author ?? this.author,
        imageUrl: imageUrl ?? this.imageUrl,
        subscribedAt: subscribedAt ?? this.subscribedAt,
      );
  PodcastSubscriptionData copyWithCompanion(PodcastSubscriptionCompanion data) {
    return PodcastSubscriptionData(
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
      Object.hash(rss, title, description, author, imageUrl, subscribedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastSubscriptionData &&
          other.rss == this.rss &&
          other.title == this.title &&
          other.description == this.description &&
          other.author == this.author &&
          other.imageUrl == this.imageUrl &&
          other.subscribedAt == this.subscribedAt);
}

class PodcastSubscriptionCompanion
    extends UpdateCompanion<PodcastSubscriptionData> {
  final Value<String> rss;
  final Value<String> title;
  final Value<String> description;
  final Value<String> author;
  final Value<String> imageUrl;
  final Value<DateTime> subscribedAt;
  final Value<int> rowid;
  const PodcastSubscriptionCompanion({
    this.rss = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PodcastSubscriptionCompanion.insert({
    required String rss,
    required String title,
    required String description,
    required String author,
    required String imageUrl,
    this.subscribedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : rss = Value(rss),
        title = Value(title),
        description = Value(description),
        author = Value(author),
        imageUrl = Value(imageUrl);
  static Insertable<PodcastSubscriptionData> custom({
    Expression<String>? rss,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? imageUrl,
    Expression<DateTime>? subscribedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (rss != null) 'rss': rss,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PodcastSubscriptionCompanion copyWith(
      {Value<String>? rss,
      Value<String>? title,
      Value<String>? description,
      Value<String>? author,
      Value<String>? imageUrl,
      Value<DateTime>? subscribedAt,
      Value<int>? rowid}) {
    return PodcastSubscriptionCompanion(
      rss: rss ?? this.rss,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastSubscriptionCompanion(')
          ..write('rss: $rss, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('author: $author, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _audioUrlMeta =
      const VerificationMeta('audioUrl');
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
      'audio_url', aliasedName, false,
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
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
    } else if (isInserting) {
      context.missing(_positionMeta);
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
  Set<GeneratedColumn> get $primaryKey => {audioUrl};
  @override
  ListeningHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListeningHistoryData(
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
      {required this.audioUrl,
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
          {String? audioUrl,
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
  int get hashCode => Object.hash(audioUrl, title, description, imageUrl,
      podcastTitle, podcastRSS, position, duration, isFinished, listenedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListeningHistoryData &&
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
  final Value<int> rowid;
  const ListeningHistoryCompanion({
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
    this.rowid = const Value.absent(),
  });
  ListeningHistoryCompanion.insert({
    required String audioUrl,
    required String title,
    required String description,
    required String imageUrl,
    required String podcastTitle,
    required String podcastRSS,
    required int position,
    required int duration,
    this.isFinished = const Value.absent(),
    this.listenedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : audioUrl = Value(audioUrl),
        title = Value(title),
        description = Value(description),
        imageUrl = Value(imageUrl),
        podcastTitle = Value(podcastTitle),
        podcastRSS = Value(podcastRSS),
        position = Value(position),
        duration = Value(duration);
  static Insertable<ListeningHistoryData> custom({
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
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
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
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListeningHistoryCompanion copyWith(
      {Value<String>? audioUrl,
      Value<String>? title,
      Value<String>? description,
      Value<String>? imageUrl,
      Value<String>? podcastTitle,
      Value<String>? podcastRSS,
      Value<int>? position,
      Value<int>? duration,
      Value<bool>? isFinished,
      Value<DateTime>? listenedAt,
      Value<int>? rowid}) {
    return ListeningHistoryCompanion(
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeningHistoryCompanion(')
          ..write('audioUrl: $audioUrl, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('podcastRSS: $podcastRSS, ')
          ..write('position: $position, ')
          ..write('duration: $duration, ')
          ..write('isFinished: $isFinished, ')
          ..write('listenedAt: $listenedAt, ')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [podcastSubscription, listeningHistory];
}

typedef $$PodcastSubscriptionTableCreateCompanionBuilder
    = PodcastSubscriptionCompanion Function({
  required String rss,
  required String title,
  required String description,
  required String author,
  required String imageUrl,
  Value<DateTime> subscribedAt,
  Value<int> rowid,
});
typedef $$PodcastSubscriptionTableUpdateCompanionBuilder
    = PodcastSubscriptionCompanion Function({
  Value<String> rss,
  Value<String> title,
  Value<String> description,
  Value<String> author,
  Value<String> imageUrl,
  Value<DateTime> subscribedAt,
  Value<int> rowid,
});

class $$PodcastSubscriptionTableFilterComposer
    extends Composer<_$PoddrDatabase, $PodcastSubscriptionTable> {
  $$PodcastSubscriptionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
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
    (
      PodcastSubscriptionData,
      BaseReferences<_$PoddrDatabase, $PodcastSubscriptionTable,
          PodcastSubscriptionData>
    ),
    PodcastSubscriptionData,
    PrefetchHooks Function()> {
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
            Value<String> rss = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> author = const Value.absent(),
            Value<String> imageUrl = const Value.absent(),
            Value<DateTime> subscribedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion(
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            subscribedAt: subscribedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String rss,
            required String title,
            required String description,
            required String author,
            required String imageUrl,
            Value<DateTime> subscribedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion.insert(
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            subscribedAt: subscribedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
    (
      PodcastSubscriptionData,
      BaseReferences<_$PoddrDatabase, $PodcastSubscriptionTable,
          PodcastSubscriptionData>
    ),
    PodcastSubscriptionData,
    PrefetchHooks Function()>;
typedef $$ListeningHistoryTableCreateCompanionBuilder
    = ListeningHistoryCompanion Function({
  required String audioUrl,
  required String title,
  required String description,
  required String imageUrl,
  required String podcastTitle,
  required String podcastRSS,
  required int position,
  required int duration,
  Value<bool> isFinished,
  Value<DateTime> listenedAt,
  Value<int> rowid,
});
typedef $$ListeningHistoryTableUpdateCompanionBuilder
    = ListeningHistoryCompanion Function({
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
  Value<int> rowid,
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
            Value<int> rowid = const Value.absent(),
          }) =>
              ListeningHistoryCompanion(
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
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String audioUrl,
            required String title,
            required String description,
            required String imageUrl,
            required String podcastTitle,
            required String podcastRSS,
            required int position,
            required int duration,
            Value<bool> isFinished = const Value.absent(),
            Value<DateTime> listenedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListeningHistoryCompanion.insert(
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
            rowid: rowid,
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

class $PoddrDatabaseManager {
  final _$PoddrDatabase _db;
  $PoddrDatabaseManager(this._db);
  $$PodcastSubscriptionTableTableManager get podcastSubscription =>
      $$PodcastSubscriptionTableTableManager(_db, _db.podcastSubscription);
  $$ListeningHistoryTableTableManager get listeningHistory =>
      $$ListeningHistoryTableTableManager(_db, _db.listeningHistory);
}
