import 'package:flutter/material.dart';

import '../domain/dashboard_models.dart';

/// SAMPLE DATA ONLY, transcribed from the design reference to demonstrate the
/// layout. Replace with real data sources in a later step.
abstract final class DashboardSampleData {
  static const int totalToday = 38;
  static const int insideNow = 12;
  static const int checkedOutToday = 26;

  static const List<StatCardData> stats = [
    StatCardData(
      label: "TODAY'S VISITS",
      icon: Icons.people_outline,
      value: '38',
      unit: 'visits today',
      footer: '12% vs. yesterday (34 total)',
      tone: FooterTone.positive,
    ),
    StatCardData(
      label: 'REGISTERED DIRECTORY',
      icon: Icons.badge_outlined,
      value: '214',
      unit: 'members',
      footer: '+8 new patrons added this week',
      tone: FooterTone.positive,
    ),
    StatCardData(
      label: 'CURRENTLY INSIDE',
      icon: Icons.meeting_room_outlined,
      value: '12',
      unit: '/45 capacity',
      footer: '27% Net Occupancy | 33 Seats Free',
      progress: 12 / 45,
      live: true,
    ),
    StatCardData(
      label: 'INDUCTIONS TODAY',
      icon: Icons.school_outlined,
      value: '5',
      unit: 'sessions',
      footer: '80% Biometric & Card ID Issued',
    ),
  ];

  static const VisitorProfile visitor = VisitorProfile(
    name: 'Amina Hassan Mwangi',
    initials: 'AH',
    email: 'amina.hassan@example.com',
    phone: '+254 722 849 102',
    memberId: 'ACM-2024-0892',
    memberSince: 'March 14, 2023',
    totalVisits: '42 visits total',
    lastVisited: 'Last visited: Oct 21, 2024 (3 days ago)',
  );

  static const List<String> visitPurposes = [
    'English Conversation Club',
    'Research & Study',
    'American Culture Activities',
    'English Lessons & TOEFL Prep',
    'Games Corner & Makerspace',
    'e-Library Access',
  ];

  static const List<ActivityItem> activities = [
    ActivityItem(
      title: 'English Conversation',
      schedule: '10:00 AM - 12:00 PM • Room A',
      badge: '14 Attendees',
      icon: Icons.forum_outlined,
      note: 'Session currently active',
      isActive: true,
    ),
    ActivityItem(
      title: 'Research & Study',
      schedule: 'All Day • Quiet Zone & e-Library',
      badge: '9 Students',
      icon: Icons.menu_book_outlined,
      note: '11 of 16 PCs occupied',
    ),
    ActivityItem(
      title: 'American Culture Activities',
      schedule: '02:00 PM - 03:30 PM • Main Hall',
      badge: '22 Registered',
      icon: Icons.palette_outlined,
    ),
    ActivityItem(
      title: 'English Lessons & TOEFL Prep',
      schedule: '03:30 PM - 05:00 PM • Lab 2',
      badge: '8 Registered',
      icon: Icons.translate,
      note: 'Audio workstations ready',
    ),
    ActivityItem(
      title: 'Games Corner & Makerspace',
      schedule: '06:00 PM - 08:00 PM • Creative Lounge',
      badge: '6 Registered',
      icon: Icons.sports_esports_outlined,
      note: '3D Printing & Board Games',
    ),
  ];

  static const String totalEngagement = '59 participants';

  static const List<CheckInRecord> recentCheckIns = [
    CheckInRecord(
      name: 'Amina Hassan Mwangi',
      initials: 'AH',
      subtitle: 'Frequent Member • 42 visits',
      cardNumber: 'ACM-2024-0892',
      checkInTime: '10:44 AM',
      purpose: 'English Conversation',
      status: VisitStatus.checkedIn,
    ),
    CheckInRecord(
      name: 'Brian Ochieng Otieno',
      initials: 'BO',
      subtitle: 'University Student',
      cardNumber: 'ACM-2024-0734',
      checkInTime: '10:32 AM',
      purpose: 'Research & Study',
      status: VisitStatus.checkedIn,
    ),
    CheckInRecord(
      name: 'Fatma Zahra Salim',
      initials: 'FZ',
      subtitle: 'Youth Patron',
      cardNumber: 'ACM-2024-0415',
      checkInTime: '10:15 AM',
      purpose: 'American Culture Activities',
      status: VisitStatus.checkedIn,
    ),
    CheckInRecord(
      name: 'Kevin Mutua Kimani',
      initials: 'KM',
      subtitle: 'Tech Enthusiast',
      cardNumber: 'ACM-2024-0221',
      checkInTime: '09:45 AM',
      purpose: 'Games Corner',
      status: VisitStatus.checkedIn,
    ),
    CheckInRecord(
      name: "Mary Wanjiku Ndung'u",
      initials: 'MW',
      subtitle: 'TOEFL Scholar',
      cardNumber: 'ACM-2023-0678',
      checkInTime: '09:12 AM',
      purpose: 'English Lessons',
      status: VisitStatus.checkedOut,
      checkedOutAt: '09:58 AM',
    ),
    CheckInRecord(
      name: 'Omar Swaleh Said',
      initials: 'OS',
      subtitle: 'General Researcher',
      cardNumber: 'ACM-2023-0512',
      checkInTime: '08:50 AM',
      purpose: 'e-Library Access',
      status: VisitStatus.checkedOut,
      checkedOutAt: '09:58 AM',
    ),
  ];
}
