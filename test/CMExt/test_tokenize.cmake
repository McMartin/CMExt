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

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  cme_test_main()
endif()
