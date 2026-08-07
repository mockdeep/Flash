import {describe, expect, it, vi} from "vitest";
import WakeLockController from "controllers/wake_lock_controller";
import {ensure} from "helpers/ensure";
import {bootStimulus, getController} from "support/stimulus";

interface SentinelMock {
  release: ReturnType<typeof vi.fn<() => Promise<undefined>>>;
}

interface WakeLockMock {
  request: ReturnType<typeof vi.fn<(type: string) => Promise<SentinelMock>>>;
  sentinel: SentinelMock;
}

function setHidden(value: boolean): void {
  Object.defineProperty(document, "hidden", {
    configurable: true,
    get: () => { return value; },
  });
}

function stubWakeLock(): WakeLockMock {
  setHidden(false);
  const release = vi.fn<() => Promise<undefined>>();
  release.mockResolvedValue(undefined);
  const sentinel = {release};
  const request = vi.fn<(type: string) => Promise<SentinelMock>>();
  request.mockResolvedValue(sentinel);
  Object.defineProperty(navigator, "wakeLock", {
    configurable: true,
    value: {request},
  });

  return {request, sentinel};
}

function removeWakeLock(): void {
  Reflect.deleteProperty(navigator, "wakeLock");
}

async function flushAsync(): Promise<void> {
  await Promise.resolve();
  await Promise.resolve();
}

async function setupController(): Promise<void> {
  document.body.replaceChildren();
  const frame = document.createElement("div");
  frame.setAttribute("data-controller", "wake-lock");
  document.body.appendChild(frame);

  await bootStimulus("wake-lock", WakeLockController);
  await flushAsync();
}

function controller(): WakeLockController {
  const selector = "[data-controller='wake-lock']";
  const element = ensure(document.querySelector<HTMLElement>(selector));

  return getController(element, "wake-lock", WakeLockController);
}

describe("connect", () => {
  it("requests a screen wake lock", async () => {
    const {request} = stubWakeLock();

    await setupController();

    expect(request.mock.calls).toStrictEqual([["screen"]]);
  });

  it("does nothing when the API is unavailable", async () => {
    removeWakeLock();

    await expect(setupController()).resolves.not.toThrow();
  });

  it("recovers when the request is rejected", async () => {
    const {request} = stubWakeLock();
    request.mockRejectedValueOnce(new Error("low battery"));

    await expect(setupController()).resolves.not.toThrow();
  });
});

describe("refresh", () => {
  it("requests the lock again when the page is visible", async () => {
    const {request} = stubWakeLock();
    await setupController();

    controller().refresh();

    expect(request).toHaveBeenCalledTimes(2);
  });

  it("does not request while the page is hidden", async () => {
    const {request} = stubWakeLock();
    await setupController();

    setHidden(true);
    controller().refresh();

    expect(request).toHaveBeenCalledTimes(1);
  });
});

describe("disconnect", () => {
  it("releases the held lock", async () => {
    const {sentinel} = stubWakeLock();
    await setupController();

    controller().disconnect();
    await flushAsync();

    expect(sentinel.release).toHaveBeenCalledTimes(1);
  });

  it("does not throw when no lock is held", async () => {
    removeWakeLock();
    await setupController();

    expect(() => { controller().disconnect(); }).not.toThrow();

    await flushAsync();
  });

  it("does not throw when disconnect runs a second time", async () => {
    stubWakeLock();
    await setupController();
    const ctrl = controller();
    ctrl.disconnect();

    expect(() => { ctrl.disconnect(); }).not.toThrow();
  });

  it("releases a lock that resolves after disconnect", async () => {
    const {request, sentinel} = stubWakeLock();
    let grantLock!: (sentinel: SentinelMock) => void;
    request.mockReturnValueOnce(new Promise((resolve) => {
      grantLock = resolve;
    }));
    await setupController();

    controller().disconnect();
    grantLock(sentinel);
    await flushAsync();

    expect(sentinel.release).toHaveBeenCalledTimes(1);
  });
});
