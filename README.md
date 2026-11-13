# vulkan-tutorial

Khronos 公式チュートリアル [Vulkan Tutorial (docs.vulkan.org)](https://docs.vulkan.org/tutorial/latest/00_Introduction.html)
で Vulkan の基礎を学ぶための練習リポジトリ。
ブラックホール・レンダラー (bh-renderer) の Vulkan Compute 実装に向けた前提学習。

旧サイト vulkan-tutorial.com (2016年公開) の後継にあたる公式版に準拠する。
主な違いは下の「旧版との違い」を参照。

- **単一プロジェクト方式** (2026-11-13 に章別フォルダ方式から変更):
  `src/main.cpp` の1ファイルを章ごとに育て、途中状態は Git のコミットで残す。
  公式チュートリアルの本来の進め方に合わせた形
- 章の番号と名前は、公式 attachments のコードファイル名 (`00_base_code.cpp` など) に
  合わせ、コミットメッセージと notes のファイル名に使う
- 進め方の詳細は [docs/progression.md](docs/progression.md)

## ディレクトリ構成

```
├── CMakeLists.txt          # ルート。公式テンプレート準拠の単一ターゲット構成
├── CMakePresets.json       # debug / release プリセット
├── CMake/                  # 自前 CMake モジュール (公式テンプレートの流儀)
│   └── FindVulkan.cmake    #   attachments から配置済み (CMake/README.md)
├── src/
│   └── main.cpp            # 全章を通して育てる唯一のコード
├── shaders/                # shader.slang (09章から。最初は空)
├── notes/                  # 章ごとの学習メモ (自分で追加していく)
├── assets/                 # 共有モデル/テクスチャ (後半の章用、最初は空)
├── scripts/
│   └── install_dependencies_linux.sh  # 公式の依存インストールスクリプト (コピー)
└── docs/
    ├── setup.md            # 環境構築と環境依存ポイント
    └── progression.md      # 章の進め方・全章一覧
```

## 旧版 (vulkan-tutorial.com) との違い

| 項目 | 旧版 | このチュートリアル (docs.vulkan.org) |
|---|---|---|
| シェーダー言語 | GLSL (`shader.vert` / `shader.frag`) | **Slang が本流** (`shader.slang` 1ファイルに `vertMain` / `fragMain` / `compMain`)。GLSL 版も attachments にあり併用可 |
| シェーダーコンパイラ | `glslc` / `glslangValidator` | `slangc` (SDK同梱、`slang.spv` を1つ出力)。GLSL 版は `glslangValidator` |
| C++ バインディング | C API (`vkCreate...` 直書き) | **Vulkan-Hpp RAII** (`vk::raii::`、`vulkan_raii.hpp`) |
| ビルド | Visual Studio 手作業設定が中心 | **CMake が公式方式** (attachments にテンプレートあり)。CMake 3.29 以降 |
| Vulkan の版 | 1.0 前提 | **1.4.335 以降の SDK** が前提 |
| C++20 モジュール | なし | `ENABLE_CPP20_MODULE` オプションあり (実験的、既定 OFF) |
| 後半の章 | 31_compute_shader で終了 | 32 ecosystem utilities、33 Vulkan profiles、35 glTF/KTX、37 multithreading、38 ray tracing まで続く |

GLSL の学習が目的に含まれる場合は、attachments の GLSL 版シェーダー
(`09_shader_base.vert` など) の内容を `shaders/shader.vert` などに写せば、
同じ章を GLSL でも進められる。このリポジトリの CMake は Slang / GLSL の両対応。

## 必要なもの

| もの | 用途 | 備考 |
|---|---|---|
| Vulkan SDK 1.4.335+ | Vulkan 本体、Validation Layers、`slangc` | 環境変数 `VULKAN_SDK`、Linux では `setup-env.sh` |
| GLFW / GLM | ウィンドウ作成 / 行列演算 | `find_package` で探す |
| tinyobjloader | モデル読み込み | 28章以降 |
| tinygltf / KTX | glTF / KTX2 テクスチャ | 35章以降 |
| stb | 画像読み込み | `find_package(stb)` |
| C++20 コンパイラ | ビルド | 公式の対象は Windows = Visual Studio、Ubuntu = GCC |
| CMake 3.29+ | ビルド | 公式テンプレートの要求 |

導入手順と環境依存ポイントは [docs/setup.md](docs/setup.md) にまとめた。
**先にそちらを読んでから** ビルドすること。

## ビルド方法

```bash
cmake --preset debug
cmake --build --preset debug
# プリセットを使わない場合: cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build
```

実行ファイルは `VulkanTutorial` の1つだけ。
Vulkan または GLFW が見つからない環境では、configure は警告のみで通り、
実行ファイルは生成されない。

C++20 モジュールを試す場合 (対応コンパイラのみ、公式でも実験扱い):

```bash
cmake --preset debug -DENABLE_CPP20_MODULE=ON
```

## 実行方法

シェーダーとアセットは相対パス (`shaders/slang.spv`, `models/viking_room.obj` など) で
読むため、**作業ディレクトリ = 実行ファイルがあるフォルダ** (`build/<preset>/`) で実行する。
Visual Studio では作業ディレクトリは自動設定済み。

```bash
cd build/debug
./VulkanTutorial
```

## シェーダーのコンパイル

手作業で `slangc` を叩く必要はない。`shaders/` にファイルがあれば、
configure 時に検出され、ビルド時に自動で変換される
(ファイルを追加した直後は `cmake --preset debug` の再実行が必要)。

- `shaders/shader.slang` があれば `slangc` で `shaders/slang.spv` に変換
  (`-target spirv -profile spirv_1_4 -emit-spirv-directly -fvk-use-entrypoint-name`、
  エントリは `vertMain` / `fragMain`、`shader.comp` がある章では `compMain` も追加)
- `shaders/shader.vert/.frag/.comp` があれば `glslangValidator` で
  `shaders/vert.spv` 等に変換

`.spv` は生成物なので Git には入れない (`.gitignore` 済み)。

## 進め方

1. [docs/setup.md](docs/setup.md) で環境を作り、`vkcube` が動くことと
   `which slangc` が SDK の `bin` を指すことを確認する
2. 章を1つ読み、`src/main.cpp` に差分を書き足す (型は [docs/progression.md](docs/progression.md))
3. ビルド・実行し、章末の完全コード (attachments) と見比べる
4. 分かったこと・詰まったことを `notes/NN_<章名>.md` に短く残す
5. 1章 (または1節) ごとにコミットする。例: `01: create instance (raii)`

## 注意

- Validation Layers のエラーは学習のうち。無効化で回避しない
- 公式の環境構築の章が対象とするのは Windows (Visual Studio) と Ubuntu (GCC)。
  macOS は対象外で、MoltenVK 経由の追加対応が別途必要になる
- `.spv` や大きなアセット、ビルド生成物はコミットしない
