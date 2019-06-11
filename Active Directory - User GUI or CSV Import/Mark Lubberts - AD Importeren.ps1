# GEBRUIKER CONFIGURATIE
# Dit stuk kan je aanpassen om de standaard configuratie bij te werken.
# Pas bij voorkeur niks anders aan tenzij je weet wat je doet.
#======================================================================#
# Account informatie                                                   #
$def_vnaam      = ""                                                   # Voornaam van de gebruiker.
$def_anaam      = ""                                                   # Achternaam van de gebruiker.
$def_email      = ""                                                   # Email van de gebruiker.
$def_functie    = ""                                                   # Functie van de gebruiker.
$def_telefoon   = ""                                                   # Telefoonnummer van de gebruiker.
$def_username   = ""                                                   # Gebruikersnaam van de gebruiker.
$def_password   = ""                                                   # Wachtwoord van de gebruiker.
$def_oupad      = "OU=Wienkel,DC=intern,DC=dehosting,DC=club"          # OU van de gebruiker.
                                                                       #
# Accountopties                                                        #
$def_AcAccess   = $True                                                # Is het account ingeschakeld?
$def_Smartcard  = $False                                               # Smartcard authenticatie verplicht?
$def_NoPassword = $False                                               # Inloggen zonder wachtwoord mogelijk?
$def_NoChangePw = $False                                               # Mag de gebruiker het wachtwoord wijzigen?
$def_NoPassExp  = $False                                               # Verloopt het wachtwoord van de gebruiker?
$def_ChPasswd   = $True                                                # Moet de gebruiker op de eerstvolgende login zijn wachtwoord wijzigen?
                                                                       #
# Extra                                                                #
$def_HomeDir    = $False                                               # Moet er een homedrive verbonden worden?
$def_HomeLetter = ""                                                   # NYI: Welke drive letter moet aan de homedrive verbonden worden?
$def_HomePath   = ""                                                   # NYI: Welk pad hoort bij deze Homedrive?
#======================================================================#
# EINDE GEBRUIKER CONFIGURATIE

# Dit script is geschreven door Mark Lubberts.
# Voel je vrij om het ter referentie te gebruiken (of het gewoon in te leveren maar dat zou ik niet aanraden).
# Fijne dag toegewenst en veel succes met het script!
#
# Oh juist, dit script werkt alleen op een Windows Server machine met Active Directory geïnstalleerd en geconfigureerd.

# Versienummer voor de app.
$app_versie = 1.1

#Laad nodige assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") # De library die we nodig hebben om een GUI te maken.
Import-Module ActiveDirectory                                                    # De library die we nodig hebben om met ActiveDirectory te werken, dit geeft een error op niet Windows Server machines.

# De afmetingen voor de GUI elementen (invoervelden, labels, knoppen)
$size_textbox     = New-Object System.Drawing.Size(240,14)
$size_label       = New-Object System.Drawing.Size(100,12)
$size_button      = New-Object System.Drawing.Size(130,58)

# Een paar GUI elementen komen heel vaak voor, het doet ons doet deze een consistente plaatsing te geven.
# Verder zetten we alvast een teller op voor het aantal aangemaakte gebruikers.
$label_x_left     = 10
$txtb_x_left      = 112
$txtb_x_right     = 500
$count_UsersMade  = 0

# De rechten op homefolders
$home_Rechten     = [System.Security.AccessControl.FileSystemRights]"Modify"
$home_Control     = [System.Security.AccessControl.AccessControlType]::Allow
$home_Inherit     = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit" 
$home_Propagation = [System.Security.AccessControl.PropagationFlags]"None"

# Defineer een standaard wachtwoord voor accounts.
$gebr_Password    = ConvertTo-SecureString "Potetos1!" -AsPlainText -Force

# De lijst van veilige stationletters.
[array]$def_ValidDisks = "A:", "B:", "D:", "E:", "F:", "G:", "H:", "I:", "J:", "K:", "L:", "M:", "N:", "O:", "P:", "Q:", "R:", "S:", "T:", "U:", "W:", "X:", "Y:", "Z:"

