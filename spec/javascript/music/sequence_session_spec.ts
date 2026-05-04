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

describe("initialState", () => {
  it("starts at index 0 with no candidate", () => {
    const state = initialState(["C4", "E4"]);

    expect(state).toStrictEqual({
      candidate: null,
      nextIndex: 0,
      notes: ["C4", "E4"],
    });
  });
});

describe("step when the sequence is already complete", () => {
  it("returns noop without altering state", () => {
    const state = {candidate: null, nextIndex: 1, notes: ["C4"]};
    const input = makeInput({detected: {cents: 0, note: "C4"}, now: 200});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state).toBe(state);
  });
});

describe("step with no pitch detected", () => {
  it("returns the same state when there is no candidate", () => {
    const state = initialState(["C4"]);
    const input = makeInput({detected: null});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state).toBe(state);
  });

  it("clears the candidate when one was being held", () => {
    const state = holding(initialState(["C4"]), "C4", 0);
    const input = makeInput({detected: null, now: 50});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state.candidate).toBeNull();
  });
});

describe("step with pitch outside cent tolerance", () => {
  it("treats it as no pitch and keeps progress", () => {
    const state = initialState(["C4", "E4"]);
    const input =
      makeInput({detected: {cents: 80, note: "C4"}, now: 10});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state.candidate).toBeNull();
  });

  it("clears an existing candidate", () => {
    const state = holding(initialState(["C4"]), "C4", 0);
    const input =
      makeInput({detected: {cents: 60, note: "C4"}, now: 50});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state.candidate).toBeNull();
  });
});

describe("step with a fresh in-tolerance pitch", () => {
  it("starts a candidate when none exists", () => {
    const state = initialState(["C4", "E4"]);
    const input =
      makeInput({detected: {cents: 5, note: "C4"}, now: 100});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state.candidate).toStrictEqual({note: "C4", since: 100});
  });

  it("replaces a candidate when the note changes", () => {
    const state = holding(initialState(["C4"]), "D4", 0);
    const input =
      makeInput({detected: {cents: 5, note: "F4"}, now: 70});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state.candidate).toStrictEqual({note: "F4", since: 70});
  });
});

describe("step while a candidate is still being held", () => {
  it("returns noop without changing state", () => {
    const state = holding(initialState(["C4"]), "C4", 0);
    const input =
      makeInput({detected: {cents: 5, note: "C4"}, now: 50});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state).toBe(state);
  });
});

describe("step when a held note classifies as the expected note", () => {
  it("advances to the next index when more notes remain", () => {
    const state = holding(initialState(["C4", "E4"]), "C4", 0);
    const input =
      makeInput({detected: {cents: 0, note: "C4"}, now: 200});

    const result = step(state, input);

    expect(result.event).toBe("advanced");
    expect(result.state.nextIndex).toBe(1);
    expect(result.state.candidate).toBeNull();
  });

  it("emits 'completed' when the last note is reached", () => {
    const state = holding(initialState(["C4"]), "C4", 0);
    const input =
      makeInput({detected: {cents: 0, note: "C4"}, now: 200});

    const result = step(state, input);

    expect(result.event).toBe("completed");
    expect(result.state.nextIndex).toBe(1);
  });
});

describe("step when a held note is wrong", () => {
  it("resets progress to the start of the sequence", () => {
    const partway: SessionState = {
      candidate: {note: "D4", since: 0},
      nextIndex: 1,
      notes: ["C4", "E4", "G4"],
    };
    const input =
      makeInput({detected: {cents: 0, note: "D4"}, now: 200});

    const result = step(partway, input);

    expect(result.event).toBe("reset");
    expect(result.state.nextIndex).toBe(0);
    expect(result.state.candidate).toBeNull();
  });
});

describe("step over a realistic frame sequence", () => {
  it("walks through C4 → E4 → G4 with held notes between", () => {
    const notes = ["C4", "E4", "G4"];
    let state = initialState(notes);

    const frames: StepInput[] = [
      makeInput({detected: {cents: 0, note: "C4"}, now: 0}),
      makeInput({detected: {cents: 0, note: "C4"}, now: 200}),
      makeInput({detected: null, now: 300}),
      makeInput({detected: {cents: 0, note: "E4"}, now: 400}),
      makeInput({detected: {cents: 0, note: "E4"}, now: 600}),
      makeInput({detected: null, now: 700}),
      makeInput({detected: {cents: 0, note: "G4"}, now: 800}),
      makeInput({detected: {cents: 0, note: "G4"}, now: 1000}),
    ];
    const events: string[] = [];

    for (const input of frames) {
      const {event, state: nextState} = step(state, input);
      state = nextState;
      events.push(event);
    }

    expect(events).
      toStrictEqual([
        "noop",
        "advanced",
        "noop",
        "noop",
        "advanced",
        "noop",
        "noop",
        "completed",
      ]);
    expect(state.nextIndex).toBe(3);
  });
});
