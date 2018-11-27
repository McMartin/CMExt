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
  cme_assert([[DEFINED tokens_syntax_error AND NOT tokens_syntax_error]])

endfunction()


function(test_tokenize_parse_error)

  # Error on expected '\n'
  assert_parse_error(1   1  "|foo|")
  assert_parse_error(2   1  "\n|foo|")
  assert_parse_error(1   6  "foo()bar()")
  assert_parse_error(1   8  "foo()\t bar()")
  assert_parse_error(1   1  "42foo()")
  assert_parse_error(1   1  "\"bar\"")
  assert_parse_error(1   1  "[[bar]]")

  # Error on expected '('
  assert_parse_error(1   4  "foo")
  assert_parse_error(1   6  "foo\t ")
  assert_parse_error(1   6  "\t foo")

  # Error on expected ')'
  assert_parse_error(1   5  "foo(")
  assert_parse_error(1   7  "foo\t (")
  assert_parse_error(2   1  "foo(\n")
  assert_parse_error(1   7  "foo(\t ")
  assert_parse_error(1   6  "foo((")
  assert_parse_error(1  10  "foo(bar()")
  assert_parse_error(1  13  "foo(#[[bar]]")
  assert_parse_error(2   3  "foo([[bar\n]]")
  assert_parse_error(1  10  "foo(bar#)")
  assert_parse_error(2   2  "foo(\"bar\n\"")
  assert_parse_error(1   8  "foo(bar")
  assert_parse_error(1  10  "foo(bar\\)")
  assert_parse_error(1   5  "foo(\\\n)")
  assert_parse_error(1   8  "foo(bar\\\n)")
  assert_parse_error(1   8  "foo(bar\\\nbaz)")

  # Error on expected ']=*]'
  assert_parse_error(1   5  "foo([==[bar")
  assert_parse_error(1   5  "foo([[bar\n")
  assert_parse_error(1   5  "foo(#[==[bar")
  assert_parse_error(1   5  "foo(#[=[bar\n")
  assert_parse_error(1   1  "#[=[foo")
  assert_parse_error(1   1  "#[[foo\n")

  # Error on expected '"'
  assert_parse_error(1   5  "foo(\"bar")
  assert_parse_error(1   5  "foo(\"bar\n")
  assert_parse_error(1   8  "foo(bar\")")

endfunction()


function(test_tokenize_newlines)

  set(code "\n\nfoo(\nbar\nbaz)\n#\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 12]])
  assert_token_equals(tokens_1   1  1  "Token_Newline"  "\n")
  assert_token_equals(tokens_2   2  1  "Token_Newline"  "\n")
  assert_token_equals(tokens_5   3  5  "Token_Newline"  "\n")
  assert_token_equals(tokens_7   4  4  "Token_Newline"  "\n")
  assert_token_equals(tokens_10  5  5  "Token_Newline"  "\n")
  assert_token_equals(tokens_12  6  2  "Token_Newline"  "\n")

endfunction()


function(test_tokenize_spaces)

  set(code " \tfoo\t (\t ) \t#[[]] \t# foo \t\n \t")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 12]])
  assert_token_equals(tokens_1   1   1  "Token_Spaces"  " \t")
  assert_token_equals(tokens_3   1   6  "Token_Spaces"  "\t ")
  assert_token_equals(tokens_5   1   9  "Token_Spaces"  "\t ")
  assert_token_equals(tokens_7   1  12  "Token_Spaces"  " \t")
  assert_token_equals(tokens_9   1  19  "Token_Spaces"  " \t")
  assert_token_equals(tokens_12  2   1  "Token_Spaces"  " \t")

endfunction()


function(test_tokenize_identifiers)

  set(code "Foo42()\n_23bAr()\nba_Z()\n_()\n_87()\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
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
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 3]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"  "PARENT_SCOPE")
  assert_token_equals(tokens_2  1  13  "Token_LeftParen"   "(")
  assert_token_equals(tokens_3  1  14  "Token_RightParen"  ")")

endfunction()


function(test_tokenize_nullary_command_invocation)

  set(code "foo()\n")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Identifier"  "foo")
  assert_token_equals(tokens_2  1  4  "Token_LeftParen"   "(")
  assert_token_equals(tokens_3  1  5  "Token_RightParen"  ")")
  assert_token_equals(tokens_4  1  6  "Token_Newline"     "\n")

