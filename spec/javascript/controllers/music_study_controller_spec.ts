import type {detectPitch as DetectPitch} from "music/pitch_detector";
import type {playSequence as PlaySequence} from "music/reference_player";
import {describe, expect, it, vi} from "vitest";
import type {MusicSpec} from "support/music_study_harness";
import MusicStudyController from "controllers/music_study_controller";
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

afterEach(() => {
  vi.unstubAllGlobals();
});

describe("connect", () => {
  it("renders progress for the parsed sequence", async () => {
    await boot("C4,E4,G4");

    expect(musicTarget("progress").textContent).toBe("0 / 3");
  });
});

describe("startMic when access is denied", () => {
  async function denied(): Promise<Spec> {
    const spec = await boot("C4");
    spec.harness.getUserMedia.mockRejectedValueOnce(new Error("denied"));
    await spec.controller.startMic();

    return spec;
  }

  it("shows an access-denied status text", async () => {
    await denied();

    expect(musicTarget("status").textContent).
      toBe("Microphone access denied");
  });

  it("does not request animation frames", async () => {
    const spec = await denied();

    expect(spec.harness.raf.request).not.toHaveBeenCalled();
  });
});

describe("startMic when access is granted", () => {
  async function start(notes = "C4"): Promise<Spec> {
    const spec = await boot(notes);
    await spec.controller.startMic();

    return spec;
  }

  it("creates an AudioContext", async () => {
    const spec = await start();

    expect(spec.harness.audioContexts).toHaveLength(1);
  });

  it("connects the mic source to a 4096-sized analyser", async () => {
    const spec = await start();
    const ctx = assert(spec.harness.audioContexts[0]);

    expect(ctx.analyser.fftSize).toBe(4096);
    expect(ctx.source.connect).toHaveBeenCalledWith(ctx.analyser);
  });

  it("hides the start button and reveals the play button", async () => {
    await start();

    expect(musicTarget("startButton").hidden).toBe(true);
    expect(musicTarget("playButton").hidden).toBe(false);
  });

  it("schedules the first animation frame", async () => {
    const spec = await start();

    expect(spec.harness.raf.request).toHaveBeenCalledTimes(1);
  });
});

describe("play before the mic has been started", () => {
  it("does not call playSequence", async () => {
    const spec = await boot("C4");

    await spec.controller.play();

    expect(playSequence).not.toHaveBeenCalled();
  });
});

describe("play after the mic has been started", () => {
  async function startThenPlay(): Promise<Spec> {
    const spec = await boot("C4,E4");
    vi.mocked(playSequence).mockResolvedValueOnce(undefined);
    await spec.controller.startMic();
    await spec.controller.play();

    return spec;
  }

  it("calls playSequence with the audio context and parsed notes", async () => {
    const spec = await startThenPlay();
    const ctx = assert(spec.harness.audioContexts[0]);

    expect(playSequence).toHaveBeenCalledWith(ctx, ["C4", "E4"]);
  });

  it("updates the status to prompt the user to play", async () => {
    await startThenPlay();

    expect(musicTarget("status").textContent).toBe("Now play it back!");
  });
});

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
    const spec = await boot("A4,C5");
    await spec.controller.startMic();

    holdNote(spec.harness, 440, 0);

    expect(musicTarget("progress").textContent).toBe("1 / 2");
  });

  it("submits the form once the last note is detected", async () => {
    const spec = await boot("A4,C5");
    await spec.controller.startMic();
    holdNote(spec.harness, 440, 0);
    const formEl = musicForm("form");
    const submitSpy = vi.spyOn(formEl, "requestSubmit").mockReturnValue();

    holdNote(spec.harness, 523.25, 600);

    expect(submitSpy).toHaveBeenCalledTimes(1);
    expect(musicInput("answerInput").value).toBe("A4,C5");
  });
});

describe("ticks where a wrong note is held", () => {
  async function holdWrong(): Promise<Spec> {
    const spec = await boot("A4,C5");
    await spec.controller.startMic();
    holdNote(spec.harness, 440, 0);
    holdNote(spec.harness, 587.33, 600);

    return spec;
  }

  it("resets progress to 0 / N", async () => {
    await holdWrong();

    expect(musicTarget("progress").textContent).toBe("0 / 2");
  });

  it("updates the status text", async () => {
    await holdWrong();

    expect(musicTarget("status").textContent).
      toBe("Wrong note — start from the top");
  });
});

describe("a frame that fires after disconnect", () => {
  it("returns early without touching the (now-null) analyser", async () => {
    const spec = await boot("C4");
    await spec.controller.startMic();
    const entries = Array.from(spec.harness.raf.callbacks.entries());
    const [, callback] = assert(entries[0]);

    spec.controller.disconnect();

    expect(() => {
      callback(0);
    }).not.toThrow();
  });
});

describe("disconnect after the mic has been started", () => {
  async function startedSpec(): Promise<Spec> {
    const spec = await boot("C4");
    await spec.controller.startMic();

    return spec;
  }

  it("cancels the pending animation frame", async () => {
    const spec = await startedSpec();

    spec.controller.disconnect();

    expect(spec.harness.raf.cancel).toHaveBeenCalledTimes(1);
  });

  it("stops every track on the media stream", async () => {
    const spec = await startedSpec();
    const track = assert(spec.harness.stream.tracks[0]);

    spec.controller.disconnect();

    expect(track.stop).toHaveBeenCalledTimes(1);
  });

  it("closes the audio context", async () => {
    const spec = await startedSpec();
    const ctx = assert(spec.harness.audioContexts[0]);

    spec.controller.disconnect();

    expect(ctx.close).toHaveBeenCalledTimes(1);
  });

  it("swallows errors from a failed close()", async () => {
    const spec = await startedSpec();
    const ctx = assert(spec.harness.audioContexts[0]);
    ctx.close.mockRejectedValueOnce(new Error("already closed"));

    expect(() => {
      spec.controller.disconnect();
    }).not.toThrow();
  });
});

describe("disconnect before the mic has been started", () => {
  it("does nothing", async () => {
    const spec = await boot("C4");

    spec.controller.disconnect();

    expect(spec.harness.raf.cancel).not.toHaveBeenCalled();
  });
});
