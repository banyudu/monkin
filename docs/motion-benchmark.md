# Motion Benchmark

The app includes a local A/B curator for deterministic motion-graph pairs.

## Open the curator

Launch Monkin, click the monkey status-bar item, and choose **Open Motion
Benchmark**. The first run creates 150 cases across wave, jump, soccer kick,
tennis swing, and stretch. Candidate A is a baseline graph; candidate B has a
controlled perturbation such as timing, contact, balance, or follow-through.

The UI randomizes which semantic candidate appears on the left. Use the buttons
to label the left/right winner, a tie, or both bad; persisted labels are mapped
back to semantic candidate `a`/`b`. An optional reason is stored with the label.
Labeled cases are skipped when the curator is reopened.

## Files

The dataset is stored locally under:

```text
~/Library/Application Support/Monkin/
  motion-benchmark-cases.jsonl
  motion-benchmark-labels.jsonl
```

The case file contains graph parameters and seeds, not screenshots. A case can
therefore be replayed at any frame rate using `MotionGraphLibrary.pose(for:at:)`.
Labels are append-only JSONL records with `caseID`, `choice`, `reason`, and a
timestamp.

## Implementation

- `MotionGraph.swift` defines the parameterized graphs, seeded generator,
  validation checks, and persistence.
- `MotionBenchmarkWindowController.swift` provides the side-by-side curator.
- `PetView.swift` exposes a deterministic benchmark-driving mode while keeping
  the live animation path unchanged.
