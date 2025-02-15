---
external help file: PSOpenAD.dll-Help.xml
Module Name: PSOpenAD
online version:
schema: 2.0.0
---

# Get-OpenADPrincipalGroupMembership

## SYNOPSIS
Get the Active Directory groups that an object belongs to.

## SYNTAX

### ServerIdentity (Default)
```
Get-OpenADPrincipalGroupMembership [-Recursive] [-Server <String>] [-AuthType <AuthenticationMethod>]
 [-SessionOption <OpenADSessionOptions>] [-StartTLS] [-Credential <PSCredential>]
 [-Identity] <ADPrincipalIdentity> [-Property <String[]>] [<CommonParameters>]
```

### SessionIdentity
```
Get-OpenADPrincipalGroupMembership [-Recursive] -Session <OpenADSession> [-Identity] <ADPrincipalIdentity>
 [-Property <String[]>] [<CommonParameters>]
```

### SessionLDAPFilter
```
Get-OpenADPrincipalGroupMembership [-Recursive] -Session <OpenADSession> [-LDAPFilter <String>]
 [-SearchBase <String>] [-SearchScope <SearchScope>] [-Property <String[]>] [<CommonParameters>]
```

### ServerLDAPFilter
```
Get-OpenADPrincipalGroupMembership [-Recursive] [-Server <String>] [-AuthType <AuthenticationMethod>]
 [-SessionOption <OpenADSessionOptions>] [-StartTLS] [-Credential <PSCredential>] [-LDAPFilter <String>]
 [-SearchBase <String>] [-SearchScope <SearchScope>] [-Property <String[]>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-OpenADPrincipalGroupMembership` cmdlet performs a search for all Active Directory groups which a user, computer, or other security principal is a member of directly, and optionally indirectly.

The `-Identity` parameter specifies the Active Directory principal to get group membership of.
You can specify the identity with the distinguished name, GUID, User Principal Name (UPN), Security Account Manager (SAM) name, or security identifier.
The identity can also be specified by passing in a group object through the pipeline.

The `-LDAPFilter` parameter can be used to get multiple principals' group membership using the LDAP query language.
The filter can be combined with `-SearchBase` and `-SearchScope` to refine the search parameters used.

The cmdlet communicates in one of three way:

+ Using the implicit AD connection based on the current environment

+ Using the `-Session` object specified

+ Using a new or cached connection to the `-Server` specified

For more information on Open AD sessions, see [about_OpenADSessions](./about_OpenADSessions.md).

The output for each object retrieves a default set of object properties as documented in the `OUTPUT` section.
Any additional properties can be requested with the `-Property` parameter in the form of the LDAP property name desired.

## EXAMPLES

### Example 1: Get all of an object's direct group memberships
```powershell
PS C:\> Get-OpenADPrincipalGroupMembership 'DC01$'
```

List the groups that the computer DC01 is directly a member of.

### Example 2: Get all group memberships of an object recursively
```powershell
PS C:\> Get-OpenADPrincipalGroupMembership 'Administrator' -Recursive
```

List the groups that Administrator is a member of, directly or indirectly.

## PARAMETERS

### -AuthType
The authentication type to use when creating the `OpenAD` session.
This is used when the cmdlet creates a new connection to the `-Server` specified.

```yaml
Type: AuthenticationMethod
Parameter Sets: ServerIdentity, ServerLDAPFilter
Aliases:
Accepted values: Default, Anonymous, Simple, Negotiate, Kerberos, Certificate

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
The explicit credentials to use when creating the `OpenAD` session.
This is used when the cmdlet creates a new connection to the `-Server` specified.

```yaml
Type: PSCredential
Parameter Sets: ServerIdentity, ServerLDAPFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity
Specifies the Active Directory group to list the members of using one of the following formats:

+ `DistinguishedName`

+ `ObjectGUID`

+ `ObjectSID`

+ `UserPrincipalName`

+ `SamAccountName`

The cmdlet writes an error if no group is found based on the identity specified.
In addition the identity is filtered by the LDAP filter `(objectCategory=group)` to restrict only group objects from being searched.
The `-LDAPFilter` parameter can be used instead to query for multiple objects.

