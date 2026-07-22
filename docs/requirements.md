# Wizardlings — Requirements Specification

**Developed by:** B Company (Allan Paredes & Andres Perea)  
**Source Document:** Vision Specification v1.0  
**Spec Version:** 1.0  
**Date:** 2026-07-21  

---

## 1. Purpose

This document defines the functional requirements for Wizardlings. Each requirement describes **what** the system shall do, not **how** it shall be implemented. Requirements are derived from the approved Vision Specification v1.0.

### 1.1 Terminology

- **SHALL** — The requirement is mandatory.
- **SHALL NOT** — The behavior is explicitly prohibited.
- **SHOULD** — The requirement is recommended but not mandatory.
- **Apprentice** — An autonomous wizard entity controlled by the system, not the player.
- **Role** — A magical discipline assigned by the player that permanently changes an apprentice's behavior.
- **Hazard** — Any environmental element that causes apprentice death or damage.
- **Level** — A self-contained puzzle section within the tower.

---

## 2. Apprentice Movement

| ID | Requirement |
|----|-------------|
| MOV-01 | The system shall move all apprentices autonomously via pathfinding without player input. |
| MOV-02 | The system shall not provide the player with any means to directly control apprentice movement direction, speed, or destination. |
| MOV-03 | The system shall cause unattended apprentices (those without roles) to walk into hazards and die if no intervention is made. |
| MOV-04 | The system shall allow multiple apprentices to move simultaneously and independently of one another. |

---

## 3. Role Assignment

| ID | Requirement |
|----|-------------|
| ROL-01 | The system shall allow the player to assign exactly one role to an individual apprentice. |
| ROL-02 | The system shall make role assignment permanent; once a role is assigned, it shall not be revoked or replaced. |
| ROL-03 | The system shall change the assigned apprentice's behavior immediately upon role assignment. |
| ROL-04 | The system shall support exactly four roles: Geomancer, Cryomancer, Aegimancer, and Aeromancer. |
| ROL-05 | The system shall allow the player to assign roles at any point during active gameplay within a level. |
| ROL-06 | The system shall allow role assignment only to living apprentices. |

---

## 4. Geomancer Role

| ID | Requirement |
|----|-------------|
| GEO-01 | The system shall allow the Geomancer to reshape terrain in a way that creates passable ground over gaps. |
| GEO-02 | The system shall allow the Geomancer to build bridges across spike hazards. |
| GEO-03 | The system shall allow the Geomancer to create terrain that grants access to higher elevations. |
| GEO-04 | Terrain created by the Geomancer shall be usable by all apprentices, not only the Geomancer. |

---

## 5. Cryomancer Role

| ID | Requirement |
|----|-------------|
| CRY-01 | The system shall allow the Cryomancer to freeze liquid hazards, rendering them traversable. |
| CRY-02 | The system shall allow the Cryomancer to extinguish flame hazards, neutralizing them. |
| CRY-03 | The system shall allow the Cryomancer to solidify hazardous terrain, converting it to safe ground. |

---

## 6. Aegimancer Role

| ID | Requirement |
|----|-------------|
| AEG-01 | The system shall cause the Aegimancer to project a protective barrier within a small radius around itself. |
| AEG-02 | The barrier shall protect all apprentices within its radius from lethal hazards. |
| AEG-03 | The barrier shall absorb exactly 2 hazard hits before breaking permanently. |
| AEG-04 | Once the barrier is broken, the Aegimancer shall no longer provide protection. |
| AEG-05 | The system shall not allow the barrier to regenerate or be repaired after breaking. |

---

## 7. Aeromancer Role

| ID | Requirement |
|----|-------------|
| AER-01 | The system shall allow the Aeromancer to control wind direction. |
| AER-02 | The system shall allow the Aeromancer's wind to move obstacles. |
| AER-03 | The system shall allow the Aeromancer's wind to propel moving air platforms. |
| AER-04 | The system shall allow the Aeromancer to use air powers to cross gaps. |

---

## 8. Level Structure

| ID | Requirement |
|----|-------------|
| LVL-01 | The system shall organize gameplay into discrete, self-contained levels. |
| LVL-02 | Each level shall have exactly one exit point that apprentices must reach. |
| LVL-03 | Each level shall have a designer-defined win threshold (X) specifying the minimum number of apprentices that must reach the exit. |
| LVL-04 | The system shall present levels as vertical tower sections, with progression moving upward. |
| LVL-05 | Each level shall be completable through planning and correctly-timed role assignments alone. |

