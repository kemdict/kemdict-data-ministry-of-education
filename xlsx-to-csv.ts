#!/usr/bin/env deno run
import XLSX from "xlsx";
import fs from "node:fs";
import path from "node:path";
import { parseArgs } from "node:util";

const parsedArgs = parseArgs({
  args: process.argv.slice(2),
  allowPositionals: true,
  options: {
    all: { type: "boolean", short: "a" },
    help: { type: "boolean", short: "h" },
  },
});
if (parsedArgs.values.help) {
  console.log(`./xlsx-to-csv.ts <file>

Convert a spreadsheet file to CSV.

Options:
--all, -a: Extract all worksheets, not just the first one
--help, -h: show help (this message)`);
  process.exit(0);
}

const all = parsedArgs.values.all;

const filename = parsedArgs.positionals[0];

if (!filename) {
  console.log("File name is not given");
  process.exit(1);
}
if (!fs.existsSync(filename)) {
  console.log("Specified file does not exist");
  process.exit(1);
}

// port of elisp's file-name-sans-extension minus the version number handling
function noExt(filename: string) {
  const base = path.basename(filename);
  const match = base.match(/\.[^.]*$/);
  if (match && match.index !== 0) {
    const directory = path.dirname(filename);
    const outfilename = base.substring(0, match.index);
    if (directory === ".") {
      return outfilename;
    } else {
      return path.join(directory, outfilename);
    }
  } else {
    return filename;
  }
}

const nameWithoutExt = noExt(filename);
const workbook = XLSX.readFile(filename);

for (const sheetname of workbook.SheetNames) {
  const outfile = all
    ? `${nameWithoutExt}-${sheetname}.csv`
    : `${nameWithoutExt}.csv`;
  console.log(`Exporting ${outfile}...`);
  const worksheet = workbook.Sheets[sheetname]!;
  const csv = XLSX.utils.sheet_to_csv(worksheet);
  fs.writeFileSync(outfile, csv);
  if (!all) break;
}
