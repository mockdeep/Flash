import {noteToFrequency} from "music/note_utils";

const DEFAULT_NOTE_DURATION_MS = 500;
const DEFAULT_GAP_MS = 100;
const NOTE_VOLUME = 0.3;
const MS_PER_SECOND = 1000;

interface AudioParamLike {
  setValueAtTime: (value: number, when: number) => void;
}

interface GainNodeLike {
  connect: (dest: unknown) => void;
  gain: AudioParamLike;
}

interface OscillatorLike {
  connect: (dest: unknown) => void;
  frequency: {value: number};
  start: (when: number) => void;
  stop: (when: number) => void;
  type: OscillatorType;
}

interface AudioContextLike {
  createGain: () => GainNodeLike;
  createOscillator: () => OscillatorLike;
  currentTime: number;
  destination: unknown;
}

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

function scheduleNote(args: ScheduleArgs): void {
  const {ctx, durationSec, hz, when} = args;
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();
  osc.type = "sine";
  osc.frequency.value = hz;
  gain.gain.setValueAtTime(NOTE_VOLUME, when);
  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(when);
  osc.stop(when + durationSec);
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
