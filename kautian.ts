// -*- lsp-disabled-clients: (ts-ls); -*-
import process from "node:process";
import { DatabaseSync } from "node:sqlite";
import { writeFileSync } from "node:fs";
import { z } from "zod";
import { cached } from "@kisaragi-hiu/cached-fetch";
import { DOMParser } from "@b-fuze/deno-dom";

// No idea why these aren't in the ODS. Sorry for relying on scraping.
const categoriesDOM = new DOMParser().parseFromString(
  await cached("kautian-categories", () =>
    fetch("https://sutian.moe.edu.tw/zh-hant/hunlui/", {
      headers: { "User-Agent": "Kemdict (Kisaragi Hiu)" },
    }),
  ),
  "text/html",
);
const categories = Object.fromEntries(
  [...categoriesDOM.querySelectorAll("nav > ul > li > a")]
    .map((elem) => {
      const href = elem.getAttribute("href");
      if (!href || href.startsWith("#")) return;
      const match = href.match(/(\d+)\/$/);
      if (!match) return;
      return [elem.textContent.trim(), parseInt(match[1])] as [string, number];
    })
    .filter((elem) => elem !== undefined),
);

// This schema parses both files from moedict-data-twblg.
// const heteronym = z.object({
//   id: z.string(),
//   trs: z.string(),
//   reading: z.optional(z.enum(["替", "白", "文", "俗"])),
//   synonyms: z.optional(z.string()),
//   antonyms: z.optional(z.string()),
//   definitions: z.array(
//     z.object({
//       // prettier-ignore
//       type: z.optional(z.enum([
//         "介", "代", "位", "副", "助", "動", "名", "嘆", "形",
//         "態", "數", "數量", "時", "熟", "疑", "聲", "連", "量",
//       ])),
//       def: z.string(),
//       example: z.optional(z.array(z.string())),
//     }),
//   ),
// });
// const word = z.object({
//   title: z.string(),
//   radical: z.optional(z.string()),
//   stroke_count: z.optional(z.int().or(z.null())),
//   non_radical_stroke_count: z.optional(z.int().or(z.null())),
//   heteronyms: z.array(heteronym),
// });

const db = new DatabaseSync("kautian.db", { readOnly: true });

/**
 * Reference to a word.
 * Used in Word-to-Word or Het-to-Word synonyms or antonyms.
 */
const inputWordRef = z.object({
  對應詞目id: z.number(),
  對應詞目漢字: z.string(),
});
/** Het-to-Het synonym or antonym */
const inputHHSynoAnto = z.object({
  對應義項id: z.number(),
  對應詞目漢字: z.string(),
  對應解說: z.string(),
});
const inputWord = z.object({
  詞目id: z.number(),
  詞目類型: z.enum([
    "主詞目",
    "單字不成詞者",
    "近反義詞不單列詞目者",
    "臺華共同詞",
    "附錄",
  ]),
  漢字: z.string(),
  羅馬字: z.string(),
  分類: z.string().transform((str) => (str === "" ? [] : str.split(","))),
  羅馬字音檔檔名: z.string(),
});
const inputHet = z.object({
  詞目id: z.number(),
  義項id: z.number(),
  // prettier-ignore
  詞性: z.enum([
    "", "數詞", "形容詞", "副詞", "熟語", "助詞", "時間詞", "名詞",
    "動詞", "代詞", "量詞", "方位詞", "連詞", "介詞", "嘆詞", "擬聲詞",
    "疑問詞", "擬態詞", "助動詞",
  ]).transform((str) => str === "" ? undefined : str),
  解說: z.string(),
});
const inputExample = z.object({
  漢字: z.string(),
  羅馬字: z.string(),
  華語: z.string(),
  音檔檔名: z.string(),
});
interface OutputHet {
  id: number;
  // prettier-ignore
  pos:
    | "數詞" | "形容詞" | "副詞" | "熟語" | "助詞" | "時間詞" | "名詞" | "動詞"
    | "代詞" | "量詞" | "方位詞" | "連詞" | "介詞" | "嘆詞" | "擬聲詞"
    | "疑問詞" | "擬態詞" | "助動詞" | undefined;
  def: string;
  examples?: Array<{
    han: string;
    tl: string;
    zh: string;
  }>;
  hwAntonyms?: Array<{
    desc: string;
    id;
  }>;
  hwSynonyms?: number[];
  hhAntonyms?: number[];
  hhSynonyms?: number[];
}
export interface OutputWord {
  id: number;
  type:
    | "主詞目"
    | "單字不成詞者"
    | "近反義詞不單列詞目者"
    | "臺華共同詞"
    | "附錄";
  han: {
    main: string;
    alt?: string[];
  };
  tl: {
    main: string;
    // 俗唸作
    colloquial?: string[];
    // 又唸作
    alt?: string[];
    // 合音唸作
    otherMerged?: string[];
  };
  categories: Array<{
    id?: number;
    title: string;
  }>;
  wwAntonyms?: Array<{
    id: number;
    han: string;
  }>;
  wwSynonyms?: Array<{
    id: number;
    han: string;
  }>;
  heteronyms?: Array<OutputHet>;
}

