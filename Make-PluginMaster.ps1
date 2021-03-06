$ErrorActionPreference = 'SilentlyContinue'

$output = New-Object Collections.Generic.List[object]
$notInclude = "sdfg", "dhfnf", "XIVStats", "TitleEdit";

$counts = Get-Content "downloadcounts.json" | ConvertFrom-Json

$table = ""

Get-ChildItem -Path plugins -File -Recurse -Include *.json |
Foreach-Object {
    $content = Get-Content $_.FullName | ConvertFrom-Json

    if ($notInclude.Contains($content.InternalName)) { 
    	$content | add-member -Name "IsHide" -value "True" -MemberType NoteProperty
    }
    else
    {
    	$content | add-member -Name "IsHide" -value "False" -MemberType NoteProperty
    	$table = $table + "| " + $content.Author + " | " + $content.Name + " | " + $content.Description + " |`n"
    }

    $dlCount = $counts | Select-Object -ExpandProperty $content.InternalName | Select-Object -ExpandProperty "count" 

    if ($dlCount -eq $null){
        $dlCount = 0;
    }

    $content | add-member -Name "DownloadCount" $dlCount -MemberType NoteProperty

    $output.Add($content)
}

$outputStr = $output | ConvertTo-Json
Write-Output $outputStr

Out-File -FilePath .\pluginmaster.json -InputObject $outputStr

$template = Get-Content -Path mdtemplate.txt
$template = $template + $table
Out-File -FilePath .\plugins.md -InputObject $template
