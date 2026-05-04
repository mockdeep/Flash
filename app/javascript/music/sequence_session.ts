import {assert} from "helpers/assert";

interface Candidate {
  note: string;
  since: number;
}

interface SessionState {
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

type StepEvent = "advanced" | "completed" | "noop" | "reset";

interface StepResult {
  event: StepEvent;
  state: SessionState;
}

function initialState(notes: string[]): SessionState {
  return {candidate: null, nextIndex: 0, notes};
}

function clearCandidate(state: SessionState): StepResult {
  if (state.candidate === null) {
    return {event: "noop", state};
  }

  return {event: "noop", state: {...state, candidate: null}};
}

function startCandidate(
  state: SessionState,
  note: string,
  now: number,
): StepResult {
  return {
    event: "noop",
    state: {...state, candidate: {note, since: now}},
  };
}

function classifyHeldNote(
  state: SessionState,
  detectedNote: string,
): StepResult {
  const expected = assert(state.notes[state.nextIndex]);
  if (detectedNote !== expected) {
    return {
      event: "reset",
      state: {...state, candidate: null, nextIndex: 0},
    };
  }
  const newIndex = state.nextIndex + 1;
  const isComplete = newIndex >= state.notes.length;
  let event: StepEvent = "advanced";
  if (isComplete) {
    event = "completed";
  }

  return {
    event,
    state: {...state, candidate: null, nextIndex: newIndex},
  };
}

function isInTolerance(input: StepInput): boolean {
  return input.detected !== null &&
    Math.abs(input.detected.cents) <= input.toleranceCents;
}

function step(state: SessionState, input: StepInput): StepResult {
  if (state.nextIndex >= state.notes.length) {
    return {event: "noop", state};
  }
  if (!isInTolerance(input)) {
    return clearCandidate(state);
  }
  const {note} = assert(input.detected);
  if (state.candidate?.note !== note) {
    return startCandidate(state, note, input.now);
  }
  if (input.now - state.candidate.since < input.holdMs) {
    return {event: "noop", state};
  }

  return classifyHeldNote(state, note);
}

export {initialState, step};
export type {SessionState, StepEvent, StepInput, StepResult};