```yaml
Type: ADPrincipalIdentity
Parameter Sets: ServerIdentity, SessionIdentity
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -LDAPFilter
Used instead of `-Identity` to specify an LDAP query used to filter group objects.
The filter specified here will be used with an `AND` condition to `(objectSid=*)`.

```yaml
Type: String
Parameter Sets: SessionLDAPFilter, ServerLDAPFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Property
The attributes to retrieve for each group object returned.
The values of each attribute is in the form of an LDAP attribute name and are case insensitive.
When no properties are specified the following attributes are retrieved:

+ `distinguishedName`

+ `name`

+ `objectClass`

+ `objectGUID`

+ `sAMAccountName`

+ `objectSid`

+ `groupType`

Any attributes specified by this parameter will be added to the list above.
Specify `*` to display all attributes that are set on the object.
Any attributes on the object that do not have a value set will not be returned with `*` unless they were also explicitly requested.
These unset attributes must be explicitly defined for it to return on the output object.

If there has been a successful connection to any LDAP server this option supports tab completion.
The possible properties shown in the tab completion are based on the schema returned by the server for the `group` object class.
If no connection has been created by the client then there is no tab completion available.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Properties

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recursive
Include groups that the queried principal is indirectly a member of, i.e. ones its groups are themselves members of.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchBase
The base Active Directory path to search the object for.
This defaults to the `defaultNamingContext` of the session connection which is typically the root of the domain.
Combine this with `-SearchScope` to limit searches to a smaller subset of the domain.

```yaml
Type: String
Parameter Sets: SessionLDAPFilter, ServerLDAPFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchScope
Specifies the scope of an Active Directory search.
This can be set to

+ `Base` - Only searches the object at the `-SearchBase` path specified

+ `OneLevel` - Searches the immediate children of `-SearchBase`

+ `Subtree` (default) - Searches the children of `-SearchBase` and subsequent children of them

```yaml
Type: SearchScope
Parameter Sets: SessionLDAPFilter, ServerLDAPFilter
Aliases:
Accepted values: Base, OneLevel, Subtree

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Server
The Active Directory server to connect to.
This can either be the name of the server or the LDAP connection uri starting with `ldap://` or `ldaps://`.
The derived URI of this value is used to find any existing connections that are available for use or will be used to create a new session if no cached session exists.
If both `-Server` and `-Session` are not specified then the default Kerberos realm is used if available otherwise it will generate an error.
This option supports tab completion based on the existing OpenADSessions that have been created.

This option is mutually exclusive with `-Session`.

```yaml
Type: String
Parameter Sets: ServerIdentity, ServerLDAPFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Session
The `OpenAD` session to use for the query rather than trying to create a new connection or reuse a cached connection.
This session is generated by `New-OpenADSession` and can be used in situations where the global defaults should not be used.

This option is mutually exclusive with `-Server`.

```yaml
Type: OpenADSession
Parameter Sets: SessionIdentity, SessionLDAPFilter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SessionOption
Advanced session options used when creating a new session with `-Server`.
These options can be generated with `New-OpenADSessionOption`.

```yaml
Type: OpenADSessionOptions
Parameter Sets: ServerIdentity, ServerLDAPFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartTLS
Use `StartTLS` when creating a new session with `-Server`.

```yaml
Type: SwitchParameter
Parameter Sets: ServerIdentity, ServerLDAPFilter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### PSOpenAD.ADPrincipalIdentity
The identity in it's various forms can be piped into the cmdlet.

## OUTPUTS

### PSOpenAD.OpenADGroup
The `OpenADGroup` representing the object(s) found. This object will always have the following properties set:

+ `DistinguishedName`

+ `Name`

+ `ObjectClass`

+ `ObjectGuid`

+ `SamAccountName`

+ `SID`

+ `GroupCategory`

+ `GroupScope`

+ `DomainController`: This is set to the domain controller that processed the request

+ `QueriedPrincipal`: This is set to the principal whose group membership was requested

Any explicit attributes requested through `-Property` are also present on the object.

If an LDAP attribute on the underlying object did not have a value set but was explicitly requested then the property will be set to `$null`.

## NOTES

## RELATED LINKS

[Active Directory: LDAP Syntax Filters](https://social.technet.microsoft.com/wiki/contents/articles/5392.active-directory-ldap-syntax-filters.aspx)
[LDAP Filters](https://ldap.com/ldap-filters/)
