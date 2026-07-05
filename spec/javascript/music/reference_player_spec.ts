import type {AudioContextLike} from "music/reference_player";
import type {Mock} from "vitest";
import {describe, expect, it, vi} from "vitest";
import {ensure} from "helpers/ensure";
import {playSequence} from "music/reference_player";

interface MockGain {
  connect: Mock<(dest: unknown) => void>;
  gain: {setValueAtTime: Mock<(value: number, when: number) => void>};
}

interface MockOscillator {
  connect: Mock<(dest: unknown) => void>;
  frequency: {value: number};
  start: Mock<(when: number) => void>;
  stop: Mock<(when: number) => void>;
  type: OscillatorType;
}

interface Harness {
  ctx: AudioContextLike;
  destination: object;
  gains: MockGain[];
  oscillators: MockOscillator[];
}

function buildGain(): MockGain {
  return {
    connect: vi.fn<(dest: unknown) => void>(),
    gain: {setValueAtTime: vi.fn<(value: number, when: number) => void>()},
  };
}

function buildOscillator(): MockOscillator {
  return {
    connect: vi.fn<(dest: unknown) => void>(),
    frequency: {value: 0},
    start: vi.fn<(when: number) => void>(),
    stop: vi.fn<(when: number) => void>(),
    type: "sawtooth",
  };
}

function buildHarness(currentTime = 0): Harness {
  const oscillators: MockOscillator[] = [];
  const gains: MockGain[] = [];
  const destination = {};
  const ctx: AudioContextLike = {
    createGain: () => {
      const gain = buildGain();
      gains.push(gain);

      return gain;
    },
    createOscillator: () => {
      const osc = buildOscillator();
      oscillators.push(osc);

      return osc;
    },
    currentTime,
    destination,
  };

  return {ctx, destination, gains, oscillators};
}

async function withFakeTimers<T>(fn: () => Promise<T>): Promise<T> {
  vi.useFakeTimers();
  try {
    return await fn();
  } finally {
    vi.useRealTimers();
  }
}

async function playAndFlush(
  harness: Harness,
  notes: string[],
  options: Parameters<typeof playSequence>[2] = {},
): Promise<void> {
  await withFakeTimers(async () => {
    const promise = playSequence(harness.ctx, notes, options);
    await vi.runAllTimersAsync();
    await promise;
  });
}

describe("playSequence creates audio nodes", () => {
  it("creates a fundamental and an octave oscillator per note", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4", "C5"]);

    expect(harness.oscillators).toHaveLength(4);
  });

  it("creates a gain per oscillator", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4", "C5"]);

    expect(harness.gains).toHaveLength(4);
  });

  it("creates no oscillators when notes is empty", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, []);

    expect(harness.oscillators).toHaveLength(0);
  });
});

describe("playSequence configures each oscillator", () => {
  it("uses sine waves throughout", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"]);

    expect(ensure(harness.oscillators[0]).type).toBe("sine");
    expect(ensure(harness.oscillators[1]).type).toBe("sine");
  });

  it("sets the fundamental to the note's frequency", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"]);

    expect(ensure(harness.oscillators[0]).frequency.value).
      toBeCloseTo(440, 5);
  });

  it("sets the octave oscillator to twice the fundamental", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"]);

    expect(ensure(harness.oscillators[1]).frequency.value).
      toBeCloseTo(880, 5);
  });

  it("connects each oscillator to its gain", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"]);

    expect(ensure(harness.oscillators[0]).connect).
      toHaveBeenCalledWith(ensure(harness.gains[0]));
    expect(ensure(harness.oscillators[1]).connect).
      toHaveBeenCalledWith(ensure(harness.gains[1]));
  });

  it("connects gain → destination", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"]);

    expect(ensure(harness.gains[0]).connect).
      toHaveBeenCalledWith(harness.destination);
  });
});

describe("playSequence schedules with default timings", () => {
  it("starts each note 600ms apart by default", async () => {
    const harness = buildHarness(2);
    await playAndFlush(harness, ["A4", "C5"]);

    expect(ensure(harness.oscillators[0]).start).toHaveBeenCalledWith(2);
    expect(ensure(harness.oscillators[2]).start).toHaveBeenCalledWith(2.6);
  });

  it("stops each note 500ms after its start by default", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"]);

    expect(ensure(harness.oscillators[0]).stop).toHaveBeenCalledWith(0.5);
  });
});

describe("playSequence resolves after total duration", () => {
  it("resolves after notes.length * (noteDurationMs + gapMs)", async () => {
    await withFakeTimers(async () => {
      const harness = buildHarness();
      let resolved = false;
      const promise = playSequence(harness.ctx, ["A4", "C5"]).then(() => {
        resolved = true;
      });

      await vi.advanceTimersByTimeAsync(1199);

      expect(resolved).toBe(false);

      await vi.advanceTimersByTimeAsync(1);
      await promise;

      expect(resolved).toBe(true);
    });
  });
});

describe("playSequence honors custom options", () => {
  it("respects a custom noteDurationMs", async () => {
    const harness = buildHarness();
    await playAndFlush(harness, ["A4"], {noteDurationMs: 200});

    expect(ensure(harness.oscillators[0]).stop).toHaveBeenCalledWith(0.2);
  });

  it("respects a custom gapMs in scheduling", async () => {
    const harness = buildHarness();
    await playAndFlush(
      harness,
      ["A4", "C5"],
      {gapMs: 50, noteDurationMs: 200},
    );

    expect(ensure(harness.oscillators[2]).start).toHaveBeenCalledWith(0.25);
  });
});
