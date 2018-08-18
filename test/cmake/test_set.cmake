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


function(test_set_value_from_undefined)

  set(foo)
  cme_assert([[NOT DEFINED foo]])

  set(bar ${foo})
  cme_assert([[NOT DEFINED bar]])

  set(baz "${foo}")
  cme_assert([[DEFINED baz AND baz STREQUAL ""]])

endfunction()


function(test_set_value_from_an_empty_string)

  set(foo "")
  cme_assert([[DEFINED foo AND foo STREQUAL ""]])

  set(bar ${foo})
  cme_assert([[NOT DEFINED bar]])

  set(baz "${foo}")
  cme_assert([[DEFINED baz AND baz STREQUAL ""]])

endfunction()


function(test_set_value_from_two_empty_strings)

  set(foo "" "")
  cme_assert([[DEFINED foo AND foo STREQUAL "\;"]])

  set(bar ${foo})
  cme_assert([[NOT DEFINED bar]])

  set(baz "${foo}")
  cme_assert([[DEFINED baz AND baz STREQUAL "\;"]])

endfunction()


function(test_set_value_from_list_with_empty_items)

  set(foo "a" "" "b" "")
  cme_assert([[DEFINED foo AND foo STREQUAL "a\;\;b\;"]])

  set(bar ${foo})
  cme_assert([[DEFINED bar AND bar STREQUAL "a\;b"]])

  set(baz "${foo}")
  cme_assert([[DEFINED baz AND baz STREQUAL "a\;\;b\;"]])

endfunction()


if(CMAKE_SCRIPT_MODE_FILE STREQUAL CMAKE_CURRENT_LIST_FILE)
  test_set_value_from_undefined()
  test_set_value_from_an_empty_string()
  test_set_value_from_two_empty_strings()
  test_set_value_from_list_with_empty_items()
endif()
