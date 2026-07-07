import {bootStimulus, getController} from "support/stimulus";
import FontController from "controllers/font_controller";
import {ensure} from "helpers/ensure";

type Font = "hei" | "song" | "kai" | "hand";
type Choice = Font | "mix";
type EventTargetName = "target" | "currentTarget";

const CHOICES: readonly Choice[] = ["hei", "song", "kai", "hand", "mix"];
const DECK_ID = "42";
const STORAGE_KEY = `font:${DECK_ID}`;
const ROOT_SEL = "[data-controller='font']";

function buildOption(choice: Choice): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.fontTarget = "option";
  button.dataset.font = choice;
  button.setAttribute("aria-checked", "false");

  return button;
}

function setupDOM(): void {
  const root = document.createElement("div");
  root.dataset.controller = "font";
  root.dataset.fontDeckIdValue = DECK_ID;

  for (const choice of CHOICES) { root.appendChild(buildOption(choice)); }

  document.body.replaceChildren(root);
}

async function boot(storedChoice?: Choice): Promise<void> {
  if (storedChoice !== undefined) {
    localStorage.setItem(STORAGE_KEY, storedChoice);
  }
  setupDOM();
  await bootStimulus("font", FontController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(ROOT_SEL));
}

function controller(): FontController {
  return getController(element(), "font", FontController);
}

function option(choice: Choice): HTMLButtonElement {
  const sel = `[data-font-target='option'][data-font='${choice}']`;

  return ensure(document.querySelector<HTMLButtonElement>(sel));
}

function eventTargeting(name: EventTargetName, node: unknown): MouseEvent {
  const event = new MouseEvent("click");
  Object.defineProperty(event, name, {value: node});

  return event;
}

function selectEvent(choice: Choice): MouseEvent {
  return eventTargeting("currentTarget", option(choice));
}

export {
  boot,
  buildOption,
  controller,
  element,
  eventTargeting,
  option,
  selectEvent,
  STORAGE_KEY,
};
export type {Choice, Font};
