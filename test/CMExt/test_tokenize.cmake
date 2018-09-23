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
  assert_cme_tokenize_limitation(1   5  "foo(\n)")
  assert_cme_tokenize_limitation(1   5  "foo(\t)")
  assert_cme_tokenize_limitation(1   5  "foo(#\n)")
  assert_cme_tokenize_limitation(1   5  "foo(())")
  assert_cme_tokenize_limitation(1   9  "foo([=[)]=])")
  assert_cme_tokenize_limitation(1  10  "foo([==[)]==])")
  assert_cme_tokenize_limitation(1   5  "foo(#[[)]])")
  assert_cme_tokenize_limitation(1   5  "foo(#[=[)]=])")
  assert_cme_tokenize_limitation(1   5  "foo(#[==[)]==])")
  assert_cme_tokenize_limitation(2   1  "#[[\n]]")
  assert_cme_tokenize_limitation(2   1  "#[=[\n]=]")
  assert_cme_tokenize_limitation(2   1  "#[==[\n]==]")

endfunction()


function(test_tokenize_parse_error)

  # Error on expected '\n'
  assert_parse_error(1   1  "|foo|")
  assert_parse_error(2   1  "\n|foo|")
  assert_parse_error(1   6  "foo()bar()")
  assert_parse_error(1   1  "42foo()")
  assert_parse_error(1   1  "\"bar\"")
  assert_parse_error(1   1  "[[bar]]")

  # Error on expected '('
  assert_parse_error(1   4  "foo")
  assert_parse_error(1   6  "  foo")

  # Error on expected ')'
  assert_parse_error(1   5  "foo(")
  assert_parse_error(1   8  "foo(bar")
  assert_parse_error(1   8  "foo(bar()")
  assert_parse_error(1   8  "foo(bar#)")
  assert_parse_error(1   8  "foo(bar\\)")

  # Error on expected ']]'
  assert_parse_error(1   5  "foo([[bar")

  # Error on expected '"'
  assert_parse_error(1   5  "foo(\"bar")
  assert_parse_error(1   8  "foo(bar\")")

endfunction()


function(test_tokenize_newlines)

  set(code "\n\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 2]])
  assert_token_equals(tokens_1  1  1  "Token_Newline"  "\n")
  assert_token_equals(tokens_2  2  1  "Token_Newline"  "\n")

endfunction()


function(test_tokenize_identifiers)

  set(code "Foo42()\n_23bAr()\nba_Z()\n_()\n_87()\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 20]])
  assert_token_equals(tokens_1   1  1  "Token_Identifier"  "Foo42")
  assert_token_equals(tokens_5   2  1  "Token_Identifier"  "_23bAr")
  assert_token_equals(tokens_9   3  1  "Token_Identifier"  "ba_Z")
  assert_token_equals(tokens_13  4  1  "Token_Identifier"  "_")
  assert_token_equals(tokens_17  5  1  "Token_Identifier"  "_87")

endfunction()


function(test_tokenize_PARENT_SCOPE_identifier)

  set(code "PARENT_SCOPE()")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_parse_error]])

endfunction()


function(test_tokenize_nullary_command_invocation)

  set(code "foo()\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Identifier"  "foo")
  assert_token_equals(tokens_2  1  4  "Token_LeftParen"   "(")
  assert_token_equals(tokens_3  1  5  "Token_RightParen"  ")")
  assert_token_equals(tokens_4  1  6  "Token_Newline"     "\n")

endfunction()


function(test_tokenize_indented_nullary_command_invocation)

  set(code "  foo()")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Spaces"      "  ")
  assert_token_equals(tokens_2  1  3  "Token_Identifier"  "foo")
  assert_token_equals(tokens_3  1  6  "Token_LeftParen"   "(")
  assert_token_equals(tokens_4  1  7  "Token_RightParen"  ")")

endfunction()


function(test_tokenize_bracket_argument)

  set(code "foo([[bar]])")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"       "foo")
  assert_token_equals(tokens_2  1   4  "Token_LeftParen"        "(")
  assert_token_equals(tokens_3  1   5  "Token_BracketArgument"  "[[bar]]")
  assert_token_equals(tokens_4  1  12  "Token_RightParen"       ")")

endfunction()


function(test_tokenize_quoted_argument)

  set(code "foo(\"bar\")")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"      "foo")
  assert_token_equals(tokens_2  1   4  "Token_LeftParen"       "(")
  assert_token_equals(tokens_3  1   5  "Token_QuotedArgument"  "\"bar\"")
  assert_token_equals(tokens_4  1  10  "Token_RightParen"      ")")

endfunction()


function(test_tokenize_unquoted_argument)

  set(code "foo(bar)")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Identifier"        "foo")
  assert_token_equals(tokens_2  1  4  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3  1  5  "Token_UnquotedArgument"  "bar")
  assert_token_equals(tokens_4  1  8  "Token_RightParen"        ")")

endfunction()


function(test_tokenize_PARENT_SCOPE_unquoted_argument)

  set(code "unset(foo PARENT_SCOPE)")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 6]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"        "unset")
  assert_token_equals(tokens_2  1   6  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3  1   7  "Token_UnquotedArgument"  "foo")
  assert_token_equals(tokens_4  1  10  "Token_Spaces"            " ")
  assert_token_equals(tokens_5  1  11  "Token_UnquotedArgument"  "PARENT_SCOPE")
  assert_token_equals(tokens_6  1  23  "Token_RightParen"        ")")

endfunction()


function(test_tokenize_several_arguments)

  set(code "set(foo \"bar\" [[baz]])")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 8]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"        "set")
  assert_token_equals(tokens_2  1   4  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3  1   5  "Token_UnquotedArgument"  "foo")
  assert_token_equals(tokens_4  1   8  "Token_Spaces"            " ")
  assert_token_equals(tokens_5  1   9  "Token_QuotedArgument"    "\"bar\"")
  assert_token_equals(tokens_6  1  14  "Token_Spaces"            " ")
  assert_token_equals(tokens_7  1  15  "Token_BracketArgument"   "[[baz]]")
  assert_token_equals(tokens_8  1  22  "Token_RightParen"        ")")

endfunction()


function(test_tokenize_line_comment)

  set(code "# foo\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[tokens_count EQUAL 2]])
  assert_token_equals(tokens_1  1  1  "Token_LineComment"  "# foo")
  assert_token_equals(tokens_2  1  6  "Token_Newline"      "\n")

endfunction()


function(test_tokenize_cme_tokenize_itself)

  file(READ "${CMAKE_CURRENT_LIST_DIR}/../../Modules/CMExt.Tokenize.cmake" file_content)

  cme_tokenize("${file_content}" tokens)

  cme_assert([[NOT tokens_parse_error]])

endfunction()


function(test_tokenize_this_file)

  file(READ "${CMAKE_CURRENT_LIST_FILE}" this_file_content)

  cme_tokenize("${this_file_content}" tokens)

  cme_assert([[NOT tokens_parse_error]])

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  cme_test_main()
endif()
