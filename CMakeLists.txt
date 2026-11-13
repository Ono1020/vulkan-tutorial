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
# 環境が未完成でも configure が通るよう QUIET にし、無いものは警告する。
# 実行ファイルの生成は Vulkan と GLFW が揃ったときだけ行う (下記)。
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

find_program(SLANGC_EXECUTABLE slangc HINTS "$ENV{VULKAN_SDK}/bin" "$ENV{VULKAN_SDK}/Bin")
find_program(GLSLANG_VALIDATOR "glslangValidator" HINTS "$ENV{VULKAN_SDK}/bin" "$ENV{VULKAN_SDK}/Bin")

# 単一プロジェクト方式 (2026-11-13 に章別フォルダ方式から変更)。
# 実行ファイルは VulkanTutorial の1つだけ。src/main.cpp を章ごとに育て、
# 途中状態は Git のコミットで残す。
if(TARGET Vulkan::Vulkan AND TARGET glfw)
  add_executable(VulkanTutorial src/main.cpp)
  set_target_properties(VulkanTutorial PROPERTIES
    CXX_STANDARD 20
    VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:VulkanTutorial>)

  target_link_libraries(VulkanTutorial PRIVATE Vulkan::cppm glfw)
  target_compile_definitions(VulkanTutorial PRIVATE
    VULKAN_HPP_HANDLE_ERROR_OUT_OF_DATE_AS_SUCCESS)
  if(ENABLE_CPP20_MODULE)
    target_compile_definitions(VulkanTutorial PRIVATE USE_CPP20_MODULES=1)
  endif()
  if(DEFINED STB_INCLUDEDIR AND NOT STB_INCLUDEDIR STREQUAL "")
    target_include_directories(VulkanTutorial PRIVATE ${STB_INCLUDEDIR})
  endif()

  # 後半の章で使うライブラリは、見つかっているものだけをリンクする。
  # (19章〜: glm / 28章〜: tinyobjloader / 35章〜: tinygltf, KTX)
  foreach(_opt_target IN ITEMS glm::glm tinyobjloader::tinyobjloader tinygltf::tinygltf KTX::ktx)
    if(TARGET ${_opt_target})
      target_link_libraries(VulkanTutorial PRIVATE ${_opt_target})
    endif()
  endforeach()

  # シェーダー (09章〜)。shaders/ にファイルがあればビルド時に変換する。
  # Slang が本流: shaders/shader.slang -> shaders/slang.spv
  # GLSL 版を使う場合: shaders/shader.vert/.frag/.comp -> shaders/<ext>.spv
  set(_shader_dir ${CMAKE_BINARY_DIR}/shaders)
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.slang)
    if(NOT SLANGC_EXECUTABLE)
      message(FATAL_ERROR "slangc が見つかりません。Vulkan SDK に同梱されています (docs/setup.md)")
    endif()
    file(MAKE_DIRECTORY ${_shader_dir})
    set(_entries -entry vertMain -entry fragMain)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.comp)
      list(APPEND _entries -entry compMain)
    endif()
    add_custom_command(
      OUTPUT ${_shader_dir}/slang.spv
      COMMAND ${SLANGC_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.slang
              -target spirv -profile spirv_1_4 -emit-spirv-directly
              -fvk-use-entrypoint-name ${_entries} -o slang.spv
      WORKING_DIRECTORY ${_shader_dir}
      DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.slang
      COMMENT "Compiling Slang shaders"
      VERBATIM)
    add_custom_target(VulkanTutorial_slang_shader DEPENDS ${_shader_dir}/slang.spv)
    add_dependencies(VulkanTutorial VulkanTutorial_slang_shader)
  endif()
  set(_glsl_sources)
  set(_glsl_outputs)
  foreach(_ext vert frag comp)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.${_ext})
      list(APPEND _glsl_sources ${CMAKE_CURRENT_SOURCE_DIR}/shaders/shader.${_ext})
      list(APPEND _glsl_outputs ${_shader_dir}/${_ext}.spv)
    endif()
  endforeach()
  if(_glsl_sources)
    if(NOT GLSLANG_VALIDATOR)
      message(FATAL_ERROR "glslangValidator が見つかりません。Vulkan SDK に同梱されています (docs/setup.md)")
    endif()
    file(MAKE_DIRECTORY ${_shader_dir})
    add_custom_command(
      OUTPUT ${_glsl_outputs}
      COMMAND ${GLSLANG_VALIDATOR} --target-env vulkan1.0 ${_glsl_sources} --quiet
      WORKING_DIRECTORY ${_shader_dir}
      DEPENDS ${_glsl_sources}
      COMMENT "Compiling GLSL shaders"
      VERBATIM)
    add_custom_target(VulkanTutorial_glsl_shader DEPENDS ${_glsl_outputs})
    add_dependencies(VulkanTutorial VulkanTutorial_glsl_shader)
  endif()

  # 共有アセット (assets/) を実行ファイルの隣へコピーする (28章〜)。
  foreach(_kind models textures)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/assets/${_kind})
      add_custom_command(TARGET VulkanTutorial POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
          ${CMAKE_CURRENT_SOURCE_DIR}/assets/${_kind}
          $<TARGET_FILE_DIR:VulkanTutorial>/${_kind}
        VERBATIM)
    endif()
  endforeach()
else()
  message(WARNING
    "Vulkan または GLFW が見つからないため、実行ファイルは生成されません (docs/setup.md)")
endif()
