# 章の追加手順と進め方

章名・番号・シェーダーのベース名は、公式 attachments のファイル名に合わせる。
コードファイルは `00_base_code.cpp` のように「章名 = ファイル名」が公式の形。

## 新しい章を作る

```bash
mkdir chapters/01_instance_creation
cp chapters/00_base_code/00_base_code.cpp chapters/01_instance_creation/01_instance_creation.cpp
```

`chapters/01_instance_creation/CMakeLists.txt` を作る (ルートが自動登録する):

```cmake
add_chapter(01_instance_creation)
```

シェーダーを使う章 (公式テンプレートと同じ書き方):

```cmake
add_chapter(09_shader_modules SHADER 09_shader_base)
```

追加ライブラリやアセットが要る章:

```cmake
add_chapter(28_model_loading SHADER 27_shader_depth
            LIBS glm::glm tinyobjloader::tinyobjloader
            MODELS viking_room.obj TEXTURES viking_room.png)
```

章フォルダに置くもの:

- `<章名>.cpp` — その章の完全コードを自分で書く
- `<SHADER>.slang` — Slang シェーダー (本流)。1ファイルに `vertMain` / `fragMain`
  (Compute は `compMain`) を書く。ビルドで `shaders/slang.spv` になる
- `<SHADER>.vert` / `.frag` / `.comp` — attachments の GLSL 版を使う場合。
  ビルドで `shaders/vert.spv` などになる

## 全章一覧 (attachments の番号)

抜けている番号 (11, 13, 18) は、独立したコードファイルが無い章。

| # | 章フォルダ名 | SHADER | 追加 LIBS |
|---|---|---|---|
| 00 | `00_base_code` | - | - |
| 01 | `01_instance_creation` | - | - |
| 02 | `02_validation_layers` | - | - |
| 03 | `03_physical_device_selection` | - | - |
| 04 | `04_logical_device` | - | - |
| 05 | `05_window_surface` | - | - |
| 06 | `06_swap_chain_creation` | - | - |
| 07 | `07_image_views` | - | - |
| 08 | `08_graphics_pipeline` | - | - |
| 09 | `09_shader_modules` | `09_shader_base` | - |
| 10 | `10_fixed_functions` | `09_shader_base` | - |
| 12 | `12_graphics_pipeline_complete` | `09_shader_base` | - |
| 14 | `14_command_buffers` | `09_shader_base` | - |
| 15 | `15_hello_triangle` | `09_shader_base` | - |
| 16 | `16_frames_in_flight` | `09_shader_base` | - |
| 17 | `17_swap_chain_recreation` | `09_shader_base` | - |
| 19 | `19_vertex_buffer` | `19_shader_vertexbuffer` | glm |
| 20 | `20_staging_buffer` | `19_shader_vertexbuffer` | glm |
| 21 | `21_index_buffer` | `19_shader_vertexbuffer` | glm |
| 22 | `22_descriptor_layout` | `22_shader_ubo` | glm |
| 23 | `23_descriptor_sets` | `22_shader_ubo` | glm |
| 24 | `24_texture_image` | `22_shader_ubo` | glm |
| 25 | `25_sampler` | `22_shader_ubo` | glm |
| 26 | `26_texture_mapping` | `26_shader_textures` | glm |
| 27 | `27_depth_buffering` | `27_shader_depth` | glm |
| 28 | `28_model_loading` | `27_shader_depth` | glm, tinyobjloader |
| 29 | `29_mipmapping` | `27_shader_depth` | glm, tinyobjloader |
| 30 | `30_multisampling` | `27_shader_depth` | glm, tinyobjloader |
| 31 | `31_compute_shader` | `31_shader_compute` | glm |
| 32 | `32_ecosystem_utilities` | `27_shader_depth` | glm, tinyobjloader |
| 33 | `33_vulkan_profiles` | `27_shader_depth` | glm, tinyobjloader |
| 34 | `34_android` | `27_shader_depth` | glm, tinyobjloader |
| 35 | `35_gltf_ktx` | `27_shader_depth` | glm, tinygltf, KTX |
| 36 | `36_multiple_objects` | `27_shader_depth` | glm, tinygltf, KTX |
| 37 | `37_multithreading` | `37_shader_compute` | glm |
| 38 | `38_ray_tracing` | `38_ray_tracing` | glm, tinyobjloader |

## 進め方の運用

- 前章のコピーを起点に、その章の差分だけを書き足す。共通化・リファクタはしない
- C++ は Vulkan-Hpp RAII (`vk::raii::`) で書くのが本文の形。C API の直書きと比較したい
  ときは notes に違いをメモする
- 1章または1節ごとにコミット: `git commit -m "09: shader modules (slang)"` のような形
- メモは `notes/NN_<章名>.md` に: 「何を作ったか」「Validation Layers に言われたこと」
  「本文と自分の環境で違った点」「C API 版 (旧チュートリアル) との違い」
- 詰まったら `docs/setup.md` の「動作確認の順番」で切り分けてから本文を読み直す

## アセットを使う章

- モデル/テクスチャは章フォルダではなく `assets/models`, `assets/textures` に置く (共有)
- ビルド時に実行ファイルの隣へコピーされるので、本文の相対パスはそのまま使える
- 一覧と入手元は `assets/README.md`