# Functies in Powershell zijn nogal html-like, ze werken alleen als ze aangemaakt zijn *voor* je er een call naar doet.
# Deze functie neemt argumenten vanuit het formulier of vanuit ImporteerCsvLijst en maakt een gebruiker aan op basis van deze argumenten.
Function MaakGebruikerAan {

    # Maak een degelijke username aan.
    if($txtb_Username.TextLength -eq 0) {
    $gebr_filter    = $gebr_Voornaam.Substring(0,1)
    $gebr_unaam     = "$gebr_filter.$gebr_Achternaam".ToLower()
    } else {
        $gebr_unaam = $txtb_Username.Text.ToLower()
    }

    # Is er een wachtwoord in de GUI opgegeven?
    # Als dit zo is moet er SecureString van gemaakt worden en hoeft de gebruiker dit wachtwoord ook niet te wijzigen.
    if(!$txtb_Password.TextLength -eq 0) { 
        $gebr_Password = ConvertTo-SecureString $txtb_Password.Text -AsPlainText -Force
    }


    # Nog even checken of de gebruiker niet al bestaat...
    if(@(Get-ADUser -Filter { UserPrincipalName -eq $gebr_unaam }).Count -eq 1) {  
        $txtb_Output.Text = $txtb_Output.Text + "[AD_USR]: Het account '$gebr_Voornaam $gebr_Achternaam' bestaat al!`r`n"   
        return  
    } 

    # Voorbereidingen treffen om de Home Directory aan te maken.
    $home_Folder = "\\P4-DC1\UserHome$\$($gebr_unaam)"

    # Maak de gebruiker zelf aan met alle gegevens en een geforceerde password reset.
    # We doen ook direct een controle of het account bestaat en geven de juiste melding door!
    New-Item -path $home_Folder -ItemType Directory -force
    New-ADUser -Name "$gebr_Voornaam $gebr_Achternaam" -DisplayName "$gebr_Voornaam $gebr_Achternaam" -GivenName $gebr_Voornaam -Surname $gebr_Achternaam -SamAccountName $gebr_unaam -UserPrincipalName $gebr_unaam -OfficePhone $gebr_telnr -EmailAddress $gebr_Email -Description $gebr_Functie -AccountPassword $gebr_Password -Path $gebr_OUPad -HomeDrive "H:" -HomeDirectory "\\P4-DC1\UserHome$\$($gebr_unaam)" -PasswordNeverExpires $chkb_ExpPasswd.Checked -CannotChangePassword $chkb_ChPasswd.Checked -ChangePasswordAtLogon $chkb_NewPasswd.Checked -Enabled $chkb_AcAccess.Checked
    
    # Permissions instellen op de user HomeFolder.
    $home_User = Get-ADUser -Identity $gebr_Unaam
    $home_FinalRule = New-Object System.Security.AccessControl.FileSystemAccessRule($home_User.SID, $home_Rechten, $home_Inherit, $home_Propagation, $home_Control)
    $home_Acl = Get-Acl $home_Folder
    $home_Acl.AddAccessRule($home_FinalRule)
    Set-Acl -Path $home_Folder -AclObject $home_Acl

    if(@(Get-ADUser -Filter { UserPrincipalName -eq $gebr_unaam }).Count -eq 0) {  
        $txtb_Output.Text = $txtb_Output.Text + "[AD_USR]: Het account '$gebr_Voornaam $gebr_Achternaam' kon niet worden aangemaakt!`r`n"
    } else {    
        $txtb_Output.Text = $txtb_Output.Text + "[AD_USR]: Het account '$gebr_Voornaam $gebr_Achternaam' is aangemaakt!`r`n"
        $count_UsersMade++
    }
}

# Deze functie leest een Csv bestand uit en importeert deze naar de MaakGebruikerAan functie.
Function ImporteerCsvLijst {

    # Aantal aangemaakte gebruikers weer op 0 zetten.
    $count_UsersMade = 0

    $dial_OpenCsv = New-Object System.Windows.Forms.OpenFileDialog
    $dial_OpenCsv.Filter = "Comma Seperated Value(*.csv)|*.csv"
    If($dial_OpenCsv.ShowDialog() -eq "OK") { # Het volgende blok alleen doorwerken als de gebruiker op OK klikt en niet als er op Annuleren geklikt is.
        $file_GebruikerCsv = Import-Csv $dial_OpenCsv.FileName

        ForEach($Gebruiker in $file_GebruikerCsv) {
            # Lees het Csv bestand uit en verzamel gebruikersinformatie.
            $gebr_Voornaam   = $Gebruiker.'Voornaam'
            $gebr_Achternaam = $Gebruiker.'Achternaam' 
            $gebr_Email      = $Gebruiker.'Email'
            $gebr_Telnr      = $Gebruiker.'Telnr'
            $gebr_Functie    = $Gebruiker.'Functie'
            $gebr_OUPad      = $Gebruiker.'OUPad'
            MaakGebruikerAan
        }
        $txtb_Output.Text = $txtb_Output.Text + "[AD_CSV]: $count_UsersMade accounts zijn geïmporteerd."
    }
}

