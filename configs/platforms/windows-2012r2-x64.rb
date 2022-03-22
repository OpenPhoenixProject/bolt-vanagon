platform "windows-2012r2-x64" do |plat|
  plat.vmpooler_template "win-2012r2-x86_64"

  plat.servicetype "windows"

  # We need to ensure we install chocolatey prior to adding any nuget repos. Otherwise, everything will fall over
  plat.add_build_repository "https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/chocolatey/install-chocolatey.ps1"
  plat.add_build_repository "https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/nuget"

  # C:\tools is likely added by mingw, however because we also want to use that
  # dir for vsdevcmd.bat we create it for safety
  plat.provision_with "mkdir -p C:/tools"
  # We don't want to install any packages from the chocolatey repo by accident
  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe upgrade -y chocolatey"
  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe sources remove -name chocolatey"

  plat.provision_with "C:/ProgramData/chocolatey/bin/choco.exe install -y Wix310 -version 3.10.2 -debug -x86"

  plat.install_build_dependencies_with "C:/ProgramData/chocolatey/bin/choco.exe install -y"

  plat.make "/usr/bin/make"
  plat.patch "TMP=/var/tmp /usr/bin/patch.exe --binary"

  plat.platform_triple "x86_64-w64-mingw32"

  plat.package_type "msi"
  plat.output_dir "windows"
end
