{u_options.pas - FASTA 36 Scan version 1.0

Copyright (C) 2018-2019 Olivier Friard

olivier.friard@unito.it

This file is part of FASTA 36 Scan software

}


unit u_options;

{$MODE Delphi}

interface

uses
  SysUtils, Types, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmOptions = class(TForm)
    cbIncludeDescription: TCheckBox;
    btSave: TButton;
    btCancel: TButton;
    cbSaveUniqueSequence: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmOptions: TfrmOptions;

implementation

{$R *.lfm}

end.
