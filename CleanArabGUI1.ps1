<#
.SYNOPSIS
    Clean Arab Optimizer - Full GUI in PowerShell
    Inspired by ChrisTitusTech WinUtil (https://github.com/ChrisTitusTech/winutil)
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# التحقق من صلاحيات المسؤول
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show("Please run this script as Administrator (Right-Click -> Run with PowerShell)!", "Admin Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    exit
}

# النافذة الرئيسية (Main Form)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Clean Arab Optimizer v2.0 - Powered by WinUtil"
$form.Size = New-Object System.Drawing.Size(950, 700)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

# التبويبات (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = "Fill"
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

# ==========================================
# HELPER: Status Bar
# ==========================================
$statusBar = New-Object System.Windows.Forms.StatusStrip
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready. Run as Administrator for full features."
$statusBar.Items.Add($statusLabel) | Out-Null
$statusBar.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)

function Set-Status($msg) { $statusLabel.Text = $msg }

# ==========================================
# TAB 1: Apps & Drivers
# ==========================================
$tabApps = New-Object System.Windows.Forms.TabPage
$tabApps.Text = "  Apps & Drivers  "
$tabApps.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$listBoxApps = New-Object System.Windows.Forms.ListBox
$listBoxApps.Location = New-Object System.Drawing.Point(20, 20)
$listBoxApps.Size = New-Object System.Drawing.Size(450, 540)
$listBoxApps.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$listBoxApps.ForeColor = [System.Drawing.Color]::White
$listBoxApps.Font = New-Object System.Drawing.Font("Segoe UI", 11)

$apps = [ordered]@{
    "Google Chrome" = "https://raw.githubusercontent.com/Blackhawk501/-Clean-Arab2/main/ChromeSetup%20(1).exe"
    "WinRAR"        = "https://raw.githubusercontent.com/Blackhawk501/-Clean-Arab2/main/winrar-x64-723.exe"
}
foreach ($app in $apps.Keys) { [void]$listBoxApps.Items.Add($app) }

$btnInstallApp = New-Object System.Windows.Forms.Button
$btnInstallApp.Text = "⬇ Download & Install Selected"
$btnInstallApp.Location = New-Object System.Drawing.Point(490, 20)
$btnInstallApp.Size = New-Object System.Drawing.Size(380, 70)
$btnInstallApp.BackColor = [System.Drawing.Color]::FromArgb(0, 122, 204)
$btnInstallApp.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$btnInstallApp.Add_Click({
    if ($listBoxApps.SelectedItem) {
        $appName = $listBoxApps.SelectedItem
        $url = $apps[$appName]
        $fileName = [System.IO.Path]::GetFileName([uri]::UnescapeDataString($url))
        $tempExe = "$env:TEMP\$fileName"
        
        Set-Status "Downloading $appName from GitHub... Please wait."
        try {
            Invoke-WebRequest -Uri $url -OutFile $tempExe -UseBasicParsing
            Set-Status "Download complete. Starting installer..."
            Start-Process $tempExe -Wait
            Set-Status "Installation finished."
            [System.Windows.Forms.MessageBox]::Show("$appName Downloaded and Installation Started!", "Success")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to download $appName. Error: $($_.Exception.Message)", "Error")
            Set-Status "Error installing $appName."
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an app first.", "Info")
    }
})

$labelInfo = New-Object System.Windows.Forms.Label
$labelInfo.Text = "Apps are downloaded directly from the custom GitHub repository (-Clean-Arab2).`nSelect an app and click Download & Install."
$labelInfo.Location = New-Object System.Drawing.Point(490, 110)
$labelInfo.Size = New-Object System.Drawing.Size(380, 50)
$labelInfo.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$labelInfo.ForeColor = [System.Drawing.Color]::LightGray

$tabApps.Controls.AddRange(@($listBoxApps, $btnInstallApp, $labelInfo))

# ==========================================
# TAB 2: System Tweaks & Boost
# ==========================================
$tabTweaks = New-Object System.Windows.Forms.TabPage
$tabTweaks.Text = "  System Tweaks  "
$tabTweaks.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$tweakPanel = New-Object System.Windows.Forms.Panel
$tweakPanel.Dock = "Fill"
$tweakPanel.AutoScroll = $true

function New-TweakBtn($text, $color, $x, $y) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size(390, 55)
    $btn.BackColor = $color
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    return $btn
}

