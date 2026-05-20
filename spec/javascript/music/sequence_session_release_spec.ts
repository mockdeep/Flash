import type {SessionState, StepInput} from "music/sequence_session";
import {describe, expect, it} from "vitest";
import {initialState, step} from "music/sequence_session";

const TOLERANCE = 50;
const HOLD_MS = 150;

function makeInput(overrides: Partial<StepInput> = {}): StepInput {
  return {
    detected: null,
    holdMs: HOLD_MS,
    now: 0,
    toleranceCents: TOLERANCE,
    ...overrides,
  };
}

function holding(
  state: SessionState,
  note: string,
  since: number,
): SessionState {
  return {...state, candidate: {note, since}};
}

function advanced(): SessionState {
  const start = holding(initialState(["C4", "E4"]), "C4", 0);
  const tone = {cents: 0, note: "C4"};
  const {state} = step(start, makeInput({detected: tone, now: 200}));

  return state;
}

describe("release gate after a classification", () => {
  it("sets awaitingRelease after advancing mid-sequence", () => {
    expect(advanced().awaitingRelease).toBe(true);
  });

  it("leaves awaitingRelease false on completion", () => {
    const state = holding(initialState(["C4"]), "C4", 0);
    const result =
      step(state, makeInput({detected: {cents: 0, note: "C4"}, now: 200}));

    expect(result.state.awaitingRelease).toBe(false);
  });

  it("ignores a sustained match of the just-classified pitch", () => {
    const tone = {cents: 0, note: "C4"};
    const result = step(advanced(), makeInput({detected: tone, now: 400}));

    expect(result.event).toBe("noop");
    expect(result.state.awaitingRelease).toBe(true);
  });

  it("clears the gate when an out-of-tolerance frame arrives", () => {
    const result = step(advanced(), makeInput({detected: null, now: 300}));

    expect(result.state.awaitingRelease).toBe(false);
    expect(result.state.candidate).toBeNull();
  });

  it("releases and starts a candidate when a different pitch arrives", () => {
    const tone = {cents: 0, note: "E4"};
    const result = step(advanced(), makeInput({detected: tone, now: 400}));

    expect(result.state.awaitingRelease).toBe(false);
    expect(result.state.candidate).toStrictEqual({note: "E4", since: 400});
  });

  it("classifies the next note when held after a fast pitch change", () => {
    const tone = {cents: 0, note: "E4"};
    const released =
      step(advanced(), makeInput({detected: tone, now: 400}));
    const classified =
      step(released.state, makeInput({detected: tone, now: 600}));

    expect(classified.event).toBe("completed");
  });
});
