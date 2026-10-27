# 章の追加手順と進め方

## 新しい章を作る

前の章が終わった状態から始める。

```bash
mkdir chapters/01_instance_creation
cp chapters/00_base/main.cpp chapters/01_instance_creation/main.cpp
```

`chapters/01_instance_creation/CMakeLists.txt` を作る (これだけでルートが自動登録する):

```cmake
add_chapter(01_instance_creation)
```

シェーダーを使う章ではファイル名も書く:

```cmake
add_chapter(08_shader_modules SHADERS shader.vert shader.frag)
```

その章のフォルダに `shader.vert` / `shader.frag` を置くと、
ビルド時に `shaders/vert.spv` / `shaders/frag.spv` へ自動変換される。

Compute シェーダーの章:

```cmake
add_chapter(31_compute_shader SHADERS shader.comp)
```

## 章フォルダの命名

- 番号はチュートリアルの配布コード / 目次の順に合わせた2桁ゼロ埋め
- 名前は本文の見出しを snake_case にしたもの
- 例: `00_base`, `01_instance_creation`, `02_validation_layers`,
  `06_swap_chain_creation`, `16_vertex_buffer`, `24_texture_mapping`,
  `27_loading_models`, `31_compute_shader`

## 進め方の運用

- 前章のコピーを起点にし、その章の差分だけを書き足す。共通化・リファクタはしない
  (重複が残るのは学習用として意図的。全章終了後にやりたくなったら別ブランチで)
- 1章または1節ごとにコミット: `git commit -m "08: add shader modules"` のような形
- メモはコードと分けて `notes/NN_<章名>.md` に置く。書くのは最低限:
  「何を作ったか」「Validation Layers に言われたこと」「本文と自分の環境で違った点」
- 詰まったら `docs/setup.md` の「動作確認の順番」で切り分けてから本文を読み直す

## アセットを使う章

- モデル/テクスチャは章フォルダではなく `assets/models`, `assets/textures` に置く (共有)
- ビルド時に実行ファイルの隣へコピーされるので、本文の相対パスはそのまま使える
- `stb_image.h` / `tiny_obj_loader.h` は `external/` に置く (入手元は `external/README.md`)