$btnRemoveEdge = New-TweakBtn "☢ Remove Microsoft Edge (Force)" ([System.Drawing.Color]::DarkRed) 30 20
$btnRemoveEdge.Add_Click({
    $msg = [System.Windows.Forms.MessageBox]::Show("Force remove all Edge versions from roots?", "Warning", "YesNo", "Warning")
    if ($msg -eq 'Yes') {
        @("msedge","MicrosoftEdgeUpdate","edge") | ForEach-Object { Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue }
        @("C:\Program Files (x86)\Microsoft\Edge\Application\*\Installer\setup.exe","C:\Program Files (x86)\Microsoft\EdgeUpdate\*\setup.exe") | ForEach-Object {
            $i = Resolve-Path $_ -ErrorAction SilentlyContinue | Select-Object -Last 1
            if ($i) { Start-Process -FilePath $i.Path -ArgumentList "--uninstall --system-level --force-uninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue }
        }
        @("C:\Program Files (x86)\Microsoft\Edge","C:\Program Files (x86)\Microsoft\EdgeUpdate","C:\Program Files (x86)\Microsoft\EdgeCore","C:\Program Files\Microsoft\Edge") | ForEach-Object {
            if (Test-Path $_) { cmd /c "takeown /f `"$_`" /r /d y >nul 2>&1 && icacls `"$_`" /grant administrators:F /t >nul 2>&1"; Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }
        }
        $r = "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"
        if (!(Test-Path $r)) { New-Item $r -Force | Out-Null }
        Set-ItemProperty $r "DoNotUpdateToEdgeWithChromium" 1 -Type DWord -Force
        Set-ItemProperty $r "UpdateDefault" 0 -Type DWord -Force
        Set-Status "Edge removed."; [System.Windows.Forms.MessageBox]::Show("Edge NUKED! ☢️", "Done")
    }
})

$btnCPU = New-TweakBtn "⚡ Optimize CPU (High Performance)" ([System.Drawing.Color]::FromArgb(63,63,70)) 30 90
$btnCPU.Add_Click({
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>$null
    Set-Status "CPU: High Performance plan activated."
    [System.Windows.Forms.MessageBox]::Show("CPU Power Plan set to High/Ultimate Performance!", "Done")
})

$btnPing = New-TweakBtn "🌐 Boost Network & Reduce Ping" ([System.Drawing.Color]::FromArgb(63,63,70)) 30 160
$btnPing.Add_Click({
    ipconfig /flushdns | Out-Null; netsh winsock reset | Out-Null; netsh int tcp set global autotuninglevel=normal | Out-Null
    $rp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $rp) { Set-ItemProperty $rp "NetworkThrottlingIndex" 0xffffffff -Type DWord; Set-ItemProperty $rp "SystemResponsiveness" 0 -Type DWord }
    $tcp = "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters"; if (!(Test-Path $tcp)) { New-Item $tcp -Force | Out-Null }
    Set-ItemProperty $tcp "TCPNoDelay" 1 -Type DWord
    Set-Status "Network boosted!"; [System.Windows.Forms.MessageBox]::Show("Network & Ping Optimized! Restart to fully apply.", "Done")
})

$btnClean = New-TweakBtn "🗑 Clean Temp Files & Junk" ([System.Drawing.Color]::FromArgb(63,63,70)) 30 230
$btnClean.Add_Click({
    @("$env:TEMP\*","$env:windir\Temp\*","$env:windir\Prefetch\*","$env:windir\SoftwareDistribution\Download\*") | ForEach-Object { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }
    Set-Status "Temp files cleaned."; [System.Windows.Forms.MessageBox]::Show("Temp, Prefetch, and Update cache cleaned!", "Done")
})

$btnRestore = New-TweakBtn "🛡 Create System Restore Point" ([System.Drawing.Color]::DarkGreen) 30 300
$btnRestore.Add_Click({
    [System.Windows.Forms.MessageBox]::Show("Creating restore point 'Clean Arab Checkpoint'...", "Info")
    Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
    Checkpoint-Computer -Description "Clean Arab Checkpoint" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
    Set-Status "Restore point created."; [System.Windows.Forms.MessageBox]::Show("Restore Point Created Successfully!", "Success")
})

$btnBing = New-TweakBtn "🔍 Disable Bing Web Search (Faster Start)" ([System.Drawing.Color]::FromArgb(63,63,70)) 30 370
$btnBing.Add_Click({
    $s1 = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    if (!(Test-Path $s1)) { New-Item $s1 -Force | Out-Null }
    Set-ItemProperty $s1 "BingSearchEnabled" 0 -Type DWord; Set-ItemProperty $s1 "CortanaConsent" 0 -Type DWord
    $s2 = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    if (!(Test-Path $s2)) { New-Item $s2 -Force | Out-Null }
    Set-ItemProperty $s2 "DisableSearchBoxSuggestions" 1 -Type DWord
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Set-Status "Bing search disabled."; [System.Windows.Forms.MessageBox]::Show("Web Search Disabled! Start Menu is now lightning fast.", "Done")
})

# WinUtil-inspired tweaks (RIGHT COLUMN)
$btnTelemetry = New-TweakBtn "🕵 Disable Telemetry & Tracking (WinUtil)" ([System.Drawing.Color]::FromArgb(100,30,30)) 460 20
$btnTelemetry.Add_Click({
    # Disable Telemetry
    $telPaths = @(
        @{p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; n="AllowTelemetry"; v=0},
        @{p="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"; n="AllowTelemetry"; v=0},
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; n="TailoredExperiencesWithDiagnosticDataEnabled"; v=0},
        @{p="HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack"; n="Start"; v=4},
        @{p="HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice"; n="Start"; v=4}
    )
    foreach ($t in $telPaths) {
        if (!(Test-Path $t.p)) { New-Item $t.p -Force | Out-Null }
        Set-ItemProperty $t.p $t.n $t.v -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Set-Status "Telemetry disabled."; [System.Windows.Forms.MessageBox]::Show("Windows Telemetry & Tracking DISABLED!", "Done")
})

$btnCopilot = New-TweakBtn "🤖 Disable Copilot & Cortana (WinUtil)" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 90
$btnCopilot.Add_Click({
    $paths = @(
        @{p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"; n="TurnOffWindowsCopilot"; v=1},
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; n="ShowCopilotButton"; v=0},
        @{p="HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Experience"; n="AllowCortana"; v=0}
    )
    foreach ($t in $paths) {
        if (!(Test-Path $t.p)) { New-Item $t.p -Force | Out-Null }
        Set-ItemProperty $t.p $t.n $t.v -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Set-Status "Copilot & Cortana disabled."; [System.Windows.Forms.MessageBox]::Show("Copilot & Cortana Disabled!", "Done")
})

$btnBloat = New-TweakBtn "💣 Remove Windows Bloat Apps (WinUtil)" ([System.Drawing.Color]::FromArgb(100,60,0)) 460 160
$btnBloat.Add_Click({
    $confirm = [System.Windows.Forms.MessageBox]::Show("Remove Xbox, Cortana, Teams, Maps, Mixed Reality, Solitaire, and other bloatware?", "Confirm", "YesNo", "Warning")
    if ($confirm -eq 'Yes') {
        Set-Status "Removing bloatware... please wait."
        $bloatApps = @(
            "Microsoft.3DBuilder","Microsoft.Microsoft3DViewer",
            "Microsoft.BingNews","Microsoft.BingWeather","Microsoft.GetHelp",
            "Microsoft.Getstarted","Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection","Microsoft.MixedReality.Portal",
            "Microsoft.People","Microsoft.SkypeApp","Microsoft.Todos",
            "Microsoft.WindowsFeedbackHub","Microsoft.WindowsMaps",
            "Microsoft.Xbox.TCUI","Microsoft.XboxApp","Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay","Microsoft.XboxIdentityProvider",
            "Microsoft.XboxSpeechToTextOverlay","Microsoft.ZuneMusic","Microsoft.ZuneVideo",
            "MicrosoftTeams","Microsoft.GamingApp"
        )
        foreach ($app in $bloatApps) {
            Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
            Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -Like "*$app*" | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
        }
        Set-Status "Bloatware removed."; [System.Windows.Forms.MessageBox]::Show("Bloatware apps removed successfully!", "Done")
    }
})

$btnPrivacy = New-TweakBtn "🔒 Disable Ads & Privacy Invasions (WinUtil)" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 230
$btnPrivacy.Add_Click({
    $privPaths = @(
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; n="Enabled"; v=0},
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; n="SilentInstalledAppsEnabled"; v=0},
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; n="SubscribedContent-338393Enabled"; v=0},
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; n="SubscribedContent-353696Enabled"; v=0},
        @{p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; n="SystemPaneSuggestionsEnabled"; v=0},
        @{p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; n="DisableWindowsConsumerFeatures"; v=1},
        @{p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; n="DisableCloudOptimizedContent"; v=1}
    )
    foreach ($t in $privPaths) {
        if (!(Test-Path $t.p)) { New-Item $t.p -Force | Out-Null }
        Set-ItemProperty $t.p $t.n $t.v -Type DWord -Force -ErrorAction SilentlyContinue
    }
    Set-Status "Ads & privacy settings applied."; [System.Windows.Forms.MessageBox]::Show("Ads and Privacy Invasions Disabled!", "Done")
})

