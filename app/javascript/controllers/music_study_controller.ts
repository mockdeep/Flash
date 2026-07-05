import type {SessionState, StepEvent, StepInput} from "music/sequence_session";
import {
  bindInactivity,
  clearTimer,
  prependAttempt,
  renderProgress,
} from "./music_study_helpers";
import {Controller} from "@hotwired/stimulus";
import {ensure} from "helpers/ensure";
import {detectPitch} from "music/pitch_detector";
import {frequencyToNote, parseSequence} from "music/note_utils";
import {initialState, step} from "music/sequence_session";
import {playSequence} from "music/reference_player";

const TOLERANCE_CENTS = 50;
const HOLD_MS = 150;
const FFT_SIZE = 4096;
const REPLAY_DELAY_MS = 1000;
const COMPLETE_DELAY_MS = 1000;

/* Persists across Turbo frame swaps; resets on full page load. */
let micActivated = false;

function resetMicActivatedForTests(): void {
  micActivated = false;
}

export {resetMicActivatedForTests};

export default class extends Controller<HTMLElement> {
  static override targets = [
    "answerInput",
    "attempts",
    "form",
    "progress",
    "startButton",
    "status",
  ];

  static override values = {
    sequence: String,
  };

  declare answerInputTarget: HTMLInputElement;

  declare attemptsTarget: HTMLElement;

  declare formTarget: HTMLFormElement;

  declare progressTarget: HTMLElement;

  declare startButtonTarget: HTMLButtonElement;

  declare statusTarget: HTMLElement;

  declare sequenceValue: string;

  private sessionState: SessionState = initialState([]);

  private audioContext: AudioContext | null = null;

  private mediaStream: MediaStream | null = null;

  private analyser: AnalyserNode | null = null;

  private rafHandle = 0;

  private replayTimeoutHandle: ReturnType<typeof setTimeout> | null = null;

  private completeTimeoutHandle: ReturnType<typeof setTimeout> | null = null;

  private playing = false;

  private pausedForInactive = false;

  private unbindInactivity: (() => void) | null = null;

  private readonly buffer = new Float32Array(FFT_SIZE);

  private readonly micConstraints: MediaTrackConstraints = {
    autoGainControl: false,
    echoCancellation: true,
    noiseSuppression: true,
  };

  override connect(): void {
    this.sessionState = initialState(parseSequence(this.sequenceValue));
    renderProgress(this.progressTarget, this.sessionState);
    this.unbindInactivity = bindInactivity(
      () => { this.pauseForInactive(); },
      () => { this.resumeFromInactive(); },
    );
    if (micActivated) {
      this.startButtonTarget.hidden = true;
      this.startMic().catch(() => { return null; });
    }
  }

  override disconnect(): void {
    if (this.unbindInactivity !== null) {
      this.unbindInactivity();
      this.unbindInactivity = null;
    }
    this.stopMic();
  }

  async startMic(): Promise<void> {
    await this.acquireMic({playReference: true});
  }

  async resumeMic(): Promise<void> {
    await this.acquireMic({playReference: false});
  }

  async play(): Promise<void> {
    if (this.audioContext === null) {
      return;
    }
    this.sessionState = initialState(this.sessionState.notes);
    renderProgress(this.progressTarget, this.sessionState);
    this.playing = true;
    try {
      await playSequence(this.audioContext, this.sessionState.notes);
    } finally {
      this.playing = false;
    }
    this.statusTarget.textContent = "Now play it back!";
  }

  private async acquireMic(opts: {playReference: boolean}): Promise<void> {
    const stream = await navigator.mediaDevices.
      getUserMedia({audio: this.micConstraints}).
      catch(() => { return null; });
    if (stream === null) {
      this.handleMicDenied();
    } else {
      this.handleMicGranted(stream, opts.playReference);
    }
  }

  private handleMicGranted(stream: MediaStream, playReference: boolean): void {
    this.mediaStream = stream;
    micActivated = true;
    this.attachAnalyser(stream);
    this.startButtonTarget.hidden = true;
    this.scheduleTick();
    if (playReference) {
      this.statusTarget.textContent = "Listen…";
      this.play().catch(() => { return null; });
    }
  }

  private pauseForInactive(): void {
    if (this.analyser === null) { return; }
    const {nextIndex, notes} = this.sessionState;
    if (nextIndex >= notes.length) { return; }
    this.pausedForInactive = true;
    this.stopMic();
  }

