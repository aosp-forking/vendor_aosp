#
# Copyright (C) 2010 The Android Open Source Project
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Makefile for producing kraken sdk coverage reports.
# Run "make custom-sdk-test-coverage" in the $ANDROID_BUILD_TOP directory.

custom_sdk_api_coverage_exe := $(HOST_OUT_EXECUTABLES)/custom-sdk-api-coverage
dexdeps_exe := $(HOST_OUT_EXECUTABLES)/dexdeps

coverage_out := $(HOST_OUT)/custom-sdk-api-coverage

api_text_description := custom-sdk/api/custom_current.txt
api_xml_description := $(coverage_out)/api.xml
$(api_xml_description) : $(api_text_description) $(APICHECK)
	$(hide) echo "Converting API file to XML: $@"
	$(hide) mkdir -p $(dir $@)
	$(hide) $(APICHECK_COMMAND) -convert2xml $< $@

custom-sdk-test-coverage-report := $(coverage_out)/custom-sdk-test-coverage.html

custom_sdk_tests_apk := $(call intermediates-dir-for,APPS,CustomPlatformTests)/package.apk
customsettingsprovider_tests_apk := $(call intermediates-dir-for,APPS,CustomSettingsProviderTests)/package.apk
custom_sdk_api_coverage_dependencies := $(custom_sdk_api_coverage_exe) $(dexdeps_exe) $(api_xml_description)

$(custom-sdk-test-coverage-report): PRIVATE_TEST_CASES := $(custom_sdk_tests_apk) $(customsettingsprovider_tests_apk)
$(custom-sdk-test-coverage-report): PRIVATE_CUSTOM_SDK_API_COVERAGE_EXE := $(custom_sdk_api_coverage_exe)
$(custom-sdk-test-coverage-report): PRIVATE_DEXDEPS_EXE := $(dexdeps_exe)
$(custom-sdk-test-coverage-report): PRIVATE_API_XML_DESC := $(api_xml_description)
$(custom-sdk-test-coverage-report): $(custom_sdk_tests_apk) $(customsettingsprovider_tests_apk) $(custom_sdk_api_coverage_dependencies) | $(ACP)
	$(call generate-custom-coverage-report,"LINEAGE-SDK API Coverage Report",\
			$(PRIVATE_TEST_CASES),html)

.PHONY: custom-sdk-test-coverage
custom-sdk-test-coverage : $(custom-sdk-test-coverage-report)

# Put the test coverage report in the dist dir if "custom-sdk" is among the build goals.
ifneq ($(filter custom-sdk, $(MAKECMDGOALS)),)
  $(call dist-for-goals, custom-sdk, $(custom-sdk-test-coverage-report):custom-sdk-test-coverage-report.html)
endif

# Arguments;
#  1 - Name of the report printed out on the screen
#  2 - List of apk files that will be scanned to generate the report
#  3 - Format of the report
define generate-custom-coverage-report
	$(hide) mkdir -p $(dir $@)
	$(hide) $(PRIVATE_CUSTOM_SDK_API_COVERAGE_EXE) -d $(PRIVATE_DEXDEPS_EXE) -a $(PRIVATE_API_XML_DESC) -f $(3) -o $@ $(2) -cm
	@ echo $(1): file://$@
endef

# Reset temp vars
custom_sdk_api_coverage_dependencies :=
custom-sdk-combined-coverage-report :=
custom-sdk-combined-xml-coverage-report :=
custom-sdk-verifier-coverage-report :=
custom-sdk-test-coverage-report :=
api_xml_description :=
api_text_description :=
coverage_out :=
dexdeps_exe :=
custom_sdk_api_coverage_exe :=
custom_sdk_verifier_apk :=
android_custom_sdk_zip :=
