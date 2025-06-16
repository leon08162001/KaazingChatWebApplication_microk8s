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

ENV hostname "leonpc.asuscomm.com"
ENV pfxpw "880816"

WORKDIR /inetpub/wwwroot
RUN mkdir -p C:\inetpub\wwwroot\KaazingChatWebApplication
RUN mkdir C:\inetpub\wwwroot\PushNotificationWebAp
RUN mkdir C:\inetpub\wwwroot\TaipeiStarBankMessageClientWebApi

COPY certs/wildcard.asuscomm.com.pfx /wildcard.asuscomm.com.pfx
COPY certs/ca.cer /ca.cer
COPY certs/Intermediate.cer /Intermediate.cer


#ADD KaazingChatWebApplication C:\inetpub\wwwroot\KaazingChatWebApplication

#ADD release C:\inetpub\wwwroot\KaazingChatWebApplication
#ADD TaipeiStarBankMessageClientWebApi C:\inetpub\wwwroot\TaipeiStarBankMessageClientWebApi
#ADD PushNotificationWebAp C:\inetpub\wwwroot\PushNotificationWebAp

#COPY etc/hosts C:\Windows\System32\drivers\etc\hosts


SHELL [ "powershell" ]

#RUN Add-WindowsFeature telnet-client;

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

RUN Import-Module IISAdministration; `
    $PfxPW = ConvertTo-SecureString -String \"${env:pfxpw}\" -Force -AsPlainText; `
    Import-Certificate -FilePath C:\ca.cer -CertStoreLocation cert:\LocalMachine\Root; `
    Import-Certificate -FilePath C:\Intermediate.cer -CertStoreLocation cert:\LocalMachine\CA; `
    $cert = Import-PfxCertificate -FilePath C:\wildcard.asuscomm.com.pfx -CertStoreLocation cert:\LocalMachine\My -Password $PfxPW; `
    Remove-Item C:\ca.cer; `
    Remove-Item C:\Intermediate.cer; `
    Remove-Item C:\wildcard.asuscomm.com.pfx; `
    $newAppPool = New-WebAppPool -Name "KaazingChatWebApplication" -Force; `
    $newAppPool = New-WebAppPool -Name "TaipeiStarBankMessageClientWebApi" -Force; `
    $newAppPool = New-WebAppPool -Name "PushNotificationWebAp" -Force; `
    New-IISSiteBinding -Name \"Default Web Site\" -Protocol http -BindingInformation "*:80:"; `
    New-IISSiteBinding -Name \"Default Web Site\" -Protocol https -BindingInformation \"*:1443:\" -CertificateThumbPrint $cert.Thumbprint -CertStoreLocation "cert:\LocalMachine\My"; `
    New-WebApplication -Name "KaazingChatWebApplication" -Site \"Default Web Site\" -PhysicalPath "C:\inetpub\wwwroot\KaazingChatWebApplication" -ApplicationPool "KaazingChatWebApplication" -Force; `
    New-WebApplication -Name "TaipeiStarBankMessageClientWebApi" -Site \"Default Web Site\" -PhysicalPath "C:\inetpub\wwwroot\TaipeiStarBankMessageClientWebApi" -ApplicationPool "TaipeiStarBankMessageClientWebApi" -Force; `
    New-WebApplication -Name "PushNotificationWebAp" -Site \"Default Web Site\" -PhysicalPath "C:\inetpub\wwwroot\PushNotificationWebAp" -ApplicationPool "PushNotificationWebAp" -Force;    

EXPOSE 80
EXPOSE 1443
EXPOSE 8172

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]