# 環境構築

チュートリアル本体の [Development environment](https://docs.vulkan.org/tutorial/latest/02_Development_environment.html)
の章と併せて読むこと。ここではこのリポジトリの CMake 構成に合わせた要点と、
**環境依存ポイント** を挙げる。

公式が環境構築の対象としているのは **Windows (Visual Studio)** と **Ubuntu (GCC)** の2つ。
それ以外の環境 (macOS など) は本文の手順がそのまま適用できない。

## 1. Vulkan SDK (1.4.335 以降)

- 入手: https://vulkan.lunarg.com/sdk/home (LunarG 公式インストーラ / tarball)
- 入れるもの: Vulkan 本体、Validation Layers、Shader ツール (`slangc`、`glslangValidator`)
- Linux では SDK の `setup-env.sh` を読み込むと `VULKAN_SDK` などの環境変数が設定される。
  ターミナルや IDE の起動時に毎回効くよう、自動起動への組み込みが公式の推奨
- `find_package(slang CONFIG HINTS "$ENV{VULKAN_SDK}/lib/cmake")` のように、
  SDK 側の config ファイルをヒントで探す場面もある

確認方法:

```bash
vkcube            # 回転する立方体が出ればドライバ + SDK は OK
vulkaninfo --summary
slangc --version  # シェーダーは Slang が本流。glslc ではない
```

## 2. FindVulkan.cmake の配置

公式テンプレートは、Kitware (CMake) 同梱の FindVulkan は非推奨かつ macOS ビルドに
不具合があるとして、VulkanSamples 由来の `FindVulkan.cmake` をプロジェクト側に
置く方式を推奨している。

- チュートリアルの attachments にある `CMake/FindVulkan.cmake` をダウンロードし、
  このリポジトリの `CMake/` フォルダに置く (詳細: `CMake/README.md`)
- ルート `CMakeLists.txt` は `CMake/` を `CMAKE_MODULE_PATH` に追加済みなので、
  置けば自動的にそちらが使われる。置くまでは CMake 同梱版で代替される

## 3. その他の依存 (GLFW / GLM / tinyobjloader / tinygltf / KTX / stb)

公式テンプレートは全て `find_package` で探す:

```cmake
find_package(glfw3 REQUIRED)
find_package(glm REQUIRED)
find_package(tinyobjloader REQUIRED)
find_package(tinygltf REQUIRED)
find_package(KTX REQUIRED)
find_package(stb REQUIRED)
```

このリポジトリでは序盤の章 (GLFW と GLM だけ) で詰まらないよう、
ルートでは QUIET にしてあり、使う章で初めて必要になる。

| 環境 | 入れ方 (例) |
|---|---|
| Windows + vcpkg | `vcpkg install glfw3 glm tinyobjloader tinygltf ktx stb`。configure 時に `-DCMAKE_TOOLCHAIN_FILE=<vcpkg>/scripts/buildsystems/vcpkg.cmake` が必要 |
| Ubuntu | GLFW / GLM は `sudo apt install libglfw3-dev libglm-dev`。SDK は tarball + `setup-env.sh`。tinyobjloader などは章が来てから個別に用意する |

使う章の目安: GLM は 19章 (vertex buffer) から、tinyobjloader は 28章 (model loading) から、
tinygltf と KTX は 35章 (glTF/KTX) から、stb は 24章 (texture image) から。

## 4. コンパイラと CMake

- CMake **3.29 以降** (公式テンプレートの要求。C++20 モジュールのスキャン等が前提)
- C++20 対応コンパイラ: Visual Studio 2022 (MSVC) / GCC (Ubuntu の既定が公式対象)
- Vulkan-Hpp の C++20 モジュール (`vulkan.cppm`) は実験的でコンパイラ依存が強い。
  公式でも「試したい場合以外は使わない」推奨で、既定 OFF のままヘッダ
  (`#include <vulkan/vulkan_raii.hpp>`) で進めるのが本流

## 環境依存ポイント一覧

1. **公式対象 OS は Windows と Ubuntu のみ** — macOS は環境構築の章の対象外。
   MoltenVK 経由になり、portability 拡張などの追加対応が要る
2. **`VULKAN_SDK` の設定方法** — Windows はインストーラが設定、Linux は `setup-env.sh` の
   読み込み。IDE を再起動しないと反映されないことがある
3. **`slangc` の場所** — SDK の `bin` (Windows の表記ゆれで `Bin` の場合もある)。
   このリポジトリの CMake は両方を探す
4. **ジェネレータの違い** — Visual Studio はマルチコンフィグで実行ファイルの場所に
   `Debug/` 等が付く。Ninja/Make はシングルコンフィグ。実行手順とファイルパスが変わる
5. **依存パッケージの名前と見つけ方** — vcpkg / apt / 手動配置で `find_package` の
   通り方が異なる。vcpkg はツールチェーンファイルの指定が要る
6. **CMake の版** — 3.29 未満では公式テンプレート自体が configure できない
7. **C++20 モジュールの可否** — コンパイラと CMake の組み合わせ依存。落ちたら OFF に戻すのが正解
8. **Validation Layers の有無** — SDK 未導入だと Debug で
   `VK_LAYER_KHRONOS_validation` が見つからない。本文は `#ifndef NDEBUG` 前提の箇所がある
9. **GPU / ドライバ** — スワップチェーンの対応フォーマット等は GPU 依存で、
   本文の実行結果と一致しないことがある

## 動作確認の順番

1. `vkcube` が動くか (ドライバ + SDK)
2. `slangc --version` が出るか (シェーダーコンパイラ)
3. 空のリポジトリで `cmake --preset debug` が通るか (依存の検出)
4. `00_base_code` (ウィンドウを開くだけ) が動くか (GLFW + Vulkan-Hpp)
5. Validation Layers 有効で警告・エラーが出ていないか
