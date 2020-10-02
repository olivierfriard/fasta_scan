{u_main.pas - FASTA 36 Scan version 1.2

Copyright (C) 2018-2020 Olivier Friard

olivier.friard@unito.it

This file is part of FASTA 36 Scan software

}

unit u_main;

{$MODE Delphi}

interface

uses inifiles,strutils,
  SysUtils,  Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ComCtrls, ExtCtrls;

type
  TfrmMain = class(TForm)
    MainMenu1: TMainMenu;
    Sequences1: TMenuItem;
    LoadFASTAresults1: TMenuItem;
    N3: TMenuItem;
    mi_Saveselectedsequences: TMenuItem;
    N2: TMenuItem;
    Quit1: TMenuItem;
    Selection1: TMenuItem;
    SUS1: TMenuItem;
    Font1: TMenuItem;
    Help1: TMenuItem;
    Info1: TMenuItem;
    N4: TMenuItem;
    Contents1: TMenuItem;
    About1: TMenuItem;
    lv: TListView;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    lv_popupmenu: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    sb: TStatusBar;
    N5: TMenuItem;
    Selectallsequences1: TMenuItem;
    Unselectallsequences1: TMenuItem;
    Invertselection1: TMenuItem;
    mi_SaveselectedsequencesinFASTACONVformat: TMenuItem;
    procedure About1Click(Sender: TObject);
    procedure Load(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure mi_SaveselectedsequencesClick(Sender: TObject);
    procedure SUS1Click(Sender: TObject);
    procedure Info1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvClick(Sender: TObject);
    procedure Selectallsequences1Click(Sender: TObject);
    procedure Unselectallsequences1Click(Sender: TObject);
    procedure Invertselection1Click(Sender: TObject);
    procedure mi_SaveselectedsequencesinFASTACONVformatClick(
      Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const maxseq = 1000000;
      version_number = '1.2';
      version_date = '2020-09-29';
      program_name = 'FASTA 36 Scan';

var frmMain: TfrmMain;
    nom_input,nq:string;
    f, f2, f3: Tstringlist;
    seq_list, query_seq_list: Tstringlist;
    fastatype, nseq, ls:integer;
    versionAlg:shortstring;
    posit:array[1..maxseq] of ^integer;
    itm:tlistitem;
    IniFile:TIniFile;
    flagparam:boolean;

procedure count_checked_sequences;

implementation

uses u_about, u_warning, u_select, u_options;

{$R *.lfm}

function rev(s:string):string;
var i:integer;
    s3:string;
begin
s3:='';
for i:=length(s) downto 1 do
      case s[i] of '-': s3 := s3 + '-';
                   ' ':s3 := s3 + ' ';
                   'A':s3 := s3 + 'T';
                   'C':s3 := s3+'G';
                   'G':s3 := s3+'C';
                   'T':s3 := s3+'A';
                   'M':s3 := s3+'K';
                   'R':s3 := s3+'Y';
                   'S':s3 := s3+'S';
                   'V':s3 := s3+'B';
                   'W':s3 := s3+'W';
                   'Y':s3 := s3+'R';
                   'H':s3 := s3+'D';
                   'K':s3 := s3+'M';
                   'D':s3 := s3+'H';
                   'B':s3 := s3+'V';
                   'N':s3 := s3+'N';
                   end;
result:=s3;
end;  //rev

procedure count_checked_sequences; //count number of checked sequences
var w:integer;
    compt:integer;
begin
compt:=0;
with frmMain do
    begin
    for w:=0 to lv.items.count-1 do
        if lv.items[w].checked then
           inc(compt);
    sb.Panels[1].Text:='Selected: '+inttostr(compt);
    end;
end; //count number of checked sequences

procedure TfrmMain.About1Click(Sender: TObject);  //show About window
begin
frmabout.lb_version.caption := 'version ' + version_number;
frmabout.lb_exefilename.caption := extractfilename(application.exename);
frmabout.showmodal;
end;


procedure removeHTMLtag(var sl:tstringlist);  //remove HTML tag of sequence
var s,s2:string;
    t,i:integer;
    flagin:boolean;
begin
for t:=0 to sl.count-1 do
    begin
    s:=sl[t];
    flagin:=false;
    s2:='';
    for i:=1 to length(s) do
        begin
        if s[i]='<' then
           flagin:=true;
        if not flagin then
           s2:=s2+s[i];
        if s[i]='>' then
           flagin:=false;
        end;
    while pos('&gt;',s2)<>0 do     //replace &gt; by ">"
       begin
       insert('>',s2,pos('&gt;',s2));
       delete(s2,pos('&gt;',s2),4);
       end;
    sl[t]:=s2;
    end;
end; //removeHTMLtag

procedure TfrmMain.Load(Sender: TObject);   //load file
var s, s1, s2, mem_ac: string;
    align, init1, initn, opt, zscore, e, ac, id, de: shortstring;
    w,erreur:integer;
    flagHTML:boolean;


procedure loadFASTA;  //load FASTA output
var w, n1, eliminate_repeated_ac: integer;
    homol_percent, query_id: shortstring;
    hp: Double;
    flag_seq, flag_revcomp: boolean;
    seq, query_seq: string;

begin
//check for FASTA file
fastatype := 2;

//extraction of FASTA version number
versionAlg:='';
for w := 0 to f.count-1 do
   if pos('; pg_ver:', f[w]) <> 0 then
       begin
       versionAlg := copy(f[w], pos('; pg_ver:', f[w]) + 10, 255);
       break;
       end;


// find query length
for w := 0 to f.count-1 do
   if pos('; sq_len:', f[w]) <> 0 then
       begin
       s2 := copy(f[w], pos('; sq_len:', f[w]) + 10, 255);
       break;
       end;

// query id

for w := 0 to f.count-1 do
   if (pos('>>>', f[w]) = 1) and (pos(' vs ', f[w]) <> 0) then
        begin
        query_id := f[w];
        query_id := stringreplace(query_id, '>>>', '', []);
        query_id := copy(query_id, 1, pos(', ', query_id) - 1);
        end;


for w := 0 to f.count-1 do
   if pos('; sq_len:', f[w]) <> 0 then
       begin
       s2 := copy(f[w], pos('; sq_len:', f[w]) + 10, 255);
       break;
       end;

if s2 = '' then //unknown query length
    repeat
       s2:=inputbox('Query length','Input the query length','');
       val(s2,ls,erreur);
       if (erreur<>0) or (ls=0) then
          showmessage('Input a numeric positive value!');
    until ls<>0;

ls := strtoint(s2);

if w = f.count-1 then
    begin
    Screen.Cursor:=crDefault;
    showmessage('First alignment not found!'+#10+'Check the FASTA output.');
    exit;
    end;


//sequences index creation
nseq:=0;
w := 0;
while w <= f.count-1 do
    begin
    if (copy(f[w], 1, 2) = '>>')
        and (copy(f[w], 1, 3) <> '>>>') then
        begin
        inc(nseq);
        new(posit[nseq]);
        posit[nseq]^ := w;
        end;
    inc(w);
    end;
new(posit[nseq + 1]);
posit[nseq + 1]^ := f.count;


//load sequences
lv.items.clear;
seq_list := TstringList.Create;
query_seq_list := TstringList.Create;
mem_ac := '';
eliminate_repeated_ac := -1;

for n1 := 1 to nseq do
     begin
     s := f[posit[n1]^];    // '>>'

     //read first word from ID sequence
     //remove '>>'
     s := copy(s, 3, 255);
     //extract ACCESSION first word
     ac := copy(s, 1, pos(' ', s) - 1);
     //remove ID
     delete(s, 1, length(ac));
     //remove ; if present
     ac := stringreplace(ac, ';', '', []);

     if pos(ac, mem_ac) <> 0 then
        begin
        if eliminate_repeated_ac = -1 then
           begin
           eliminate_repeated_ac := MessageDlg('Eliminate the repeated accession codes?',
                                            mtCustom,
                                            [mbYes, mbNo], 0);
           end;
        if eliminate_repeated_ac = mrYes then
           continue;
        end;

     itm := lv.items.add;
     itm.caption := inttostr(n1);     //seq number

     mem_ac := mem_ac + '*' + ac + '*';

     //remove blank
     s := trim(s);

     de := s;
     itm.subitems.add(ac);
     //extract DEFINITION
     itm.subitems.add(de);

     // extract query seq

     w := 1;
     flag_seq := false;
     query_seq := '';
     repeat
          //showmessage(f[posit[n1]^ + w]);
        if pos('>' + query_id, f[posit[n1]^ + w]) = 1 then
           begin
           flag_seq := true;
           inc(w);
           end;

        if flag_seq and (pos(';', f[posit[n1]^ + w]) = 0) then
           begin
           query_seq := query_seq +  f[posit[n1]^ + w];
           end;
        inc(w);
        if (pos('>', f[posit[n1]^ + w]) <> 0)
            and (pos('>' + query_id, f[posit[n1]^ + w]) = 0) then
           break;

     until (f[posit[n1]^ + w -1] = '>>><<<');

     query_seq_list.Add(query_seq);

     // extract sequence
     w := 1;
     flag_seq := false;
     seq := '';
     flag_revcomp := false;

     repeat

        if pos('; bs_ident: ', f[posit[n1]^ + w]) <> 0 then
            begin
            homol_percent := stringreplace(f[posit[n1]^ + w], '; bs_ident: ', '', []);
            hp :=  StrToFloat(homol_percent) * 100 ;
            itm.subitems.add(FloatToStr(hp));
            end;

        if pos('; bs_overlap: ', f[posit[n1]^ + w]) <> 0 then
            begin
            itm.subitems.add(stringreplace(f[posit[n1]^ + w], '; bs_overlap: ', '', []));
            end;

        if pos('; fa_frame: r', f[posit[n1]^ + w]) <> 0 then
            begin
            flag_revcomp := true;
            end;

        if pos('>' + ac, f[posit[n1]^ + w]) = 1 then
           begin
           flag_seq := true;
           inc(w);
           end;

        if flag_seq and (pos(';', f[posit[n1]^ + w]) <> 1) then
           begin
           seq := seq +  f[posit[n1]^ + w];
           end;
        inc(w);

     until (f[posit[n1]^ + w -1] = '>>><<<') or (pos('; al_cons:', f[posit[n1]^ + w -1 ]) <> 0);

     // remove gap from sequence
     (*
     while pos('-', seq)<>0 do
          delete(seq, pos('-', seq), 1);
     *)
     if flag_revcomp then
         seq_list.Add(rev(seq))
     else
         seq_list.Add(seq);

     if (f[posit[n1]^ + w -1] = '>>><<<') then
        break;
     end;

end; //loadFASTA


//==========================================================================
begin //tfrmMain.load

opendialog1.title:='Open FASTA output';
opendialog1.filter:='FASTA output (*.fas; *.fasta)|*.fas;*.fasta|Text file (*.txt)|*.txt|All files (*.*)|*.*';

if not flagparam then
   begin
   if opendialog1.execute then
      nom_input := opendialog1.filename
   else
      exit;
   end;

flagparam := false;
if nom_input = '' then
   exit;
nseq:=0;
Screen.Cursor := crHourglass;
lv.items.BeginUpdate;
//load file in memory
f.loadfromfile(nom_input);
f.text := AdjustLineBreaks(f.text);
align := '';
for w := 0 to f.count-1 do
    begin
    if (pos('(Nucleotide) FASTA',f[w])<>0)
       or (pos('(Peptide) FASTA',f[w])<>0)
       or (pos('FASTA searches a protein or DNA sequence data bank',f[w])<>0) then
       begin
       align:='FASTA';
       break;
       end;
    end;
if align='FASTA' then
   loadFASTA;

lv.Items.EndUpdate;
Screen.Cursor:=crDefault;   
sb.panels[0].text:='Sequences number: '+inttostr(nseq);
sb.panels[1].text:='Selected: 0';

caption:='FASTA Scan - version '+version_number+' ('+version_date+') - '+nom_input;
mi_SaveSelectedSequences.enabled:=true;
mi_SaveselectedsequencesinFASTACONVformat.enabled:=true;
selection1.enabled:=true;
end;//load file


procedure end_program;  //ask user confirmation and close program
var n1:word;
begin
if MessageDlg('Close FASTA Scan?',mtConfirmation,[mbYes,mbNo],0)=mrNo then
      exit;
f.free;
if (fastatype<>0) then
   for n1:=1 to nseq+1 do
       dispose(posit[n1]);
IniFile:=TIniFile.create(extractFilePath(application.exename)+'FASTA_Scan.ini');
for n1:=0 to frmMain.lv.columns.count-1 do
    inifile.writeinteger('FASTA_Scan','col'+inttostr(n1),frmMain.lv.columns[n1].Width);
inifile.free;
application.terminate; 
end;  //end_program

procedure TfrmMain.Quit1Click(Sender: TObject);
begin
end_program;
end;

function checknumb(s:string):boolean; //check for number
var t:byte;
    flag:boolean;
begin
flag:=true;
for t:=1 to length(s) do
   if s[t] in ['a'..'z','A'..'Z','%','-','(',')'] then
      begin
      flag:=false;
      break;
      end;
checknumb:=flag;
end;  //checknumb


procedure TfrmMain.mi_SaveselectedsequencesClick(Sender: TObject);
var flagseqloc, flagtotrev, flagname, flaggap, flagrev: boolean;
    deb,n1: word;
    w,w1,w2: integer;
    ss, nomseq, rev_str, seq_ac, descr_str: shortstring;
    mem, s, s2, s3, memseq: string;
    ft: textfile;
    flagadd, flagfirstgi, flag_incl_gi: boolean;

label label1;

begin
//search for selected sequences
for w := 0 to lv.items.count - 1 do
    if (lv.items[w].checked)  then
       begin
       n1:=1;
       break;
       end;
if n1 = 0 then
   begin
   showmessage('No selected sequences!');
   exit;
   end;

frmOptions.showmodal;
if frmOptions.modalresult=mrCancel then
   exit;

f2 := Tstringlist.create;

for w := 0 to lv.items.count - 1 do
    if (lv.items[w].checked)  then
       begin
       seq_ac := lv.items[w].subitems.strings[0];
       if frmOptions.cbIncludeDescription.Checked then
          descr_str := lv.items[w].subitems.strings[1] //DE
       else
          descr_str := '';

       if (frmOptions.cbSaveUniqueSequence.Checked) then
          begin
          if pos(seq_list[w], memseq) = 0 then
             begin
             //sequence name
             f2.add('>' + seq_ac +  ' ' + descr_str);
             //nucleotide sequence
             f2.add(seq_list[w]);
             memseq := memseq + '*' + seq_list[w] + '*';
             end;
          end
       else
          begin
          // sequence name
          f2.add('>' + seq_ac +  ' ' + descr_str);
          //nucleotide sequence
          f2.add(seq_list[w]);
          end;

       //writeln(seq_list[w])
       end;

Screen.Cursor:=crDefault;

savedialog1.filename:=changefileext(nom_input, '.fst');
if savedialog1.execute then
    begin
    flagadd:=false;
    if fileexists(savedialog1.filename) then
        begin
        frmWarning.showmodal;
        if frmWarning.modalresult=mrcancel then
           exit;
        if frmWarning.modalresult=mrno then
           flagadd:=true
        else
           flagadd:=false;
        end;
    if not flagadd then
        f2.savetofile(savedialog1.filename) //overwrite f file already exists
    else
        begin
        assignfile(ft,savedialog1.filename);  //add if file already exists
        append(ft);
        for n1:=0 to f2.count-1 do
            writeln(ft,f2[n1]);
        closefile(ft);
        end;
    end;

mem := '';
f2.free;
end;  //save selected seq.


procedure TfrmMain.SUS1Click(Sender: TObject);
begin
frmSelect.Top:=0;
frmSelect.left:=0;
frmSelect.show;
end;

procedure TfrmMain.Info1Click(Sender: TObject);
begin
if (fastatype=0) then
    showmessage('No alignment!')
else
    showmessage(copy('FASTA Output from GCG Package',1,255*byte(fastatype=1))+
                copy('FASTA Output from Pearson Package',1,255*byte(fastatype=2))+
                versionAlg+#10+
                'File name: ' + nom_input + #10+
                'Query name: '+nq+#10+
                'Query length: '+inttostr(ls)+#10+
                'Number of sequences: '+inttostr(nseq));

end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
Action := caNone;
end_program;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var i:integer;
begin
IniFile:=Tinifile.create(extractFilePath(application.exename)+'FASTA_Scan.ini');
for i:=0 to lv.Columns.count-1 do
    lv.Columns[i].Width := inifile.readinteger('FASTA_Scan','col'+inttostr(i),100);
inifile.free;
decimalseparator := '.';
mi_saveselectedsequences.enabled := false;
mi_SaveselectedsequencesinFASTACONVformat.enabled := false;
flagparam := false;
f := Tstringlist.create;
caption:='FASTA 36 Scan - version ' + version_number + ' (' + version_date+')';
end;


procedure TfrmMain.MenuItem1Click(Sender: TObject);
var w:integer;
begin
if lv.Items.count > 0 then
   for w:=0 to lv.items.count-1 do
       if lv.Items[w].selected then
          lv.Items[w].Checked := true;
end;

procedure TfrmMain.MenuItem2Click(Sender: TObject);
var w:integer;
begin
if lv.Items.count > 0 then
   for w:=0 to lv.items.count-1 do
       if lv.Items[w].selected then
          lv.Items[w].Checked:=false;
end;          

procedure TfrmMain.FormShow(Sender: TObject);
begin
if paramcount <> 0 then
   begin
   flagparam := true;
   nom_input := paramstr(1);
   Load(self);
   end;
end;

procedure TfrmMain.lvClick(Sender: TObject);
begin
count_checked_sequences;
end;

procedure TfrmMain.Selectallsequences1Click(Sender: TObject);
var w:integer;
begin //select all
if MessageDlg('Select all sequences?',mtConfirmation,[mbYes, mbNo],0)=mrYes then
   if lv.items.count>0 then
      for w:=0 to lv.items.count-1 do
          lv.items[w].checked:=true;
sb.panels[1].text:='Selected: '+inttostr(nseq);
end;

procedure TfrmMain.Unselectallsequences1Click(Sender: TObject);
var w:integer;
begin  //deselect all
if MessageDlg('Deselect all sequences?',mtConfirmation,[mbYes, mbNo],0)=mrYes then
   if lv.items.count>0 then
      for w:=0 to lv.items.count-1 do
          lv.items[w].checked:=false;
sb.panels[1].text:='Selected: 0';
end;

procedure TfrmMain.Invertselection1Click(Sender: TObject);
var w:integer;
begin
if lv.items.count>0 then
   for w:=0 to lv.items.count-1 do
       if lv.items[w].checked then
          lv.items[w].checked:=false
       else
          lv.items[w].checked:=true;
count_checked_sequences;
end;



procedure Lalign(var s:string; b:byte);
begin
s:=s+dupestring(' ',b-length(s));
end;

procedure TfrmMain.mi_SaveselectedsequencesinFASTACONVformatClick(
  Sender: TObject);

const validbase='ACGTUYRWSKMBDHVN-';
      tabseq=104;

var flagseqloc, flagtotrev, flagname, flaggap: boolean;
    deb, n1: word;
    s0, nomseq, nomquery, mem: string;
    s4,s5,q,seqquery, mem2, s,s2, query_id, new_seq, seq_ac, seq_def: string;
    ft: textfile;
    flagadd, flagfirstgi, flag_incl_gi, flagL, flagrev: boolean;
    w, w1, w2, w3, flag_different, i: integer;

begin
mem := '*';
n1 := 0;
flagname := false;
flaggap := false;
//verify if sequences are selected
for w := 0 to lv.items.count - 1 do
    if (lv.items[w].checked)  then
       begin
       n1 := 1;
       break;
       end;

if n1 = 0 then
   begin
   showmessage('No selected sequences!');
   exit;
   end;

flag_different := 0;
mem2 := '';
for w := 0 to lv.items.count - 1 do
    if (lv.items[w].checked)  then
        begin
        if mem2 = '' then
             mem2 := query_seq_list[w];
        if mem2 <> query_seq_list[w] then
           begin
           flag_different := 1;
           break;
           end;
        end;

showmessage(inttostr(flag_different));

if (flag_different = 1) then
   exit;

f2 := Tstringlist.create;
seq_ac := 'query';
while length(seq_ac) < 100 do
    seq_ac := seq_ac + ' ';
f2.add(seq_ac + ' ' +mem2);

for w := 0 to lv.items.count - 1 do
    if (lv.items[w].checked) then
       begin
       new_seq := '';
       for i := 1 to length(mem2) do
           if mem2[i] = seq_list[w][i] then
              new_seq := new_seq + '.'
           else
              new_seq := new_seq + seq_list[w][i];
       seq_ac := lv.items[w].subitems.strings[0];
       seq_ac := seq_ac + '  ' +lv.items[w].subitems.strings[1];

       while length(seq_ac) < 100 do
           seq_ac := seq_ac + ' ';
       f2.add(seq_ac + ' ' + new_seq);
       end;

f2.savetofile('1.fbs');


(*
//======= FASTA ============================
Screen.Cursor := crHourglass;
if fastatype <> 0 then
   begin
   flagtotrev := false;
   f2 := Tstringlist.create;
   //extract seq query
   seqquery := '';

   flagL:=true;
   if pos('initn:', f[posit[1]^+1]) <> 0 then //option -L "more info"
      flagL := false;

   if flagL then //option -L "more info"
      w := posit[1]^ + 6
   else
      w := posit[1]^ + 5;

   nomquery := copy(f[w],1,pos(' ',f[w])-1);
   repeat
       if copy(f[w],1,pos(' ',f[w])-1)=nomquery then
          begin
          seqquery:=seqquery+copy(f[w],length(nomquery)+1,255);
          inc(w,2);
          end;
       inc(w);
   until w >= posit[2]^;

   //delete space char.
   seqquery := trim(seqquery);
   while pos(' ', seqquery) <> 0 do
       delete(seqquery,pos(' ', seqquery), 1);

   //rev. seq
   if (pos('rev-comp',f[posit[1]^+1])<>0) or (pos('rev-comp', f[posit[1]^+2])<>0) then
      seqquery:=rev(seqquery);

   Lalign(nomquery, tabseq);

   f2.add(nomquery + seqquery);

   for w:=0 to lv.items.count-1 do
       begin
       if lv.items[w].checked then
          begin
          flagseqloc:=false;
          n1:=w+1;      // read sequence number
          if (pos('/rev',f[posit[n1]^-3])<>0)
             or (pos('rev-comp ',f[posit[n1]^+1])<>0)
             or (pos('rev-comp ',f[posit[n1]^+2])<>0) then
             begin
             flagrev:=true;
             flagtotrev:=true;
             end
          else
             flagrev:=false;
          case fastatype of 1:begin      //GCG
                              if pos('ID',f[posit[n1]^])=1 then
                                 begin
                                 s:=copy(f[posit[n1]^],6,80);
                                 s:=uppercase(copy(s,1,pos(' ',s)-1));
                                 end
                              else
                               if pos('LOCUS',f[posit[n1]^])=1 then
                                 begin
                                 s:=copy(f[posit[n1]^],13,80);
                                 s:=uppercase(copy(s,1,pos(' ',s)-1));
                                 end
                               else //local db sequences
                                 begin
                                 flagseqloc:=true;
                                 s:=f[posit[n1]^];
                                 end;
                               end;
                            2:begin        // PEARSON FASTA
                              s:=uppercase(copy(f[posit[n1]^],1,pos(' ',f[posit[n1]^])));
                              delete(s,1,2); //clear ">>"
                              s:=s+' '+copy(f[posit[n1]^],14,255);
                              if flagL then //option -L "more info"
                                 begin
                                 s:=s+' '+f[posit[n1]^+1];

                                 s4:=f[posit[n1]^+2];  //initn: 115 init1: 115 opt: 115
                                 s5:=f[posit[n1]^+3];  //banded Smith-Waterman score: 115;  100.000% identity (100.000% ungapped) in 23 nt overlap (1-23:15354-15376)
                                 end
                              else
                                 begin
                                 s4:=f[posit[n1]^+1];  //initn: 115 init1: 115 opt: 115
                                 s5:=f[posit[n1]^+2];  //banded Smith-Waterman score: 115;  100.000% identity (100.000% ungapped) in 23 nt overlap (1-23:15354-15376)
                                 end;
                              end;
                            3:begin  //SSEARCH
                              s:=uppercase(trim(copy(f[posit[n1]^],3,13))); //AC
                              s:=s+'  '+copy(f[posit[n1]^],16,255);
                              if flagL then //option -L "more info"
                                 begin
                                 s:=s+' '+f[posit[n1]^+1];
                                 s4:=f[posit[n1]^+2];
                                 s5:=f[posit[n1]^+3];
                                 end
                              else
                                 begin
                                 s4:=f[posit[n1]^+1];
                                 s5:=f[posit[n1]^+2];
                                 end;
                              end;
                            end;//case

          if lv.items[w].subitems.count>2 then
             nomseq:=lv.items[w].subitems.strings[0]
          else
             nomseq:='SEQUENCE_NAME_ERROR';
          //modification of sequence name if name already found
          while pos('*'+nomseq+'*',mem)<>0 do
             begin
             nomseq:=nomseq+'_';
             flagname:=true;
             end;

          mem:=mem+nomseq+'*';
          if flagseqloc then   //local db sequences
             begin
             w1:=1;
             s2:='';
             while posit[n1]^+w1<posit[n1+1]^ do
                begin
                if (f[posit[n1]^+w1]<>'') and checknumb(f[posit[n1]^+w1]) and (f[posit[n1]^+w1+1]<>'') then
                   begin
                   inc(w1,3);
                   deb:=1;
                   // skip seq ID
                   while f[posit[n1]^+w1][deb]<>' ' do
                      inc(deb);
                   // skip space character
                   while f[posit[n1]^+w1][deb]=' ' do
                      inc(deb);
                   for w2:=deb to length(f[posit[n1]^+w1-2]) do
                       if pos(f[posit[n1]^+w1-2][w2],validbase)<>0 then
                          s2:=s2+f[posit[n1]^+w1][w2];
                   end;
                inc(w1);
                end;
             end
          else        // EMBL or GB
             begin
             s:=copy(lv.items[w].subitems.strings[0],1,6);
             Lalign(s,6);
             w1:=1;
             s2:='';
             q:='';
             while posit[n1]^+w1<posit[n1+1]^ do
                   begin
                   if trim(uppercase(copy(f[posit[n1]^+w1],1,6)))=trim(uppercase(copy(s,1,pos('@',s+'@')-1))) then
                      begin
                      deb:=8;

                      for w2:=deb to length(f[posit[n1]^+w1-2]) do
                          if pos(f[posit[n1]^+w1-2][w2],validbase)<>0 then
                             begin
                             s2:=s2+f[posit[n1]^+w1][w2];
                             q:=q+f[posit[n1]^+w1-2][w2];
                             end;
                      end;
                   inc(w1);
                   end;

             end; //else

       s0:=lv.items[w].subitems.strings[0];

       if flagrev then
          begin
          s0:=s0+' /rev';
          s2:=rev(s2);
          q:=rev(q);
          end;

       Lalign(s0,16);

       s0:=s0+'  '+lv.items[w].subitems.strings[1];   //add DEFINITION

       //truncate if line>100 char
       if length(s0)>100 then
          s0:=copy(s0,1,98)+'..';

       Lalign(s0,tabseq);

       //clean seq vs query
       for w2:=1 to length(q) do
           begin
           if s2[w2]=q[w2] then
              s2[w2]:='.';
           if q[w2]='-' then
              s2[w2]:=chr(ord(s2[w2])+32);
           end;

       Lalign(s2,length(seqquery));

       f2.add(s0+s2+'    '+lv.items[w].subitems.strings[3]);
       end;
    end;

   //FASTA output header
   for w3 := 0 to f.Count - 1 do  //search for database info
       if (pos(' residues ',f[w3])<>0) and (pos(' sequences',f[w3])<>0) and (pos(' in ',f[w3])<>0) then
           break;
   f2.insert(0,'');
   f2.insert(0,'');
   for w:=w3+5 downto w3 do
       f2.Insert(0,f[w]);

   f2.insert(0,'');
   for w:=6 downto 0 do  //insert FASTA header
       f2.insert(0,f[w]);
     
   f2.insert(0,'');
   f2.insert(0,'FASTA scan '+version_number+' (output: query-anchored format)');

   //end of file
   f2.add('');
   for w:=f.Count-7 to f.Count-1 do
       f2.add(f[w]);
   end; //fasta

Screen.Cursor := crDefault;

savedialog1.filename:=changefileext(nom_input,'.fbs');
if savedialog1.execute then
   begin
   flagadd:=false;
   if fileexists(savedialog1.filename) then
      begin
      frmWarning.showmodal;
      if frmWarning.modalresult=mrcancel then
         exit;
      if frmWarning.modalresult=mrno then
         flagadd:=true
      else
         flagadd:=false;
      end;

   if not flagadd then
      f2.savetofile(savedialog1.filename)   //overwrite if file already exists
   else
      begin
      assignfile(ft,savedialog1.filename);  //add if file already exists
      append(ft);
      for n1:=0 to f2.count-1 do
          writeln(ft,f2[n1]);
      closefile(ft);
      end;
   end;
mem:='';
f2.free;
*)
end;

end.  //u_main
