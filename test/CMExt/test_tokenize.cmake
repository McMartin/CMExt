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


function(test_tokenize_limitations)

  assert_cme_tokenize_limitation(1   1  "\tfoo()")
  assert_cme_tokenize_limitation(1   4  "foo ()")
  assert_cme_tokenize_limitation(1   4  "foo\t()")
  assert_cme_tokenize_limitation(1   6  "foo() ")
  assert_cme_tokenize_limitation(1   6  "foo()\t")
  assert_cme_tokenize_limitation(1   5  "foo(\\;)")
  assert_cme_tokenize_limitation(1   5  "foo(#\n)")
  assert_cme_tokenize_limitation(1   5  "foo(())")
  assert_cme_tokenize_limitation(1   8  "foo([[)]])")
  assert_cme_tokenize_limitation(1   5  "foo(#[[)]])")

endfunction()


function(test_tokenize_parse_error)

  assert_parse_error(1   1  "|This is not CMake code|")
  assert_parse_error(2   1  "\n|What?|")
  assert_parse_error(1   4  "foo")
  assert_parse_error(1   5  "foo(")
  assert_parse_error(1   6  "foo()bar()")
  assert_parse_error(1   6  "  foo")
  assert_parse_error(1   5  "foo(\"bar")
  assert_parse_error(1   1  "\"bar\"")
  assert_parse_error(1   8  "foo(bar")
  assert_parse_error(1   8  "foo(bar()")
  assert_parse_error(1   8  "foo(bar#)")
  assert_parse_error(1   8  "foo(bar\")")
  assert_parse_error(1   8  "foo(bar\\)")
  assert_parse_error(1  12  "foo(bar baz")
  assert_parse_error(1   4  "bar baz")

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


function(test_tokenize_nullary_command_invocation_bug)

  set(code "return(\n\t\n)")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"        "return")
  assert_token_equals(tokens_2  1   7  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3  1   8  "Token_UnquotedArgument"  "\n\t\n")
  assert_token_equals(tokens_4  1  11  "Token_RightParen"        ")")

endfunction()


function(test_tokenize_quoted_argument)

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


function(test_tokenize_unquoted_argument)

  set(code "include(CMExt)\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 5]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"        "include")
  assert_token_equals(tokens_2  1   8  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3  1   9  "Token_UnquotedArgument"  "CMExt")
  assert_token_equals(tokens_4  1  14  "Token_RightParen"        ")")
  assert_token_equals(tokens_5  1  15  "Token_Newline"           "\n")

endfunction()


function(test_tokenize_several_arguments)

  set(code "  set(code \"function\")\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 8]])
  assert_token_equals(tokens_1  1   1  "Token_Spaces"            "  ")
  assert_token_equals(tokens_2  1   3  "Token_Identifier"        "set")
  assert_token_equals(tokens_3  1   6  "Token_LeftParen"         "(")
  assert_token_equals(tokens_4  1   7  "Token_UnquotedArgument"  "code")
  assert_token_equals(tokens_5  1  11  "Token_Spaces"            " ")
  assert_token_equals(tokens_6  1  12  "Token_QuotedArgument"    "\"function\"")
  assert_token_equals(tokens_7  1  22  "Token_RightParen"        ")")
  assert_token_equals(tokens_8  1  23  "Token_Newline"           "\n")

endfunction()


function(test_tokenize_line_comment)

  set(code "# This file is part of CMExt.\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 2]])
  assert_token_equals(tokens_1 1  1 "Token_LineComment" "# This file is part of CMExt.")
  assert_token_equals(tokens_2 1 30 "Token_Newline"     "\n")

endfunction()


function(test_tokenize_cme_tokenize_itself)

  file(READ "${CMAKE_CURRENT_LIST_DIR}/../../Modules/CMExt.Tokenize.cmake" file_content)

  cme_tokenize("${file_content}" tokens)

  cme_assert([[NOT tokens_parse_error]])

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  cme_test_main()
endif()
