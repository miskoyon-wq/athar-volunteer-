import 'package:hive/hive.dart';

/// ===================== Association =====================
class Association extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String fullName;
  @HiveField(3)
  String tag;

  Association({
    required this.id,
    required this.name,
    required this.fullName,
    required this.tag,
  });
}

class AssociationAdapter extends TypeAdapter<Association> {
  @override
  final int typeId = 0;
  @override
  Association read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return Association(
      id: f[0] as String,
      name: f[1] as String,
      fullName: f[2] as String,
      tag: f[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Association obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.fullName)
      ..writeByte(3)
      ..write(obj.tag);
  }
}

/// ===================== UserProfile =====================
class UserProfile extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String phone;
  @HiveField(2)
  String name;
  @HiveField(3)
  String age;
  @HiveField(4)
  String city;
  @HiveField(5)
  List<String> availability;
  @HiveField(6)
  String? selectedNgoId;
  @HiveField(7)
  DateTime createdAt;
  @HiveField(8)
  bool onboarded;

  UserProfile({
    required this.id,
    required this.phone,
    this.name = '',
    this.age = '',
    this.city = '',
    List<String>? availability,
    this.selectedNgoId,
    DateTime? createdAt,
    this.onboarded = false,
  })  : availability = availability ?? <String>[],
        createdAt = createdAt ?? DateTime.now();

  bool get isComplete => name.trim().isNotEmpty && age.trim().isNotEmpty && city.trim().isNotEmpty;
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;
  @override
  UserProfile read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return UserProfile(
      id: f[0] as String,
      phone: f[1] as String,
      name: (f[2] as String?) ?? '',
      age: (f[3] as String?) ?? '',
      city: (f[4] as String?) ?? '',
      availability: (f[5] as List?)?.cast<String>() ?? <String>[],
      selectedNgoId: f[6] as String?,
      createdAt: f[7] as DateTime?,
      onboarded: (f[8] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.age)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.availability)
      ..writeByte(6)
      ..write(obj.selectedNgoId)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.onboarded);
  }
}

/// ===================== Opportunity =====================
class Opportunity extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String ngoId;
  @HiveField(2)
  String field;
  @HiveField(3)
  String title;
  @HiveField(4)
  String description;
  @HiveField(5)
  String location;
  @HiveField(6)
  String timeText;
  @HiveField(7)
  int seats;
  @HiveField(8)
  String startDate;
  @HiveField(9)
  String status; // open | closed
  @HiveField(10)
  List<String> requirements;
  @HiveField(11)
  DateTime createdAt;

  Opportunity({
    required this.id,
    required this.ngoId,
    required this.field,
    required this.title,
    required this.description,
    required this.location,
    required this.timeText,
    required this.seats,
    required this.startDate,
    this.status = 'open',
    List<String>? requirements,
    DateTime? createdAt,
  })  : requirements = requirements ?? <String>[],
        createdAt = createdAt ?? DateTime.now();
}

class OpportunityAdapter extends TypeAdapter<Opportunity> {
  @override
  final int typeId = 2;
  @override
  Opportunity read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return Opportunity(
      id: f[0] as String,
      ngoId: f[1] as String,
      field: (f[2] as String?) ?? '',
      title: (f[3] as String?) ?? '',
      description: (f[4] as String?) ?? '',
      location: (f[5] as String?) ?? '',
      timeText: (f[6] as String?) ?? '',
      seats: (f[7] as num?)?.toInt() ?? 0,
      startDate: (f[8] as String?) ?? '',
      status: (f[9] as String?) ?? 'open',
      requirements: (f[10] as List?)?.cast<String>() ?? <String>[],
      createdAt: f[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Opportunity obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ngoId)
      ..writeByte(2)
      ..write(obj.field)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.timeText)
      ..writeByte(7)
      ..write(obj.seats)
      ..writeByte(8)
      ..write(obj.startDate)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.requirements)
      ..writeByte(11)
      ..write(obj.createdAt);
  }
}

/// ===================== Application =====================
class Application extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String opportunityId;
  @HiveField(2)
  String userId;
  @HiveField(3)
  String note;
  @HiveField(4)
  String status; // pending | accepted | rejected
  @HiveField(5)
  DateTime consentAt;
  @HiveField(6)
  DateTime createdAt;
  @HiveField(7)
  DateTime? decidedAt;
  @HiveField(8)
  String? decidedBy;

  Application({
    required this.id,
    required this.opportunityId,
    required this.userId,
    this.note = '',
    this.status = 'pending',
    DateTime? consentAt,
    DateTime? createdAt,
    this.decidedAt,
    this.decidedBy,
  })  : consentAt = consentAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();
}

