[CmdletBinding()]
param(
)
$M365DSCTestFolder = Join-Path -Path $PSScriptRoot `
                        -ChildPath "..\..\Unit" `
                        -Resolve
$CmdletModule = (Join-Path -Path $M365DSCTestFolder `
            -ChildPath "\Stubs\Microsoft365.psm1" `
            -Resolve)
$GenericStubPath = (Join-Path -Path $M365DSCTestFolder `
    -ChildPath "\Stubs\Generic.psm1" `
    -Resolve)
Import-Module -Name (Join-Path -Path $M365DSCTestFolder `
        -ChildPath "\UnitTestHelper.psm1" `
        -Resolve)

$Global:DscHelper = New-M365DscUnitTestHelper -StubModule $CmdletModule `
    -DscResource "TeamsCortanaPolicy" -GenericStubModule $GenericStubPath
Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope
        BeforeAll {

            $secpasswd = ConvertTo-SecureString "f@kepassword1" -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ("tenantadmin@mydomain.com", $secpasswd)

            Mock -CommandName Confirm-M365DSCDependencies -MockWith {
            }

            Mock -CommandName Get-PSSession -MockWith {
            }

            Mock -CommandName Remove-PSSession -MockWith {
            }

            Mock -CommandName Set-CsTeamsCortanaPolicy -MockWith {
            }

            Mock -CommandName New-CsTeamsCortanaPolicy -MockWith {
            }

            Mock -CommandName Remove-CsTeamsCortanaPolicy -MockWith {
            }

            Mock -CommandName New-M365DSCConnection -MockWith {
                return "Credential"
            }
        }
        # Test contexts
        Context -Name "The TeamsCortanaPolicy should exist but it DOES NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"
                    Ensure                        = "Present"
                    Credential                    = $Credential;
                }

                Mock -CommandName Get-CsTeamsCortanaPolicy -MockWith {
                    return $null
                }
            }
            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Absent'
            }
            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }
            It 'Should Create the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName New-CsTeamsCortanaPolicy -Exactly 1
            }
        }

        Context -Name "The TeamsCortanaPolicy exists but it SHOULD NOT" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"
                    Ensure                        = "Absent"
                    Credential                    = $Credential;
                }

                Mock -CommandName Get-CsTeamsCortanaPolicy -MockWith {
                    return @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"

                    }
                }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It 'Should Remove the group from the Set method' {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Remove-CsTeamsCortanaPolicy -Exactly 1
            }
        }
        Context -Name "The TeamsCortanaPolicy Exists and Values are already in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"
                    Ensure                        = "Present"
                    Credential                    = $Credential;
                }

                Mock -CommandName Get-CsTeamsCortanaPolicy -MockWith {
                    return @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"

                    }
                }
            }


            It 'Should return true from the Test method' {
                Test-TargetResource @testParams | Should -Be $true
            }
        }

        Context -Name "The TeamsCortanaPolicy exists and values are NOT in the desired state" -Fixture {
            BeforeAll {
                $testParams = @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"
                    Ensure                = "Present"
                    Credential            = $Credential;
                }

                Mock -CommandName Get-CsTeamsCortanaPolicy -MockWith {
                    return @{
                    AllowCortanaVoiceInvocation      = $False
                    Description                      = "FakeStringValueDrift #Drift"
                    AllowCortanaInContextSuggestions = $False
                    AllowCortanaAmbientListening     = $False
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValueDrift #Drift"
                    }
                }
            }

            It "Should return Values from the Get method" {
                (Get-TargetResource @testParams).Ensure | Should -Be 'Present'
            }

            It 'Should return false from the Test method' {
                Test-TargetResource @testParams | Should -Be $false
            }

            It "Should call the Set method" {
                Set-TargetResource @testParams
                Should -Invoke -CommandName Set-CsTeamsCortanaPolicy -Exactly 1
            }
        }

        Context -Name "ReverseDSC Tests" -Fixture {
            BeforeAll {
                $Global:CurrentModeIsExport = $true
                $testParams = @{
                    Credential = $Credential
                }

                Mock -CommandName Get-CsTeamsCortanaPolicy -MockWith {
                    return @{
                    AllowCortanaVoiceInvocation      = $True
                    Description                      = "FakeStringValue"
                    AllowCortanaInContextSuggestions = $True
                    AllowCortanaAmbientListening     = $True
                    Identity                         = "FakeStringValue"
                    CortanaVoiceInvocationMode       = "FakeStringValue"

                    }
                }
            }
            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