---

## 9. Win and Lose Conditions

| ID | Requirement |
|----|-------------|
| WIN-01 | The system shall declare a level won when at least X apprentices reach the exit, where X is the designer-defined threshold for that level. |
| WIN-02 | The system shall declare a level lost when the number of surviving apprentices drops below X and no surviving apprentice can still reach the exit. |
| WIN-03 | The system shall declare a level lost when all apprentices are dead. |
| WIN-04 | The system shall communicate the win threshold X to the player before or at the start of each level. |

---

## 10. Hazards and Death

| ID | Requirement |
|----|-------------|
| HAZ-01 | The system shall kill any unprotected apprentice that contacts a hazard. |
| HAZ-02 | The system shall support the following hazard categories: gaps/pits, spikes, liquids, flames, and hazardous terrain. |
| HAZ-03 | Hazards shall be visually distinguishable from safe terrain at a glance. |

---

## 11. Player Interaction

| ID | Requirement |
|----|-------------|
| INT-01 | The system shall restrict the player's actions during gameplay to role assignment only. |
| INT-02 | The system shall allow the player to select an individual apprentice as the target for role assignment. |
| INT-03 | The system shall provide the player with a view of all available roles and their remaining supply (if limited per level). |

> **[QUESTION]** Is the supply of roles unlimited per level, or does each level provide a limited budget of assignable roles?

---

## 12. Visual Requirements

| ID | Requirement |
|----|-------------|
| VIS-01 | The system shall render all game elements in NES-era pixel art style. |
| VIS-02 | The system should limit sprites to approximately 4 colors each. |
| VIS-03 | The system shall prioritize visual readability over graphical detail in all art assets. |
| VIS-04 | The system shall visually distinguish each wizard role so the player can identify assigned roles at a glance. |
| VIS-05 | The system shall visually distinguish hazard types from safe terrain and from each other. |

---

## 13. Game Flow

| ID | Requirement |
|----|-------------|
| FLW-01 | The system shall present the game as a single-player experience. |
| FLW-02 | The system shall allow the player to progress through levels sequentially. |
| FLW-03 | The system shall allow the player to restart a level after a loss. |

---

## 14. Design Pillar Constraints

These requirements enforce the stated design pillars at a functional level.

| ID | Requirement |
|----|-------------|
| PIL-01 | Every level shall require at least one role assignment to be completed; no level shall be solvable by passively watching. |
| PIL-02 | Each role shall be useful in at least one level; no role shall be vestigial across the game. |
| PIL-03 | The system shall provide clear visual/audio feedback when an apprentice dies, so the player understands what happened. |
| PIL-04 | The system shall ensure hazards are visible before apprentices reach them, giving the player time to react. |

---

## 15. Out of Scope

The following features are explicitly excluded from this requirements set, consistent with the Vision Specification:

- Multiplayer or cooperative modes.
- Persistent progression, upgrades, or meta-systems between levels.
- Undo or rewind mechanics.
- Role revocation after assignment.
- Difficulty selection.
- Dialogue or cutscene systems.

---

## 16. Open Questions

| # | Question | Affects |
|---|----------|---------|
| 1 | Is the supply of roles limited per level (budget) or unlimited? | INT-03, puzzle design |
| 2 | Can the player pause gameplay to plan and assign roles, or is assignment real-time only? | INT-01, difficulty |
| 3 | Is there a time limit per level? | WIN/LOSE conditions |
| 4 | When an apprentice with a role dies, is that role "lost" or returned to the available pool? | ROL-01, puzzle constraints |
| 5 | Do Cryomancer/Geomancer terrain changes persist for the full level, or can they expire? | GEO-01, CRY-01 |
| 6 | Can multiple apprentices hold the same role within a single level? | ROL-01, puzzle design |
| 7 | Does the Aeromancer's wind affect all apprentices or only objects/platforms? | AER-01, emergent behavior |
| 8 | How does the Aegimancer's barrier interact with non-lethal obstacles? | AEG-02, edge cases |

---

*This document defines functional behavior only. Implementation details, architecture decisions, and technical solutions are deferred to the Technical Design Specification.*
