import {describe, expect, it, vi} from "vitest";
import type {FontLoad} from "support/font_harness";
import {
  boot,
  buildCard,
  buildOption,
  controller,
  element,
  eventTargeting,
  option,
  selectEvent,
  STORAGE_KEY,
  stubFonts,
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

describe("a new card connecting", () => {
  it("rerolls the font when mix is chosen", async () => {
    await boot("mix");
    controller().cardTargetConnected(buildCard("1"));
    vi.spyOn(Math, "random").mockReturnValue(0.99);

    controller().cardTargetConnected(buildCard("2"));

    expect(element().dataset.font).toBe("hand");
  });

  it("keeps the font when the same card reconnects", async () => {
    await boot("mix");
    controller().cardTargetConnected(buildCard("1"));
    const asked = element().dataset.font;
    vi.spyOn(Math, "random").mockReturnValue(0.99);

    controller().cardTargetConnected(buildCard("1"));

    expect(element().dataset.font).toBe(asked);
  });

  it("ignores cards without an id", async () => {
    await boot("mix");
    controller().cardTargetConnected(buildCard("1"));
    const asked = element().dataset.font;
    vi.spyOn(Math, "random").mockReturnValue(0.99);

    controller().cardTargetConnected(document.createElement("div"));

    expect(element().dataset.font).toBe(asked);
  });

  it("leaves a fixed font unchanged", async () => {
    await boot("kai");
    vi.spyOn(Math, "random").mockReturnValue(0.99);

    controller().cardTargetConnected(buildCard("2"));

    expect(element().dataset.font).toBe("kai");
  });
});

describe("prewarming", () => {
  it("warms the chosen family with the deck's characters", async () => {
    const fonts = stubFonts();

    await boot("kai", "你好");

    expect(fonts.load).toHaveBeenCalledWith("1em \"LXGW WenKai\"", "你好");
  });

  it("skips warming when no characters are embedded", async () => {
    const fonts = stubFonts();

    await boot("kai");

    expect(fonts.load).not.toHaveBeenCalled();
  });

  it("warms a newly selected family", async () => {
    const fonts = stubFonts();
    await boot("kai", "你");

    controller().setFont(selectEvent("song"));

    expect(fonts.load).toHaveBeenCalledWith("1em \"Noto Serif SC\"", "你");
  });

  it("survives a failed font load", async () => {
    stubFonts({
      load: vi.fn<FontLoad>(async () => {
        return Promise.reject(new Error("offline"));
      }),
    });

    await boot("kai", "你");
    await new Promise((resolve) => { setTimeout(resolve, 0); });

    expect(element().dataset.font).toBe("kai");
  });
});

describe("prewarming under mix", () => {
  it("warms every family", async () => {
    const fonts = stubFonts();

    await boot("mix", "你");

    expect(fonts.load).toHaveBeenCalledTimes(4);
  });

  it("does not warm again when a card rerolls the font", async () => {
    const fonts = stubFonts();
    await boot("mix", "你");

    controller().cardTargetConnected(buildCard("1"));

    expect(fonts.load).toHaveBeenCalledTimes(4);
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
