# Wizardlings — Vision Specification

**Developed by:** B Company (Allan Paredes & Andres Perea)  
**Source Document:** One-Page GDD v0.1  
**Spec Version:** 1.0  
**Date:** 2026-07-21  

---

## 1. Product Vision

Wizardlings is a Lemmings-inspired puzzle game where the player guides a group of reckless apprentice wizards climbing a magical tower in search of the Eschaton. The player does not control movement directly; instead, they assign magical disciplines that grant unique spells and alter apprentice behavior, allowing the group to overcome increasingly dangerous obstacles.

### 1.1 Core Fantasy

Lead a group of incompetent apprentice wizards to the top of a magical tower by assigning the right magical disciplines at the right time.

### 1.2 Reference Genre

Puzzle / Lemmings-like

---

## 2. Game Loop

```
Observe apprentices → Identify obstacle → Assign magic role → Role changes apprentice behavior → Reach next section → Repeat
```

The player's agency is entirely expressed through role assignment. Timing and planning are the primary skills tested.

---

## 3. Core Mechanics

| Mechanic | Description |
|----------|-------------|
| Automatic movement | Apprentices move autonomously via pathfinding. |
| No direct movement control | The player cannot influence movement direction or speed. |
| Role assignment | The player assigns magical roles to individual apprentices. |
| Permanent role change | Once assigned, a role permanently alters that apprentice's behavior. |
| Planning & timing | Levels are solved through pre-planning and correctly-timed role assignments. |

---

## 4. Win / Lose Conditions

### Win
- At least **X** apprentices reach the level exit.

### Lose
- Too many apprentices die (below the threshold X).
- All apprentices die.

> **[QUESTION]** What determines X per level? Is it a fixed number, a percentage of the group, or a designer-set value per level?
Designer-defined per level.
---

## 5. Wizard Roles

| Role | Personality | Abilities |
|------|-------------|-----------|
| **Geomancer** | Hardworking | Controls the ground. Can cross gaps, build bridges across spikes, and reach higher places. |
| **Cryomancer** | Lazy | Freezes liquids, extinguishes flames, and solidifies hazardous terrain. |
| **Aegimancer** | Courageous | Projects protective barriers that allow nearby apprentices to pass through lethal hazards. Barrier absorbs exactly 2 hazard hits before breaking. |
| **Aeromancer** | Free-spirited | Controls wind direction. Can move obstacles, create air platforms, and jump gaps using air powers. |

> **[QUESTION]** The GDD lists an empty bullet between Aegimancer and Aeromancer. Was a fifth role planned or is this a formatting artifact?
Just a mistake
> **[QUESTION]** "Nearby apprentices" for Aegimancer — is this a radius-based area effect or does it apply to all apprentices currently on-screen / in the same section?
Its around a small radius effect.
> **[QUESTION]** Geomancer "can cross gaps" — does the Geomancer personally fly/jump over gaps, or do they create terrain that the entire group can use?
The Geomancer reshapes terrain for everyone, not just themselves.
> **[QUESTION]** Aeromancer "air platforms" — are these persistent platforms or temporary gusts that only function while the Aeromancer is active nearby?
By air platforms i mean moving platforms in the sky.
---

## 6. Design Pillars

1. **Meaningful role assignment** — Every role assignment in every level should feel like a deliberate, impactful decision.
2. **Unreliable apprentices** — Apprentices require constant player intervention; left unattended, they will walk to their death.
3. **Readable level design** — The player should always understand why something happened and how they can redo or avoid it.

---

## 7. World & Narrative

### Setting
A vertical magical tower. The game progresses upward.

### The Eschaton
A tome at the summit believed to contain the entirety of existence. Every wizard aspires to reach it, viewing its knowledge as the highest form of enlightenment.

### Narrative Truth
The Eschaton does contain the complete history of existence — everything that was, is, and will be. Whoever reaches it gains perfect knowledge of reality **but not the power to alter it**.

> **[QUESTION]** Does the narrative truth get revealed to the player at the end, or is it hinted at throughout? Is there an in-game consequence to "perfect knowledge without power"?

---

## 8. Art Style

- **Pixel art** reminiscent of the NES era.
- **Limited color palette** — approximately 4 colors per sprite.
- **Readability over detail** — visual clarity is prioritized above all else.

> **[QUESTION]** "4 colors per sprite?" was phrased as a question in the GDD. Should this be treated as a hard constraint (strict NES palette rules) or a guideline (NES-inspired, roughly 4 colors)?

---

## 9. Scope Boundaries (Inferred from GDD)

The following are explicitly present in the GDD and form the confirmed scope:

- Single-player puzzle game.
- Level-based progression (tower sections).
- 4 wizard roles (Geomancer, Cryomancer, Aegimancer, Aeromancer).
- Automatic deterministic movement. Apprentices continuously walk in their current direction until interacting with terrain or an obstacle that changes their behavior.
- Win/lose threshold system.
- NES-era pixel art.

The following are **not mentioned** in the GDD and are considered out of scope unless explicitly added:

- Multiplayer or co-op.
- Story cutscenes or dialogue systems.
- Upgrade systems or persistent progression between levels.
- Undo/rewind mechanic.
- Role revocation (removing a role once assigned).
- Difficulty settings.
- Tutorial system.
- Sound design or music direction.
- Target platform(s).
- Level count or estimated play time.

---

## 10. Open Questions Summary

| # | Question | Section |
|---|----------|---------|
| 1 | What determines X (win threshold) per level? Fixed number, percentage, or designer-set? | Win/Lose |
| 2 | Is there a planned fifth wizard role, or is the empty GDD bullet a formatting artifact? | Roles |
| 3 | What is the Aegimancer's barrier radius — proximity-based, screen-wide, or section-wide? | Roles |
| 4 | Does the Geomancer personally traverse gaps, or does it create terrain for the group? | Roles |
| 5 | Are Aeromancer air platforms persistent or temporary? | Roles |
| 6 | Is the Eschaton's truth revealed at endgame? Are there narrative consequences? | World |
| 7 | Is the 4-colors-per-sprite rule a hard constraint or a guideline? | Art |
| 8 | What are the target platform(s)? | Scope |
| 9 | Is there any sound/music direction planned? | Scope |
| 10 | Approximately how many levels or how long is the intended play time? | Scope |

---

*This document faithfully reflects the One-Page GDD v0.1 without introducing new mechanics, systems, or scope. All ambiguities are surfaced as questions for the design team to resolve.*
