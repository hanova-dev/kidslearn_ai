import '../../../data/models/story.dart';

/// How one circle on the path looks and whether it can be tapped.
enum PathNodeState { finished, current, locked }

/// One circle on the child's path map: a story, its number and its state.
class PathNode {
  const PathNode({
    required this.story,
    required this.number,
    required this.state,
  });

  final Story story;

  /// 1 for the oldest story, at the bottom of the path.
  final int number;
  final PathNodeState state;

  /// Finished and current stories open; locked ones do not (SRS 10.10).
  bool get canOpen => state != PathNodeState.locked;
}

/// Builds the path: finished stories stay open, the first unfinished one is current, the rest are locked.
List<PathNode> buildPathNodes(List<Story> stories, Set<String> finishedIds) {
  final nodes = <PathNode>[];
  var currentFound = false;
  for (var i = 0; i < stories.length; i++) {
    final story = stories[i];

    // ── Pick the state of this circle ──
    PathNodeState state;
    if (finishedIds.contains(story.id)) {
      state = PathNodeState.finished;
    } else if (!currentFound) {
      state = PathNodeState.current;
      currentFound = true;
    } else {
      state = PathNodeState.locked;
    }

    nodes.add(PathNode(story: story, number: i + 1, state: state));
  }
  return nodes;
}
