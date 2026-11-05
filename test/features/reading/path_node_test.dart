import 'package:flutter_test/flutter_test.dart';
import 'package:kidslearn_ai/data/models/story.dart';
import 'package:kidslearn_ai/data/models/story_status.dart';
import 'package:kidslearn_ai/features/reading/controllers/path_node.dart';

Story makeStory(String id) {
  return Story(
    id: id,
    parentId: 'parent-1',
    childId: 'child-1',
    promptText: '',
    promptValue: 'Sharing',
    title: 'Story $id',
    moralValue: 'Sharing',
    language: 'en',
    characterSheet: '',
    seed: 1,
    status: StoryStatus.ready,
    approved: true,
    createdAt: DateTime(2026, 11, 1),
  );
}

List<PathNodeState> statesOf(List<PathNode> nodes) {
  return nodes.map((node) => node.state).toList();
}

void main() {
  final stories = [makeStory('a'), makeStory('b'), makeStory('c')];

  // ── Nothing finished yet: only story 1 opens (SRS 10.10, D1) ──
  test('with nothing finished, story 1 is current and the rest locked', () {
    final nodes = buildPathNodes(stories, {});

    expect(statesOf(nodes), [
      PathNodeState.current,
      PathNodeState.locked,
      PathNodeState.locked,
    ]);
    expect(nodes.map((node) => node.number).toList(), [1, 2, 3]);
    expect(nodes[0].canOpen, isTrue);
    expect(nodes[1].canOpen, isFalse);
  });

  test('finishing story 1 makes story 2 current', () {
    final nodes = buildPathNodes(stories, {'a'});

    expect(statesOf(nodes), [
      PathNodeState.finished,
      PathNodeState.current,
      PathNodeState.locked,
    ]);
  });

  test('when all are finished, there is no current story', () {
    final nodes = buildPathNodes(stories, {'a', 'b', 'c'});

    expect(statesOf(nodes), [
      PathNodeState.finished,
      PathNodeState.finished,
      PathNodeState.finished,
    ]);
    expect(nodes.every((node) => node.canOpen), isTrue);
  });

  test('a finished story after the current one stays open', () {
    final nodes = buildPathNodes(stories, {'c'});

    expect(statesOf(nodes), [
      PathNodeState.current,
      PathNodeState.locked,
      PathNodeState.finished,
    ]);
  });

  test('no stories gives an empty path', () {
    expect(buildPathNodes([], {}), isEmpty);
  });
}