# Dit is een wrapper functie.
# Omdat de GUI zelf ook losse accounts aan kan maken moet ik een CSV import emuleren.
# Deze functie doet dat.
Function ImporteerGebruikerGUI {
   # Aantal aangemaakte gebruikers weer op 0 zetten.
   $count_UsersMade = 0

   $gebr_Voornaam           = $txtb_FirstName.Text
   $gebr_Achternaam         = $txtb_LastName.Text
   $gebr_Email              = $txtb_EmailAddr.Text
   $gebr_Functie            = $txtb_Description.Text
   $gebr_telnr              = $txtb_PhoneNumber.Text
   $gebr_unaam              = $txtb_Username.Text
   $gebr_oupad              = $txtb_OUPad.Text
   MaakGebruikerAan
}

# Deze functie zet het formulier snel terug naar de standaard configuratie.
Function ResetFormulier { 
    $txtb_FirstName.Text     = $def_vnaam
    $txtb_Lastname.Text      = $def_anaam
    $txtb_EmailAddr.Text     = $def_email
    $txtb_Description.Text   = $def_functie
    $txtb_PhoneNumber.Text   = $def_telefoon
    $txtb_Username.Text      = $def_username
    $txtb_Password.Text      = $def_password
    $txtb_OUpad.Text         = $def_oupad
    $txtb_MountDir.Text      = $def_HomePath


    $chkb_AcAccess.Checked   = $def_AcAccess
    $chkb_Smartcard.Checked  = $def_Smartcard
    $chkb_ReqPasswd.Checked  = $def_NoPassword
    $chkb_ChPasswd.Checked   = $def_NoChangePw
    $chkb_ExpPasswd.Checked  = $def_NoPassExp
    $chkb_NewPasswd.Checked  = $def_ChPasswd
    $chkb_HomeDir.Checked    = $def_HomeDir
}


# Hieronder vind je alle gebruikte GUI elementen.
# Aanpassingen hier zijn vrij veilig hoewel het wel een knop kapot kan maken zal het programma zelf altijd starten.

# Een basis form en controls tekenen.
$Form_GebruikerMaken = New-Object System.Windows.Forms.Form                                  
    $Form_GebruikerMaken.Text            = "Gebruiker aanmaken"                                         
    $Form_GebruikerMaken.Size            = New-Object System.Drawing.Size(774,449)                      
    $Form_GebruikerMaken.FormBorderStyle = "FixedDialog"                                     
    $Form_GebruikerMaken.TopMost         = $true                                                     
    $Form_GebruikerMaken.MaximizeBox     = $false                                                
    $Form_GebruikerMaken.MinimizeBox     = $true                                                 
    $Form_GebruikerMaken.ControlBox      = $true                                                  
    $Form_GebruikerMaken.StartPosition   = "CenterScreen"                                      
    $Form_GebruikerMaken.Font            = "Segoe UI"

# Borders
$bord_Account = New-Object System.Windows.Forms.GroupBox
    $bord_Account.Text                   = "Account informatie"
    $bord_Account.Size                   = "355,255"
    $bord_Account.Location               = "3,3"
    $bord_Account.Visible                = $True
    $form_GebruikerMaken.Controls.Add($bord_Account)

$bord_Opties = New-Object System.Windows.Forms.GroupBox
    $bord_Opties.Text                    = "Accountopties"
    $bord_Opties.Size                    = "753,148"
    $bord_Opties.Location                = "3,260"
    $bord_Opties.Visible                 = $True
    $form_GebruikerMaken.Controls.Add($bord_Opties)

$bord_Control = New-Object System.Windows.Forms.GroupBox
    $bord_Control.Text                   = "In- en output"
    $bord_Control.Size                   = "396,255"
    $bord_Control.Location               = "360,3"
    $bord_Control.Visible                = $True
    $form_GebruikerMaken.Controls.Add($bord_Control)                                                       

