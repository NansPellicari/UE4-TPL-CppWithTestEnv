// Copyright 2020-present Nans Pellicari (nans.pellicari@gmail.com).
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS
BEGIN_DEFINE_SPEC(SimpleSpec,
    "MyProject.Simple",
    EAutomationTestFlags::ProductFilter | EAutomationTestFlags::ApplicationContextMask)
END_DEFINE_SPEC(SimpleSpec)
void SimpleSpec::Define()
{
    Describe("A Spec", [this]() {

        It("should spec with true", [this]() {
            TestTrue("a true assert", true);
        });
        It("should spec with false", [this]() {
            TestFalse("a false assert", false);
        });

    });
}

#endif    // WITH_DEV_AUTOMATION_TESTS
