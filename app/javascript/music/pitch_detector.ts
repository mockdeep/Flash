import {ensure} from "helpers/ensure";

const DEFAULT_THRESHOLD = 0.15;
const DEFAULT_MIN_HZ = 60;
const DEFAULT_MAX_HZ = 2000;
const MIN_TAU = 2;

interface DetectOptions {
  maxHz?: number;
  minHz?: number;
  threshold?: number;
}

function differenceFunction(
  samples: Float32Array,
  maxTau: number,
): Float32Array {
  const diffs = new Float32Array(maxTau + 1);
  for (let tau = 1; tau <= maxTau; tau += 1) {
    let sum = 0;
    for (let index = 0; index < maxTau; index += 1) {
      const delta = ensure(samples[index]) - ensure(samples[index + tau]);
      sum += delta * delta;
    }
    diffs[tau] = sum;
  }

  return diffs;
}

function normalizeCMNDF(diffs: Float32Array): void {
  diffs[0] = 1;
  let runningSum = 0;
  for (let tau = 1; tau < diffs.length; tau += 1) {
    runningSum += ensure(diffs[tau]);
    diffs[tau] = ensure(diffs[tau]) * tau / runningSum;
  }
}

interface SearchArgs {
  diffs: Float32Array;
  maxTau: number;
  minTau: number;
  threshold: number;
}

function findFundamentalTau(args: SearchArgs): number | null {
  const {diffs, maxTau, minTau, threshold} = args;
  for (let tau = minTau; tau <= maxTau; tau += 1) {
    if (ensure(diffs[tau]) < threshold) {
      let bestTau = tau;
      while (
        bestTau < maxTau &&
        ensure(diffs[bestTau + 1]) < ensure(diffs[bestTau])
      ) {
        bestTau += 1;
      }

      return bestTau;
    }
  }

  return null;
}

interface ResolvedOptions {
  maxTau: number;
  minTau: number;
  threshold: number;
}

function resolveOptions(
  sampleRate: number,
  options: DetectOptions,
): ResolvedOptions {
  const threshold = options.threshold ?? DEFAULT_THRESHOLD;
  const minHz = options.minHz ?? DEFAULT_MIN_HZ;
  const maxHz = options.maxHz ?? DEFAULT_MAX_HZ;
  const minTau = Math.max(MIN_TAU, Math.floor(sampleRate / maxHz));
  const maxTau = Math.floor(sampleRate / minHz);

  return {maxTau, minTau, threshold};
}

function detectPitch(
  samples: Float32Array,
  sampleRate: number,
  options: DetectOptions = {},
): number | null {
  const {maxTau, minTau, threshold} = resolveOptions(sampleRate, options);
  if (samples.length < maxTau * 2) {
    return null;
  }
  const diffs = differenceFunction(samples, maxTau);
  normalizeCMNDF(diffs);
  const tau = findFundamentalTau({diffs, maxTau, minTau, threshold});
  if (tau === null) {
    return null;
  }

  return sampleRate / tau;
}

export {detectPitch};
