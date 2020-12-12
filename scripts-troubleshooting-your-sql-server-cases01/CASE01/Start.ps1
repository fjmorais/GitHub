Get-ChildItem "C:\Scripts\Case01\output" | Remove-Item -Recurse -ErrorAction SilentlyContinue

$Block01 = 
{
    Start-Sleep -Seconds 0
    $Block = "Block01"
    $LogFile = "C:\Scripts\Case01\Log\$Block.log"
    Remove-Item $LogFile -ErrorAction SilentlyContinue
    "Iniciou $Block" | Out-File -FilePath $LogFile -Append

    foreach ($loop in 1..10000) {
        $n = Get-Random -Minimum 1 -Maximum 5 #número de conexões
        $r = Get-Random -Minimum 1 -Maximum 5 #número de iterações por conexão
        $i = Get-Random -Minimum 100 -Maximum 1000 #intervalo de tempo em milisegundos entre cada iteração do LOOP

        $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $Message = "$Date INFO loop: $loop conexao: $n iteracao: $r intervalo: $i"

        "$Message" | Out-File -FilePath $LogFile -Append

        Start-Process "ostress.exe" -ArgumentList "-SEC2AMAZ-N9T8T09", "-dStackOverflow50", "-E", "-itsql01.sql", "-n$n", "-r$r", "-q", "-ooutput\$Block-$loop.log" -WindowStyle Hidden -WorkingDirectory "C:\Scripts\Case01"
        Start-Sleep -Milliseconds $i
    }
}

$Block02 = 
{
    Start-Sleep -Seconds 10
    $Block = "Block02"
    $LogFile = "C:\Scripts\Case01\Log\$Block.log"
    Remove-Item $LogFile -ErrorAction SilentlyContinue
    "Iniciou $Block" | Out-File -FilePath $LogFile -Append

    foreach ($loop in 1..10000) {
        #Configuracaoes que causam 100% cpu
        #$n = 12 
        #$r = 8
        $n = Get-Random -Minimum 8 -Maximum 12 #número de conexões
        $r = Get-Random -Minimum 8 -Maximum 12 #número de iterações por conexão
        $i = Get-Random -Minimum 8000 -Maximum 12000 #intervalo de tempo em milisegundos entre cada iteração do LOOP

        $Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        $Message = "$Date INFO loop: $loop conexao: $n iteracao: $r intervalo: $i"

        "$Message" | Out-File -FilePath $LogFile -Append

        Start-Process "ostress.exe" -ArgumentList "-SEC2AMAZ-N9T8T09", "-dStackOverflow50", "-E", "-itsql02.sql", "-n$n", "-r$r", "-q", "-ooutput\$Block-$loop.log" -WindowStyle Hidden -WorkingDirectory "C:\Scripts\Case01"
        Start-Sleep -Milliseconds $i
    }
}

Start-Job -ScriptBlock $Block01
Start-Job -ScriptBlock $Block02