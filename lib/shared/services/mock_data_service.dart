import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:foodbegood/features/auth/domain/entities/user_role.dart';

export 'package:foodbegood/features/auth/domain/entities/user_role.dart';

/// User model
class User {
  final String id;
  final String studentId;
  final String passwordHash;
  final UserRole role;
  final Profile profile;

  User({
    required this.id,
    required this.studentId,
    required this.passwordHash,
    required this.role,
    required this.profile,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'passwordHash': passwordHash,
    'role': role.name,
    'profile': profile.toJson(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    passwordHash: json['passwordHash'] as String,
    role: UserRole.values.firstWhere(
      (e) => e.name == json['role'],
      orElse: () => UserRole.student,
    ),
    profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
  );
}

/// Profile model
class Profile {
  final String firstName;
  final String lastName;
  final String? photoPath;
  final String? department;
  final int? yearOfStudy;

  Profile({
    required this.firstName,
    required this.lastName,
    this.photoPath,
    this.department,
    this.yearOfStudy,
  });

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'photoPath': photoPath,
    'department': department,
    'yearOfStudy': yearOfStudy,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    photoPath: json['photoPath'] as String?,
    department: json['department'] as String?,
    yearOfStudy: json['yearOfStudy'] as int?,
  );

  String get fullName => '$firstName $lastName';
}

/// Dashboard data model
class DashboardData {
  final int totalMeals;
  final int monthlyGoal;
  final double monthlyGoalProgress;
  final MoneySaved moneySaved;
  final double monthlyAverage;
  final int percentile;
  final int currentStreak;
  final NextPickup? nextPickup;
  final SocialImpact socialImpact;

  DashboardData({
    required this.totalMeals,
    required this.monthlyGoal,
    required this.monthlyGoalProgress,
    required this.moneySaved,
    required this.monthlyAverage,
    required this.percentile,
    required this.currentStreak,
    this.nextPickup,
    required this.socialImpact,
  });

  Map<String, dynamic> toJson() => {
    'totalMeals': totalMeals,
    'monthlyGoal': monthlyGoal,
    'monthlyGoalProgress': monthlyGoalProgress,
    'moneySaved': moneySaved.toJson(),
    'monthlyAverage': monthlyAverage,
    'percentile': percentile,
    'currentStreak': currentStreak,
    'nextPickup': nextPickup?.toJson(),
    'socialImpact': socialImpact.toJson(),
  };

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    totalMeals: json['totalMeals'] as int,
    monthlyGoal: json['monthlyGoal'] as int,
    monthlyGoalProgress: json['monthlyGoalProgress'] as double,
    moneySaved: MoneySaved.fromJson(json['moneySaved'] as Map<String, dynamic>),
    monthlyAverage: json['monthlyAverage'] as double,
    percentile: json['percentile'] as int,
    currentStreak: json['currentStreak'] as int,
    nextPickup: json['nextPickup'] != null
        ? NextPickup.fromJson(json['nextPickup'] as Map<String, dynamic>)
        : null,
    socialImpact: SocialImpact.fromJson(json['socialImpact'] as Map<String, dynamic>),
  );
}

/// Money saved model
class MoneySaved {
  final double thisMonth;
  final double lastMonth;
  final double trend;
  final Map<String, double> breakdown;

  MoneySaved({
    required this.thisMonth,
    required this.lastMonth,
    required this.trend,
    required this.breakdown,
  });

  double get difference => thisMonth - lastMonth;

  Map<String, dynamic> toJson() => {
    'thisMonth': thisMonth,
    'lastMonth': lastMonth,
    'trend': trend,
    'breakdown': breakdown,
  };

  factory MoneySaved.fromJson(Map<String, dynamic> json) => MoneySaved(
    thisMonth: json['thisMonth'] as double,
    lastMonth: json['lastMonth'] as double,
    trend: json['trend'] as double,
    breakdown: (json['breakdown'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(k, v as double),
    ),
  );
}

/// Next pickup model
class NextPickup {
  final String location;
  final DateTime time;

