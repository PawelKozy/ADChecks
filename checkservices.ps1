# Import the Active Directory module
Import-Module ActiveDirectory

# Fetch all OUs named "Service Accounts"
$serviceAccountOUs = Get-ADOrganizationalUnit -Filter 'Name -like "Service Accounts"'

# Initialize an empty list to store the non-MSA/gMSA service accounts
$nonManagedServiceAccounts = @()

# Go through all the "Service Accounts" OUs
foreach ($ou in $serviceAccountOUs) {
    # Fetch all user accounts from this OU
    $allAccounts = Get-ADUser -SearchBase $ou.DistinguishedName -Filter *

    # Go through all the accounts
    foreach ($account in $allAccounts) {
        # Fetch the account with additional properties
        $detailedAccount = Get-ADUser -Identity $account.SamAccountName -Properties *

        # Check if the account is a MSA or gMSA and is a normal user account (not a computer account, etc.)
        if (($detailedAccount.ObjectClass -ne "msDS-ManagedServiceAccount" -and $detailedAccount.ObjectClass -ne "msDS-GroupManagedServiceAccount") -and $detailedAccount.SamAccountType -eq 805306368) {
            # This account is not a MSA or gMSA and is a normal user account, so add it to the list with the OU name
            $nonManagedServiceAccounts += New-Object PSObject -Property @{
                'Name' = $account.Name
                'OU'   = $ou.Name
            }
        }
    }
}

# Print out the non-MSA/gMSA service accounts
$nonManagedServiceAccounts | Format-Table Name, OU
