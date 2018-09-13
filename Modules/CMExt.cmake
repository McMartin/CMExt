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

if(_CMExt.cmake_included)
  return()
endif()
set(_CMExt.cmake_included TRUE)


function(cme_assert condition)

  set(result FALSE)
  cme_exec(
    "if(${condition})\n"
    "  set(result TRUE)\n"
    "endif()\n"
  )
  if(NOT result)
    message(FATAL_ERROR "Assertion error: cme_assert(${condition})")
  endif()

endfunction()


set(_cme_exec_tmp_file "${CMAKE_CURRENT_LIST_FILE}.exec.tmp")

macro(cme_exec)

  file(WRITE "${_cme_exec_tmp_file}"
    "macro(_cme_exec_inner_macro)\n"
    ${ARGN}
    "\nendmacro()"
  )
  include("${_cme_exec_tmp_file}")
  _cme_exec_inner_macro()

endmacro()
