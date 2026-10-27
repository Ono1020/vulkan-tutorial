# vulkan-tutorial

[Vulkan Tutorial](https://vulkan-tutorial.com/) で Vulkan と GLSL の基礎を学ぶための
練習リポジトリ。ブラックホール・レンダラー (bh-renderer) の Vulkan Compute 実装に向けた前提学習。

- 1章 = 1フォルダ = 1実行ファイル。本文のコードを自分で書いて進める
- `chapters/` と `notes/` は最初は空 (`.gitkeep` のみ)。中身はチュートリアルを進めながら自分で作る

## ディレクトリ構成

```
├── CMakeLists.txt          # ルート。chapters/ の章を自動登録する
├── CMakePresets.json       # debug / release プリセット
├── cmake/
│   └── CompileShaders.cmake  # add_chapter() と GLSL -> SPIR-V 変換
├── chapters/               # 章ごとのコード (自分で追加していく)
├── notes/                  # 章ごとの学習メモ (自分で追加していく)
├── assets/                 # 共有モデル/テクスチャ (後半の章用、最初は空)
├── external/               # ヘッダオンリー単体ファイル用 (最初は空)
└── docs/
    ├── setup.md            # 環境構築 (OS別) と環境依存ポイント
    └── adding-chapters.md  # 章の追加手順・進め方・コミットの切り方
```

## 必要なもの

| もの | 用途 | 備考 |
|---|---|---|
| Vulkan SDK (LunarG) | Vulkan 本体、Validation Layers、`glslc` | 環境変数 `VULKAN_SDK` が設定される |
| GLFW 3.3+ | ウィンドウ作成 | `find_package(glfw3)` で探す |
| GLM | 行列・ベクトル演算 | ヘッダオンリー |
| C++20 コンパイラ | ビルド | MSVC 2022 / GCC / Clang など |
| CMake 3.20+ | ビルド | Ninja があれば併用可 |

OS別の導入手順と、環境によって変わる場所の一覧は [docs/setup.md](docs/setup.md) にまとめた。
**先にそちらを読んでから** ビルドすること。特に `VULKAN_SDK` のパス、GLFW/GLM の入れ方、
ジェネレータ (Visual Studio / Ninja / Make) は環境依存で、この README のコマンド例と異なる場合がある。

## ビルド方法

依存を入れた後、リポジトリのルートで:

```bash
# プリセットを使う場合 (推奨)
cmake --preset debug
cmake --build --preset debug

# プリセットを使わない場合
cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

章がまだ無い段階では、実行ファイルは作られず configure だけが通る (依存が無い場合は警告が出る)。
章を追加した後のビルドと実行は [docs/adding-chapters.md](docs/adding-chapters.md) を参照。

特定の章だけビルドする場合:

```bash
cmake --build build --target 00_base
```

## 実行方法

シェーダーやアセットは相対パス (`shaders/vert.spv`, `models/viking_room.obj` など) で読むため、
**作業ディレクトリ = その章の実行ファイルがあるフォルダ** で実行する。

```bash
# 例: build/debug/chapters/00_base/ に実行ファイルができる構成の場合
cd build/debug/chapters/00_base
./00_base        # Windows では 00_base.exe
```

Visual Studio から実行する場合は作業ディレクトリが自動で設定済み
(`cmake/CompileShaders.cmake` の `VS_DEBUGGER_WORKING_DIRECTORY`)。

## シェーダーのコンパイル

手作業で `glslc` を叩く必要はない。各章の `CMakeLists.txt` で:

```cmake
add_chapter(08_shader_modules SHADERS shader.vert shader.frag)
```

と書くと、ビルド時に `shader.vert -> shaders/vert.spv`、`shader.frag -> shaders/frag.spv`
へ自動変換される (`.comp` も同様)。`.spv` は生成物なので Git には入れない (`.gitignore` 済み)。

手動で確認したい場合は SDK 付属のツールで:

```bash
glslc shader.vert -o vert.spv
# または
glslangValidator -V shader.vert -o vert.spv
```

## 進め方

1. [docs/setup.md](docs/setup.md) で環境を作り、`vkcube` や SDK のサンプル、
   または Validation Layers が有効な状態で警告なく起動するか確認する
2. チュートリアルの章を1つ読み、`chapters/NN_<章名>/` を作って本文コードを書く
   (手順の型は [docs/adding-chapters.md](docs/adding-chapters.md))
3. ビルドして実行し、章末の状態と一致するか確認する
4. 分かったこと・詰まったことを `notes/NN_<章名>.md` に短く残す
5. 1章 (または1節) ごとにコミットする。例: `01: create VkInstance`

章同士を比べたいときは `git diff` ではなくフォルダ同士の差分を見る:
前の章をコピーしてから書き足す運用にすると、「この章で増えたもの」がそのまま差分になる。

## 注意

- Validation Layers のエラーは学習のうち。まずメッセージを読む。無効化で回避しない
- `.spv`、モデル/テクスチャの大きなファイル、ビルド生成物はコミットしない
- macOS では Vulkan は MoltenVK 経由になり、本文と挙動・必要な拡張が異なる箇所がある
  (詳細は docs/setup.md の環境依存ポイント)
