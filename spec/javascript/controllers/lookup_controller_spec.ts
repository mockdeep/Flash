import type {MockInstance} from "vitest";
import {describe, expect, it, vi} from "vitest";
import {bootStimulus} from "support/stimulus";
import LookupController from "controllers/lookup_controller";
import {findEl} from "helpers/find_el";

const url = "/decks/7/lookups";

type FetchMock = MockInstance<typeof fetch>;

function stubFetch(): FetchMock {
  return vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response());
}

function buildWord(): HTMLButtonElement {
  const word = document.createElement("button");
  word.type = "button";
  word.setAttribute("data-action", "lookup#record");
  word.setAttribute("data-lookup-sense-id-param", "42");
  word.className = "reading-snippet__word reading-snippet__word--new";
  word.textContent = "爱";
  return word;
}

function setupDOM(): void {
  document.head.replaceChildren();
  const meta = document.createElement("meta");
  meta.name = "csrf-token";
  meta.content = "token-123";
  document.head.appendChild(meta);

  const wrapper = document.createElement("div");
  wrapper.setAttribute("data-controller", "lookup");
  wrapper.setAttribute("data-lookup-url-value", url);
  wrapper.append(buildWord(), buildWord());
  document.body.replaceChildren(wrapper);
}

async function clickWord(): Promise<FetchMock> {
  const fetchMock = stubFetch();
  setupDOM();
  await bootStimulus("lookup", LookupController);

  findEl(document, "button").click();

  return fetchMock;
}

function request(fetchMock: FetchMock): RequestInit {
  const [, init] = fetchMock.mock.lastCall ?? [];
  if (!init) { throw new Error("fetch was not called"); }
  return init;
}

function sentForm(fetchMock: FetchMock): FormData {
  const {body} = request(fetchMock);
  if (!(body instanceof FormData)) { throw new Error("body is not a form"); }
  return body;
}

describe("record", () => {
  it("posts to the url value", async () => {
    const fetchMock = await clickWord();

    expect(fetchMock.mock.lastCall?.[0]).toBe(url);
  });

  it("posts the word's sense", async () => {
    const fetchMock = await clickWord();

    expect(sentForm(fetchMock).get("sense_id")).toBe("42");
  });

  it("sends the CSRF token", async () => {
    const fetchMock = await clickWord();

    expect(request(fetchMock).headers).toMatchObject({
      "X-CSRF-Token": "token-123",
    });
  });

  it("uses POST", async () => {
    const fetchMock = await clickWord();

    expect(request(fetchMock).method).toBe("POST");
  });
});

describe("record marks the word", () => {
  it("as missed everywhere it shows", async () => {
    await clickWord();

    const words = [...document.querySelectorAll("button")];
    const classes = words.map((word) => { return [...word.classList]; });

    expect(classes).toStrictEqual([
      ["reading-snippet__word", "reading-snippet__word--missed"],
      ["reading-snippet__word", "reading-snippet__word--missed"],
    ]);
  });
});
