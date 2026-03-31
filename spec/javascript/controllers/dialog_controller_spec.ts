import {bootStimulus, getController} from "support/stimulus";
import DialogController from "controllers/dialog_controller";
import {assert} from "helpers/assert";

// HTMLDialogElement.showModal and close are not implemented in jsdom
// eslint-disable-next-line vitest/require-hook
Object.assign(HTMLDialogElement.prototype, {
  close(): void { /* Noop for jsdom */ },
  showModal(): void { /* Noop for jsdom */ },
});

function setupDOM(): void {
  const wrapper = document.createElement("div");
  wrapper.setAttribute("data-controller", "dialog");

  const dialogEl = document.createElement("dialog");
  dialogEl.setAttribute("data-dialog-target", "dialog");

  wrapper.appendChild(dialogEl);
  document.body.appendChild(wrapper);
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("dialog", DialogController);
}

function element(): HTMLElement {
  const selector = "[data-controller='dialog']";

  return assert(document.querySelector<HTMLElement>(selector));
}

function controller(): DialogController {
  return getController(element(), "dialog", DialogController);
}

function dialog(): HTMLDialogElement {
  const selector = "dialog[data-dialog-target='dialog']";

  return assert(document.querySelector<HTMLDialogElement>(selector));
}

describe("open", () => {
  it("calls showModal on the dialog target", async () => {
    await setupController();
    const showModal = vi.spyOn(dialog(), "showModal");

    controller().open();

    expect(showModal).toHaveBeenCalledWith();
  });
});

describe("close", () => {
  it("calls close on the dialog target", async () => {
    await setupController();
    const close = vi.spyOn(dialog(), "close");

    controller().close();

    expect(close).toHaveBeenCalledWith();
  });
});

describe("closeOnBackdropClick", () => {
  it("closes the dialog when clicking the backdrop", async () => {
    await setupController();
    const close = vi.spyOn(dialog(), "close");
    const event = new MouseEvent("click");
    Object.defineProperty(event, "target", {value: dialog()});

    controller().closeOnBackdropClick(event);

    expect(close).toHaveBeenCalledWith();
  });

  it("does not close when clicking inside the dialog content", async () => {
    await setupController();
    const close = vi.spyOn(dialog(), "close");
    const inner = document.createElement("div");
    dialog().appendChild(inner);
    const event = new MouseEvent("click");
    Object.defineProperty(event, "target", {value: inner});

    controller().closeOnBackdropClick(event);

    expect(close).not.toHaveBeenCalled();
  });
});

describe("closeOnSuccess", () => {
  it("closes the dialog when the submission succeeded", async () => {
    await setupController();
    const close = vi.spyOn(dialog(), "close");
    const event = new CustomEvent<{success: boolean}>(
      "turbo:submit-end",
      {detail: {success: true}},
    );

    controller().closeOnSuccess(event);

    expect(close).toHaveBeenCalledWith();
  });

  it("does not close the dialog when the submission failed", async () => {
    await setupController();
    const close = vi.spyOn(dialog(), "close");
    const event = new CustomEvent<{success: boolean}>(
      "turbo:submit-end",
      {detail: {success: false}},
    );

    controller().closeOnSuccess(event);

    expect(close).not.toHaveBeenCalled();
  });
});
