# Implementation Plan: Muscle Heatmap Feature (Body Part Highlight)

## 1. Overview & Objective
Implement a visual "Muscle Heatmap" (Body Map) that highlights targeted muscles based on workout sessions. 
- **Primary Goal:** Display in the Session History detail view (per-session heatmap).
- **Secondary Goal:** Display on the Home Dashboard (7-day weekly heatmap).

---

## 2. Phase 1: Data Infrastructure ✅ COMPLETED

### Insight (Opus): The Gemini plan proposed creating `muscles` and `exercise_muscles` tables on the PostgreSQL backend. However, **this is unnecessary** — the local `ExerciseDictionary` table (seeded from `exercises.json`) already contains `primaryMuscles` and `secondaryMuscles` columns for all 873 exercises. The muscle lookup happens entirely on the Flutter/Drift side.

### Files created:
- `lib/data/muscle_data.dart` — Enum of 17 muscle groups + activation models
- `lib/data/muscle_activation_service.dart` — Cross-references WorkoutSets against ExerciseDictionary

---

## 3. Phase 2: Backend API — **SKIPPED (Not needed)**

---

## 4. Phase 3: Body Map Widget ✅ COMPLETED

### Approach: `flutter_body_part_selector` package (MIT, free, pub.dev)
- Ships with built-in SVG body diagrams (front + back views)
- Has 25 individual Muscle enum values

### Files created:
- `pubspec.yaml` — Added `flutter_body_part_selector: ^1.2.1`
- `lib/widgets/muscle_heatmap_widget.dart` — Bridges MuscleActivationData → package SVG

---

## 5. Phase 4: UI Integration ✅ COMPLETED

### Files modified:

**`lib/features/gym/gym_screen.dart`:**
- `_showSessionDetail()` — Computes muscle activation data per session and shows heatmap between stats row and exercise list
- `_showWorkoutSummary()` — Builds synthetic WorkoutSets from summary exercises, computes activation, and shows heatmap between stats grid and exercise breakdown

**`lib/features/dashboard/dashboard_screen.dart`:**
- Added weekly muscle heatmap card (FutureBuilder) between Calorie section and Activity section
- Only renders if there's workout data in the last 7 days

---

## Summary of All Changes

| File | Status | Description |
|---|---|---|
| `lib/data/muscle_data.dart` | **NEW** | 17 muscle group enums, activation models |
| `lib/data/muscle_activation_service.dart` | **NEW** | Exercise→muscle lookup service |
| `lib/widgets/muscle_heatmap_widget.dart` | **NEW** | Body map widget with front/back flip |
| `lib/features/gym/gym_screen.dart` | **MODIFIED** | Heatmap in session detail + workout summary |
| `lib/features/dashboard/dashboard_screen.dart` | **MODIFIED** | Weekly heatmap card |
| `pubspec.yaml` | **MODIFIED** | Added flutter_body_part_selector dependency |
