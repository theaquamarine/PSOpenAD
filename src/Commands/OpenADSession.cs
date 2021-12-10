using System;
using System.Management.Automation;
using System.Threading;
using System.Threading.Tasks;

namespace PSOpenAD.Commands
{
    [Cmdlet(
        VerbsCommon.New, "OpenADSession"
    )]
    public class NewOpenADSession : PSCmdlet
    {
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true
        )]
        [ValidateNotNullOrEmpty]
        [Alias("Server")]
        public string ComputerName { get; set; } = "";

        [Parameter()]
        public PSCredential? Credential { get; set; }

        [Parameter()]
        public AuthenticationMethod AuthenticationMethod { get; set; } = AuthenticationMethod.Simple;

        private CancellationTokenSource? CurrentCancelToken { get; set; }

        protected override void ProcessRecord()
        {
            var ldap = OpenLDAP.Initialize($"ldap://{ComputerName}:389");
            OpenLDAP.SetOption(ldap, LDAPOption.LDAP_OPT_PROTOCOL_VERSION, 3);

            string username = Credential?.UserName ?? "";
            string password = Credential?.GetNetworkCredential().Password ?? "";

            if (AuthenticationMethod == AuthenticationMethod.Simple)
            {
                using (CurrentCancelToken = new CancellationTokenSource())
                {
                    Task bindTask = OpenLDAP.SimpleBindAsync(ldap, username, password, cancelToken: CurrentCancelToken.Token);
                    bindTask.GetAwaiter().GetResult();
                }
            }
            else
            {
                SaslPrompter prompter = new SaslPrompter()
                {
                    UserName = username,
                };
                Task bindTask = OpenLDAP.SaslInteractiveBindAsync(ldap, "", AuthenticationMethod, prompter);
                bindTask.GetAwaiter().GetResult();
            }

            WriteObject(ldap);
        }

        protected override void StopProcessing()
        {
            CurrentCancelToken?.Cancel();
        }
    }

    public enum AuthenticationMethod
    {
        Anonymous,
        Simple,
        Negotiate,
        Kerberos,
    }

    internal class SaslPrompter : SaslInteract
    {
        public string UserName { get; set; } = "";

        public override string GetUser() => UserName;
    }
}
