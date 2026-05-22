import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/project_models.dart';
import '../../data/models/tag_entry.dart';
import '../../state/project_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../tagging/config/form_config.dart';
import '../tagging/config/tag_constants.dart';
import 'site_detail_screen.dart';
import 'tag_detail_screen.dart';

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final _search = TextEditingController();
  String _typeFilter = 'All';
  String _categoryFilter = 'All';

  List<String> get _typeFilters => ['All', ...TagTypes.all];

  List<String> _categoriesForType(String type) {
    if (type == 'All') return const ['All'];
    return ['All', ...TagFormConfig.categoriesForTagType(type)];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProjectState>();
    final availableCategories = _categoriesForType(_typeFilter);
    if (!availableCategories.contains(_categoryFilter)) {
      _categoryFilter = 'All';
    }

    final rows = _buildLocationRows(state);
    final query = _search.text.trim().toLowerCase();
    final filtered = rows.where((row) {
      final tag = row.tag;
      final typeOk = _typeFilter == 'All' || tag.tagType == _typeFilter;
      final categoryOk = _categoryFilter == 'All' || tag.category == _categoryFilter;
      final searchOk = query.isEmpty ||
          tag.entityName.toLowerCase().contains(query) ||
          tag.category.toLowerCase().contains(query) ||
          tag.tagType.toLowerCase().contains(query);
      return typeOk && categoryOk && searchOk;
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
              AppSpacing.x3, AppSpacing.x2, AppSpacing.x3, AppSpacing.x1),
          child: Text('All Locations',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: Text(
            '${filtered.length} tags',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search by entity, type, category...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        _filterRail(
          items: _typeFilters,
          selected: _typeFilter,
          labelBuilder: (type) => type == TagTypes.stakeholder ? 'Stake holder' : type,
          onSelect: (type) => setState(() {
            _typeFilter = type;
            _categoryFilter = 'All';
          }),
        ),
        const SizedBox(height: AppSpacing.x1),
        _filterRail(
          items: availableCategories,
          selected: _categoryFilter,
          labelBuilder: (category) => category,
          onSelect: (category) => setState(() => _categoryFilter = category),
          compact: true,
        ),
        const SizedBox(height: AppSpacing.x1),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.x3),
            child: Center(child: Text('No matching locations')),
          )
        else
          ...filtered.map(_tagCard),
      ],
    );
  }

  List<_LocationRecord> _buildLocationRows(ProjectState state) {
    final savedTags = state.latestTags;

    final projectRows = state.projects
        .map(
          (p) => _LocationRecord(
            tag: TagEntry(
              id: p.id?.toString() ?? 'project_${p.updatedAt}',
              tagType: TagTypes.project,
              category: p.segment,
              entityName: p.projectName,
              contactPerson: null,
              phone: null,
              email: null,
              address: null,
              latitude: p.latitude,
              longitude: p.longitude,
              capturedAt: p.updatedAt,
            ),
            project: p,
          ),
        )
        .toList();

    final otherRows = savedTags
        .where((e) => e.tagType != TagTypes.project)
        .map((e) => _LocationRecord(tag: e))
        .toList();

    final rows = [...otherRows, ...projectRows]
      ..sort((a, b) => b.tag.capturedAt.compareTo(a.tag.capturedAt));
    return rows;
  }

  Widget _tagCard(_LocationRecord row) {
    final tag = row.tag;
    final colors = _typeColors(tag.tagType);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.x3, 0, AppSpacing.x3, AppSpacing.x1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onLocationTap(row),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9E8EF), width: 1.1),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                child: Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: colors.fg,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.x2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tag.entityName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                        ),
                        _pill(tag.tagType),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tag.category,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.brand),
                        const SizedBox(width: 4),
                        Text(
                          '${tag.latitude.toStringAsFixed(5)}, ${tag.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterRail({
    required List<String> items,
    required String selected,
    required String Function(String item) labelBuilder,
    required ValueChanged<String> onSelect,
    bool compact = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.x3),
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.x1),
                  child: ChoiceChip(
                    label: Text(labelBuilder(item)),
                    selected: selected == item,
                    onSelected: (_) => onSelect(item),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: BorderSide(
                      color: selected == item ? AppColors.brand : AppColors.border,
                    ),
                    selectedColor: const Color(0xFFE8F5EE),
                    backgroundColor: const Color(0xFFFFFFFF),
                    labelStyle: TextStyle(
                      color: selected == item ? AppColors.brandStrong : AppColors.textSecondary,
                      fontWeight: selected == item ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Future<void> _onLocationTap(_LocationRecord row) async {
    if (row.tag.tagType == TagTypes.project && row.project != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SiteDetailScreen(project: row.project!)),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TagDetailScreen(tag: row.tag)),
    );
  }

  Widget _pill(String type) {
    final colors = _typeColors(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type == TagTypes.stakeholder ? 'Stake holder' : type,
        style: TextStyle(color: colors.fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }

  _TypeColors _typeColors(String type) {
    switch (type) {
      case TagTypes.project:
        return const _TypeColors(
          fg: AppColors.brandStrong,
          bg: Color(0xFFE8F5EE),
          border: Color(0xFF9FD8B1),
        );
      case TagTypes.stakeholder:
        return const _TypeColors(
          fg: AppColors.success,
          bg: Color(0xFFEAF8F1),
          border: Color(0xFF97D5B8),
        );
      case TagTypes.partner:
        return const _TypeColors(
          fg: AppColors.info,
          bg: Color(0xFFEAF0FD),
          border: Color(0xFF9FB8EE),
        );
      default:
        return const _TypeColors(
          fg: Color(0xFF6B7280),
          bg: Color(0xFFF3F4F6),
          border: Color(0xFFD1D5DB),
        );
    }
  }

}

class _LocationRecord {
  const _LocationRecord({required this.tag, this.project});

  final TagEntry tag;
  final Project? project;
}

class _TypeColors {
  const _TypeColors({required this.fg, required this.bg, required this.border});

  final Color fg;
  final Color bg;
  final Color border;
}
