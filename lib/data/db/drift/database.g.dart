// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shouldSyncMeta =
      const VerificationMeta('shouldSync');
  @override
  late final GeneratedColumn<bool> shouldSync = GeneratedColumn<bool>(
      'should_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("should_sync" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, name, shouldSync];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileData> instance,
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
    if (data.containsKey('should_sync')) {
      context.handle(
          _shouldSyncMeta,
          shouldSync.isAcceptableOrUnknown(
              data['should_sync']!, _shouldSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shouldSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}should_sync'])!,
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final int id;
  final String name;
  final bool shouldSync;
  const ProfileData(
      {required this.id, required this.name, required this.shouldSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['should_sync'] = Variable<bool>(shouldSync);
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      name: Value(name),
      shouldSync: Value(shouldSync),
    );
  }

  factory ProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shouldSync: serializer.fromJson<bool>(json['shouldSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'shouldSync': serializer.toJson<bool>(shouldSync),
    };
  }

  ProfileData copyWith({int? id, String? name, bool? shouldSync}) =>
      ProfileData(
        id: id ?? this.id,
        name: name ?? this.name,
        shouldSync: shouldSync ?? this.shouldSync,
      );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shouldSync:
          data.shouldSync.present ? data.shouldSync.value : this.shouldSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shouldSync: $shouldSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, shouldSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.shouldSync == this.shouldSync);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> shouldSync;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shouldSync = const Value.absent(),
  });
  ProfileCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.shouldSync = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? shouldSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shouldSync != null) 'should_sync': shouldSync,
    });
  }

  ProfileCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<bool>? shouldSync}) {
    return ProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shouldSync: shouldSync ?? this.shouldSync,
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
    if (shouldSync.present) {
      map['should_sync'] = Variable<bool>(shouldSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shouldSync: $shouldSync')
          ..write(')'))
        .toString();
  }
}

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
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile (id)'));
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
      [id, rss, title, description, author, imageUrl, profileId, subscribedAt];
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
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
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
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
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
  final int profileId;
  final DateTime subscribedAt;
  const PodcastSubscriptionData(
      {required this.id,
      required this.rss,
      required this.title,
      required this.description,
      required this.author,
      required this.imageUrl,
      required this.profileId,
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
    map['profile_id'] = Variable<int>(profileId);
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
      profileId: Value(profileId),
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
      profileId: serializer.fromJson<int>(json['profileId']),
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
      'profileId': serializer.toJson<int>(profileId),
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
          int? profileId,
          DateTime? subscribedAt}) =>
      PodcastSubscriptionData(
        id: id ?? this.id,
        rss: rss ?? this.rss,
        title: title ?? this.title,
        description: description ?? this.description,
        author: author ?? this.author,
        imageUrl: imageUrl ?? this.imageUrl,
        profileId: profileId ?? this.profileId,
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
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
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
          ..write('profileId: $profileId, ')
          ..write('subscribedAt: $subscribedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, rss, title, description, author, imageUrl, profileId, subscribedAt);
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
          other.profileId == this.profileId &&
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
  final Value<int> profileId;
  final Value<DateTime> subscribedAt;
  const PodcastSubscriptionCompanion({
    this.id = const Value.absent(),
    this.rss = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.author = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.profileId = const Value.absent(),
    this.subscribedAt = const Value.absent(),
  });
  PodcastSubscriptionCompanion.insert({
    this.id = const Value.absent(),
    required String rss,
    required String title,
    required String description,
    required String author,
    required String imageUrl,
    required int profileId,
    this.subscribedAt = const Value.absent(),
  })  : rss = Value(rss),
        title = Value(title),
        description = Value(description),
        author = Value(author),
        imageUrl = Value(imageUrl),
        profileId = Value(profileId);
  static Insertable<PodcastSubscriptionData> custom({
    Expression<int>? id,
    Expression<String>? rss,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? author,
    Expression<String>? imageUrl,
    Expression<int>? profileId,
    Expression<DateTime>? subscribedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rss != null) 'rss': rss,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (author != null) 'author': author,
      if (imageUrl != null) 'image_url': imageUrl,
      if (profileId != null) 'profile_id': profileId,
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
      Value<int>? profileId,
      Value<DateTime>? subscribedAt}) {
    return PodcastSubscriptionCompanion(
      id: id ?? this.id,
      rss: rss ?? this.rss,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      profileId: profileId ?? this.profileId,
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
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
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
          ..write('profileId: $profileId, ')
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
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<int> profileId = GeneratedColumn<int>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES profile (id)'));
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
        profileId
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
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
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
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}profile_id'])!,
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
  final int profileId;
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
      required this.profileId});
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
    map['profile_id'] = Variable<int>(profileId);
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
      profileId: Value(profileId),
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
      profileId: serializer.fromJson<int>(json['profileId']),
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
      'profileId': serializer.toJson<int>(profileId),
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
          int? profileId}) =>
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
        profileId: profileId ?? this.profileId,
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
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
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
          ..write('profileId: $profileId')
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
      profileId);
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
          other.profileId == this.profileId);
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
  final Value<int> profileId;
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
    this.profileId = const Value.absent(),
  });
  ListeningHistoryCompanion.insert({
    this.id = const Value.absent(),
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
    required int profileId,
  })  : audioUrl = Value(audioUrl),
        title = Value(title),
        description = Value(description),
        imageUrl = Value(imageUrl),
        podcastTitle = Value(podcastTitle),
        podcastRSS = Value(podcastRSS),
        position = Value(position),
        duration = Value(duration),
        profileId = Value(profileId);
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
    Expression<int>? profileId,
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
      if (profileId != null) 'profile_id': profileId,
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
      Value<int>? profileId}) {
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
      profileId: profileId ?? this.profileId,
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
    if (profileId.present) {
      map['profile_id'] = Variable<int>(profileId.value);
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
          ..write('profileId: $profileId')
          ..write(')'))
        .toString();
  }
}

