﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



function Get-MonkeyAADDirectoryRole {
<#
        .SYNOPSIS
		Plugin to get Directoryroles from Azure AD
        https://docs.microsoft.com/en-us/azure/active-directory/active-directory-assign-admin-roles

        .DESCRIPTION
		Plugin to get Directoryroles from Azure AD
        https://docs.microsoft.com/en-us/azure/active-directory/active-directory-assign-admin-roles

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyAADDirectoryRole
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false,HelpMessage = "Background Plugin ID")]
		[string]$pluginId
	)
	begin {
		#Plugin metadata
        $monkey_metadata = @{
			Id = "aad0005";
			Provider = "AzureAD";
			Resource = "AzureAD";
			ResourceType = $null;
			resourceName = $null;
			PluginName = "Get-MonkeyAADDirectoryRole";
			ApiType = "MSGraph";
			Title = "Plugin to get Directoryroles from Azure AD";
			Group = @("AzureAD");
			Tags = @{
				"enabled" = $true
			};
			Docs = "https://silverhack.github.io/monkey365/"
		}
        try{
            $aadConf = $O365Object.internal_config.azuread.provider.msgraph
        }
        catch{
            $msg = @{
                MessageData = ($message.MonkeyInternalConfigError);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'verbose';
                InformationAction = $O365Object.InformationAction;
                Tags = @('Monkey365ConfigError');
            }
            Write-Verbose @msg
            break
        }
	}
	process {
		$msg = @{
			MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Azure AD Directory Roles",$O365Object.TenantID);
			callStack = (Get-PSCallStack | Select-Object -First 1);
			logLevel = 'info';
			InformationAction = $InformationAction;
			Tags = @('AzureMSGraphDirectoryRole');
		}
		Write-Information @msg
        #Get Role Assignment
        $p = @{
            APIVersion = $aadConf.api_version;
            InformationAction = $O365Object.InformationAction;
			Verbose = $O365Object.Verbose;
			Debug = $O365Object.Debug;
		}
		$directory_roles = Get-MonkeyMSGraphAADRoleAssignment @p
		#Get AAD role assignment
		$p = @{
            InformationAction = $O365Object.InformationAction;
			Verbose = $O365Object.Verbose;
			Debug = $O365Object.Debug;
		}
		$aad_role_assignment = Get-MonkeyMSGraphAADDirectoryRole @p
	}
	end {
		if ($directory_roles) {
			$directory_roles.PSObject.TypeNames.Insert(0,'Monkey365.AzureAD.DirectoryRoles')
			[pscustomobject]$obj = @{
				Data = $directory_roles;
				Metadata = $monkey_metadata;
			}
			$returnData.aad_directory_roles = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Directory roles",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'verbose';
				Tags = @('AzureGraphUsersEmptyResponse');
                Verbose = $O365Object.Verbose;
			}
			Write-Verbose @msg
		}
		if ($aad_role_assignment) {
            $aad_role_assignment.PSObject.TypeNames.Insert(0,'Monkey365.AzureAD.RoleAssignment')
			[pscustomobject]$obj = @{
				Data = $aad_role_assignment;
				Metadata = $monkey_metadata;
			}
			$returnData.aad_role_assignment = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Azure AD role assignment",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'verbose';
				Tags = @('AzureGraphUsersEmptyResponse');
                Verbose = $O365Object.Verbose;
			}
			Write-Verbose @msg
		}
	}
}
