Function Test-Port {
    param (
        [string]$targetHost,
        [int]$port
    )
    
    $connection = New-Object System.Net.Sockets.TcpClient
    $connection.ConnectAsync($targetHost, $port) | Out-Null
    Start-Sleep -Milliseconds 500
    if ($connection.Connected) {
        $connection.Close()
        return $true
    } else {
        return $false
    }
}

Function Scan-Ports {
    param (
        [string]$targetHost,
        [int[]]$ports = (1..1024)
    )
    
    foreach ($port in $ports) {
        if (Test-Port -targetHost $targetHost -port $port) {
            Write-Host "Port $port is open on $targetHost" -ForegroundColor Green
        } else {
            Write-Host "Port $port is closed on $targetHost" -ForegroundColor Red
        }
    }
}

Function Show-Menu {
    Param (
        [String]$MenuName
    )

    $MenuOptions = @(
        @{Option = '1'; Description = 'Scan common ports'; Command = { 
            $targetHost = Read-Host "Enter the target host"
            Scan-Ports -targetHost $targetHost -ports (22, 80, 443, 3389)
        } },
        @{Option = '2'; Description = 'Scan custom ports'; Command = { 
            $targetHost = Read-Host "Enter the target host"
            $ports = Read-Host "Enter the ports to scan (comma-separated)" -Split ',' | ForEach-Object { [int]$_.Trim() }
            Scan-Ports -targetHost $targetHost -ports $ports
        } },
        @{Option = '3'; Description = 'Exit'; Command = { return } }
    )

    Write-Host "`n$MenuName"
    $MenuOptions | ForEach-Object { Write-Host "$($_.Option). $($_.Description)" }

    $selection = Read-Host "Choose an option"
    $selectedOption = $MenuOptions | Where-Object { $_.Option -eq $selection }

    if ($selectedOption) {
        & $selectedOption.Command
        if ($selection -ne '3') {
            Show-Menu -MenuName $MenuName
        }
    } else {
        Write-Host "Invalid selection, please try again." -ForegroundColor Red
        Show-Menu -MenuName $MenuName
    }
}

# Start the interactive menu
Show-Menu -MenuName "TCP Port Scanner Menu"
