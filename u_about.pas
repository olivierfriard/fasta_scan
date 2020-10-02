{u_about.pas - FASTA 36 Scan version 1.0

Copyright (C) 2018-2019 Olivier Friard

olivier.friard@unito.it

This file is part of FASTA 36 Scan software

}


unit u_about;

{$MODE Delphi}

interface

uses
  SysUtils, Types, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TfrmAbout }

  TfrmAbout = class(TForm)
    Memo1: TMemo;
    Label1: TLabel;
    Bevel1: TBevel;
    Button1: TButton;
    lb_version: TLabel;
    lb_exefilename: TLabel;
    procedure Label1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var frmAbout: TfrmAbout;

implementation
uses u_main;
{$R *.lfm}

{ TfrmAbout }

procedure TfrmAbout.Memo1Change(Sender: TObject);
begin

end;

procedure TfrmAbout.Label1Click(Sender: TObject);
begin

end;

end.
