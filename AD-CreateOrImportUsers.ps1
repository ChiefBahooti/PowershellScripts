#Laad nodige assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
Import-Module ActiveDirectory

# Vaste variabelen
$size_textbox = New-Object System.Drawing.Size(240,14)
$size_label = New-Object System.Drawing.Size(100,12)
$size_button = New-Object System.Drawing.Size(130,58)

$label_x_left = 10
$txtb_x_left = 112
$txtb_x_right = 500

$gebr_Password = ConvertTo-SecureString "Potetos1!" -AsPlainText -Force

# Functies in Powershell zijn nogal html-like, ze werken alleen als ze aangemaakt zijn *voor* je er een call naar doet.
# Deze functie neemt argumenten vanuit het formulier of vanuit ImporteerCsvLijst en maakt een gebruiker aan op basis van deze argumenten.
Function MaakGebruikerAan {

    # Maak een degelijke username aan.
    $gebr_filter = $gebr_Voornaam.Substring(0,1)
    $gebr_unaam = "$gebr_filter.$gebr_Achternaam".ToLower()

    # Maak de gebruiker zelf aan met alle gegevens en een geforceerde password reset.
    New-ADUser -Name "$gebr_Voornaam $gebr_Achternaam" -GivenName $gebr_Voornaam -Surname $gebr_Achternaam -UserPrincipalName $gebr_unaam -OfficePhone $gebr_telnr -EmailAddress $gebr_Email -Description $gebr_Functie -AccountPassword $gebr_Password -Path $gebr_OUPad -ChangePasswordAtLogon $True -Enabled $True
    $txtb_Output.Text = $txtb_Output.Text + "[AD_USR]: $gebr_Voornaam $gebr_Achternaam is aangemaakt!`r`n"
}

# Deze functie leest een Csv bestand uit en importeert deze naar de MaakGebruikerAan functie.
Function ImporteerCsvLijst {
    # Tijdens grote imports hangt de GUI even, de gebruiker informeren is wel zo handig.
    
    $dial_OpenCsv = New-Object System.Windows.Forms.OpenFileDialog
    $dial_OpenCsv.Filter = "Comma Seperated Value(*.csv)|*.csv"
    If($dial_OpenCsv.ShowDialog() -eq "OK") {
        $file_GebruikerCsv = Import-Csv $dial_OpenCsv.FileName

        # Geef een 5 seconden waarschuwing voor we beginnen.
        
        ForEach($Gebruiker in $file_GebruikerCsv) {
            # Lees het Csv bestand uit en verzamel gebruikersinformatie.
            $gebr_Voornaam = $Gebruiker.'Voornaam'
            $gebr_Achternaam = $Gebruiker.'Achternaam' 
            $gebr_Email = $Gebruiker.'Email'
            $gebr_Telnr = $Gebruiker.'Telnr'
            $gebr_Functie = $Gebruiker.'Functie'
            $gebr_OUPad = $Gebruiker.'OUPad'
            MaakGebruikerAan
        }
    }
}

Function ImporteerGebruikerGUI {

   $gebr_Voornaam = $txtb_FirstName.Text
   $gebr_Achternaam =  $txtb_LastName.Text
   $gebr_Email = $txtb_EmailAddr.Text
   $gebr_Functie = $txtb_Description.Text
   $gebr_telnr = $txtb_PhoneNumber.Text
   $gebr_unaam = $txtb_Username.Text
   $gebr_oupad = $txtb_OUPad.Text

   MaakGebruikerAan

}

# Deze functie haalt snel het formulier leeg.
Function WisFormulier { 
    $txtb_FirstName.Text = ""
    $txtb_LastName.Text = ""
    $txtb_EmailAddr.Text = ""
    $txtb_Description.Text = ""
    $txtb_PhoneNumber.Text = ""
    $txtb_Username.Text = ""
    $txtb_Password.Text = ""
}


