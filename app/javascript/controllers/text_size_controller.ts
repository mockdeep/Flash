import {Controller} from "@hotwired/stimulus";

import {assert as ensure} from "helpers/assert";

const SIZES = ["s", "m", "l", "xl"] as const;
type Size = (typeof SIZES)[number];

const DEFAULT_SIZE: Size = "m";

function isSize(value: string | null | undefined): value is Size {
  return value === "s" || value === "m" || value === "l" || value === "xl";
}

function storageKey(deckId: string): string {
  return `text-size:${deckId}`;
}

function loadSize(deckId: string): Size {
  const raw = localStorage.getItem(storageKey(deckId));
  if (isSize(raw)) { return raw; }

  return DEFAULT_SIZE;
}

function saveSize(deckId: string, size: Size): void {
  localStorage.setItem(storageKey(deckId), size);
}

export default class extends Controller<HTMLElement> {
  static override targets = ["menu", "toggle", "option"];

  static override values = {deckId: String};

  declare menuTarget: HTMLElement;

  declare toggleTarget: HTMLButtonElement;

  declare optionTargets: HTMLElement[];

  declare deckIdValue: string;

  private size: Size = DEFAULT_SIZE;

  private isMenuOpen = false;

  override connect(): void {
    this.applySize(loadSize(this.deckIdValue));
  }

  toggleMenu(event: MouseEvent): void {
    event.stopPropagation();
    this.setMenuOpen(!this.isMenuOpen);
  }

  setSize(event: MouseEvent): void {
    const target = event.currentTarget;
    if (!(target instanceof HTMLElement)) { return; }
    const {size} = target.dataset;
    if (!isSize(size)) { return; }
    this.applySize(size);
    saveSize(this.deckIdValue, size);
    this.setMenuOpen(false);
  }

  smaller(): void {
    this.stepSize(-1);
  }

  larger(): void {
    this.stepSize(1);
  }

  handleDocClick(event: MouseEvent): void {
    if (!this.isMenuOpen) { return; }
    if (!(event.target instanceof Node)) { return; }
    if (this.element.contains(event.target)) { return; }
    this.setMenuOpen(false);
  }

  handleEsc(event: KeyboardEvent): void {
    if (event.key !== "Escape") { return; }
    if (!this.isMenuOpen) { return; }
    this.setMenuOpen(false);
  }

  private stepSize(delta: number): void {
    const idx = SIZES.indexOf(this.size);
    const nextIdx = Math.min(SIZES.length - 1, Math.max(0, idx + delta));
    if (nextIdx === idx) { return; }
    const next = ensure(SIZES[nextIdx]);
    this.applySize(next);
    saveSize(this.deckIdValue, next);
  }

  private applySize(size: Size): void {
    this.size = size;
    this.element.dataset.size = size;
    this.optionTargets.forEach((option) => {
      const matches = option.dataset.size === size;
      option.setAttribute("aria-checked", String(matches));
    });
  }

  private setMenuOpen(open: boolean): void {
    this.isMenuOpen = open;
    this.menuTarget.hidden = !open;
    this.toggleTarget.setAttribute("aria-expanded", String(open));
  }
}
