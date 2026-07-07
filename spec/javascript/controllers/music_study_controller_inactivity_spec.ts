import type {detectPitch as DetectPitch} from "music/pitch_detector";
import type {playSequence as PlaySequence} from "music/reference_player";
import {afterEach, describe, expect, it, vi} from "vitest";
import type {MusicSpec} from "support/music_study_harness";
import MusicStudyController, {
  resetMicActivatedForTests,
} from "controllers/music_study_controller";
import {ensure} from "helpers/ensure";
import {playSequence} from "music/reference_player";
import {bootMusicStudy, holdNote} from "support/music_study_harness";

vi.mock(import("music/pitch_detector"), () => {
  return {detectPitch: vi.fn<typeof DetectPitch>()};
});

vi.mock(import("music/reference_player"), () => {
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

function setHidden(value: boolean): void {
  Object.defineProperty(document, "hidden", {
    configurable: true,
    get: () => { return value; },
  });
}

afterEach(() => {
  vi.unstubAllGlobals();
  vi.clearAllMocks();
  resetMicActivatedForTests();
});

describe("window blur while the mic is running", () => {
  it("stops every track on the media stream", async () => {
    const spec = await started();
    const track = ensure(spec.harness.stream.tracks[0]);

    window.dispatchEvent(new Event("blur"));

    expect(track.stop).toHaveBeenCalledTimes(1);
  });

  it("closes the audio context", async () => {
    const spec = await started();
    const ctx = ensure(spec.harness.audioContexts[0]);

    window.dispatchEvent(new Event("blur"));

    expect(ctx.close).toHaveBeenCalledTimes(1);
  });

  it("cancels the pending animation frame", async () => {
    const spec = await started();

    window.dispatchEvent(new Event("blur"));

    expect(spec.harness.raf.cancel).toHaveBeenCalledTimes(1);
  });
});

describe("window blur before the mic has been started", () => {
  it("does not stop any tracks", async () => {
    const spec = await boot("C4");
    const track = ensure(spec.harness.stream.tracks[0]);

    window.dispatchEvent(new Event("blur"));

    expect(track.stop).not.toHaveBeenCalled();
  });
});

describe("window focus after a pause", () => {
  async function paused(): Promise<Spec> {
    const spec = await started("C4");
    spec.harness.getUserMedia.mockClear();
    vi.mocked(playSequence).mockClear();
    window.dispatchEvent(new Event("blur"));

    return spec;
  }

  it("re-requests the microphone", async () => {
    const spec = await paused();

    window.dispatchEvent(new Event("focus"));
    await Promise.resolve();
    await Promise.resolve();

    expect(spec.harness.getUserMedia).toHaveBeenCalled();
  });

  it("does not replay the reference sequence", async () => {
    await paused();

    window.dispatchEvent(new Event("focus"));
    await Promise.resolve();
    await Promise.resolve();

    expect(playSequence).not.toHaveBeenCalled();
  });

  it("resumes the animation-frame loop", async () => {
    const spec = await paused();
    spec.harness.raf.request.mockClear();

    window.dispatchEvent(new Event("focus"));
    await new Promise((resolve) => { setTimeout(resolve, 0); });

    expect(spec.harness.raf.request).toHaveBeenCalled();
  });
});

describe("window focus without a prior pause", () => {
  it("does not request the mic again", async () => {
    const spec = await started("C4");
    spec.harness.getUserMedia.mockClear();

    window.dispatchEvent(new Event("focus"));
    await Promise.resolve();

    expect(spec.harness.getUserMedia).not.toHaveBeenCalled();
  });
});

describe("visibilitychange when the page becomes hidden", () => {
  it("stops the media stream", async () => {
    const spec = await started();
    const track = ensure(spec.harness.stream.tracks[0]);
    setHidden(true);

    document.dispatchEvent(new Event("visibilitychange"));

    expect(track.stop).toHaveBeenCalledTimes(1);
  });
});

describe("visibilitychange when the page becomes visible after pause", () => {
  it("re-requests the microphone", async () => {
    const spec = await started("C4");
    setHidden(true);
    document.dispatchEvent(new Event("visibilitychange"));
    spec.harness.getUserMedia.mockClear();
    setHidden(false);

    document.dispatchEvent(new Event("visibilitychange"));
    await Promise.resolve();
    await Promise.resolve();

    expect(spec.harness.getUserMedia).toHaveBeenCalled();
  });
});

describe("window blur during the post-complete delay", () => {
  it("does not stop the media stream", async () => {
    const spec = await started("C4");
    holdNote(spec.harness, 261.63, 0);
    const track = ensure(spec.harness.stream.tracks[0]);
    track.stop.mockClear();

    window.dispatchEvent(new Event("blur"));

    expect(track.stop).not.toHaveBeenCalled();
  });
});

describe("focus resume when resumeMic itself rejects", () => {
  it("swallows the rejection rather than raising", async () => {
    const spec = await started("C4");
    window.dispatchEvent(new Event("blur"));
    vi.spyOn(spec.controller, "resumeMic").
      mockRejectedValueOnce(new Error("boom"));

    window.dispatchEvent(new Event("focus"));
    await new Promise((resolve) => { setTimeout(resolve, 0); });

    expect(spec.controller).toBeDefined();
  });
});

describe("inactivity listeners after disconnect", () => {
  it("are removed so a later blur is a no-op", async () => {
    const spec = await started();
    spec.controller.disconnect();
    const track = ensure(spec.harness.stream.tracks[0]);
    track.stop.mockClear();

    window.dispatchEvent(new Event("blur"));

    expect(track.stop).not.toHaveBeenCalled();
  });

  it("are safe to remove twice", async () => {
    const spec = await started();
    spec.controller.disconnect();

    expect(() => { spec.controller.disconnect(); }).not.toThrow();
  });
});
