# escape=`

ARG REPO=mcr.microsoft.com/dotnet/framework/runtime
FROM $REPO:4.8-20250513-windowsservercore-ltsc2022

RUN dism /Online /Quiet /Enable-Feature /All /FeatureName:IIS-WebServerRole /FeatureName:NetFx4Extended-ASPNET45 /FeatureName:IIS-ASPNET45 `
    && del /q "C:\inetpub\wwwroot\*" `
    && for /D %p IN ("C:\inetpub\wwwroot\*") DO rmdir "%p" /s /q `
    && curl -fSLo ServiceMonitor.exe https://github.com/microsoft/IIS.ServiceMonitor/releases/download/v2.0.1.10/ServiceMonitor.exe `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen update `
    && %windir%\Microsoft.NET\Framework\v4.0.30319\ngen update

# Install 2.9.0 Roslyn compilers
RUN curl -fSLo microsoft.net.compilers.2.9.0.zip https://api.nuget.org/packages/microsoft.net.compilers.2.9.0.nupkg `
    && mkdir C:\RoslynCompilers `
    && tar -C C:\RoslynCompilers -zxf microsoft.net.compilers.2.9.0.zip `
    && del microsoft.net.compilers.2.9.0.zip `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers\tools\csc.exe /ExeConfig:C:\RoslynCompilers\tools\csc.exe `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers\tools\vbc.exe /ExeConfig:C:\RoslynCompilers\tools\vbc.exe `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers\tools\VBCSCompiler.exe /ExeConfig:C:\RoslynCompilers\tools\VBCSCompiler.exe

# Install 3.6.0 Roslyn compilers
RUN curl -fSLo microsoft.net.compilers.3.6.0.zip https://api.nuget.org/packages/microsoft.net.compilers.3.6.0.nupkg `
    && mkdir C:\RoslynCompilers-3.6.0 `
    && tar -C C:\RoslynCompilers-3.6.0 -zxf microsoft.net.compilers.3.6.0.zip `
    && del microsoft.net.compilers.3.6.0.zip `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers-3.6.0\tools\csc.exe /ExeConfig:C:\RoslynCompilers-3.6.0\tools\csc.exe `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers-3.6.0\tools\vbc.exe /ExeConfig:C:\RoslynCompilers-3.6.0\tools\vbc.exe `
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers-3.6.0\tools\VBCSCompiler.exe /ExeConfig:C:\RoslynCompilers-3.6.0\tools\VBCSCompiler.exe

ENV ROSLYN_COMPILER_LOCATION=C:\RoslynCompilers-3.6.0\tools

ENV hostname "leonpc.asuscomm.com"
ENV pfxpw "880816"

WORKDIR /inetpub/wwwroot
RUN mkdir -p C:\inetpub\wwwroot\KaazingChatApi

COPY certs/wildcard.asuscomm.com.pfx /wildcard.asuscomm.com.pfx
COPY certs/ca.cer /ca.cer
COPY certs/Intermediate.cer /Intermediate.cer

ADD install/dotnet-hosting-8.0.16-win.exe C:\install\dotnet-hosting-8.0.16-win.exe
#ADD install/ServiceMonitor.exe C:\ServiceMonitor.exe
ADD System32/avicap32.dll C:\Windows\System32\avicap32.dll
ADD System32/msvfw32.dll C:\Windows\System32\msvfw32.dll
#ADD KaazingChatApi C:\inetpub\wwwroot\KaazingChatApi
COPY etc/hosts C:\Windows\System32\drivers\etc\hosts

SHELL [ "powershell" ]

#setup Remote IIS management
RUN Install-WindowsFeature Web-Mgmt-Service; `
New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force; `
Set-Service -Name wmsvc -StartupType automatic;

#Add user for Remote IIS Manager Login
RUN net user iisadmin 1qaz!QAZ /ADD; `
net localgroup administrators iisadmin /add;

RUN Add-WindowsFeature Web-Server; `
Add-WindowsFeature Web-Http-Tracing; `
Add-WindowsFeature Web-ISAPI-Ext; `
Add-WindowsFeature Web-ISAPI-Filter; `
Add-WindowsFeature Web-Mgmt-Console;

#RUN C:\install\dotnet-hosting-8.0.16-win.exe /install /quiet;

#ENV HOSTING_BUNDLE_URL https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.16/dotnet-hosting-8.0.16-win.exe
#RUN Invoke-WebRequest $env:HOSTING_BUNDLE_URL -OutFile dotnet-hosting.exe; `
#    Start-Process -FilePath .\dotnet-hosting.exe -ArgumentList '/quiet' -Wait; `
#    Remove-Item .\dotnet-hosting.exe -Force

ENV HOSTING_BUNDLE_FILE C:\install\dotnet-hosting-8.0.16-win.exe
RUN Start-Process -FilePath $env:HOSTING_BUNDLE_FILE -ArgumentList '/quiet' -Wait;

RUN Import-Module IISAdministration; `
    $PfxPW = ConvertTo-SecureString -String \"${env:pfxpw}\" -Force -AsPlainText; `
    Import-Certificate -FilePath C:\ca.cer -CertStoreLocation cert:\LocalMachine\Root; `
    Import-Certificate -FilePath C:\Intermediate.cer -CertStoreLocation cert:\LocalMachine\CA; `
    $cert = Import-PfxCertificate -FilePath C:\wildcard.asuscomm.com.pfx -CertStoreLocation cert:\LocalMachine\My -Password $PfxPW; `
    Remove-Item C:\ca.cer; `
    Remove-Item C:\Intermediate.cer; `
    Remove-Item C:\wildcard.asuscomm.com.pfx; `
    $newAppPool = New-WebAppPool -Name "KaazingChatApi" -Force; `
    $newAppPool.managedRuntimeVersion = \"\"; `
    $newAppPool | Set-Item; `
    New-IISSite -Name "KaazingChatWebApi" -BindingInformation "*:8080:" -PhysicalPath "C:\inetpub\wwwroot\KaazingChatApi"; `
    New-IISSiteBinding -Name \"KaazingChatWebApi\" -Protocol https -BindingInformation "*:8081:localhost" -SslFlag Sni -CertificateThumbPrint $cert.Thumbprint -CertStoreLocation "cert:\LocalMachine\My"; `
    New-IISSiteBinding -Name \"KaazingChatWebApi\" -Protocol https -BindingInformation "*:8081:" -CertificateThumbprint $cert.Thumbprint -CertStoreLocation "cert:\LocalMachine\My"; `
    Set-ItemProperty "IIS:\Sites\KaazingChatWebApi" -Name applicationPool -Value "KaazingChatApi";
    #New-IISSiteBinding -Name \"KaazingChatWebApi\" -Protocol https -BindingInformation "127.0.0.1:8081:" -SslFlag Sni -CertificateThumbPrint $cert.Thumbprint -CertStoreLocation "cert:\LocalMachine\My";
    #New-IISSiteBinding -Name \"KaazingChatWebApi\" -Protocol https -BindingInformation \"*:8081:${env:hostname}\" -SslFlag Sni -CertificateThumbPrint $cert.Thumbprint -CertStoreLocation "cert:\LocalMachine\My"; `
    #New-IISSiteBinding -Name \"KaazingChatWebApi\" -Protocol http -BindingInformation "192.168.134.114:8080:";

EXPOSE 8080
EXPOSE 8081
EXPOSE 8172

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]