# Een basis form en controls tekenen.
$Form_GebruikerMaken = New-Object System.Windows.Forms.Form
    $Form_GebruikerMaken.Text = "Gebruiker aanmaken"                      # Titel van het venster
    $Form_GebruikerMaken.Size = New-Object System.Drawing.Size(764,287)   # Resolutie van het venster
    $Form_GebruikerMaken.FormBorderStyle = "FixedDialog"                  # Venster kan niet groter of kleiner gemaakt worden
    $Form_GebruikerMaken.TopMost = $true                                  # Het venster verschijnt altijd boven alle andere vensters.
    $Form_GebruikerMaken.MaximizeBox = $false                             # Maximaliseerknop uitschakelen
    $Form_GebruikerMaken.MinimizeBox = $true                              # Minimaliseerknop inschakelen.
    $Form_GebruikerMaken.ControlBox = $true                               # Sluitknop inschakelen
    $Form_GebruikerMaken.StartPosition = "CenterScreen"                   # Venster opent in het midden van het scherm.
    $Form_GebruikerMaken.Font = "Segoe UI"                                # Vensterfont op Segoe UI zetten.

# Een label toevoegen aan het scherm.
$label_HelloUser = New-Object System.Windows.Forms.Label
    $label_HelloUser.Location = New-Object System.Drawing.Size(3,3)         # Waar moet het label staan? (x,y)
    $label_HelloUser.Size = New-Object System.Drawing.Size(400,12)          # Hoe groot moet het label zijn? (w,l)
    $label_HelloUser.TextAlign = "MiddleLeft"                               # Uitlijnen, left, right of center.
    $label_HelloUser.Text = "Vul alle gevraagde gegevens in of importeer een csv bestand"
    $form_GebruikerMaken.Controls.Add($label_HelloUser)

# Labels
$label_FirstName = New-Object System.Windows.Forms.Label
    $label_FirstName.Location = New-Object System.Drawing.Size($label_x_left,29) 
    $label_FirstName.Size = $size_label                                     
    $label_FirstName.TextAlign = "MiddleRight"                              
    $label_FirstName.Text = "Voornaam:"                                     
    $form_GebruikerMaken.Controls.Add($label_FirstName)

$label_LastName = New-Object System.Windows.Forms.Label
    $label_LastName.Location = New-Object System.Drawing.Size($label_x_left,59)
    $label_LastName.Size = $size_label                                     
    $label_LastName.TextAlign = "MiddleRight"                               
    $label_LastName.Text = "Achternaam:"                                   
    $form_GebruikerMaken.Controls.Add($label_LastName)

$label_EmailAddr = New-Object System.Windows.Forms.Label
    $label_EmailAddr.Location = New-Object System.Drawing.Size($label_x_left,88)
    $label_EmailAddr.Size = $size_label                                     
    $label_EmailAddr.TextAlign = "MiddleRight"                             
    $label_EmailAddr.Text = "Email:"                               
    $form_GebruikerMaken.Controls.Add($label_EmailAddr)

$label_Function = New-Object System.Windows.Forms.Label
    $label_Function.Location = New-Object System.Drawing.Size($label_x_left,117)
    $label_Function.Size = $size_label                                     
    $label_Function.TextAlign = "MiddleRight"                             
    $label_Function.Text = "Beschrijving:"                               
    $form_GebruikerMaken.Controls.Add($label_Function)

$label_Telephone = New-Object System.Windows.Forms.Label
    $label_Telephone.Location = New-Object System.Drawing.Size($label_x_left,146)
    $label_Telephone.Size = $size_label                                     
    $label_Telephone.TextAlign = "MiddleRight"                             
    $label_Telephone.Text = "Telefoon:"                               
    $form_GebruikerMaken.Controls.Add($label_Telephone)

$label_Username = New-Object System.Windows.Forms.Label
    $label_Username.Location = New-Object System.Drawing.Size($label_x_left,175) 
    $label_Username.Size = $size_label                                     
    $label_Username.TextAlign = "MiddleRight"                              
    $label_Username.Text = "Gebruikersnaam:"                                     
    $form_GebruikerMaken.Controls.Add($label_Username)

$label_Password = New-Object System.Windows.Forms.Label
    $label_Password.Location = New-Object System.Drawing.Size($label_x_left,204) 
    $label_Password.Size = $size_label                                     
    $label_Password.TextAlign = "MiddleRight"                              
    $label_Password.Text = "Wachtwoord:"                                     
    $form_GebruikerMaken.Controls.Add($label_Password)

$label_OUPad = New-Object System.Windows.Forms.Label
    $label_OUPad.Location = New-Object System.Drawing.Size($label_x_left,233) 
    $label_OUPad.Size = $size_label                                     
    $label_OUPad.TextAlign = "MiddleRight"                              
    $label_OUPad.Text = "OU:"                                     
    $form_GebruikerMaken.Controls.Add($label_OUPad)

