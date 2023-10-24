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
convert = libreoffice "--infilter=CSV:44,34,76,1" --convert-to csv --outdir "原始資料" "$(1)"
else ifneq (,$(shell command -v in2csv))
convert = in2csv "$(1)" > "$(basename $(1)).csv"
else
$(error "libreoffice or in2csv (from csvkit) not found")
endif

hakkadict.json: $(wildcard 原始資料/《臺灣客家語常用詞辭典》*.ods)
	$(call convert,$<)
	npx csvtojson "$(patsubst %.ods,%.csv,$<)" --noheader=false --headers='["id","title","type","category","p_四縣","p_海陸","p_大埔","p_饒平","p_詔安","p_南四縣","definition","synonyms","antonyms","corr_zh","r_大埔","r_p_大埔","r_饒平","r_p_饒平","r_詔安","r_p_詔安","r_南四縣","r_p_南四縣"]' > "$@"

dict_revised.json: $(wildcard 原始資料/dict_revised*.xlsx)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xlsx,%.csv,$<) --noheader=false --headers='["title","alias","length","id","radical","stroke_count","non_radical_stroke_count","het_sort","bopomofo","v_type","v_bopomofo","pinyin","v_pinyin","synonyms","antonyms","definition","het_ref","異體字"]' > "$@"

dict_concised.json: $(wildcard 原始資料/dict_concised*.xlsx)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xlsx,%.csv,$<) --noheader=false --headers='["title","id","radical","stroke_count","non_radical_stroke_count","het_sort","bopomofo","v_type","v_bopomofo","pinyin","v_pinyin","synonyms","antonyms","definition","het_ref"]' > "$@"

# Original header:
# (Something is off here, as the 參考成語(正文) header is duplicated
# but the corresponding content sometimes isn't)
# "編號","成語","參考成語(正文)","注音","漢語拼音","釋義","典源文獻名稱","典源文獻內容","典源-註解","典源-參考","典故說明","用法-語意說明","用法-使用類別","用法-例句","書證","辨識-同","辨識-異","辨識-例句","形音辨誤","近義-同","近義-反","參考成語(正文)"
# Converted header:
# "id","title","word_ref2","bopomofo","pinyin","definition","source_name","source_content","source_comment","source_reference","典故說明","用法語意說明","用法使用類別","用法例句","書證","辨識同","辨識異","辨識例句","形音辨誤","近義同","近義反","word_ref"
dict_idioms.json: $(wildcard 原始資料/dict_idioms*.xls)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xls,%.csv,$<) --noheader=false --headers='["id","title","word_ref2","bopomofo","pinyin","definition","source_name","source_content","source_comment","source_reference","典故說明","用法語意說明","用法使用類別","用法例句","書證","辨識同","辨識異","辨識例句","形音辨誤","近義同","近義反","word_ref"]' > "$@"

dict_mini.json: $(wildcard 原始資料/dict_mini*.xlsx)
	$(call convert,$<)
	npx csvtojson $(patsubst %.xlsx,%.csv,$<) --noheader=false --headers='["id","title","radical","stroke_count","non_radical_stroke_count","bopomofo","definition"]' > "$@"

all: dict_revised.json dict_concised.json dict_idioms.json dict_mini.json hakkadict.json
.DEFAULT_GOAL := all
.PHONY: all
