#Laad nodige assemblies
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Vaste variabelen
$size_textbox = New-Object System.Drawing.Size(240,14)
$size_label = New-Object System.Drawing.Size(100,12)
$size_button = New-Object System.Drawing.Size(130,58)

$label_x = 10
$txtb_x = 112


# Een basis form en controls tekenen.
$Form_GebruikerMaken = New-Object System.Windows.Forms.Form
    $Form_GebruikerMaken.Text = "Gebruiker aanmaken"                      # Titel van het venster
    $Form_GebruikerMaken.Size = New-Object System.Drawing.Size(1440,900)  # Resolutie van het venster
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
    $label_FirstName.Location = New-Object System.Drawing.Size($label_x,29) # Waar moet het label staan? (x,y)
    $label_FirstName.Size = $size_label                                     # Hoe groot moet het label zijn? (w,l)
    $label_FirstName.TextAlign = "MiddleRight"                              # Uitlijnen, left, right of center.
    $label_FirstName.Text = "Voornaam:"                                     # Wat voor tekst moet het label weergeven?
    #$label_FirstName.BackColor = "Red"
    $form_GebruikerMaken.Controls.Add($label_FirstName)

$label_LastName = New-Object System.Windows.Forms.Label
    $label_LastName.Location = New-Object System.Drawing.Size($label_x,59)  # Waar moet het label staan? (x,y)
    $label_LastName.Size = $size_label                                      # Hoe groot moet het label zijn? (w,l)
    $label_LastName.TextAlign = "MiddleRight"                               # Uitlijnen, left, right of center.
    $label_LastName.Text = "Achternaam:"                                    # Wat voor tekst moet het label weergeven?
    $form_GebruikerMaken.Controls.Add($label_LastName)

$label_GivenName = New-Object System.Windows.Forms.Label
    $label_GivenName.Location = New-Object System.Drawing.Size($label_x,188)# Waar moet het label staan? (x,y)
    $label_GivenName.Size = $size_label                                     # Hoe groot moet het label zijn? (w,l)
    $label_GivenName.TextAlign = "MiddleRight"                              # Uitlijnen, left, right of center.
    $label_GivenName.Text = "Getoonde naam:"                                # Wat voor tekst moet het label weergeven?
    $form_GebruikerMaken.Controls.Add($label_GivenName)


# Buttons
$knop_GebruikerAanmaken = New-Object System.Windows.Forms.Button
    $knop_GebruikerAanmaken.Location = New-Object System.Drawing.Size(1043,50)
    $knop_GebruikerAanmaken.Size = $size_button
    $knop_GebruikerAanmaken.TextAlign = "MiddleCenter"
    $knop_GebruikerAanmaken.Text = "Gebruiker aanmaken"
    $form_GebruikerMaken.Controls.Add($knop_GebruikerAanmaken)

$knop_GebruikerImporteren = New-Object System.Windows.Forms.Button
    $knop_GebruikerImporteren.Location = New-Object System.Drawing.Size(1173,50)
    $knop_GebruikerImporteren.Size = $size_button
    $knop_GebruikerImporteren.TextAlign = "MiddleCenter"
    $knop_GebruikerImporteren.Text = "Gebruikers importeren"
    $form_GebruikerMaken.Controls.Add($knop_GebruikerImporteren)

$knop_FormulierLegen = New-Object System.Windows.Forms.Button
    $knop_FormulierLegen.Location = New-Object System.Drawing.Size(1303,50)
    $knop_FormulierLegen.Size = $size_button
    $knop_FormulierLegen.TextAlign = "MiddleCenter"
    $knop_FormulierLegen.Text = "Wis formulier"
    $form_GebruikerMaken.Controls.Add($knop_FormulierLegen)


# Velden
$txtb_FirstName = New-Object System.Windows.Forms.TextBox
    $txtb_FirstName.Location = New-Object System.Drawing.Size($txtb_x,25)
    $txtb_FirstName.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_FirstName)

$txtb_Lastname = New-Object System.Windows.Forms.TextBox
    $txtb_Lastname.Location = New-Object System.Drawing.Size($txtb_x,54)
    $txtb_Lastname.Size = $size_textbox
    $form_GebruikerMaken.Controls.Add($txtb_Lastname)






# Laat het formulier zien.
#$Form_GebruikerMaken.Add_Shown({$Form.GebruikerMaken.Activate()})
[void] $Form_GebruikerMaken.ShowDialog()



