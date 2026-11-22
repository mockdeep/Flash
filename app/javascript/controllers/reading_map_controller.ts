import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";

const ZOOMS = [0.75, 1, 1.5, 2.25];
const DEFAULT_STEP = 1;

/*
 * Where to scroll so a spot `offset` along the box's content sits in the
 * middle of the `visible` stretch.
 */
function centered(offset: number, visible: number): number {
  return offset - visible / 2;
}

export default class extends Controller<HTMLElement> {
  static override targets = ["box", "canvas", "start"];

  declare boxTarget: HTMLElement;

  declare canvasTarget: HTMLElement;

  declare hasStartTarget: boolean;

  declare startTarget: HTMLElement;

  private step = DEFAULT_STEP;

  override connect(): void {
    this.scrollToStart("instant");
  }

  zoomIn(): void {
    this.zoomBy(1);
  }

  zoomOut(): void {
    this.zoomBy(-1);
  }

  recenter(): void {
    this.scrollToStart("auto");
  }

  // The spot in the middle of the box stays there as the map changes size.
  private zoomBy(delta: number): void {
    const box = this.boxTarget;
    const across = (box.scrollLeft + box.clientWidth / 2) / box.scrollWidth;
    const down = (box.scrollTop + box.clientHeight / 2) / box.scrollHeight;

    this.step = Math.min(ZOOMS.length - 1, Math.max(0, this.step + delta));
    const zoom = String(ensure(ZOOMS[this.step]));
    this.canvasTarget.style.setProperty("--zoom", zoom);
    box.scrollTo({
      behavior: "instant",
      left: centered(across * box.scrollWidth, box.clientWidth),
      top: centered(down * box.scrollHeight, box.clientHeight),
    });
  }

  // The map's starting node, or its middle when it has none.
  private scrollToStart(behavior: ScrollBehavior): void {
    const box = this.boxTarget;
    let left = box.scrollWidth / 2;
    let top = box.scrollHeight / 2;

    if (this.hasStartTarget) {
      const start = this.startTarget.getBoundingClientRect();
      const frame = box.getBoundingClientRect();
      left = box.scrollLeft + start.left - frame.left + start.width / 2;
      top = box.scrollTop + start.top - frame.top + start.height / 2;
    }

    box.scrollTo({
      behavior,
      left: centered(left, box.clientWidth),
      top: centered(top, box.clientHeight),
    });
  }
}