$btnOneDrive = New-TweakBtn "☁ Remove OneDrive Completely (WinUtil)" ([System.Drawing.Color]::FromArgb(100,30,30)) 460 300
$btnOneDrive.Add_Click({
    $msg = [System.Windows.Forms.MessageBox]::Show("Uninstall OneDrive completely?", "Confirm", "YesNo", "Warning")
    if ($msg -eq 'Yes') {
        Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        @("$env:SystemRoot\SysWOW64\OneDriveSetup.exe /uninstall","$env:SystemRoot\System32\OneDriveSetup.exe /uninstall") | ForEach-Object {
            $parts = $_ -split " ", 2
            if (Test-Path $parts[0]) { Start-Process $parts[0] -ArgumentList $parts[1] -Wait -NoNewWindow -ErrorAction SilentlyContinue }
        }
        @("$env:USERPROFILE\OneDrive","$env:LOCALAPPDATA\Microsoft\OneDrive","$env:PROGRAMDATA\Microsoft OneDrive") | ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
        reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDrive" /f 2>$null
        Set-Status "OneDrive removed."; [System.Windows.Forms.MessageBox]::Show("OneDrive Removed Successfully!", "Done")
    }
})

$btnTaskClean = New-TweakBtn "📋 Clean Scheduled Tasks (WinUtil)" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 370
$btnTaskClean.Add_Click({
    $tasks = @(
        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
        "\Microsoft\Windows\Windows Error Reporting\QueueReporting",
        "\Microsoft\Windows\Autochk\Proxy"
    )
    $removed = 0
    foreach ($task in $tasks) {
        $t = Get-ScheduledTask -TaskPath (Split-Path $task -Parent) -TaskName (Split-Path $task -Leaf) -ErrorAction SilentlyContinue
        if ($t) { Unregister-ScheduledTask -TaskPath $t.TaskPath -TaskName $t.TaskName -Confirm:$false -ErrorAction SilentlyContinue; $removed++ }
    }
    Set-Status "Cleaned $removed scheduled tasks."; [System.Windows.Forms.MessageBox]::Show("Removed $removed telemetry scheduled tasks!", "Done")
})