# Labels
$label_FirstName = New-Object System.Windows.Forms.Label
    $label_FirstName.Location            = New-Object System.Drawing.Size($label_x_left,29) 
    $label_FirstName.Size                = $size_label                                     
    $label_FirstName.TextAlign           = "MiddleRight"                              
    $label_FirstName.Text                = "Voornaam:"                                     
    $bord_Account.Controls.Add($label_FirstName)

$label_LastName = New-Object System.Windows.Forms.Label
    $label_LastName.Location             = New-Object System.Drawing.Size($label_x_left,59)
    $label_LastName.Size                 = $size_label                                     
    $label_LastName.TextAlign            = "MiddleRight"                               
    $label_LastName.Text                 = "Achternaam:"                                   
    $bord_Account.Controls.Add($label_LastName)

$label_EmailAddr = New-Object System.Windows.Forms.Label
    $label_EmailAddr.Location            = New-Object System.Drawing.Size($label_x_left,88)
    $label_EmailAddr.Size                = $size_label                                     
    $label_EmailAddr.TextAlign           = "MiddleRight"                             
    $label_EmailAddr.Text                = "Email:"                               
    $bord_Account.Controls.Add($label_EmailAddr)

$label_Function = New-Object System.Windows.Forms.Label
    $label_Function.Location             = New-Object System.Drawing.Size($label_x_left,117)
    $label_Function.Size                 = $size_label                                     
    $label_Function.TextAlign            = "MiddleRight"                             
    $label_Function.Text                 = "Functie:"                               
    $bord_Account.Controls.Add($label_Function)

$label_Telephone = New-Object System.Windows.Forms.Label
    $label_Telephone.Location            = New-Object System.Drawing.Size($label_x_left,146)
    $label_Telephone.Size                = $size_label                                     
    $label_Telephone.TextAlign           = "MiddleRight"                             
    $label_Telephone.Text                = "Telefoon:"                               
    $bord_Account.Controls.Add($label_Telephone)

$label_Username = New-Object System.Windows.Forms.Label
    $label_Username.Location = New-Object System.Drawing.Size($label_x_left,175) 
    $label_Username.Size                 = $size_label                                     
    $label_Username.TextAlign            = "MiddleRight"                              
    $label_Username.Text                 = "Gebruikersnaam:"                                     
    $bord_Account.Controls.Add($label_Username)

$label_Password = New-Object System.Windows.Forms.Label
    $label_Password.Location             = New-Object System.Drawing.Size($label_x_left,204) 
    $label_Password.Size                 = $size_label                                     
    $label_Password.TextAlign            = "MiddleRight"                              
    $label_Password.Text                 = "Wachtwoord:"                                     
    $bord_Account.Controls.Add($label_Password)

$label_OUPad = New-Object System.Windows.Forms.Label
    $label_OUPad.Location                = New-Object System.Drawing.Size($label_x_left,233) 
    $label_OUPad.Size                    = $size_label                                     
    $label_OUPad.TextAlign               = "MiddleRight"                              
    $label_OUPad.Text                    = "OU:"                                     
    $bord_Account.Controls.Add($label_OUPad)

$label_Version = New-Object System.Windows.Forms.Label
    $label_Version.Location                = New-Object System.Drawing.Size(520,132) 
    $label_Version.Size                    = "230,14"                                     
    $label_Version.TextAlign               = "MiddleRight"                              
    $label_Version.Text                    = "Versie $($app_versie)"
    $label_Version.ForeColor               = "DarkGray"                                    
    $bord_Opties.Controls.Add($label_Version)

# Buttons
$knop_GebruikerAanmaken = New-Object System.Windows.Forms.Button
    $knop_GebruikerAanmaken.Location     = New-Object System.Drawing.Size(3,24)
    $knop_GebruikerAanmaken.Size         = $size_button
    $knop_GebruikerAanmaken.TextAlign    = "MiddleCenter"
    $knop_GebruikerAanmaken.Text         = "Gebruiker aanmaken"
    $knop_GebruikerAanmaken.Add_Click({ImporteerGebruikerGUI})
    $bord_Control.Controls.Add($knop_GebruikerAanmaken)

