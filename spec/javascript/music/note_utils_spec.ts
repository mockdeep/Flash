import {describe, expect, it} from "vitest";
import {
  frequencyToNote,
  noteToFrequency,
  parseSequence,
} from "music/note_utils";

describe("noteToFrequency", () => {
  it("returns 440 for A4", () => {
    expect(noteToFrequency("A4")).toBeCloseTo(440, 5);
  });

  it("returns ~261.63 for C4 (middle C)", () => {
    expect(noteToFrequency("C4")).toBeCloseTo(261.63, 1);
  });

  it("returns ~277.18 for C#4", () => {
    expect(noteToFrequency("C#4")).toBeCloseTo(277.18, 1);
  });

  it("doubles the frequency one octave up", () => {
    expect(noteToFrequency("A5")).toBeCloseTo(880, 5);
  });

  it("halves the frequency one octave down", () => {
    expect(noteToFrequency("A3")).toBeCloseTo(220, 5);
  });

  it("handles the highest note in the validated range (B8)", () => {
    expect(noteToFrequency("B8")).toBeGreaterThan(0);
  });

  it("throws for an invalid note string", () => {
    expect(() => {
      noteToFrequency("Z9");
    }).toThrow("Invalid note: Z9");
  });

  it("throws for missing octave", () => {
    expect(() => {
      noteToFrequency("C");
    }).toThrow("Invalid note: C");
  });

  it("throws for flats (only sharps are supported)", () => {
    expect(() => {
      noteToFrequency("Bb4");
    }).toThrow("Invalid note: Bb4");
  });
});

describe("frequencyToNote", () => {
  it("returns A4 with 0 cents for 440 Hz", () => {
    expect(frequencyToNote(440)).toStrictEqual({cents: 0, note: "A4"});
  });

  it("returns C4 with ~0 cents for 261.63 Hz", () => {
    const result = frequencyToNote(261.63);

    expect(result.note).toBe("C4");
    expect(Math.abs(result.cents)).toBeLessThanOrEqual(1);
  });

  it("returns positive cents when sharp of the target", () => {
    const result = frequencyToNote(445);

    expect(result.note).toBe("A4");
    expect(result.cents).toBeGreaterThan(0);
  });

  it("returns negative cents when flat of the target", () => {
    const result = frequencyToNote(435);

    expect(result.note).toBe("A4");
    expect(result.cents).toBeLessThan(0);
  });

  it("rounds to the nearest sharp note name", () => {
    expect(frequencyToNote(noteToFrequency("C#4")).note).toBe("C#4");
  });

  it("returns the same note after a round-trip", () => {
    const cases = ["C4", "G4", "F#5", "A3", "D#2"];

    for (const note of cases) {
      expect(frequencyToNote(noteToFrequency(note)).note).toBe(note);
    }
  });
});

describe("parseSequence", () => {
  it("splits a single note into a one-element array", () => {
    expect(parseSequence("G4")).toStrictEqual(["G4"]);
  });

  it("splits a multi-note sequence on commas", () => {
    expect(parseSequence("C4,E4,G4")).toStrictEqual(["C4", "E4", "G4"]);
  });

  it("preserves sharps", () => {
    expect(parseSequence("C#4,F#4")).toStrictEqual(["C#4", "F#4"]);
  });
});
