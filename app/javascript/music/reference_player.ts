import {noteToFrequency} from "music/note_utils";

const DEFAULT_NOTE_DURATION_MS = 500;
const DEFAULT_GAP_MS = 100;
const FUNDAMENTAL_VOLUME = 0.4;
const OCTAVE_VOLUME = 0.2;
const MS_PER_SECOND = 1000;

/* eslint-disable @typescript-eslint/method-signature-style --
 * Method syntax gives us bivariant parameter checking, which is what
 * lets real DOM AudioContext satisfy these structural interfaces.
 * Real `AudioNode.connect` takes `(dest: AudioNode | AudioParam)` —
 * narrower than our `unknown` — and only method shorthand makes the
 * relationship work without `as` casts.
 */
interface AudioParamLike {
  setValueAtTime(value: number, when: number): void;
}

interface GainNodeLike {
  gain: AudioParamLike;
  connect(dest: unknown): void;
}

interface OscillatorLike {
  frequency: {value: number};
  type: OscillatorType;
  connect(dest: unknown): void;
  start(when: number): void;
  stop(when: number): void;
}

interface AudioContextLike {
  currentTime: number;
  destination: unknown;
  createGain(): GainNodeLike;
  createOscillator(): OscillatorLike;
}
/* eslint-enable @typescript-eslint/method-signature-style */

interface PlayOptions {
  gapMs?: number;
  noteDurationMs?: number;
}

interface ScheduleArgs {
  ctx: AudioContextLike;
  durationSec: number;
  hz: number;
  when: number;
}

interface OscillatorArgs {
  ctx: AudioContextLike;
  durationSec: number;
  hz: number;
  volume: number;
  when: number;
}

function scheduleOscillator(args: OscillatorArgs): void {
  const {ctx, durationSec, hz, volume, when} = args;
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = "sine";
  osc.frequency.value = hz;
  gain.gain.setValueAtTime(volume, when);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(when);
  osc.stop(when + durationSec);
}

/*
 * Doubling at the octave keeps the perceived pitch on the fundamental
 * while giving small speakers a partial they can actually reproduce.
 */
function scheduleNote(args: ScheduleArgs): void {
  const {ctx, durationSec, hz, when} = args;
  scheduleOscillator({ctx, durationSec, hz, volume: FUNDAMENTAL_VOLUME, when});
  scheduleOscillator({
    ctx,
    durationSec,
    hz: hz * 2,
    volume: OCTAVE_VOLUME,
    when,
  });
}

async function playSequence(
  ctx: AudioContextLike,
  notes: string[],
  options: PlayOptions = {},
): Promise<void> {
  const noteDurationMs = options.noteDurationMs ?? DEFAULT_NOTE_DURATION_MS;
  const gapMs = options.gapMs ?? DEFAULT_GAP_MS;
  const noteSec = noteDurationMs / MS_PER_SECOND;
  const gapSec = gapMs / MS_PER_SECOND;
  const stepSec = noteSec + gapSec;

  notes.forEach((note, index) => {
    scheduleNote({
      ctx,
      durationSec: noteSec,
      hz: noteToFrequency(note),
      when: ctx.currentTime + index * stepSec,
    });
  });

  const totalMs = notes.length * (noteDurationMs + gapMs);
  await new Promise((resolve) => {
    setTimeout(resolve, totalMs);
  });
}

export {playSequence};
export type {AudioContextLike};