  NextPickup({
    required this.location,
    required this.time,
  });

  String get formattedTime {
    final now = DateTime.now();
    final difference = time.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  Map<String, dynamic> toJson() => {
    'location': location,
    'time': time.toIso8601String(),
  };

  factory NextPickup.fromJson(Map<String, dynamic> json) => NextPickup(
    location: json['location'] as String,
    time: DateTime.parse(json['time'] as String),
  );
}

/// Social impact model
class SocialImpact {
  final int studentsHelped;
  final double avgMoneySavedPerStudent;

  SocialImpact({
    required this.studentsHelped,
    required this.avgMoneySavedPerStudent,
  });

  Map<String, dynamic> toJson() => {
    'studentsHelped': studentsHelped,
    'avgMoneySavedPerStudent': avgMoneySavedPerStudent,
  };

  factory SocialImpact.fromJson(Map<String, dynamic> json) => SocialImpact(
    studentsHelped: json['studentsHelped'] as int,
    avgMoneySavedPerStudent: json['avgMoneySavedPerStudent'] as double,
  );
}

/// Canteen dashboard model
class CanteenDashboard {
  final int totalMealsSaved;
  final int dailyAverage;
  final int weeklyTotal;
  final double monthlyTrend;
  final double foodWastePrevented;
  final double wasteReduction;
  final double canteenSavings;
  final int studentsHelped;
  final double studentsTrend;
  final double studentSavingsTotal;
  final int urgentRequests;

  CanteenDashboard({
    required this.totalMealsSaved,
    required this.dailyAverage,
    required this.weeklyTotal,
    required this.monthlyTrend,
    required this.foodWastePrevented,
    required this.wasteReduction,
    required this.canteenSavings,
    required this.studentsHelped,
    required this.studentsTrend,
    required this.studentSavingsTotal,
    required this.urgentRequests,
  });

  Map<String, dynamic> toJson() => {
    'totalMealsSaved': totalMealsSaved,
    'dailyAverage': dailyAverage,
    'weeklyTotal': weeklyTotal,
    'monthlyTrend': monthlyTrend,
    'foodWastePrevented': foodWastePrevented,
    'wasteReduction': wasteReduction,
    'canteenSavings': canteenSavings,
    'studentsHelped': studentsHelped,
    'studentsTrend': studentsTrend,
    'studentSavingsTotal': studentSavingsTotal,
    'urgentRequests': urgentRequests,
  };

  factory CanteenDashboard.fromJson(Map<String, dynamic> json) => CanteenDashboard(
    totalMealsSaved: json['totalMealsSaved'] as int,
    dailyAverage: json['dailyAverage'] as int,
    weeklyTotal: json['weeklyTotal'] as int,
    monthlyTrend: json['monthlyTrend'] as double,
    foodWastePrevented: json['foodWastePrevented'] as double,
    wasteReduction: json['wasteReduction'] as double,
    canteenSavings: json['canteenSavings'] as double,
    studentsHelped: json['studentsHelped'] as int,
    studentsTrend: json['studentsTrend'] as double,
    studentSavingsTotal: json['studentSavingsTotal'] as double,
    urgentRequests: json['urgentRequests'] as int,
  );
}

/// Food category model
class FoodCategory {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int maxPerPickup;

  FoodCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.maxPerPickup,
  });
}

