# Copyright 2018 Alain Martin
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

include(CMExt)


set(_tokenize_test_helpers_tmp_file "${CMAKE_CURRENT_LIST_FILE}.tmp")


function(assert_cmake_can_parse code)

  file(WRITE "${_tokenize_test_helpers_tmp_file}" "return()\n${code}")

  execute_process(
    COMMAND "${CMAKE_COMMAND}" "-P" "${_tokenize_test_helpers_tmp_file}"
    RESULT_VARIABLE process_result
    ERROR_QUIET
  )
  cme_assert([[process_result EQUAL 0]])

endfunction()


function(assert_cmake_fails code error_message)

  file(WRITE "${_tokenize_test_helpers_tmp_file}" "return()\n${code}")

  execute_process(
    COMMAND "${CMAKE_COMMAND}" "-P" "${_tokenize_test_helpers_tmp_file}"
    RESULT_VARIABLE process_result
    ERROR_VARIABLE process_error
  )
  cme_assert([[process_result EQUAL 1]])
  cme_assert([[process_error MATCHES "${error_message}"]])

endfunction()


function(assert_no_tokenize_errors count code)

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")

  cme_assert("NOT tokens_parse_error")
  cme_assert("NOT tokens_syntax_error")
  cme_assert("tokens_count EQUAL ${count}")

endfunction()


function(assert_parse_error line column code)

  cme_tokenize("${code}" tokens)

  assert_cmake_fails("${code}" "Parse error\\\\.")

  cme_assert("tokens_parse_error")
  cme_assert("tokens_parse_error_line EQUAL ${line}")
  cme_assert("tokens_parse_error_column EQUAL ${column}")
  cme_assert("NOT tokens_syntax_error")

endfunction()


function(assert_syntax_error line column code)

  cme_tokenize("${code}" tokens)

  assert_cmake_fails("${code}" "Syntax Error in cmake code")

  cme_assert("tokens_syntax_error")
  cme_assert("tokens_syntax_error_line EQUAL ${line}")
  cme_assert("tokens_syntax_error_column EQUAL ${column}")
  cme_assert("NOT tokens_parse_error")

endfunction()


function(assert_takes_one_argument arg1)

  set(remainder "${ARGN}")
  cme_assert([[remainder STREQUAL ""]])

endfunction()


function(assert_takes_two_arguments arg1 arg2)

  set(remainder "${ARGN}")
  cme_assert([[remainder STREQUAL ""]])

endfunction()


function(assert_token_equals token line column type text)

  cme_assert("${token}_line EQUAL line")
  cme_assert("${token}_column EQUAL column")
  cme_assert("${token}_type STREQUAL type")
  cme_assert("${token}_text STREQUAL text")

endfunction()


function(assert_tokenize_argument code arg_index arg_type arg_text)

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert("tokens_${arg_index}_type STREQUAL Token_${arg_type}Argument")
  cme_assert("tokens_${arg_index}_text STREQUAL arg_text")

endfunction()
