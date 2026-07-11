import {describe, expect, it, vi} from "vitest";
import {
  activeTab,
  boot,
  controller,
  element,
  items,
  storageKey,
} from "support/filter_harness";

function hiddenStates(): boolean[] {
  return items().map((item) => { return item.hidden === true; });
}

function anyHidden(): boolean {
  return items().some((item) => { return item.hidden === true; });
}

describe("select", () => {
  it("hides items that do not match the chosen value", async () => {
    await boot();

    controller().select({params: {value: "blue"}});

    expect(hiddenStates()).toStrictEqual([true, true, false]);
  });

  it("shows every item when All is chosen", async () => {
    await boot();
    controller().select({params: {value: "blue"}});

    controller().select({params: {value: "All"}});

    expect(anyHidden()).toBe(false);
  });

  it("marks the chosen tab active", async () => {
    await boot();

    controller().select({params: {value: "red"}});

    expect(activeTab()?.dataset.filterValueParam).toBe("red");
  });

  it("persists the chosen value for the key", async () => {
    await boot();

    controller().select({params: {value: "blue"}});

    expect(localStorage.getItem(storageKey())).toBe("blue");
  });

  it("dispatches an applied event", async () => {
    await boot();
    const heard = vi.fn<() => void>();
    element().addEventListener("filter:applied", heard);

    controller().select({params: {value: "blue"}});

    expect(heard).toHaveBeenCalledTimes(1);
  });
});

describe("connect", () => {
  it("restores the stored value", async () => {
    localStorage.setItem(storageKey(), "blue");

    await boot();

    expect(hiddenStates()).toStrictEqual([true, true, false]);
  });

  it("falls back to All when the stored value has no tab", async () => {
    localStorage.setItem(storageKey(), "green");

    await boot();

    expect(anyHidden()).toBe(false);
  });

  it("defaults to All when nothing is stored", async () => {
    await boot();

    expect(activeTab()?.dataset.filterValueParam).toBe("All");
  });

  it("leaves items untouched when there are no tabs", async () => {
    localStorage.setItem(storageKey(), "blue");

    await boot(["red", "red"], {withTabs: false});

    expect(anyHidden()).toBe(false);
  });
});
