import {describe, expect, it} from "vitest";
import {assert} from "helpers/assert";
import {detectPitch} from "music/pitch_detector";

const SAMPLE_RATE = 44100;

function generateSine(hz: number, sampleCount: number): Float32Array {
  const buffer = new Float32Array(sampleCount);
  for (let index = 0; index < sampleCount; index += 1) {
    buffer[index] = Math.sin(2 * Math.PI * hz * index / SAMPLE_RATE);
  }

  return buffer;
}

function generateSilence(sampleCount: number): Float32Array {
  return new Float32Array(sampleCount);
}

function relativeError(detected: number, target: number): number {
  return Math.abs(detected - target) / target;
}

describe("detectPitch with default options", () => {
  it("detects a 440 Hz sine wave within 1%", () => {
    const samples = generateSine(440, 4096);
    const detected = assert(detectPitch(samples, SAMPLE_RATE));

    expect(relativeError(detected, 440)).toBeLessThan(0.01);
  });

  it("detects middle C (~261.63 Hz) within 1%", () => {
    const samples = generateSine(261.63, 4096);
    const detected = assert(detectPitch(samples, SAMPLE_RATE));

    expect(relativeError(detected, 261.63)).toBeLessThan(0.01);
  });

  it("returns null when given a silent buffer", () => {
    const samples = generateSilence(4096);

    expect(detectPitch(samples, SAMPLE_RATE)).toBeNull();
  });

  it("returns null when the buffer is too short for the lowest τ", () => {
    const samples = generateSine(440, 100);

    expect(detectPitch(samples, SAMPLE_RATE)).toBeNull();
  });
});

describe("detectPitch with custom options", () => {
  it("respects a custom threshold for accepting a candidate", () => {
    const samples = generateSine(440, 4096);
    const detected =
      assert(detectPitch(samples, SAMPLE_RATE, {threshold: 0.05}));

    expect(relativeError(detected, 440)).toBeLessThan(0.01);
  });

  it("respects a custom minHz (raises maxTau, shrinks search range)", () => {
    const samples = generateSine(440, 4096);
    const detected =
      assert(detectPitch(samples, SAMPLE_RATE, {minHz: 200}));

    expect(relativeError(detected, 440)).toBeLessThan(0.01);
  });

  it("respects a custom maxHz (raises minTau, shrinks search range)", () => {
    const samples = generateSine(440, 4096);
    const detected =
      assert(detectPitch(samples, SAMPLE_RATE, {maxHz: 1000}));

    expect(relativeError(detected, 440)).toBeLessThan(0.01);
  });

  it("returns null when an impossibly tight threshold rejects all τ", () => {
    const samples = generateSine(440, 4096);

    expect(detectPitch(samples, SAMPLE_RATE, {threshold: -1})).toBeNull();
  });

  it("stops the local-min walk when it reaches the maxTau boundary", () => {
    const samples = generateSine(100, 4096);
    const detected =
      assert(detectPitch(samples, SAMPLE_RATE, {minHz: 100}));

    expect(relativeError(detected, 100)).toBeLessThan(0.01);
  });
});