$tweakPanel.Controls.AddRange(@($btnRemoveEdge,$btnCPU,$btnPing,$btnClean,$btnRestore,$btnBing,$btnTelemetry,$btnCopilot,$btnBloat,$btnPrivacy,$btnOneDrive,$btnTaskClean))
$tabTweaks.Controls.Add($tweakPanel)

# ==========================================
# TAB 3: Startup Apps Manager
# ==========================================
$tabStartup = New-Object System.Windows.Forms.TabPage
$tabStartup.Text = "  Startup Manager  "
$tabStartup.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$listStartup = New-Object System.Windows.Forms.ListView
$listStartup.Location = New-Object System.Drawing.Point(20, 20)
$listStartup.Size = New-Object System.Drawing.Size(880, 530)
$listStartup.View = [System.Windows.Forms.View]::Details
$listStartup.FullRowSelect = $true; $listStartup.GridLines = $true
$listStartup.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$listStartup.ForeColor = [System.Drawing.Color]::White
$listStartup.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$listStartup.Columns.Add("App Name", 250) | Out-Null
$listStartup.Columns.Add("Hive", 80) | Out-Null
$listStartup.Columns.Add("Command / Path", 520) | Out-Null

function Load-Startup {
    $listStartup.Items.Clear()
    $paths = @(
        @{H="HKCU";P="Software\Microsoft\Windows\CurrentVersion\Run"},
        @{H="HKLM";P="SOFTWARE\Microsoft\Windows\CurrentVersion\Run"}
    )
    foreach ($p in $paths) {
        $rp = "$($p.H):\$($p.P)"
        if (Test-Path $rp) {
            $keys = Get-ItemProperty $rp -ErrorAction SilentlyContinue
            if ($keys) {
                foreach ($prop in $keys.psobject.properties) {
                    if ($prop.Name -notin @("PSPath","PSParentPath","PSChildName","PSDrive","PSProvider")) {
                        $item = New-Object System.Windows.Forms.ListViewItem($prop.Name)
                        $item.SubItems.Add($p.H) | Out-Null
                        $item.SubItems.Add($prop.Value.ToString()) | Out-Null
                        $listStartup.Items.Add($item) | Out-Null
                    }
                }
            }
        }
    }
    Set-Status "Startup apps loaded: $($listStartup.Items.Count) items found."
}
Load-Startup

