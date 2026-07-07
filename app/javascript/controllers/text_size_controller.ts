import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";

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
  static override targets = ["option"];

  static override values = {deckId: String};

  declare optionTargets: HTMLElement[];

  declare deckIdValue: string;

  private size: Size = DEFAULT_SIZE;

  override connect(): void {
    this.applySize(loadSize(this.deckIdValue));
  }

  setSize(event: MouseEvent): void {
    const target = event.currentTarget;
    if (!(target instanceof HTMLElement)) { return; }
    const {size} = target.dataset;
    if (!isSize(size)) { return; }
    this.applySize(size);
    saveSize(this.deckIdValue, size);
  }

  smaller(): void {
    this.stepSize(-1);
  }

  larger(): void {
    this.stepSize(1);
  }

  /*
   * Options re-render with each Turbo frame swap while the frame (and this
   * controller) persists, so sync each fresh option's checked state.
   */
  optionTargetConnected(option: HTMLElement): void {
    this.syncOption(option);
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
    this.optionTargets.forEach((option) => { this.syncOption(option); });
  }

  private syncOption(option: HTMLElement): void {
    const matches = option.dataset.size === this.size;
    option.setAttribute("aria-checked", String(matches));
  }
}
