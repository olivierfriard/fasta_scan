{u_warning.pas - FASTA 36 Scan version 1.0

Copyright (C) 2018-2019 Olivier Friard

olivier.friard@unito.it

This file is part of FASTA 36 Scan software

}


unit u_warning;

{$MODE Delphi}

interface

uses
  SysUtils, Types, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmWarning = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWarning: TfrmWarning;

implementation

{$R *.lfm}



end.
