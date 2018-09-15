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

  set(count 0)
  set(line 1)
  set(column 1)

  macro(_cme_tokenize_parse_error)
    set(${out_namespace}_parse_error TRUE PARENT_SCOPE)
    set(${out_namespace}_parse_error_line "${line}" PARENT_SCOPE)
    set(${out_namespace}_parse_error_column "${column}" PARENT_SCOPE)
    return()
  endmacro()

  while(NOT cmake_code STREQUAL "")
    _cme_tokenize_parse_error()
  endwhile()

  set(${out_namespace}_count ${count} PARENT_SCOPE)
  set(${out_namespace}_parse_error FALSE PARENT_SCOPE)

endfunction()
