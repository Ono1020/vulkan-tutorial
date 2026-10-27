cmake_minimum_required(VERSION 3.29)
project(VulkanTutorial LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# 公式テンプレートと同様、自前モジュールは CMake/ (大文字) に置く
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMake")

# Vulkan-Hpp の C++20 モジュールを使うかどうか (公式テンプレートと同じオプション)。
# 対応コンパイラが限られる実験的機能のため、既定は OFF (ヘッダ利用) が推奨。
option(ENABLE_CPP20_MODULE "Enable C++ 20 module support for Vulkan" OFF)
if(ENABLE_CPP20_MODULE)
  set(CMAKE_CXX_SCAN_FOR_MODULES ON)
endif()

# 依存ライブラリ。公式テンプレートは REQUIRED だが、このリポジトリでは
# 章がまだ無い段階でも configure が通るよう QUIET にし、無いものは警告する。
# 実際に章が使う時点で CMake/AddChapter.cmake 側がエラーを出す。
find_package(Vulkan 1.4.335 QUIET)
find_package(glfw3 QUIET)
find_package(glm QUIET)
find_package(tinyobjloader QUIET)
find_package(tinygltf QUIET)
find_package(KTX QUIET)
find_package(stb QUIET)

if(NOT Vulkan_FOUND)
  message(WARNING "Vulkan SDK 1.4.335 以降が見つかりません (docs/setup.md)")
endif()
if(NOT glfw3_FOUND)
  message(WARNING "GLFW が見つかりません (docs/setup.md)")
endif()
if(NOT glm_FOUND)
  message(WARNING "GLM が見つかりません (docs/setup.md)")
endif()

if(stb_FOUND)
  set(STB_INCLUDEDIR ${stb_INCLUDE_DIRS})
endif()

# Vulkan::cppm (公式テンプレートと同じ形)。
# モジュール有効時: vulkan.cppm をビルドするライブラリ。
# 無効時: Vulkan::Vulkan + 定義2つの INTERFACE ライブラリ。
if(TARGET Vulkan::Vulkan AND NOT TARGET Vulkan::cppm)
  if(ENABLE_CPP20_MODULE)
    add_library(VulkanCppModule)
    add_library(Vulkan::cppm ALIAS VulkanCppModule)
    target_compile_definitions(VulkanCppModule PUBLIC
      VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1
      VULKAN_HPP_NO_STRUCT_CONSTRUCTORS=1)
    target_include_directories(VulkanCppModule PUBLIC "${Vulkan_INCLUDE_DIR}")
    target_link_libraries(VulkanCppModule PUBLIC Vulkan::Vulkan)
    set_target_properties(VulkanCppModule PROPERTIES CXX_STANDARD 20)
    if(MSVC)
      target_compile_options(VulkanCppModule PRIVATE
        /std:c++latest /permissive- /Zc:__cplusplus /EHsc /Zc:preprocessor /translateInclude)
    endif()
    target_sources(VulkanCppModule PUBLIC
      FILE_SET cxx_modules TYPE CXX_MODULES
      BASE_DIRS "${Vulkan_INCLUDE_DIR}"
      FILES "${Vulkan_INCLUDE_DIR}/vulkan/vulkan.cppm")
    target_sources(VulkanCppModule PRIVATE "${Vulkan_INCLUDE_DIR}/vulkan/vulkan.cppm")
  else()
    add_library(VulkanCppModule INTERFACE)
    add_library(Vulkan::cppm ALIAS VulkanCppModule)
    target_link_libraries(VulkanCppModule INTERFACE Vulkan::Vulkan)
    target_compile_definitions(VulkanCppModule INTERFACE
      VULKAN_HPP_DISPATCH_LOADER_DYNAMIC=1
      VULKAN_HPP_NO_STRUCT_CONSTRUCTORS=1)
  endif()
endif()

include(AddChapter)

# chapters/ 配下に CMakeLists.txt がある章だけを自動で登録する
file(GLOB _chapter_dirs RELATIVE ${CMAKE_SOURCE_DIR}/chapters ${CMAKE_SOURCE_DIR}/chapters/*)
foreach(_dir IN LISTS _chapter_dirs)
  if(EXISTS ${CMAKE_SOURCE_DIR}/chapters/${_dir}/CMakeLists.txt)
    add_subdirectory(chapters/${_dir})
  endif()
endforeach()
