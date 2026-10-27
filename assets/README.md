# assets/

後半の章で使う共有アセット。最初は空でよい。

| 置き場所 | 内容 | 入手元 |
|---|---|---|
| `models/viking_room.obj` | Viking room モデル | チュートリアルの Loading models の章の添付ファイル |
| `textures/viking_room.png` | 上記モデルのテクスチャ | 同上 |
| `textures/texture.jpg` | Texture mapping の章のサンプル画像 | 同章の添付ファイル |

ビルド時に各章の実行ファイルの隣へ `models/` `textures/` としてコピーされる
(`cmake/CompileShaders.cmake` の `add_chapter()` が処理する)。
そのため本文コードの相対パス (`models/viking_room.obj` など) は変更しなくてよい。
