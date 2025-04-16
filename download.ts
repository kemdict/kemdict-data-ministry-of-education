#!/usr/bin/env deno run

import { $ } from "zx";
import { dicts } from "./versions.ts";

async function download() {
  for (const [dict, { current: version }] of Object.entries(dicts)) {
    const url = `https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/respub/download/${dict}_${version}.zip`;
    const dir = "原始資料";
    await $`curl -L ${url} > ${dir}/${dict}_${version}.zip`;
    await $`cd ${dir} && unzip -o ${dict}_${version}.zip`;
    await $`rm ${dir}/${dict}_${version}.zip`;
  }
}

await download();

console.log("Now go into diff/ and fiddle with it to produce the differences");
