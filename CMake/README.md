# CMake/

公式テンプレートと同様、自前の CMake モジュールを置くフォルダ
(ルートの `CMakeLists.txt` が `CMAKE_MODULE_PATH` に追加している)。

| ファイル | 内容 |
|---|---|
| `AddChapter.cmake` | 公式テンプレートの `add_chapter()` を、このリポジトリの章フォルダ構成に合わせて切り出したもの |
| `FindVulkan.cmake` | **自分で配置する。** Development environment の章の指示通り、チュートリアルの attachments にある `FindVulkan.cmake` (VulkanSamples 由来) をダウンロードしてここに置く。Kitware 同梱版は非推奨とされているため、置かれた場合はそちらが優先される。置くまでは CMake 同梱モジュールで代替される |

注意: フォルダ名は `CMake` (大文字 C) で、公式テンプレートの指定通り。
大文字小文字を区別しないファイルシステム (Windows / 既定の macOS) では
`cmake` という名前のフォルダと衝突するので、別名のフォルダを作らないこと。
