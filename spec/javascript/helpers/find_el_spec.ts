import {describe, expect, it} from "vitest";
import {findEl} from "helpers/find_el";

function setupDOM(): void {
  document.body.innerHTML = `
    <button type="button" class="answer-button">
      <span class="answer-text">Paris</span>
    </button>
  `;
}

describe(findEl, () => {
  it("returns the first element matching the tag and selector", () => {
    setupDOM();
    const button = findEl(document.body, "button", ".answer-button");

    expect(button).toBeInstanceOf(HTMLButtonElement);
  });

  it("finds by tag alone when no selector is given", () => {
    setupDOM();

    expect(findEl(document.body, "span").textContent).toBe("Paris");
  });

  it("throws when nothing matches the selector", () => {
    setupDOM();

    expect(() => {
      findEl(document.body, "button", ".missing");
    }).toThrow("no element matching \"button.missing\"");
  });

  it("throws when the tag does not match", () => {
    setupDOM();

    expect(() => {
      findEl(document.body, "input", ".answer-button");
    }).toThrow("no element matching \"input.answer-button\"");
  });
});
