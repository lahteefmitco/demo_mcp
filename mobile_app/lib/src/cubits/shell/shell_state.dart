/// State for bottom navigation shell.
class ShellState {
  const ShellState({required this.selectedIndex});

  final int selectedIndex;

  ShellState copyWith({int? selectedIndex}) {
    return ShellState(selectedIndex: selectedIndex ?? this.selectedIndex);
  }
}

