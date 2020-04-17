#include "Misc/AutomationTest.h"

#if WITH_DEV_AUTOMATION_TESTS
BEGIN_DEFINE_SPEC(SimpleSpec,
    "MyProject.Simple",
    EAutomationTestFlags::ProductFilter | EAutomationTestFlags::ApplicationContextMask)
END_DEFINE_SPEC(SimpleSpec)
void SimpleSpec::Define()
{
    Describe("A Spec", [this]() {

        It("should spec", [this]() {
            TestTrue("a true assert", true);
        });

    });
}

#endif    // WITH_DEV_AUTOMATION_TESTS
