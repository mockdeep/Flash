import type {SessionState, StepEvent, StepInput} from "music/sequence_session";
import {Controller} from "@hotwired/stimulus";
import {detectPitch} from "music/pitch_detector";
import {frequencyToNote, parseSequence} from "music/note_utils";
import {initialState, step} from "music/sequence_session";
import {playSequence} from "music/reference_player";

const TOLERANCE_CENTS = 50;
const HOLD_MS = 150;
const FFT_SIZE = 4096;

export default class extends Controller<HTMLElement> {
  static override targets = [
    "answerInput",
    "form",
    "playButton",
    "progress",
    "startButton",
    "status",
  ];

  static override values = {
    sequence: String,
  };

  declare answerInputTarget: HTMLInputElement;

  declare formTarget: HTMLFormElement;

  declare playButtonTarget: HTMLButtonElement;

  declare progressTarget: HTMLElement;

  declare startButtonTarget: HTMLButtonElement;

  declare statusTarget: HTMLElement;

  declare sequenceValue: string;

  private sessionState: SessionState = initialState([]);

  private audioContext: AudioContext | null = null;

  private mediaStream: MediaStream | null = null;

  private analyser: AnalyserNode | null = null;

  private rafHandle = 0;

  private playing = false;

  private readonly buffer = new Float32Array(FFT_SIZE);

  private readonly micConstraints: MediaTrackConstraints = {
    autoGainControl: false,
    echoCancellation: true,
    noiseSuppression: true,
  };

  override connect(): void {
    this.sessionState = initialState(parseSequence(this.sequenceValue));
    this.renderProgress();
  }

  override disconnect(): void {
    this.stopMic();
  }

  async startMic(): Promise<void> {
    try {
      this.mediaStream =
        await navigator.mediaDevices.getUserMedia({audio: this.micConstraints});
    } catch {
      this.statusTarget.textContent = "Microphone access denied";

      return;
    }
    this.attachAnalyser(this.mediaStream);
    this.startButtonTarget.hidden = true;
    this.playButtonTarget.hidden = false;
    this.statusTarget.textContent = "Mic ready — press Play to hear the note";
    this.scheduleTick();
  }

  async play(): Promise<void> {
    if (this.audioContext === null) {
      return;
    }
    this.sessionState = initialState(this.sessionState.notes);
    this.renderProgress();
    this.playing = true;
    try {
      await playSequence(this.audioContext, this.sessionState.notes);
    } finally {
      this.playing = false;
    }
    this.statusTarget.textContent = "Now play it back!";
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
    this.applyEvent(result.event);
    if (result.event !== "completed") {
      this.scheduleTick();
    }
  }

  private applyEvent(event: StepEvent): void {
    if (event === "advanced" || event === "reset" || event === "needs_replay") {
      this.renderProgress();
    }
    if (event === "reset") {
      this.statusTarget.textContent = "Wrong note — start from the top";
    }
    if (event === "needs_replay") {
      this.statusTarget.textContent = "Listen again…";
      this.play().catch(() => {
        return null;
      });
    }
    if (event === "completed") {
      this.submit();
    }
  }

  private renderProgress(): void {
    const total = this.sessionState.notes.length;
    const done = this.sessionState.nextIndex;
    this.progressTarget.textContent = `${done} / ${total}`;
  }

  private submit(): void {
    this.stopMic();
    this.answerInputTarget.value = this.sequenceValue;
    this.formTarget.requestSubmit();
  }

  private stopMic(): void {
    if (this.rafHandle !== 0) {
      cancelAnimationFrame(this.rafHandle);
      this.rafHandle = 0;
    }
    if (this.mediaStream !== null) {
      this.mediaStream.getTracks().forEach((track) => {
        track.stop();
      });
      this.mediaStream = null;
    }
    if (this.audioContext !== null) {
      this.audioContext.close().catch(() => {
        return null;
      });
      this.audioContext = null;
    }
    this.analyser = null;
  }
}
