function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.UInt32]
        $OneDriveStorageQuota,

        [Parameter()]
        [System.UInt32]
        $OrphanedPersonalSitesRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $OneDriveForGuestsEnabled,

        [Parameter()]
        [System.Boolean]
        $NotifyOwnersWhenInvitationsAccepted,

        [Parameter()]
        [System.Boolean]
        $NotificationsInOneDriveForBusinessEnabled,

        [Parameter()]
        [System.String]
        [ValidateSet("On", "Off", "Unspecified")]
        $ODBMembersCanShare,

        [Parameter()]
        [System.String]
        [ValidateSet("On", "Off", "Unspecified")]
        $ODBAccessRequests,

        [Parameter()]
        [System.Boolean]
        $BlockMacSync,

        [Parameter()]
        [System.Boolean]
        $DisableReportProblemDialog,

        [Parameter()]
        [System.String[]]
        $DomainGuids,

        [Parameter()]
        [System.String[]]
        $ExcludedFileExtensions,

        [Parameter()]
        [System.String]
        [ValidateSet("OptOut", "HardOptIn", "SoftOptIn")]
        $GrooveBlockOption,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )

    Write-Verbose -Message "Getting configuration of OneDrive Settings"
    #region Telemetry
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $MyInvocation.MyCommand.ModuleName)
    $data.Add("Method", $MyInvocation.MyCommand)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Test-MSCloudLogin -CloudCredential $GlobalAdminAccount `
        -Platform PnP

    $nullReturn = @{
        IsSingleInstance                          = "Yes"
        BlockMacSync                              = $null
        DisableReportProblemDialog                = $null
        DomainGuids                               = $null
        ExcludedFileExtensions                    = $null
        GrooveBlockOption                         = $null
        OneDriveStorageQuota                      = $null
        OrphanedPersonalSitesRetentionPeriod      = $null
        OneDriveForGuestsEnabled                  = $null
        ODBAccessRequests                         = $null
        ODBMembersCanShare                        = $null
        NotifyOwnersWhenInvitationsAccepted       = $null
        NotificationsInOneDriveForBusinessEnabled = $null
        Ensure                                    = "Absent"
    }

    try
    {
        Write-Verbose -Message "Getting OneDrive quota size for tenant"
        $tenant = Get-PnPTenant

        if ($null -eq $tenant)
        {
            Write-Verbose -Message "Failed to get Tenant information"
            return $nullReturn
        }

        Write-Verbose -Message "Getting OneDrive quota size for tenant $($tenant.OneDriveStorageQuota)"
        Write-Verbose -Message "Getting tenant client sync setting"
        $tenantRestrictions = Get-PnPTenantSyncClientRestriction

        if ($null -eq $tenantRestrictions)
        {
            Write-Verbose -Message "Failed to get Tenant client synce settings!"
            return $nullReturn
        }

        $GrooveOption = $null

        if (($tenantRestrictions.OptOutOfGrooveBlock -eq $true) -and ($tenantRestrictions.OptOutOfGrooveSoftBlock -eq $false))
        {
            $GrooveOption = "SoftOptIn"
        }

        if (($tenantRestrictions.OptOutOfGrooveBlock -eq $false) -and ($tenantRestrictions.OptOutOfGrooveSoftBlock -eq $true))
        {
            $GrooveOption = "HardOptIn"
        }

        if (($tenantRestrictions.OptOutOfGrooveBlock -eq $true) -and ($tenantRestrictions.OptOutOfGrooveSoftBlock -eq $true))
        {
            $GrooveOption = "OptOut"
        }

        $FixedExcludedFileExtensions = $tenantRestrictions.ExcludedFileExtensions
        if ($FixedExcludedFileExtensions.Count -eq 0 -or
            ($FixedExcludedFileExtensions.Count -eq 1 -and $FixedExcludedFileExtensions[0] -eq ""))
        {
            $FixedExcludedFileExtensions = @()
        }

        $FixedAllowedDomainList = $tenantRestrictions.AllowedDomainList
        if ($FixedAllowedDomainList.Count -eq 0 -or
            ($FixedAllowedDomainList.Count -eq 1 -and $FixedAllowedDomainList[0] -eq ""))
        {
            $FixedAllowedDomainList = @()
        }

        $ODBMembersCanShareValue = $tenant.ODBMembersCanShare
        if ([System.String]::IsNullOrEmpty($ODBMembersCanShareValue))
        {
            $ODBMembersCanShareValue = 'Unspecified'
        }
        return @{
            IsSingleInstance                          = "Yes"
            BlockMacSync                              = $tenantRestrictions.BlockMacSync
            DisableReportProblemDialog                = $tenantRestrictions.DisableReportProblemDialog
            DomainGuids                               = $FixedAllowedDomainList
            ExcludedFileExtensions                    = $FixedExcludedFileExtensions
            GrooveBlockOption                         = $GrooveOption
            OneDriveStorageQuota                      = $tenant.OneDriveStorageQuota
            OrphanedPersonalSitesRetentionPeriod      = $tenant.OrphanedPersonalSitesRetentionPeriod
            OneDriveForGuestsEnabled                  = $tenant.OneDriveForGuestsEnabled
            ODBAccessRequests                         = $tenant.ODBAccessRequests
            ODBMembersCanShare                        = $ODBMembersCanShareValue
            NotifyOwnersWhenInvitationsAccepted       = $tenant.NotifyOwnersWhenInvitationsAccepted
            NotificationsInOneDriveForBusinessEnabled = $tenant.NotificationsInOneDriveForBusinessEnabled
            Ensure                                    = "Present"
        }
    }
    catch
    {
        $Message = "Failed to get Tenant client sync settings"
        New-M365DSCLogEntry -Error $_ -Message $Message -Source $MyInvocation.MyCommand.ModuleName
        return $nullReturn
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.UInt32]
        $OneDriveStorageQuota,

        [Parameter()]
        [System.UInt32]
        $OrphanedPersonalSitesRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $OneDriveForGuestsEnabled,

        [Parameter()]
        [System.Boolean]
        $NotifyOwnersWhenInvitationsAccepted,

        [Parameter()]
        [System.Boolean]
        $NotificationsInOneDriveForBusinessEnabled,

        [Parameter()]
        [System.String]
        [ValidateSet("On", "Off", "Unspecified")]
        $ODBMembersCanShare,

        [Parameter()]
        [System.String]
        [ValidateSet("On", "Off", "Unspecified")]
        $ODBAccessRequests,

        [Parameter()]
        [System.Boolean]
        $BlockMacSync,

        [Parameter()]
        [System.Boolean]
        $DisableReportProblemDialog,

        [Parameter()]
        [System.String[]]
        $DomainGuids,

        [Parameter()]
        [System.String[]]
        $ExcludedFileExtensions,

        [Parameter()]
        [System.String]
        [ValidateSet("OptOut", "HardOptIn", "SoftOptIn")]
        $GrooveBlockOption,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )

    Write-Verbose -Message "Setting configuration of OneDrive Settings"
    #region Telemetry
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $MyInvocation.MyCommand.ModuleName)
    $data.Add("Method", $MyInvocation.MyCommand)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion

    Test-MSCloudLogin -CloudCredential $GlobalAdminAccount `
        -Platform PnP

    ## Configure OneDrive settings
    ## Parameters below are remove for the Set-SPOTenant cmdlet
    ## they are used in the Set-SPOTenantSyncClientRestriction cmdlet
    $CurrentParameters = $PSBoundParameters
    $CurrentParameters.Remove("GlobalAdminAccount")

    if ($CurrentParameters.ContainsKey("Ensure"))
    {
        $CurrentParameters.Remove("Ensure")
    }

    if ($CurrentParameters.ContainsKey("BlockMacSync"))
    {
        $CurrentParameters.Remove("BlockMacSync")
    }
    if ($CurrentParameters.ContainsKey("DomainGuids"))
    {
        $CurrentParameters.Remove("DomainGuids")
    }
    if ($CurrentParameters.ContainsKey("DisableReportProblemDialog"))
    {
        $CurrentParameters.Remove("DisableReportProblemDialog")
    }
    if ($CurrentParameters.ContainsKey("ExcludedFileExtensions"))
    {
        $CurrentParameters.Remove("ExcludedFileExtensions")
    }
    if ($CurrentParameters.ContainsKey("GrooveBlockOption"))
    {
        $CurrentParameters.Remove("GrooveBlockOption")
    }
    if ($CurrentParameters.ContainsKey("IsSingleInstance"))
    {
        $CurrentParameters.Remove("IsSingleInstance")
    }

    Write-Verbose -Message "Configuring OneDrive settings."
    Set-PnPTenant @CurrentParameters

    $clientSyncParameters = $PSBoundParameters

    ## Configure Sync Client restrictions
    ## Set-SPOTenantSyncClientRestriction has different parameter sets and they cannot be combined see article:
    ## https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/set-spotenantsyncclientrestriction?view=sharepoint-ps

    if ($clientSyncParameters.ContainsKey("BlockMacSync") -and $clientSyncParameters.ContainsKey("DomainGuids"))
    {
        Set-PnPTenantSyncClientRestriction -BlockMacSync:$BlockMacSync -DomainGuids $DomainGuids -Enable
    }
    elseif ($clientSyncParameters.ContainsKey("DomainGuids") -and ($clientSyncParameters.ContainsKey("BlockMacSync") -eq $false))
    {
        Set-PnPTenantSyncClientRestriction -DomainGuids $DomainGuids -Enable
    }

    if ($clientSyncParameters.ContainsKey("ExcludedFileExtensions"))
    {
        $BlockedFileTypes = ""
        foreach ($fileTypes in $ExcludedFileExtensions)
        {
            $BlockedFileTypes += $fileTypes + ';'
        }

        Set-PnPTenantSyncClientRestriction -ExcludedFileExtensions $BlockedFileTypes
    }
    if ($clientSyncParameters.ContainsKey("DisableReportProblemDialog"))
    {
        Set-PnPTenantSyncClientRestriction -DisableReportProblemDialog $DisableReportProblemDialog
    }

    if ($clientSyncParameters.ContainsKey("GrooveBlockOption"))
    {
        Set-PnPTenantSyncClientRestriction -GrooveBlockOption $GrooveBlockOption
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Yes")]
        [System.String]
        $IsSingleInstance,

        [Parameter()]
        [System.UInt32]
        $OneDriveStorageQuota,

        [Parameter()]
        [System.UInt32]
        $OrphanedPersonalSitesRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $OneDriveForGuestsEnabled,

        [Parameter()]
        [System.Boolean]
        $NotifyOwnersWhenInvitationsAccepted,

        [Parameter()]
        [System.Boolean]
        $NotificationsInOneDriveForBusinessEnabled,

        [Parameter()]
        [System.String]
        [ValidateSet("On", "Off", "Unspecified")]
        $ODBMembersCanShare,

        [Parameter()]
        [System.String]
        [ValidateSet("On", "Off", "Unspecified")]
        $ODBAccessRequests,

        [Parameter()]
        [System.Boolean]
        $BlockMacSync,

        [Parameter()]
        [System.Boolean]
        $DisableReportProblemDialog,

        [Parameter()]
        [System.String[]]
        $DomainGuids,

        [Parameter()]
        [System.String[]]
        $ExcludedFileExtensions,

        [Parameter()]
        [System.String]
        [ValidateSet("OptOut", "HardOptIn", "SoftOptIn")]
        $GrooveBlockOption,

        [Parameter()]
        [ValidateSet("Present", "Absent")]
        [System.String]
        $Ensure = "Present",

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )

    Write-Verbose -Message "Testing configuration of OneDrive Settings"

    $CurrentValues = Get-TargetResource @PSBoundParameters

    Write-Verbose -Message "Current Values: $(Convert-M365DscHashtableToString -Hashtable $CurrentValues)"
    Write-Verbose -Message "Target Values: $(Convert-M365DscHashtableToString -Hashtable $PSBoundParameters)"

    $TestResult = Test-Microsoft365DSCParameterState -CurrentValues $CurrentValues `
        -Source $($MyInvocation.MyCommand.Source) `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck @("BlockMacSync", `
            "ExcludedFileExtensions", `
            "DisableReportProblemDialog", `
            "GrooveBlockOption", `
            "DomainGuids", `
            "OneDriveStorageQuota", `
            "OrphanedPersonalSitesRetentionPeriod", `
            "OneDriveForGuestsEnabled", `
            "ODBAccessRequests", `
            "ODBMembersCanShare", `
            "NotifyOwnersWhenInvitationsAccepted", `
            "NotificationsInOneDriveForBusinessEnabled",
        "Ensure")

    Write-Verbose -Message "Test-TargetResource returned $TestResult"

    return $TestResult
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    $InformationPReference = 'Continue'

    #region Telemetry
    $data = [System.Collections.Generic.Dictionary[[String], [String]]]::new()
    $data.Add("Resource", $MyInvocation.MyCommand.ModuleName)
    $data.Add("Method", $MyInvocation.MyCommand)
    Add-M365DSCTelemetryEvent -Data $data
    #endregion
    Test-MSCloudLogin -CloudCredential $GlobalAdminAccount `
        -Platform PnP `
        -ErrorAction SilentlyContinue
    $Params = @{
        IsSingleInstance   = 'Yes'
        GlobalAdminAccount = $GlobalAdminAccount
    }
    $result = Get-TargetResource @Params

    if ([System.String]::IsNullOrEmpty($result.GrooveBlockOption))
    {
        $result.Remove("GrooveBlockOption") | Out-Null
    }
    $result.GlobalAdminAccount = Resolve-Credentials -UserName "globaladmin"
    $content = "        ODSettings " + (New-GUID).ToString() + "`r`n"
    $content += "        {`r`n"
    $currentDSCBlock = Get-DSCBlock -Params $result -ModulePath $PSScriptRoot
    $content += Convert-DSCStringParamToVariable -DSCBlock $currentDSCBlock -ParameterName "GlobalAdminAccount"
    $content += "        }`r`n"
    Write-Host $Global:M365DSCEmojiGreenCheckMark
    return $content
}

Export-ModuleMember -Function *-TargetResource
