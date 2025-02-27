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

function Get-MonkeyAZAPIM {
<#
        .SYNOPSIS
		Plugin to get information about Azure API Management

        .DESCRIPTION
		Plugin to get information about Azure API Management

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyAZAPIM
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
			Id = "az00070";
			Provider = "Azure";
			Resource = "APIM";
			ResourceType = $null;
			resourceName = $null;
			PluginName = "Get-MonkeyAZAPIM";
			ApiType = "resourceManagement";
			Title = "Plugin to get information about Azure API Management";
			Group = @("APIM");
			Tags = @{
				"enabled" = $true
			};
			Docs = "https://silverhack.github.io/monkey365/"
		}
		#Get Config
		$APIMConfig = $O365Object.internal_config.ResourceManager | Where-Object { $_.Name -eq "APIManagement" } | Select-Object -ExpandProperty resource
		#Get Storage accounts
		$APIM_objects = $O365Object.all_resources | Where-Object { $_.type -like 'Microsoft.ApiManagement/service' }
        if (-not $APIM_objects) { continue }
		#Set array
		$all_APIM = New-Object System.Collections.Generic.List[System.Object]
	}
	process {
		$msg = @{
			MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Azure API Management",$O365Object.current_subscription.displayName);
			callStack = (Get-PSCallStack | Select-Object -First 1);
			logLevel = 'info';
			InformationAction = $InformationAction;
			Tags = @('AzureAPIManagementInfo');
		}
		Write-Information @msg
        #Check storage accounts
        if($null -ne $APIM_objects -and @($APIM_objects).Count -gt 0){
            foreach($obj in @($APIM_objects)){
                $apimObj = $null;
                try{
                    $msg = @{
				        MessageData = ($message.AzureUnitResourceMessage -f $obj.Name,"API Management");
				        callStack = (Get-PSCallStack | Select-Object -First 1);
				        logLevel = 'info';
				        InformationAction = $O365Object.InformationAction;
				        Tags = @('AzureAPIMInfo');
			        }
			        Write-Information @msg
                    $p = @{
					    Id = $obj.Id;
                        ApiVersion = $APIMConfig.api_version;
                        Verbose = $O365Object.verbose;
                        Debug = $O365Object.debug;
                        InformationAction = $O365Object.InformationAction;
				    }
				    $apimObj = Get-MonkeyAzObjectById @p
                    if($null -ne $apimObj){
                        #Check if infrastructure encryption is enabled
                        if($null -ne $apimObj.properties.apiVersionConstraint.minApiVersion -and $apimObj.properties.apiVersionConstraint.minApiVersion -eq '2019-12-01'){
                            $apimObj | Add-Member NoteProperty -name canReadOnlyUsersReadSecrets -value $false -Force
                        }
                        else{
                            $apimObj | Add-Member NoteProperty -name canReadOnlyUsersReadSecrets -value $true -Force
                        }

                        #Add to array
                        [void]$all_APIM.Add($apimObj)
                    }
                }
                catch{
                    Write-Error $_
                }
            }
        }
	}
	end {
		if ($all_APIM) {
			$all_APIM.PSObject.TypeNames.Insert(0,'Monkey365.Azure.APIM')
			[pscustomobject]$obj = @{
				Data = $all_APIM;
				Metadata = $monkey_metadata;
			}
			$returnData.az_APIM = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Azure API Management",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = "verbose";
				InformationAction = $O365Object.InformationAction;
				Tags = @('AzureAPIMEmptyResponse');
				Verbose = $O365Object.Verbose;
			}
			Write-Verbose @msg
		}
	}
}