$btnDisableStartup = New-Object System.Windows.Forms.Button
$btnDisableStartup.Text = "✖ Remove Selected from Startup"
$btnDisableStartup.Location = New-Object System.Drawing.Point(20, 565)
$btnDisableStartup.Size = New-Object System.Drawing.Size(350, 50)
$btnDisableStartup.BackColor = [System.Drawing.Color]::DarkRed
$btnDisableStartup.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnDisableStartup.Add_Click({
    if ($listStartup.SelectedItems.Count -gt 0) {
        $sel = $listStartup.SelectedItems[0]; $name = $sel.Text; $hive = $sel.SubItems[1].Text
        $rp = if ($hive -eq "HKCU") { "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" } else { "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" }
        Remove-ItemProperty $rp -Name $name -Force -ErrorAction SilentlyContinue
        Set-Status "$name removed from startup."; [System.Windows.Forms.MessageBox]::Show("$name removed from startup!", "Done")
        Load-Startup
    } else { [System.Windows.Forms.MessageBox]::Show("Please select an app first.", "Info") }
})

$btnRefreshStartup = New-Object System.Windows.Forms.Button
$btnRefreshStartup.Text = "⟳ Refresh"
$btnRefreshStartup.Location = New-Object System.Drawing.Point(390, 565)
$btnRefreshStartup.Size = New-Object System.Drawing.Size(150, 50)
$btnRefreshStartup.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnRefreshStartup.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnRefreshStartup.Add_Click({ Load-Startup })

$tabStartup.Controls.AddRange(@($listStartup, $btnDisableStartup, $btnRefreshStartup))

