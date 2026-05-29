import {describe, expect, it, vi} from "vitest";
import {bootStimulus} from "support/stimulus";
import TimezoneController from "controllers/timezone_controller";

function buildField(): HTMLInputElement {
  document.body.replaceChildren();

  const field = document.createElement("input");
  field.type = "hidden";
  field.value = "UTC";
  field.setAttribute("data-controller", "timezone");
  document.body.appendChild(field);

  return field;
}

function stubDetectedZone(timeZone: string): void {
  vi.spyOn(Intl.DateTimeFormat.prototype, "resolvedOptions").mockReturnValue({
    calendar: "gregory",
    locale: "en-US",
    numberingSystem: "latn",
    timeZone,
  });
}

describe("connect", () => {
  it("replaces the field value with the detected time zone", async () => {
    stubDetectedZone("America/New_York");
    const field = buildField();

    await bootStimulus("timezone", TimezoneController);

    expect(field.value).toBe("America/New_York");
  });
});
