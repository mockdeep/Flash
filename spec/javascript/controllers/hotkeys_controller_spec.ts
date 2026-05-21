import {bootStimulus, getController} from "support/stimulus";
import HotkeysController from "controllers/hotkeys_controller";
import {assert} from "helpers/assert";

function setupDOM(): void {
  document.body.innerHTML = `
    <div data-controller="hotkeys">
      <button data-hotkeys-target="click" data-hotkey="a">A</button>
    </div>
  `;
}

function setupSpaceDOM(): void {
  document.body.innerHTML = `
    <div data-controller="hotkeys">
      <button data-hotkeys-target="click" data-hotkey=" ">Space</button>
    </div>
  `;
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("hotkeys", HotkeysController);
}

function element(): HTMLElement {
  const selector = "[data-controller='hotkeys']";

  return assert(document.querySelector<HTMLElement>(selector));
}

function controller(): HotkeysController {
  return getController(element(), "hotkeys", HotkeysController);
}

function button(): HTMLButtonElement {
  const selector = "button[data-hotkeys-target='click']";

  return assert(document.querySelector<HTMLButtonElement>(selector));
}

function appendOpenDialog(): HTMLDialogElement {
  const dialog = document.createElement("dialog");
  dialog.setAttribute("open", "");
  document.body.appendChild(dialog);

  return dialog;
}

describe("clickTargetConnected", () => {
  it("indexes the connected click target by its hotkey", async () => {
    await setupController();

    expect(controller().indexedClickTargets.get("a")).toBe(button());
  });
});

describe("clickTargetDisconnected", () => {
  it("removes the disconnected click target from the index", async () => {
    await setupController();

    button().remove();

    await Promise.resolve();

    expect(controller().indexedClickTargets.get("a")).toBeUndefined();
  });
});

it("clicks the target for the pressed key", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");

  controller().handleKeydown(new KeyboardEvent("keydown", {key: "a"}));

  expect(clickSpy).toHaveBeenCalledWith();
});

it("does nothing if there is no target for the pressed key", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");

  controller().handleKeydown(new KeyboardEvent("keydown", {key: "b"}));

  expect(clickSpy).not.toHaveBeenCalled();
});

it("clicks the space target when Enter is pressed", async () => {
  setupSpaceDOM();
  await bootStimulus("hotkeys", HotkeysController);
  const clickSpy = vi.spyOn(button(), "click");
  const ctrl = getController(element(), "hotkeys", HotkeysController);

  ctrl.handleKeydown(new KeyboardEvent("keydown", {key: "Enter"}));

  expect(clickSpy).toHaveBeenCalledWith();
});

it("ignores keypresses originating from <input> elements", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");
  const field = document.createElement("input");
  element().appendChild(field);
  const event = new KeyboardEvent("keydown", {bubbles: true, key: "a"});
  Object.defineProperty(event, "target", {value: field});

  controller().handleKeydown(event);

  expect(clickSpy).not.toHaveBeenCalled();
});

it("ignores keypresses originating from <textarea> elements", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");
  const field = document.createElement("textarea");
  element().appendChild(field);
  const event = new KeyboardEvent("keydown", {bubbles: true, key: "a"});
  Object.defineProperty(event, "target", {value: field});

  controller().handleKeydown(event);

  expect(clickSpy).not.toHaveBeenCalled();
});

it("ignores keypresses originating from <select> elements", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");
  const field = document.createElement("select");
  element().appendChild(field);
  const event = new KeyboardEvent("keydown", {bubbles: true, key: "a"});
  Object.defineProperty(event, "target", {value: field});

  controller().handleKeydown(event);

  expect(clickSpy).not.toHaveBeenCalled();
});

it("ignores hotkeys for elements outside an open dialog", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");
  appendOpenDialog();

  controller().handleKeydown(new KeyboardEvent("keydown", {key: "a"}));

  expect(clickSpy).not.toHaveBeenCalled();
});

it("allows hotkeys for elements inside an open dialog", async () => {
  await setupController();
  const dialog = appendOpenDialog();
  const dialogButton = document.createElement("button");
  Object.assign(dialogButton.dataset, {hotkey: "b", hotkeysTarget: "click"});
  dialog.appendChild(dialogButton);
  controller().clickTargetConnected(dialogButton);
  const clickSpy = vi.spyOn(dialogButton, "click");

  controller().handleKeydown(new KeyboardEvent("keydown", {key: "b"}));

  expect(clickSpy).toHaveBeenCalledWith();
});

function setHotkey(hotkey: string): void {
  controller().clickTargetDisconnected(button());
  button().dataset.hotkey = hotkey;
  controller().clickTargetConnected(button());
}

describe("ctrl-modified hotkeys", () => {
  it("clicks the target on Ctrl+key", async () => {
    await setupController();
    setHotkey("ctrl+Enter");
    const clickSpy = vi.spyOn(button(), "click");
    const event = new KeyboardEvent("keydown", {ctrlKey: true, key: "Enter"});

    controller().handleKeydown(event);

    expect(clickSpy).toHaveBeenCalledWith();
  });

  it("clicks the target on Cmd+key (metaKey)", async () => {
    await setupController();
    setHotkey("ctrl+Enter");
    const clickSpy = vi.spyOn(button(), "click");
    const event = new KeyboardEvent("keydown", {key: "Enter", metaKey: true});

    controller().handleKeydown(event);

    expect(clickSpy).toHaveBeenCalledWith();
  });

  it("does not click the target without modifier", async () => {
    await setupController();
    setHotkey("ctrl+Enter");
    const clickSpy = vi.spyOn(button(), "click");
    const event = new KeyboardEvent("keydown", {key: "Enter"});

    controller().handleKeydown(event);

    expect(clickSpy).not.toHaveBeenCalled();
  });
});

it("ctrl-modified hotkeys work from form fields", async () => {
  await setupController();
  setHotkey("ctrl+Enter");
  const clickSpy = vi.spyOn(button(), "click");
  const field = document.createElement("textarea");
  element().appendChild(field);
  const event = new KeyboardEvent("keydown", {ctrlKey: true, key: "Enter"});
  Object.defineProperty(event, "target", {value: field});

  controller().handleKeydown(event);

  expect(clickSpy).toHaveBeenCalledWith();
});

it("does not fire regular hotkeys when ctrl is held", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");
  const event = new KeyboardEvent("keydown", {ctrlKey: true, key: "a"});

  controller().handleKeydown(event);

  expect(clickSpy).not.toHaveBeenCalled();
});

it("does not fire regular hotkeys when alt is held", async () => {
  await setupController();
  const clickSpy = vi.spyOn(button(), "click");
  const event = new KeyboardEvent("keydown", {altKey: true, key: "a"});

  controller().handleKeydown(event);

  expect(clickSpy).not.toHaveBeenCalled();
});

it("does not fire ctrl-modified hotkeys when alt is also held", async () => {
  await setupController();
  setHotkey("ctrl+Enter");
  const clickSpy = vi.spyOn(button(), "click");
  const event = new KeyboardEvent("keydown", {
    altKey: true,
    ctrlKey: true,
    key: "Enter",
  });

  controller().handleKeydown(event);

  expect(clickSpy).not.toHaveBeenCalled();
});
