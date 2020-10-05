{ FASTA 36 Scan
 	Copyright (C) 2018-2020 Olivier Friard
        (olivier.friard@unito.it)

  This file is part of FASTA 36 Scan software

}

program fasta_36_scan;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

uses
  Forms, Interfaces,
  u_main in 'u_main.pas' {frmMain},
  u_warning in 'u_warning.pas' {frmWarning},
  u_about in 'u_about.pas' {frmAbout},
  u_select in 'u_select.pas' {frmSelect},
  u_options in 'u_options.pas' {frmOptions};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FASTA 36 Scan';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmWarning, frmWarning);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmSelect, frmSelect);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.
