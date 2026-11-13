import 'package:flutter/material.dart';

import '../../../core/domain/models.dart';
import '../domain/dashboard_models.dart';

/// Turns raw dashboard numbers into the four cards shown at the top.
List<StatCardData> buildStatCards(DashboardStats s) {
  final today = s.todayVisits;
  final yesterday = s.yesterdayVisits;

  String visitsFooter;
  var visitsTone = FooterTone.neutral;
  if (yesterday == 0) {
    visitsFooter = today == 0 ? 'No visits yet today' : 'First visits recorded';
    if (today > 0) visitsTone = FooterTone.positive;
  } else {
    final pct = ((today - yesterday) / yesterday * 100).round();
    visitsFooter =
        '${pct >= 0 ? '+' : ''}$pct% vs. yesterday ($yesterday total)';
    if (pct >= 0) visitsTone = FooterTone.positive;
  }

  final occupancy = s.capacity == 0 ? 0 : (s.inside / s.capacity * 100).round();
  final seatsFree = (s.capacity - s.inside).clamp(0, s.capacity);

  final cardPct = s.registeredToday == 0
      ? null
      : (s.cardsIssuedToday / s.registeredToday * 100).round();

  return [
    StatCardData(
      label: "TODAY'S VISITS",
      icon: Icons.people_outline,
      value: '$today',
      unit: today == 1 ? 'visit today' : 'visits today',
      footer: visitsFooter,
      tone: visitsTone,
    ),
    StatCardData(
      label: 'REGISTERED DIRECTORY',
      icon: Icons.badge_outlined,
      value: '${s.directoryCount}',
      unit: s.directoryCount == 1 ? 'member' : 'members',
      footer: s.newThisWeek == 0
          ? 'No new patrons this week'
          : '+${s.newThisWeek} new patrons added this week',
      tone: s.newThisWeek > 0 ? FooterTone.positive : FooterTone.neutral,
    ),
    StatCardData(
      label: 'CURRENTLY INSIDE',
      icon: Icons.meeting_room_outlined,
      value: '${s.inside}',
      unit: '/${s.capacity} capacity',
      footer: '$occupancy% Net Occupancy | $seatsFree Seats Free',
      progress: s.capacity == 0 ? 0 : (s.inside / s.capacity).clamp(0.0, 1.0),
      live: true,
    ),
    StatCardData(
      label: 'INDUCTIONS TODAY',
      icon: Icons.school_outlined,
      value: '${s.registeredToday}',
      unit: s.registeredToday == 1 ? 'new member' : 'new members',
      footer: cardPct == null
          ? 'No new registrations today'
          : '$cardPct% ID cards issued',
    ),
  ];
}
