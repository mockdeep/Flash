import {assert} from "helpers/assert";

const A4_FREQUENCY = 440;
const A4_MIDI = 69;
const SEMITONES_PER_OCTAVE = 12;
const CENTS_PER_SEMITONE = 100;

const LETTER_TO_OFFSET: {[letter: string]: number} = {
  /* eslint-disable id-length */
  A: 9, B: 11, C: 0, D: 2, E: 4, F: 5, G: 7,
  /* eslint-enable id-length */
};

const NOTE_NAMES = "C C# D D# E F F# G G# A A# B".split(" ");

// eslint-disable-next-line prefer-named-capture-group
const NOTE_REGEXP = /^([A-G])(#?)(\d)$/u;

interface PitchMatch {
  cents: number;
  note: string;
}

function noteToMidi(note: string): number {
  // eslint-disable-next-line @typescript-eslint/prefer-regexp-exec
  const match = note.match(NOTE_REGEXP);
  if (!match) {
    throw new Error(`Invalid note: ${note}`);
  }
  const offset = assert(LETTER_TO_OFFSET[assert(match[1])]);
  let sharpStep = 0;
  if (match[2] === "#") {
    sharpStep = 1;
  }
  const octave = Number(assert(match[3]));

  return offset + sharpStep + (octave + 1) * SEMITONES_PER_OCTAVE;
}

function midiToNote(midi: number): string {
  const octave = Math.floor(midi / SEMITONES_PER_OCTAVE) - 1;
  const name = assert(NOTE_NAMES[midi % SEMITONES_PER_OCTAVE]);

  return `${name}${octave}`;
}

function noteToFrequency(note: string): number {
  const semitonesAboveA4 = noteToMidi(note) - A4_MIDI;

  return A4_FREQUENCY * 2 ** (semitonesAboveA4 / SEMITONES_PER_OCTAVE);
}

function frequencyToNote(hz: number): PitchMatch {
  const offsetSemitones =
    SEMITONES_PER_OCTAVE * Math.log2(hz / A4_FREQUENCY);
  const midi = A4_MIDI + offsetSemitones;
  const rounded = Math.round(midi);
  const cents = Math.round((midi - rounded) * CENTS_PER_SEMITONE);

  return {cents, note: midiToNote(rounded)};
}

function parseSequence(text: string): string[] {
  return text.split(",");
}

export {frequencyToNote, noteToFrequency, parseSequence};
export type {PitchMatch};
