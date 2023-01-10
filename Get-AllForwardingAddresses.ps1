function Get-AllForwardingAddresses {
    [CmdletBinding()]
    param (
        $OutputFolder = "\\srv-file\PowerShell-Scripte\2-Exchange\Get-AllForwardingAddresses",
        $OutputTextFile = "ForwardingAddresses.txt"
    )
    
    Connect-ExchangeOnline -ShowBanner:$false

    Clear-Host

    $AllForwardingAddresses = Get-Mailbox | Where {$_.ForwardingAddress -ne $null} | Select Name, PrimarySmtpAddress, ForwardingAddress, DeliverToMailboxAndForward
    
    $AllMailAddressesOnThisTenant = Get-Mailbox -Identity *
    $AllMailContactsOnThisTenant = Get-MailContact
    $AllForwardingAddressesReadable = @()
    
    foreach ($FWAddr in $AllForwardingAddresses) {
        $TempSMTPAddress = ""
        foreach ($Addr in $AllMailAddressesOnThisTenant) {
            if($Addr.Name -like $FWAddr.ForwardingAddress) {
                $TempSMTPAddress = $Addr.PrimarySmtpAddress
            }
        }

        foreach ($Cont in $AllMailContactsOnThisTenant) {
            if($Cont.Name -like $FWAddr.ForwardingAddress) {
                $TempSMTPAddress = $Cont.WindowsEmailAddress
            }
        }

        $AllForwardingAddressesReadable += New-Object -TypeName PSObject -Property @{
            'MailAddress'       = $FWAddr.PrimarySmtpAddress
            'ForwardingAddress' = $TempSMTPAddress
        }
    }
    

    Write-Output $AllForwardingAddressesReadable
    $AllForwardingAddressesReadable | Out-File "$OutputFolder\$OutputTextFile"

    Disconnect-ExchangeOnline -Confirm:$false
}

Get-AllForwardingAddresses
