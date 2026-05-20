import type {SessionState, StepEvent, StepInput} from "music/sequence_session";
import {Controller} from "@hotwired/stimulus";
import {assert as ensure} from "helpers/assert";
import {detectPitch} from "music/pitch_detector";
import {frequencyToNote, parseSequence} from "music/note_utils";
import {initialState, step} from "music/sequence_session";
import {playSequence} from "music/reference_player";

const TOLERANCE_CENTS = 50;
const HOLD_MS = 150;
const FFT_SIZE = 4096;
const REPLAY_DELAY_MS = 1000;

/* Persists across Turbo frame swaps; resets on full page load. */
let micActivated = false;

function resetMicActivatedForTests(): void {
  micActivated = false;
}

export {resetMicActivatedForTests};

export default class extends Controller<HTMLElement> {
  static override targets = [
    "answerInput",
    "form",
    "progress",
    "startButton",
    "status",
    "wrongNote",
    "wrongNoteText",
  ];

  static override values = {
    sequence: String,
  };

  declare answerInputTarget: HTMLInputElement;

  declare formTarget: HTMLFormElement;

  declare progressTarget: HTMLElement;

  declare startButtonTarget: HTMLButtonElement;

  declare statusTarget: HTMLElement;

  declare wrongNoteTarget: HTMLElement;

  declare wrongNoteTextTarget: HTMLElement;

  declare sequenceValue: string;

  private sessionState: SessionState = initialState([]);

  private audioContext: AudioContext | null = null;

  private mediaStream: MediaStream | null = null;

  private analyser: AnalyserNode | null = null;

  private rafHandle = 0;

  private replayTimeoutHandle: ReturnType<typeof setTimeout> | null = null;

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
    if (micActivated) {
      this.startButtonTarget.hidden = true;
      this.startMic().catch(() => {
        return null;
      });
    }
  }

  override disconnect(): void {
    this.stopMic();
  }

  async startMic(): Promise<void> {
    try {
      this.mediaStream =
        await navigator.mediaDevices.getUserMedia({audio: this.micConstraints});
    } catch {
      this.handleMicDenied();

      return;
    }
    this.handleMicGranted(this.mediaStream);
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

  private handleMicDenied(): void {
    this.statusTarget.textContent = "Microphone access denied";
    this.startButtonTarget.hidden = false;
    micActivated = false;
  }

  private handleMicGranted(stream: MediaStream): void {
    micActivated = true;
    this.attachAnalyser(stream);
    this.startButtonTarget.hidden = true;
    this.statusTarget.textContent = "Listen…";
    this.scheduleTick();
    this.play().catch(() => {
      return null;
    });
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
      this.handleAdvanced();
    } else if (event === "needs_replay") {
      this.handleNeedsReplay(detected);
    } else if (event === "completed") {
      this.handleCompleted();
    }
  }

  private handleReset(detected: string | null): void {
    this.renderProgress();
    this.statusTarget.textContent = "Wrong note — start from the top";
    this.showWrongNote(ensure(detected));
  }

  private handleAdvanced(): void {
    this.renderProgress();
    this.hideWrongNote();
  }

  private handleNeedsReplay(detected: string | null): void {
    this.renderProgress();
    this.statusTarget.textContent = "Listen again…";
    this.showWrongNote(ensure(detected));
    this.scheduleReplay();
  }

  private handleCompleted(): void {
    this.hideWrongNote();
    this.submit();
  }

  private scheduleReplay(): void {
    this.playing = true;
    this.replayTimeoutHandle = setTimeout(() => {
      this.replayTimeoutHandle = null;
      this.play().catch(() => {
        return null;
      });
    }, REPLAY_DELAY_MS);
  }

  private cancelReplay(): void {
    if (this.replayTimeoutHandle !== null) {
      clearTimeout(this.replayTimeoutHandle);
      this.replayTimeoutHandle = null;
    }
  }

  private showWrongNote(note: string): void {
    this.wrongNoteTextTarget.textContent = note;
    this.wrongNoteTarget.classList.remove("answer-incorrect");
    this.wrongNoteTarget.hidden = false;

    /* Force a reflow so the shake animation replays on each wrong note. */
    this.wrongNoteTarget.getBoundingClientRect();
    this.wrongNoteTarget.classList.add("answer-incorrect");
  }

  private hideWrongNote(): void {
    this.wrongNoteTarget.hidden = true;
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
    this.cancelReplay();
    this.cancelTick();
    this.stopStream();
    this.closeContext();
    this.analyser = null;
  }

  private cancelTick(): void {
    if (this.rafHandle !== 0) {
      cancelAnimationFrame(this.rafHandle);
      this.rafHandle = 0;
    }
  }

  private stopStream(): void {
    if (this.mediaStream !== null) {
      this.mediaStream.getTracks().forEach((track) => {
        track.stop();
      });
      this.mediaStream = null;
    }
  }

  private closeContext(): void {
    if (this.audioContext !== null) {
      this.audioContext.close().catch(() => {
        return null;
      });
      this.audioContext = null;
    }
  }
}
