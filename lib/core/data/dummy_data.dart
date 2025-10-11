import '../models/user_model.dart';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';

class DummyData {
  // Dummy Users
  static List<UserModel> get users => [
    UserModel(
      id: 'user_1',
      name: 'John Doe',
      email: 'john.doe@university.edu',
      role: 'student',
      course: 'Computer Science',
      points: 1650,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'user_2',
      name: 'Alice Johnson',
      email: 'alice.johnson@university.edu',
      role: 'student',
      course: 'Information Technology',
      points: 1450,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'user_3',
      name: 'Bob Smith',
      email: 'bob.smith@university.edu',
      role: 'student',
      course: 'Software Engineering',
      points: 1250,
      createdAt: DateTime.now().subtract(const Duration(days: 250)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'leader_1',
      name: 'Dr. Sarah Wilson',
      email: 'sarah.wilson@university.edu',
      role: 'club_leader',
      course: 'Computer Science Faculty',
      points: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
      updatedAt: DateTime.now(),
    ),
    UserModel(
      id: 'leader_2',
      name: 'Prof. Michael Brown',
      email: 'michael.brown@university.edu',
      role: 'club_leader',
      course: 'Business Faculty',
      points: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Dummy Clubs
  static List<ClubModel> get clubs => [
    ClubModel(
      id: 'club_1',
      name: 'Tech Innovators Club',
      description: 'A community of technology enthusiasts focused on learning, sharing, and building innovative solutions together. We organize workshops, hackathons, and tech talks.',
      leaderId: 'leader_1',
      status: 'approved',
      categories: ['Technology', 'Programming', 'Innovation'],
      memberCount: 156,
      eventCount: 24,
      createdAt: DateTime.now().subtract(const Duration(days: 400)),
      updatedAt: DateTime.now(),
    ),
    ClubModel(
      id: 'club_2',
      name: 'Business Leaders Society',
      description: 'Empowering future business leaders through networking, mentorship, and practical business experience. Join us for case competitions and industry insights.',
      leaderId: 'leader_2',
      status: 'approved',
      categories: ['Business', 'Leadership', 'Networking'],
      memberCount: 89,
      eventCount: 18,
      createdAt: DateTime.now().subtract(const Duration(days: 350)),
      updatedAt: DateTime.now(),
    ),
    ClubModel(
      id: 'club_3',
      name: 'Creative Arts Collective',
      description: 'A vibrant community for artists, designers, and creative minds. We showcase talent, organize exhibitions, and foster artistic collaboration.',
      leaderId: 'leader_1',
      status: 'approved',
      categories: ['Arts', 'Design', 'Creativity'],
      memberCount: 67,
      eventCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 300)),
      updatedAt: DateTime.now(),
    ),
    ClubModel(
      id: 'club_4',
      name: 'Environmental Action Group',
      description: 'Dedicated to environmental sustainability and awareness. We organize clean-up drives, awareness campaigns, and eco-friendly initiatives.',
      leaderId: 'leader_2',
      status: 'pending',
      categories: ['Environment', 'Sustainability', 'Community'],
      memberCount: 45,
      eventCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Dummy Events
  static List<EventModel> get events => [
    EventModel(
      id: 'event_1',
      clubId: 'club_1',
      title: 'AI & Machine Learning Workshop',
      description: 'Comprehensive workshop covering the fundamentals of AI and ML. Learn about neural networks, deep learning, and practical applications in industry.',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      venue: 'Main Auditorium, Block A',
      maxParticipants: 100,
      currentParticipants: 45,
      status: 'upcoming',
      tags: ['AI', 'Machine Learning', 'Workshop', 'Technology'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    EventModel(
      id: 'event_2',
      clubId: 'club_1',
      title: 'Hackathon 2024: Code for Change',
      description: '48-hour hackathon focused on creating solutions for social problems. Teams will compete for prizes and recognition.',
      dateTime: DateTime.now().add(const Duration(days: 14)),
      venue: 'Computer Lab Complex',
      maxParticipants: 80,
      currentParticipants: 67,
      status: 'upcoming',
      tags: ['Hackathon', 'Programming', 'Competition', 'Innovation'],
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now(),
    ),
    EventModel(
      id: 'event_3',
      clubId: 'club_2',
      title: 'Entrepreneurship Bootcamp',
      description: 'Intensive bootcamp for aspiring entrepreneurs. Learn about business planning, funding, and startup strategies from industry experts.',
      dateTime: DateTime.now().add(const Duration(days: 21)),
      venue: 'Business School Auditorium',
      maxParticipants: 60,
      currentParticipants: 38,
      status: 'upcoming',
      tags: ['Entrepreneurship', 'Business', 'Startup', 'Bootcamp'],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    EventModel(
      id: 'event_4',
      clubId: 'club_1',
      title: 'Web Development Masterclass',
      description: 'Complete web development course covering HTML, CSS, JavaScript, and modern frameworks like React and Vue.js.',
      dateTime: DateTime.now().subtract(const Duration(days: 15)),
      venue: 'Computer Lab 1',
      maxParticipants: 50,
      currentParticipants: 48,
      status: 'completed',
      tags: ['Web Development', 'JavaScript', 'React', 'Programming'],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now(),
    ),
    EventModel(
      id: 'event_5',
      clubId: 'club_3',
      title: 'Digital Art Exhibition',
      description: 'Showcase of student digital artwork including 3D modeling, digital painting, and interactive media installations.',
      dateTime: DateTime.now().subtract(const Duration(days: 7)),
      venue: 'Art Gallery, Main Building',
      maxParticipants: 200,
      currentParticipants: 156,
      status: 'completed',
      tags: ['Art', 'Digital', 'Exhibition', 'Creative'],
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
      updatedAt: DateTime.now(),
    ),
    EventModel(
      id: 'event_6',
      clubId: 'club_2',
      title: 'Leadership Summit 2024',
      description: 'Annual leadership summit featuring keynote speakers, panel discussions, and networking opportunities with industry leaders.',
      dateTime: DateTime.now().add(const Duration(days: 30)),
      venue: 'Convention Center',
      maxParticipants: 150,
      currentParticipants: 89,
      status: 'upcoming',
      tags: ['Leadership', 'Summit', 'Networking', 'Professional'],
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      updatedAt: DateTime.now(),
    ),
  ];

  // Dummy Registrations
  static List<RegistrationModel> get registrations => [
    RegistrationModel(
      id: 'reg_1',
      eventId: 'event_1',
      studentId: 'user_1',
      status: 'approved',
      registeredAt: DateTime.now().subtract(const Duration(days: 5)),
      approvedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    RegistrationModel(
      id: 'reg_2',
      eventId: 'event_1',
      studentId: 'user_2',
      status: 'registered',
      registeredAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    RegistrationModel(
      id: 'reg_3',
      eventId: 'event_2',
      studentId: 'user_1',
      status: 'approved',
      registeredAt: DateTime.now().subtract(const Duration(days: 10)),
      approvedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    RegistrationModel(
      id: 'reg_4',
      eventId: 'event_4',
      studentId: 'user_1',
      status: 'attended',
      registeredAt: DateTime.now().subtract(const Duration(days: 30)),
      approvedAt: DateTime.now().subtract(const Duration(days: 28)),
      attendedAt: DateTime.now().subtract(const Duration(days: 15)),
      pointsEarned: 50,
    ),
    RegistrationModel(
      id: 'reg_5',
      eventId: 'event_4',
      studentId: 'user_2',
      status: 'attended',
      registeredAt: DateTime.now().subtract(const Duration(days: 28)),
      approvedAt: DateTime.now().subtract(const Duration(days: 26)),
      attendedAt: DateTime.now().subtract(const Duration(days: 15)),
      pointsEarned: 50,
    ),
    RegistrationModel(
      id: 'reg_6',
      eventId: 'event_5',
      studentId: 'user_3',
      status: 'attended',
      registeredAt: DateTime.now().subtract(const Duration(days: 20)),
      approvedAt: DateTime.now().subtract(const Duration(days: 18)),
      attendedAt: DateTime.now().subtract(const Duration(days: 7)),
      pointsEarned: 75,
    ),
  ];

  // Firestore JSON Structure for easy import
  static Map<String, dynamic> get firestoreData => {
    'users': {
      for (var user in users) user.id: user.toJson()..remove('id'),
    },
    'clubs': {
      for (var club in clubs) club.id: club.toJson()..remove('id'),
    },
    'events': {
      for (var event in events) event.id: event.toJson()..remove('id'),
    },
    'registrations': {
      for (var registration in registrations) registration.id: registration.toJson()..remove('id'),
    },
  };

  // Sample Firestore Rules
  static String get firestoreRules => '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null; // Allow reading other users for leaderboard
    }
    
    // Clubs collection
    match /clubs/{clubId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource == null || resource.data.leaderId == request.auth.uid);
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        exists(/databases/\$(database)/documents/clubs/\$(resource.data.clubId)) &&
        get(/databases/\$(database)/documents/clubs/\$(resource.data.clubId)).data.leaderId == request.auth.uid;
    }
    
    // Registrations collection
    match /registrations/{registrationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.studentId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.studentId || 
         exists(/databases/\$(database)/documents/events/\$(resource.data.eventId)) &&
         exists(/databases/\$(database)/documents/clubs/\$(get(/databases/\$(database)/documents/events/\$(resource.data.eventId)).data.clubId)) &&
         get(/databases/\$(database)/documents/clubs/\$(get(/databases/\$(database)/documents/events/\$(resource.data.eventId)).data.clubId)).data.leaderId == request.auth.uid);
    }
  }
}
''';

  // Sample Firebase Storage Rules
  static String get storageRules => '''
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Club logos
    match /club_logos/{clubId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        exists(/databases/(default)/documents/clubs/\$(clubId)) &&
        get(/databases/(default)/documents/clubs/\$(clubId)).data.leaderId == request.auth.uid;
    }
    
    // Event banners
    match /event_banners/{eventId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        exists(/databases/(default)/documents/events/\$(eventId)) &&
        exists(/databases/(default)/documents/clubs/\$(get(/databases/(default)/documents/events/\$(eventId)).data.clubId)) &&
        get(/databases/(default)/documents/clubs/\$(get(/databases/(default)/documents/events/\$(eventId)).data.clubId)).data.leaderId == request.auth.uid;
    }
  }
}
''';
}
