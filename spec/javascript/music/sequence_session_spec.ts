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
  it("starts at index 0 with no candidate and no attempts", () => {
    const state = initialState(["C4", "E4"]);

    expect(state).toStrictEqual({
      attemptCount: 0,
      candidate: null,
      nextIndex: 0,
      notes: ["C4", "E4"],
    });
  });
});

describe("step when the sequence is already complete", () => {
  it("returns noop without altering state", () => {
    const state = {
      attemptCount: 0, candidate: null, nextIndex: 1, notes: ["C4"],
    };
    const input = makeInput({detected: {cents: 0, note: "C4"}, now: 200});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state).toBe(state);
  });
});

describe("step with no pitch detected", () => {
  it("returns the same state and a null detected when no candidate", () => {
    const state = initialState(["C4"]);
    const input = makeInput({detected: null});

    const result = step(state, input);

    expect(result.event).toBe("noop");
    expect(result.state).toBe(state);
    expect(result.detected).toBeNull();
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
    expect(result.detected).toBe("C4");
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

function holdPitchOnce(
  state: SessionState,
  pitch: string,
  startNow: number,
): {event: string; state: SessionState} {
  const start = makeInput({detected: {cents: 0, note: pitch}, now: startNow});
  const afterStart = step(state, start).state;
  const finish =
    makeInput({detected: {cents: 0, note: pitch}, now: startNow + 200});
  const {event, state: nextState} = step(afterStart, finish);

  return {event, state: nextState};
}

function runAttempts(
  notes: string[],
  pitch: string,
): {events: string[]; state: SessionState} {
  let state = initialState(notes);
  const events: string[] = [];
  for (let attempt = 0; attempt < notes.length; attempt += 1) {
    const result = holdPitchOnce(state, pitch, attempt * 400);
    ({state} = result);
    events.push(result.event);
  }

  return {events, state};
}

describe("attempt counting", () => {
  it("increments attemptCount on each classified note", () => {
    const after = holdPitchOnce(initialState(["C4", "E4", "G4"]), "C4", 0);

    expect(after.state.attemptCount).toBe(1);
  });

  it("counts wrong notes too", () => {
    const after = holdPitchOnce(initialState(["C4", "E4", "G4"]), "D4", 0);

    expect(after.state.attemptCount).toBe(1);
  });
});

describe("step when attempts are exhausted without completing", () => {
  it("emits needs_replay on the Nth wrong attack", () => {
    const {events} = runAttempts(["C4", "E4", "G4"], "D4");

    expect(events).toStrictEqual(["reset", "reset", "needs_replay"]);
  });

  it("resets state when needs_replay fires", () => {
    const {state} = runAttempts(["C4", "E4", "G4"], "D4");

    expect(state.attemptCount).toBe(0);
    expect(state.nextIndex).toBe(0);
    expect(state.candidate).toBeNull();
  });
});

describe("completed takes priority over needs_replay", () => {
  it("emits completed when the Nth attack matches the final note", () => {
    let state = initialState(["C4", "E4"]);
    ({state} = holdPitchOnce(state, "C4", 0));
    const final = holdPitchOnce(state, "E4", 400);

    expect(final.event).toBe("completed");
  });
});

describe("step when a held note is wrong", () => {
  it("resets progress and surfaces the detected note", () => {
    const partway: SessionState = {
      attemptCount: 1,
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
    expect(result.detected).toBe("D4");
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