endfunction()


function(test_tokenize_parens)

  set(code "foo(() ( ()))")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 11]])
  assert_token_equals(tokens_2   1   4  "Token_LeftParen"   "(")
  assert_token_equals(tokens_3   1   5  "Token_LeftParen"   "(")
  assert_token_equals(tokens_4   1   6  "Token_RightParen"  ")")
  assert_token_equals(tokens_6   1   8  "Token_LeftParen"   "(")
  assert_token_equals(tokens_8   1  10  "Token_LeftParen"   "(")
  assert_token_equals(tokens_9   1  11  "Token_RightParen"  ")")
  assert_token_equals(tokens_10  1  12  "Token_RightParen"  ")")
  assert_token_equals(tokens_11  1  13  "Token_RightParen"  ")")

endfunction()


function(test_tokenize_bracket_argument)

  set(code "foo([[\nbar\n]])")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Identifier"       "foo")
  assert_token_equals(tokens_2  1  4  "Token_LeftParen"        "(")
  assert_token_equals(tokens_3  1  5  "Token_BracketArgument"  "[[\nbar\n]]")
  assert_token_equals(tokens_4  3  3  "Token_RightParen"       ")")

endfunction()


function(test_tokenize_bracket_comment_in_arguments)

  set(code "foo(#[==[\nbar]==])")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Identifier"      "foo")
  assert_token_equals(tokens_2  1  4  "Token_LeftParen"       "(")
  assert_token_equals(tokens_3  1  5  "Token_BracketComment"  "#[==[\nbar]==]")
  assert_token_equals(tokens_4  2  8  "Token_RightParen"      ")")

endfunction()


function(test_tokenize_line_comment_in_arguments)

  set(code "foo(# [==[bar]==] \n)")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 5]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"   "foo")
  assert_token_equals(tokens_2  1   4  "Token_LeftParen"    "(")
  assert_token_equals(tokens_3  1   5  "Token_LineComment"  "# [==[bar]==] ")
  assert_token_equals(tokens_4  1  19  "Token_Newline"      "\n")
  assert_token_equals(tokens_5  2   1  "Token_RightParen"   ")")

endfunction()


function(test_tokenize_quoted_argument)

  set(code "foo(\"bar\n\")")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_Identifier"      "foo")
  assert_token_equals(tokens_2  1  4  "Token_LeftParen"       "(")
  assert_token_equals(tokens_3  1  5  "Token_QuotedArgument"  "\"bar\n\"")
  assert_token_equals(tokens_4  2  2  "Token_RightParen"      ")")

endfunction()


function(test_tokenize_unquoted_argument)

  set(code "foo(bar)")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
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
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 6]])
  assert_token_equals(tokens_1  1   1  "Token_Identifier"        "unset")
  assert_token_equals(tokens_2  1   6  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3  1   7  "Token_UnquotedArgument"  "foo")
  assert_token_equals(tokens_4  1  10  "Token_Spaces"            " ")
  assert_token_equals(tokens_5  1  11  "Token_UnquotedArgument"  "PARENT_SCOPE")
  assert_token_equals(tokens_6  1  23  "Token_RightParen"        ")")

endfunction()


function(test_tokenize_escape_sequences)

  set(code "foo(\\A\\a\\0\\ \\t\\r\\n\\;\\$\\{\\}\\@\\\\)")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(
    tokens_3  1  5  "Token_UnquotedArgument"  "\\A\\a\\0\\ \\t\\r\\n\\;\\$\\{\\}\\@\\\\"
  )

endfunction()


function(test_tokenize_several_arguments)

  set(code "set(foo (\"bar\" [=[baz]=]))")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 10]])
  assert_token_equals(tokens_1   1   1  "Token_Identifier"        "set")
  assert_token_equals(tokens_2   1   4  "Token_LeftParen"         "(")
  assert_token_equals(tokens_3   1   5  "Token_UnquotedArgument"  "foo")
  assert_token_equals(tokens_4   1   8  "Token_Spaces"            " ")
  assert_token_equals(tokens_5   1   9  "Token_LeftParen"         "(")
  assert_token_equals(tokens_6   1  10  "Token_QuotedArgument"    "\"bar\"")
  assert_token_equals(tokens_7   1  15  "Token_Spaces"            " ")
  assert_token_equals(tokens_8   1  16  "Token_BracketArgument"   "[=[baz]=]")
  assert_token_equals(tokens_9   1  25  "Token_RightParen"        ")")
  assert_token_equals(tokens_10  1  26  "Token_RightParen"        ")")

