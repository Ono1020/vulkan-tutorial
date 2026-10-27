# 環境構築

チュートリアル本体の「Environment setup」の章と併せて読むこと。
ここではこのリポジトリの CMake 構成に合わせた要点と、**環境依存ポイント** を挙げる。

## 1. Vulkan SDK

- 入手: https://vulkan.lunarg.com/sdk/home (LunarG 公式インストーラ)
- 入れるもの: Vulkan 本体、Validation Layers、Shader ツール (`glslc` / `glslangValidator`)
- インストール後、環境変数 `VULKAN_SDK` が SDK のルートを指すこと。
  このリポジトリは `glslc` の探索に `$VULKAN_SDK/Bin` (Windows) と `$VULKAN_SDK/bin` (Linux/macOS) の両方を見る

確認方法:

```bash
vulkaninfo --summary   # GPU とドライバが Vulkan 対応か
vkcube                 # 回転する立方体が出ればドライバ側は OK (SDK 同梱)
glslc --version
```

## 2. GLFW と GLM

このリポジトリはシステムにインストールされたものを `find_package` で探す。
入れ方は OS / 環境で異なる (下表)。vcpkg を使う場合は configure 時に
`-DCMAKE_TOOLCHAIN_FILE=<vcpkg>/scripts/buildsystems/vcpkg.cmake` が必要になる点に注意。

| 環境 | GLFW / GLM の入れ方 (例) |
|---|---|
| Windows + vcpkg | `vcpkg install glfw3 glm` |
| Windows (手動) | GLFW は公式の prebuilt binaries、GLM はヘッダ一式を配置し、`CMAKE_PREFIX_PATH` で場所を教える |
| Ubuntu / Debian | `sudo apt install libglfw3-dev libglm-dev` |
| Arch | `sudo pacman -S glfw glm` |
| macOS (Homebrew) | `brew install glfw glm` |

チュートリアル本文は GLFW のバイナリを直接参照する Visual Studio 構成だが、
このリポジトリでは CMake 経由に統一している。本文のプロジェクト設定のくだりは読み替えが必要。

## 3. コンパイラとビルドツール

- C++20 対応コンパイラ: Visual Studio 2022 (MSVC)、GCC 12 以降、Clang 15 以降が目安
- CMake 3.20 以降
- ジェネレータは環境依存: Windows は Visual Studio、Linux/macOS は Make か Ninja が既定。
  `CMakePresets.json` にはジェネレータを指定していないので、各環境の既定が使われる

## 環境依存ポイント一覧

コードや設定を書くときに「自分の環境では違う」となりやすい場所。

1. **`VULKAN_SDK` のパスと `Bin` / `bin` の表記** — Windows は `Bin`、他は `bin`。SDK の版でも変わる
2. **ジェネレータの違い** — Visual Studio はマルチコンフィグ (Debug/Release を1つの build で切替、
   実行ファイルは `Debug/` 等のサブフォルダに出る)。Ninja/Make はシングルコンフィグで
   `CMAKE_BUILD_TYPE` を configure 時に決める。実行ファイルのパスが変わるので実行手順に影響する
3. **GLFW / GLM の見つけ方** — パッケージ名 (`glfw3`)、vcpkg のツールチェーンファイル要否、
   `CMAKE_PREFIX_PATH` の要否が環境で異なる
4. **実行ファイル名** — Windows は `.exe` が付く
5. **Validation Layers の有無** — SDK を入れていない環境では Debug ビルドで
   `VK_LAYER_KHRONOS_validation` が見つからずエラーになる。本文のコードは
   `#ifdef NDEBUG` で Release では無効化される前提
6. **macOS は MoltenVK 経由** — ネイティブ Vulkan ではないため、
   `VK_KHR_portability_enumeration` フラグと `VK_KHR_portability_subset` 拡張、
   ICD の環境変数など、本文 (Windows/Linux 前提) に無い追加設定が必要になる章がある
7. **GPU / ドライバ** — スワップチェーンのフォーマットや present モードの対応状況は GPU 依存。
   本文のスクリーンショットと自分の環境の結果が一致しないことがある
8. **シェーダーの作業ディレクトリ** — `shaders/vert.spv` は相対パス。IDE から実行すると
   作業ディレクトリがずれ、ファイルが見つからないエラーになる (README の実行方法を参照)

## 動作確認の順番

詰まったら上から切り分ける:

1. `vkcube` が動くか (ドライバ + SDK)
2. 空のリポジトリで `cmake --preset debug` が通るか (依存の検出)
3. 00_base (ウィンドウを開くだけ) が動くか (GLFW)
4. Validation Layers 有効で警告・エラーが出ていないか
