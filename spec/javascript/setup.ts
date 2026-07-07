import {beforeEach, expect, vi} from "vitest";

// eslint-disable-next-line vitest/require-hook
Object.defineProperty(navigator, "serviceWorker", {
  configurable: true,
  value: {register: vi.fn()},
});

/*
 * In-memory localStorage shim for the jsdom 29 + Node 26 environment, which
 * does not provide a working localStorage out of the box. Matches the surface
 * of Window#localStorage in a real browser.
 */
function buildLocalStorage(): Storage {
  const store = new Map<string, string>();

  return {
    clear(): void { store.clear(); },
    getItem(key: string): string | null { return store.get(key) ?? null; },
    key(index: number): string | null {
      return Array.from(store.keys())[index] ?? null;
    },
    get length(): number { return store.size; },
    removeItem(key: string): void { store.delete(key); },
    setItem(key: string, value: string): void { store.set(key, value); },
  };
}

// eslint-disable-next-line vitest/require-hook
Object.defineProperty(globalThis, "localStorage", {
  configurable: true,
  value: buildLocalStorage(),
  writable: true,
});

/*
 * Non-matching matchMedia shim: jsdom does not implement it. Tests that need
 * a matching media query mock window.matchMedia per-test.
 */
function buildMediaQueryList(query: string): MediaQueryList {
  return {
    addEventListener(): void { /* Listeners are irrelevant in tests */ },
    addListener(): void { /* Deprecated listener API */ },
    dispatchEvent(): boolean { return false; },
    matches: false,
    media: query,
    onchange: null,
    removeEventListener(): void { /* Listeners are irrelevant in tests */ },
    removeListener(): void { /* Deprecated listener API */ },
  };
}

// eslint-disable-next-line vitest/require-hook
Object.defineProperty(window, "matchMedia", {
  configurable: true,
  value: buildMediaQueryList,
  writable: true,
});

beforeEach(() => {
  expect.hasAssertions();

  localStorage.clear();
});