endfunction()


function(test_tokenize_non_separated_arguments)

  assert_no_tokenize_errors(7  "foo(()())")
  assert_no_tokenize_errors(6  "foo(()#[[baz]])")
  assert_syntax_error(1   7    "foo(()[[baz]])")
  assert_no_tokenize_errors(6  "foo(()\"baz\")")
  assert_no_tokenize_errors(6  "foo(()baz)")

  assert_no_tokenize_errors(6  "foo(#[[bar]]())")
  assert_no_tokenize_errors(5  "foo(#[[bar]]#[[baz]])")
  assert_syntax_error(1  13    "foo(#[[bar]][[baz]])")
  assert_syntax_error(1  13    "foo(#[[bar]]\"baz\")")
  assert_syntax_error(1  13    "foo(#[[bar]]baz)")

  assert_no_tokenize_errors(6  "foo([[bar]]())")
  assert_no_tokenize_errors(5  "foo([[bar]]#[[baz]])")
  assert_syntax_error(1  12    "foo([[bar]][[baz]])")
  assert_syntax_error(1  12    "foo([[bar]]\"baz\")")
  assert_syntax_error(1  12    "foo([[bar]]baz)")

  assert_no_tokenize_errors(6  "foo(\"bar\"())")
  assert_no_tokenize_errors(5  "foo(\"bar\"#[[baz]])")
  assert_syntax_error(1  10    "foo(\"bar\"[[baz]])")
  assert_no_tokenize_errors(5  "foo(\"bar\"\"baz\")")
  assert_no_tokenize_errors(5  "foo(\"bar\"baz)")

  assert_no_tokenize_errors(6  "foo(bar())")
  assert_no_tokenize_errors(5  "foo(bar#[[baz]])")
  assert_no_tokenize_errors(4  "foo(bar[[baz]])")
  assert_no_tokenize_errors(5  "foo(bar\"baz\")")
  assert_no_tokenize_errors(4  "foo(barbaz)")

endfunction()


function(test_tokenize_standalone_bracket_comments)

  set(code "#[[foo]]#[=[bar\n]=] #[==[baz]==]")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 4]])
  assert_token_equals(tokens_1  1  1  "Token_BracketComment"  "#[[foo]]")
  assert_token_equals(tokens_2  1  9  "Token_BracketComment"  "#[=[bar\n]=]")
  assert_token_equals(tokens_3  2  4  "Token_Spaces"          " ")
  assert_token_equals(tokens_4  2  5  "Token_BracketComment"  "#[==[baz]==]")

endfunction()


function(test_tokenize_interleaved_brackets)

  set(code "foo(#[=[b\na[[r]=]\n[==[ba]]z]==])")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 6]])
  assert_token_equals(tokens_3  1  5  "Token_BracketComment"   "#[=[b\na[[r]=]")
  assert_token_equals(tokens_5  3  1  "Token_BracketArgument"  "[==[ba]]z]==]")

endfunction()


function(test_tokenize_line_comments)

  set(code "# foo\nbar(\n) # baz")

  cme_tokenize("${code}" tokens)

  assert_cmake_can_parse("${code}")
  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])
  cme_assert([[tokens_count EQUAL 8]])
  assert_token_equals(tokens_1  1  1  "Token_LineComment"  "# foo")
  assert_token_equals(tokens_8  3  3  "Token_LineComment"  "# baz")

endfunction()


function(test_tokenize_cme_tokenize_itself)

  file(READ "${CMAKE_CURRENT_LIST_DIR}/../../Modules/CMExt.Tokenize.cmake" file_content)

  cme_tokenize("${file_content}" tokens)

  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])

endfunction()


function(test_tokenize_this_file)

  file(READ "${CMAKE_CURRENT_LIST_FILE}" this_file_content)

  cme_tokenize("${this_file_content}" tokens)

  cme_assert([[NOT tokens_parse_error AND NOT tokens_syntax_error]])

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  cme_test_main()
endif()