abstract class _$PoddrDatabase extends GeneratedDatabase {
  _$PoddrDatabase(QueryExecutor e) : super(e);
  $PoddrDatabaseManager get managers => $PoddrDatabaseManager(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $PodcastSubscriptionTable podcastSubscription =
      $PodcastSubscriptionTable(this);
  late final $ListeningHistoryTable listeningHistory =
      $ListeningHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [profile, podcastSubscription, listeningHistory];
}

typedef $$ProfileTableCreateCompanionBuilder = ProfileCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> shouldSync,
});
typedef $$ProfileTableUpdateCompanionBuilder = ProfileCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> shouldSync,
});

final class $$ProfileTableReferences
    extends BaseReferences<_$PoddrDatabase, $ProfileTable, ProfileData> {
  $$ProfileTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PodcastSubscriptionTable,
      List<PodcastSubscriptionData>> _podcastSubscriptionRefsTable(
          _$PoddrDatabase db) =>
      MultiTypedResultKey.fromTable(db.podcastSubscription,
          aliasName: $_aliasNameGenerator(
              db.profile.id, db.podcastSubscription.profileId));

  $$PodcastSubscriptionTableProcessedTableManager get podcastSubscriptionRefs {
    final manager =
        $$PodcastSubscriptionTableTableManager($_db, $_db.podcastSubscription)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_podcastSubscriptionRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ListeningHistoryTable, List<ListeningHistoryData>>
      _listeningHistoryRefsTable(_$PoddrDatabase db) =>
          MultiTypedResultKey.fromTable(db.listeningHistory,
              aliasName: $_aliasNameGenerator(
                  db.profile.id, db.listeningHistory.profileId));

  $$ListeningHistoryTableProcessedTableManager get listeningHistoryRefs {
    final manager =
        $$ListeningHistoryTableTableManager($_db, $_db.listeningHistory)
            .filter((f) => f.profileId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_listeningHistoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfileTableFilterComposer
    extends Composer<_$PoddrDatabase, $ProfileTable> {
  $$ProfileTableFilterComposer({
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

  ColumnFilters<bool> get shouldSync => $composableBuilder(
      column: $table.shouldSync, builder: (column) => ColumnFilters(column));

  Expression<bool> podcastSubscriptionRefs(
      Expression<bool> Function($$PodcastSubscriptionTableFilterComposer f) f) {
    final $$PodcastSubscriptionTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.podcastSubscription,
        getReferencedColumn: (t) => t.profileId,
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
    return f(composer);
  }

  Expression<bool> listeningHistoryRefs(
      Expression<bool> Function($$ListeningHistoryTableFilterComposer f) f) {
    final $$ListeningHistoryTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.listeningHistory,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListeningHistoryTableFilterComposer(
              $db: $db,
              $table: $db.listeningHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfileTableOrderingComposer
    extends Composer<_$PoddrDatabase, $ProfileTable> {
  $$ProfileTableOrderingComposer({
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

  ColumnOrderings<bool> get shouldSync => $composableBuilder(
      column: $table.shouldSync, builder: (column) => ColumnOrderings(column));
}

class $$ProfileTableAnnotationComposer
    extends Composer<_$PoddrDatabase, $ProfileTable> {
  $$ProfileTableAnnotationComposer({
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

  GeneratedColumn<bool> get shouldSync => $composableBuilder(
      column: $table.shouldSync, builder: (column) => column);

  Expression<T> podcastSubscriptionRefs<T extends Object>(
      Expression<T> Function($$PodcastSubscriptionTableAnnotationComposer a)
          f) {
    final $$PodcastSubscriptionTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.podcastSubscription,
            getReferencedColumn: (t) => t.profileId,
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
    return f(composer);
  }

  Expression<T> listeningHistoryRefs<T extends Object>(
      Expression<T> Function($$ListeningHistoryTableAnnotationComposer a) f) {
    final $$ListeningHistoryTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.listeningHistory,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ListeningHistoryTableAnnotationComposer(
              $db: $db,
              $table: $db.listeningHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfileTableTableManager extends RootTableManager<
    _$PoddrDatabase,
    $ProfileTable,
    ProfileData,
    $$ProfileTableFilterComposer,
    $$ProfileTableOrderingComposer,
    $$ProfileTableAnnotationComposer,
    $$ProfileTableCreateCompanionBuilder,
    $$ProfileTableUpdateCompanionBuilder,
    (ProfileData, $$ProfileTableReferences),
    ProfileData,
    PrefetchHooks Function(
        {bool podcastSubscriptionRefs, bool listeningHistoryRefs})> {
  $$ProfileTableTableManager(_$PoddrDatabase db, $ProfileTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> shouldSync = const Value.absent(),
          }) =>
              ProfileCompanion(
            id: id,
            name: name,
            shouldSync: shouldSync,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> shouldSync = const Value.absent(),
          }) =>
              ProfileCompanion.insert(
            id: id,
            name: name,
            shouldSync: shouldSync,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfileTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {podcastSubscriptionRefs = false, listeningHistoryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (podcastSubscriptionRefs) db.podcastSubscription,
                if (listeningHistoryRefs) db.listeningHistory
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (podcastSubscriptionRefs)
                    await $_getPrefetchedData<ProfileData, $ProfileTable,
                            PodcastSubscriptionData>(
                        currentTable: table,
                        referencedTable: $$ProfileTableReferences
                            ._podcastSubscriptionRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileTableReferences(db, table, p0)
                                .podcastSubscriptionRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items),
                  if (listeningHistoryRefs)
                    await $_getPrefetchedData<ProfileData, $ProfileTable,
                            ListeningHistoryData>(
                        currentTable: table,
                        referencedTable: $$ProfileTableReferences
                            ._listeningHistoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfileTableReferences(db, table, p0)
                                .listeningHistoryRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfileTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $ProfileTable,
    ProfileData,
    $$ProfileTableFilterComposer,
    $$ProfileTableOrderingComposer,
    $$ProfileTableAnnotationComposer,
    $$ProfileTableCreateCompanionBuilder,
    $$ProfileTableUpdateCompanionBuilder,
    (ProfileData, $$ProfileTableReferences),
    ProfileData,
    PrefetchHooks Function(
        {bool podcastSubscriptionRefs, bool listeningHistoryRefs})>;
typedef $$PodcastSubscriptionTableCreateCompanionBuilder
    = PodcastSubscriptionCompanion Function({
  Value<int> id,
  required String rss,
  required String title,
  required String description,
  required String author,
  required String imageUrl,
  required int profileId,
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
  Value<int> profileId,
  Value<DateTime> subscribedAt,
});

final class $$PodcastSubscriptionTableReferences extends BaseReferences<
    _$PoddrDatabase, $PodcastSubscriptionTable, PodcastSubscriptionData> {
  $$PodcastSubscriptionTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfileTable _profileIdTable(_$PoddrDatabase db) =>
      db.profile.createAlias($_aliasNameGenerator(
          db.podcastSubscription.profileId, db.profile.id));

  $$ProfileTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfileTableTableManager($_db, $_db.profile)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
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

  $$ProfileTableFilterComposer get profileId {
    final $$ProfileTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileTableFilterComposer(
              $db: $db,
              $table: $db.profile,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
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

  $$ProfileTableOrderingComposer get profileId {
    final $$ProfileTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileTableOrderingComposer(
              $db: $db,
              $table: $db.profile,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  $$ProfileTableAnnotationComposer get profileId {
    final $$ProfileTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileTableAnnotationComposer(
              $db: $db,
              $table: $db.profile,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
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
    PrefetchHooks Function({bool profileId})> {
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
            Value<int> profileId = const Value.absent(),
            Value<DateTime> subscribedAt = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion(
            id: id,
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            profileId: profileId,
            subscribedAt: subscribedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String rss,
            required String title,
            required String description,
            required String author,
            required String imageUrl,
            required int profileId,
            Value<DateTime> subscribedAt = const Value.absent(),
          }) =>
              PodcastSubscriptionCompanion.insert(
            id: id,
            rss: rss,
            title: title,
            description: description,
            author: author,
            imageUrl: imageUrl,
            profileId: profileId,
            subscribedAt: subscribedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PodcastSubscriptionTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable: $$PodcastSubscriptionTableReferences
                        ._profileIdTable(db),
                    referencedColumn: $$PodcastSubscriptionTableReferences
                        ._profileIdTable(db)
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
    PrefetchHooks Function({bool profileId})>;
typedef $$ListeningHistoryTableCreateCompanionBuilder
    = ListeningHistoryCompanion Function({
  Value<int> id,
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
  required int profileId,
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
  Value<int> profileId,
});

final class $$ListeningHistoryTableReferences extends BaseReferences<
    _$PoddrDatabase, $ListeningHistoryTable, ListeningHistoryData> {
  $$ListeningHistoryTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfileTable _profileIdTable(_$PoddrDatabase db) =>
      db.profile.createAlias(
          $_aliasNameGenerator(db.listeningHistory.profileId, db.profile.id));

  $$ProfileTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<int>('profile_id')!;

    final manager = $$ProfileTableTableManager($_db, $_db.profile)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

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

  $$ProfileTableFilterComposer get profileId {
    final $$ProfileTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileTableFilterComposer(
              $db: $db,
              $table: $db.profile,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  $$ProfileTableOrderingComposer get profileId {
    final $$ProfileTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileTableOrderingComposer(
              $db: $db,
              $table: $db.profile,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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

  $$ProfileTableAnnotationComposer get profileId {
    final $$ProfileTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profile,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfileTableAnnotationComposer(
              $db: $db,
              $table: $db.profile,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
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
    (ListeningHistoryData, $$ListeningHistoryTableReferences),
    ListeningHistoryData,
    PrefetchHooks Function({bool profileId})> {
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
            Value<int> profileId = const Value.absent(),
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
            profileId: profileId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
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
            required int profileId,
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
            profileId: profileId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ListeningHistoryTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ListeningHistoryTableReferences._profileIdTable(db),
                    referencedColumn: $$ListeningHistoryTableReferences
                        ._profileIdTable(db)
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

typedef $$ListeningHistoryTableProcessedTableManager = ProcessedTableManager<
    _$PoddrDatabase,
    $ListeningHistoryTable,
    ListeningHistoryData,
    $$ListeningHistoryTableFilterComposer,
    $$ListeningHistoryTableOrderingComposer,
    $$ListeningHistoryTableAnnotationComposer,
    $$ListeningHistoryTableCreateCompanionBuilder,
    $$ListeningHistoryTableUpdateCompanionBuilder,
    (ListeningHistoryData, $$ListeningHistoryTableReferences),
    ListeningHistoryData,
    PrefetchHooks Function({bool profileId})>;

class $PoddrDatabaseManager {
  final _$PoddrDatabase _db;
  $PoddrDatabaseManager(this._db);
  $$ProfileTableTableManager get profile =>
      $$ProfileTableTableManager(_db, _db.profile);
  $$PodcastSubscriptionTableTableManager get podcastSubscription =>
      $$PodcastSubscriptionTableTableManager(_db, _db.podcastSubscription);
  $$ListeningHistoryTableTableManager get listeningHistory =>
      $$ListeningHistoryTableTableManager(_db, _db.listeningHistory);
}