  private resumeFromInactive(): void {
    if (!this.pausedForInactive) { return; }
    this.pausedForInactive = false;
    this.resumeMic().catch(() => { return null; });
  }

  private handleMicDenied(): void {
    this.statusTarget.textContent = "Microphone access denied";
    this.startButtonTarget.hidden = false;
    micActivated = false;
  }

  private attachAnalyser(stream: MediaStream): void {
    const ctx = new AudioContext();
    const source = ctx.createMediaStreamSource(stream);
    const analyser = ctx.createAnalyser();
    analyser.fftSize = FFT_SIZE;
    source.connect(analyser);
    this.audioContext = ctx;
    this.analyser = analyser;
  }

  private scheduleTick(): void {
    this.rafHandle = requestAnimationFrame(() => {
      this.runTick();
    });
  }

  private buildStepInput(analyser: AnalyserNode, ctx: AudioContext): StepInput {
    analyser.getFloatTimeDomainData(this.buffer);
    const hz = detectPitch(this.buffer, ctx.sampleRate);
    let detected = null;
    if (hz !== null) {
      detected = frequencyToNote(hz);
    }

    return {
      detected,
      holdMs: HOLD_MS,
      now: performance.now(),
      toleranceCents: TOLERANCE_CENTS,
    };
  }

  private runTick(): void {
    if (this.analyser === null || this.audioContext === null) {
      return;
    }
    if (this.playing) {
      this.scheduleTick();

      return;
    }
    this.processFrame(this.analyser, this.audioContext);
  }

  private processFrame(analyser: AnalyserNode, ctx: AudioContext): void {
    const result = step(this.sessionState, this.buildStepInput(analyser, ctx));
    this.sessionState = result.state;
    this.applyEvent(result.event, result.detected);
    if (result.event !== "completed") {
      this.scheduleTick();
    }
  }

  private applyEvent(event: StepEvent, detected: string | null): void {
    if (event === "reset") {
      this.handleReset(detected);
    } else if (event === "advanced") {
      this.handleAdvanced(detected);
    } else if (event === "needs_replay") {
      this.handleNeedsReplay(detected);
    } else if (event === "completed") {
      this.handleCompleted(detected);
    }
  }

  private handleReset(detected: string | null): void {
    renderProgress(this.progressTarget, this.sessionState);
    this.statusTarget.textContent = "Wrong note — start from the top";
    prependAttempt(this.attemptsTarget, ensure(detected), "incorrect");
  }

  private handleAdvanced(detected: string | null): void {
    renderProgress(this.progressTarget, this.sessionState);
    prependAttempt(this.attemptsTarget, ensure(detected), "correct");
  }

  private handleNeedsReplay(detected: string | null): void {
    renderProgress(this.progressTarget, this.sessionState);
    this.statusTarget.textContent = "Listen again…";
    prependAttempt(this.attemptsTarget, ensure(detected), "incorrect");
    this.scheduleReplay();
  }

  private handleCompleted(detected: string | null): void {
    prependAttempt(this.attemptsTarget, ensure(detected), "correct");
    this.completeTimeoutHandle = setTimeout(() => {
      this.completeTimeoutHandle = null;
      this.submit();
    }, COMPLETE_DELAY_MS);
  }

  private scheduleReplay(): void {
    this.playing = true;
    this.replayTimeoutHandle = setTimeout(() => {
      this.replayTimeoutHandle = null;
      this.play().catch(() => { return null; });
    }, REPLAY_DELAY_MS);
  }

  private submit(): void {
    this.stopMic();
    this.answerInputTarget.value = this.sequenceValue;
    this.formTarget.requestSubmit();
  }

  private stopMic(): void {
    this.replayTimeoutHandle = clearTimer(this.replayTimeoutHandle);
    this.completeTimeoutHandle = clearTimer(this.completeTimeoutHandle);
    if (this.rafHandle !== 0) {
      cancelAnimationFrame(this.rafHandle);
      this.rafHandle = 0;
    }
    if (this.mediaStream !== null) {
      this.mediaStream.getTracks().forEach((track) => { track.stop(); });
      this.mediaStream = null;
    }
    this.closeContext();
    this.analyser = null;
  }

  private closeContext(): void {
    if (this.audioContext !== null) {
      this.audioContext.close().catch(() => { return null; });
      this.audioContext = null;
    }
  }
}
