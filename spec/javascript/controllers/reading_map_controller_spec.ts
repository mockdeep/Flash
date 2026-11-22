import {describe, expect, it} from "vitest";
import {boot, controller, scrolls, zoom} from "support/reading_map_harness";

describe("connect", () => {
  it("opens with the starting node in the middle of the box", async () => {
    await boot();

    const opening = {behavior: "instant", left: 220, top: 180};

    expect(scrolls()).toStrictEqual([opening]);
  });

  it("opens on the middle of a map with no starting node", async () => {
    await boot({start: false});

    const opening = {behavior: "instant", left: 600, top: 300};

    expect(scrolls()).toStrictEqual([opening]);
  });
});

describe("recenter", () => {
  it("scrolls back to the starting node", async () => {
    await boot();

    controller().recenter();

    expect(scrolls().at(-1)).toStrictEqual({
      behavior: "auto",
      left: 220,
      top: 180,
    });
  });
});

describe("zoomIn", () => {
  it("makes the map bigger", async () => {
    await boot();

    controller().zoomIn();

    expect(zoom()).toBe("1.5");
  });

  it("keeps the spot in the middle of the box there", async () => {
    await boot();

    controller().zoomIn();

    expect(scrolls().at(-1)).toStrictEqual({
      behavior: "instant",
      left: 100,
      top: 50,
    });
  });

  it("stops at the biggest size", async () => {
    await boot();

    [1, 2, 3].forEach(() => { controller().zoomIn(); });

    expect(zoom()).toBe("2.25");
  });
});

describe("zoomOut", () => {
  it("makes the map smaller", async () => {
    await boot();

    controller().zoomOut();

    expect(zoom()).toBe("0.75");
  });

  it("stops at the smallest size", async () => {
    await boot();

    [1, 2].forEach(() => { controller().zoomOut(); });

    expect(zoom()).toBe("0.75");
  });
});
