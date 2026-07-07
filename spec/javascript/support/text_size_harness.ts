import {bootStimulus, getController} from "support/stimulus";
import TextSizeController from "controllers/text_size_controller";
import {ensure} from "helpers/ensure";

type Size = "s" | "m" | "l" | "xl";
type EventTargetName = "target" | "currentTarget";

const SIZES: readonly Size[] = ["s", "m", "l", "xl"];
const DECK_ID = "42";
const STORAGE_KEY = `text-size:${DECK_ID}`;
const ROOT_SEL = "[data-controller='text-size']";

function buildOption(size: Size): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.textSizeTarget = "option";
  button.dataset.size = size;
  button.setAttribute("aria-checked", "false");

  return button;
}

function setupDOM(): void {
  const root = document.createElement("div");
  root.dataset.controller = "text-size";
  root.dataset.textSizeDeckIdValue = DECK_ID;
  root.dataset.size = "m";

  for (const size of SIZES) { root.appendChild(buildOption(size)); }

  document.body.replaceChildren(root);
}

async function boot(storedSize?: Size): Promise<void> {
  if (storedSize !== undefined) {
    localStorage.setItem(STORAGE_KEY, storedSize);
  }
  setupDOM();
  await bootStimulus("text-size", TextSizeController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(ROOT_SEL));
}

function controller(): TextSizeController {
  return getController(element(), "text-size", TextSizeController);
}

function option(size: Size): HTMLButtonElement {
  const sel = `[data-text-size-target='option'][data-size='${size}']`;

  return ensure(document.querySelector<HTMLButtonElement>(sel));
}

function eventTargeting(name: EventTargetName, node: unknown): MouseEvent {
  const event = new MouseEvent("click");
  Object.defineProperty(event, name, {value: node});

  return event;
}

function selectEvent(size: Size): MouseEvent {
  return eventTargeting("currentTarget", option(size));
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
export type {Size};
