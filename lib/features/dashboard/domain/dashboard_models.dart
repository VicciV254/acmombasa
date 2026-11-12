import 'package:flutter/widgets.dart';

enum FooterTone { positive, neutral }

class StatCardData {
  const StatCardData({
    required this.label,
    required this.icon,
    required this.value,
    required this.unit,
    required this.footer,
    this.tone = FooterTone.neutral,
    this.progress,
    this.live = false,
  });

  final String label;
  final IconData icon;
  final String value;
  final String unit;
  final String footer;
  final FooterTone tone;

  /// 0..1; draws a thin progress bar under the value when set.
  final double? progress;

  /// Shows a small "live" dot next to the label.
  final bool live;
}

class VisitorProfile {
  const VisitorProfile({
    required this.name,
    required this.initials,
    required this.email,
    required this.phone,
    required this.memberId,
    required this.memberSince,
    required this.totalVisits,
    required this.lastVisited,
  });

  final String name;
  final String initials;
  final String email;
  final String phone;
  final String memberId;
  final String memberSince;
  final String totalVisits;
  final String lastVisited;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.schedule,
    required this.badge,
    required this.icon,
    this.note,
    this.isActive = false,
  });

  final String title;
  final String schedule;
  final String badge;
  final IconData icon;
  final String? note;
  final bool isActive;
}

enum VisitStatus { checkedIn, checkedOut }

class CheckInRecord {
  const CheckInRecord({
    required this.name,
    required this.initials,
    required this.subtitle,
    required this.cardNumber,
    required this.checkInTime,
    required this.purpose,
    required this.status,
    this.checkedOutAt,
  });

  final String name;
  final String initials;
  final String subtitle;
  final String cardNumber;
  final String checkInTime;
  final String purpose;
  final VisitStatus status;
  final String? checkedOutAt;
}
