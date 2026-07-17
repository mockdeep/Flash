import {describe, expect, it} from "vitest";
import {matchAnswers} from "helpers/fuzzy_match";

describe("empty queries", () => {
  it("matches nothing when the query is empty", () => {
    expect(matchAnswers(["Paris", "London"], "")).toStrictEqual([]);
  });

  it("matches nothing when the query is only whitespace", () => {
    expect(matchAnswers(["Paris", "London"], "   ")).toStrictEqual([]);
  });
});

describe("matching", () => {
  it("matches answers sharing a prefix with the query", () => {
    expect(matchAnswers(["Paris", "London", "Berlin"], "pa")).
      toStrictEqual(["Paris"]);
  });

  it("orders matches by fewest remaining characters first", () => {
    expect(matchAnswers(["caterpillar", "cat", "candy"], "ca")).
      toStrictEqual(["cat", "candy", "caterpillar"]);
  });

  it("counts unmatched words toward remaining characters", () => {
    const answers = [
      "to live in an apartment",
      "to live in a house",
      "to live",
    ];

    expect(matchAnswers(answers, "to live")).toStrictEqual([
      "to live",
      "to live in a house",
      "to live in an apartment",
    ]);
  });

  it("matches against any word in a phrase", () => {
    expect(matchAnswers(["the quick brown fox", "lazy dog"], "qu")).
      toStrictEqual(["the quick brown fox"]);
  });

  it("caps results at five entries", () => {
    const answers = ["aa", "ab", "ac", "ad", "ae", "af", "ag"];

    expect(matchAnswers(answers, "a")).toHaveLength(5);
  });
});

describe("multi-word matching", () => {
  it("matches adjacent words when the query has whitespace", () => {
    expect(matchAnswers(["last name", "first name", "lastly"], "last name")).
      toStrictEqual(["last name"]);
  });

  it("matches word prefixes inside a phrase", () => {
    const answers = ["the quick brown fox", "quick fox", "brown bear"];

    expect(matchAnswers(answers, "qu br")).
      toStrictEqual(["the quick brown fox"]);
  });

  it("matches word prefixes separated by other words", () => {
    expect(matchAnswers(["to have a beard", "to be happy"], "ha be")).
      toStrictEqual(["to have a beard"]);
  });
});

describe("multi-word edge cases", () => {
  it("does not match when query words are out of order", () => {
    expect(matchAnswers(["the quick brown fox"], "br qu")).toStrictEqual([]);
  });

  it("collapses internal whitespace when splitting the query", () => {
    expect(matchAnswers(["last name"], "last   name")).
      toStrictEqual(["last name"]);
  });

  it("does not match when the answer is shorter than the query", () => {
    expect(matchAnswers(["short"], "short answer")).toStrictEqual([]);
  });
});

describe("normalization", () => {
  it("matches case-insensitively", () => {
    expect(matchAnswers(["Paris"], "PAR")).toStrictEqual(["Paris"]);
  });

  it("matches accent-insensitively", () => {
    expect(matchAnswers(["café", "carrot"], "caf")).toStrictEqual(["café"]);
  });

  it("treats typed accents as base letters", () => {
    expect(matchAnswers(["café"], "café")).toStrictEqual(["café"]);
  });
});

describe("atomic Latin substitution", () => {
  it.each([
    ["Straße", "strasse"],
    ["Þór", "thor"],
    ["nære", "naere"],
    ["øl", "oel"],
    ["sœur", "soeur"],
    ["eðli", "edli"],
    ["đak", "dak"],
    ["łódź", "lodz"],
    ["ħamiem", "hamiem"],
  ])("matches %s when typing %s", (answer, query) => {
    expect(matchAnswers([answer], query)).toStrictEqual([answer]);
  });

  it.each([
    "Straße",
    "Þór",
    "nære",
    "øl",
    "sœur",
    "eðli",
    "đak",
    "łódź",
    "ħamiem",
  ])("matches %s when typing it directly", (answer) => {
    expect(matchAnswers([answer], answer)).toStrictEqual([answer]);
  });
});
