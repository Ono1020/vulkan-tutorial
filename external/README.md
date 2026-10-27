# external/

ヘッダオンリーの外部ライブラリを置く場所。最初は空でよい。
該当する章に進んだら、チュートリアルの指示に従って自分で配置する。

| ファイル | 入手先 | 使う章 (目安) |
|---|---|---|
| `stb_image.h` | https://github.com/nothings/stb (`stb_image.h` 単体) | Texture mapping 以降 |
| `tiny_obj_loader.h` | https://github.com/tinyobjloader/tinyobjloader (`tiny_obj_loader.h` 単体) | Loading models 以降 |

Vulkan SDK / GLFW / GLM はここには置かない。システムにインストールして
CMake の `find_package` で見つける方式 (手順: `docs/setup.md`)。
