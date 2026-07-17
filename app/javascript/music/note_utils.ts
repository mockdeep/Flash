import {ensure} from "helpers/ensure";

const A4_FREQUENCY = 440;
const A4_MIDI = 69;
const SEMITONES_PER_OCTAVE = 12;
const CENTS_PER_SEMITONE = 100;

interface PitchClass {
  accidental: string;
  letter: string;
  semitone: number;
}

const PITCH_CLASSES: PitchClass[] = [
  {accidental: "", letter: "C", semitone: 0},
  {accidental: "#", letter: "C", semitone: 1},
  {accidental: "", letter: "D", semitone: 2},
  {accidental: "#", letter: "D", semitone: 3},
  {accidental: "", letter: "E", semitone: 4},
  {accidental: "", letter: "F", semitone: 5},
  {accidental: "#", letter: "F", semitone: 6},
  {accidental: "", letter: "G", semitone: 7},
  {accidental: "#", letter: "G", semitone: 8},
  {accidental: "", letter: "A", semitone: 9},
  {accidental: "#", letter: "A", semitone: 10},
  {accidental: "", letter: "B", semitone: 11},
];

const NOTE_REGEXP = /^(?<letter>[A-G])(?<accidental>#?)(?<octave>\d)$/u;

interface PitchMatch {
  cents: number;
  note: string;
}

function noteToMidi(note: string): number {
  const groups = NOTE_REGEXP.exec(note)?.groups;
  if (!groups) {
    throw new Error(`Invalid note: ${note}`);
  }
  const pitchClass = ensure(PITCH_CLASSES.find((candidate) => {
    return candidate.letter === groups.letter &&
      candidate.accidental === groups.accidental;
  }));
  const octave = Number(ensure(groups.octave));

  return pitchClass.semitone + (octave + 1) * SEMITONES_PER_OCTAVE;
}

function midiToNote(midi: number): string {
  const octave = Math.floor(midi / SEMITONES_PER_OCTAVE) - 1;
  const semitone = midi % SEMITONES_PER_OCTAVE;
  const pitchClass = ensure(PITCH_CLASSES.find((candidate) => {
    return candidate.semitone === semitone;
  }));

  return `${pitchClass.letter}${pitchClass.accidental}${octave}`;
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
