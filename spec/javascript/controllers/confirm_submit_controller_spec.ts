import {describe, expect, it, vi} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import ConfirmSubmitController from "controllers/confirm_submit_controller";
import {ensure} from "helpers/ensure";

const message = "Are you sure?";

function setupDOM(): void {
  document.body.replaceChildren();

  const formEl = document.createElement("form");
  formEl.setAttribute("data-controller", "confirm-submit");
  formEl.setAttribute("data-confirm-submit-message-value", message);
  formEl.setAttribute("data-action", "submit->confirm-submit#confirm");
  document.body.appendChild(formEl);
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("confirm-submit", ConfirmSubmitController);
}

function element(): HTMLElement {
  const selector = "[data-controller='confirm-submit']";

  return ensure(document.querySelector<HTMLElement>(selector));
}

function controller(): ConfirmSubmitController {
  return getController(element(), "confirm-submit", ConfirmSubmitController);
}

function buildSubmitEvent(): SubmitEvent {
  return new SubmitEvent("submit", {cancelable: true});
}

describe("confirm", () => {
  it("calls window.confirm with the configured message", async () => {
    await setupController();
    const confirmSpy = vi.spyOn(window, "confirm").mockReturnValue(true);

    controller().confirm(buildSubmitEvent());

    expect(confirmSpy).toHaveBeenCalledWith(message);
  });

  it("does not cancel the event when the user accepts", async () => {
    await setupController();
    vi.spyOn(window, "confirm").mockReturnValue(true);
    const event = buildSubmitEvent();

    controller().confirm(event);

    expect(event.defaultPrevented).toBe(false);
  });

  it("cancels the event when the user dismisses", async () => {
    await setupController();
    vi.spyOn(window, "confirm").mockReturnValue(false);
    const event = buildSubmitEvent();

    controller().confirm(event);

    expect(event.defaultPrevented).toBe(true);
  });
});