# ==========================================
# TAB 4: WinUtil Advanced Debloat
# ==========================================
$tabWinUtil = New-Object System.Windows.Forms.TabPage
$tabWinUtil.Text = "  ⚡ WinUtil Debloat  "
$tabWinUtil.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$labelWU = New-Object System.Windows.Forms.Label
$labelWU.Text = "Advanced Debloat & Optimization - Inspired by ChrisTitusTech WinUtil"
$labelWU.Location = New-Object System.Drawing.Point(20, 10)
$labelWU.Size = New-Object System.Drawing.Size(880, 30)
$labelWU.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$labelWU.ForeColor = [System.Drawing.Color]::FromArgb(0,180,255)

$wuPanel = New-Object System.Windows.Forms.Panel
$wuPanel.Location = New-Object System.Drawing.Point(0, 50)
$wuPanel.Size = New-Object System.Drawing.Size(930, 580)
$wuPanel.AutoScroll = $true

function New-WUBtn($text, $color, $x, $y) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text; $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size(420, 55)
    $btn.BackColor = $color; $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    return $btn
}

$btnDarkMode = New-WUBtn "🌙 Enable Dark Mode System-Wide" ([System.Drawing.Color]::FromArgb(50,50,80)) 20 10
$btnDarkMode.Add_Click({
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "AppsUseLightTheme" 0 -Type DWord -Force
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "SystemUsesLightTheme" 0 -Type DWord -Force
    Set-Status "Dark Mode enabled."; [System.Windows.Forms.MessageBox]::Show("Dark Mode Enabled!", "Done")
})

$btnShowExt = New-WUBtn "📁 Show File Extensions in Explorer" ([System.Drawing.Color]::FromArgb(63,63,70)) 20 80
$btnShowExt.Add_Click({
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 -Type DWord -Force
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Set-Status "File extensions shown."; [System.Windows.Forms.MessageBox]::Show("File Extensions are now visible!", "Done")
})

$btnShowHidden = New-WUBtn "👁 Show Hidden Files & Folders" ([System.Drawing.Color]::FromArgb(63,63,70)) 20 150
$btnShowHidden.Add_Click({
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 -Type DWord -Force
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Set-Status "Hidden files visible."; [System.Windows.Forms.MessageBox]::Show("Hidden Files are now visible!", "Done")
})

$btnNumLock = New-WUBtn "🔢 Enable NumLock on Startup" ([System.Drawing.Color]::FromArgb(63,63,70)) 20 220
$btnNumLock.Add_Click({
    Set-ItemProperty "HKCU:\Control Panel\Keyboard" "InitialKeyboardIndicators" "2" -Force
    Set-Status "NumLock on startup enabled."; [System.Windows.Forms.MessageBox]::Show("NumLock will be ON at every startup!", "Done")
})

$btnDisableWU = New-WUBtn "🔄 Disable Windows Auto Updates" ([System.Drawing.Color]::FromArgb(100,60,0)) 20 290
$btnDisableWU.Add_Click({
    $msg = [System.Windows.Forms.MessageBox]::Show("Disable Windows automatic updates? (You can still update manually)", "Confirm", "YesNo", "Warning")
    if ($msg -eq 'Yes') {
        $wu = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        if (!(Test-Path $wu)) { New-Item $wu -Force | Out-Null }
        Set-ItemProperty $wu "NoAutoUpdate" 1 -Type DWord -Force
        Set-ItemProperty $wu "AUOptions" 1 -Type DWord -Force
        Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
        Set-Service wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
        Set-Status "Windows Update disabled."; [System.Windows.Forms.MessageBox]::Show("Windows Auto-Updates DISABLED!", "Done")
    }
})

$btnEnableWU = New-WUBtn "✅ Re-Enable Windows Auto Updates" ([System.Drawing.Color]::DarkGreen) 20 360
$btnEnableWU.Add_Click({
    $wu = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (Test-Path $wu) { Remove-ItemProperty $wu "NoAutoUpdate" -Force -ErrorAction SilentlyContinue; Remove-ItemProperty $wu "AUOptions" -Force -ErrorAction SilentlyContinue }
    Set-Service wuauserv -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service wuauserv -ErrorAction SilentlyContinue
    Set-Status "Windows Update re-enabled."; [System.Windows.Forms.MessageBox]::Show("Windows Updates Re-Enabled!", "Done")
})

