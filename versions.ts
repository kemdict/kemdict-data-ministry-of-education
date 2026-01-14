// Dictionaries from Ministry of Education, plus their current versions and
// previous versions.
//
// Previous versions are used by the diff generation process, "parsing" this
// file with Emacs Lisp, so:
// - the newlines here are sensitive: each dict should be in one line.
// - the variable name/type is also sensitive. It has to be "const dicts".
// - the order is sensitive: current must come before previous
//
// This ridiculous requirement would be relaxed if the diff generation process
// gets rewritten in JS at some point.
// prettier-ignore
export const dicts = {
  dict_concised: { current: "2014_20251229", previous: "2014_20250326" },
  dict_idioms:   { current: "2020_20251224", previous: "2020_20250324" },
  dict_mini:     { current: "2019_20251229", previous: "2019_20250328" },
  dict_revised:  { current: "2015_20251229", previous: "2015_20250327" },
} satisfies Record<string, { current: string, previous: string }>;