# Buttons
$knop_GebruikerAanmaken = New-Object System.Windows.Forms.Button
    $knop_GebruikerAanmaken.Location = New-Object System.Drawing.Size(360,24)
    $knop_GebruikerAanmaken.Size = $size_button
    $knop_GebruikerAanmaken.TextAlign = "MiddleCenter"
    $knop_GebruikerAanmaken.Text = "Gebruiker aanmaken"
    $knop_GebruikerAanmaken.Add_Click({ImporteerGebruikerGUI})
    $form_GebruikerMaken.Controls.Add($knop_GebruikerAanmaken)

$knop_GebruikerImporteren = New-Object System.Windows.Forms.Button
    $knop_GebruikerImporteren.Location = New-Object System.Drawing.Size(490,24)
    $knop_GebruikerImporteren.Size = $size_button
    $knop_GebruikerImporteren.TextAlign = "MiddleCenter"
    $knop_GebruikerImporteren.Text = "Gebruikers importeren"
	$knop_GebruikerImporteren.Add_Click({ImporteerCsvLijst})
    $form_GebruikerMaken.Controls.Add($knop_GebruikerImporteren)

$knop_FormulierLegen = New-Object System.Windows.Forms.Button
    $knop_FormulierLegen.Location = New-Object System.Drawing.Size(620,24)
    $knop_FormulierLegen.Size = $size_button
    $knop_FormulierLegen.TextAlign = "MiddleCenter"
    $knop_FormulierLegen.Text = "Wis formulier"
    $knop_FormulierLegen.Add_Click({WisFormulier})
    $form_GebruikerMaken.Controls.Add($knop_FormulierLegen)

# Velden
$txtb_FirstName = New-Object System.Windows.Forms.TextBox
    $txtb_FirstName.Location = New-Object System.Drawing.Size($txtb_x_left,25)
    $txtb_FirstName.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_FirstName)

$txtb_Lastname = New-Object System.Windows.Forms.TextBox
    $txtb_Lastname.Location = New-Object System.Drawing.Size($txtb_x_left,54)
    $txtb_Lastname.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_Lastname)

$txtb_EmailAddr = New-Object System.Windows.Forms.TextBox
    $txtb_EmailAddr.Location = New-Object System.Drawing.Size($txtb_x_left,83)
    $txtb_EmailAddr.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_EmailAddr)

$txtb_Description = New-Object System.Windows.Forms.TextBox
    $txtb_Description.Location = New-Object System.Drawing.Size($txtb_x_left,112)
    $txtb_Description.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_Description)

$txtb_PhoneNumber = New-Object System.Windows.Forms.TextBox
    $txtb_PhoneNumber.Location = New-Object System.Drawing.Size($txtb_x_left,141)
    $txtb_PhoneNumber.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_PhoneNumber)

$txtb_Username = New-Object System.Windows.Forms.TextBox
    $txtb_Username.Location = New-Object System.Drawing.Size($txtb_x_left,170)
    $txtb_Username.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_Username)

$txtb_Password = New-Object System.Windows.Forms.TextBox
    $txtb_Password.Location = New-Object System.Drawing.Size($txtb_x_left,199)
    $txtb_Password.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_Password)

$txtb_OUPad = New-Object System.Windows.Forms.TextBox
    $txtb_OUPad.Location = New-Object System.Drawing.Size($txtb_x_left,228)
    $txtb_OUPad.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_OUPad)

$txtb_Output = New-Object System.Windows.Forms.TextBox
    $txtb_Output.Location = New-Object System.Drawing.Size(361,83)
    $txtb_Output.Size = New-Object System.Drawing.Size(388,167)
    $txtb_Output.Enabled = $False
    $txtb_Output.BackColor = "White"
    $txtb_Output.ScrollBars = "Vertical"
    $txtb_Output.Multiline = $True
    $form_GebruikerMaken.Controls.Add($txtb_Output)

# Laat het formulier zien en waarschuw de gebruiker dat GUI freezes normaal zijn.
$txtb_Output.Text = $txtb_Output.Text + "[AD_CSV]: De GUI kan bevriezen tijdens de import, dit is normaal!`r`n"
[void] $Form_GebruikerMaken.ShowDialog()



