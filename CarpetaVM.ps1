# Ruta de la carpeta a crear
$folderPath = "D:\MV-$env:USERNAME"

# Verifica si la carpeta ya existe
if (!(Test-Path -Path $folderPath)) {
    # Crea la carpeta si no existe
    New-Item -Path $folderPath -ItemType Directory

    # Otorga permisos completos al usuario
    $acl = Get-Acl $folderPath
    $permission = "DOMAIN\$env:USERNAME","FullControl","Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($permission)
    $acl.SetAccessRule($accessRule)

    # Remueve todos los accesos para otros usuarios
    $acl.Access | ForEach-Object {
        if ($_.IdentityReference -notlike "*$env:USERNAME") {
            $acl.RemoveAccessRule($_)
        }
    }

    # Aplica los cambios
    Set-Acl $folderPath $acl

    #Cambiar la configuración de la carpeta para que la use Virtualbox por defecto:
    # Ruta del archivo de configuración VirtualBox.xml
    $configFile = "C:\Users\$env:USERNAME\.VirtualBox\VirtualBox.xml"

    # Ruta donde se almacenarán las máquinas virtuales
    $vmPath = "D:\MV-$env:USERNAME"

    # Asegúrate de que el archivo de configuración existe
    if (Test-Path $configFile) {
      # Lee el contenido del archivo VirtualBox.xml
      [xml]$xmlContent = Get-Content $configFile

      # Busca la sección donde se define la ruta predeterminada de las VMs
      $machineFolderNode = $xmlContent.VirtualBox.Global.MachineRegistry

      # Modifica la ruta a la carpeta creada en D:
      $machineFolderNode.MachineFolder = $vmPath

      # Guarda los cambios en VirtualBox.xml
      $xmlContent.Save($configFile)
    }
    
}

