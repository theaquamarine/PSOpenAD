using System.Management.Automation;

namespace PSOpenAD.Commands;

[Cmdlet(
    VerbsCommon.Get, "AuthSupport"
)]
[OutputType(typeof(AuthenticationProvider))]
public class GetOpenADAuthSupport : PSCmdlet
{
    protected override void EndProcessing()
    {
        foreach (AuthenticationProvider provider in GlobalState.Providers.Values)
            WriteObject(provider);
    }
}
