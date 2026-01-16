# kemdict-data-ministry-of-education

教育部一些辭典處理成 JSON 格式的結果。

（華語：重編國語辭典修訂本、國語辭典簡編本、成語典、國語小字典；客語：臺灣客家語常用詞辭典（尚需更新）、學科術語對譯查詢（客語）；台語：臺灣台語常用詞辭典、學科術語對譯查詢（台語））

各個詞的 key 有改（一方面單字統一用 `title`，另一方面省空間），除此之外內容沒有再動。

這不像 [moedict-data](https://github.com/g0v/moedict-data) 一樣有再經過將各個定義分開來等等的分析，但好處是這樣比較好更新。

- `dict_revised`: 重編國語辭典修訂本
- `dict_concised`: 國語辭典簡編本
- `dict_idioms`: 成語典
- `dict_mini`: 國語小字典
- `hakkadict`: 臺灣客家語常用詞辭典
- `kautian`: 臺灣台語常用詞辭典
- `stti-taigi`: 學科術語對譯查詢（台語）
- `stti-hakka`: 學科術語對譯查詢（客語）

原始資料在`./原始資料`這個資料夾下，這些 JSON 檔案是以下流程生成的檔案。

## Updating

- 更新 versions.ts，填入新的版本號碼（舊的版本號碼移到 previous）
- 自動化下載：`npx tsx download.ts`
- 或是手動下載：
  - 從[教育部國語辭典公眾授權網](https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/respub/index.html)閱讀使用說明及授權後下載原始檔案（`.xlsx` 或 `.xls`），放在`原始資料/`這個資料夾裡。
  - 《臺灣客語辭典》要到[資料釋出](https://hakkadict.moe.edu.tw/resource_download/)下載，類似這樣

    ```sh
    date=20240515
    for variant in 四縣腔 海陸腔 大埔腔 饒平腔 詔安腔 南四縣腔; do
        curl https://hakkadict.moe.edu.tw/static/resource/客語資源下載/本辭典的文字/"$variant"詞條詞目文字.ods \
            > hakkadict_"$variant"_"$date".ods
    done
    ```

    - 
  - 《教育部臺灣台語常用詞辭典》[資料釋出](https://sutian.moe.edu.tw/zh-hant/siongkuantsuguan/#hid2)
  - STTI (台語): https://stti.moe.edu.tw/file-download/newsData/?lang=sutgi
  - STTI (客語): https://stti.moe.edu.tw/sudngi/file-download/societyData/?lang=sudngi
- 安裝 Node、npm、LibreOffice
- `npm install` (for `csvtojson`)
- 到 `./原始資料`，檢查後把舊的檔案刪掉
- 然後 `make all`

如果格式沒有變的話就會產生各個辭典對應的 JSON 檔案。

- `make diff` (make sure the working copy has the new files and HEAD has the old files)

這樣會產生前後的差異比對結果。Now make a commit and push.

## License

辭典本文的著作權為中華民國教育部所有。完整授權說明的複本置於 [license](./license) 資料夾下。

（臺灣客家語常用詞辭典沒有額外的授權說明，但是[還是以創用CC「姓名標示─禁止改作」3.0臺灣授權條款釋出的](https://hakkadict.moe.edu.tw/cgi-bin/gs32/gsweb.cgi/ccd=ChLpKc/description?id=MSA00000041&opt=opt2)。）

轉換用程式碼與編輯的著作權（如果有的話）由如月飛羽 (Kisaragi Hiu) 以 [CC0](https://creativecommons.org/publicdomain/zero/1.0/legalcode) 釋出。

- 中華民國教育部（Ministry of Education, R.O.C.）。《重編國語辭典修訂本》網址：http://dict.revised.moe.edu.tw/
- 中華民國教育部（Ministry of Education, R.O.C.）。《國語辭典簡編本》網址：http://dict.concised.moe.edu.tw/
- 中華民國教育部（Ministry of Education, R.O.C.）。《成語典》網址：http://dict.idioms.moe.edu.tw/
- 中華民國教育部（Ministry of Education, R.O.C.）。《國語小字典》網址：http://dict.mini.moe.edu.tw
- 中華民國教育部（Ministry of Education, R.O.C.）。《臺灣客語辭典》（取用於 2024 年 5 月 15 日）網址：https://hakkadict.moe.edu.tw
- 中華民國教育部（Ministry of Education, R.O.C.）。《臺灣台語常用詞辭典》（取用於 2025 年 12 月 19 日）網址：https://sutian.moe.edu.tw
- 中華民國教育部（Ministry of Education, R.O.C.）。《學科術語臺灣台語/臺灣客語對譯查詢》（版本：20241219）網址：https://stti.moe.edu.tw

```
《重編國語辭典修訂本》
企劃執行：國家教育研究院
原 著 者：教育部國語推行委員會
（民國102年1月1日配合行政院組改併入相關單位）
發 行 人：潘文忠　林崇熙
發 行 所：中華民國教育部
維護單位：國家教育研究院語文教育及編譯研究中心
地　　址：臺北市大安區和平東路一段179號
電　　話：(02)7740-7282
傳　　真：(02)7740-7284
電子郵件：onile@mail.naer.edu.tw
版　　次：中華民國110年11月臺灣學術網路第六版

教育部《國語辭典簡編本》
維護管理：國家教育研究院
原 著 者：教育部國語推行委員會
(民國102年1月1日配合行政院組改併入相關單位)
修 訂 者：國家教育研究院
發 行 人：潘文忠、林崇熙
發 行 所：中華民國教育部
維護單位：國家教育研究院語文教育及編譯研究中心
地　　址：新北市三峽區三樹路2號
電　　話：(02)7740-7282
傳　　真：(02)7740-7284
電子郵件：onile@mail.naer.edu.tw
版　  次：中華民國110年11月臺灣學術網路第三版

教育部《成語典》
編　　輯　　者　國家教育研究院語文教育及編譯研究中心
原　　著　　者　教育部國語推行委員會
（民國102年1月1日配合行政院組改併入相關單位）
發　　行　　人　潘文忠 許添明
發　　行　　所　教育部
維　護　單　位　國家教育研究院
總 院 區 地 址  23703新北市三峽區三樹路2號
電　　　　　話　(02)7740-7282
電　子　郵　件　onile@mail.naer.edu.tw

國語小字典
規劃執行	國家教育研究院
原 著 者	教育部國語推行委員會(民國102年1月1日配合行政院組改併入相關單位)
發 行 人	潘文忠、許添明
發 行 所	教育部
維護單位	國家教育研究院語文教育及編譯研究中心
地　　址	新北市三峽區三樹路2號
電　　話	(02)7740-7282
傳　　真	(02)7740-7284
```

## Key 的對應

JSON 的 key / Excel 的標頭有修改，這樣我在 [kemdict](https://github.com/kisaragi-hiu/kemdict) 整合的時候比較容易，同時也節省空間：因為 JSON 每一個項目都會重複每一個 key，一個 key 少一個位元組，一個大概 80000 項的檔案就會少 80000 個位元組。

有些 key 跟萌典相通：`title`、`stroke_count`、`non_radical_stroke_count`、`bopomofo`、`pinyin`，但沒有萌典的 heteronyms。

### `dict_revised.json`

| Original                           | Here                       |
|------------------------------------|----------------------------|
| 字詞名                             | title                      |
| 辭條別名                           | alias                      |
| 字數                               | length                     |
| 字詞號                             | id                         |
| 部首字                             | radical                    |
| 總筆畫數                           | `stroke_count`             |
| 部首外筆畫數                       | `non_radical_stroke_count` |
| 多音排序                           | `het_sort`                 |
| 注音一式                           | bopomofo                   |
| 變體類型 1:變 2:又音 3:語音 4:讀音 | `v_type`                   |
| 變體注音                           | `v_bopomofo`               |
| 漢語拼音                           | pinyin                     |
| 變體漢語拼音                       | v_pinyin                   |
| 相似詞                             | synonyms                   |
| 相反詞                             | antonyms                   |
| 釋義                               | definition                 |
| 多音參見訊息                       | `het_ref`                  |
| 異體字                             | 異體字                     |

### `dict_concised.json`

| Original                           | Here                       | Notes |
|------------------------------------|----------------------------|-------|
| 字詞名                             | title                      |       |
| 字詞號                             | id                         |       |
| 部首字                             | radical                    |       |
| 總筆畫數                           | `stroke_count`             |       |
| 部首外筆畫數                       | `non_radical_stroke_count` |       |
| 多音排序                           | `het_sort`                 |       |
| 注音一式                           | bopomofo                   |       |
| 變體類型 1:變 2:又音 3:語音 4:讀音 | `v_type`                   |       |
| 變體注音                           | `v_bopomofo`               |       |
| 漢語拼音                           | pinyin                     |       |
| 變體漢語拼音                       | `v_pinyin`                 |       |
| 相似詞                             | synonyms                   |       |
| 相反詞                             | antonyms                   |       |
| 釋義                               | definition                 |       |
| 多音參見訊息                       | `het_ref`                  |       |

### `dict_idioms.json`

| Original       | Here               |
|----------------|--------------------|
| 編號           | id                 |
| 成語           | title              |
| 注音           | bopomofo           |
| 漢語拼音       | pinyin             |
| 釋義           | definition         |
| 典源文獻出處   | `source_source`      |
| 典源文獻內容   | `source_content`   |
| 典源-註解      | `source_comment`   |
| 典源-參考      | `source_reference` |
| 典故說明       | 典故說明           |
| 用法-語意說明  | 用法語意說明       |
| 用法-使用類別  | 用法使用類別       |
| 用法-例句      | 用法例句           |
| x書證           | 書證               |
| 辨識-同        | 辨識同             |
| 辨識-異        | 辨識異             |
| 辨識-例句      | 辨識例句           |
| 形音辨誤       | 形音辨誤           |
| 近義成語        | 近義同             |
| 反義成語        | 近義反             |
| 參考成語(正文) | `word_ref`     |
| 主條目/非主條目 | `is_main` |

### `dict_mini.json`

| Original   | Here                       |
|------------|----------------------------|
| 單字       | title                      |
| 部首       | radical                    |
| 單字筆畫   | `stroke_count`             |
| 部首外筆畫 | `non_radical_stroke_count` |
| 注音       | bopomofo                   |
| 解釋       | definition                 |

### `hakkadict.json`

| Original     | Here            | Notes          |
|--------------|-----------------|----------------|
| 序號         | id              |                |
| 詞目         | title           |                |
| 詞性         | pos             | part of speech |
| 詞目索引     | index_path      |                |
| 音讀         | pn   | pronunciation                |
| 釋義         | def      | definition                |
| 例句         | example         |                |
| 相似詞       | synonyms        |                |
| 相反詞       | antonyms        |                |
| 對應音檔名稱 | audio_file_name |                |

### `stti-taigi.json`

| Original     | Here | Notes                         |
|--------------+------+-------------------------------|
| 序號         | id   |                               |
| 學科術語     | zh   |                               |
| 參考解釋     | def  |                               |
| 第1階段      |      | I'll be dropping these, sorry |
| 第2階段      |      |                               |
| 第3階段      |      |                               |
| 第4階段      |      |                               |
| 第5階段      |      |                               |
| 臺灣台語詞彙 | han  |                               |
| 臺羅         | tl   |                               |

Note that .han and .tl are newline-delimited lists that encode a mapping.

### `stti-hakka.json`

| Original             | Here                 | Notes |
|----------------------+----------------------+-------|
| 序號                 | id                   |       |
| 學科術語             | zh                   |       |
| 參考解釋             | def                  |       |
| 第1階段              |                      |       |
| 第2階段              |                      |       |
| 第3階段              |                      |       |
| 第4階段              |                      |       |
| 第5階段              |                      |       |
| 四縣詞彙             | 四縣詞彙             | The newlines are removed.  |
| 四縣音讀             | 四縣音讀             |       |
| 南四縣詞彙           | 南四縣詞彙           |       |
| 南四縣音讀           | 南四縣音讀           |       |
| 海陸詞彙             | 海陸詞彙             |       |
| 海陸音讀             | 海陸音讀             |       |
| 大埔詞彙             | 大埔詞彙             |       |
| 大埔音讀             | 大埔音讀             |       |
| 饒平詞彙             | 饒平詞彙             |       |
| 饒平音讀             | 饒平音讀             |       |
| 饒平腔備註詞彙(卓蘭) | 饒平腔備註詞彙(卓蘭) |       |
| 饒平腔備註音讀(卓蘭) | 饒平腔備註音讀(卓蘭) |       |
| 詔安詞彙             | 詔安詞彙             |       |
| 詔安音讀             | 詔安音讀             |       |

## Kautian

因為《臺灣台語常用詞辭典》的資料釋出格式是一整個 relational database 的格式，因此我發現像萌典一樣的做成有層級的會比較容易。

資料表清單與目前已整合的部分：

- [X] 詞目
- [X] 義項
- [X] 例句
- [X] 俗唸作
- [X] 又唸作
- [X] 合音唸作
- [ ] 名
- [ ] 姓
- [ ] 漢字羅馬字對應
- [X] 異用字
- [ ] 羅馬字清單
- [X] 義項tuì義項反義
- [X] 義項tuì義項近義
- [X] 義項tuì詞目反義
- [X] 義項tuì詞目近義
- [X] 詞目tuì詞目反義
- [X] 詞目tuì詞目近義
- [ ] 詞彙比較
- [X] 語音差異

Schema:

kautian.json 是 `Array<OutputWord>`。

```typescript
// 詞目
interface OutputWord {
  // 詞目id
  id: number;
  // 詞目類型
  type: "主詞目" | "單字不成詞者" | "近反義詞不單列詞目者" | "臺華共同詞" | "附錄";
  // 漢字...
  han: {
    // 「主要」漢字
    main: string;
    // 異用字
    alt?: string[];
  };
  // 羅馬字...
  tl: {
    // 「主要」羅馬字
    main: string;
    // 俗唸作
    colloquial?: string[];
    // 又唸作
    alt?: string[];
    // 合音唸作
    otherMerged?: string[];
    // 語音差異，像是 {"臺中偏漳腔": ["ji̍t","gi̍t"]}
    dialects?: Record<string, string[]>;
  };
  // 分類
  categories: Array<{
    // 分類在教典上的id
    id?: number;
    // 分類名稱
    title: string;
  }>;
  // 詞目對詞目反義
  wwAntonyms?: Array<{
    id: number; // 對應詞目id
    han: string; // 對應詞目漢字
  }>;
  // 詞目對詞目近義
  wwSynonyms?: Array<{
    id: number; // 對應詞目id
    han: string; // 對應詞目漢字
  }>;
  // 詞目的義項
  heteronyms?: Array<OutputHet>;
};

// 義項
interface OutputHet {
  // 教典的義項id
  id: number;
  // prettier-ignore
  pos:
    | "數詞" | "形容詞" | "副詞" | "熟語" | "助詞" | "時間詞" | "名詞" | "動詞"
    | "代詞" | "量詞" | "方位詞" | "連詞" | "介詞" | "嘆詞" | "擬聲詞"
    | "疑問詞" | "擬態詞" | "助動詞" | undefined;
  def: string;
  examples?: Array<{
    han: string; // 台語（漢字）
    tl: string; // 台語（羅馬字）
    zh: string; // 華語
  }>;
  // 義項對詞目反義
  hwAntonyms?: Array<{
    id: number; // 對應詞目id
    han: string; // 對應詞目漢字
  }>;
  // 義項對詞目近義
  hwSynonyms?: Array<{
    id: number; // 對應詞目id
    han: string; // 對應詞目漢字
  }>;
  // 義項對義項反義
  hhAntonyms?: Array<{
    id: number; // 對應義項id
    han: string; // 對應漢字
  }>;
  // 義項對義項近義
  hhSynonyms?: Array<{
    id: number; // 對應義項id
    han: string; // 對應漢字
  }>;
}
```