/// Mock data service for Phase 1 local-first prototyping
class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  final Random _random = Random();

  /// Mock users
  final List<User> _users = [
    User(
      id: '1',
      studentId: '61913042',
      passwordHash: _hashPassword('password123'),
      role: UserRole.student,
      profile: Profile(
        firstName: 'Zain',
        lastName: 'Ul Ebad',
        department: 'Computer Science',
        yearOfStudy: 3,
      ),
    ),
    User(
      id: '2',
      studentId: '61913043',
      passwordHash: _hashPassword('password123'),
      role: UserRole.student,
      profile: Profile(
        firstName: 'Maria',
        lastName: 'Garcia',
        department: 'Business Administration',
        yearOfStudy: 2,
      ),
    ),
    User(
      id: '3',
      studentId: 'canteen001',
      passwordHash: _hashPassword('canteen123'),
      role: UserRole.canteen,
      profile: Profile(
        firstName: 'John',
        lastName: 'Smith',
        department: 'Canteen Staff',
      ),
    ),
  ];

  /// Food categories
  final List<FoodCategory> _foodCategories = [
    FoodCategory(
      id: 'salad',
      name: 'Salad',
      icon: '🥗',
      color: '#10B981',
      maxPerPickup: 1,
    ),
    FoodCategory(
      id: 'dessert',
      name: 'Dessert',
      icon: '🍰',
      color: '#EC4899',
      maxPerPickup: 1,
    ),
    FoodCategory(
      id: 'side',
      name: 'Side',
      icon: '🍟',
      color: '#F59E0B',
      maxPerPickup: 2,
    ),
    FoodCategory(
      id: 'chicken',
      name: 'Chicken',
      icon: '🍗',
      color: '#F97316',
      maxPerPickup: 1,
    ),
    FoodCategory(
      id: 'fish',
      name: 'Fish',
      icon: '🐟',
      color: '#3B82F6',
      maxPerPickup: 1,
    ),
    FoodCategory(
      id: 'veggie',
      name: 'Veggie',
      icon: '🥘',
      color: '#8B5CF6',
      maxPerPickup: 1,
    ),
  ];

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password
  bool verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  /// Get user by student ID
  User? getUserByStudentId(String studentId) {
    try {
      return _users.firstWhere(
        (u) => u.studentId.toLowerCase() == studentId.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get dashboard data for user
  DashboardData getDashboardForUser(String userId) {
    return DashboardData(
      totalMeals: 34,
      monthlyGoal: 50,
      monthlyGoalProgress: 0.68,
      moneySaved: MoneySaved(
        thisMonth: 82.50,
        lastMonth: 70.00,
        trend: 0.18,
        breakdown: {
          'Meals': 45.00,
          'Drinks': 22.50,
          'Snacks': 15.00,
        },
      ),
      monthlyAverage: 12.3,
      percentile: 15,
      currentStreak: 5,
      nextPickup: NextPickup(
        location: 'Mensa Viadrina',
        time: DateTime.now().add(const Duration(hours: 2, minutes: 45)),
      ),
      socialImpact: SocialImpact(
        studentsHelped: 156,
        avgMoneySavedPerStudent: 12.50,
      ),
    );
  }

  /// Get canteen dashboard
  CanteenDashboard getCanteenDashboard() {
    return CanteenDashboard(
      totalMealsSaved: 1247,
      dailyAverage: 89,
      weeklyTotal: 342,
      monthlyTrend: 0.23,
      foodWastePrevented: 428,
      wasteReduction: -0.15,
      canteenSavings: 3142.00,
      studentsHelped: 287,
      studentsTrend: 0.08,
      studentSavingsTotal: 4235.00,
      urgentRequests: 3,
    );
  }

  /// Get all food categories
  List<FoodCategory> getFoodCategories() => List.unmodifiable(_foodCategories);

  /// Get meal history
  List<Map<String, dynamic>> getMealHistory(String userId) {
    return [
      {
        'id': '1',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'items': ['Salad', 'Chicken'],
        'totalValue': 6.50,
      },
      {
        'id': '2',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'items': ['Fish', 'Side'],
        'totalValue': 5.00,
      },
      {
        'id': '3',
        'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
        'items': ['Veggie', 'Dessert'],
        'totalValue': 5.00,
      },
    ];
  }

  /// Generate QR code data
  String generateQRCodeData(String pickupId) {
    final data = {
      'pickupId': pickupId,
      'timestamp': DateTime.now().toIso8601String(),
      'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }
}
