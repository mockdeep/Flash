import type {visit as Visit} from "@hotwired/turbo";
import {describe, expect, it, vi} from "vitest";
import AutoAdvanceController from "controllers/auto_advance_controller";
import {assert as ensure} from "helpers/assert";
import {bootStimulus, getController} from "support/stimulus";
import {visit} from "@hotwired/turbo";

vi.mock(import("@hotwired/turbo"), () => {
  return {visit: vi.fn<typeof Visit>()};
});

const NEXT_URL = "/decks/1/study";
const FRAME = "study";

function setupDOM(): void {
  document.body.replaceChildren();
  const wrapper = document.createElement("div");
  wrapper.setAttribute("data-controller", "auto-advance");
  wrapper.setAttribute("data-auto-advance-url-value", NEXT_URL);
  wrapper.setAttribute("data-auto-advance-frame-value", FRAME);
  document.body.appendChild(wrapper);
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("auto-advance", AutoAdvanceController);
}

function element(): HTMLElement {
  const selector = "[data-controller='auto-advance']";

  return ensure(document.querySelector<HTMLElement>(selector));
}

function controller(): AutoAdvanceController {
  return getController(element(), "auto-advance", AutoAdvanceController);
}

describe("after the one-second delay", () => {
  it("visits the configured url in the configured frame", async () => {
    vi.useFakeTimers();
    vi.mocked(visit).mockClear();
    await setupController();
    vi.advanceTimersByTime(1000);
    const {calls} = vi.mocked(visit).mock;
    vi.useRealTimers();

    expect(calls).toStrictEqual([[NEXT_URL, {frame: FRAME}]]);
  });
});

describe("before the delay has elapsed", () => {
  it("does not call visit", async () => {
    vi.useFakeTimers();
    vi.mocked(visit).mockClear();
    await setupController();
    vi.advanceTimersByTime(999);
    const callCount = vi.mocked(visit).mock.calls.length;
    vi.useRealTimers();

    expect(callCount).toBe(0);
  });
});

describe("when the controller disconnects before the delay", () => {
  it("cancels the scheduled visit", async () => {
    vi.useFakeTimers();
    vi.mocked(visit).mockClear();
    await setupController();
    controller().disconnect();
    vi.advanceTimersByTime(1000);
    const callCount = vi.mocked(visit).mock.calls.length;
    vi.useRealTimers();

    expect(callCount).toBe(0);
  });
});

describe("when disconnect runs a second time", () => {
  it("does not throw", async () => {
    await setupController();
    const ctrl = controller();
    ctrl.disconnect();

    expect(() => { ctrl.disconnect(); }).not.toThrow();
  });
});
