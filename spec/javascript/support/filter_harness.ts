import {afterEach} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import FilterController from "controllers/filter_controller";
import {ensure} from "helpers/ensure";

const ROOT_SEL = "[data-controller='filter']";
const KEY = "harness-section";
const ACTIVE_CLASS = "tab--on";

function buildTab(value: string): HTMLButtonElement {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.filterValueParam = value;
  button.dataset.filterTarget = "tab";
  if (value === "All") { button.classList.add(ACTIVE_CLASS); }

  return button;
}

function buildItem(value: string): HTMLElement {
  const item = document.createElement("div");
  item.dataset.filterValue = value;
  item.dataset.filterTarget = "item";

  return item;
}

function setupDOM(values: string[], withTabs: boolean): void {
  const root = document.createElement("div");
  root.dataset.controller = "filter";
  root.dataset.filterKeyValue = KEY;
  root.dataset.filterActiveClass = ACTIVE_CLASS;

  if (withTabs) {
    ["All", ...new Set(values)].forEach((value) => {
      root.appendChild(buildTab(value));
    });
  }

  values.forEach((value) => { root.appendChild(buildItem(value)); });

  document.body.replaceChildren(root);
}

async function boot(
  values = ["red", "red", "blue"],
  {withTabs = true} = {},
): Promise<void> {
  setupDOM(values, withTabs);
  await bootStimulus("filter", FilterController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>(ROOT_SEL));
}

function controller(): FilterController {
  return getController(element(), "filter", FilterController);
}

function items(): HTMLElement[] {
  const sel = "[data-filter-target='item']";

  return [...document.querySelectorAll<HTMLElement>(sel)];
}

function activeTab(): HTMLButtonElement | null {
  return document.querySelector<HTMLButtonElement>(`.${ACTIVE_CLASS}`);
}

function storageKey(): string {
  return `filter-tab:${KEY}`;
}

afterEach(() => { localStorage.clear(); });

export {activeTab, boot, controller, element, items, storageKey};
