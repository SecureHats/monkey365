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


function Get-MonkeyTeamsSkypeMeetingPolicy {
<#
        .SYNOPSIS
		Plugin to get information about Teams meeting policies (Skype)

        .DESCRIPTION
		Plugin to get information about Teams meeting policies (Skype)

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyTeamsSkypeMeetingPolicy
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
			Id = "teams09";
			Provider = "Microsoft365";
			Resource = "MicrosoftTeams";
			ResourceType = $null;
			resourceName = $null;
			PluginName = "Get-MonkeyTeamsSkypeMeetingPolicy";
			ApiType = $null;
			Title = "Plugin to get information about Teams meeting policies (Skype)";
			Group = @("MicrosoftTeams");
			Tags = @{
				"enabled" = $true
			};
			Docs = "https://silverhack.github.io/monkey365/"
		}
		#Getting environment
		$Environment = $O365Object.Environment
		#Get Access Token from Teams
		$access_token = $O365Object.auth_tokens.Teams
		$meeting_policies = $null
	}
	process {
		if ($null -ne $access_token) {
			$msg = @{
				MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId,"Microsoft 365 Teams: Skype meeting policies",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = 'info';
				InformationAction = $InformationAction;
				Tags = @('TeamsMeetingPolicies');
			}
			Write-Information @msg
			$p = @{
				Authentication = $access_token;
				InternalPath = 'SkypePolicy';
				ObjectType = "configurations";
				ObjectId = 'TeamsMeetingPolicy';
				Environment = $Environment;
				InformationAction = $O365Object.InformationAction;
                Verbose = $O365Object.verbose;
                Debug = $O365Object.debug;
			}
			$meeting_policies = Get-MonkeyTeamsObject @p
		}
	}
	end {
		if ($meeting_policies) {
			$meeting_policies.PSObject.TypeNames.Insert(0,'Monkey365.Teams.Skype.Meeting.Policies')
			[pscustomobject]$obj = @{
				Data = $meeting_policies;
				Metadata = $monkey_metadata;
			}
			$returnData.o365_teams_skype_meeting_policies = $obj
		}
		else {
			$msg = @{
				MessageData = ($message.MonkeyEmptyResponseMessage -f "Microsoft 365 Teams= Skype meeting policies",$O365Object.TenantID);
				callStack = (Get-PSCallStack | Select-Object -First 1);
				logLevel = "verbose";
				InformationAction = $O365Object.InformationAction;
				Tags = @('TeamsSkypeMeetingPoliciesEmptyResponse');
				Verbose = $O365Object.Verbose;
			}
			Write-Verbose @msg
		}
	}
}




