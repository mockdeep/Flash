import {vi} from "vitest";

import {bootStimulus, getController} from "support/stimulus";
import ReadingMapController from "controllers/reading_map_controller";
import {ensure} from "helpers/ensure";

type ScrollToFn = (options: ScrollToOptions) => void;

// A box 800 by 400 showing a map 2000 by 1000, scrolled 100 across, 50 down.
const BOX = {
  clientHeight: 400,
  clientWidth: 800,
  scrollHeight: 1000,
  scrollLeft: 100,
  scrollTop: 50,
  scrollWidth: 2000,
};

// Where the box and the starting node sit on the screen.
const BOX_RECT = new DOMRect(10, 20, 800, 400);
const START_RECT = new DOMRect(510, 320, 40, 60);

let scrollTo: ReturnType<typeof vi.fn<ScrollToFn>> | null = null;

function build(target: string, parent: HTMLElement): HTMLElement {
  const element = document.createElement("div");
  element.dataset.readingMapTarget = target;
  parent.appendChild(element);

  return element;
}

function buildBox(root: HTMLElement): HTMLElement {
  const box = build("box", root);
  Object.entries(BOX).forEach(([name, value]) => {
    Object.defineProperty(box, name, {value});
  });
  const spy = vi.fn<ScrollToFn>();
  scrollTo = spy;
  Object.defineProperty(box, "scrollTo", {value: spy});
  vi.spyOn(box, "getBoundingClientRect").mockReturnValue(BOX_RECT);

  return box;
}

function setupDOM(withStart: boolean): void {
  const root = document.createElement("div");
  root.dataset.controller = "reading-map";
  const canvas = build("canvas", buildBox(root));

  if (withStart) {
    const start = build("start", canvas);
    vi.spyOn(start, "getBoundingClientRect").mockReturnValue(START_RECT);
  }

  document.body.replaceChildren(root);
}

async function boot({start = true} = {}): Promise<void> {
  setupDOM(start);
  await bootStimulus("reading-map", ReadingMapController);
}

function find(target: string): HTMLElement {
  const sel = `[data-reading-map-target='${target}']`;

  return ensure(document.querySelector<HTMLElement>(sel));
}

function controller(): ReadingMapController {
  const sel = "[data-controller='reading-map']";
  const element = ensure(document.querySelector<HTMLElement>(sel));

  return getController(element, "reading-map", ReadingMapController);
}

function scrolls(): ScrollToOptions[] {
  return ensure(scrollTo).mock.calls.map(([options]) => { return options; });
}

function zoom(): string {
  return find("canvas").style.getPropertyValue("--zoom");
}

export {boot, controller, scrolls, zoom};
