# 章ターゲットの共通定義。docs.vulkan.org チュートリアルの attachments に付属する
# 公式 CMakeLists.txt テンプレートの add_chapter() を、このリポジトリの
# 「chapters/<章名>/<章名>.cpp」構成に合わせて切り出したもの。
#
# 使い方 (各章の CMakeLists.txt に1行):
#   add_chapter(00_base_code)
#   add_chapter(09_shader_modules SHADER 09_shader_base)
#   add_chapter(28_model_loading SHADER 27_shader_depth
#               LIBS glm::glm tinyobjloader::tinyobjloader
#               MODELS viking_room.obj TEXTURES viking_room.png)
#
# シェーダーは章フォルダに置く:
#   <SHADER>.slang          -> slangc で shaders/slang.spv に変換 (チュートリアルの本流)
#   <SHADER>.vert/.frag/.comp -> glslangValidator で shaders/vert.spv 等に変換
#                              (attachments にある GLSL 版を使う場合)

find_program(SLANGC_EXECUTABLE slangc HINTS "$ENV{VULKAN_SDK}/bin" "$ENV{VULKAN_SDK}/Bin")
find_program(GLSLANG_VALIDATOR "glslangValidator" HINTS "$ENV{VULKAN_SDK}/bin" "$ENV{VULKAN_SDK}/Bin")

function(add_slang_shader_target TARGET CHAPTER_NAME SHADER_BASE)
  if(NOT SLANGC_EXECUTABLE)
    message(FATAL_ERROR "slangc が見つかりません。Vulkan SDK に同梱されています (docs/setup.md)")
  endif()
  set(_dir ${CMAKE_BINARY_DIR}/chapters/${CHAPTER_NAME}/shaders)
  file(MAKE_DIRECTORY ${_dir})
  set(_entries -entry vertMain -entry fragMain)
  if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SHADER_BASE}.comp)
    list(APPEND _entries -entry compMain)
  endif()
  add_custom_command(
    OUTPUT ${_dir}/slang.spv
    COMMAND ${SLANGC_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/${SHADER_BASE}.slang
            -target spirv -profile spirv_1_4 -emit-spirv-directly
            -fvk-use-entrypoint-name ${_entries} -o slang.spv
    WORKING_DIRECTORY ${_dir}
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${SHADER_BASE}.slang
    COMMENT "Compiling Slang shaders for ${CHAPTER_NAME}"
    VERBATIM)
  add_custom_target(${TARGET} DEPENDS ${_dir}/slang.spv)
endfunction()

function(add_glsl_shader_target TARGET CHAPTER_NAME SHADER_BASE)
  if(NOT GLSLANG_VALIDATOR)
    message(FATAL_ERROR "glslangValidator が見つかりません。Vulkan SDK に同梱されています (docs/setup.md)")
  endif()
  set(_dir ${CMAKE_BINARY_DIR}/chapters/${CHAPTER_NAME}/shaders)
  file(MAKE_DIRECTORY ${_dir})
  set(_outputs)
  foreach(_ext vert frag comp)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SHADER_BASE}.${_ext})
      list(APPEND _sources ${CMAKE_CURRENT_SOURCE_DIR}/${SHADER_BASE}.${_ext})
      list(APPEND _outputs ${_dir}/${_ext}.spv)
    endif()
  endforeach()
  add_custom_command(
    OUTPUT ${_outputs}
    COMMAND ${GLSLANG_VALIDATOR} --target-env vulkan1.0 ${_sources} --quiet
    WORKING_DIRECTORY ${_dir}
    DEPENDS ${_sources}
    COMMENT "Compiling GLSL shaders for ${CHAPTER_NAME}"
    VERBATIM)
  add_custom_target(${TARGET} DEPENDS ${_outputs})
endfunction()

function(add_chapter CHAPTER_NAME)
  cmake_parse_arguments(CHAPTER "" "SHADER" "LIBS;TEXTURES;MODELS" ${ARGN})

  if(NOT TARGET Vulkan::Vulkan)
    message(FATAL_ERROR
      "Vulkan が見つかりません。Vulkan SDK (1.4.335 以降) を入れ、"
      "環境変数 VULKAN_SDK を確認してください。手順: docs/setup.md")
  endif()
  if(NOT TARGET glfw)
    message(FATAL_ERROR "GLFW が見つかりません。導入手順: docs/setup.md")
  endif()

  add_executable(${CHAPTER_NAME} ${CHAPTER_NAME}.cpp)
  set_target_properties(${CHAPTER_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/chapters/${CHAPTER_NAME}
    CXX_STANDARD 20)

  # 公式テンプレートと同様、Vulkan::cppm 経由でリンクする。
  # モジュール無効時は INTERFACE ライブラリとして Vulkan::Vulkan + 定義2つに展開される。
  if(TARGET Vulkan::cppm)
    target_link_libraries(${CHAPTER_NAME} PRIVATE Vulkan::cppm glfw)
  else()
    target_link_libraries(${CHAPTER_NAME} PRIVATE Vulkan::Vulkan glfw)
  endif()
  if(ENABLE_CPP20_MODULE)
    target_compile_definitions(${CHAPTER_NAME} PRIVATE USE_CPP20_MODULES=1)
  endif()
  target_compile_definitions(${CHAPTER_NAME} PRIVATE
    VULKAN_HPP_HANDLE_ERROR_OUT_OF_DATE_AS_SUCCESS)
  if(DEFINED STB_INCLUDEDIR AND NOT STB_INCLUDEDIR STREQUAL "")
    target_include_directories(${CHAPTER_NAME} PRIVATE ${STB_INCLUDEDIR})
  endif()
  if(CHAPTER_LIBS)
    target_link_libraries(${CHAPTER_NAME} PRIVATE ${CHAPTER_LIBS})
  endif()
  set_target_properties(${CHAPTER_NAME} PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:${CHAPTER_NAME}>)

  if(DEFINED CHAPTER_SHADER)
    if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${CHAPTER_SHADER}.slang)
      add_slang_shader_target(${CHAPTER_NAME}_slang_shader ${CHAPTER_NAME} ${CHAPTER_SHADER})
      add_dependencies(${CHAPTER_NAME} ${CHAPTER_NAME}_slang_shader)
    endif()
    foreach(_ext vert frag comp)
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${CHAPTER_SHADER}.${_ext})
        add_glsl_shader_target(${CHAPTER_NAME}_shader ${CHAPTER_NAME} ${CHAPTER_SHADER})
        add_dependencies(${CHAPTER_NAME} ${CHAPTER_NAME}_shader)
        break()
      endif()
    endforeach()
  endif()

  # 共有アセット (リポジトリ直下 assets/) を実行先へコピーする。
  # MODELS / TEXTURES 引数は公式テンプレートとの互換のための宣言で、
  # 実コピーはフォルダ単位で行う (本文の相対パス models/... textures/... が動く)。
  if(CHAPTER_MODELS OR CHAPTER_TEXTURES)
    foreach(_kind models textures)
      if(EXISTS ${CMAKE_SOURCE_DIR}/assets/${_kind})
        add_custom_command(TARGET ${CHAPTER_NAME} POST_BUILD
          COMMAND ${CMAKE_COMMAND} -E copy_directory_if_different
            ${CMAKE_SOURCE_DIR}/assets/${_kind}
            $<TARGET_FILE_DIR:${CHAPTER_NAME}>/${_kind}
          VERBATIM)
      endif()
    endforeach()
  endif()
endfunction()
