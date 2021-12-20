using PSOpenAD.Native;
using System;
using System.Collections.Generic;

namespace PSOpenAD
{
    public sealed class OpenADSession
    {
        public Uri Uri { get; }

        public AuthenticationMethod Authentication { get; }

        public bool IsSigned { get; }

        public bool IsEncrypted { get; }

        public string DefaultNamingContext { get; internal set; }

        public bool IsClosed { get; internal set; } = false;

        internal SafeLdapHandle Handle { get; }

        internal Dictionary<string, AttributeTypes> AttributeTypes { get; } = new Dictionary<string, AttributeTypes>();

        internal OpenADSession(SafeLdapHandle ldap, Uri uri, AuthenticationMethod auth, bool isSigned, bool isEncrypted,
            string defaultNamingContext)
        {
            Handle = ldap;
            Uri = uri;
            Authentication = auth;
            IsSigned = isSigned;
            IsEncrypted = isEncrypted;
            DefaultNamingContext = defaultNamingContext;
        }
    }
}
