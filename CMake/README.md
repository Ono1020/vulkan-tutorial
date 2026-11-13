# CMake/

公式テンプレートと同様、自前の CMake モジュールを置くフォルダ
(ルートの `CMakeLists.txt` が `CMAKE_MODULE_PATH` に追加している)。

| ファイル | 内容 |
|---|---|
| `FindVulkan.cmake` | Development environment の章の指示に従い、チュートリアルの attachments にある `FindVulkan.cmake` (VulkanSamples 由来) を配置したもの (2026-11-13 配置済み)。Kitware 同梱版は非推奨とされているため、こちらが優先される |

注意: フォルダ名は `CMake` (大文字 C) で、公式テンプレートの指定通り。
大文字小文字を区別しないファイルシステム (Windows / 既定の macOS) では
`cmake` という名前のフォルダと衝突するので、別名のフォルダを作らないこと。
