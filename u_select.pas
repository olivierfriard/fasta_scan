{u_select.pas - FASTA 36 Scan version 1.0

Copyright (C) 2018-2019 Olivier Friard

olivier.friard@unito.it

This file is part of FASTA 36 Scan software

}


unit u_select;

{$MODE Delphi}

interface

uses
  SysUtils, Types, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmSelect = class(TForm)
    Label1: TLabel;
    btnClose: TButton;
    edLength: TEdit;
    edHomol: TEdit;
    edCutoff: TEdit;
    lbLength: TLabel;
    lbHomology: TLabel;
    lbCutoff: TLabel;
    gbKeyword: TGroupBox;
    edMatch: TEdit;
    edNoMatch: TEdit;
    lbSelect: TLabel;
    lbUnselect: TLabel;
    procedure edLengthChange(Sender: TObject);
    procedure edLengthExit(Sender: TObject);
    procedure edLengthKeyPress(Sender: TObject; var Key: Char);
    procedure edHomolChange(Sender: TObject);
    procedure edHomolExit(Sender: TObject);
    procedure edHomolKeyPress(Sender: TObject; var Key: Char);
    procedure edCutoffChange(Sender: TObject);
    procedure edCutoffExit(Sender: TObject);
    procedure edCutoffKeyPress(Sender: TObject; var Key: Char);
    procedure edMatchKeyPress(Sender: TObject; var Key: Char);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var frmSelect: TfrmSelect;

implementation

uses u_main;

{$R *.lfm}

procedure updatelength(l:integer);
var i:integer;
    s:shortstring;
begin
with frmMain do
    for i:=0 to lv.items.Count-1 do
        begin
        lv.items[i].checked:=false;
        if lv.items[i].subitems.count>=4 then
           s:=trim(lv.items[i].subitems.strings[3]);    //length
        if strtoint(s)>=l then
           lv.items[i].checked:=true;
        end;
frmSelect.edHomol.text:='';
frmSelect.edCutOff.text:='';
count_checked_sequences;
end;  //updatelength

procedure updateHomol(h:double);
var i:integer;
    s:shortstring;
begin
if (h<0) or (h>100) then
   begin
   showmessage('Homology value out of range (0-100)');
   exit;
   end;
with frmMain do
for i:=0 to lv.items.Count-1 do
    begin
    lv.items[i].checked:=false;
    if lv.items[i].subitems.count>=3 then
       s:=trim(lv.items[i].subitems.strings[2]);    //homol
    if strtofloat(s)>=h then
       lv.items[i].checked:=true;
    end;
frmSelect.edLength.text:='';
frmSelect.edCutOff.text:='';
count_checked_sequences;
end;  //updateHomol

procedure updateCutOff(co:double);
var i,w:integer;
    s,s2:shortstring;
begin
if (co<0) or (co>1) then
   begin
   showmessage('Cut-off value out of range (0-1)');
   exit;
   end;
with frmMain do
for i:=0 to lv.items.Count-1 do
     begin
     lv.items[i].checked:=false; //unselection
     if lv.items[i].subitems.count>=4 then
        begin
        s2:=trim(lv.items[w].subitems.strings[3]);    //homol
        s:=trim(lv.items[i].subitems.strings[4]);    //length
        end;
     if strtofloat(s2)*strtoint(s)/ls/100>=co then
        lv.items[i].checked:=true;
     end;
frmSelect.edHomol.text:='';
frmSelect.edLength.text:='';
count_checked_sequences;
end;

procedure TfrmSelect.edLengthChange(Sender: TObject);
begin
if edlength.Focused then
   begin
   edHomol.Text:='';
   edCutoff.Text:='';
   end;
end;

procedure TfrmSelect.edLengthExit(Sender: TObject);
begin
if edlength.text<>'' then
   updatelength(strtoint(edlength.text));
end;

procedure TfrmSelect.edLengthKeyPress(Sender: TObject; var Key: Char);
begin
if not (key in ['0'..'9',#13,#8]) then
   begin
   showmessage('Input numerical value!');
   key:=#0;
   exit;
   end;
if key=#13 then
   updatelength(strtoint(edlength.text));
end;

procedure TfrmSelect.edHomolChange(Sender: TObject);
begin
if edHomol.Focused then
   begin
   edLength.Text:='';
   edCutoff.Text:='';
   end;
end;

procedure TfrmSelect.edHomolExit(Sender: TObject);
begin
if edHomol.text<>'' then
   updatehomol(strtofloat(edHomol.text));
end;

procedure TfrmSelect.edHomolKeyPress(Sender: TObject; var Key: Char);
begin
if not (key in ['0'..'9',#13,'.',#8]) then
   begin
   showmessage('Input numerical value!');
   key:=#0;
   exit;
   end;
if key=#13 then
   updateHomol(strtofloat(edHomol.text));
end;

procedure TfrmSelect.edCutoffChange(Sender: TObject);
begin
if edCutOff.Focused then
   begin
   edLength.Text:='';
   edHomol.Text:='';
   end;
end;

procedure TfrmSelect.edCutoffExit(Sender: TObject);
begin
if edCutoff.text<>'' then
   updateCutOff(strtofloat(edCutoff.text));
end;

procedure TfrmSelect.edCutoffKeyPress(Sender: TObject; var Key: Char);
begin
if not (key in ['0'..'9',#13,'.',#8]) then
   begin
   showmessage('Input numerical value!');
   key:=#0;
   exit;
   end;
if key=#13 then
   updateCutOff(strtofloat(edCutoff.text));
end;

procedure TfrmSelect.edMatchKeyPress(Sender: TObject; var Key: Char);
var i,w1:integer;
begin
if key=#13 then
   begin
   with frmMain do
   for i:=0 to lv.items.count-1 do
       if lv.items[i].subitems.count>=2 then
          for w1:=0 to 1 do
              begin
              if pos(uppercase(edMatch.text),uppercase(lv.items[i].subitems.strings[w1]))<>0 then
                 lv.items[i].checked:=true;
              if pos(uppercase(edNoMatch.text),uppercase(lv.items[i].subitems.strings[w1]))<>0 then
                 lv.items[i].checked:=false;
              end;
    count_checked_sequences;
    end;
end;

procedure TfrmSelect.btnCloseClick(Sender: TObject);
begin
if edLength.text<>'' then
   updatelength(strtoint(edLength.text));
if edHomol.text<>'' then
   updatehomol(strtofloat(edHomol.text));
if edCutOff.text<>'' then
   updateCutOff(strtofloat(edCutoff.text));
close;
end;

end.
