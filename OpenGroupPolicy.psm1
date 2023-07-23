enum GpoStatus {
    AllSettingsEnabled
    UserSettingsDisabled
    ComputerSettingsDisabled
    AllSettingsDisabled
} # https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-gpod/d360d288-d7d5-49a9-83be-603805da1379

class GpoConfiguration {
    [int]$DSVersion = 0
    [bool]$Enabled
    $Policy
    $Preference
    [int]$SysvolVersion = 0

    # TODO: this should actually be done in output formatting
    [string]ToString() {return ('AD Version: {0}, SysVol Version: {1}' -f $this.DSVersion, $this.SysvolVersion)}
}

class UserConfiguration : GpoConfiguration {}

class ComputerConfiguration : GpoConfiguration {}

class Gpo {
    [ComputerConfiguration]$Computer
    $CreationTime
    $Description
    $DisplayName
    $DomainName
    [GpoStatus]$GpoStatus
    $Id
    $ModificationTime
    $Owner
    $Path
    [UserConfiguration]$User
    $WmiFilter
    # maybe change names
    $PhysicalPath # 'gpo path' already taken, GPTPath? gPCFileSysPath? Physical (component) path? File (share) path?
    $MachineExtensions
    $UserExtensions
    $FunctionalityVersion
}

class GpoLink {
    $DisplayName
    [bool]$Enabled
    [bool]$Enforced
    $GpoDomainName
    [guid]$GpoId
    [int]$Order
    $Target
}

function Get-OpenGPO {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName = 'Guid')]
        [Alias('Id')]
        [guid]$GUID,
        [Parameter(Mandatory, ParameterSetName = 'DistinguishedName')]
        [Alias('DN')]
        $DistinguishedName
    )
    # TODO: by name

    # TODO: Get-OpenADDomain
    # TODO: use DC= from DistinguishedName
    $domain = Get-ADDomain

    if ($PSCmdlet.ParameterSetName -eq 'Guid') {
        $DistinguishedName = 'CN={{{0}}},CN=Policies,{1}' -f $GUID.Guid, $domain.SystemsContainer
    } elseif ($PSCmdlet.ParameterSetName -eq 'DistinguishedName') {
        $DistinguishedName = $DistinguishedName -replace '^LDAP://'
    }

    $obj = Get-ADObject $DistinguishedName -Properties * # TODO: Get-OpenADObject
    Write-Debug "Got $($obj.DistinguishedName)"

    $sysvolVersion = (Get-Content (Join-Path $obj.gPCFileSysPath 'GPT.INI') -ErrorAction SilentlyContinue |
        Where-Object {$_ -match '^Version=(\d+)$'}) -replace '^Version='

    $userConfig = [UserConfiguration]@{
        DSVersion     = $obj.versionNumber -shr 16 # upper 16 bits
        SysvolVersion = $sysvolVersion -shr 16
        Enabled       = $obj.flags -ne 1
    }

    $computerConfig = [ComputerConfiguration]@{
        DSVersion     = $obj.versionNumber % 65536 # lower 16 bits
        SysvolVersion = $sysvolVersion % 65536
        Enabled       = $obj.flags -ne 2
    }

    [Gpo]@{
        DisplayName      = $obj.DisplayName
        DomainName       = $domain.Forest
        Owner            = $obj.nTSecurityDescriptor # TODO: get owner from descriptor
        Id               = $obj.Name.Trim('{}')
        GpoStatus        = [GpoStatus]$obj.flags
        Description      = $obj.Description
        CreationTime     = $obj.whenCreated
        ModificationTime = $obj.whenChanged
        Path             = $distinguishedName
        User             = $userConfig
        Computer         = $computerConfig
        WmiFilter        = $obj.'msWMI-SOM' # gPCWQLFilter?
        PhysicalPath     = $obj.gPCFileSysPath
    }
}

function Get-OpenGPLink {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('DN')]
        $DistinguishedName
    )

    $target = Get-ADObject $DistinguishedName -Properties gPLink, gPOptions
    if ($target.gPLink) {
        $links = @($target.gPLink.Split('][') | Where-Object {$_})
        Write-Debug "Target has $($links.Count) linked GPOs: $links"
    }

    # gp link numbering starts at 1
    for ($order = 1; $order -le $links.Count; $order++) {
        # https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-gpol/08090b22-bc16-49f4-8e10-f27a8fb16d18
        $gpodn, $linkoptions = $links[$order-1] -split ';'
        Write-Debug "Link $order is $dn"

        $gpo = Get-OpenGPO -DistinguishedName $gpodn
        [GpoLink]@{
            GpoId       = $gpo.Id
            DisplayName = $gpo.DisplayName
            Enabled     = !($linkoptions -band 1) # disabled if 1 bit is set
            Enforced    = [bool]($linkoptions -band 2) # enforce if 2 bit is set
            Target      = $target.DistinguishedName
            Order       = $order
        } | Write-Output
    }
}

function Get-OpenGPInheritance {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Alias('DistinguishedName', 'DN')]
        $Target
    )

    $obj = Get-ADObject $Target

    # TODO: type
    [PSCustomObject]@{
        Name = $obj.DisplayName
        ContainerType = 'TODO, not ObjectClass'
        Path = $obj.DistinguishedName
        GpoInheritanceBlocked = 'TODO'
        GpoLinks = Get-OpenGPLink -DistinguishedName $obj.DistinguishedName
        InheritedGpoLinks = 'TODO'
    }
}

<#
Get-GPRegistryValue # requires reading .pol or lazy way of grepping Registry.pol
Get-GPPermission # requires reading security descriptor
Get-GPPrefRegistryValue
Get-GPOReport # complicated
Get-GPResultantSetOfPolicy # complicated, relies on gpinheritance & gporeport
Get-GPStarterGPO # low priority
#>
