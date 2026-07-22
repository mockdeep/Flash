import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";

const FONTS = ["hei", "song", "kai", "hand", "semantic"] as const;
type Font = (typeof FONTS)[number];
type Choice = Font | "random";

const DEFAULT_CHOICE: Choice = "hei";

// Mirrors the --hanzi-font mapping in flash.css.
const FAMILIES: {[font in Font]: string} = {
  hand: "Ma Shan Zheng",
  hei: "Noto Sans SC",
  kai: "LXGW WenKai",
  semantic: "Flash Hanzi Semantic",
  song: "Noto Serif SC",
};

function isFont(value: string | null | undefined): value is Font {
  return value === "hei" || value === "song" ||
    value === "kai" || value === "hand" || value === "semantic";
}

function isChoice(value: string | null | undefined): value is Choice {
  return value === "random" || isFont(value);
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
  static override targets = ["card", "option"];

  static override values = {deckId: String, hanzi: String};

  declare optionTargets: HTMLElement[];

  declare deckIdValue: string;

  declare hanziValue: string;

  private choice: Choice = DEFAULT_CHOICE;

  private lastCardId: string | null = null;

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
   * Random picks a fresh font per card, not per Turbo frame swap: answering
   * re-renders the frame with the same card's result, and that card must keep
   * the font it was asked in. Card elements carry their card id, so a reroll
   * only happens when a different card connects.
   */
  cardTargetConnected(card: HTMLElement): void {
    const {cardId} = card.dataset;
    if (cardId === undefined || cardId === this.lastCardId) { return; }
    this.lastCardId = cardId;
    if (this.choice !== "random") { return; }
    this.applyFont(randomFont());
  }

  optionTargetConnected(option: HTMLElement): void {
    this.syncOption(option);
  }

  private applyChoice(choice: Choice): void {
    this.choice = choice;
    this.optionTargets.forEach((option) => { this.syncOption(option); });
    if (choice === "random") {
      this.applyFont(randomFont());
      FONTS.forEach((font) => { this.warm(font); });
    } else {
      this.applyFont(choice);
      this.warm(choice);
    }
  }

  private applyFont(font: Font): void {
    this.element.dataset.font = font;
  }

  /*
   * Ask the browser to fetch every slice of the family that the deck's
   * characters (embedded on the initial page render) will need, so cards
   * first paint in the correct font instead of popping in slice by slice.
   * Slices are immutable-cached, and the browser never re-fetches a loaded
   * face, so repeat calls cost only the range matching.
   */
  private warm(font: Font): void {
    if (this.hanziValue === "") { return; }
    document.fonts.load(`1em "${FAMILIES[font]}"`, this.hanziValue).
      catch(() => { return null; });
  }

  private syncOption(option: HTMLElement): void {
    const matches = option.dataset.font === this.choice;
    option.setAttribute("aria-checked", String(matches));
  }
}
