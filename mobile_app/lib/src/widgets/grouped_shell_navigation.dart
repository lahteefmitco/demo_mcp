import 'package:flutter/material.dart';

/// Bottom bar: Home, Dashboard, Report, Settings in one band, then a divider,
/// then Chat as a second visual group (matches shell indices 0–4).
class GroupedShellBottomNavigationBar extends StatelessWidget {
  const GroupedShellBottomNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  static const _main = <_NavSpec>[
    _NavSpec(
      index: 0,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    _NavSpec(
      index: 1,
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavSpec(
      index: 2,
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment,
      label: 'Report',
    ),
    _NavSpec(
      index: 3,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  static const _chat = _NavSpec(
    index: 4,
    icon: Icons.chat_bubble_outline,
    selectedIcon: Icons.chat_bubble,
    label: 'Chat',
  );

  /// More horizontal space for Home–Settings than for Chat (was 5:2 ≈ 71:29).
  static const int _mainGroupFlex = 8;
  static const int _chatGroupFlex = 2;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).navigationBarTheme.backgroundColor ??
        scheme.surfaceContainer;

    return Material(
      elevation: 3,
      color: surface,
      surfaceTintColor:
          Theme.of(context).navigationBarTheme.surfaceTintColor ??
              scheme.surfaceTint,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: _mainGroupFlex,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final spec in _main)
                      Expanded(
                        child: _BottomNavSlot(
                          spec: spec,
                          selected: selectedIndex == spec.index,
                          onTap: () => onDestinationSelected(spec.index),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 40,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: scheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Expanded(
                flex: _chatGroupFlex,
                child: _BottomNavSlot(
                  spec: _chat,
                  selected: selectedIndex == _chat.index,
                  onTap: () => onDestinationSelected(_chat.index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [NavigationRail] with four primary destinations and Chat in [trailing].
class GroupedShellNavigationRail extends StatelessWidget {
  const GroupedShellNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.extended,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final railIndex = selectedIndex < 4 ? selectedIndex : null;

    return NavigationRail(
      extended: extended,
      selectedIndex: railIndex,
      onDestinationSelected: onDestinationSelected,
      // extended rail shows labels inline; Material disallows labelType.all here.
      labelType: extended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.assessment_outlined),
          selectedIcon: Icon(Icons.assessment),
          label: Text('Report'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
      ],
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: extended ? 16 : 8,
                  ),
                  child: Divider(
                    height: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                _RailChatDestination(
                  selected: selectedIndex == 4,
                  extended: extended,
                  onTap: () => onDestinationSelected(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSpec {
  const _NavSpec({
    required this.index,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _BottomNavSlot extends StatelessWidget {
  const _BottomNavSlot({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barTheme = Theme.of(context).navigationBarTheme;
    final indicatorColor = barTheme.indicatorColor ?? scheme.secondaryContainer;
    final iconColor = selected
        ? (barTheme.iconTheme?.resolve({WidgetState.selected})?.color ??
            scheme.onSecondaryContainer)
        : scheme.onSurfaceVariant;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 12,
          color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? indicatorColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                selected ? spec.selectedIcon : spec.icon,
                size: 24,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              spec.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: labelStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _RailChatDestination extends StatelessWidget {
  const _RailChatDestination({
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant;
    final bg = selected ? scheme.secondaryContainer : Colors.transparent;

    final icon = Icon(
      selected ? Icons.chat_bubble : Icons.chat_bubble_outline,
      color: foreground,
    );

    final label = Text(
      'Chat',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: foreground,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: extended
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: icon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    label,
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: icon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    label,
                  ],
                ),
        ),
      ),
    );
  }
}
