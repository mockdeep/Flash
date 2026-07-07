import type {Context, Controller} from "@hotwired/stimulus";
import type {Mock} from "vitest";
import {vi} from "vitest";
import {ensure} from "helpers/ensure";
import {bootStimulus, getController} from "support/stimulus";
import {detectPitch} from "music/pitch_detector";

interface TrackMock {
  stop: Mock<() => void>;
}

interface MediaStreamMock {
  getTracks: Mock<() => TrackMock[]>;
  tracks: TrackMock[];
}

interface AnalyserMock {
  fftSize: number;
  connect: Mock<(dest: unknown) => void>;
  getFloatTimeDomainData: Mock<(buffer: Float32Array) => void>;
}

interface SourceMock {
  connect: Mock<(dest: unknown) => void>;
}

interface AudioContextMock {
  analyser: AnalyserMock;
  closed: boolean;
  sampleRate: number;
  source: SourceMock;
  close: Mock<() => Promise<void>>;
  createAnalyser: Mock<() => AnalyserMock>;
  createMediaStreamSource: Mock<(stream: MediaStream) => SourceMock>;
}

interface RafState {
  callbacks: Map<number, FrameRequestCallback>;
  cancel: Mock<typeof cancelAnimationFrame>;
  nextHandle: {value: number};
  request: Mock<typeof requestAnimationFrame>;
}

interface MusicHarness {
  audioContexts: AudioContextMock[];
  getUserMedia: Mock<GetUserMediaFn>;
  now: {value: number};
  raf: RafState;
  stream: MediaStreamMock;
}

interface MusicSpec<TController extends Controller> {
  controller: TController;
  harness: MusicHarness;
}

type ControllerClass<T extends Controller> = new (context: Context) => T;

function buildTrack(): TrackMock {
  return {stop: vi.fn<() => void>()};
}

function buildStream(): MediaStreamMock {
  const tracks = [buildTrack()];

  return {
    getTracks: vi.fn<() => TrackMock[]>(() => {
      return tracks;
    }),
    tracks,
  };
}

function buildAnalyser(): AnalyserMock {
  return {
    connect: vi.fn<(dest: unknown) => void>(),
    fftSize: 0,
    getFloatTimeDomainData: vi.fn<(buffer: Float32Array) => void>(),
  };
}

function buildAudioContextMock(): AudioContextMock {
  const analyser = buildAnalyser();
  const source: SourceMock = {connect: vi.fn<(dest: unknown) => void>()};

  return {
    analyser,
    close: vi.fn<() => Promise<void>>(async () => {
      await Promise.resolve();
    }),
    closed: false,
    createAnalyser: vi.fn<() => AnalyserMock>(() => {
      return analyser;
    }),
    createMediaStreamSource: vi.fn<(s: MediaStream) => SourceMock>(() => {
      return source;
    }),
    sampleRate: 44100,
    source,
  };
}

function stubAudioContext(audioContexts: AudioContextMock[]): void {
  function StubbedAudioContext(): AudioContextMock {
    const mock = buildAudioContextMock();
    audioContexts.push(mock);

    return mock;
  }
  vi.stubGlobal("AudioContext", StubbedAudioContext);
}

function stubRaf(): RafState {
  const callbacks = new Map<number, FrameRequestCallback>();
  const nextHandle = {value: 1};
  const request = vi.fn<typeof requestAnimationFrame>((callback) => {
    const handle = nextHandle.value;
    nextHandle.value += 1;
    callbacks.set(handle, callback);

    return handle;
  });
  const cancel = vi.fn<typeof cancelAnimationFrame>((handle) => {
    callbacks.delete(handle);
  });
  vi.stubGlobal("requestAnimationFrame", request);
  vi.stubGlobal("cancelAnimationFrame", cancel);

  return {callbacks, cancel, nextHandle, request};
}

type GetUserMediaFn =
  (constraints?: MediaStreamConstraints) => Promise<MediaStreamMock>;

function stubGetUserMedia(stream: MediaStreamMock): Mock<GetUserMediaFn> {
  const getUserMedia = vi.fn<GetUserMediaFn>(async () => {
    await Promise.resolve();

    return stream;
  });
  vi.stubGlobal("navigator", {mediaDevices: {getUserMedia}});

  return getUserMedia;
}

function stubPerformance(): {value: number} {
  const now = {value: 0};
  vi.stubGlobal("performance", {
    now: () => {
      return now.value;
    },
  });

  return now;
}

function setupMusicHarness(): MusicHarness {
  const audioContexts: AudioContextMock[] = [];
  const stream = buildStream();
  const getUserMedia = stubGetUserMedia(stream);
  stubAudioContext(audioContexts);
  const raf = stubRaf();
  const now = stubPerformance();

  return {audioContexts, getUserMedia, now, raf, stream};
}

function setupMusicDOM(sequence: string): void {
  document.body.innerHTML = `
    <div data-controller="music-study"
         data-music-study-sequence-value="${sequence}">
      <p data-music-study-target="status">Press Begin to start</p>
      <p data-music-study-target="progress"></p>
      <div data-music-study-target="attempts"></div>
      <button data-music-study-target="startButton"
              data-action="music-study#startMic">Begin</button>
      <form data-music-study-target="form" action="/decks/1/study">
        <input type="hidden" name="answer[answer]"
               data-music-study-target="answerInput">
      </form>
    </div>
  `;
}

async function bootMusicStudy<TController extends Controller>(
  sequence: string,
  controllerClass: ControllerClass<TController>,
): Promise<MusicSpec<TController>> {
  const harness = setupMusicHarness();
  setupMusicDOM(sequence);
  await bootStimulus("music-study", controllerClass);
  const sel = "[data-controller='music-study']";
  const root = ensure(document.querySelector<HTMLElement>(sel));
  const controller = getController(root, "music-study", controllerClass);

  return {controller, harness};
}

function fireFrames(harness: MusicHarness, count: number): void {
  for (let index = 0; index < count; index += 1) {
    const entries = Array.from(harness.raf.callbacks.entries());
    if (entries.length === 0) {
      return;
    }
    const [handle, callback] = ensure(entries[0]);
    harness.raf.callbacks.delete(handle);
    callback(performance.now());
  }
}

function holdNote(harness: MusicHarness, hz: number, when: number): void {
  vi.mocked(detectPitch).mockReturnValue(hz);
  harness.now.value = when;
  fireFrames(harness, 1);
  harness.now.value = when + 300;
  fireFrames(harness, 1);
  vi.mocked(detectPitch).mockReturnValue(null);
  harness.now.value = when + 350;
  fireFrames(harness, 1);
}

function musicTarget(name: string): HTMLElement {
  const sel = `[data-music-study-target='${name}']`;

  return ensure(document.querySelector<HTMLElement>(sel));
}

function musicInput(name: string): HTMLInputElement {
  const sel = `[data-music-study-target='${name}']`;

  return ensure(document.querySelector<HTMLInputElement>(sel));
}

function musicForm(name: string): HTMLFormElement {
  const sel = `[data-music-study-target='${name}']`;

  return ensure(document.querySelector<HTMLFormElement>(sel));
}

export {
  bootMusicStudy,
  fireFrames,
  holdNote,
  musicForm,
  musicInput,
  musicTarget,
};
export type {AudioContextMock, MediaStreamMock, MusicHarness, MusicSpec};
