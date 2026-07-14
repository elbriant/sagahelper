import 'package:flutter_riverpod/flutter_riverpod.dart';

final recruitSelectedTagsProvider =
    NotifierProvider.autoDispose<RecruitSelectedTagsNotifier, RecruitSelectedTags>(
  RecruitSelectedTagsNotifier.new,
);

class RecruitSelectedTags {
  final Set<int> selectedTagIds;
  final List<int> tagStack;

  const RecruitSelectedTags({
    this.selectedTagIds = const {},
    this.tagStack = const [],
  });

  RecruitSelectedTags copyWith({
    Set<int>? selectedTagIds,
    List<int>? tagStack,
  }) {
    return RecruitSelectedTags(
      selectedTagIds: selectedTagIds ?? this.selectedTagIds,
      tagStack: tagStack ?? this.tagStack,
    );
  }

  bool get isEmpty => selectedTagIds.isEmpty;
  bool get isNotEmpty => selectedTagIds.isNotEmpty;
  bool get isFull => selectedTagIds.length >= 10;
  bool get hasTooMany => selectedTagIds.length > 5;
}

class RecruitSelectedTagsNotifier extends Notifier<RecruitSelectedTags> {
  @override
  RecruitSelectedTags build() {
    return const RecruitSelectedTags();
  }

  void toggleTag(int tagId) {
    final newSelected = Set<int>.from(state.selectedTagIds);
    final newStack = List<int>.from(state.tagStack);

    if (newSelected.contains(tagId)) {
      newSelected.remove(tagId);
      newStack.remove(tagId);
    } else if (newSelected.length < 10) {
      newSelected.add(tagId);
      newStack.add(tagId);
    } else {
      return;
    }

    state = state.copyWith(
      selectedTagIds: newSelected,
      tagStack: newStack,
    );
  }

  void addTag(int tagId) {
    if (state.selectedTagIds.contains(tagId) || state.isFull) return;

    state = state.copyWith(
      selectedTagIds: {...state.selectedTagIds, tagId},
      tagStack: [...state.tagStack, tagId],
    );
  }

  void removeLastTag() {
    if (state.tagStack.isEmpty) return;

    final lastTagId = state.tagStack.last;
    final newSelected = Set<int>.from(state.selectedTagIds)..remove(lastTagId);
    final newStack = List<int>.from(state.tagStack)..removeLast();

    state = state.copyWith(
      selectedTagIds: newSelected,
      tagStack: newStack,
    );
  }

  void reset() {
    state = const RecruitSelectedTags();
  }
}