$btnDisableNotif = New-WUBtn "🔕 Disable Notification Banners" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 10
$btnDisableNotif.Add_Click({
    $np = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"
    if (!(Test-Path $np)) { New-Item $np -Force | Out-Null }
    Set-ItemProperty $np "ToastEnabled" 0 -Type DWord -Force
    Set-Status "Notifications disabled."; [System.Windows.Forms.MessageBox]::Show("Notification Banners Disabled!", "Done")
})

$btnEnableNotif = New-WUBtn "🔔 Re-Enable Notifications" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 80
$btnEnableNotif.Add_Click({
    $np = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"
    if (!(Test-Path $np)) { New-Item $np -Force | Out-Null }
    Set-ItemProperty $np "ToastEnabled" 1 -Type DWord -Force
    Set-Status "Notifications enabled."; [System.Windows.Forms.MessageBox]::Show("Notifications Re-Enabled!", "Done")
})

$btnVBS = New-WUBtn "🔓 Disable VBS & Core Isolation (FPS Boost)" ([System.Drawing.Color]::FromArgb(100,30,30)) 460 150
$btnVBS.Add_Click({
    $msg = [System.Windows.Forms.MessageBox]::Show("Disable VBS (Virtualization Based Security)? This can boost FPS in games but reduces some security.", "Confirm", "YesNo", "Warning")
    if ($msg -eq 'Yes') {
        $vbs = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
        if (!(Test-Path $vbs)) { New-Item $vbs -Force | Out-Null }
        Set-ItemProperty $vbs "EnableVirtualizationBasedSecurity" 0 -Type DWord -Force
        Set-Status "VBS disabled. Restart required."; [System.Windows.Forms.MessageBox]::Show("VBS Disabled! Restart PC to apply (may boost FPS).", "Done")
    }
})

$btnGPUTweak = New-WUBtn "🎮 Gaming GPU Priority Tweak" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 220
$btnGPUTweak.Add_Click({
    $gp = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
    if (!(Test-Path $gp)) { New-Item $gp -Force | Out-Null }
    Set-ItemProperty $gp "GPU Priority" 8 -Type DWord -Force
    Set-ItemProperty $gp "Priority" 6 -Type DWord -Force
    Set-ItemProperty $gp "Scheduling Category" "High" -Force
    Set-Status "GPU gaming priority set."; [System.Windows.Forms.MessageBox]::Show("GPU Gaming Priority Tweaked!", "Done")
})

$btnMouseFix = New-WUBtn "🖱 Disable Mouse Acceleration (Raw Input)" ([System.Drawing.Color]::FromArgb(63,63,70)) 460 290
$btnMouseFix.Add_Click({
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseSpeed" "0" -Force
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0" -Force
    Set-ItemProperty "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0" -Force
    Set-Status "Mouse acceleration disabled."; [System.Windows.Forms.MessageBox]::Show("Mouse Acceleration Disabled! Raw Input is now active.", "Done")
})

$btnSvcClean = New-WUBtn "🛑 Stop Heavy Background Services (WinUtil)" ([System.Drawing.Color]::FromArgb(100,30,30)) 460 360
$btnSvcClean.Add_Click({
    $svcs = @("SysMain","DiagTrack","WSearch","RetailDemo","TabletInputService")
    foreach ($svc in $svcs) {
        Stop-Service $svc -Force -ErrorAction SilentlyContinue
        Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
    }
    Set-Status "Heavy services stopped."; [System.Windows.Forms.MessageBox]::Show("Heavy background services stopped and disabled!", "Done")
})

$wuPanel.Controls.AddRange(@($btnDarkMode,$btnShowExt,$btnShowHidden,$btnNumLock,$btnDisableWU,$btnEnableWU,$btnDisableNotif,$btnEnableNotif,$btnVBS,$btnGPUTweak,$btnMouseFix,$btnSvcClean))
$tabWinUtil.Controls.Add($labelWU)
$tabWinUtil.Controls.Add($wuPanel)

