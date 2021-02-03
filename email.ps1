#$cred=Get-Credential $env:computername"\Administrator"
#$mail=Get-Credential asarat@centermed.pl

$cred=Get-StoredCredential -Target admin
$mail=Get-StoredCredential -Target mail

#$mailto=Read-Host -Prompt 'Mail odbiorcy'

$array="103","160","125","177"
$array2="154","189"
$text=""
$text2=""

$head = @"
<style type="text/css">
tr:nth-child(even) {
	background-color: #f2f2f2;
}
tr:nth-child(odd) {
	background-color: #ccc;
}
table {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
th {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
td {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

$utf8 = New-Object System.Text.utf8encoding

function Replica
{
for ($i=0; $i -le $array.Length -1 ;$i++)
{
$ip="192.168.1."+$array[$i]

get-vmreplication -computername $ip -credential $cred
}
for ($i=0; $i -le $array2.Length -1 ;$i++ )
{
$ip2="192.168.111."+$array2[$i]
get-vmreplication -computername $ip2 -credential $cred
}
}

Function Errors
{
for ($i=0; $i -le $array.Length -1 ;$i++)
{
$ip="192.168.1."+$array[$i]
$ip2="192.168.111."

if((get-vmreplication -computername $ip -credential $cred).ReplicationHealth -ne "Normal")
{

get-vmreplication -computername $ip -ReplicationHealth Warning -credential $cred | Select Name,State,Health,Mode,PrimaryServer,ReplicaServer
get-vmreplication -computername $ip -ReplicationHealth Critical -credential $cred | Select Name,State,Health,Mode,PrimaryServer,ReplicaServer
}

}
Start-Sleep -s 150
}




for(;;)
{

#if(-not (Test-path C:\Users\$env:username\Desktop\replikacja) )
#{
#New-Item -Path "C:\Users\$env:username\Desktop\" -Name "replikacja" -ItemType "directory"
#
#$file_array="replica","errors","errors2"
#
#for($i=0;$i -le $file_array.Length -1;$i++)
#{
#New-Item -Path "C:\Users\$env:username\Desktop\replikacja\"+($file_array[$i]+".txt") -ItemType File 
#}
#
#}

#else
#{
$out = Replica | Out-String

Errors > C:\Users\$env:username\Desktop\replikacja\errors.txt

$text= Get-Content C:\Users\$env:username\Desktop\replikacja\errors.txt
$text2 = Get-Content C:\Users\$env:username\Desktop\replikacja\errors2.txt

if($text -eq $null)
{
$text="empty"
}

if($text.length -eq $text2.length)
{

#Write-Host "Nie trzeba"
Start-Sleep -s 5
cls
$out
(Get-Date).DateTime

}
else
{
Write-Host "Wysylam maila"

#$body= Get-Content C:\Users\$env:username\Desktop\replikacja\errors.txt | Out-String

$body= Errors | ConvertTo-Html -Head $head| Out-File -FilePath C:\Users\$env:username\Desktop\replikacja\Critical.html
$body= Get-Content  C:\Users\$env:username\Desktop\replikacja\Critical.html -Raw

#Send-MailMessage -To @("asarat@centermed.pl") -From $env:username@centermed.pl  -Subject Replikacja -Body $body -Credential $mail -SmtpServer serwer1447049.home.pl -Port 587
Send-MailMessage -To @("it@centermed.pl") -From asarat@centermed.pl  -Subject "Błędy replikacji BETA" -Body $body"<br /><br />Wiadomość wygenerowana automatycznie." -BodyAsHtml -Credential $mail -SmtpServer serwer1447049.home.pl -Port 587 -encoding $utf8

$text2=$text
$text2 > C:\Users\$env:username\Desktop\replikacja\errors2.txt

}
}


#}