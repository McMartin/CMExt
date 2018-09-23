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
    set(text "${CMAKE_MATCH_0}")
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

  macro(_cme_tokenize_consume_bracket_argument)
    string(FIND "${cmake_code}" "]]" bracket_close_pos)
    if(bracket_close_pos EQUAL -1)
      _cme_tokenize_parse_error()
    endif()
    math(EXPR bracket_end "${bracket_close_pos} + 2")
    string(SUBSTRING "${cmake_code}" 0 ${bracket_end} text)
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_BracketArgument)
    math(EXPR column "${column} + ${text_length}")
  endmacro()

  macro(_cme_tokenize_consume_quoted_argument)
    if(NOT cmake_code MATCHES "^\"([\\].|[^\"\\])*\"")
      _cme_tokenize_parse_error()
    endif()
    set(text "${CMAKE_MATCH_0}")
    string(LENGTH "${text}" text_length)
    string(SUBSTRING "${cmake_code}" ${text_length} -1 cmake_code)
    _cme_tokenize_emit_token(Token_QuotedArgument)
    math(EXPR column "${column} + ${text_length}")
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
      if(cmake_code MATCHES "^[ ]+")
        _cme_tokenize_consume_spaces()
      elseif(cmake_code MATCHES "^\\[\\[")
        _cme_tokenize_consume_bracket_argument()
      elseif(cmake_code MATCHES "^\"")
        _cme_tokenize_consume_quoted_argument()
      elseif(cmake_code MATCHES "^[^\n \t()#\"\\]+")
        _cme_tokenize_consume_unquoted_argument()
      else()
        break()
      endif()
    endwhile()
  endmacro()

  macro(_cme_tokenize_consume_command_invocation)
    _cme_tokenize_consume_identifier()

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
    if(cmake_code MATCHES "^[ ]+")
      _cme_tokenize_consume_spaces()
    endif()

    if(cmake_code MATCHES "^[A-Za-z_]+")
      _cme_tokenize_consume_command_invocation()
    endif()

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
