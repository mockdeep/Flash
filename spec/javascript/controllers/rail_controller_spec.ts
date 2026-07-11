import {describe, expect, it, vi} from "vitest";
import {
  arrows,
  boot,
  controller,
  rail,
  stubRailWidths,
} from "support/rail_harness";

type ScrollByFn = (options: ScrollToOptions) => void;

function scrollSpy(): ReturnType<typeof vi.fn<ScrollByFn>> {
  const spy = vi.fn<ScrollByFn>();
  Object.defineProperty(rail(), "scrollBy", {value: spy});

  return spy;
}

function arrowStates(): boolean[] {
  return arrows().map((arrow) => { return arrow.hidden === true; });
}

describe("scroll", () => {
  it("scrolls the rail by three quarters of its width", async () => {
    await boot();
    stubRailWidths(2000, 800);
    const spy = scrollSpy();

    controller().scroll({params: {dir: 1}});

    expect(spy).toHaveBeenCalledWith({behavior: "smooth", left: 600});
  });

  it("scrolls backwards for the left arrow", async () => {
    await boot();
    stubRailWidths(2000, 800);
    const spy = scrollSpy();

    controller().scroll({params: {dir: -1}});

    expect(spy).toHaveBeenCalledWith({behavior: "smooth", left: -600});
  });
});

describe("syncArrows", () => {
  it("reveals both arrows when scrolled to the middle", async () => {
    await boot();
    stubRailWidths(2000, 800, 600);

    controller().syncArrows();

    expect(arrowStates()).toStrictEqual([false, false]);
  });

  it("hides the left arrow at the start of the rail", async () => {
    await boot();
    stubRailWidths(2000, 800, 0);

    controller().syncArrows();

    expect(arrowStates()).toStrictEqual([true, false]);
  });

  it("hides the right arrow at the end of the rail", async () => {
    await boot();
    stubRailWidths(2000, 800, 1200);

    controller().syncArrows();

    expect(arrowStates()).toStrictEqual([false, true]);
  });

  it("hides the arrows when everything fits", async () => {
    await boot();
    stubRailWidths(800, 800);

    controller().syncArrows();

    expect(arrowStates()).toStrictEqual([true, true]);
  });
});
