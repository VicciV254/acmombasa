import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/domain/app_exception.dart';
import '../../../../core/domain/program_models.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/format_utils.dart';
import '../../application/programs_providers.dart';

const _audiences = [
  'High School & Teen Innovators',
  'University & TVET Students',
  'Youth Exchange Alumni',
  'Educators & Teachers',
  'General Public',
];

/// Create New Program / Session (F4). Returns the created program.
Future<Program?> showCreateProgramDialog(BuildContext context, {DateTime? day}) {
  return showDialog<Program>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CreateProgramDialog(initialDay: day),
  );
}

class _CreateProgramDialog extends ConsumerStatefulWidget {
  const _CreateProgramDialog({this.initialDay});

  final DateTime? initialDay;

  @override
  ConsumerState<_CreateProgramDialog> createState() => _CreateProgramDialogState();
}

class _CreateProgramDialogState extends ConsumerState<_CreateProgramDialog> {
  final _title = TextEditingController();
  final _facilitator = TextEditingController();
  final _note = TextEditingController();
  late DateTime _day = widget.initialDay ?? DateTime.now();
  String _pillar = Pillars.stem;
  String _format = ProgramFormat.inPerson;
  String _recurrence = Recurrence.none;
  String? _room;
  TimeOfDay _start = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 16, minute: 0);
  int _capacity = 16;
  bool _walkIns = true;
  final Set<String> _audience = {_audiences[0], _audiences[1]};
  String _reference = 'PROG-…';
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(sessionRepositoryProvider).nextReference().then((r) {
      if (mounted) setState(() => _reference = r);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _facilitator.dispose();
    _note.dispose();
    super.dispose();
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _submit({required bool publish}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final program = await ref.read(sessionRepositoryProvider).createSession(
            NewSessionInput(
              title: _title.text,
              pillar: _pillar,
              format: _format,
              day: _day,
              startMinute: _minutes(_start),
              endMinute: _minutes(_end),
              recurrence: _recurrence,
              room: _room ?? '',
              capacity: _capacity,
              walkInsAllowed: _walkIns,
              audience: _audience.toList(),
              publish: publish,
              facilitator: _facilitator.text.trim().isEmpty ? null : _facilitator.text.trim(),
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            ),
          );
      if (mounted) Navigator.of(context).pop(program);
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = friendlyError(e);
        });
      }
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day.isBefore(today) ? today : _day,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 2),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: start ? _start : _end,
    );
    if (picked != null) setState(() => start ? _start = picked : _end = picked);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = ref.watch(roomNamesProvider).asData?.value ?? knownRooms.keys.toList();
    final roomLimit = _room == null ? null : knownRooms[_room!];
    final duration = _minutes(_end) - _minutes(_start);
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final nextThu = _nextWeekday(today);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f4): () => _submit(publish: true),
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (!_busy) Navigator.of(context).pop();
        },
      },
      child: Focus(
        autofocus: true,
        child: Dialog(
          backgroundColor: AppColors.surface,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                const Divider(height: 1),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _section('Core Program Information',
                            trailing: '* Required inputs for roster initialization'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: _labeled(
                                'Program / Session Title *',
                                TextField(
                                  controller: _title,
                                  decoration: _deco('e.g. Robotics & AI Innovation Lab'),
                                ),
                                hint: 'Public title displayed on kiosk terminal and reception display badge',
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 5,
                              child: _labeled(
                                'Strategic Pillar / ECA Category *',
                                _dropdown<String>(
                                  value: _pillar,
                                  items: [
                                    for (final p in Pillars.all)
                                      DropdownMenuItem(value: p, child: Text(p)),
                                  ],
                                  onChanged: (v) => setState(() => _pillar = v ?? _pillar),
                                ),
                                hint: 'Classifies metric for Washington ECA reporting',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Delivery Format & Accessibility',
                            style: AppTextStyles.bodyStrong),
                        const SizedBox(height: 6),
                        Row(children: [
                          for (final f in const [
                            (ProgramFormat.inPerson, 'Physical check-in at Mombasa facility'),
                            (ProgramFormat.hybrid, 'Simultaneous Zoom / Teams broadcast'),
                            (ProgramFormat.outreach, 'Held off-site in Coast region county'),
                          ])
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _formatTile(f.$1, f.$2),
                              ),
                            ),
                        ]),
                        const SizedBox(height: 18),
                        _section('Schedule & Room Assignment',
                            trailing: 'Time Zone: East Africa Time (EAT • UTC+3)'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _labeled(
                                'Date of Session',
                                _pickerBox(DateFormatter.fullDate(_day), Icons.calendar_today_outlined, _pickDate),
                                extra: Wrap(spacing: 6, children: [
                                  _quick('Today', today),
                                  _quick('Tomorrow', tomorrow),
                                  _quick('Next ${DateFormatter.weekdayShort(nextThu)}', nextThu),
                                ]),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 5,
                              child: _labeled(
                                'Time Slot & Duration',
                                Row(children: [
                                  Expanded(
                                    child: _pickerBox(_start.format(context), null, () => _pickTime(true)),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: _pickerBox(_end.format(context), null, () => _pickTime(false)),
                                  ),
                                ]),
                                extra: Text(
                                  duration > 0
                                      ? '${formatMinutes(duration)} Total'
                                      : 'End must be after start',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: duration > 0 ? AppColors.success : AppColors.americanRed,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 5,
                              child: _labeled(
                                'Recurrence Frequency',
                                _dropdown<String>(
                                  value: _recurrence,
                                  items: [
                                    for (final r in const [Recurrence.none, Recurrence.daily, Recurrence.weekly])
                                      DropdownMenuItem(value: r, child: Text(Recurrence.label(r))),
                                  ],
                                  onChanged: (v) => setState(() => _recurrence = v ?? _recurrence),
                                ),
                                hint: 'Generates automated calendar series',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _labeled(
                          'Allocated Center Venue / Hall',
                          _dropdown<String?>(
                            value: _room,
                            hint: 'Choose a room',
                            items: [
                              for (final r in rooms)
                                DropdownMenuItem(
                                  value: r,
                                  child: Text(knownRooms[r] == null
                                      ? r
                                      : '$r (Max Capacity: ${knownRooms[r]})'),
                                ),
                            ],
                            onChanged: (v) => setState(() {
                              _room = v;
                              final limit = v == null ? null : knownRooms[v];
                              if (limit != null && _capacity > limit) _capacity = limit;
                            }),
                          ),
                          hint: '${rooms.length} Available Rooms',
                        ),
                        const SizedBox(height: 12),
                        _labeled(
                          'Facilitator(s) (optional)',
                          TextField(
                            controller: _facilitator,
                            decoration: _deco('e.g. Sarah Ochiambo & Fatuma Ali'),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _section('Capacity & Attendee Policies', trailing: 'Kiosk Admission Control'),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: _labeled(
                                'Max Seat Capacity',
                                Row(children: [
                                  IconButton.outlined(
                                    onPressed: _capacity > 1 ? () => setState(() => _capacity--) : null,
                                    icon: const Icon(Icons.remove, size: 16),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text('$_capacity', style: AppTextStyles.cardTitle),
                                    ),
                                  ),
                                  IconButton.outlined(
                                    onPressed: (roomLimit == null || _capacity < roomLimit)
                                        ? () => setState(() => _capacity++)
                                        : null,
                                    icon: const Icon(Icons.add, size: 16),
                                  ),
                                ]),
                                extra: Text(
                                  roomLimit == null
                                      ? 'No room limit on file'
                                      : (_capacity == roomLimit
                                          ? 'Matches room limit ($roomLimit)'
                                          : 'Room limit: $roomLimit'),
                                  style: const TextStyle(fontSize: 11, color: AppColors.success),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 8,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceTinted,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                ),
                                child: Row(children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          const Text('Allow Reception Walk-in Admissions',
                                              style: AppTextStyles.bodyStrong),
                                          const SizedBox(width: 6),
                                          if (_walkIns)
                                            const Text('Active',
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.success)),
                                        ]),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Permits reception desk to fast check-in visitors on-site without prior roster RSVP ticket',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(value: _walkIns, onChanged: (v) => setState(() => _walkIns = v)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Target Audience & Eligibility Filter',
                            style: AppTextStyles.bodyStrong),
                        const SizedBox(height: 6),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final a in _audiences)
                            FilterChip(
                              label: Text(a),
                              selected: _audience.contains(a),
                              showCheckmark: _audience.contains(a),
                              selectedColor: AppColors.navy,
                              labelStyle: TextStyle(
                                fontSize: 12,
                                color: _audience.contains(a) ? Colors.white : AppColors.textSecondary,
                              ),
                              checkmarkColor: Colors.white,
                              onSelected: (v) => setState(
                                  () => v ? _audience.add(a) : _audience.remove(a)),
                            ),
                        ]),
                        const SizedBox(height: 12),
                        _labeled(
                          'Equipment / logistics note (optional)',
                          TextField(
                            controller: _note,
                            decoration: _deco('e.g. 25 discussion handouts, projector, refreshments'),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!,
                              style: const TextStyle(color: AppColors.americanRed, fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(children: const [
                    Icon(Icons.info_outline, size: 14, color: AppColors.brightBlue),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Once published, this session immediately synchronizes with front-desk badge scanning, kiosk kiosks, and the live reception roster.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _submit(publish: false),
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Save as Draft'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel [Esc]'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _submit(publish: true),
                      style: FilledButton.styleFrom(backgroundColor: AppColors.brightBlue),
                      icon: const Icon(Icons.rocket_launch_outlined, size: 16),
                      label: Text(_busy ? 'Saving…' : 'Publish & Open Roster [F4]'),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime _nextWeekday(DateTime from) {
    // "Next Thu" style shortcut: the same weekday one week from today.
    return from.add(const Duration(days: 7));
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.event_available_outlined, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Create New Program / Session', style: AppTextStyles.cardTitle),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.infoSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('DESK SHORTCUT F4',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.info)),
                  ),
                ]),
                const Text(
                  'Schedule an American Spaces educational, cultural, or tech program and initialize attendee roster',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.infoSoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text('$_reference • DRAFT',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.info)),
          ),
          IconButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
          ),
        ]),
      );

  Widget _section(String title, {String? trailing}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Container(width: 3, height: 14, color: AppColors.brightBlue),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.cardTitle),
          const Spacer(),
          if (trailing != null) Text(trailing, style: AppTextStyles.caption),
        ]),
      );

  Widget _labeled(String label, Widget field, {String? hint, Widget? extra}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyStrong),
        const SizedBox(height: 6),
        field,
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(hint, style: AppTextStyles.caption),
        ],
        if (extra != null) ...[const SizedBox(height: 4), extra],
      ],
    );
  }

  InputDecoration _deco(String hint) => InputDecoration(
        isDense: true,
        hintText: hint,
        border: const OutlineInputBorder(),
      );

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return InputDecorator(
      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          isDense: true,
          hint: hint == null ? null : Text(hint),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _pickerBox(String text, IconData? icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
        child: Row(children: [
          Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
          if (icon != null) Icon(icon, size: 16, color: AppColors.textMuted),
        ]),
      ),
    );
  }

  Widget _quick(String label, DateTime d) {
    final selected = DateUtils.isSameDay(_day, d);
    return InkWell(
      onTap: () => setState(() => _day = d),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.infoSoft,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.info,
            )),
      ),
    );
  }

  Widget _formatTile(String value, String sub) {
    final selected = _format == value;
    return InkWell(
      onTap: () => setState(() => _format = value),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppColors.infoSoft : AppColors.surface,
          border: Border.all(color: selected ? AppColors.brightBlue : AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16, color: selected ? AppColors.brightBlue : AppColors.textFaint),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ProgramFormat.label(value),
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 12)),
                Text(sub, style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
