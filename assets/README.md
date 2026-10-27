# assets/

後半の章で使う共有アセット。最初は空でよい。
入手元はいずれもチュートリアルの attachments (各章の完全コードと一緒に配布される)。

| 置き場所 | 内容 | 使う章 |
|---|---|---|
| `textures/texture.jpg` | Texture mapping のサンプル画像 | 24〜27 など |
| `models/viking_room.obj` | Viking room モデル | 28〜34 |
| `textures/viking_room.png` | 上記のテクスチャ | 28〜34 |
| `models/viking_room.glb` | Viking room の glTF 版 | 35〜36 |
| `textures/viking_room.ktx2` | 上記の KTX2 テクスチャ | 35〜36 |
| `models/plant_on_table.obj` ほか | Ray tracing 章のモデル一式 | 38 |
| `textures/plant_on_table_textures/*.png` | 上記のテクスチャ一式 | 38 |

ビルド時に各章の実行ファイルの隣へ `models/` `textures/` としてコピーされる
(`CMake/AddChapter.cmake` の `add_chapter()` が処理する)。
そのため本文コードの相対パス (`models/viking_room.obj` など) は変更しなくてよい。
