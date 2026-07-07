import {describe, expect, it, vi} from "vitest";
import {
  boot,
  buildOption,
  controller,
  element,
  eventTargeting,
  option,
  selectEvent,
  STORAGE_KEY,
} from "support/font_harness";

describe("connect with empty storage", () => {
  it("applies the hei default to the frame", async () => {
    await boot();

    expect(element().dataset.font).toBe("hei");
  });

  it("marks the hei option as checked", async () => {
    await boot();

    expect(option("hei").getAttribute("aria-checked")).toBe("true");
  });

  it("marks the other options as unchecked", async () => {
    await boot();

    for (const choice of ["song", "kai", "hand", "mix"] as const) {
      expect(option(choice).getAttribute("aria-checked")).toBe("false");
    }
  });
});

describe("connect with a stored font", () => {
  it("applies the stored font to the frame", async () => {
    await boot("kai");

    expect(element().dataset.font).toBe("kai");
  });

  it("marks the stored option as checked", async () => {
    await boot("song");

    expect(option("song").getAttribute("aria-checked")).toBe("true");
    expect(option("hei").getAttribute("aria-checked")).toBe("false");
  });
});

describe("connect with garbage in storage", () => {
  it("falls back to the hei default", async () => {
    localStorage.setItem(STORAGE_KEY, "wingdings");

    await boot();

    expect(element().dataset.font).toBe("hei");
  });
});

describe("connect with mix stored", () => {
  it("applies one of the concrete fonts to the frame", async () => {
    await boot("mix");

    expect(["hei", "song", "kai", "hand"]).toContain(element().dataset.font);
  });

  it("marks the mix option as checked", async () => {
    await boot("mix");

    expect(option("mix").getAttribute("aria-checked")).toBe("true");
  });
});

describe("setFont from a menu option", () => {
  it("applies the chosen font to the frame", async () => {
    await boot();

    controller().setFont(selectEvent("kai"));

    expect(element().dataset.font).toBe("kai");
  });

  it("persists the chosen font scoped to the deck", async () => {
    await boot();

    controller().setFont(selectEvent("song"));

    expect(localStorage.getItem(STORAGE_KEY)).toBe("song");
  });

  it("updates aria-checked on the options", async () => {
    await boot();

    controller().setFont(selectEvent("hand"));

    expect(option("hand").getAttribute("aria-checked")).toBe("true");
    expect(option("hei").getAttribute("aria-checked")).toBe("false");
  });

  it("persists mix rather than the rolled font", async () => {
    await boot();

    controller().setFont(selectEvent("mix"));

    expect(localStorage.getItem(STORAGE_KEY)).toBe("mix");
  });
});

describe("setFont defensive guards", () => {
  it("ignores the event when currentTarget is missing", async () => {
    await boot();

    controller().setFont(new MouseEvent("click"));

    expect(element().dataset.font).toBe("hei");
  });

  it("ignores the event when the target has no valid font", async () => {
    await boot();
    const stray = document.createElement("button");
    stray.dataset.font = "wingdings";

    controller().setFont(eventTargeting("currentTarget", stray));

    expect(element().dataset.font).toBe("hei");
  });
});

describe("reroll", () => {
  it("picks a new font when mix is chosen", async () => {
    await boot("mix");
    vi.spyOn(Math, "random").mockReturnValue(0.99);

    controller().reroll();

    expect(element().dataset.font).toBe("hand");
  });

  it("leaves a fixed font unchanged", async () => {
    await boot("kai");
    vi.spyOn(Math, "random").mockReturnValue(0.99);

    controller().reroll();

    expect(element().dataset.font).toBe("kai");
  });
});

describe("options re-rendered by a frame swap", () => {
  it("syncs the checked state of freshly connected options", async () => {
    await boot("kai");
    const fresh = buildOption("kai");

    element().appendChild(fresh);
    await Promise.resolve();

    expect(fresh.getAttribute("aria-checked")).toBe("true");
  });

  it("checks the mix option itself, not the rolled font", async () => {
    await boot("mix");
    const freshMix = buildOption("mix");

    element().appendChild(freshMix);
    await Promise.resolve();

    expect(freshMix.getAttribute("aria-checked")).toBe("true");
  });
});
