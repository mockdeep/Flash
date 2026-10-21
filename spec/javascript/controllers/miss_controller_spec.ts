import type {MockInstance} from "vitest";
import {describe, expect, it, vi} from "vitest";
import {bootStimulus} from "support/stimulus";
import MissController from "controllers/miss_controller";
import {findEl} from "helpers/find_el";

const url = "/decks/7/misses";
const WORD = "reading-snippet__word";

type FetchMock = MockInstance<typeof fetch>;

function stubFetch(): FetchMock {
  return vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response());
}

function buildWord(state: string): HTMLButtonElement {
  const word = document.createElement("button");
  word.type = "button";
  word.setAttribute("data-sense-id", "42");
  word.setAttribute("data-action", "miss#view");
  word.setAttribute("data-miss-sense-id-param", "42");
  word.className = `${WORD} ${WORD}--${state}`;
  word.textContent = "爱";
  return word;
}

function buildRestudy(): HTMLButtonElement {
  const restudy = document.createElement("button");
  restudy.type = "button";
  restudy.className = "restudy";
  restudy.setAttribute("data-action", "miss#restudy");
  restudy.setAttribute("data-miss-sense-id-param", "42");
  restudy.textContent = "Restudy";
  return restudy;
}

function buildLookup(): HTMLDivElement {
  const lookup = document.createElement("div");
  lookup.setAttribute("data-sense-id", "42");
  lookup.className = "reading-snippet__lookup reading-snippet__lookup--done";
  lookup.append(buildRestudy());
  return lookup;
}

function addCsrfToken(): void {
  document.head.replaceChildren();
  const meta = document.createElement("meta");
  meta.name = "csrf-token";
  meta.content = "token-123";
  document.head.appendChild(meta);
}

async function setupDOM(state: string): Promise<FetchMock> {
  const fetchMock = stubFetch();
  addCsrfToken();
  const wrapper = document.createElement("div");
  wrapper.setAttribute("data-controller", "miss");
  wrapper.setAttribute("data-miss-url-value", url);
  wrapper.append(buildWord(state), buildWord(state), buildLookup());
  document.body.replaceChildren(wrapper);
  await bootStimulus("miss", MissController);
  return fetchMock;
}

async function clickRestudy(): Promise<FetchMock> {
  const fetchMock = await setupDOM("done");
  findEl(document, "button", ".restudy").click();
  return fetchMock;
}

async function clickWord(state: string): Promise<FetchMock> {
  const fetchMock = await setupDOM(state);
  findEl(document, "button", `.${WORD}`).click();
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

function wordClasses(): string[][] {
  const words = [...document.querySelectorAll(`.${WORD}`)];
  return words.map((word) => { return [...word.classList]; });
}

describe("restudy", () => {
  it("posts to the url value", async () => {
    const fetchMock = await clickRestudy();

    expect(fetchMock.mock.lastCall?.[0]).toBe(url);
  });

  it("posts the word's sense", async () => {
    const fetchMock = await clickRestudy();

    expect(sentForm(fetchMock).get("sense_id")).toBe("42");
  });

  it("sends the CSRF token", async () => {
    const fetchMock = await clickRestudy();

    expect(request(fetchMock).headers).toMatchObject({
      "X-CSRF-Token": "token-123",
    });
  });

  it("uses POST", async () => {
    const fetchMock = await clickRestudy();

    expect(request(fetchMock).method).toBe("POST");
  });
});

describe("restudy marks the word", () => {
  it("as missed everywhere it shows", async () => {
    await clickRestudy();

    expect(wordClasses()).toStrictEqual([
      [WORD, `${WORD}--missed`],
      [WORD, `${WORD}--missed`],
    ]);
  });

  it("as no longer done in its popover", async () => {
    await clickRestudy();

    const lookup = findEl(document, "div", ".reading-snippet__lookup");

    expect([...lookup.classList]).toStrictEqual(["reading-snippet__lookup"]);
  });
});

describe("view", () => {
  it("posts a new word's sense", async () => {
    const fetchMock = await clickWord("new");

    expect(sentForm(fetchMock).get("sense_id")).toBe("42");
  });

  it("marks a new word as missed everywhere it shows", async () => {
    await clickWord("new");

    expect(wordClasses()).toStrictEqual([
      [WORD, `${WORD}--missed`],
      [WORD, `${WORD}--missed`],
    ]);
  });

  it("posts nothing for a word that has a state", async () => {
    const fetchMock = await clickWord("done");

    expect(fetchMock).not.toHaveBeenCalled();
  });
});
