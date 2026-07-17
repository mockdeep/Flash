const MAX_RESULTS = 5;

const ATOMIC_LATIN_SUBSTITUTIONS = new Map<string, string>([
  ["æ", "ae"],
  ["đ", "d"],
  ["ð", "d"],
  ["ħ", "h"],
  ["ł", "l"],
  ["ø", "oe"],
  ["œ", "oe"],
  ["ß", "ss"],
  ["þ", "th"],
]);

interface Match {
  answer: string;
  remaining: number;
}

function normalize(text: string): string {
  let result = text.
    normalize("NFD").
    replace(/\p{Diacritic}/gu, "").
    toLowerCase();
  for (const [from, to] of ATOMIC_LATIN_SUBSTITUTIONS) {
    result = result.split(from).join(to);
  }

  return result;
}

function findPrefixWord(
  answerWords: string[],
  queryWord: string,
  start: number,
): number {
  for (let index = start; index < answerWords.length; index += 1) {
    if (answerWords[index]?.startsWith(queryWord) === true) { return index; }
  }

  return -1;
}

function hasPrefixMatch(
  answerWords: string[],
  queryWords: string[],
): boolean {
  let start = 0;
  for (const queryWord of queryWords) {
    const index = findPrefixWord(answerWords, queryWord, start);
    if (index === -1) { return false; }
    start = index + 1;
  }

  return true;
}

function totalChars(words: string[]): number {
  return words.reduce((sum, word) => {
    return sum + word.length;
  }, 0);
}

function tryMatch(answer: string, queryWords: string[]): Match | null {
  const answerWords = normalize(answer).split(/\s+/u);
  if (!hasPrefixMatch(answerWords, queryWords)) { return null; }
  const remaining = totalChars(answerWords) - totalChars(queryWords);

  return {answer, remaining};
}

function collectMatches(answers: string[], queryWords: string[]): Match[] {
  const matches: Match[] = [];
  for (const answer of answers) {
    const match = tryMatch(answer, queryWords);
    if (match !== null) { matches.push(match); }
  }

  return matches;
}

export function matchAnswers(answers: string[], rawQuery: string): string[] {
  const query = normalize(rawQuery.trim());
  if (query.length === 0) { return []; }
  const queryWords = query.split(/\s+/u);
  const matches = collectMatches(answers, queryWords);
  matches.sort((left, right) => {
    return left.remaining - right.remaining;
  });

  return matches.slice(0, MAX_RESULTS).map((match) => {
    return match.answer;
  });
}
