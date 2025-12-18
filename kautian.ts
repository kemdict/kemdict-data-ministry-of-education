import { DatabaseSync } from "node:sqlite";
import { readFileSync } from "node:fs";
import { z } from "zod";

// This schema parses moedict-data-twblg.
const heteronym = z.object({
  id: z.string(),
  trs: z.string(),
  reading: z.optional(z.enum(["替", "白", "文", "俗"])),
  synonyms: z.optional(z.string()),
  antonyms: z.optional(z.string()),
  definitions: z.array(
    z.object({
      // prettier-ignore
      type: z.optional(z.enum([
        "介", "代", "位", "副", "助", "動", "名", "嘆", "形",
        "態", "數", "數量", "時", "熟", "疑", "聲", "連", "量",
      ])),
      def: z.string(),
      example: z.optional(z.array(z.string())),
    }),
  ),
});
const word = z.object({
  title: z.string(),
  radical: z.optional(z.string()),
  stroke_count: z.optional(z.int()),
  non_radical_stroke_count: z.optional(z.int()),
  heteronyms: z.array(heteronym),
});
const obj = JSON.parse(
  readFileSync("../moedict-data-twblg/dict-twblg.json", {
    encoding: "utf-8",
  }),
);
const dictMoedictTwblg = z.array(word).parse(obj);
console.log(dictMoedictTwblg.length);

const my = new DatabaseSync("kautian.db", { readOnly: true });
