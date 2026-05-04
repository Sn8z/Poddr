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
  static const VerificationMeta _brokenMeta = const VerificationMeta('broken');
  @override
  late final GeneratedColumn<bool> broken = GeneratedColumn<bool>(
      'broken', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("broken" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, rss, title, description, author, imageUrl, subscribedAt, broken];
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
    if (data.containsKey('broken')) {
      context.handle(_brokenMeta,
          broken.isAcceptableOrUnknown(data['broken']!, _brokenMeta));
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
      broken: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}broken'])!,
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
  final bool broken;
  const PodcastSubscriptionData(
      {required this.id,
      required this.rss,
      required this.title,
      required this.description,
      required this.author,
      required this.imageUrl,
      required this.subscribedAt,
      required this.broken});
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
    map['broken'] = Variable<bool>(broken);
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
      broken: Value(broken),
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
      broken: serializer.fromJson<bool>(json['broken']),
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
      'broken': serializer.toJson<bool>(broken),
    };
  }

  PodcastSubscriptionData copyWith(
          {int? id,
          String? rss,
          String? title,
          String? description,
          String? author,
          String? imageUrl,
          DateTime? subscribedAt,
          bool? broken}) =>
      PodcastSubscriptionData(
        id: id ?? this.id,
        rss: rss ?? this.rss,
        title: title ?? this.title,
        description: description ?? this.description,
        author: author ?? this.author,
        imageUrl: imageUrl ?? this.imageUrl,
        subscribedAt: subscribedAt ?? this.subscribedAt,
        broken: broken ?? this.broken,
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
      broken: data.broken.present ? data.broken.value : this.broken,
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
          ..write('subscribedAt: $subscribedAt, ')
          ..write('broken: $broken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, rss, title, description, author, imageUrl, subscribedAt, broken);
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
          other.subscribedAt == this.subscribedAt &&
          other.broken == this.broken);
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
  final Value<bool> broken;
  const PodcastSubscriptionCompanion({
    this.id = const Value.absent(),
    this.rss = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.broken = const Value.absent(),
  });
  PodcastSubscriptionCompanion.insert({
    this.id = const Value.absent(),
    required String rss,
    required String title,
    required String description,
    required String author,
    required String imageUrl,
    this.subscribedAt = const Value.absent(),
    this.broken = const Value.absent(),
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
    Expression<bool>? broken,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rss != null) 'rss': rss,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (broken != null) 'broken': broken,
    });
  }

  PodcastSubscriptionCompanion copyWith(
      {Value<int>? id,
      Value<String>? rss,
      Value<String>? title,
      Value<String>? description,
      Value<String>? author,
      Value<String>? imageUrl,
      Value<DateTime>? subscribedAt,
      Value<bool>? broken}) {
    return PodcastSubscriptionCompanion(
      id: id ?? this.id,
      rss: rss ?? this.rss,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      broken: broken ?? this.broken,
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
    if (broken.present) {
      map['broken'] = Variable<bool>(broken.value);
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
          ..write('subscribedAt: $subscribedAt, ')
          ..write('broken: $broken')
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
  static const VerificationMeta _videoUrlMeta =
      const VerificationMeta('videoUrl');
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
      'video_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        listenedAt,
        videoUrl
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
    if (data.containsKey('video_url')) {
      context.handle(_videoUrlMeta,
          videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta));
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
      videoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_url']),
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
  final String? videoUrl;
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
      required this.listenedAt,
      this.videoUrl});
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
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
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
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
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
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
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
      'videoUrl': serializer.toJson<String?>(videoUrl),
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
          DateTime? listenedAt,
          Value<String?> videoUrl = const Value.absent()}) =>
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
        videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
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
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
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
          ..write('listenedAt: $listenedAt, ')
          ..write('videoUrl: $videoUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      listenedAt,
      videoUrl);
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
          other.listenedAt == this.listenedAt &&
          other.videoUrl == this.videoUrl);
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
  final Value<String?> videoUrl;
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
    this.videoUrl = const Value.absent(),
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
    this.videoUrl = const Value.absent(),
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
    Expression<String>? videoUrl,
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
      if (videoUrl != null) 'video_url': videoUrl,
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
      Value<DateTime>? listenedAt,
      Value<String?>? videoUrl}) {
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
      videoUrl: videoUrl ?? this.videoUrl,
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
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
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
          ..write('listenedAt: $listenedAt, ')
          ..write('videoUrl: $videoUrl')
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
  static const VerificationMeta _publicationDateMeta =
      const VerificationMeta('publicationDate');
  @override
  late final GeneratedColumn<DateTime> publicationDate =
      GeneratedColumn<DateTime>('publication_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _videoUrlMeta =
      const VerificationMeta('videoUrl');
  @override
  late final GeneratedColumn<String> videoUrl = GeneratedColumn<String>(
      'video_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _videoLocalPathMeta =
      const VerificationMeta('videoLocalPath');
  @override
  late final GeneratedColumn<String> videoLocalPath = GeneratedColumn<String>(
      'video_local_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _videoFileSizeMeta =
      const VerificationMeta('videoFileSize');
  @override
  late final GeneratedColumn<int> videoFileSize = GeneratedColumn<int>(
      'video_file_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
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
        downloadedAt,
        publicationDate,
        videoUrl,
        videoLocalPath,
        videoFileSize
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
    if (data.containsKey('publication_date')) {
      context.handle(
          _publicationDateMeta,
          publicationDate.isAcceptableOrUnknown(
              data['publication_date']!, _publicationDateMeta));
    }
    if (data.containsKey('video_url')) {
      context.handle(_videoUrlMeta,
          videoUrl.isAcceptableOrUnknown(data['video_url']!, _videoUrlMeta));
    }
    if (data.containsKey('video_local_path')) {
      context.handle(
          _videoLocalPathMeta,
          videoLocalPath.isAcceptableOrUnknown(
              data['video_local_path']!, _videoLocalPathMeta));
    }
    if (data.containsKey('video_file_size')) {
      context.handle(
          _videoFileSizeMeta,
          videoFileSize.isAcceptableOrUnknown(
              data['video_file_size']!, _videoFileSizeMeta));
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
      publicationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}publication_date']),
      videoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}video_url']),
      videoLocalPath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}video_local_path']),
      videoFileSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}video_file_size']),
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
  final DateTime? publicationDate;
  final String? videoUrl;
  final String? videoLocalPath;
  final int? videoFileSize;
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
      required this.downloadedAt,
      this.publicationDate,
      this.videoUrl,
      this.videoLocalPath,
      this.videoFileSize});
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
    if (!nullToAbsent || publicationDate != null) {
      map['publication_date'] = Variable<DateTime>(publicationDate);
    }
    if (!nullToAbsent || videoUrl != null) {
      map['video_url'] = Variable<String>(videoUrl);
    }
    if (!nullToAbsent || videoLocalPath != null) {
      map['video_local_path'] = Variable<String>(videoLocalPath);
    }
    if (!nullToAbsent || videoFileSize != null) {
      map['video_file_size'] = Variable<int>(videoFileSize);
    }
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
      publicationDate: publicationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(publicationDate),
      videoUrl: videoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(videoUrl),
      videoLocalPath: videoLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(videoLocalPath),
      videoFileSize: videoFileSize == null && nullToAbsent
          ? const Value.absent()
          : Value(videoFileSize),
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
      publicationDate: serializer.fromJson<DateTime?>(json['publicationDate']),
      videoUrl: serializer.fromJson<String?>(json['videoUrl']),
      videoLocalPath: serializer.fromJson<String?>(json['videoLocalPath']),
      videoFileSize: serializer.fromJson<int?>(json['videoFileSize']),
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
      'publicationDate': serializer.toJson<DateTime?>(publicationDate),
      'videoUrl': serializer.toJson<String?>(videoUrl),
      'videoLocalPath': serializer.toJson<String?>(videoLocalPath),
      'videoFileSize': serializer.toJson<int?>(videoFileSize),
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
          DateTime? downloadedAt,
          Value<DateTime?> publicationDate = const Value.absent(),
          Value<String?> videoUrl = const Value.absent(),
          Value<String?> videoLocalPath = const Value.absent(),
          Value<int?> videoFileSize = const Value.absent()}) =>
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
        publicationDate: publicationDate.present
            ? publicationDate.value
            : this.publicationDate,
        videoUrl: videoUrl.present ? videoUrl.value : this.videoUrl,
        videoLocalPath:
            videoLocalPath.present ? videoLocalPath.value : this.videoLocalPath,
        videoFileSize:
            videoFileSize.present ? videoFileSize.value : this.videoFileSize,
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
      publicationDate: data.publicationDate.present
          ? data.publicationDate.value
          : this.publicationDate,
      videoUrl: data.videoUrl.present ? data.videoUrl.value : this.videoUrl,
      videoLocalPath: data.videoLocalPath.present
          ? data.videoLocalPath.value
          : this.videoLocalPath,
      videoFileSize: data.videoFileSize.present
          ? data.videoFileSize.value
          : this.videoFileSize,
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
          ..write('downloadedAt: $downloadedAt, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('videoLocalPath: $videoLocalPath, ')
          ..write('videoFileSize: $videoFileSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
      downloadedAt,
      publicationDate,
      videoUrl,
      videoLocalPath,
      videoFileSize);
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
          other.downloadedAt == this.downloadedAt &&
          other.publicationDate == this.publicationDate &&
          other.videoUrl == this.videoUrl &&
          other.videoLocalPath == this.videoLocalPath &&
          other.videoFileSize == this.videoFileSize);
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
  final Value<DateTime?> publicationDate;
  final Value<String?> videoUrl;
  final Value<String?> videoLocalPath;
  final Value<int?> videoFileSize;
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
    this.publicationDate = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.videoLocalPath = const Value.absent(),
    this.videoFileSize = const Value.absent(),
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
    this.publicationDate = const Value.absent(),
    this.videoUrl = const Value.absent(),
    this.videoLocalPath = const Value.absent(),
    this.videoFileSize = const Value.absent(),
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
    Expression<DateTime>? publicationDate,
    Expression<String>? videoUrl,
    Expression<String>? videoLocalPath,
    Expression<int>? videoFileSize,
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
      if (publicationDate != null) 'publication_date': publicationDate,
      if (videoUrl != null) 'video_url': videoUrl,
      if (videoLocalPath != null) 'video_local_path': videoLocalPath,
      if (videoFileSize != null) 'video_file_size': videoFileSize,
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
      Value<DateTime>? downloadedAt,
      Value<DateTime?>? publicationDate,
      Value<String?>? videoUrl,
      Value<String?>? videoLocalPath,
      Value<int?>? videoFileSize}) {
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
      publicationDate: publicationDate ?? this.publicationDate,
      videoUrl: videoUrl ?? this.videoUrl,
      videoLocalPath: videoLocalPath ?? this.videoLocalPath,
      videoFileSize: videoFileSize ?? this.videoFileSize,
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
    if (publicationDate.present) {
      map['publication_date'] = Variable<DateTime>(publicationDate.value);
    }
    if (videoUrl.present) {
      map['video_url'] = Variable<String>(videoUrl.value);
    }
    if (videoLocalPath.present) {
      map['video_local_path'] = Variable<String>(videoLocalPath.value);
    }
    if (videoFileSize.present) {
      map['video_file_size'] = Variable<int>(videoFileSize.value);
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
          ..write('downloadedAt: $downloadedAt, ')
          ..write('publicationDate: $publicationDate, ')
          ..write('videoUrl: $videoUrl, ')
          ..write('videoLocalPath: $videoLocalPath, ')
          ..write('videoFileSize: $videoFileSize')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(Insertable<Collection> instance,
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
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String name;
  final int color;
  const Collection({required this.id, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
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

  Collection copyWith({int? id, String? name, int? color}) => Collection(
        id: id ?? this.id,
        name: name ?? this.name,
        color: color ?? this.color,
      );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
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
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int color,
  })  : name = Value(name),
        color = Value(color);
  static Insertable<Collection> custom({
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

  CollectionsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<int>? color}) {
    return CollectionsCompanion(
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
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionCollectionsTable extends SubscriptionCollections
    with TableInfo<$SubscriptionCollectionsTable, SubscriptionCollection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionCollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _subscriptionIdMeta =
      const VerificationMeta('subscriptionId');
  @override
  late final GeneratedColumn<int> subscriptionId = GeneratedColumn<int>(
      'subscription_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES podcast_subscription (id) ON DELETE CASCADE'));
  static const VerificationMeta _collectionIdMeta =
      const VerificationMeta('collectionId');
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
      'collection_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES collections (id) ON DELETE CASCADE'));
  @override
  List<GeneratedColumn> get $columns => [subscriptionId, collectionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_collections';
  @override
  VerificationContext validateIntegrity(
      Insertable<SubscriptionCollection> instance,
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
    if (data.containsKey('collection_id')) {
      context.handle(
          _collectionIdMeta,
          collectionId.isAcceptableOrUnknown(
              data['collection_id']!, _collectionIdMeta));
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {subscriptionId, collectionId};
  @override
  SubscriptionCollection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionCollection(
      subscriptionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subscription_id'])!,
      collectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}collection_id'])!,
    );
  }

  @override
  $SubscriptionCollectionsTable createAlias(String alias) {
    return $SubscriptionCollectionsTable(attachedDatabase, alias);
  }
}

class SubscriptionCollection extends DataClass
    implements Insertable<SubscriptionCollection> {
  final int subscriptionId;
  final int collectionId;
  const SubscriptionCollection(
      {required this.subscriptionId, required this.collectionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['subscription_id'] = Variable<int>(subscriptionId);
    map['collection_id'] = Variable<int>(collectionId);
    return map;
  }

  SubscriptionCollectionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionCollectionsCompanion(
      subscriptionId: Value(subscriptionId),
      collectionId: Value(collectionId),
    );
  }

  factory SubscriptionCollection.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionCollection(
      subscriptionId: serializer.fromJson<int>(json['subscriptionId']),
      collectionId: serializer.fromJson<int>(json['collectionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'subscriptionId': serializer.toJson<int>(subscriptionId),
      'collectionId': serializer.toJson<int>(collectionId),
    };
  }

  SubscriptionCollection copyWith({int? subscriptionId, int? collectionId}) =>
      SubscriptionCollection(
        subscriptionId: subscriptionId ?? this.subscriptionId,
        collectionId: collectionId ?? this.collectionId,
      );
  SubscriptionCollection copyWithCompanion(
      SubscriptionCollectionsCompanion data) {
    return SubscriptionCollection(
      subscriptionId: data.subscriptionId.present
          ? data.subscriptionId.value
          : this.subscriptionId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionCollection(')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('collectionId: $collectionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(subscriptionId, collectionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionCollection &&
          other.subscriptionId == this.subscriptionId &&
          other.collectionId == this.collectionId);
}

class SubscriptionCollectionsCompanion
    extends UpdateCompanion<SubscriptionCollection> {
  final Value<int> subscriptionId;
  final Value<int> collectionId;
  final Value<int> rowid;
  const SubscriptionCollectionsCompanion({
    this.subscriptionId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionCollectionsCompanion.insert({
    required int subscriptionId,
    required int collectionId,
    this.rowid = const Value.absent(),
  })  : subscriptionId = Value(subscriptionId),
        collectionId = Value(collectionId);
  static Insertable<SubscriptionCollection> custom({
    Expression<int>? subscriptionId,
    Expression<int>? collectionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (subscriptionId != null) 'subscription_id': subscriptionId,
      if (collectionId != null) 'collection_id': collectionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionCollectionsCompanion copyWith(
      {Value<int>? subscriptionId,
      Value<int>? collectionId,
      Value<int>? rowid}) {
    return SubscriptionCollectionsCompanion(
      subscriptionId: subscriptionId ?? this.subscriptionId,
      collectionId: collectionId ?? this.collectionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (subscriptionId.present) {
      map['subscription_id'] = Variable<int>(subscriptionId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionCollectionsCompanion(')
          ..write('subscriptionId: $subscriptionId, ')
          ..write('collectionId: $collectionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingEpisodeActionsTable extends PendingEpisodeActions
    with TableInfo<$PendingEpisodeActionsTable, PendingEpisodeAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingEpisodeActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _podcastRssMeta =
      const VerificationMeta('podcastRss');
  @override
  late final GeneratedColumn<String> podcastRss = GeneratedColumn<String>(
      'podcast_rss', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _episodeUrlMeta =
      const VerificationMeta('episodeUrl');
  @override
  late final GeneratedColumn<String> episodeUrl = GeneratedColumn<String>(
      'episode_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, podcastRss, episodeUrl, action, position, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_episode_actions';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingEpisodeAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('podcast_rss')) {
      context.handle(
          _podcastRssMeta,
          podcastRss.isAcceptableOrUnknown(
              data['podcast_rss']!, _podcastRssMeta));
    } else if (isInserting) {
      context.missing(_podcastRssMeta);
    }
    if (data.containsKey('episode_url')) {
      context.handle(
          _episodeUrlMeta,
          episodeUrl.isAcceptableOrUnknown(
              data['episode_url']!, _episodeUrlMeta));
    } else if (isInserting) {
      context.missing(_episodeUrlMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {episodeUrl, action},
      ];
  @override
  PendingEpisodeAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingEpisodeAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      podcastRss: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}podcast_rss'])!,
      episodeUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}episode_url'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $PendingEpisodeActionsTable createAlias(String alias) {
    return $PendingEpisodeActionsTable(attachedDatabase, alias);
  }
}

class PendingEpisodeAction extends DataClass
    implements Insertable<PendingEpisodeAction> {
  final int id;
  final String podcastRss;
  final String episodeUrl;
  final String action;
  final int position;
  final DateTime timestamp;
  const PendingEpisodeAction(
      {required this.id,
      required this.podcastRss,
      required this.episodeUrl,
      required this.action,
      required this.position,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['podcast_rss'] = Variable<String>(podcastRss);
    map['episode_url'] = Variable<String>(episodeUrl);
    map['action'] = Variable<String>(action);
    map['position'] = Variable<int>(position);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  PendingEpisodeActionsCompanion toCompanion(bool nullToAbsent) {
    return PendingEpisodeActionsCompanion(
      id: Value(id),
      podcastRss: Value(podcastRss),
      episodeUrl: Value(episodeUrl),
      action: Value(action),
      position: Value(position),
      timestamp: Value(timestamp),
    );
  }

  factory PendingEpisodeAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingEpisodeAction(
      id: serializer.fromJson<int>(json['id']),
      podcastRss: serializer.fromJson<String>(json['podcastRss']),
      episodeUrl: serializer.fromJson<String>(json['episodeUrl']),
      action: serializer.fromJson<String>(json['action']),
      position: serializer.fromJson<int>(json['position']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'podcastRss': serializer.toJson<String>(podcastRss),
      'episodeUrl': serializer.toJson<String>(episodeUrl),
      'action': serializer.toJson<String>(action),
      'position': serializer.toJson<int>(position),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  PendingEpisodeAction copyWith(
          {int? id,
          String? podcastRss,
          String? episodeUrl,
          String? action,
          int? position,
          DateTime? timestamp}) =>
      PendingEpisodeAction(
        id: id ?? this.id,
        podcastRss: podcastRss ?? this.podcastRss,
        episodeUrl: episodeUrl ?? this.episodeUrl,
        action: action ?? this.action,
        position: position ?? this.position,
        timestamp: timestamp ?? this.timestamp,
      );
  PendingEpisodeAction copyWithCompanion(PendingEpisodeActionsCompanion data) {
    return PendingEpisodeAction(
      id: data.id.present ? data.id.value : this.id,
      podcastRss:
          data.podcastRss.present ? data.podcastRss.value : this.podcastRss,
      episodeUrl:
          data.episodeUrl.present ? data.episodeUrl.value : this.episodeUrl,
      action: data.action.present ? data.action.value : this.action,
      position: data.position.present ? data.position.value : this.position,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingEpisodeAction(')
          ..write('id: $id, ')
          ..write('podcastRss: $podcastRss, ')
          ..write('episodeUrl: $episodeUrl, ')
          ..write('action: $action, ')
          ..write('position: $position, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, podcastRss, episodeUrl, action, position, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingEpisodeAction &&
          other.id == this.id &&
          other.podcastRss == this.podcastRss &&
          other.episodeUrl == this.episodeUrl &&
          other.action == this.action &&
          other.position == this.position &&
          other.timestamp == this.timestamp);
}

class PendingEpisodeActionsCompanion
    extends UpdateCompanion<PendingEpisodeAction> {
  final Value<int> id;
  final Value<String> podcastRss;
  final Value<String> episodeUrl;
  final Value<String> action;
  final Value<int> position;
  final Value<DateTime> timestamp;
  const PendingEpisodeActionsCompanion({
    this.id = const Value.absent(),
    this.podcastRss = const Value.absent(),
    this.episodeUrl = const Value.absent(),
    this.action = const Value.absent(),
    this.position = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  PendingEpisodeActionsCompanion.insert({
    this.id = const Value.absent(),
    required String podcastRss,
    required String episodeUrl,
    required String action,
    this.position = const Value.absent(),
    required DateTime timestamp,
  })  : podcastRss = Value(podcastRss),
        episodeUrl = Value(episodeUrl),
        action = Value(action),
        timestamp = Value(timestamp);
  static Insertable<PendingEpisodeAction> custom({
    Expression<int>? id,
    Expression<String>? podcastRss,
    Expression<String>? episodeUrl,
    Expression<String>? action,
    Expression<int>? position,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastRss != null) 'podcast_rss': podcastRss,
      if (episodeUrl != null) 'episode_url': episodeUrl,
      if (action != null) 'action': action,
      if (position != null) 'position': position,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  PendingEpisodeActionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? podcastRss,
      Value<String>? episodeUrl,
      Value<String>? action,
      Value<int>? position,
      Value<DateTime>? timestamp}) {
    return PendingEpisodeActionsCompanion(
      id: id ?? this.id,
      podcastRss: podcastRss ?? this.podcastRss,
      episodeUrl: episodeUrl ?? this.episodeUrl,
      action: action ?? this.action,
      position: position ?? this.position,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (podcastRss.present) {
      map['podcast_rss'] = Variable<String>(podcastRss.value);
    }
    if (episodeUrl.present) {
      map['episode_url'] = Variable<String>(episodeUrl.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingEpisodeActionsCompanion(')
          ..write('id: $id, ')
          ..write('podcastRss: $podcastRss, ')
          ..write('episodeUrl: $episodeUrl, ')
          ..write('action: $action, ')
          ..write('position: $position, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $PendingSubscriptionActionsTable extends PendingSubscriptionActions
    with
        TableInfo<$PendingSubscriptionActionsTable, PendingSubscriptionAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingSubscriptionActionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, rss, action, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_subscription_actions';
  @override
  VerificationContext validateIntegrity(
      Insertable<PendingSubscriptionAction> instance,
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
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingSubscriptionAction map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingSubscriptionAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      rss: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rss'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $PendingSubscriptionActionsTable createAlias(String alias) {
    return $PendingSubscriptionActionsTable(attachedDatabase, alias);
  }
}

class PendingSubscriptionAction extends DataClass
    implements Insertable<PendingSubscriptionAction> {
  final int id;
  final String rss;
  final String action;
  final DateTime timestamp;
  const PendingSubscriptionAction(
      {required this.id,
      required this.rss,
      required this.action,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['rss'] = Variable<String>(rss);
    map['action'] = Variable<String>(action);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  PendingSubscriptionActionsCompanion toCompanion(bool nullToAbsent) {
    return PendingSubscriptionActionsCompanion(
      id: Value(id),
      rss: Value(rss),
      action: Value(action),
      timestamp: Value(timestamp),
    );
  }

  factory PendingSubscriptionAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingSubscriptionAction(
      id: serializer.fromJson<int>(json['id']),
      rss: serializer.fromJson<String>(json['rss']),
      action: serializer.fromJson<String>(json['action']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rss': serializer.toJson<String>(rss),
      'action': serializer.toJson<String>(action),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  PendingSubscriptionAction copyWith(
          {int? id, String? rss, String? action, DateTime? timestamp}) =>
      PendingSubscriptionAction(
        id: id ?? this.id,
        rss: rss ?? this.rss,
        action: action ?? this.action,
        timestamp: timestamp ?? this.timestamp,
      );
  PendingSubscriptionAction copyWithCompanion(
      PendingSubscriptionActionsCompanion data) {
    return PendingSubscriptionAction(
      id: data.id.present ? data.id.value : this.id,
      rss: data.rss.present ? data.rss.value : this.rss,
      action: data.action.present ? data.action.value : this.action,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingSubscriptionAction(')
          ..write('id: $id, ')
          ..write('rss: $rss, ')
          ..write('action: $action, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rss, action, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingSubscriptionAction &&
          other.id == this.id &&
          other.rss == this.rss &&
          other.action == this.action &&
          other.timestamp == this.timestamp);
}

class PendingSubscriptionActionsCompanion
    extends UpdateCompanion<PendingSubscriptionAction> {
  final Value<int> id;
  final Value<String> rss;
  final Value<String> action;
  final Value<DateTime> timestamp;
  const PendingSubscriptionActionsCompanion({
    this.id = const Value.absent(),
    this.rss = const Value.absent(),
    this.action = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  PendingSubscriptionActionsCompanion.insert({
    this.id = const Value.absent(),
    required String rss,
    required String action,
    required DateTime timestamp,
  })  : rss = Value(rss),
        action = Value(action),
        timestamp = Value(timestamp);
  static Insertable<PendingSubscriptionAction> custom({
    Expression<int>? id,
    Expression<String>? rss,
    Expression<String>? action,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rss != null) 'rss': rss,
      if (action != null) 'action': action,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  PendingSubscriptionActionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? rss,
      Value<String>? action,
      Value<DateTime>? timestamp}) {
    return PendingSubscriptionActionsCompanion(
      id: id ?? this.id,
      rss: rss ?? this.rss,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
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
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingSubscriptionActionsCompanion(')
          ..write('id: $id, ')
          ..write('rss: $rss, ')
          ..write('action: $action, ')
          ..write('timestamp: $timestamp')
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
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $SubscriptionCollectionsTable subscriptionCollections =
      $SubscriptionCollectionsTable(this);
  late final $PendingEpisodeActionsTable pendingEpisodeActions =
      $PendingEpisodeActionsTable(this);
  late final $PendingSubscriptionActionsTable pendingSubscriptionActions =
      $PendingSubscriptionActionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        podcastSubscription,
        listeningHistory,
        offlineEpisodes,
        collections,
        subscriptionCollections,
        pendingEpisodeActions,
        pendingSubscriptionActions
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('podcast_subscription',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subscription_collections', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('collections',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('subscription_collections', kind: UpdateKind.delete),
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
  Value<bool> broken,
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
  Value<bool> broken,
});

final class $$PodcastSubscriptionTableReferences extends BaseReferences<
    _$PoddrDatabase, $PodcastSubscriptionTable, PodcastSubscriptionData> {
  $$PodcastSubscriptionTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubscriptionCollectionsTable,
      List<SubscriptionCollection>> _subscriptionCollectionsRefsTable(
          _$PoddrDatabase db) =>
      MultiTypedResultKey.fromTable(db.subscriptionCollections,
          aliasName: $_aliasNameGenerator(db.podcastSubscription.id,
              db.subscriptionCollections.subscriptionId));

  $$SubscriptionCollectionsTableProcessedTableManager
      get subscriptionCollectionsRefs {
    final manager = $$SubscriptionCollectionsTableTableManager(
            $_db, $_db.subscriptionCollections)
        .filter((f) => f.subscriptionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subscriptionCollectionsRefsTable($_db));
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

  ColumnFilters<bool> get broken => $composableBuilder(
      column: $table.broken, builder: (column) => ColumnFilters(column));

  Expression<bool> subscriptionCollectionsRefs(
      Expression<bool> Function($$SubscriptionCollectionsTableFilterComposer f)
          f) {
    final $$SubscriptionCollectionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subscriptionCollections,
            getReferencedColumn: (t) => t.subscriptionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubscriptionCollectionsTableFilterComposer(
                  $db: $db,
                  $table: $db.subscriptionCollections,
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

  ColumnOrderings<bool> get broken => $composableBuilder(
      column: $table.broken, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<bool> get broken =>
      $composableBuilder(column: $table.broken, builder: (column) => column);

  Expression<T> subscriptionCollectionsRefs<T extends Object>(
      Expression<T> Function($$SubscriptionCollectionsTableAnnotationComposer a)
          f) {
    final $$SubscriptionCollectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subscriptionCollections,
            getReferencedColumn: (t) => t.subscriptionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubscriptionCollectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subscriptionCollections,
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
    PrefetchHooks Function({bool subscriptionCollectionsRefs})> {
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
            Value<bool> broken = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion(
            id: id,
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            subscribedAt: subscribedAt,
            broken: broken,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rss,
            required String title,
            required String description,
            required String author,
            required String imageUrl,
            Value<DateTime> subscribedAt = const Value.absent(),
            Value<bool> broken = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion.insert(
            id: id,
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            subscribedAt: subscribedAt,
            broken: broken,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PodcastSubscriptionTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({subscriptionCollectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subscriptionCollectionsRefs) db.subscriptionCollections
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subscriptionCollectionsRefs)
                    await $_getPrefetchedData<PodcastSubscriptionData,
                            $PodcastSubscriptionTable, SubscriptionCollection>(
                        currentTable: table,
                        referencedTable: $$PodcastSubscriptionTableReferences
                            ._subscriptionCollectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PodcastSubscriptionTableReferences(db, table, p0)
                                .subscriptionCollectionsRefs,
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
    PrefetchHooks Function({bool subscriptionCollectionsRefs})>;
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
  Value<String?> videoUrl,
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
  Value<String?> videoUrl,
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

  ColumnFilters<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);
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
            Value<String?> videoUrl = const Value.absent(),
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
            videoUrl: videoUrl,
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
            Value<String?> videoUrl = const Value.absent(),
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
            videoUrl: videoUrl,
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
  Value<DateTime?> publicationDate,
  Value<String?> videoUrl,
  Value<String?> videoLocalPath,
  Value<int?> videoFileSize,
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
  Value<DateTime?> publicationDate,
  Value<String?> videoUrl,
  Value<String?> videoLocalPath,
  Value<int?> videoFileSize,
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

  ColumnFilters<DateTime> get publicationDate => $composableBuilder(
      column: $table.publicationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get videoLocalPath => $composableBuilder(
      column: $table.videoLocalPath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get videoFileSize => $composableBuilder(
      column: $table.videoFileSize, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<DateTime> get publicationDate => $composableBuilder(
      column: $table.publicationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoUrl => $composableBuilder(
      column: $table.videoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get videoLocalPath => $composableBuilder(
      column: $table.videoLocalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get videoFileSize => $composableBuilder(
      column: $table.videoFileSize,
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

  GeneratedColumn<DateTime> get publicationDate => $composableBuilder(
      column: $table.publicationDate, builder: (column) => column);

  GeneratedColumn<String> get videoUrl =>
      $composableBuilder(column: $table.videoUrl, builder: (column) => column);

  GeneratedColumn<String> get videoLocalPath => $composableBuilder(
      column: $table.videoLocalPath, builder: (column) => column);

  GeneratedColumn<int> get videoFileSize => $composableBuilder(
      column: $table.videoFileSize, builder: (column) => column);
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
            Value<DateTime?> publicationDate = const Value.absent(),
            Value<String?> videoUrl = const Value.absent(),
            Value<String?> videoLocalPath = const Value.absent(),
            Value<int?> videoFileSize = const Value.absent(),
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
            publicationDate: publicationDate,
            videoUrl: videoUrl,
            videoLocalPath: videoLocalPath,
            videoFileSize: videoFileSize,
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
            Value<DateTime?> publicationDate = const Value.absent(),
            Value<String?> videoUrl = const Value.absent(),
            Value<String?> videoLocalPath = const Value.absent(),
            Value<int?> videoFileSize = const Value.absent(),
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
            publicationDate: publicationDate,
            videoUrl: videoUrl,
            videoLocalPath: videoLocalPath,
            videoFileSize: videoFileSize,
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
typedef $$CollectionsTableCreateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  required String name,
  required int color,
});
typedef $$CollectionsTableUpdateCompanionBuilder = CollectionsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> color,
});

final class $$CollectionsTableReferences
    extends BaseReferences<_$PoddrDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubscriptionCollectionsTable,
      List<SubscriptionCollection>> _subscriptionCollectionsRefsTable(
          _$PoddrDatabase db) =>
      MultiTypedResultKey.fromTable(db.subscriptionCollections,
          aliasName: $_aliasNameGenerator(
              db.collections.id, db.subscriptionCollections.collectionId));

  $$SubscriptionCollectionsTableProcessedTableManager
      get subscriptionCollectionsRefs {
    final manager = $$SubscriptionCollectionsTableTableManager(
            $_db, $_db.subscriptionCollections)
        .filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_subscriptionCollectionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$PoddrDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
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

  Expression<bool> subscriptionCollectionsRefs(
      Expression<bool> Function($$SubscriptionCollectionsTableFilterComposer f)
          f) {
    final $$SubscriptionCollectionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subscriptionCollections,
            getReferencedColumn: (t) => t.collectionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubscriptionCollectionsTableFilterComposer(
                  $db: $db,
                  $table: $db.subscriptionCollections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$PoddrDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
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

class $$CollectionsTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
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

  Expression<T> subscriptionCollectionsRefs<T extends Object>(
      Expression<T> Function($$SubscriptionCollectionsTableAnnotationComposer a)
          f) {
    final $$SubscriptionCollectionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.subscriptionCollections,
            getReferencedColumn: (t) => t.collectionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SubscriptionCollectionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.subscriptionCollections,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CollectionsTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, $$CollectionsTableReferences),
    Collection,
    PrefetchHooks Function({bool subscriptionCollectionsRefs})> {
  $$CollectionsTableTableManager(_$PoddrDatabase db, $CollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> color = const Value.absent(),
          }) =>
              CollectionsCompanion(
            id: id,
            name: name,
            color: color,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int color,
          }) =>
              CollectionsCompanion.insert(
            id: id,
            name: name,
            color: color,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({subscriptionCollectionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (subscriptionCollectionsRefs) db.subscriptionCollections
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subscriptionCollectionsRefs)
                    await $_getPrefetchedData<Collection, $CollectionsTable,
                            SubscriptionCollection>(
                        currentTable: table,
                        referencedTable: $$CollectionsTableReferences
                            ._subscriptionCollectionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CollectionsTableReferences(db, table, p0)
                                .subscriptionCollectionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.collectionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CollectionsTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $CollectionsTable,
    Collection,
    $$CollectionsTableFilterComposer,
    $$CollectionsTableOrderingComposer,
    $$CollectionsTableAnnotationComposer,
    $$CollectionsTableCreateCompanionBuilder,
    $$CollectionsTableUpdateCompanionBuilder,
    (Collection, $$CollectionsTableReferences),
    Collection,
    PrefetchHooks Function({bool subscriptionCollectionsRefs})>;
typedef $$SubscriptionCollectionsTableCreateCompanionBuilder
    = SubscriptionCollectionsCompanion Function({
  required int subscriptionId,
  required int collectionId,
  Value<int> rowid,
});
typedef $$SubscriptionCollectionsTableUpdateCompanionBuilder
    = SubscriptionCollectionsCompanion Function({
  Value<int> subscriptionId,
  Value<int> collectionId,
  Value<int> rowid,
});

final class $$SubscriptionCollectionsTableReferences extends BaseReferences<
    _$PoddrDatabase, $SubscriptionCollectionsTable, SubscriptionCollection> {
  $$SubscriptionCollectionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PodcastSubscriptionTable _subscriptionIdTable(_$PoddrDatabase db) =>
      db.podcastSubscription.createAlias($_aliasNameGenerator(
          db.subscriptionCollections.subscriptionId,
          db.podcastSubscription.id));

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

  static $CollectionsTable _collectionIdTable(_$PoddrDatabase db) =>
      db.collections.createAlias($_aliasNameGenerator(
          db.subscriptionCollections.collectionId, db.collections.id));

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager($_db, $_db.collections)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SubscriptionCollectionsTableFilterComposer
    extends Composer<_$PoddrDatabase, $SubscriptionCollectionsTable> {
  $$SubscriptionCollectionsTableFilterComposer({
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

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableFilterComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionCollectionsTableOrderingComposer
    extends Composer<_$PoddrDatabase, $SubscriptionCollectionsTable> {
  $$SubscriptionCollectionsTableOrderingComposer({
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

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableOrderingComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionCollectionsTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $SubscriptionCollectionsTable> {
  $$SubscriptionCollectionsTableAnnotationComposer({
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

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.collectionId,
        referencedTable: $db.collections,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CollectionsTableAnnotationComposer(
              $db: $db,
              $table: $db.collections,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SubscriptionCollectionsTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $SubscriptionCollectionsTable,
    SubscriptionCollection,
    $$SubscriptionCollectionsTableFilterComposer,
    $$SubscriptionCollectionsTableOrderingComposer,
    $$SubscriptionCollectionsTableAnnotationComposer,
    $$SubscriptionCollectionsTableCreateCompanionBuilder,
    $$SubscriptionCollectionsTableUpdateCompanionBuilder,
    (SubscriptionCollection, $$SubscriptionCollectionsTableReferences),
    SubscriptionCollection,
    PrefetchHooks Function({bool subscriptionId, bool collectionId})> {
  $$SubscriptionCollectionsTableTableManager(
      _$PoddrDatabase db, $SubscriptionCollectionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionCollectionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionCollectionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionCollectionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> subscriptionId = const Value.absent(),
            Value<int> collectionId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionCollectionsCompanion(
            subscriptionId: subscriptionId,
            collectionId: collectionId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int subscriptionId,
            required int collectionId,
            Value<int> rowid = const Value.absent(),
          }) =>
              SubscriptionCollectionsCompanion.insert(
            subscriptionId: subscriptionId,
            collectionId: collectionId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SubscriptionCollectionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {subscriptionId = false, collectionId = false}) {
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
                    referencedTable: $$SubscriptionCollectionsTableReferences
                        ._subscriptionIdTable(db),
                    referencedColumn: $$SubscriptionCollectionsTableReferences
                        ._subscriptionIdTable(db)
                        .id,
                  ) as T;
                }
                if (collectionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.collectionId,
                    referencedTable: $$SubscriptionCollectionsTableReferences
                        ._collectionIdTable(db),
                    referencedColumn: $$SubscriptionCollectionsTableReferences
                        ._collectionIdTable(db)
                        .id,
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

typedef $$SubscriptionCollectionsTableProcessedTableManager
    = ProcessedTableManager<
        _$PoddrDatabase,
        $SubscriptionCollectionsTable,
        SubscriptionCollection,
        $$SubscriptionCollectionsTableFilterComposer,
        $$SubscriptionCollectionsTableOrderingComposer,
        $$SubscriptionCollectionsTableAnnotationComposer,
        $$SubscriptionCollectionsTableCreateCompanionBuilder,
        $$SubscriptionCollectionsTableUpdateCompanionBuilder,
        (SubscriptionCollection, $$SubscriptionCollectionsTableReferences),
        SubscriptionCollection,
        PrefetchHooks Function({bool subscriptionId, bool collectionId})>;
typedef $$PendingEpisodeActionsTableCreateCompanionBuilder
    = PendingEpisodeActionsCompanion Function({
  Value<int> id,
  required String podcastRss,
  required String episodeUrl,
  required String action,
  Value<int> position,
  required DateTime timestamp,
});
typedef $$PendingEpisodeActionsTableUpdateCompanionBuilder
    = PendingEpisodeActionsCompanion Function({
  Value<int> id,
  Value<String> podcastRss,
  Value<String> episodeUrl,
  Value<String> action,
  Value<int> position,
  Value<DateTime> timestamp,
});

class $$PendingEpisodeActionsTableFilterComposer
    extends Composer<_$PoddrDatabase, $PendingEpisodeActionsTable> {
  $$PendingEpisodeActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get podcastRss => $composableBuilder(
      column: $table.podcastRss, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get episodeUrl => $composableBuilder(
      column: $table.episodeUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$PendingEpisodeActionsTableOrderingComposer
    extends Composer<_$PoddrDatabase, $PendingEpisodeActionsTable> {
  $$PendingEpisodeActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get podcastRss => $composableBuilder(
      column: $table.podcastRss, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get episodeUrl => $composableBuilder(
      column: $table.episodeUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$PendingEpisodeActionsTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $PendingEpisodeActionsTable> {
  $$PendingEpisodeActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get podcastRss => $composableBuilder(
      column: $table.podcastRss, builder: (column) => column);

  GeneratedColumn<String> get episodeUrl => $composableBuilder(
      column: $table.episodeUrl, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$PendingEpisodeActionsTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $PendingEpisodeActionsTable,
    PendingEpisodeAction,
    $$PendingEpisodeActionsTableFilterComposer,
    $$PendingEpisodeActionsTableOrderingComposer,
    $$PendingEpisodeActionsTableAnnotationComposer,
    $$PendingEpisodeActionsTableCreateCompanionBuilder,
    $$PendingEpisodeActionsTableUpdateCompanionBuilder,
    (
      PendingEpisodeAction,
      BaseReferences<_$PoddrDatabase, $PendingEpisodeActionsTable,
          PendingEpisodeAction>
    ),
    PendingEpisodeAction,
    PrefetchHooks Function()> {
  $$PendingEpisodeActionsTableTableManager(
      _$PoddrDatabase db, $PendingEpisodeActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingEpisodeActionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingEpisodeActionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingEpisodeActionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> podcastRss = const Value.absent(),
            Value<String> episodeUrl = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              PendingEpisodeActionsCompanion(
            id: id,
            podcastRss: podcastRss,
            episodeUrl: episodeUrl,
            action: action,
            position: position,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String podcastRss,
            required String episodeUrl,
            required String action,
            Value<int> position = const Value.absent(),
            required DateTime timestamp,
          }) =>
              PendingEpisodeActionsCompanion.insert(
            id: id,
            podcastRss: podcastRss,
            episodeUrl: episodeUrl,
            action: action,
            position: position,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingEpisodeActionsTableProcessedTableManager
    = ProcessedTableManager<
        _$PoddrDatabase,
        $PendingEpisodeActionsTable,
        PendingEpisodeAction,
        $$PendingEpisodeActionsTableFilterComposer,
        $$PendingEpisodeActionsTableOrderingComposer,
        $$PendingEpisodeActionsTableAnnotationComposer,
        $$PendingEpisodeActionsTableCreateCompanionBuilder,
        $$PendingEpisodeActionsTableUpdateCompanionBuilder,
        (
          PendingEpisodeAction,
          BaseReferences<_$PoddrDatabase, $PendingEpisodeActionsTable,
              PendingEpisodeAction>
        ),
        PendingEpisodeAction,
        PrefetchHooks Function()>;
typedef $$PendingSubscriptionActionsTableCreateCompanionBuilder
    = PendingSubscriptionActionsCompanion Function({
  Value<int> id,
  required String rss,
  required String action,
  required DateTime timestamp,
});
typedef $$PendingSubscriptionActionsTableUpdateCompanionBuilder
    = PendingSubscriptionActionsCompanion Function({
  Value<int> id,
  Value<String> rss,
  Value<String> action,
  Value<DateTime> timestamp,
});

class $$PendingSubscriptionActionsTableFilterComposer
    extends Composer<_$PoddrDatabase, $PendingSubscriptionActionsTable> {
  $$PendingSubscriptionActionsTableFilterComposer({
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

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$PendingSubscriptionActionsTableOrderingComposer
    extends Composer<_$PoddrDatabase, $PendingSubscriptionActionsTable> {
  $$PendingSubscriptionActionsTableOrderingComposer({
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

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$PendingSubscriptionActionsTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $PendingSubscriptionActionsTable> {
  $$PendingSubscriptionActionsTableAnnotationComposer({
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

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$PendingSubscriptionActionsTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $PendingSubscriptionActionsTable,
    PendingSubscriptionAction,
    $$PendingSubscriptionActionsTableFilterComposer,
    $$PendingSubscriptionActionsTableOrderingComposer,
    $$PendingSubscriptionActionsTableAnnotationComposer,
    $$PendingSubscriptionActionsTableCreateCompanionBuilder,
    $$PendingSubscriptionActionsTableUpdateCompanionBuilder,
    (
      PendingSubscriptionAction,
      BaseReferences<_$PoddrDatabase, $PendingSubscriptionActionsTable,
          PendingSubscriptionAction>
    ),
    PendingSubscriptionAction,
    PrefetchHooks Function()> {
  $$PendingSubscriptionActionsTableTableManager(
      _$PoddrDatabase db, $PendingSubscriptionActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingSubscriptionActionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingSubscriptionActionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingSubscriptionActionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> rss = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              PendingSubscriptionActionsCompanion(
            id: id,
            rss: rss,
            action: action,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rss,
            required String action,
            required DateTime timestamp,
          }) =>
              PendingSubscriptionActionsCompanion.insert(
            id: id,
            rss: rss,
            action: action,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PendingSubscriptionActionsTableProcessedTableManager
    = ProcessedTableManager<
        _$PoddrDatabase,
        $PendingSubscriptionActionsTable,
        PendingSubscriptionAction,
        $$PendingSubscriptionActionsTableFilterComposer,
        $$PendingSubscriptionActionsTableOrderingComposer,
        $$PendingSubscriptionActionsTableAnnotationComposer,
        $$PendingSubscriptionActionsTableCreateCompanionBuilder,
        $$PendingSubscriptionActionsTableUpdateCompanionBuilder,
        (
          PendingSubscriptionAction,
          BaseReferences<_$PoddrDatabase, $PendingSubscriptionActionsTable,
              PendingSubscriptionAction>
        ),
        PendingSubscriptionAction,
        PrefetchHooks Function()>;

class $PoddrDatabaseManager {
  final _$PoddrDatabase _db;
  $PoddrDatabaseManager(this._db);
  $$PodcastSubscriptionTableTableManager get podcastSubscription =>
      $$PodcastSubscriptionTableTableManager(_db, _db.podcastSubscription);
  $$ListeningHistoryTableTableManager get listeningHistory =>
      $$ListeningHistoryTableTableManager(_db, _db.listeningHistory);
  $$OfflineEpisodesTableTableManager get offlineEpisodes =>
      $$OfflineEpisodesTableTableManager(_db, _db.offlineEpisodes);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$SubscriptionCollectionsTableTableManager get subscriptionCollections =>
      $$SubscriptionCollectionsTableTableManager(
          _db, _db.subscriptionCollections);
  $$PendingEpisodeActionsTableTableManager get pendingEpisodeActions =>
      $$PendingEpisodeActionsTableTableManager(_db, _db.pendingEpisodeActions);
  $$PendingSubscriptionActionsTableTableManager
      get pendingSubscriptionActions =>
          $$PendingSubscriptionActionsTableTableManager(
              _db, _db.pendingSubscriptionActions);
}
