class AddTransferState {
  const AddTransferState({
    required this.fromAccountUuid,
    required this.toAccountUuid,
  });

  final String? fromAccountUuid;
  final String? toAccountUuid;

  AddTransferState copyWith({String? fromAccountUuid, String? toAccountUuid}) {
    return AddTransferState(
      fromAccountUuid: fromAccountUuid ?? this.fromAccountUuid,
      toAccountUuid: toAccountUuid ?? this.toAccountUuid,
    );
  }
}

