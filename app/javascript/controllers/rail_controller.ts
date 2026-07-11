import {Controller} from "@hotwired/stimulus";

export default class extends Controller<HTMLElement> {
  static override targets = ["rail", "leftArrow", "rightArrow"];

  declare railTarget: HTMLElement;

  declare leftArrowTarget: HTMLButtonElement;

  declare rightArrowTarget: HTMLButtonElement;

  override connect(): void {
    this.syncArrows();
  }

  scroll(event: {params: {dir: number}}): void {
    const distance = this.railTarget.clientWidth * 0.75 * event.params.dir;
    this.railTarget.scrollBy({behavior: "smooth", left: distance});
  }

  syncArrows(): void {
    const maxScroll = this.railTarget.scrollWidth - this.railTarget.clientWidth;
    const {scrollLeft} = this.railTarget;

    this.leftArrowTarget.hidden = maxScroll <= 0 || scrollLeft <= 1;
    this.rightArrowTarget.hidden =
      maxScroll <= 0 || scrollLeft >= maxScroll - 1;
  }
}
