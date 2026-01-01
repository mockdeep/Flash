import {expect, it} from "@jest/globals";
import "app/javascript/application";

it("disables Turbo", () => {
  expect(Turbo.session.drive).toBe(false);
});
