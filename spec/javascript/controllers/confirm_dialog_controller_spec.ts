import {describe, expect, it, vi} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import ConfirmDialogController from "controllers/confirm_dialog_controller";
import {ensure} from "helpers/ensure";

function setupDOM(): void {
  document.body.replaceChildren();

  const formEl = document.createElement("form");
  formEl.setAttribute("data-controller", "confirm-dialog");
  formEl.setAttribute("data-action", "submit->confirm-dialog#intercept");

  const dialogEl = document.createElement("dialog");
  dialogEl.setAttribute("data-confirm-dialog-target", "dialog");

  // HTMLDialogElement.showModal and close are not implemented in jsdom
  Object.assign(dialogEl, {
    close(): void { /* Noop for jsdom */ },
    showModal(): void { /* Noop for jsdom */ },
  });

  formEl.appendChild(dialogEl);
  document.body.appendChild(formEl);
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("confirm-dialog", ConfirmDialogController);
}

function form(): HTMLFormElement {
  const selector = "form[data-controller='confirm-dialog']";

  return ensure(document.querySelector<HTMLFormElement>(selector));
}

function controller(): ConfirmDialogController {
  return getController(form(), "confirm-dialog", ConfirmDialogController);
}

function dialog(): HTMLDialogElement {
  const selector = "dialog[data-confirm-dialog-target='dialog']";

  return ensure(document.querySelector<HTMLDialogElement>(selector));
}

function buildSubmitEvent(): SubmitEvent {
  return new SubmitEvent("submit", {cancelable: true});
}

describe("intercept", () => {
  it("cancels the submission", async () => {
    await setupController();
    const event = buildSubmitEvent();

    controller().intercept(event);

    expect(event.defaultPrevented).toBe(true);
  });

  it("opens the dialog", async () => {
    await setupController();
    const showModal = vi.spyOn(dialog(), "showModal");

    controller().intercept(buildSubmitEvent());

    expect(showModal).toHaveBeenCalledWith();
  });

  it("lets the submission through after confirmation", async () => {
    await setupController();
    vi.spyOn(form(), "requestSubmit").mockReturnValue(undefined);
    controller().confirm();
    const event = buildSubmitEvent();

    controller().intercept(event);

    expect(event.defaultPrevented).toBe(false);
  });

  it("asks again on the next submission after a confirmed one", async () => {
    await setupController();
    vi.spyOn(form(), "requestSubmit").mockReturnValue(undefined);
    controller().confirm();
    controller().intercept(buildSubmitEvent());
    const event = buildSubmitEvent();

    controller().intercept(event);

    expect(event.defaultPrevented).toBe(true);
  });
});

describe("confirm", () => {
  it("closes the dialog", async () => {
    await setupController();
    vi.spyOn(form(), "requestSubmit").mockReturnValue(undefined);
    const close = vi.spyOn(dialog(), "close");

    controller().confirm();

    expect(close).toHaveBeenCalledWith();
  });

  it("resubmits the form", async () => {
    await setupController();
    const requestSubmit =
      vi.spyOn(form(), "requestSubmit").mockReturnValue(undefined);

    controller().confirm();

    expect(requestSubmit).toHaveBeenCalledWith();
  });
});

describe("close", () => {
  it("closes the dialog", async () => {
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
