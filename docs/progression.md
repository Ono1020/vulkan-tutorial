# 章の進め方 (単一プロジェクト方式)

2026-11-13 に、章別フォルダ方式 (1章 = 1フォルダ = 1実行ファイル) から
単一プロジェクト方式へ変更した。公式チュートリアルの本来の進め方に合わせた形。

## 基本方針

- コードは `src/main.cpp` の1ファイルだけを育てる
- 実行ファイルは `VulkanTutorial` の1つだけ
- 章の途中状態はフォルダではなく **Git のコミット** で残す。
  コミットメッセージは公式 attachments の番号と名前に合わせる
  (例: `00: base code`、`09: shader modules (slang)`)
- シェーダーは `shaders/shader.slang` の1ファイルを育てる (09章から)。
  章が進んだら中身を書き換える。GLSL 版で進める場合は
  `shaders/shader.vert` / `shader.frag` / `shader.comp` を使う
- メモは `notes/NN_<章名>.md` に残す: 「何を作ったか」
  「Validation Layers に言われたこと」「本文と自分の環境で違った点」
  「C API 版 (旧チュートリアル) との違い」
- 詰まったら `docs/setup.md` の「動作確認の順番」で切り分けてから本文を読み直す
- 共通化やリファクタはしない。本文の形のまま育てる

## 1章の流れ

1. 本文を読む
2. `src/main.cpp` (と、必要なら `shaders/shader.slang`) に差分を書き足す
3. ビルドと実行

   ```bash
   cmake --preset debug
   cmake --build --preset debug
   ./build/debug/VulkanTutorial
   ```

   シェーダーファイルを新規に追加した直後は、configure のやり直し
   (`cmake --preset debug`) が必要。シェーダーの有無は configure 時に判定される
4. 章末の完全コード (公式 attachments の `NN_<章名>.cpp`) と見比べる
5. `notes/NN_<章名>.md` にメモを残し、コミットする

過去の状態へ戻りたいときは、コミット履歴から取り出す。

```bash
git log --oneline          # 章ごとのコミットを確認
git show <commit>:src/main.cpp
```

## 全章一覧 (attachments の番号)

抜けている番号 (11, 13, 18) は、独立したコードファイルが無い章。
番号は公式に合わせて維持し、詰め直さない。

| # | 章名 (コミット / notes 用) | この章で増えるもの |
|---|---|---|
| 00 | `00_base_code` | GLFW のウィンドウだけ |
| 01 | `01_instance_creation` | インスタンス生成 |
| 02 | `02_validation_layers` | Validation Layers とデバッグメッセンジャ |
| 03 | `03_physical_device_selection` | 物理デバイス選択 |
| 04 | `04_logical_device` | 論理デバイスとキュー |
| 05 | `05_window_surface` | ウィンドウサーフェス |
| 06 | `06_swap_chain_creation` | スワップチェーン |
| 07 | `07_image_views` | イメージビュー |
| 08 | `08_graphics_pipeline` | パイプライン生成の枠 |
| 09 | `09_shader_modules` | `shaders/shader.slang` を追加。シェーダーモジュール |
| 10 | `10_fixed_functions` | 固定機能の設定 |
| 12 | `12_graphics_pipeline_complete` | パイプライン完成 |
| 14 | `14_command_buffers` | コマンドバッファ |
| 15 | `15_hello_triangle` | 最初の三角形 |
| 16 | `16_frames_in_flight` | 複数フレームの並行処理 |
| 17 | `17_swap_chain_recreation` | スワップチェーン再生成 |
| 19 | `19_vertex_buffer` | 頂点バッファ。glm を使い始める |
| 20 | `20_staging_buffer` | ステージングバッファ |
| 21 | `21_index_buffer` | インデックスバッファ |
| 22 | `22_descriptor_layout` | デスクリプタレイアウトと UBO |
| 23 | `23_descriptor_sets` | デスクリプタセット |
| 24 | `24_texture_image` | テクスチャイメージ。stb を使い始める |
| 25 | `25_sampler` | サンプラー |
| 26 | `26_texture_mapping` | テクスチャマッピング |
| 27 | `27_depth_buffering` | 深度バッファ |
| 28 | `28_model_loading` | モデル読み込み。tinyobjloader と assets を使い始める |
| 29 | `29_mipmapping` | ミップマップ |
| 30 | `30_multisampling` | MSAA |
| 31 | `31_compute_shader` | コンピュートシェーダー (shader に compMain が増える) |
| 32 | `32_ecosystem_utilities` | エコシステムユーティリティ |
| 33 | `33_vulkan_profiles` | Vulkan Profiles |
| 34 | `34_android` | Android 対応 |
| 35 | `35_gltf_ktx` | glTF / KTX。tinygltf と KTX を使い始める |
| 36 | `36_multiple_objects` | 複数オブジェクト |
| 37 | `37_multithreading` | マルチスレッディング |
| 38 | `38_ray_tracing` | レイトレーシング |

## アセットを使う章 (28章〜)

- モデル / テクスチャは `assets/models`, `assets/textures` に置く (共有)
- ビルド時に実行ファイルの隣へコピーされるので、本文の相対パスはそのまま使える
- 一覧と入手元は `assets/README.md`