$knop_GebruikerImporteren = New-Object System.Windows.Forms.Button
    $knop_GebruikerImporteren.Location   = New-Object System.Drawing.Size(133,24)
    $knop_GebruikerImporteren.Size       = $size_button
    $knop_GebruikerImporteren.TextAlign  = "MiddleCenter"
    $knop_GebruikerImporteren.Text       = "Gebruikers importeren"
	$knop_GebruikerImporteren.Add_Click({ImporteerCsvLijst})
    $bord_Control.Controls.Add($knop_GebruikerImporteren)

$knop_FormulierLegen = New-Object System.Windows.Forms.Button
    $knop_FormulierLegen.Location        = New-Object System.Drawing.Size(263,24)
    $knop_FormulierLegen.Size            = $size_button
    $knop_FormulierLegen.TextAlign       = "MiddleCenter"
    $knop_FormulierLegen.Text            = "Wis formulier"
    $knop_FormulierLegen.Add_Click({ResetFormulier})
    $bord_Control.Controls.Add($knop_FormulierLegen)

# Velden
$txtb_FirstName = New-Object System.Windows.Forms.TextBox
    $txtb_FirstName.Location             = New-Object System.Drawing.Size($txtb_x_left,25)
    $txtb_FirstName.Size                 = $size_textbox
    $bord_Account.Controls.Add($txtb_FirstName)

$txtb_Lastname = New-Object System.Windows.Forms.TextBox
    $txtb_Lastname.Location              = New-Object System.Drawing.Size($txtb_x_left,54)
    $txtb_Lastname.Size                  = $size_textbox
    $bord_Account.Controls.Add($txtb_Lastname)

$txtb_EmailAddr = New-Object System.Windows.Forms.TextBox
    $txtb_EmailAddr.Location             = New-Object System.Drawing.Size($txtb_x_left,83)
    $txtb_EmailAddr.Size                 = $size_textbox
    $bord_Account.Controls.Add($txtb_EmailAddr)

$txtb_Description = New-Object System.Windows.Forms.TextBox
    $txtb_Description.Location           = New-Object System.Drawing.Size($txtb_x_left,112)
    $txtb_Description.Size               = $size_textbox
    $bord_Account.Controls.Add($txtb_Description)

$txtb_PhoneNumber = New-Object System.Windows.Forms.TextBox
    $txtb_PhoneNumber.Location           = New-Object System.Drawing.Size($txtb_x_left,141)
    $txtb_PhoneNumber.Size               = $size_textbox
    $bord_Account.Controls.Add($txtb_PhoneNumber)

$txtb_Username = New-Object System.Windows.Forms.TextBox
    $txtb_Username.Location              = New-Object System.Drawing.Size($txtb_x_left,170)
    $txtb_Username.Size                  = $size_textbox
    $bord_Account.Controls.Add($txtb_Username)

$txtb_Password = New-Object System.Windows.Forms.TextBox
    $txtb_Password.Location              = New-Object System.Drawing.Size($txtb_x_left,199)
    $txtb_Password.Size                  = $size_textbox
    $txtb_Password.PasswordChar          = '*'
    $bord_Account.Controls.Add($txtb_Password)

$txtb_OUPad = New-Object System.Windows.Forms.TextBox
    $txtb_OUPad.Location                 = New-Object System.Drawing.Size($txtb_x_left,228)
    $txtb_OUPad.Size                     = $size_textbox
    $bord_Account.Controls.Add($txtb_OUPad)

$txtb_Output = New-Object System.Windows.Forms.TextBox
    $txtb_Output.Location                = New-Object System.Drawing.Size(3,86)
    $txtb_Output.Size                    = New-Object System.Drawing.Size(388,167)
    $txtb_Output.ReadOnly                = $True
    $txtb_Output.BackColor               = "White"
    $txtb_Output.ScrollBars              = "Vertical"
    $txtb_Output.Multiline               = $True
    $bord_Control.Controls.Add($txtb_Output)

$txtb_MountDir = New-Object System.Windows.Forms.TextBox
    $txtb_MountDir.Location                 = "510,33"
    $txtb_MountDir.Size                     = $size_textbox
    $txtb_MountDir.Enabled                  = $chkb_HomeDir.Checked
    $bord_Opties.Controls.Add($txtb_MountDir)

