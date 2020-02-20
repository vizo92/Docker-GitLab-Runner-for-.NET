FROM mcr.microsoft.com/dotnet/framework/sdk:4.8

MAINTAINER s.kwiatkowski@sakurastudio.pl

WORKDIR 'C:\\'

COPY gitlab-runner gitlab-runner
COPY nunit NUnit

SHELL ["powershell"]

RUN Invoke-WebRequest 'https://github.com/git-for-windows/git/releases/download/v2.25.0.windows.1/MinGit-2.25.0-64-bit.zip' -OutFile MinGit.zip

RUN Expand-Archive c:\MinGit.zip -DestinationPath c:\MinGit; \
$env:PATH = $env:PATH + ';C:\\MinGit\\cmd\\;C:\\MinGit\\cmd'; \
Set-ItemProperty -Path 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\' -Name Path -Value $env:PATH
# latest version of runner is still in beta and antivirus software don't accept it yet so it have to be downloaded
RUN Invoke-WebRequest -Uri "https://gitlab-runner-downloads.s3.amazonaws.com/master/binaries/gitlab-runner-windows-amd64.exe" -OutFile "$env:systemdrive\\gitlab-runner\\gitlab-runner.exe"
#install nuget
RUN Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
#install powershell
RUN Install-Module PowerShellGet -Force -SkipPublisherCheck
#Set policy for installing git
RUN Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
#install git
RUN Install-Module posh-git -Scope AllUsers -Force
#To include git information in your prompt, the posh-git module needs to be imported. To have posh-git imported every time PowerShell starts, execute the Add-PoshGitToProfile command which will add the import statement into you $profile script.
RUN Import-Module posh-git
RUN Add-PoshGitToProfile -AllHosts

