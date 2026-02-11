import {expect, it} from "vitest";
import "javascript/application";

it("disables Turbo", () => {
  expect(Turbo.session.drive).toBe(false);
});