# Vinkjes
$chkb_ExpPasswd = New-Object System.Windows.Forms.CheckBox
    $chkb_ExpPasswd.Text                 = "Wachtwoord verloopt nooit"
    $chkb_ExpPasswd.Size                 = "300,20"
    $chkb_ExpPasswd.Location             = "10,100"
    $chkb_ExpPasswd.Checked              = $False
    $bord_Opties.Controls.Add($chkb_ExpPasswd)

$chkb_NewPasswd = New-Object System.Windows.Forms.CheckBox
    $chkb_NewPasswd.Text                 = "Wachtwoord wijzigen op volgende login"
    $chkb_NewPasswd.Size                 = "300,20"
    $chkb_NewPasswd.Location             = "10,120"
    $chkb_NewPasswd.Checked              = $True
    $bord_Opties.Controls.Add($chkb_NewPasswd)

$chkb_Smartcard = New-Object System.Windows.Forms.CheckBox
    $chkb_Smartcard.Text                 = "Alleen smartcard authenticatie toestaan"
    $chkb_Smartcard.Size                 = "300,20"
    $chkb_Smartcard.Location             = "10,40"
    $chkb_Smartcard.Checked              = $False
    $bord_Opties.Controls.Add($chkb_Smartcard)

$chkb_ReqPasswd = New-Object System.Windows.Forms.CheckBox
    $chkb_ReqPasswd.Text                 = "Gebruiker mag inloggen zonder wachtwoord"
    $chkb_ReqPasswd.Size                 = "300,20"
    $chkb_ReqPasswd.Location             = "10,60"
    $chkb_ReqPasswd.Checked              = $False
    $bord_Opties.Controls.Add($chkb_ReqPasswd)

$chkb_ChPasswd = New-Object System.Windows.Forms.CheckBox
    $chkb_ChPasswd.Text                  = "Gebruiker mag wachtwoord niet wijzigen"
    $chkb_ChPasswd.Size                  = "300,20"
    $chkb_ChPasswd.Location              = "10,80"
    $chkb_ChPasswd.Checked               = $False
    $bord_Opties.Controls.Add($chkb_ChPasswd)

$chkb_AcAccess = New-Object System.Windows.Forms.CheckBox
    $chkb_AcAccess.Text                  = "Account is ingeschakeld"
    $chkb_AcAccess.Size                  = "300,20"
    $chkb_AcAccess.Location              = "10,20"
    $chkb_AcAccess.Checked               = $True
    $bord_Opties.Controls.Add($chkb_AcAccess)

$chkb_HomeDir = New-Object System.Windows.Forms.CheckBox
    $chkb_HomeDir.Text                  = "Verbind het volgende pad aan"
    $chkb_HomeDir.Size                  = "180,20"
    $chkb_HomeDir.Location              = "511,11"
    $chkb_HomeDir.Checked               = $False
    $chkb_HomeDir.add_CheckedChanged({
        if($chkb_HomeDir.Checked){
            $drop_Disks.Enabled = $True
            $txtb_MountDir.Enabled = $True
        } else {
            $drop_Disks.Enabled = $False
            $txtb_MountDir.Enabled = $False        
        }   
    })
    $bord_Opties.Controls.Add($chkb_HomeDir)

# Dropdowns
$drop_Disks    = New-Object System.Windows.Forms.ComboBox
    $drop_Disks.Location = "691,10"
    $drop_Disks.Size = "59,14"
    $drop_Disks.Enabled = $chkb_HomeDir.Checked
    $bord_Opties.Controls.Add($drop_Disks)

# De dropdown lijsten vullen met waardes
ForEach($disk in $def_ValidDisks) {
    [void] $drop_Disks.Items.Add($disk)
}

# Waarschuw de gebruiker dat een vastlopende GUI normaal is bij grote imports.
$txtb_Output.Text = $txtb_Output.Text + "[AD_CSV]: De GUI kan bevriezen tijdens de import, dit is normaal!`r`n"
$txtb_Output.Text = $txtb_Output.Text + "[AD_CSV]: CSV gebruikers krijgen altijd het wachtwoord 'Potetos1!'`r`n"
$txtb_Output.Text = $txtb_Output.Text + "[AD_USR]: Aangepaste homedrives werken nog niet.`r`n"

# Zet het formulier naar de standaard staat.
ResetFormulier

# En laat het venster zien.
[void] $Form_GebruikerMaken.ShowDialog()