# Monkin Sports Animation Design

## Goals

Sports actions should read as small physical stories, not isolated poses. Each
scene has four phases:

1. Preparation: Monkin notices or reaches for the prop.
2. Action: the body and prop move together with anticipation and follow-through.
3. Result: the prop travels, collides, lands, or splashes.
4. Recovery: Monkin reacts, resets, or resumes roaming.

Props and environments are world objects. A water pool, goal, or hoop must stay
fixed to the screen while Monkin's transparent window moves through the scene.

## First batch

| Scene | Preparation | Action | Result |
| --- | --- | --- | --- |
| Soccer | Monkin tracks a ball near the feet | Wind-up and kick | Ball arcs toward a goal; celebrate or miss |
| Basketball | Ball settles at ground level | Two dribbles and jump shot | Ball reaches hoop; celebrate or recover |
| Tennis | Ball bounces across the court | Racket swing with follow-through | Ball crosses the screen |
| Diving | Pool appears at the bottom of the display | Monkin runs and jumps from a high position | Sink below the waterline; splash; return |
| Swimming | Monkin enters the pool | Alternating strokes and kicks | Water ripples; head bobs above water |
| Skateboarding | Board rolls under the feet | Lean and push | Smooth horizontal glide |
| Jump rope | Rope attaches to both hands | Rope cycles under the feet | Jump rhythm stays synchronized |
| Weightlifting | Barbell rises to hand height | Squat and overhead press | Hold, strain, then lower safely |

## Motion rules

- Use anticipation before fast actions and follow-through after contact.
- Keep props close to the hands or feet during preparation.
- Use a separate screen-coordinate scene for fixed environments.
- Keep each scene short: 2–5 seconds, then return to roaming.
- Sports are selected randomly, with a visible sports action within roughly one
  minute of idle observation.
- Log only the selected scene and result. Do not log screen text or screenshots.

## Implementation map

- `MonkinMotion.swift`: public scene names and selection weighting.
- `PetView.swift`: body poses and keyframe-like motion phases.
- `SportsPropView.swift`: procedural props attached to the Monkin scene.
- `WaterPoolWindow.swift`: screen-fixed pool used by the diving scene.
- `PetWindowController.swift`: scene timing, world movement, and recovery.
