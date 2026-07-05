import {describe, expect, it} from "vitest";
import {
  boot,
  clickEventOn,
  controller,
  keyEvent,
  open,
  panel,
  toggle as toggleButton,
} from "support/disclosure_harness";

describe("toggle", () => {
  it("opens a closed panel", async () => {
    await boot();

    open();

    expect(panel().hidden).toBe(false);
  });

  it("sets aria-expanded to true when opening", async () => {
    await boot();

    open();

    expect(toggleButton().getAttribute("aria-expanded")).toBe("true");
  });

  it("closes an open panel", async () => {
    await boot();
    open();

    controller().toggle();

    expect(panel().hidden).toBe(true);
  });

  it("sets aria-expanded to false when closing", async () => {
    await boot();
    open();

    controller().toggle();

    expect(toggleButton().getAttribute("aria-expanded")).toBe("false");
  });
});

describe("close", () => {
  it("closes an open panel", async () => {
    await boot();
    open();

    controller().close();

    expect(panel().hidden).toBe(true);
  });

  it("leaves a closed panel closed", async () => {
    await boot();

    controller().close();

    expect(panel().hidden).toBe(true);
  });
});

describe("handleDocClick", () => {
  it("closes when an open panel is clicked outside the wrapper", async () => {
    await boot();
    open();
    const outside = document.createElement("div");
    document.body.appendChild(outside);

    controller().handleDocClick(clickEventOn(outside));

    expect(panel().hidden).toBe(true);
  });

  it("leaves the panel open when the click is inside the wrapper", async () => {
    await boot();
    open();

    controller().handleDocClick(clickEventOn(panel()));

    expect(panel().hidden).toBe(false);
  });

  it("does nothing when the panel is already closed", async () => {
    await boot();
    const outside = document.createElement("div");
    document.body.appendChild(outside);

    controller().handleDocClick(clickEventOn(outside));

    expect(panel().hidden).toBe(true);
  });

  it("ignores clicks whose target is not a DOM node", async () => {
    await boot();
    open();

    controller().handleDocClick(clickEventOn({notANode: true}));

    expect(panel().hidden).toBe(false);
  });
});

describe("handleEsc", () => {
  it("closes an open panel when Escape is pressed", async () => {
    await boot();
    open();

    controller().handleEsc(keyEvent("Escape"));

    expect(panel().hidden).toBe(true);
  });

  it("ignores non-Escape keys", async () => {
    await boot();
    open();

    controller().handleEsc(keyEvent("a"));

    expect(panel().hidden).toBe(false);
  });

  it("does nothing when the panel is already closed", async () => {
    await boot();

    controller().handleEsc(keyEvent("Escape"));

    expect(panel().hidden).toBe(true);
  });
});
