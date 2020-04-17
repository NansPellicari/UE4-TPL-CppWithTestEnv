using UnrealBuildTool;
using System.Collections.Generic;
using System.IO;
 
public class GoogleTestAppTarget : TargetRules
{
    public GoogleTestAppTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Program;
        DefaultBuildSettings = BuildSettingsVersion.V2;
        LinkType = TargetLinkType.Modular;
        LaunchModuleName = "GoogleTestApp";
 
        bIsBuildingConsoleApplication = true;
    }
}
