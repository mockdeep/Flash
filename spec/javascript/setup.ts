/// <reference types="vitest/globals" />

// eslint-disable-next-line vitest/require-hook
Object.defineProperty(navigator, "serviceWorker", {
  configurable: true,
  value: {register: vi.fn()},
});

beforeEach(() => {
  expect.hasAssertions();
});
