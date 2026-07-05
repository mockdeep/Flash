import {bootStimulus, getController} from "support/stimulus";
import TextSizeController from "controllers/text_size_controller";
import {ensure} from "helpers/ensure";

type Size = "s" | "m" | "l" | "xl";
type EventTargetName = "target" | "currentTarget";

const SIZES: readonly Size[] = ["s", "m", "l", "xl"];
const DECK_ID = "42";
const STORAGE_KEY = `text-size:${DECK_ID}`;
const ROOT_SEL = "[data-controller='text-size']";
const MENU_SEL = "[data-text-size-target='menu']";
const TOGGLE_SEL = "[data-text-size-target='toggle']";

function buildToggle(): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.textSizeTarget = "toggle";
  button.setAttribute("aria-expanded", "false");

  return button;
}

function buildMenu(): HTMLElement {
  const div = document.createElement("div");
  div.dataset.textSizeTarget = "menu";
  div.hidden = true;

  return div;
}

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

  root.appendChild(buildToggle());
  root.appendChild(buildMenu());
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

function menu(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(MENU_SEL));
}

function toggle(): HTMLButtonElement {
  return ensure(document.querySelector<HTMLButtonElement>(TOGGLE_SEL));
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

function clickEventOn(target: unknown): MouseEvent {
  return eventTargeting("target", target);
}

function keyEvent(key: string): KeyboardEvent {
  return new KeyboardEvent("keydown", {key});
}

function openMenu(): void {
  controller().toggleMenu(new MouseEvent("click"));
}

export {
  boot,
  clickEventOn,
  controller,
  element,
  eventTargeting,
  keyEvent,
  menu,
  openMenu,
  option,
  selectEvent,
  STORAGE_KEY,
  toggle,
};
export type {Size};
