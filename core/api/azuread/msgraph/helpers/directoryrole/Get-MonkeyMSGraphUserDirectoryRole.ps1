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


Function Get-MonkeyMSGraphUserDirectoryRole{
    <#
        .SYNOPSIS
		Get User directory role

        .DESCRIPTION
		Get User directory role

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyMSGraphUserDirectoryRole
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true, HelpMessage="User Id")]
        [string]$UserId,

        [parameter(Mandatory=$false)]
        [ValidateSet("v1.0","beta")]
        [String]$APIVersion = "v1.0"
    )
    try{
        #Import Localized data
        $LocalizedDataParams = $O365Object.LocalizedDataParams
        Import-LocalizedData @LocalizedDataParams;
        $Environment = $O365Object.Environment
        #Get Graph Auth
        $graphAuth = $O365Object.auth_tokens.MSGraph
        $msg = @{
            MessageData = ($message.ObjectIdMessageInfo -f "user's", $UserId);
            callStack = (Get-PSCallStack | Select-Object -First 1);
            logLevel = 'debug';
            InformationAction = $InformationAction;
            Tags = @('AzureGraphDirectoryRoleByUserId');
        }
        Write-Debug @msg
        #Get UserObject
        $p = @{
            UserId = $UserId;
            Expand = 'memberOf';
            InformationAction = $O365Object.InformationAction;
            Verbose = $O365Object.verbose;
            Debug = $O365Object.debug;
        }
        $userObject = Get-MonkeyMSGraphUser @p
        if($userObject){
            $objectType = ('users/{0}/transitiveMemberOf' -f $userObject.id)
            $params = @{
                Authentication = $graphAuth;
                ObjectType = $objectType;
                Environment = $Environment;
                ContentType = 'application/json';
                Method = "GET";
                APIVersion = $APIVersion;
                InformationAction = $O365Object.InformationAction;
                Verbose = $O365Object.verbose;
                Debug = $O365Object.debug;
            }
            $permissions = Get-MonkeyMSGraphObject @params | Where-Object {$_.'@odata.type' -eq '#microsoft.graph.directoryRole'}
            if(@($permissions).Count -gt 0){
                #Add to object
                $userObject | Add-Member -type NoteProperty -name directoryRoleInfo -value $permissions -Force
            }
            else{
                $msg = @{
                    MessageData = ($message.RBACPermissionEmptyResponse -f $userObject.userPrincipalName);
                    callStack = (Get-PSCallStack | Select-Object -First 1);
                    logLevel = 'warning';
                    InformationAction = $O365Object.InformationAction;
                    Tags = @('RBACEmptyResponse');
                }
                Write-Warning @msg
                #Add to object
                $userObject | Add-Member -type NoteProperty -name directoryRoleInfo -value $null -Force
            }
            if($null -ne $userObject){
                return $userObject
            }
        }
    }
    catch{
        $msg = @{
            MessageData = ("Unable to get user's directory role information from id {0}" -f $UserId);
            callStack = (Get-PSCallStack | Select-Object -First 1);
            logLevel = 'warning';
            InformationAction = $InformationAction;
            Tags = @('AzureGraphDirectoryRole');
        }
        Write-Warning @msg
        #Set verbose
        $msg.MessageData = $_
        $msg.logLevel = 'Verbose'
        Write-Verbose @msg
    }
}
