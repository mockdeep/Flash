import {describe, expect, it} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import MobileNavController from "controllers/mobile_nav_controller";
import {ensure} from "helpers/ensure";

function setupDOM(): void {
  document.body.innerHTML = `
    <div data-controller="mobile-nav">
      <div data-mobile-nav-target="menu"></div>
    </div>
  `;
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("mobile-nav", MobileNavController);
}

function element(): HTMLElement {
  const selector = "[data-controller='mobile-nav']";

  return ensure(document.querySelector<HTMLElement>(selector));
}

function controller(): MobileNavController {
  return getController(element(), "mobile-nav", MobileNavController);
}

function menu(): HTMLElement {
  const selector = "[data-mobile-nav-target='menu']";

  return ensure(document.querySelector<HTMLElement>(selector));
}

describe("toggle", () => {
  it("adds site-nav-open when closed", async () => {
    await setupController();

    controller().toggle();

    expect(menu().classList).toContain("site-nav-open");
  });

  it("removes site-nav-open when open", async () => {
    await setupController();

    controller().toggle();
    controller().toggle();

    expect(menu().classList).not.toContain("site-nav-open");
  });
});

describe("close", () => {
  it("removes site-nav-open", async () => {
    await setupController();
    controller().toggle();

    controller().close();

    expect(menu().classList).not.toContain("site-nav-open");
  });

  it("does nothing when already closed", async () => {
    await setupController();

    controller().close();

    expect(menu().classList).not.toContain("site-nav-open");
  });
});