class ApplicationAdapter extends TypeAdapter<Application> {
  @override
  final int typeId = 3;
  @override
  Application read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return Application(
      id: f[0] as String,
      opportunityId: f[1] as String,
      userId: f[2] as String,
      note: (f[3] as String?) ?? '',
      status: (f[4] as String?) ?? 'pending',
      consentAt: f[5] as DateTime?,
      createdAt: f[6] as DateTime?,
      decidedAt: f[7] as DateTime?,
      decidedBy: f[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Application obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.opportunityId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.consentAt)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.decidedAt)
      ..writeByte(8)
      ..write(obj.decidedBy);
  }
}

/// ===================== AppNotification =====================
class AppNotification extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String userId;
  @HiveField(2)
  String type; // info | sent | accepted | rejected | new
  @HiveField(3)
  String title;
  @HiveField(4)
  String body;
  @HiveField(5)
  String? opportunityId;
  @HiveField(6)
  DateTime? readAt;
  @HiveField(7)
  DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.opportunityId,
    this.readAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isRead => readAt != null;
}

class AppNotificationAdapter extends TypeAdapter<AppNotification> {
  @override
  final int typeId = 4;
  @override
  AppNotification read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return AppNotification(
      id: f[0] as String,
      userId: (f[1] as String?) ?? '',
      type: (f[2] as String?) ?? 'info',
      title: (f[3] as String?) ?? '',
      body: (f[4] as String?) ?? '',
      opportunityId: f[5] as String?,
      readAt: f[6] as DateTime?,
      createdAt: f[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AppNotification obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.body)
      ..writeByte(5)
      ..write(obj.opportunityId)
      ..writeByte(6)
      ..write(obj.readAt)
      ..writeByte(7)
      ..write(obj.createdAt);
  }
}

/// ===================== ChatMessage =====================
class ChatMessage extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String role; // ai | user
  @HiveField(2)
  String text;
  @HiveField(3)
  List<String>? chips;
  @HiveField(4)
  DateTime createdAt;
  @HiveField(5)
  bool reported;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.chips,
    DateTime? createdAt,
    this.reported = false,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isAi => role == 'ai';
}

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 5;
  @override
  ChatMessage read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return ChatMessage(
      id: f[0] as String,
      role: (f[1] as String?) ?? 'ai',
      text: (f[2] as String?) ?? '',
      chips: (f[3] as List?)?.cast<String>(),
      createdAt: f[4] as DateTime?,
      reported: (f[5] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.role)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.chips)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.reported);
  }
}

/// ===================== ChatSession =====================
class ChatSession extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String userId;
  @HiveField(2)
  List<ChatMessage> messages;
  @HiveField(3)
  Map<String, dynamic> extractedInterests;
  @HiveField(4)
  bool done;
  @HiveField(5)
  DateTime createdAt;

  ChatSession({
    required this.id,
    required this.userId,
    List<ChatMessage>? messages,
    Map<String, dynamic>? extractedInterests,
    this.done = false,
    DateTime? createdAt,
  })  : messages = messages ?? <ChatMessage>[],
        extractedInterests = extractedInterests ?? <String, dynamic>{},
        createdAt = createdAt ?? DateTime.now();

  String get userTranscript => messages
      .where((m) => !m.isAi)
      .map((m) => m.text)
      .join(' ');
}

class ChatSessionAdapter extends TypeAdapter<ChatSession> {
  @override
  final int typeId = 6;
  @override
  ChatSession read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return ChatSession(
      id: f[0] as String,
      userId: (f[1] as String?) ?? '',
      messages: (f[2] as List?)?.cast<ChatMessage>() ?? <ChatMessage>[],
      extractedInterests: (f[3] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      done: (f[4] as bool?) ?? false,
      createdAt: f[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.extractedInterests)
      ..writeByte(4)
      ..write(obj.done)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}

/// ===================== AI report (Google Play policy) =====================
class AiReport extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String userId;
  @HiveField(2)
  String sessionId;
  @HiveField(3)
  int messageIndex;
  @HiveField(4)
  String reason;
  @HiveField(5)
  DateTime createdAt;

  AiReport({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.messageIndex,
    required this.reason,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AiReportAdapter extends TypeAdapter<AiReport> {
  @override
  final int typeId = 7;
  @override
  AiReport read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) {
      f[reader.readByte()] = reader.read();
    }
    return AiReport(
      id: f[0] as String,
      userId: (f[1] as String?) ?? '',
      sessionId: (f[2] as String?) ?? '',
      messageIndex: (f[3] as num?)?.toInt() ?? 0,
      reason: (f[4] as String?) ?? '',
      createdAt: f[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AiReport obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.messageIndex)
      ..writeByte(4)
      ..write(obj.reason)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
