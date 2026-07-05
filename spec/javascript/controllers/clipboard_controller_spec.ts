import {describe, expect, it, vi} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import ClipboardController from "controllers/clipboard_controller";
import {ensure} from "helpers/ensure";

const url = "https://flash.test/shared/abc123";

function buildButton(): HTMLButtonElement {
  const buttonEl = document.createElement("button");
  buttonEl.type = "button";
  buttonEl.setAttribute("data-clipboard-target", "button");
  buttonEl.setAttribute("data-action", "click->clipboard#copy");
  buttonEl.textContent = "Copy";
  return buttonEl;
}

function setupDOM(): void {
  document.body.replaceChildren();

  const wrapper = document.createElement("div");
  wrapper.setAttribute("data-controller", "clipboard");
  wrapper.setAttribute("data-clipboard-url-value", url);
  wrapper.appendChild(buildButton());
  document.body.appendChild(wrapper);
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("clipboard", ClipboardController);
}

function element(): HTMLElement {
  const selector = "[data-controller='clipboard']";

  return ensure(document.querySelector<HTMLElement>(selector));
}

function controller(): ClipboardController {
  return getController(element(), "clipboard", ClipboardController);
}

const buttonSelector = "[data-clipboard-target='button']";

function button(): HTMLButtonElement {
  return ensure(document.querySelector<HTMLButtonElement>(buttonSelector));
}

function stubClipboard(writeText: (text: string) => Promise<void>): void {
  Object.defineProperty(navigator, "clipboard", {
    configurable: true,
    value: {writeText},
  });
}

function resolvedWriteText(): (text: string) => Promise<void> {
  return vi.fn<(text: string) => Promise<void>>().mockResolvedValue(undefined);
}

describe("copy", () => {
  it("writes the url value to the clipboard", async () => {
    const writeText = resolvedWriteText();
    stubClipboard(writeText);
    await setupController();

    await controller().copy();

    expect(writeText).toHaveBeenCalledWith(url);
  });

  it("sets the button text to 'Copied!' after writing", async () => {
    stubClipboard(resolvedWriteText());
    await setupController();

    await controller().copy();

    expect(button().textContent).toBe("Copied!");
  });

  it("restores the original button text after 1500ms", async () => {
    vi.useFakeTimers();
    stubClipboard(resolvedWriteText());
    await setupController();
    await controller().copy();
    await vi.advanceTimersByTimeAsync(1500);
    const textAfterReset = button().textContent;
    vi.useRealTimers();

    expect(textAfterReset).toBe("Copy");
  });

  it("does not restore the original text before 1500ms", async () => {
    vi.useFakeTimers();
    stubClipboard(resolvedWriteText());
    await setupController();
    await controller().copy();
    await vi.advanceTimersByTimeAsync(1499);
    const textBeforeReset = button().textContent;
    vi.useRealTimers();

    expect(textBeforeReset).toBe("Copied!");
  });
});
