import type {detectPitch as DetectPitch} from "music/pitch_detector";
import type {playSequence as PlaySequence} from "music/reference_player";
import {describe, expect, it, vi} from "vitest";
import type {MusicSpec} from "support/music_study_harness";
import MusicStudyController, {
  resetMicActivatedForTests,
} from "controllers/music_study_controller";
import {assert} from "helpers/assert";
import {detectPitch} from "music/pitch_detector";
import {playSequence} from "music/reference_player";
import {
  bootMusicStudy,
  fireFrames,
  holdNote,
  musicForm,
  musicInput,
  musicTarget,
} from "support/music_study_harness";

vi.mock("music/pitch_detector", () => {
  return {detectPitch: vi.fn<typeof DetectPitch>()};
});

vi.mock("music/reference_player", () => {
  return {playSequence: vi.fn<typeof PlaySequence>()};
});

type Spec = MusicSpec<MusicStudyController>;

async function boot(sequence: string): Promise<Spec> {
  return bootMusicStudy(sequence, MusicStudyController);
}

async function started(sequence = "C4"): Promise<Spec> {
  const spec = await boot(sequence);
  await spec.controller.startMic();

  return spec;
}

async function withHeldPlayback(spec: Spec, body: () => void): Promise<void> {
  const resolvers: (() => void)[] = [];
  const playback = new Promise<void>((resolve) => { resolvers.push(resolve); });
  vi.mocked(playSequence).mockReturnValue(playback);
  await spec.controller.startMic();
  const playPromise = spec.controller.play();
  body();
  assert(resolvers[0])();
  await playPromise;
}

afterEach(() => {
  vi.unstubAllGlobals();
  vi.clearAllMocks();
  resetMicActivatedForTests();
});

describe("ticks fired while reference playback is in progress", () => {
  it("ignores detected pitches so speaker bleed cannot advance", async () => {
    const spec = await boot("A4,C5");
    await withHeldPlayback(spec, () => {
      vi.mocked(detectPitch).mockReturnValue(440);
      spec.harness.now.value = 0;
      fireFrames(spec.harness, 1);
      spec.harness.now.value = 300;
      fireFrames(spec.harness, 1);

      expect(musicTarget("progress").textContent).toBe("0 / 2");
    });
  });
});

describe("ticks with no pitch detected", () => {
  it("schedules another frame and leaves progress at 0", async () => {
    const spec = await boot("C4");
    vi.mocked(detectPitch).mockReturnValue(null);

    await spec.controller.startMic();
    fireFrames(spec.harness, 3);

    expect(musicTarget("progress").textContent).toBe("0 / 1");
    expect(spec.harness.raf.request.mock.calls.length).toBeGreaterThan(1);
  });
});

describe("ticks that advance through the sequence", () => {
  it("updates progress after the first held note", async () => {
    const spec = await started("A4,C5");

    holdNote(spec.harness, 440, 0);

    expect(musicTarget("progress").textContent).toBe("1 / 2");
  });

  it("submits the form once the last note is detected", async () => {
    const spec = await started("A4,C5");
    holdNote(spec.harness, 440, 0);
    const submitSpy =
      vi.spyOn(musicForm("form"), "requestSubmit").mockReturnValue();

    holdNote(spec.harness, 523.25, 600);

    expect(submitSpy).toHaveBeenCalledTimes(1);
    expect(musicInput("answerInput").value).toBe("A4,C5");
  });
});

describe("ticks where a wrong note is held", () => {
  async function holdWrong(): Promise<Spec> {
    const spec = await started("A4,C5,E5");
    holdNote(spec.harness, 440, 0);
    holdNote(spec.harness, 587.33, 600);

    return spec;
  }

  it("resets progress to 0 / N", async () => {
    await holdWrong();

    expect(musicTarget("progress").textContent).toBe("0 / 3");
  });

  it("updates the status text", async () => {
    await holdWrong();

    expect(musicTarget("status").textContent).
      toBe("Wrong note — start from the top");
  });

  it("reveals the wrong-note row with the detected note glyph", async () => {
    await holdWrong();

    expect(musicTarget("wrongNote").hidden).toBe(false);
    expect(musicTarget("wrongNoteText").textContent).toBe("D5");
  });
});

