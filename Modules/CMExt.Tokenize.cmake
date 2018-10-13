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

if(_CMExt.Tokenize.cmake_included)
  return()
endif()
set(_CMExt.Tokenize.cmake_included TRUE)


function(cme_tokenize cmake_code out_namespace)

  macro(_cme_tokenize_parse_error)
    set(${out_namespace}_count ${count} PARENT_SCOPE)
    set(${out_namespace}_parse_error TRUE PARENT_SCOPE)
    set(${out_namespace}_parse_error_line "${line}" PARENT_SCOPE)
    set(${out_namespace}_parse_error_column "${column}" PARENT_SCOPE)
    return()
  endmacro()

  macro(_cme_tokenize_emit_token type)
    math(EXPR count "${count} + 1")

    set(${out_namespace}_${count}_type "${type}" PARENT_SCOPE)
    set(${out_namespace}_${count}_text "${text}" PARENT_SCOPE)
    set(${out_namespace}_${count}_line "${line}" PARENT_SCOPE)
    set(${out_namespace}_${count}_column "${column}" PARENT_SCOPE)
  endmacro()

  macro(_cme_tokenize_consume_newline)
    set(text "\n")
    string(SUBSTRING "${cmake_code}" 1 -1 cmake_code)
    _cme_tokenize_emit_token(Token_Newline)
    math(EXPR line "${line} + 1")
    set(column 1)
  endmacro()

  macro(_cme_tokenize_consume_spaces)
    set(text "${CMAKE_MATCH_0}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_Spaces)
    math(EXPR column "${column} + ${text_length}")
  endmacro()

  macro(_cme_tokenize_consume_identifier)
    string(CONCAT text "${CMAKE_MATCH_0}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_Identifier)
    math(EXPR column "${column} + ${text_length}")
  endmacro()

  macro(_cme_tokenize_consume_lparen)
    set(text "(")
    string(SUBSTRING "${cmake_code}" 1 -1 cmake_code)
    _cme_tokenize_emit_token(Token_LeftParen)
    math(EXPR column "${column} + 1")
  endmacro()

  macro(_cme_tokenize_consume_rparen)
    set(text ")")
    string(SUBSTRING "${cmake_code}" 1 -1 cmake_code)
    _cme_tokenize_emit_token(Token_RightParen)
    math(EXPR column "${column} + 1")
  endmacro()

  macro(_cme_tokenize_consume_bracket_argument_or_comment)
    string(REGEX REPLACE "[^=]" "" equal_signs_only "${CMAKE_MATCH_0}")
    set(bracket_close "]${equal_signs_only}]")
    string(FIND "${cmake_code}" "${bracket_close}" bracket_close_pos)
    if(bracket_close_pos EQUAL -1)
      _cme_tokenize_parse_error()
    endif()
    string(SUBSTRING "${cmake_code}" 0 ${bracket_close_pos} bracket_open_and_content)
    set(text "${bracket_open_and_content}${bracket_close}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    if(text MATCHES "^#")
      _cme_tokenize_emit_token(Token_BracketComment)
    else()
      _cme_tokenize_emit_token(Token_BracketArgument)
    endif()
    string(FIND "${text}" "\n" last_newline_index REVERSE)
    if(last_newline_index EQUAL -1)
      math(EXPR column "${column} + ${text_length}")
    else()
      math(EXPR column "${text_length} - ${last_newline_index}")
      string(REGEX REPLACE "[^\n]" "" only_newlines "${text}")
      string(LENGTH "${only_newlines}" newlines_count)
      math(EXPR line "${line} + ${newlines_count}")
    endif()
  endmacro()

  macro(_cme_tokenize_consume_quoted_argument)
    if(NOT cmake_code MATCHES "^\"([\\].|[^\"\\])*\"")
      _cme_tokenize_parse_error()
    endif()
    set(text "${CMAKE_MATCH_0}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_QuotedArgument)
    string(FIND "${text}" "\n" last_newline_index REVERSE)
    if(last_newline_index EQUAL -1)
      math(EXPR column "${column} + ${text_length}")
    else()
      math(EXPR column "${text_length} - ${last_newline_index}")
      string(REGEX REPLACE "[^\n]" "" only_newlines "${text}")
      string(LENGTH "${only_newlines}" newlines_count)
      math(EXPR line "${line} + ${newlines_count}")
    endif()
  endmacro()

  macro(_cme_tokenize_consume_unquoted_argument)
    string(CONCAT text "${CMAKE_MATCH_0}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_UnquotedArgument)
    math(EXPR column "${column} + ${text_length}")
  endmacro()

  macro(_cme_tokenize_consume_line_comment)
    set(text "${CMAKE_MATCH_0}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_LineComment)
    math(EXPR column "${column} + ${text_length}")
  endmacro()

  macro(_cme_tokenize_consume_arguments)
    while(1)
      if(cmake_code MATCHES "^\\(")
        _cme_tokenize_consume_lparen()
        _cme_tokenize_consume_arguments()
        if(NOT cmake_code MATCHES "^\\)")
          _cme_tokenize_parse_error()
        endif()
        _cme_tokenize_consume_rparen()
      elseif(cmake_code MATCHES "^\n")
        _cme_tokenize_consume_newline()
      elseif(cmake_code MATCHES "^[ \t]+")
        _cme_tokenize_consume_spaces()
      elseif(cmake_code MATCHES "^#?\\[=*\\[")
        _cme_tokenize_consume_bracket_argument_or_comment()
      elseif(cmake_code MATCHES "^#[^\n]*")
        _cme_tokenize_consume_line_comment()
      elseif(cmake_code MATCHES "^\"")
        _cme_tokenize_consume_quoted_argument()
      elseif(cmake_code MATCHES "^([\\].|[^\n \t()#\"\\])+")
        _cme_tokenize_consume_unquoted_argument()
      else()
        break()
      endif()
    endwhile()
  endmacro()

  macro(_cme_tokenize_consume_command_invocation)
    _cme_tokenize_consume_identifier()

    if(cmake_code MATCHES "^[ \t]+")
      _cme_tokenize_consume_spaces()
    endif()

    if(NOT cmake_code MATCHES "^\\(")
      _cme_tokenize_parse_error()
    endif()
    _cme_tokenize_consume_lparen()

    _cme_tokenize_consume_arguments()

    if(NOT cmake_code MATCHES "^\\)")
      _cme_tokenize_parse_error()
    endif()
    _cme_tokenize_consume_rparen()
  endmacro()

  set(count 0)
  set(line 1)
  set(column 1)

  while(NOT cmake_code STREQUAL "")
    if(cmake_code MATCHES "^[ \t]+")
      _cme_tokenize_consume_spaces()
    endif()

    if(cmake_code MATCHES "^[A-Za-z_][A-Za-z0-9_]*")
      _cme_tokenize_consume_command_invocation()
    endif()

    while(1)
      if(cmake_code MATCHES "^[ \t]+")
        _cme_tokenize_consume_spaces()
      elseif(cmake_code MATCHES "^#\\[=*\\[")
        _cme_tokenize_consume_bracket_argument_or_comment()
      else()
        break()
      endif()
    endwhile()

    if(cmake_code MATCHES "^#[^\n]*")
      _cme_tokenize_consume_line_comment()
    endif()

    if(NOT cmake_code STREQUAL "")
      if(NOT cmake_code MATCHES "^\n")
        _cme_tokenize_parse_error()
      endif()
      _cme_tokenize_consume_newline()
    endif()
  endwhile()

  set(${out_namespace}_count ${count} PARENT_SCOPE)
  set(${out_namespace}_parse_error FALSE PARENT_SCOPE)

endfunction()


function(cme_print_token token)

  set(line "${${token}_line}")

  set(column "${${token}_column}")
  if(column LESS 10)
    set(column "0${column}")
  endif()

  string(REGEX REPLACE "\n" "\\\\n" text "${${token}_text}")

  set(padded_type "${${token}_type}")
  string(LENGTH "${padded_type}" type_length)
  foreach(i RANGE ${type_length} 23)
    string(APPEND padded_type " ")
  endforeach()

  message(STATUS "${line},${column}:  ${padded_type}'${text}'")

endfunction()
