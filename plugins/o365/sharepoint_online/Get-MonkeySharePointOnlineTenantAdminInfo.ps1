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


function Get-MonkeySharePointOnlineTenantAdminInfo {
<#
        .SYNOPSIS
		Plugin to get information about SPS Tenant information

        .DESCRIPTION
		Plugin to get information about SPS Tenant information

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeySharePointOnlineTenantAdminInfo
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
		$sps_tenant_admin_details = $null
		#Plugin metadata
		$monkey_metadata = @{
			Id = "sps0008";
			Provider = "Microsoft365";
			Resource = "SharePointOnline";
			ResourceType = $null;
			resourceName = $null;
			PluginName = "Get-MonkeySharePointOnlineTenantAdminInfo";
			ApiType = "CSOM";
			Title = "Plugin to get information about SPS Tenant information";
			Group = @("SharePointOnline");
			Tags = @{
				"enabled" = $true
			};
			Docs = "https://silverhack.github.io/monkey365/"
		}
		#Check if user is sharepoint administrator
		if($O365Object.isSharePointAdministrator -eq $false){
            break;
        }
	}
	process {
		$msg = @{
			MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Sharepoint Online Tenant Admin Info",$O365Object.TenantID);
			callStack = (Get-PSCallStack | Select-Object -First 1);
			logLevel = 'info';
			InformationAction = $O365Object.InformationAction;
			Tags = @('SPSTenantInfo');
		}
		Write-Information @msg
        $p = @{
            InformationAction = $O365Object.InformationAction;
            Verbose = $O365Object.verbose;
            Debug = $O365Object.debug;
        }
        $sps_tenant_admin_details = Get-MonkeyCSOMTenant @p
	}
	end {
		if ($sps_tenant_admin_details) {
			$sps_tenant_admin_details.PSObject.TypeNames.Insert(0,'Monkey365.SharePoint.TenantDetails')
			[pscustomobject]$obj = @{
				Data = $sps_tenant_admin_details;
				Metadata = $monkey_metadata;
			}
			$returnData.o365_spo_tenant_admin_details = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Sharepoint Online Tenant Admin details",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = "verbose";
				InformationAction = $O365Object.InformationAction;
                Verbose = $O365Object.Verbose;
				Tags = @('SPSTenantDetailsEmptyResponse');
			}
			Write-Verbose @msg
		}
	}
}




