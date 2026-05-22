import {describe, expect, it} from "vitest";
import {
  boot,
  clickEventOn,
  controller,
  element,
  eventTargeting,
  keyEvent,
  menu,
  openMenu,
  option,
  selectEvent,
  STORAGE_KEY,
  toggle,
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

describe("toggleMenu", () => {
  it("opens a closed menu", async () => {
    await boot();

    openMenu();

    expect(menu().hidden).toBe(false);
  });

  it("sets aria-expanded to true when opening", async () => {
    await boot();

    openMenu();

    expect(toggle().getAttribute("aria-expanded")).toBe("true");
  });

  it("closes an open menu", async () => {
    await boot();
    openMenu();

    controller().toggleMenu(new MouseEvent("click"));

    expect(menu().hidden).toBe(true);
  });

  it("sets aria-expanded to false when closing", async () => {
    await boot();
    openMenu();

    controller().toggleMenu(new MouseEvent("click"));

    expect(toggle().getAttribute("aria-expanded")).toBe("false");
  });
});

describe("setSize from a menu option", () => {
  it("applies the chosen size to the wrapper", async () => {
    await boot();
    openMenu();

    controller().setSize(selectEvent("xl"));

    expect(element().dataset.size).toBe("xl");
  });

  it("persists the chosen size scoped to the deck", async () => {
    await boot();

    controller().setSize(selectEvent("l"));

    expect(localStorage.getItem(STORAGE_KEY)).toBe("l");
  });

  it("closes the menu", async () => {
    await boot();
    openMenu();

    controller().setSize(selectEvent("l"));

    expect(menu().hidden).toBe(true);
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

describe("handleDocClick", () => {
  it("closes when an open menu is clicked outside the wrapper", async () => {
    await boot();
    openMenu();
    const outside = document.createElement("div");
    document.body.appendChild(outside);

    controller().handleDocClick(clickEventOn(outside));

    expect(menu().hidden).toBe(true);
  });

  it("leaves the menu open when the click is inside the wrapper", async () => {
    await boot();
    openMenu();

    controller().handleDocClick(clickEventOn(menu()));

    expect(menu().hidden).toBe(false);
  });

  it("does nothing when the menu is already closed", async () => {
    await boot();
    const outside = document.createElement("div");
    document.body.appendChild(outside);

    controller().handleDocClick(clickEventOn(outside));

    expect(menu().hidden).toBe(true);
  });

  it("ignores clicks whose target is not a DOM node", async () => {
    await boot();
    openMenu();

    controller().handleDocClick(clickEventOn({notANode: true}));

    expect(menu().hidden).toBe(false);
  });
});

describe("handleEsc", () => {
  it("closes an open menu when Escape is pressed", async () => {
    await boot();
    openMenu();

    controller().handleEsc(keyEvent("Escape"));

    expect(menu().hidden).toBe(true);
  });

  it("ignores non-Escape keys", async () => {
    await boot();
    openMenu();

    controller().handleEsc(keyEvent("a"));

    expect(menu().hidden).toBe(false);
  });

  it("does nothing when the menu is already closed", async () => {
    await boot();

    controller().handleEsc(keyEvent("Escape"));

    expect(menu().hidden).toBe(true);
  });
});
