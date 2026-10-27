# 章ターゲットの共通定義と、GLSL -> SPIR-V コンパイル。
#
# 使い方 (各章の CMakeLists.txt に1行):
#   add_chapter(00_base)
#   add_chapter(08_shader_modules SHADERS shader.vert shader.frag)
#   add_chapter(31_compute_shader SHADERS shader.comp)
#
# 生成物: <章のビルド先>/shaders/vert.spv など。
# チュートリアル本文のコードが "shaders/vert.spv" を相対パスで読む前提に合わせている。
# 実行時の作業ディレクトリは「その章のビルド先」にすること (VS では自動設定済み)。

find_program(GLSLC glslc HINTS "$ENV{VULKAN_SDK}/Bin" "$ENV{VULKAN_SDK}/bin")
find_program(GLSLANG glslangValidator HINTS "$ENV{VULKAN_SDK}/Bin" "$ENV{VULKAN_SDK}/bin")

function(add_chapter TARGET)
  cmake_parse_arguments(ARG "" "" "SHADERS" ${ARGN})

  if(NOT TARGET Vulkan::Vulkan)
    message(FATAL_ERROR
      "Vulkan が見つかりません。Vulkan SDK を入れ、環境変数 VULKAN_SDK を確認してください。"
      " 手順: docs/setup.md")
  endif()
  if(NOT TARGET glfw)
    message(FATAL_ERROR
      "GLFW が見つかりません。導入手順: docs/setup.md (環境依存ポイントも参照)")
  endif()

  add_executable(${TARGET} main.cpp)
  target_link_libraries(${TARGET} PRIVATE
    Vulkan::Vulkan glfw
    $<$<TARGET_EXISTS:glm::glm>:glm::glm>
    $<$<TARGET_EXISTS:glm>:glm>
    stb_image tiny_obj_loader
  )
  if(MSVC)
    target_compile_options(${TARGET} PRIVATE /W4)
  else()
    target_compile_options(${TARGET} PRIVATE -Wall -Wextra)
  endif()

  # 共有アセット (assets/models, assets/textures) を実行先へコピーする。
  # 本文コードの "models/viking_room.obj" / "textures/viking_room.png" という
  # 相対パス指定がそのまま動くようにするため。
  foreach(_kind models textures)
    if(EXISTS ${CMAKE_SOURCE_DIR}/assets/${_kind})
      add_custom_command(TARGET ${TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
          ${CMAKE_SOURCE_DIR}/assets/${_kind}
          $<TARGET_FILE_DIR:${TARGET}>/${_kind}
        VERBATIM)
    endif()
  endforeach()

  set_target_properties(${TARGET} PROPERTIES
    VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:${TARGET}>)

  if(NOT ARG_SHADERS)
    return()
  endif()

  if(GLSLC)
    set(_compiler ${GLSLC})
    set(_compiler_arg "")
  elseif(GLSLANG)
    set(_compiler ${GLSLANG})
    set(_compiler_arg "-V")
  else()
    message(FATAL_ERROR
      "glslc / glslangValidator が見つかりません。Vulkan SDK に付属します (docs/setup.md)")
  endif()

  foreach(_shader IN LISTS ARG_SHADERS)
    get_filename_component(_ext ${_shader} LAST_EXT) # .vert / .frag / .comp
    string(SUBSTRING ${_ext} 1 -1 _stage)             # vert / frag / comp
    set(_spv ${CMAKE_CURRENT_BINARY_DIR}/shaders/${_stage}.spv)
    add_custom_command(
      OUTPUT ${_spv}
      COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/shaders
      COMMAND ${_compiler} ${_compiler_arg} ${CMAKE_CURRENT_SOURCE_DIR}/${_shader} -o ${_spv}
      DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${_shader}
      VERBATIM)
    list(APPEND _spvs ${_spv})
  endforeach()
  add_custom_target(${TARGET}_shaders DEPENDS ${_spvs})
  add_dependencies(${TARGET} ${TARGET}_shaders)
endfunction()
