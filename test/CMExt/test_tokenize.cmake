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
include(CMExt.Test)
include(CMExt.Tokenize)

include("${CMAKE_CURRENT_LIST_DIR}/tokenize_test_helpers.cmake")


function(test_tokenize_empty)

  cme_tokenize("" tokens)

  assert_cmake_can_parse("")
  cme_assert([[tokens_count EQUAL 0]])
  cme_assert([[DEFINED tokens_parse_error AND NOT tokens_parse_error]])

endfunction()


function(test_tokenize_parse_error)

  set(snippets_count 0)
  macro(define_snippet line column code)
    math(EXPR snippets_count "${snippets_count} + 1")
    set(snippet_${snippets_count}_line "${line}")
    set(snippet_${snippets_count}_column "${column}")
    set(snippet_${snippets_count} "${code}")
  endmacro()

  define_snippet(1   1  "|This is not CMake code|")
  define_snippet(2   1  "\n|What?|")
  define_snippet(1   4  "foo")
  define_snippet(1   5  "foo(")
  define_snippet(1   6  "foo()bar()")
  define_snippet(1   6  "  foo")
  define_snippet(1   5  "foo(\"bar")
  define_snippet(1   1  "\"bar\"")

  foreach(i RANGE 1 ${snippets_count})
    set(code "${snippet_${i}}")

    assert_cmake_cannot_parse("${code}")

    cme_tokenize("${code}" tokens_${i})

    cme_assert("tokens_${i}_parse_error")
    cme_assert("tokens_${i}_parse_error_line EQUAL ${snippet_${i}_line}")
    cme_assert("tokens_${i}_parse_error_column EQUAL ${snippet_${i}_column}")
  endforeach()

endfunction()


function(test_tokenize_newlines)

  set(code "\n\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 2]])
  assert_token_equals(tokens_1  1  1  "Token_Newline"  "\n")
  assert_token_equals(tokens_2  2  1  "Token_Newline"  "\n")

endfunction()


function(test_tokenize_nullary_command_invocation)

  set(code "endfunction()\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"  "endfunction")
  assert_token_equals(tokens_2  1  12  "Token_LeftParen"   "(")
  assert_token_equals(tokens_3  1  13  "Token_RightParen"  ")")
  assert_token_equals(tokens_4  1  14  "Token_Newline"     "\n")

endfunction()


function(test_tokenize_indented_nullary_command_invocation)

  set(code "  cme_test_main()\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 5]])
  assert_token_equals(tokens_1  1   1  "Token_Spaces"      "  ")
  assert_token_equals(tokens_2  1   3  "Token_Identifier"  "cme_test_main")
  assert_token_equals(tokens_3  1  16  "Token_LeftParen"   "(")
  assert_token_equals(tokens_4  1  17  "Token_RightParen"  ")")
  assert_token_equals(tokens_5  1  18  "Token_Newline"     "\n")

endfunction()


function(test_tokenize_quoted_arguments)

  set(code "  assert_cmake_can_parse(\"\${code}\")\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 6]])
  assert_token_equals(tokens_1  1   1  "Token_Spaces"          "  ")
  assert_token_equals(tokens_2  1   3  "Token_Identifier"      "assert_cmake_can_parse")
  assert_token_equals(tokens_3  1  25  "Token_LeftParen"       "(")
  assert_token_equals(tokens_4  1  26  "Token_QuotedArgument"  "\"\${code}\"")
  assert_token_equals(tokens_5  1  35  "Token_RightParen"      ")")
  assert_token_equals(tokens_6  1  36  "Token_Newline"         "\n")

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  cme_test_main()
endif()
