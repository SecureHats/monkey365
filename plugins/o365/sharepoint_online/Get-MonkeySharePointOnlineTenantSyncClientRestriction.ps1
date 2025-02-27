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


function Get-MonkeySharePointOnlineTenantSyncClientRestriction {
<#
        .SYNOPSIS
		Plugin to get information about SPS Tenant Sync Client Restriction

        .DESCRIPTION
		Plugin to get information about SPS Tenant Sync Client Restriction

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeySharePointOnlineTenantSyncClientRestriction
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
			Id = "sps0011";
			Provider = "Microsoft365";
			Resource = "SharePointOnline";
			ResourceType = $null;
			resourceName = $null;
			PluginName = "Get-MonkeySharePointOnlineTenantSyncClientRestriction";
			ApiType = "CSOM";
			Title = "Plugin to get information about SPS Tenant Sync Client Restriction";
			Group = @("SharePointOnline");
			Tags = @{
				"enabled" = $true
			};
			Docs = "https://silverhack.github.io/monkey365/"
		}
        #Set null
        $sps_tenant_sync_info = $null
	}
	process {
        if($O365Object.isSharePointAdministrator){
		    $msg = @{
			    MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Sharepoint Online Tenant Sync Client restriction",$O365Object.TenantID);
			    callStack = (Get-PSCallStack | Select-Object -First 1);
			    logLevel = 'info';
			    InformationAction = $O365Object.InformationAction;
			    Tags = @('SPSTenantSyncInfo');
		    }
		    Write-Information @msg
            $p = @{
                InformationAction = $O365Object.InformationAction;
                Verbose = $O365Object.verbose;
                Debug = $O365Object.debug;
            }
            $sps_tenant_sync_info = Get-MonkeyCSOMTenantSyncClientRestriction @p
        }
	}
	end {
		if ($sps_tenant_sync_info) {
			$sps_tenant_sync_info.PSObject.TypeNames.Insert(0,'Monkey365.SharePoint.Tenant.SyncClientRestriction')
			[pscustomobject]$obj = @{
				Data = $sps_tenant_sync_info;
				Metadata = $monkey_metadata;
			}
			$returnData.o365_spo_tenant_sync_restrictions = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Sharepoint Online Tenant Sync Client Restriction",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = "verbose";
				InformationAction = $O365Object.InformationAction;
                Verbose = $O365Object.Verbose;
				Tags = @('SPSTenantSyncEmptyResponse');
			}
			Write-Verbose @msg
		}
	}
}




