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

function(main)

  message(STATUS "Running all tests in ${CMAKE_CURRENT_LIST_DIR}")

  file(GLOB_RECURSE all_test_files "${CMAKE_CURRENT_LIST_DIR}/test_*.cmake")
  set(failed_test_files 0)

  foreach(test_file ${all_test_files})
    execute_process(
      COMMAND
        "${CMAKE_COMMAND}"
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        "-P" "${test_file}"
      RESULT_VARIABLE process_result
    )

    if(process_result EQUAL 0)
      message(STATUS "[PASSED] ${test_file}")
    else()
      message(STATUS "[FAILED] ${test_file}")
      math(EXPR failed_test_files "${failed_test_files} + 1")
    endif()
  endforeach()

  list(LENGTH all_test_files all_test_files_length)
  message(STATUS "Ran ${all_test_files_length} test files")

  if(NOT failed_test_files EQUAL 0)
    message(FATAL_ERROR "Some test files failed to run")
  endif()

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  main()
endif()
