(get-host).ui.rawui.backgroundcolor = "black"
(get-host).ui.rawui.foregroundcolor = "green"
$progressPreference = 'silentlyContinue' 
cls
function AnyKey {
	Write-Host "Press Any Key To Continue... "
	$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
write-host " "
write-host " "
write-host "################################################################################################################" -foregroundcolor "darkgreen"
Write-host "   before you continue disable 2factor athentification on https://robertsspaceindustries.com/account/security   "
Write-host "                                                                                                                "
Write-host "                                          twitch.tv/RubberDolly                                                 "  
write-host "################################################################################################################" -foregroundcolor "darkgreen"
write-host " "
write-host " "
AnyKey
write-host " "
write-host " "
$username = read-host "enter handle"
$password = read-host "enter password"-AsSecureString
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
cls
$login = (Invoke-RestMethod -Uri "https://robertsspaceindustries.com/api/account/signin" -Body "{`"username`":`"$username`",`"password`":`"$password`",`"remember`":`"null`"}" -Method POST -ContentType "application/json" -SessionVariable 'session')
write-host "##############################################################################" -foregroundcolor "darkgreen"
$OutputList = New-Object System.Collections.Generic.List[object]
$bburl = 'https://robertsspaceindustries.com/account/buy-back-pledges?page=1&pagesize=1'
$bbRequest = (Invoke-WebRequest -Uri $bburl -websession $session)
$getBBAmount = ((($bbRequest.Links | Where {$_.Class -like "*raquo btn*"} | select -expand href) -split ('&'))[0] -split ('='))[1] -join ""
$getBBAmount = $getBBAmount
for ($i=0; $i -lt $getBBAmount; $i++) {
	$page = $i+1
	$pageURL = "https://robertsspaceindustries.com/account/buy-back-pledges?page=$page&pagesize=1"
	$bbPage = (Invoke-WebRequest -Uri $pageURL -websession $session)
	$checkHref = $bbPage.Links | Where {$_.Class -like "*holosmallbtn*"} | select -expand href
	$checkCCU = ([Regex]::Matches($bbPage.Content, '(?<=<h1>)(.*?)(?=</h1>)') | select -Skip 1 -expand value) -replace "(<.*?>)" -split '\r?\n'
	if ($checkHref) {
		$itemURL = "https://robertsspaceindustries.com" + $checkHref
		$newRequest = (Invoke-WebRequest -Uri $itemURL -websession $session)
		$item =  ($newRequest.ParsedHtml.DocumentElement.GetElementsByTagName('h2') | Where {$_.ClassName -match '\bbuy-back-title\b'}).InnerText
		$itemValue = (((($newRequest.ParsedHtml.DocumentElement.GetElementsByTagName('div') | Where {$_.ClassName -match '\bprice\b'}).InnerText).split(" "))[0..1]) -join " "
		write-host $pageURL -foregroundcolor "cyan"
		write-host $itemURL -foregroundcolor "cyan" 
		write-host $item
		write-host $itemValue -foregroundcolor "yellow"
		$Obj =  New-Object Psobject -Property @{Number = $page; Ship = "$item"; Value = "$itemValue"; URL = "$pageURL"}
		$OutputList.add($obj)
		write-host "##############################################################################" -foregroundcolor "darkgreen"
	} elseif ($checkCCU) {
		$item = $checkCCU
		write-host $pageURL -foregroundcolor "cyan"
		write-host $item -foregroundcolor "darkred"
		write-host "new ccu detected" -foregroundcolor "red"
		$Obj =  New-Object Psobject -Property @{Number = $page; Ship = "$item"; Value = ""; URL = "$pageURL"}
		$OutputList.add($obj)
		write-host "##############################################################################" -foregroundcolor "darkgreen"
	} else {
		
	} 
	clear-variable checkHref
	clear-variable item
	clear-variable itemValue
	clear-variable itemURL
}
$OutputList | out-gridview
AnyKey