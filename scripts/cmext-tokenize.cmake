# Copyright 2018-2020 Alain Martin
#
# This file is part of CMExt.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language governing
# permissions and limitations under the License.

include(CMExt.Tokenize)


function(main)

  set(minus_p_option_pos 1)
  while(minus_p_option_pos LESS CMAKE_ARGC)
    if(CMAKE_ARGV${minus_p_option_pos} STREQUAL "-P")
      break()
    endif()
    math(EXPR minus_p_option_pos "${minus_p_option_pos} + 1")
  endwhile()

  math(EXPR file_pos "${minus_p_option_pos} + 2")
  if(NOT DEFINED CMAKE_ARGV${file_pos})
    message(FATAL_ERROR "usage: cmake -P cmext-tokenize.cmake <file_to_tokenize>")
  endif()
  set(file_path "${CMAKE_ARGV${file_pos}}")

  file(READ "${file_path}" file_content)

  cme_tokenize("${file_content}" tokens)

  set(i 0)
  while(i LESS tokens_count)
    cme_print_token(tokens_${i})
    math(EXPR i "${i} + 1")
  endwhile()

  if(tokens_parse_error)
    message(FATAL_ERROR
      "Parse error at ${tokens_parse_error_line},${tokens_parse_error_column}."
    )
  endif()

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  main()
endif()
