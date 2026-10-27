cmake_minimum_required(VERSION 3.20)
project(vulkan-tutorial LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# compile_commands.json を出す (clangd / VS Code 用)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 依存ライブラリ。見つからない場合でも、章がまだ無い段階では configure が通るように
# ここでは REQUIRED を付けない。実際に章を追加した時点で add_chapter() が
# 見つからない依存をエラーとして知らせる (手順は docs/setup.md)。
find_package(Vulkan QUIET)
find_package(glfw3 3.3 QUIET)
find_package(glm QUIET)

if(NOT Vulkan_FOUND)
  message(WARNING "Vulkan SDK が見つかりません。章をビルドするには docs/setup.md の導入が必要です")
endif()
if(NOT glfw3_FOUND)
  message(WARNING "GLFW が見つかりません。章をビルドするには docs/setup.md の導入が必要です")
endif()
if(NOT glm_FOUND)
  message(WARNING "GLM が見つかりません。章をビルドするには docs/setup.md の導入が必要です")
endif()

# ヘッダオンリー: external/ に置いたもの (該当の章に進んだら自分で配置する)
add_library(stb_image INTERFACE)
target_include_directories(stb_image INTERFACE ${CMAKE_SOURCE_DIR}/external)

add_library(tiny_obj_loader INTERFACE)
target_include_directories(tiny_obj_loader INTERFACE ${CMAKE_SOURCE_DIR}/external)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
include(CompileShaders)

# chapters/ 配下に CMakeLists.txt がある章だけを自動で登録する。
# 章を増やすときにルートを編集する必要はない。
file(GLOB _chapter_dirs RELATIVE ${CMAKE_SOURCE_DIR}/chapters ${CMAKE_SOURCE_DIR}/chapters/*)
foreach(_dir IN LISTS _chapter_dirs)
  if(EXISTS ${CMAKE_SOURCE_DIR}/chapters/${_dir}/CMakeLists.txt)
    add_subdirectory(chapters/${_dir})
  endif()
endforeach()
