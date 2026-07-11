import {Controller} from "@hotwired/stimulus";

const ALL = "All";

/*
 * Generic tab filtering: tabs carry a value param, items carry a matching
 * data-filter-value, and the "All" value shows everything. The chosen tab is
 * remembered per key in localStorage. Dispatches "filter:applied" so sibling
 * controllers can react to items showing and hiding.
 */
export default class extends Controller<HTMLElement> {
  static override targets = ["tab", "item"];

  static classes = ["active"];

  static override values = {key: String};

  declare tabTargets: HTMLButtonElement[];

  declare itemTargets: HTMLElement[];

  declare activeClass: string;

  declare keyValue: string;

  get storageKey(): string {
    return `filter-tab:${this.keyValue}`;
  }

  override connect(): void {
    if (this.tabTargets.length > 0) {
      this.apply(this.storedValue());
    }
  }

  select(event: {params: {value: string}}): void {
    this.apply(event.params.value);
    localStorage.setItem(this.storageKey, event.params.value);
  }

  private storedValue(): string {
    const value = localStorage.getItem(this.storageKey) ?? ALL;

    const known = this.tabTargets.some((tab) => {
      return tab.dataset.filterValueParam === value;
    });
    if (known) { return value; }

    return ALL;
  }

  private apply(value: string): void {
    this.itemTargets.forEach((item) => {
      item.hidden = value !== ALL && item.dataset.filterValue !== value;
    });
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.filterValueParam === value;
      tab.classList.toggle(this.activeClass, active);
    });
    this.dispatch("applied");
  }
}
