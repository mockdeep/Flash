import {bootStimulus, getController} from "support/stimulus";
import RailController from "controllers/rail_controller";
import {ensure} from "helpers/ensure";

const ROOT_SEL = "[data-controller='rail']";

const ARROW_DIRS = {left: "-1", right: "1"} as const;

function buildArrow(side: keyof typeof ARROW_DIRS): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.railTarget = `${side}Arrow`;
  button.dataset.railDirParam = ARROW_DIRS[side];
  button.hidden = true;

  return button;
}

function buildRail(cardCount: number): HTMLElement {
  const list = document.createElement("div");
  list.dataset.railTarget = "rail";
  Array.from({length: cardCount}).forEach(() => {
    list.appendChild(document.createElement("div"));
  });

  return list;
}

function setupDOM(): void {
  const root = document.createElement("section");
  root.dataset.controller = "rail";

  root.appendChild(buildArrow("left"));
  root.appendChild(buildRail(3));
  root.appendChild(buildArrow("right"));

  document.body.replaceChildren(root);
}

async function boot(): Promise<void> {
  setupDOM();
  await bootStimulus("rail", RailController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(ROOT_SEL));
}

function controller(): RailController {
  return getController(element(), "rail", RailController);
}

function rail(): HTMLElement {
  const sel = "[data-rail-target='rail']";

  return ensure(document.querySelector<HTMLElement>(sel));
}

function arrows(): HTMLButtonElement[] {
  const sel = "[data-rail-target='leftArrow'], [data-rail-target='rightArrow']";

  return [...document.querySelectorAll<HTMLButtonElement>(sel)];
}

function stubRailWidths(
  scrollWidth: number,
  clientWidth: number,
  scrollLeft = 0,
): void {
  Object.defineProperty(rail(), "scrollWidth", {value: scrollWidth});
  Object.defineProperty(rail(), "clientWidth", {value: clientWidth});
  Object.defineProperty(rail(), "scrollLeft", {value: scrollLeft});
}

export {arrows, boot, controller, element, rail, stubRailWidths};
