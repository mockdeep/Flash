import {bootStimulus, getController} from "support/stimulus";
import DisclosureController from "controllers/disclosure_controller";
import {ensure} from "helpers/ensure";

const ROOT_SEL = "[data-controller='disclosure']";
const TOGGLE_SEL = "[data-disclosure-target='toggle']";
const PANEL_SEL = "[data-disclosure-target='panel']";

function buildToggle(): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.disclosureTarget = "toggle";
  button.setAttribute("aria-expanded", "false");

  return button;
}

function buildPanel(): HTMLElement {
  const div = document.createElement("div");
  div.dataset.disclosureTarget = "panel";
  div.hidden = true;

  return div;
}

function setupDOM(): void {
  const root = document.createElement("div");
  root.dataset.controller = "disclosure";

  root.appendChild(buildToggle());
  root.appendChild(buildPanel());

  document.body.replaceChildren(root);
}

async function boot(): Promise<void> {
  setupDOM();
  await bootStimulus("disclosure", DisclosureController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(ROOT_SEL));
}

function controller(): DisclosureController {
  return getController(element(), "disclosure", DisclosureController);
}

function toggle(): HTMLButtonElement {
  return ensure(document.querySelector<HTMLButtonElement>(TOGGLE_SEL));
}

function panel(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(PANEL_SEL));
}

function clickEventOn(target: unknown): MouseEvent {
  const event = new MouseEvent("click");
  Object.defineProperty(event, "target", {value: target});

  return event;
}

function keyEvent(key: string): KeyboardEvent {
  return new KeyboardEvent("keydown", {key});
}

function open(): void {
  controller().toggle();
}

export {
  boot,
  clickEventOn,
  controller,
  element,
  keyEvent,
  open,
  panel,
  toggle,
};
