[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
    -ChildPath '..\..\Unit' `
    -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Microsoft365.psm1' `
        -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\Stubs\Generic.psm1' `
        -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath '\UnitTestHelper.psm1' `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource 'IntuneDeviceConfigurationPolicyAndroidOpenSourceProject' -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString 'test@password1' -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ('tenantadmin', $secpasswd)


            Mock -CommandName Get-M365DSCExportContentForResource -MockWith {
            }

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Update-MgDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-MgDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName Remove-MgDeviceManagementDeviceConfiguration -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return 'Credential'
            }

            # Mock Write-Host to hide output during the tests
            Mock -CommandName Write-Host -MockWith {
            }
        }

        # Test contexts
        Context -Name 'The IntuneDeviceConfigurationPolicyAndroidOpenSourceProject should exist but it DOES NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppsBlockInstallFromUnknownSources             = $True
                    BluetoothBlockConfiguration                    = $True
                    BluetoothBlocked                               = $True
                    CameraBlocked                                  = $True
                    Description                                    = 'FakeStringValue'
                    DisplayName                                    = 'FakeStringValue'
                    FactoryResetBlocked                            = $True
                    Id                                             = 'FakeStringValue'
                    PasswordMinimumLength                          = 25
                    PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                    PasswordRequiredType                           = 'deviceDefault'
                    PasswordSignInFailureCountBeforeFactoryReset   = 25
                    ScreenCaptureBlocked                           = $True
                    SecurityAllowDebuggingFeatures                 = $True
                    StorageBlockExternalMedia                      = $True
                    StorageBlockUsbFileTransfer                    = $True
                    WifiBlockEditConfigurations                    = $True

                    Ensure                                         = 'Present'
                    Credential                                     = $Credential
                }

                Mock -CommandName Get-MgDeviceManagementDeviceConfiguration -MockWith {
                    return $null
                }
            }
            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName New-MgDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'The IntuneDeviceConfigurationPolicyAndroidOpenSourceProject exists but it SHOULD NOT' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppsBlockInstallFromUnknownSources             = $True
                    BluetoothBlockConfiguration                    = $True
                    BluetoothBlocked                               = $True
                    CameraBlocked                                  = $True
                    Description                                    = 'FakeStringValue'
                    DisplayName                                    = 'FakeStringValue'
                    FactoryResetBlocked                            = $True
                    Id                                             = 'FakeStringValue'
                    PasswordMinimumLength                          = 25
                    PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                    PasswordRequiredType                           = 'deviceDefault'
                    PasswordSignInFailureCountBeforeFactoryReset   = 25
                    ScreenCaptureBlocked                           = $True
                    SecurityAllowDebuggingFeatures                 = $True
                    StorageBlockExternalMedia                      = $True
                    StorageBlockUsbFileTransfer                    = $True
                    WifiBlockEditConfigurations                    = $True

                    Ensure                                         = 'Absent'
                    Credential                                     = $Credential
                }

                Mock -CommandName Get-MgDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            ScreenCaptureBlocked                           = $True
                            PasswordMinimumLength                          = 25
                            BluetoothBlocked                               = $True
                            '@odata.type'                                  = '#microsoft.graph.'
                            AppsBlockInstallFromUnknownSources             = $True
                            FactoryResetBlocked                            = $True
                            CameraBlocked                                  = $True
                            PasswordRequiredType                           = 'deviceDefault'
                            PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                            StorageBlockUsbFileTransfer                    = $True
                            WifiBlockEditConfigurations                    = $True
                            PasswordSignInFailureCountBeforeFactoryReset   = 25
                            SecurityAllowDebuggingFeatures                 = $True
                            StorageBlockExternalMedia                      = $True
                            BluetoothBlockConfiguration                    = $True

                        }
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        Id                   = 'FakeStringValue'

                    }
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-MgDeviceManagementDeviceConfiguration -Exactly 1
            }
        }
        Context -Name 'The IntuneDeviceConfigurationPolicyAndroidOpenSourceProject Exists and Values are already in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppsBlockInstallFromUnknownSources             = $True
                    BluetoothBlockConfiguration                    = $True
                    BluetoothBlocked                               = $True
                    CameraBlocked                                  = $True
                    Description                                    = 'FakeStringValue'
                    DisplayName                                    = 'FakeStringValue'
                    FactoryResetBlocked                            = $True
                    Id                                             = 'FakeStringValue'
                    PasswordMinimumLength                          = 25
                    PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                    PasswordRequiredType                           = 'deviceDefault'
                    PasswordSignInFailureCountBeforeFactoryReset   = 25
                    ScreenCaptureBlocked                           = $True
                    SecurityAllowDebuggingFeatures                 = $True
                    StorageBlockExternalMedia                      = $True
                    StorageBlockUsbFileTransfer                    = $True
                    WifiBlockEditConfigurations                    = $True

                    Ensure                                         = 'Present'
                    Credential                                     = $Credential
                }

                Mock -CommandName Get-MgDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            ScreenCaptureBlocked                           = $True
                            PasswordMinimumLength                          = 25
                            BluetoothBlocked                               = $True
                            '@odata.type'                                  = '#microsoft.graph.'
                            AppsBlockInstallFromUnknownSources             = $True
                            FactoryResetBlocked                            = $True
                            CameraBlocked                                  = $True
                            PasswordRequiredType                           = 'deviceDefault'
                            PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                            StorageBlockUsbFileTransfer                    = $True
                            WifiBlockEditConfigurations                    = $True
                            PasswordSignInFailureCountBeforeFactoryReset   = 25
                            SecurityAllowDebuggingFeatures                 = $True
                            StorageBlockExternalMedia                      = $True
                            BluetoothBlockConfiguration                    = $True

                        }
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        Id                   = 'FakeStringValue'

                    }
                }
            }


            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name 'The IntuneDeviceConfigurationPolicyAndroidOpenSourceProject exists and values are NOT in the desired state' -Fixture {
            BeforeAll {
                $testParams = @{
                    AppsBlockInstallFromUnknownSources             = $True
                    BluetoothBlockConfiguration                    = $True
                    BluetoothBlocked                               = $True
                    CameraBlocked                                  = $True
                    Description                                    = 'FakeStringValue'
                    DisplayName                                    = 'FakeStringValue'
                    FactoryResetBlocked                            = $True
                    Id                                             = 'FakeStringValue'
                    PasswordMinimumLength                          = 25
                    PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                    PasswordRequiredType                           = 'deviceDefault'
                    PasswordSignInFailureCountBeforeFactoryReset   = 25
                    ScreenCaptureBlocked                           = $True
                    SecurityAllowDebuggingFeatures                 = $True
                    StorageBlockExternalMedia                      = $True
                    StorageBlockUsbFileTransfer                    = $True
                    WifiBlockEditConfigurations                    = $True

                    Ensure                                         = 'Present'
                    Credential                                     = $Credential
                }

                Mock -CommandName Get-MgDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            PasswordMinimumLength                          = 7
                            PasswordRequiredType                           = 'deviceDefault'
                            PasswordSignInFailureCountBeforeFactoryReset   = 7
                            PasswordMinutesOfInactivityBeforeScreenTimeout = 7
                            '@odata.type'                                  = '#microsoft.graph.'

                        }
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        Id                   = 'FakeStringValue'

                    }
                }
            }

            It 'Should return Values from the Get method' {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should call the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Update-MgDeviceManagementDeviceConfiguration -Exactly 1
            }
        }

        Context -Name 'ReverseDSC Tests' -Fixture {
            BeforeAll {
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-MgDeviceManagementDeviceConfiguration -MockWith {
                    return @{
                        AdditionalProperties = @{
                            ScreenCaptureBlocked                           = $True
                            PasswordMinimumLength                          = 25
                            BluetoothBlocked                               = $True
                            '@odata.type'                                  = '#microsoft.graph.'
                            AppsBlockInstallFromUnknownSources             = $True
                            FactoryResetBlocked                            = $True
                            CameraBlocked                                  = $True
                            PasswordRequiredType                           = 'deviceDefault'
                            PasswordMinutesOfInactivityBeforeScreenTimeout = 25
                            StorageBlockUsbFileTransfer                    = $True
                            WifiBlockEditConfigurations                    = $True
                            PasswordSignInFailureCountBeforeFactoryReset   = 25
                            SecurityAllowDebuggingFeatures                 = $True
                            StorageBlockExternalMedia                      = $True
                            BluetoothBlockConfiguration                    = $True

                        }
                        Description          = 'FakeStringValue'
                        DisplayName          = 'FakeStringValue'
                        Id                   = 'FakeStringValue'

                    }
                }
            }
            It 'Should Reverse Engineer resource from the Export method' {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
