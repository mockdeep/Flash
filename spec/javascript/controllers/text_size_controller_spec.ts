import {describe, expect, it} from "vitest";
import {
  boot,
  buildOption,
  controller,
  element,
  eventTargeting,
  option,
  selectEvent,
  STORAGE_KEY,
} from "support/text_size_harness";

describe("connect with empty storage", () => {
  it("applies the medium default to the wrapper", async () => {
    await boot();

    expect(element().dataset.size).toBe("m");
  });

  it("marks the medium option as checked", async () => {
    await boot();

    expect(option("m").getAttribute("aria-checked")).toBe("true");
  });

  it("marks the other options as unchecked", async () => {
    await boot();

    for (const size of ["s", "l", "xl"] as const) {
      expect(option(size).getAttribute("aria-checked")).toBe("false");
    }
  });
});

describe("connect with a stored size", () => {
  it("applies the stored size to the wrapper", async () => {
    await boot("xl");

    expect(element().dataset.size).toBe("xl");
  });

  it("marks the stored option as checked", async () => {
    await boot("l");

    expect(option("l").getAttribute("aria-checked")).toBe("true");
    expect(option("m").getAttribute("aria-checked")).toBe("false");
  });
});

describe("connect with garbage in storage", () => {
  it("falls back to the medium default", async () => {
    localStorage.setItem(STORAGE_KEY, "huge");

    await boot();

    expect(element().dataset.size).toBe("m");
  });
});

describe("setSize from a menu option", () => {
  it("applies the chosen size to the wrapper", async () => {
    await boot();

    controller().setSize(selectEvent("xl"));

    expect(element().dataset.size).toBe("xl");
  });

  it("persists the chosen size scoped to the deck", async () => {
    await boot();

    controller().setSize(selectEvent("l"));

    expect(localStorage.getItem(STORAGE_KEY)).toBe("l");
  });

  it("updates aria-checked on the options", async () => {
    await boot();

    controller().setSize(selectEvent("s"));

    expect(option("s").getAttribute("aria-checked")).toBe("true");
    expect(option("m").getAttribute("aria-checked")).toBe("false");
  });
});

describe("setSize defensive guards", () => {
  it("ignores the event when currentTarget is missing", async () => {
    await boot();

    controller().setSize(new MouseEvent("click"));

    expect(element().dataset.size).toBe("m");
  });

  it("ignores the event when the target has no valid size", async () => {
    await boot();
    const stray = document.createElement("button");
    stray.dataset.size = "huge";

    controller().setSize(eventTargeting("currentTarget", stray));

    expect(element().dataset.size).toBe("m");
  });
});

describe("smaller", () => {
  it("decrements the size one step", async () => {
    await boot("l");

    controller().smaller();

    expect(element().dataset.size).toBe("m");
  });

  it("persists the new size", async () => {
    await boot("l");

    controller().smaller();

    expect(localStorage.getItem(STORAGE_KEY)).toBe("m");
  });

  it("stays at the smallest size when already there", async () => {
    await boot("s");

    controller().smaller();

    expect(element().dataset.size).toBe("s");
  });
});

describe("larger", () => {
  it("increments the size one step", async () => {
    await boot("m");

    controller().larger();

    expect(element().dataset.size).toBe("l");
  });

  it("persists the new size", async () => {
    await boot("m");

    controller().larger();

    expect(localStorage.getItem(STORAGE_KEY)).toBe("l");
  });

  it("stays at the largest size when already there", async () => {
    await boot("xl");

    controller().larger();

    expect(element().dataset.size).toBe("xl");
  });
});

describe("options re-rendered by a frame swap", () => {
  it("syncs the checked state of freshly connected options", async () => {
    await boot("l");
    const fresh = buildOption("l");

    element().appendChild(fresh);
    await Promise.resolve();

    expect(fresh.getAttribute("aria-checked")).toBe("true");
  });

  it("leaves non-matching fresh options unchecked", async () => {
    await boot("l");
    const fresh = buildOption("m");

    element().appendChild(fresh);
    await Promise.resolve();

    expect(fresh.getAttribute("aria-checked")).toBe("false");
  });
});
