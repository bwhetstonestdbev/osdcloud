$username = 'SBCAdmin'
$password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force
New-LocalUser -Name $username -Password P@ssw0rd -FullName $username -Description 'Local Admin Account' 
Add-LocalGroupMember -Group "Administrators" -Member $username