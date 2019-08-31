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

if(_CMExt.Test.cmake_included)
  return()
endif()
set(_CMExt.Test.cmake_included TRUE)


if(CMAKE_VERSION VERSION_LESS 3.3)
  message(FATAL_ERROR "CMExt.Test requires at least CMake version 3.3")
endif()


include("${CMAKE_CURRENT_LIST_DIR}/CMExt.cmake")


function(cme_test_main)

  cmake_policy(SET CMP0057 NEW) # Support new if() IN_LIST operator.

  get_cmake_property(all_commands COMMANDS)
  get_cmake_property(all_macros MACROS)

  set(tests "")
  foreach(command ${all_commands})
    if(command MATCHES "^test_")
      if(NOT command IN_LIST all_macros)
        list(APPEND tests "${command}")
      endif()
    endif()
  endforeach()

  foreach(test ${tests})
    cme_exec("${test}()")
  endforeach()

endfunction()
