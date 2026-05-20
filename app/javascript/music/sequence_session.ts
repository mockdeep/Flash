import {assert} from "helpers/assert";

interface Candidate {
  note: string;
  since: number;
}

interface SessionState {
  attemptCount: number;
  candidate: Candidate | null;
  nextIndex: number;
  notes: string[];
}

interface DetectedPitch {
  cents: number;
  note: string;
}

interface StepInput {
  detected: DetectedPitch | null;
  holdMs: number;
  now: number;
  toleranceCents: number;
}

type StepEvent = "advanced" | "completed" | "needs_replay" | "noop" | "reset";

interface StepResult {
  detected: string | null;
  event: StepEvent;
  state: SessionState;
}

function initialState(notes: string[]): SessionState {
  return {attemptCount: 0, candidate: null, nextIndex: 0, notes};
}

function clearCandidate(state: SessionState): StepResult {
  if (state.candidate === null) {
    return {detected: null, event: "noop", state};
  }

  return {detected: null, event: "noop", state: {...state, candidate: null}};
}

function startCandidate(
  state: SessionState,
  note: string,
  now: number,
): StepResult {
  return {
    detected: null,
    event: "noop",
    state: {...state, candidate: {note, since: now}},
  };
}

function nextIndexAfter(state: SessionState, matched: boolean): number {
  if (matched) {
    return state.nextIndex + 1;
  }

  return 0;
}

function advanceEvent(matched: boolean): StepEvent {
  if (matched) {
    return "advanced";
  }

  return "reset";
}

function classifyHeldNote(
  state: SessionState,
  detectedNote: string,
): StepResult {
  const expected = assert(state.notes[state.nextIndex]);
  const matched = detectedNote === expected;
  const nextIndex = nextIndexAfter(state, matched);
  const attemptCount = state.attemptCount + 1;
  if (nextIndex >= state.notes.length) {
    return {
      detected: detectedNote,
      event: "completed",
      state: {...state, attemptCount, candidate: null, nextIndex},
    };
  }
  if (attemptCount >= state.notes.length) {
    return {
      detected: detectedNote,
      event: "needs_replay",
      state: {...state, attemptCount: 0, candidate: null, nextIndex: 0},
    };
  }

  return {
    detected: detectedNote,
    event: advanceEvent(matched),
    state: {...state, attemptCount, candidate: null, nextIndex},
  };
}

function isInTolerance(input: StepInput): boolean {
  return input.detected !== null &&
    Math.abs(input.detected.cents) <= input.toleranceCents;
}

function step(state: SessionState, input: StepInput): StepResult {
  if (state.nextIndex >= state.notes.length) {
    return {detected: null, event: "noop", state};
  }
  if (!isInTolerance(input)) {
    return clearCandidate(state);
  }
  const {note} = assert(input.detected);
  if (state.candidate?.note !== note) {
    return startCandidate(state, note, input.now);
  }
  if (input.now - state.candidate.since < input.holdMs) {
    return {detected: null, event: "noop", state};
  }

  return classifyHeldNote(state, note);
}

export {initialState, step};
export type {SessionState, StepEvent, StepInput, StepResult};
