﻿# TeamsCallHoldPolicy

## Parameters

| Parameter | Attribute | DataType | Description | Allowed Values |
| --- | --- | --- | --- | --- |
| **Identity** | Key | String | Unique identifier to be assigned to the new Teams call hold policy. Use the 'Global' Identity if you wish to assign this policy to the entire tenant. | |
| **AudioFileId** | Write | String | A string representing the ID referencing an audio file uploaded via the Import-CsOnlineAudioFile cmdlet. | |
| **Description** | Write | String | Enables administrators to provide explanatory text to accompany a Teams call hold policy. | |
| **Ensure** | Write | String | Present ensures the instance exists, absent ensures it is removed. | `Present`, `Absent` |
| **Credential** | Write | PSCredential | Credentials of the workload's Admin | |
| **ApplicationId** | Write | String | Id of the Azure Active Directory application to authenticate with. | |
| **TenantId** | Write | String | Id of the Azure Active Directory tenant used for authentication. | |
| **CertificateThumbprint** | Write | String | Thumbprint of the Azure Active Directory application's authentication certificate to use for authentication. | |


## Description

Creates a new Teams call hold policy in your tenant. The Teams call hold policy is used to customize the call hold experience for Teams clients.

## Permissions


