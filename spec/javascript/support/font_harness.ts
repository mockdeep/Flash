import type {Mock} from "vitest";
import {vi} from "vitest";

import {bootStimulus, getController} from "support/stimulus";
import FontController from "controllers/font_controller";
import {ensure} from "helpers/ensure";

type Font = "hei" | "song" | "kai" | "hand" | "semantic";
type Choice = Font | "random";
type EventTargetName = "target" | "currentTarget";

const CHOICES: readonly Choice[] =
  ["hei", "song", "kai", "hand", "semantic", "random"];
const DECK_ID = "42";
const STORAGE_KEY = `font:${DECK_ID}`;
const ROOT_SEL = "[data-controller='font']";

type FontLoad = (font: string, text?: string) => Promise<unknown[]>;

interface FontsStub {
  load: Mock<FontLoad>;
}

// Jsdom has no FontFaceSet; tests exercising prewarming install this stub.
function stubFonts(overrides: Partial<FontsStub> = {}): FontsStub {
  const fonts: FontsStub = {
    load: vi.fn<FontLoad>(async () => { return Promise.resolve([]); }),
    ...overrides,
  };
  Object.defineProperty(document, "fonts", {
    configurable: true,
    value: fonts,
  });

  return fonts;
}

function buildCard(cardId: string): HTMLElement {
  const div = document.createElement("div");
  div.dataset.fontTarget = "card";
  div.dataset.cardId = cardId;

  return div;
}

function buildOption(choice: Choice): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.fontTarget = "option";
  button.dataset.font = choice;
  button.setAttribute("aria-checked", "false");

  return button;
}

function setupDOM(hanzi: string): void {
  const root = document.createElement("div");
  root.dataset.controller = "font";
  root.dataset.fontDeckIdValue = DECK_ID;
  if (hanzi !== "") { root.dataset.fontHanziValue = hanzi; }

  for (const choice of CHOICES) { root.appendChild(buildOption(choice)); }

  document.body.replaceChildren(root);
}

async function boot(storedChoice?: Choice, hanzi = ""): Promise<void> {
  if (storedChoice !== undefined) {
    localStorage.setItem(STORAGE_KEY, storedChoice);
  }
  setupDOM(hanzi);
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

export type {FontLoad};
export {
  boot,
  buildCard,
  buildOption,
  controller,
  element,
  eventTargeting,
  option,
  selectEvent,
  STORAGE_KEY,
  stubFonts,
};
export type {Choice, Font};