# ==========================================
# TAB 5: Gaming & Fixes (New!)
# ==========================================
$tabFixes = New-Object System.Windows.Forms.TabPage
$tabFixes.Text = "  🎮 Gaming & Fixes  "
$tabFixes.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$fixesPanel = New-Object System.Windows.Forms.Panel
$fixesPanel.Dock = "Fill"
$fixesPanel.AutoScroll = $true

$btnWin10Menu = New-WUBtn "🖱 Restore Win 10 Classic Context Menu" ([System.Drawing.Color]::FromArgb(63,63,70)) 20 20
$btnWin10Menu.Add_Click({
    New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value "" -Force
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Set-Status "Win 10 Context Menu enabled."
    [System.Windows.Forms.MessageBox]::Show("Windows 10 Classic Context Menu restored!", "Done")
})

$btnWin11Menu = New-WUBtn "♻️ Revert to Win 11 Modern Menu" ([System.Drawing.Color]::FromArgb(63,63,70)) 20 90
$btnWin11Menu.Add_Click({
    Remove-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" -Recurse -Force -ErrorAction SilentlyContinue
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Set-Status "Win 11 Context Menu restored."
    [System.Windows.Forms.MessageBox]::Show("Windows 11 Modern Context Menu restored!", "Done")
})

$btnVCRedist = New-WUBtn "🛠 Install Visual C++ Redist (All-in-One)" ([System.Drawing.Color]::FromArgb(0,122,204)) 20 160
$btnVCRedist.Add_Click({
    Set-Status "Installing VCRedist..."
    Start-Process "cmd.exe" -ArgumentList "/c winget install --id Microsoft.VCRedist.2015+.x64 -e --accept-package-agreements --accept-source-agreements" -Wait
    Set-Status "VCRedist installed."
    [System.Windows.Forms.MessageBox]::Show("Visual C++ Redistributable Installed!", "Done")
})

$btnDirectX = New-WUBtn "🎮 Install DirectX (For Gaming)" ([System.Drawing.Color]::FromArgb(0,122,204)) 20 230
$btnDirectX.Add_Click({
    Set-Status "Installing DirectX..."
    Start-Process "cmd.exe" -ArgumentList "/c winget install --id Microsoft.DirectX -e --accept-package-agreements --accept-source-agreements" -Wait
    Set-Status "DirectX installed."
    [System.Windows.Forms.MessageBox]::Show("DirectX Installation Started/Completed!", "Done")
})

$btnSFC = New-WUBtn "🩺 Repair Windows Corrupt Files (SFC & DISM)" ([System.Drawing.Color]::FromArgb(100,30,30)) 460 20
$btnSFC.Add_Click({
    Set-Status "Running SFC & DISM..."
    [System.Windows.Forms.MessageBox]::Show("This will open a black window and take 5-10 minutes. Let it finish!", "Info")
    Start-Process "cmd.exe" -ArgumentList "/c DISM /Online /Cleanup-Image /RestoreHealth && sfc /scannow && pause"
    Set-Status "System repair command launched."
})

$btnNetReset = New-WUBtn "🌐 Deep Network Reset (Fix Connection)" ([System.Drawing.Color]::FromArgb(100,60,0)) 460 90
$btnNetReset.Add_Click({
    Start-Process "cmd.exe" -ArgumentList "/c ipconfig /release && ipconfig /renew && ipconfig /flushdns && netsh winsock reset && netsh int ip reset && pause"
    Set-Status "Network reset performed."
    [System.Windows.Forms.MessageBox]::Show("Deep Network Reset initiated! Restart PC to take full effect.", "Done")
})

$fixesPanel.Controls.AddRange(@($btnWin10Menu, $btnWin11Menu, $btnVCRedist, $btnDirectX, $btnSFC, $btnNetReset))
$tabFixes.Controls.Add($fixesPanel)

# ==========================================
# Build Form
# ==========================================
$tabControl.Controls.AddRange(@($tabApps, $tabTweaks, $tabStartup, $tabWinUtil, $tabFixes))
$form.Controls.Add($tabControl)
$form.Controls.Add($statusBar)

$form.ShowDialog() | Out-Null