/** Remove keys whose values are empty arrays in `obj` to save space. */
function trim<T extends object>(obj: T): T {
  for (const key of Object.keys(obj)) {
    const value = (obj as Record<string, unknown>)[key];
    if (Array.isArray(value) && value.length === 0) {
      delete (obj as Record<string, unknown>)[key];
    }
  }
  return obj;
}

/**
 * Collect elements of `iter` after running `body` on each of them.
 * Think a lazy .map then turning it into an array in the end.
 */
function collect<T, Ret>(iter: IterableIterator<T>, body: (input: T) => Ret) {
  const result: Ret[] = [];
  for (const elem of iter) {
    result.push(body(elem));
  }
  return result;
}

const wordsStmt = db.prepare("select * from 詞目");
const wordAntonymsStmt = db.prepare(`
  select * from "詞目tuì詞目反義" where 詞目id = ?
`);
const wordSynonymsStmt = db.prepare(`
  select * from "詞目tuì詞目近義" where 詞目id = ?
`);
// this is fine-ish because we've have an index for 義項(詞目id)
const hetsStmt = db.prepare("select * from 義項 where 詞目id = ?");
const hwAntonymsStmt = db.prepare(`
  select * from "義項tuì詞目反義" where 義項id = ?
`);
const hwSynonymsStmt = db.prepare(`
  select * from "義項tuì詞目近義" where 義項id = ?
`);
const colloquialStmt = db.prepare("select 羅馬字 from 俗唸作 where 詞目id = ?");
const alternativeStmt = db.prepare(
  "select 羅馬字 from 又唸作 where 詞目id = ?",
);
const otherMergedStmt = db.prepare(
  "select 羅馬字 from 合音唸作 where 詞目id = ?",
);
const alternativeHanStmt = db.prepare(
  "select 異用字 from 異用字 where 詞目id = ?",
);
const examplesStmt = db.prepare(`
  select 漢字, 羅馬字, 華語, 音檔檔名
  from 例句
  where 義項id = ?
  order by 例句順序
`);
const words = collect(wordsStmt.iterate(), (it) => {
  const word = inputWord.parse(it);
  const wordId = word.詞目id;
  const wordSynonyms = collect(wordSynonymsStmt.iterate(wordId), (it) => {
    const synonym = inputWordRef.parse(it);
    return { id: synonym.對應詞目id, han: synonym.對應詞目漢字 };
  });
  const wordAntonyms = collect(wordAntonymsStmt.iterate(wordId), (it) => {
    const antonym = inputWordRef.parse(it);
    return { id: antonym.對應詞目id, han: antonym.對應詞目漢字 };
  });
  const hets = collect(hetsStmt.iterate(wordId), (it) => {
    const het = inputHet.parse(it);
    const hetId = het.義項id;
    const examples = collect(examplesStmt.iterate(hetId), (it) => {
      const example = inputExample.parse(it);
      return {
        han: example.漢字,
        tl: example.羅馬字,
        zh: example.華語,
      };
    });
    const hwAntonyms = collect(hwAntonymsStmt.iterate(hetId), (it) => {
      const antonym = inputWordRef.parse(it);
      return {};
    });
    return trim({
      id: het.義項id,
      def: het.解說,
      pos: het.詞性,
      examples: examples,
    } satisfies OutputHet);
  });
  const colloquial = collect(
    colloquialStmt.iterate(wordId),
    (entry) => entry.羅馬字 as string,
    // this is a convention for denoting multiple alternatives
  ).flatMap((str) => str.split("/"));
  const alternative = collect(
    alternativeStmt.iterate(wordId),
    (entry) => entry.羅馬字 as string,
  ).flatMap((str) => str.split("/"));
  const otherMerged = collect(
    otherMergedStmt.iterate(wordId),
    (entry) => entry.羅馬字 as string,
  ).flatMap((str) => str.split("/"));
  const alternativeHan = collect(
    alternativeHanStmt.iterate(wordId),
    (entry) => entry.異用字 as string,
  );
  return trim({
    id: word.詞目id,
    type: word.詞目類型,
    categories: word.分類.map((category) => ({
      id: categories[category],
      title: category,
    })),
    han: trim({
      main: word.漢字,
      alt: alternativeHan,
    }),
    tl: trim({
      main: word.羅馬字,
      colloquial,
      alt: alternative,
      otherMerged: otherMerged,
    }),
    wwAntonyms: wordAntonyms,
    wwSynonyms: wordSynonyms,
    heteronyms: hets,
  } satisfies OutputWord);
});

if (process.argv[2]) {
  writeFileSync(process.argv[2], JSON.stringify(words, null, 1));
} else {
  // We did everything for nothing at this point, but it's still useful to not
  // error out for the REPL (deno repl --eval-file=<this file>).
  console.log("No output file was passed");
}
