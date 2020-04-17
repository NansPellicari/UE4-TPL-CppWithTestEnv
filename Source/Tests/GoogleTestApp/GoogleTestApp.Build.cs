namespace UnrealBuildTool.Rules
{
    public class GoogleTestApp : ModuleRules
    {
        public GoogleTestApp(ReadOnlyTargetRules Target) : base(Target)
        {
            bEnableExceptions = true;
            PrivateDependencyModuleNames.AddRange(
                new string[]
                {
                    "Core",
                    "GoogleTest"
                }
            );
            PrivatePCHHeaderFile = "Private/GoogleTestApp.h";
        }
    }
}
