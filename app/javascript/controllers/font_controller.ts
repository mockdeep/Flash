import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";

const FONTS = ["hei", "song", "kai", "hand"] as const;
type Font = (typeof FONTS)[number];
type Choice = Font | "mix";

const DEFAULT_CHOICE: Choice = "hei";

function isFont(value: string | null | undefined): value is Font {
  return value === "hei" || value === "song" ||
    value === "kai" || value === "hand";
}

function isChoice(value: string | null | undefined): value is Choice {
  return value === "mix" || isFont(value);
}

function randomFont(): Font {
  return ensure(FONTS[Math.floor(Math.random() * FONTS.length)]);
}

function storageKey(deckId: string): string {
  return `font:${deckId}`;
}

function loadChoice(deckId: string): Choice {
  const raw = localStorage.getItem(storageKey(deckId));
  if (isChoice(raw)) { return raw; }

  return DEFAULT_CHOICE;
}

function saveChoice(deckId: string, choice: Choice): void {
  localStorage.setItem(storageKey(deckId), choice);
}

export default class extends Controller<HTMLElement> {
  static override targets = ["option"];

  static override values = {deckId: String};

  declare optionTargets: HTMLElement[];

  declare deckIdValue: string;

  private choice: Choice = DEFAULT_CHOICE;

  override connect(): void {
    this.applyChoice(loadChoice(this.deckIdValue));
  }

  setFont(event: MouseEvent): void {
    const target = event.currentTarget;
    if (!(target instanceof HTMLElement)) { return; }
    const {font} = target.dataset;
    if (!isChoice(font)) { return; }
    this.applyChoice(font);
    saveChoice(this.deckIdValue, font);
  }

  /*
   * Mix picks a fresh font for every card; the frame element survives Turbo
   * frame navigations, so this fires on each turbo:frame-load.
   */
  reroll(): void {
    if (this.choice !== "mix") { return; }
    this.applyFont(randomFont());
  }

  optionTargetConnected(option: HTMLElement): void {
    this.syncOption(option);
  }

  private applyChoice(choice: Choice): void {
    this.choice = choice;
    this.optionTargets.forEach((option) => { this.syncOption(option); });
    if (choice === "mix") {
      this.applyFont(randomFont());
    } else {
      this.applyFont(choice);
    }
  }

  private applyFont(font: Font): void {
    this.element.dataset.font = font;
  }

  private syncOption(option: HTMLElement): void {
    const matches = option.dataset.font === this.choice;
    option.setAttribute("aria-checked", String(matches));
  }
}
