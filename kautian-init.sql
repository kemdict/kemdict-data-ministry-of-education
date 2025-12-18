--  -*- sql-product: sqlite; -*-
.mode csv

CREATE TABLE IF NOT EXISTS "詞目" (
    "詞目id" integer primary key,
    "詞目類型" text,
    "漢字" text,
    "羅馬字" text,
    "分類" text,
    "羅馬字音檔檔名" text
);
.import '原始資料/kautian-詞目.csv' 詞目 --skip 1

CREATE TABLE IF NOT EXISTS "義項" (
    "詞目id" integer references 詞目("詞目id"),
    "義項id" integer primary key,
    "詞性" text,
    "解說" text
);
.import '原始資料/kautian-義項.csv' 義項 --skip 1

CREATE TABLE IF NOT EXISTS "例句" (
    "詞目id" integer references 詞目("詞目id"),
    "義項id" integer references 義項("義項id"),
    "例句順序" integer,
    "漢字" text,
    "羅馬字" text,
    "華語" text,
    "音檔檔名" text,
    PRIMARY KEY ("詞目id", "義項id", "例句順序")
);
.import '原始資料/kautian-例句.csv' 例句 --skip 1

CREATE TABLE IF NOT EXISTS "俗唸作" (
    "詞目id" integer references 詞目("詞目id"),
    "漢字" text,
    "羅馬字" text
);
CREATE TABLE IF NOT EXISTS "又唸作" (
    "詞目id" integer references 詞目("詞目id"),
    "漢字" text,
    "羅馬字" text
);
CREATE TABLE IF NOT EXISTS "合音唸作" (
    "詞目id" integer references 詞目("詞目id"),
    "漢字" text,
    "羅馬字" text
);
.import '原始資料/kautian-俗唸作.csv' 俗唸作 --skip 1
.import '原始資料/kautian-又唸作.csv' 又唸作 --skip 1
.import '原始資料/kautian-合音唸作.csv' 合音唸作 --skip 1

CREATE TABLE IF NOT EXISTS "名" (
    "漢字" text,
    "羅馬字" text,
    "建議順序" integer,
    "類型" text
);
.import '原始資料/kautian-名.csv' 名 --skip 1
CREATE TABLE IF NOT EXISTS "姓" (
    "漢字" text,
    "羅馬字" text,
    "建議順序" integer,
    "類型" text
);
.import '原始資料/kautian-姓.csv' 姓 --skip 1

CREATE TABLE IF NOT EXISTS "漢字羅馬字對應" (
    "漢字" text,
    "羅馬字" text,
    "來源" text
);
.import '原始資料/kautian-漢字羅馬字對應.csv' 漢字羅馬字對應 --skip 1

CREATE TABLE IF NOT EXISTS "異用字" (
    "詞目id" integer references 詞目("詞目id"),
    "漢字" text,
    "異用字" text
);
.import '原始資料/kautian-異用字.csv' 異用字 --skip 1

CREATE TABLE IF NOT EXISTS "羅馬字清單" ("羅馬字" text, "來源" text);
.import '原始資料/kautian-羅馬字清單.csv' 羅馬字清單 --skip 1

CREATE TABLE IF NOT EXISTS "義項tuì義項反義" (
    "義項id" integer references 義項("義項id"),
    "詞目漢字" text,
    "解說" text,
    "對應義項id" integer references 義項("義項id"),
    "對應詞目漢字" text,
    "對應解說" text,
    PRIMARY KEY ("義項id", "對應義項id")
);
CREATE TABLE IF NOT EXISTS "義項tuì義項近義" (
    "義項id" integer references 義項("義項id"),
    "詞目漢字" text,
    "解說" text,
    "對應義項id" integer references 義項("義項id"),
    "對應詞目漢字" text,
    "對應解說" text,
    PRIMARY KEY ("義項id", "對應義項id")
);
.import '原始資料/kautian-義項tuì義項反義.csv' 義項tuì義項反義 --skip 1
.import '原始資料/kautian-義項tuì義項近義.csv' 義項tuì義項近義 --skip 1

CREATE TABLE IF NOT EXISTS "義項tuì詞目反義" (
    "義項id" integer references 義項("義項id"),
    "詞目漢字" text,
    "解說" text,
    "對應詞目id" integer references 詞目("詞目id"),
    "對應詞目漢字" text,
    PRIMARY KEY ("義項id", "對應詞目id")
);
CREATE TABLE IF NOT EXISTS "義項tuì詞目近義" (
    "義項id" integer references 義項("義項id"),
    "詞目漢字" text,
    "解說" text,
    "對應詞目id" integer references 詞目("詞目id"),
    "對應詞目漢字" text,
    PRIMARY KEY ("義項id", "對應詞目id")
);

.import '原始資料/kautian-義項tuì詞目反義.csv' 義項tuì詞目反義 --skip 1
.import '原始資料/kautian-義項tuì詞目近義.csv' 義項tuì詞目近義 --skip 1

CREATE TABLE IF NOT EXISTS "詞目tuì詞目反義" (
    "詞目id" integer references 詞目("詞目id"),
    "詞目漢字" text,
    "對應詞目id" integer references 詞目("詞目id"),
    "對應詞目漢字" text
);
CREATE TABLE IF NOT EXISTS "詞目tuì詞目近義" (
    "詞目id" integer references 詞目("詞目id"),
    "詞目漢字" text,
    "對應詞目id" integer references 詞目("詞目id"),
    "對應詞目漢字" text
);
.import '原始資料/kautian-詞目tuì詞目反義.csv' 詞目tuì詞目反義 --skip 1
.import '原始資料/kautian-詞目tuì詞目近義.csv' 詞目tuì詞目近義 --skip 1

CREATE TABLE IF NOT EXISTS "詞彙比較" (
    "華語詞目id" integer, -- this is not unique
    "華語詞目" text,
    "腔" text,
    "漢字" text,
    "羅馬字" text
);
.import '原始資料/kautian-詞彙比較.csv' 詞彙比較 --skip 1

CREATE TABLE IF NOT EXISTS "語音差異" (
    "詞目id" integer references 詞目("詞目id"),
    "漢字" text,
    "鹿港偏泉腔" text,
    "三峽偏泉腔" text,
    "臺北偏泉腔" text,
    "宜蘭偏漳腔" text,
    "臺南混合腔" text,
    "高雄混合腔" text,
    "金門偏泉腔" text,
    "馬公偏泉腔" text,
    "新竹偏泉腔" text,
    "臺中偏漳腔" text
);
.import '原始資料/kautian-語音差異.csv' 語音差異 --skip 1
