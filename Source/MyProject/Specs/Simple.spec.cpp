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
