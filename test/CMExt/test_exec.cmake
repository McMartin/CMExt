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


function(test_exec_return)

  cme_exec("return()")

  message(FATAL_ERROR "Don't execute me!")

endfunction()


function(test_exec_set_variable)

  unset(foo)

  cme_exec("set(foo 42)")

  cme_assert([[foo EQUAL 42]])

endfunction()


function(test_exec_unset_variable)

  set(foo 42)

  cme_exec("unset(foo)")

  cme_assert([[NOT DEFINED foo]])

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  test_exec_return()
  test_exec_set_variable()
  test_exec_unset_variable()
endif()