function exhaust(spec: Spec): void {
  holdNote(spec.harness, 587.33, 0);
  holdNote(spec.harness, 587.33, 600);
}

describe("wrong-note row visibility on subsequent events", () => {
  it("hides after the user advances correctly", async () => {
    const spec = await started("A4,C5,E5,G5");
    holdNote(spec.harness, 440, 0);
    holdNote(spec.harness, 587.33, 600);
    holdNote(spec.harness, 440, 1200);

    expect(musicTarget("wrongNote").hidden).toBe(true);
  });

  it("keeps the wrong note visible when attempts are exhausted", async () => {
    vi.mocked(playSequence).mockResolvedValue(undefined);
    const spec = await started("A4,C5");
    exhaust(spec);

    expect(musicTarget("wrongNote").hidden).toBe(false);
    expect(musicTarget("wrongNoteText").textContent).toBe("D5");
  });
});

describe("immediate response when attempts are exhausted", () => {
  it("sets the 'Listen again…' status text", async () => {
    vi.mocked(playSequence).mockResolvedValue(undefined);
    const spec = await started("A4,C5");

    exhaust(spec);

    expect(musicTarget("status").textContent).toBe("Listen again…");
  });

  it("ignores detected pitches during the replay delay", async () => {
    vi.useFakeTimers({toFake: ["setTimeout", "clearTimeout"]});
    vi.mocked(playSequence).mockResolvedValue(undefined);
    const spec = await started("A4,C5");

    exhaust(spec);
    holdNote(spec.harness, 440, 1200);
    const progress = musicTarget("progress").textContent;
    vi.useRealTimers();

    expect(progress).toBe("0 / 2");
  });
});

describe("delayed replay when attempts are exhausted", () => {
  it("does not replay until the delay elapses", async () => {
    vi.useFakeTimers({toFake: ["setTimeout", "clearTimeout"]});
    vi.mocked(playSequence).mockResolvedValue(undefined);
    const spec = await started("A4,C5");

    exhaust(spec);
    vi.advanceTimersByTime(999);
    const callsBefore = vi.mocked(playSequence).mock.calls.length;
    vi.useRealTimers();

    expect(callsBefore).toBe(1);
  });

  it("re-invokes playSequence with the same notes", async () => {
    vi.useFakeTimers({toFake: ["setTimeout", "clearTimeout"]});
    vi.mocked(playSequence).mockResolvedValue(undefined);
    const spec = await started("A4,C5");

    exhaust(spec);
    vi.advanceTimersByTime(1000);
    const ctx = assert(spec.harness.audioContexts[0]);
    const {calls} = vi.mocked(playSequence).mock;
    vi.useRealTimers();

    expect(calls).toContainEqual([ctx, ["A4", "C5"]]);
    expect(calls).toHaveLength(2);
  });

  it("swallows errors from a failed auto-replay", async () => {
    vi.useFakeTimers({toFake: ["setTimeout", "clearTimeout"]});
    vi.mocked(playSequence).mockRejectedValue(new Error("audio failed"));
    const spec = await started("A4,C5");

    exhaust(spec);
    vi.advanceTimersByTime(1000);
    await Promise.resolve();
    vi.useRealTimers();

    expect(spec.controller).toBeDefined();
  });
});

describe("disconnect while a replay is pending", () => {
  it("cancels the scheduled replay", async () => {
    vi.useFakeTimers({toFake: ["setTimeout", "clearTimeout"]});
    vi.mocked(playSequence).mockResolvedValue(undefined);
    const spec = await started("A4,C5");

    exhaust(spec);
    spec.controller.disconnect();
    vi.advanceTimersByTime(1000);
    const totalCalls = vi.mocked(playSequence).mock.calls.length;
    vi.useRealTimers();

    expect(totalCalls).toBe(1);
  });
});
