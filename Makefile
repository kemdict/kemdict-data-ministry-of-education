# The "--infilter=CSV:44,34,76,1" is necessary to get LibreOffice to
# read the input as UTF-8. ...Bloody hell.
# https://unix.stackexchange.com/a/259434
#
# The numbers are options to the CSV filter.
# The four options are:
# Field separator, String delimiter, Character set, First line number
#   Field Separator is an ASCII character. 44 = ","
#   String delimiter is an ASCII character. 34 = ?\"
#   Character set is basically an ID in a particular table
#     (included in the documentation), and UTF-8 is assigned 76 there.
#
# It's documented here:
# https://wiki.openoffice.org/wiki/Documentation/DevGuide/Spreadsheets/Filter_Options

ifneq (,$(shell command -v libreoffice))
# We add the semicolon so it's possible / simpler to use foreach
convert = libreoffice "--infilter=CSV:44,34,76,1" --convert-to csv --outdir "原始資料" "$(1)";
else ifneq (,$(shell command -v in2csv))
convert = in2csv "$(1)" > "$(basename $(1)).csv"
else
$(error "libreoffice or in2csv (from csvkit) not found")
endif

# hakkadict.json: $(wildcard 原始資料/hakkadict*.ods)
# 	$(foreach ods,$^,$(call convert,$(ods)))
# 	npx csvtojson $(patsubst %.ods,%.csv,$<) --noheader=false --headers='["id","title","pos","index_path","pn","def","example","synonyms","antonyms","audio_file_name"]' > "$@"

# FIXME: we need to merge them into one file. Somehow.
hakkadict.json: $(wildcard 原始資料/hakkadict_四縣腔*.ods)
	$(call convert,$<)
	npx csvtojson $(patsubst %.ods,%.csv,$<) --noheader=false --headers='["id","title","pos","index_path","pn","def","example","synonyms","antonyms","audio_file_name"]' > "$@"

dict_revised.json: $(wildcard 原始資料/dict_revised*.xlsx)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xlsx,%.csv,$<) --noheader=false --headers='["title","alias","length","id","radical","stroke_count","non_radical_stroke_count","het_sort","bopomofo","v_type","v_bopomofo","pinyin","v_pinyin","synonyms","antonyms","definition","het_ref","異體字"]' > "$@"

dict_concised.json: $(wildcard 原始資料/dict_concised*.csv)
	npx csvtojson $(patsubst %.xlsx,%.csv,$<) --noheader=false --headers='["title","id","radical","stroke_count","non_radical_stroke_count","het_sort","bopomofo","v_type","v_bopomofo","pinyin","v_pinyin","synonyms","antonyms","definition","het_ref"]' > "$@"

dict_idioms.json: $(wildcard 原始資料/dict_idioms*.xls)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xls,%.csv,$<) --noheader=false --headers='["id","title","bopomofo","pinyin","definition","source_source","source_content","source_comment","source_reference","典故說明","用法語意說明","用法使用類別","用法例句","書證","辨識同","辨識異","辨識例句","形音辨誤","近義同","近義反","word_ref"]' > "$@"

dict_mini.json: $(wildcard 原始資料/dict_mini*.xlsx)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xlsx,%.csv,$<) --noheader=false --headers='["id","title","radical","stroke_count","non_radical_stroke_count","bopomofo","definition"]' > "$@"

all: dict_revised.json dict_concised.json dict_idioms.json dict_mini.json hakkadict.json
.DEFAULT_GOAL := all
.PHONY: all

update:
	deno run update.ts
