import {describe, expect, it} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import DeckTypeController from "controllers/deck_type_controller";
import {ensure} from "helpers/ensure";

const textSel = "[data-deck-type-target='textInstructions']";
const musicSel = "[data-deck-type-target='musicInstructions']";
const settingsSel = "[data-deck-type-target='musicSettings']";
const languageSel = "[data-deck-type-target='languageSettings']";
const rootSel = "[data-controller='deck-type']";

type RadioValue = "text" | "language" | "music";
type InstructionsName =
  "textInstructions" |
  "musicInstructions" |
  "musicSettings" |
  "languageSettings";

function buildRadio(value: RadioValue, checked: boolean): HTMLInputElement {
  const input = document.createElement("input");
  input.type = "radio";
  input.name = "deck[deck_type]";
  input.value = value;
  input.checked = checked;
  input.dataset.deckTypeTarget = "radio";
  input.dataset.action = "change->deck-type#update";

  return input;
}

function buildInstructions(
  name: InstructionsName,
  hidden: boolean,
): HTMLElement {
  const div = document.createElement("div");
  div.dataset.deckTypeTarget = name;
  div.hidden = hidden;

  return div;
}

function setupDOM(): void {
  const root = document.createElement("div");
  root.dataset.controller = "deck-type";
  root.appendChild(buildRadio("text", true));
  root.appendChild(buildRadio("language", false));
  root.appendChild(buildRadio("music", false));
  root.appendChild(buildInstructions("textInstructions", false));
  root.appendChild(buildInstructions("musicInstructions", true));
  root.appendChild(buildInstructions("musicSettings", true));
  root.appendChild(buildInstructions("languageSettings", true));

  document.body.replaceChildren(root);
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("deck-type", DeckTypeController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(rootSel));
}

function controller(): DeckTypeController {
  return getController(element(), "deck-type", DeckTypeController);
}

function textInstructions(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(textSel));
}

function musicInstructions(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(musicSel));
}

function musicSettings(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(settingsSel));
}

function languageSettings(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(languageSel));
}

function radio(value: RadioValue): HTMLInputElement {
  const sel = `input[name="deck[deck_type]"][value="${value}"]`;

  return ensure(document.querySelector<HTMLInputElement>(sel));
}

describe("connect with text selected", () => {
  it("shows the text instructions", async () => {
    await setupController();

    expect(textInstructions().hidden).toBe(false);
  });

  it("hides the music instructions", async () => {
    await setupController();

    expect(musicInstructions().hidden).toBe(true);
  });

  it("hides the music settings", async () => {
    await setupController();

    expect(musicSettings().hidden).toBe(true);
  });

  it("hides the language settings", async () => {
    await setupController();

    expect(languageSettings().hidden).toBe(true);
  });
});

describe("update after selecting music", () => {
  it("hides the text instructions", async () => {
    await setupController();
    radio("text").checked = false;
    radio("music").checked = true;

    controller().update();

    expect(textInstructions().hidden).toBe(true);
  });

  it("shows the music instructions", async () => {
    await setupController();
    radio("text").checked = false;
    radio("music").checked = true;

    controller().update();

    expect(musicInstructions().hidden).toBe(false);
  });

  it("shows the music settings", async () => {
    await setupController();
    radio("text").checked = false;
    radio("music").checked = true;

    controller().update();

    expect(musicSettings().hidden).toBe(false);
  });
});

describe("update after selecting language", () => {
  it("shows the language settings", async () => {
    await setupController();
    radio("text").checked = false;
    radio("language").checked = true;

    controller().update();

    expect(languageSettings().hidden).toBe(false);
  });

  it("keeps the text instructions visible", async () => {
    await setupController();
    radio("text").checked = false;
    radio("language").checked = true;

    controller().update();

    expect(textInstructions().hidden).toBe(false);
  });
});

describe("update after switching from language back to text", () => {
  it("re-hides the language settings", async () => {
    await setupController();
    radio("text").checked = false;
    radio("language").checked = true;
    controller().update();

    radio("language").checked = false;
    radio("text").checked = true;
    controller().update();

    expect(languageSettings().hidden).toBe(true);
  });
});

describe("update after switching back to text", () => {
  it("re-shows the text instructions", async () => {
    await setupController();
    radio("text").checked = false;
    radio("music").checked = true;
    controller().update();

    radio("music").checked = false;
    radio("text").checked = true;
    controller().update();

    expect(textInstructions().hidden).toBe(false);
  });
});

describe("update with no radio selected", () => {
  it("treats it as non-music (shows text)", async () => {
    await setupController();
    radio("text").checked = false;

    controller().update();

    expect(textInstructions().hidden).toBe(false);
  });
});
