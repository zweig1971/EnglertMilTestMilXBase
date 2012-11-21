unit DATECH_1;  {Eine zusÑtzliche Datentechnik Library TURBO PASCAL V 7.0}
{
  Changes:
  14.02.96      Erstellung
  20.03.96      NewKeyPressed wegen F11, F12
  03.07.96      Convert_To_Hex: variable StringlÑnge mit String[0]-Abfrage
  04.07.96      Cursor neu
  05.07.96      Read_Int mit Abbruch und Min-, Max-Wert
  28.08.96      Tabellen mit neuem Text + Loop-Anzeige
  30.04.97      Sub-Adr fÅr Identifikation Modulbus
  07.05.97      Festlegung Mod_Test_Nr global
  12.05.97      Erweiterung Modulbus ID
  03.09.97      TAsk_String
  26.09.97      Functioncodes korrigiert
  17.11.97      Ask_Data modifiziert
  16.04.98      Ask_Hex_LongInteger_Break
  26.10.98      Displ_Ifc_Stat;  wegen Update FG380.203 geÑndert
  27.10.98      Menue geÑndert
  25.03.99      ModAdr_Min definiert
  09.04.99      IFK-Modes
  11.05.99      Neue MagTab
  04.08.2000    ID fÅr APK
  11.08.2000    Fct_Clr_DtackErr
  14.08.2001    Erweitert auf $47: IDInUni : TIO_ID = [08,$40..$47];

}
{$S-}
interface                 { Teil der UNIT-Deklaration }
uses Crt32;     {graph, dos wegen cursor}
type
 TIO_ID    = set of 0..255;

const
 Fct_Reset      = $01;   {Reset fÅr IFC, gilt auch fÅr APL-IO-Bus}
 Fct_NG_Ein     = $02;   {Magnete Ein}
 Fct_NG_Aus     = $03;   {Magnete Aus}
 Fct_NG_Plus    = $04;   {Magnete Plus}
 Fct_NG_Minus   = $05;   {Magnete Minus}

 Fct_Wr_Sw1     = $06;   {Sollwert 1 schreiben}
 Fct_Wr_Sw2     = $07;   {Sollwert 2 schreiben}
 Fct_Wr_Sw3     = $08;   {Sollwert 3 schreiben}
 Fct_Wr_Sw4     = $09;   {Sollwert 4 schreiben}
 Fct_Wr_Sw5     = $0A;   {Sollwert 5 schreiben}

 Fct_Wr_Iob_Dta = $10;   {Setze Daten fÅr APL-IO-Bus bzw. Modulbus}
 Fct_Wr_Iob_Adr = $11;   {Setze Adr   fÅr APL-IO-Bus bzw. Modulbus}
 Fct_Set_IntMask= $12;   {Intr. Maske auf der IFC setzen}
 Fct_Wr_Echo    = $13;   {Sollwert fÅr Echo-Funktion}

 Fct_NG_Last1   = $14;   {Magnete Last 1}
 Fct_NG_Last2   = $15;   {Magnete Last 2}
 Fct_NG_Last3   = $16;   {Magnete Last 3}
 Fct_NG_Last4   = $17;   {Magnete Last 4}
 Fct_NG_Last5   = $18;   {Magnete Last 5}
 Fct_NG_Last0   = $19;   {Magnete Last 0}

 Fct_Start_Conv   = $5F;   {Starte ADC-Konversion}
 Fct_Wr_ModeReg   = $60;   {IFK-Mode mit Daten-Word bestimmen}
 Fct_Clr_DtackErr = $75;   {Reset Piggy-Err bzw. Dtack-Err-Bit auf der IFK}
 Fct_En_Broad     = $7F;   {Enable Broadcast-Mode}
 Fct_Dis_Broad    = $7E;   {Disable Broadcast-Mode}

 Fct_Rd_Ist1      = $81;   {Lese ADC-Wert}
 Fct_Rd_Ist2      = $82;
 Fct_Rd_Ist3      = $83;
 Fct_Rd_Ist4      = $84;

 Fct_Rd_Echo      = $89;   {Lese Echo Istwert}
 Fct_Rd_Ident     = $8E;   {16-bit breit: HiByte=not used, LoByte=Ident-code}
 Fct_Rd_Iob_Dta   = $90;   {Lesen Daten von APL-IO-Bus bzw. Modulbus}
 Fct_Rd_FGStat1   = $91;   {Lesen FunktionsGenerator-Status}
 Fct_Rd_FGStat2   = $92;   {Lesen FG-Status}
 Fct_Rd_IfkMode   = $97;   {Mode IFA, FG, MB der Ifk}

 Fct_Rd_Stat0     = $C0;   {Lesen Status 0}
 Fct_Rd_Stat1     = $C1;   {Lesen Status 1}
 Fct_Rd_Stat2     = $C2;   {Lesen Status 3}
 Fct_Rd_Stat3     = $C3;   {Lesen Status 3}
 Fct_Rd_Status    = $C9;   {Status IFC-Karte}
 Fct_Rd_HS_Ctrl   = $CA;   {Ctrl Maske Hochstrom-Interlock}
 Fct_Rd_GlobalStat= $CA;   {globaler Status IFK}

 Fct_Rd_HS_Status = $CB;   {Status Maske Hochstrom-Interlock}
 Fct_Rd_IFK_ID    = $CC;   {Lesen Idencode der IFC-Karte}

 Ifk_ID_450012_ModBus = $FD;  {IFK 450.012 fÅr Modulbus; lesen mit Fct CC[H] }
{ Ifk_ID_380210_ModBus = $FB;}  {IFK 380.210 fÅr Modulbus; lesen mit Fct CC[H]}
 Ifk_ID_380211_ModBus = $FB;  {IFK 380.210 fÅr Modulbus; lesen mit Fct CC[H]}

 Ifk_Mode_IFA         = 0;    {Data fÅr Fct-Code Fct_Rd/Wr_ModeReg }
 Ifk_Mode_FG          = 1;    {}
 Ifk_Mode_MB          = 2;    {}

{ Ifk_Pigy_ModBus   = $06;} {IFK 380.201 mit Modulbus-Piggy      Fct 8E[H] }
{ Ifk_ID_ModBus     = $FD;} {IFK 450.012 fÅr Modulbus: lesen mit Fct CC[H] }


 {Sub-Adr fÅr Modul-Bus Identifizierung: gÅltig fÅr alle Modulbus-Karten}
                          {Antwort als 16-Bit-Wert}
 ModAdr_Max        = $1F; {max erlaubte IO-Modul-Adresse}
 ModAdr_Min        = $01; {min erlaubte IO-Modul-Adresse}

 ModSub_Adr_K0Stat = $10;
 ModSub_Adr_K1Stat = $12;
 ModSub_Adr_SumStat= $14;  {Summenstatus Kanal1 u. 0}
 ModSub_Adr_Apk0ID = $16;  {Anpa·karten0 Ident}
 ModSub_Adr_Apk1ID = $18;  {Anpa·karten1 Ident}

 ModSub_Adr_ID     = $FE; {Hi-Byt: Card-ID         (LP), Lo-Byt: VG-ID = SlotID (VG)}
 ModSub_Adr_ModAdr = $FC; {Hi-Byt: Skalierung      (VG), Lo-Byt: Modul-Adr      (VG)}
 ModSub_Adr_EPLD   = $FA; {Hi-Byt: EPLD-ID         (LP), Lo-Byt: frei               }
 ModSub_Adr_Stat12 = $F8; {Hi-Byt: ModulStat Byte2 (LP), Lo-Byt:ModulStat Byte1 (LP)}
 ModSub_Adr_Stat34 = $F6; {Hi-Byt: ModulStat Byte4 (LP), Lo-Byt:ModulStat Byte3 (LP)}

 ModID_Schalt      = $1F; {FG 450.310 Schaltkarte                }
 ModID_Digital     = $20; {FG 450.320 Digital I/O                }
 ModID_Status      = $21; {FG 450.330 Status-Karte               }
 ModID_ADC         = $22; {FG 450.340 Analog I/O (+/-10V) mit Mux}
 ModID_12Event     = $23; {FG 450.350 12-fach Event-Generator    }
 ModID_32BitIO     = $24; {FG 450.361 2-Bit I/O                 }

 ModID_GPGen       = $26; {FG 450.380 Gatepuls Generator         }
                          {ID fÅr Anpasskarten APK}
 IDOut50 : TIO_ID = [07,$30..$33];  {ID-Nr fÅr FGF 423.241, 242}
 IDOutRe : TIO_ID = [$11..$14];     {ID-Nr fÅr FGF 423.250}
 IDOutRel: TIO_ID = [$50..$57];     {ID-Nr fÅr FGF 423.260}
 IDInOpto: TIO_ID = [05,09..$0F];   {ID-Nr fÅr OIKU  FGF 423.340,41,42}
 IDInUni : TIO_ID = [08,$40..$47];  {ID-Nr fÅr OIKUI FGF 423.350}

 Port_Stat      = $220;  {AT-Bus Port-Adressen}
 Port_Data      = $222;
 Port_Mode      = $224;
 Port_Rset      = $226;  {RÅcksetzen PC-MIL-Interface (Fifo, Timer usw.)  }
 Port_Intr      = $228;  {wichtig fÅr GerÑte-Simulation: Interrupts setzen}
 Port_Tmr1      = $22A;  {set and start timer1}
 Port_Tmr2      = $22C;  {set and start timer2}
 Port_Tmr2_1ms  = $22E;  {Umschalten Timer2: Data "0"=10us, Data "1"=1 ms}

 ifc_irmask_all = $E000; {Interrupt Enable Maske auf der IFC-Karte}
 ifc_irmask_intl= $8000;
 ifc_irmask_drdy= $4000;
 ifc_irmask_dreq= $2000;
 ifc_irmask_dis = $0000; {Interrupt Disable-All Maske auf der IFC-Karte}

 stat_intlock  = $0001;
 stat_dta_rdy  = $0002;
 stat_dta_req  = $0004;
 stat_wrt_rdy  = $0008;
 stat_val_wrd  = $0010;
 stat_ffo_ety  = $0020;
 stat_ffo_ful  = $0040;
 stat_cmd_mode = $0080;
 stat_cmd_rcv  = $0100;
 stat_timeout1 = $0200; { Bit 09 Hardware-Timer1: 0=laeuft, 1=abgelaufen  }
 stat_timeout2 = $0400; { Bit 10 Hardware-Timer2: 0=laeuft, 1=abgelaufen  }
 stat_timer2   = $0800; { Bit 11 Hardware-Timer2 Clock-Ticks: 0=10us 1=1ms}

 Taste_F1      = $3B; {Sondertasten liefern einen Doppelcode}
 Taste_F2      = $3C; {(2 x ReadKey): 1. Byte= #0     2. Byte= Tastenkode}
 Taste_F3      = $3D;
 Taste_F4      = $3E;
 Taste_F5      = $3F;
 Taste_F6      = $40;
 Taste_F7      = $41;
 Taste_F8      = $42;
 Taste_F9      = $43;
 Taste_F10     = $44;
 Taste_F11     = $85;
 Taste_F12     = $86;

 Taste_Pfeil_Links  = $4B;  {Vorsicht: NewReadKey benutzen}
 Taste_Pfeil_Rechts = $4D;
 Taste_Pfeil_Auf    = $48;
 Taste_Pfeil_Ab     = $50;
 Taste_Return       = #13;
 Taste_Esc          = $1B;
 Taste_Space        = #32;

 Strich_Lot_Solid   = $B3;  {öbergrî·e fÅr Grafiken}
 Strich_Lot_Doted   = $7C;  { Write (chr(Strich_Lot_Doted)); }

                            {Cursor blinken lassen:  TextColor (Yellow+128)}
 Cursor_Solid       = $DB;  {Varianten B0, B1, B2}
                            { Write (chr(Cursor_Solid )); }

 ScanCode : Byte = 0;         {FÅr Extented Keyboard; Init auf 0}
 ScanData : Word = 0;

 Life_Time_Slow  = 5000;       {Anzeige-Dauer universales Lebenszeichen}
 Life_Time_Fast  = 2000;
 Life_Time_Super = 1500;


type
 TMilErr       = (No_Err, Fc_To, Rd_To, Wr_To, Io_Adr, Io_AdrMode);
 TOnlineErr    = (NoErr, WrTo, RdTo, AdrErr, ModAdrErr);   {Mod=Modulbus}

 TMode   = (Byt,Wrd,LongWrd);                   {fÅr einlesen von Hex-Werten}
 TFct    = record case Byte of
            1: (B: packed record
                    Adr : Byte;
                    Fct : Byte
                   end;
                );
            2: (W : Word);
             end;

 TFctAdr  = record
             Fct : Byte;
             Adr : Byte;
            end;
 Str4        = string[4];
 Num_Str     = string[10];
 TAsk_String = string[50];
 Str80       = string[80];

 T_Dual  = record
            Adr   : Byte;
            Fct   : Byte;
            Fct_Rd: Byte;
            Dta_ok: Boolean;
            Dta   : LongInt;
           end;

 TLife = (Norm, Blinc);
 TLife_XY = record
             Mode    : TLife;
             PosX    : Byte;
             PosY    : Byte;
             Time    : LongInt;
             Disp_Win: procedure;
            end;

var
 Ifc_Test_Nr: Byte;    {globale Nr. fÅr IFK-Tests}
 Mod_Test_Nr: Byte;    {globale Nr. fÅr Modul-Tests}
 Single_Step: Boolean; {globale Variable}

 IFK_Tab_Test_Nr: Byte;
 Dual      : array [1..2] of T_Dual;     {Globale Variable fÅr Mil_Dual_Mode}
 Ch        : Char;
 read_str  : str4;
 Transf_Cnt: LONGINT;

                 {Proceduren der Au·enwelt bekanntmachen}
procedure Functioncode_Table;
procedure Displ_HS_Status;
procedure Displ_HS_Cmd;
procedure Displ_HS_Ctrl;
procedure convert_to_hex (in_string  : str4;
                           var hex_out: Word;
                           var status : boolean);

procedure Displ_PC_Stat;
procedure Displ_Ifc_Stat;
procedure Ini_Text_Win;
procedure Set_Text_Win; far;
procedure Ini_Headl_Win;
procedure Ini_Msg_Win;
procedure Ini_Err_Win;
procedure Ini_Info_Win;
procedure Set_Color_Alarm;
procedure Set_Color_Norm;
procedure Std_Msg;
procedure Ini_Jumper_Win;
procedure Cursor(Sichtbar:Boolean);     {True und False}
{
procedure Status_Tab1  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab2  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab3  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab4  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab5  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab6  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab7  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab8  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab9  (Spalte_Start, Zeile_Start: Byte);
procedure Status_TabA  (Spalte_Start, Zeile_Start: Byte);
procedure Status_TabB  (Spalte_Start, Zeile_Start: Byte);
procedure Status_TabC  (Spalte_Start, Zeile_Start: Byte);
procedure Status_TabD  (Spalte_Start, Zeile_Start: Byte);
procedure Status_TabE  (Spalte_Start, Zeile_Start: Byte);
procedure Status_TabF  (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab10 (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab11 (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab12 (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab13 (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab14 (Spalte_Start, Zeile_Start: Byte);
procedure Status_Tab15 (Spalte_Start, Zeile_Start: Byte);
}

function Ask_Data: Word;
function Ask_Data_Break (var User_Data: Word): Boolean;
function Hex_Word(w: Word): Num_Str;
function Hex_Byte(b: BYTE): Num_Str;
function Ask_Hex_Word: Word; {nicht fÅr Neuentwicklungen: besser Ask_Hex_Break}
function Ask_Hex_Byte: Byte; {nicht fÅr Neuentwicklungen: besser Ask_Hex_Break}
function Ask_Hex_Break (var In_Data: Word; Mode: TMode): Boolean; {Abort m. Esc}
function Ask_String_Break (Info_Str: TAsk_String; var In_Str: Str80): Boolean;
function KeyEPressed: Boolean;   {benîtigt fÅr Funktionstasten F11, F12}
function NewReadKey: Char;       {benîtigt fÅr Funktionstasten F11, F12}
function Read_Int (Min, Max: Integer; var Neu: Integer): Boolean;
function Read_LongInt (Min, Max: LongInt; var Neu: LongInt): Boolean;
{function Get_LastNr (var Num: Byte): Boolean; }

implementation                                    {Teil der UNIT-Deklaration}
  procedure Std_Msg;
   begin
    Ini_Msg_Win;
    Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
   end;

         {Text an User wird als Info-String mit max. 50 Zeichen Åbergeben}
 function Ask_String_Break (Info_Str: TAsk_String; var In_Str: Str80): Boolean;
  var ZeichenZahl : Integer;
  begin
   Ask_String_Break := False;
   Ini_Msg_Win;
   Write (Info_Str); Write (' bzw. Abort <CR> : ');
   {$I-}                            {Compiler Check aus, Error selber abfangen}
   Readln (In_Str);
   {$I+}
   if IoResult = 0 then                             {PrÅfe, ob Eigabe ok}
    begin
     ZeichenZahl   := Byte(In_Str[0]);
     if ZeichenZahl > 0 then  Ask_String_Break := True;
    end;
  end; {Ask_String_Break}

function KeyEPressed: Boolean; //assembler;

var z:char;
begin
     z:=ReadKey;
     KeyEPressed:=true;
end;

{ asm
   mov ah, $11
   int 16h
   mov ax,1
   jnz @@True
   xor ax,ax
 @@True:
 end; }

function ReadEKey: Word; assembler;
 asm
  mov ah,10h
  int 16h
 end;

function NewReadKey: Char;

 var myChar:char;

 begin

 //readln(myChar);
 myChar:=readkey;
 NewReadKey:=myChar;

   if ScanCode <> 0 then             //Gebe dem Anwender den Scancode
    begin
      NewReadKey := Char(ScanCode);
      ScanCode := 0;
      exit;
    end;

   ScanData := ReadEKey;         //Einschlie·lich Make-Code E0 der Pfeiltasten
   if( Lo(ScanData) = 0) or (Lo(ScanData) = $E0) then
    begin                             //Es ist ein ScanCode
     ScanCode := Hi (ScanData);
     NewReadKey := #0;                //Anwender soll 2. Byte abholen
     exit;
    end;
   NewReadKey := Char (Lo(ScanData)); //Es ist ein normales Zeichen}
 end;

 procedure Ini_Text_Win;
  begin
   Window(1, 3, 80, 24);
   TextBackground(White);
   TextColor(Black);               {Setze Schriftfarbe}
   ClrScr;
  end;

 procedure Ini_Jumper_Win;        {Nur fÅr Magnete}
  begin
   Window(02, 21, 79, 23);
   TextBackground(Blue);
   TextColor(Black);               {Setze Schriftfarbe}
   ClrScr;
  end;

 procedure Set_Jumper_Win;         {Nur fÅr Magnete}
  begin
   Window(02, 21, 79, 23);
   TextBackground(Black);
   TextColor(Black);               {Setze Schriftfarbe}
  end;


  function hex_byte(b: BYTE): Num_Str;
  const hex_num : STRING[16] = '0123456789ABCDEF';
  begin
   hex_byte := hex_num[(b shr 4) + 1] + hex_num[(b AND $0F) + 1];
  end;

 function hex_word (w: Word): Num_Str;
  begin
   hex_word := hex_byte(HI (w)) + hex_byte(LO (w));
  end; {hex_word}

 procedure Convert_To_Hex (in_string  : str4;
                           var hex_out: Word;
                           var status : boolean);
  var
   offset,i : INTEGER;
   dummy    : Word;
  begin
   offset := ORD('A') - ORD('a');
   status := TRUE;
   hex_out:= 0;
{   for i :=  1 TO 4 do  }
    for i :=  1 TO ord(In_String[0]) do    {In_String[0] = Anzahl Zeichen}
    begin
     if in_string[i] <> ' ' then
       begin
         if in_string[i] in ['a'..'f'] then
            in_string[i] := CHR(offset + ORD(in_string[i]));
         if in_string[i] in ['0'..'9'] then
          hex_out := hex_out * 16 + (ORD(in_string[i]) - ORD('0'))
         else
          begin
            if in_string[i] in ['A' ..'F'] then
              hex_out := hex_out * 16 + (ORD(in_string[i]) - ORD('A') + 10)
            else
             status := FALSE;
          end; {if in 0..9}
       end; {if<>blank}
    end; {for i}
  end;

FUNCTION Ask_Data: WORD;
 VAR in_data : WORD;
     Status : Boolean;
 Begin
  status := FALSE;
  WHILE NOT status DO
   Begin
    Ini_text_win; GotoXY(5, 22);   TextColor(Brown);
    Write ('Bitte WRITE-Daten fÅr IFK-Nr. ');  TextColor(Blue);
    Write (Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write (' [H] eingeben!!');
    if Ask_Hex_Break (In_Data, Wrd) then Status := True
    else
     begin
       Ini_Err_Win;
       write('ERROR: Sorry, USER: das war keine 4-stell. Hexzahl!!');
       Ch := NewReadKey;
     end;
   end; {WHILE}
  ask_data := in_data;
 End; {Ask_Data}

function Ask_Data_Break (var User_Data: Word): Boolean;
  VAR In_data : WORD;
      Status  : Boolean;
 Begin
  Status         := False;
  Ask_Data_Break := False;
  Ini_text_win; GotoXY(5, 22);   TextColor(Brown);
  Write ('Bitte WRITE-Daten fÅr IFK-Nr. ');  TextColor(Blue);
  Write (Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write (' [H] eingeben!!');
  if Ask_Hex_Break (In_Data, Wrd) then
   begin
    Status         := True;
    User_Data      := In_Data;
    Ask_Data_Break := True;
   end
  else
   begin
     Ini_Err_Win;
     write('ERROR: Sorry, USER: das war keine 4-stell. Hexzahl!!');
     Ch := NewReadKey;
   end;
 End; {Ask_Data_Break}


               {*********** Routinen fÅr div. Fenster ***************}
{
   Farbnamen fÅr Fenster und Schrift:
   Black, Blue, Green, Cyan, Red, Magenta, Brown, Yellow, White, Blink
}
  procedure ini_headl_win;
   begin                             {Definitionen gelten bis neu definiert}
    Window(1, 1, 80, 2);             {Definiert ein Textfenster: Spalte/Zeile}
    TextBackground(Magenta);         {Setze Hintergrund fÅr Textfenster}
    TextColor(Yellow);               {Setze Schriftfarbe}
    ClrScr;                          {Clear Window}
    GotoXY(1, 1);                    {Cursor auf Anfang Fenster}
   end;


  procedure set_text_win;
   begin
    Window(1, 3, 80, 24);
    TextBackground(White);
    TextColor(Black);               {Setze Schriftfarbe}
   end;

  procedure ini_msg_win;
   begin
    Window(1, 25, 80, 25);
    TextBackground(Green);
    TextColor(Yellow);               {Setze Schriftfarbe}
    ClrScr;
   end;

  procedure ini_err_win;
   begin
    Window(1, 25, 80, 25);
    TextBackground(Green);
    TextColor(Red);               {Setze Schriftfarbe}
    ClrScr;
   end;

  procedure ini_info_win;
   begin
    Window(50, 11, 80, 22);
    TextBackground(Cyan);
    TextColor(Blue);               {Setze Schriftfarbe}
    ClrScr;
   end;

  procedure Set_Color_Alarm;
   begin
    TextBackground(Red);
    TextColor(Yellow);
   end;

  procedure Set_Color_Norm;
   begin
    TextBackground(White);
    TextColor(Black);               {Setze Schriftfarbe}
   end;

 function ask_hex_byte: byte;
  var In_str : string[2];
      Status : boolean;
      Num    : byte;
      I      : word;
      Ch     : char;
  begin
   Status := FALSE;
   while not Status do
    begin
     ini_msg_win;
     write ('--> Bitte 2-stellige Hex-Daten eingeben: '); readln(In_str);
     if (In_str[1] in ['0'..'9','a'..'f','A'..'F']) and (In_str[2] in ['0'..'9','a'..'f','A'..'F']) then
            Status := TRUE;
     if not status then
      begin
       ini_err_win;
       write('ERROR: Sorry, USER: das war keine 2-stell. Hexzahl!! Weiter mit <Space>');
       Ch := NewReadKey ;
      end;
    end;  {while}

    for I := 1 to 2 do
     begin
      if In_str[I] in ['a'..'f'] then In_str[I] := upcase(In_str[I]);
      if In_str[I] in ['0'..'9'] then
       num := num*16 + (Ord(In_str[I]) - Ord('0'));
      if In_str[I] in ['A'..'F'] then
       num := num*16 + (Ord(In_str[I]) - Ord('A')+10);
     end;
    ask_hex_byte := num;
  end;

function Ask_Hex_Word: Word;
var Status  : Boolean;
    In_Data : Word;
    Read_Str: Str4;
begin
  status := False;
  while not status do
   begin
    ini_msg_win;
    write   ('--> Bitte 4-stellige Hex-Daten eingeben: '); readln(read_str);
    convert_to_hex (read_str,in_data,status);
    if not status then
     begin
      ini_err_win;
      write('ERROR: Sorry, USER: das war keine 4-stellige Hexzahl!  Weiter mit <CR>');
      NewReadKey;
     end;
   end; {while}
  Ask_Hex_Word := In_Data;
 end; {ask_hex_word}

 {ask_hex_break ist Einleseroutine fÅr Byte- und Word-Werte mit Abbruch durch
  Esc-Taste. Der Mode gibt an, ob Byte-, Word- oder LongInt Daten gelesen werden}
 function Ask_Hex_Break (var In_Data: Word; Mode: TMode): Boolean;
  label 1;
  var Status  : Boolean;
      Read_Str: Str4;
      Zeichen : Char;
      N, I    : Byte;
      savex, savey : Byte;    {Rette Cursor-Position}
      Ziffer_Max : Byte;

  begin
    Ask_Hex_Break := False;
    if (Mode = Byt) then Ziffer_Max := 2 else Ziffer_Max := 4;
    Ini_Msg_Win;
    Write   ('--> Bitte ', Ziffer_Max, '-stellige Hex-Daten eingeben oder Abbruch mit <Esc>: ');

    for I := 1 to Ziffer_Max do Read_Str[I] := '_';
    if (Mode = Byt) then Read_Str[0] := #2 else Read_Str[0] := #4;
    SaveX := WhereX; SaveY := WhereY;

     N := 0;
     repeat
       Zeichen := NewReadKey;
       case Zeichen of
        '0'..'9','A'..'F','a'..'f' : begin
                                        if N < Ziffer_Max then N := N + 1;
                                        Read_Str[N]:= Zeichen;
                                        GotoXY (savex, savey);
                                        for I := 1 to N do Write (Read_Str[I]);
                                      end;
         chr($08)  {Esc-Taste}      : begin
                                        if (N > 0) and (Read_Str[N] in ['0'..'9','A'..'F','a'..'f']) then
                                         begin
                                           Read_Str[N]:= ' ';
                                           GotoXY (savex, savey);
                                           for I := 1 to N do Write (Read_Str[I]);
                                           N := N - 1;
                                         end;
                                       end;
         chr($1B)   {Return-Taste}  : begin
                                        Ini_Msg_Win;
                                        goto 1;
                                      end;
       end; {case}
     until Zeichen = chr($0D);
     if N = 0 then goto 1;

     Convert_To_Hex (Read_Str,In_Data,Status);
     if status then Ask_Hex_Break := True;
1:
  end; {Ask_Hex_Byte_Break}

 procedure Functioncode_Table;
  label 99;
  var Ch : Char;

  procedure Code_Table1;
   begin
    Ini_Text_Win;
            {[Dez]-[Hex]--Funktion---------------v     [Dez]-[Hex]--Funktion---------------v'}
    write ('    0     0   Keine Funktion               128    80   Daten lesen              ');
    write ('    1     1   Schalter auf Standby (Reset) 129    81   Istwert 1 lesen          ');
    write ('    2     2   GerÑt einschalten            130    82   Istwert 2 lesen          ');
    write ('    3     3   GerÑt ausschalten            131    83   Istwert 3 lesen          ');
    write ('    4     4   PolaritÑt + setzen           132    84   Istwert 4 lesen          ');
    write ('    5     5   PolaritÑt - setzen           133    85   Istwert 5 lesen          ');
    write ('    6     6   Sollwert  1 setzen           134    86   Istwert 6 lesen          ');
    write ('    7     7   Sollwert  2 setzen           135    87   Istwert 7 lesen          ');
    write ('    8     8   Sollwert  3 setzen           136    88   Istwert 8 lesen          ');
    write ('    9     9   Sollwert  4 setzen           137    89   Echo-Sollwert rÅcklesen  ');
    write ('   10     A   Sollwert  5 setzen           138    8A   frei                     ');
    write ('   11     B   Sollwert  6 setzen           139    8B   .                        ');
    write ('   12     C   Sollwert  7 setzen           140    8C   .                        ');
    write ('   13     D   Sollwert  8 setzen           141    8D   frei                     ');
    write ('   14     E   Wait                         142    8E   Piggy-Back Ident.        ');
    write ('   15     F   Release                      143    8F   Datenblock v. SD-uP lesen');
  end;

  procedure Code_Table2;
   begin
    Ini_Text_Win;
            {[Dez]-[Hex]--Funktion---------------v     [Dez]-[Hex]--Funktion---------------v'}
    write ('   16    10   Datenbus setzen (Modbus)     144    90   Datenbus lesen (Modbus)  ');
    write ('   17    11   Adre·bus setzen    "         145    91   GerÑtdaten1 / FG Stat1   ');
    write ('   18    12   Set-INR-Maske                146    92   GerÑtdaten2 / FG Stat2   ');
    write ('   19    13   Echo-Sollwert setzen         147    93   GerÑtdaten3 / FG Sw1     ');
    write ('    |     |   GerÑtefunktion               148    94   GerÑtdaten4 / FG Sw2     ');
    write ('   32    20   Funkt-Generator Broadcast    149    95   GerÑtdaten5 / FG SP-Sw1  ');
    write ('    |     |                                150    96   GerÑtdaten6 / FG SP-Sw2  ');
    write ('   40    28   Status 1 anfordern           151    97   GerÑtdaten7 / IFK-Mode   ');
    write ('   41    29   Status 2 anfordern           152    98   GerÑtdaten8 / I2C-Cmd/Dat');
    write ('   42    2A   Status 3 anfordern           153    99   Rd FctDec RAM-Datan  (MB)');
    write ('   43    2B   SIS_12 Betrieb               154    9A   Modulbus Status Reg.     ');
    write ('   44    2C   SIS_18 Betrieb               .           .                        ');
    write ('    |     |   GerÑtefunktion               .           .                        ');
    write ('   95    5F   Convert Cmd fÅr ADCs         .           .                        ');
    write ('   96    60   IFK-Mode (Modbus,FG,IFK)     .           .                        ');
    write ('   97    61   I2C-Bus: Cmd/Data setzten    .           .                        ');
    write ('   98    62   Wr FctDecoder RAM-Adr        .           .                        ');
    write ('   99    63   Wr FctDecoder RAM-Daten      .           .                        ');
    write ('    |     |                                .           .                        ');
    write ('   116   74   frei                         191    BF   frei                    ');
   end;

  procedure Code_Table3;
   begin
    Ini_Text_Win;
            {[Dez]-[Hex]--Funktion---------------v     [Dez]-[Hex]--Funktion---------------v'}
    write ('   117   75   Reset SEL-Error (auf Piggy)  192    C0   Status-Byte 1 lesen      ');
    write ('    |     |                                193    C1   Status-Byte 2 lesen      ');
    write ('    |     |   Reserve fÅr HI-Intrl         194    C2   Status-Byte 3 lesen      ');
    write ('    |     |                                .           .                        ');
    write ('    |     |                                .           .                        ');
    write ('   125   7D   Reset RCV-Error (VW Test)    201    C9   * Interrupt-Maske  lesen ');
    write ('   126   7E   Reset Broadcast IFK          202    CA   * Ctrl-Register    lesen ');
    write ('   127   7F   Set   Broadcast IFK          203    CB   * Maske HI-Interl  lesen ');
    write ('                                           204    CC   * IFK-Identcode    lesen ');
    write ('----- Ende der Write-Functioncodes ------  205    CD   * IFK-EPLD-Version lesen ');
    write ('     [ab 128 (80 Hex) Read-Function]       206    CE   frei                     ');
    write ('                                           .           .                        ');
    write ('                                           223    DF   frei                     ');
    write ('                                           224    E0   # Piggy Identcode lesen  ');
    write ('                                           225    E1   # Piggy EPLD-Vers.lesen  ');
    write ('  Legende:                                 226    E2   frei                     ');
    write ('  * Register auf der Interface-Karte       .           .                        ');
    write ('  # Register auf dem Piggy                 255    FF   frei                    ');
   end;

  procedure Code_Table4;
   begin
    Ini_Text_Win;
              {ID-Code[Hex]  IFK Version }
    writeln ('   FE          FG 380.201   ');
    writeln ('   FD          FG 450.011  IFK speziell fÅr Modulbus ');
    writeln ('   FD          FG 450.012  IFK speziell fÅr Modulbus ');
    writeln ('   FC          FG 380.203   ');
    writeln ('   FB          FG 380.210  IFK mit Modulbus + Fkt-Gen');

  end;

  procedure Code_Table5;
   begin
    Ini_Text_Win;
              {ID-Code [Hex] Piggy Function'}
    writeln ('   01          FG 402.000  Serielles I/O V24            ');
    writeln ('   02          FG 402.000  Serielles I/O 20mA           ');
    writeln ('   03          FG 380.540  neuer Funktionsgenerator     ');
    writeln ('   04          FG 403.000  IEC-Bus Controller           ');
    writeln ('   05          FG 380.710  Strahldiagnose Blockmode     ');
    writeln ('                                                        ');
    writeln;
    writeln ('   08          FG 404.000  GSI85-Bus                    ');
    writeln;
    writeln ('   10          FG 443.000  VME-Bus                      ');
    writeln ('   20          FG 468.000  Flash                        ');
    writeln ('   40          FG 495.000  Ext. Event 6-fach            ');
   end;

 procedure Code_Table_Msg;
  begin
   Ini_Text_Win;
   Ini_Msg_Win;
   TextColor(red); Write ('Fortsetzung'); TextColor(Yellow);
   Write (' mit <Space>    oder    E[X]it ');
   Set_Text_Win;
  end;


  procedure Fct_Headline;
   begin
    Ini_Headl_Win;
    GotoXY(01,01);
    write('SCHREIBEN (SE->IFK)          Funktioncodes [27.02.1997]          LESEN (IFK->SE)');
    GotoXY(01,02);
    write(' [Dez]-[Hex]--Funktion---------------v    [Dez]-[Hex]--Funktion---------------v');
    Code_Table_Msg;
   end;

  procedure IFK_Headline;
   begin
    Ini_Headl_Win;
    GotoXY(01,01);
    write('                          IFK-Identifikation     [19.03.1999]                   ');
    GotoXY(01,02);
    write(' ID-Code[Hex]  IFK Version                         Lesen mit Fct-Code: CC [Hex]');
    Code_Table_Msg;
   end;


  procedure Pigy_Headline;
   begin
    Ini_Headl_Win;
    GotoXY(01,01);
    write('                          IFK: Piggy Ident-Codes [10.02.1997]                   ');
    GotoXY(01,02);
    write(' ID-Code[Hex]  Piggy Funktion                      Lesen mit Fct-Code: 8E [Hex]');
    Code_Table_Msg;
   end;

  begin
    Fct_Headline;
    Code_Table1;
    repeat until KeyEPressed;
    Ch := NewReadKey;
    if Ch in ['x','X']then Goto 99;

    Fct_Headline;
    Code_Table2;
    repeat until KeyEPressed;
    Ch := NewReadKey;
    if Ch in ['x','X']then Goto 99;

    Fct_Headline;
    Code_Table3;
    repeat until KeyEPressed;
    Ch := NewReadKey;
    if Ch in ['x','X']then Goto 99;

    IFK_Headline;
    Code_Table4;
    repeat until KeyEPressed;
    Ch := NewReadKey;
    if Ch in ['x','X']then Goto 99;

    Pigy_Headline;
    Code_Table5;
    repeat until KeyEPressed;
    Ch := NewReadKey;
    if Ch in ['x','X']then Goto 99;
99:
  end;


 PROCEDURE Displ_Pc_Stat;
  Begin
     {Info-Anzeige der Bit-Belegung Hardware-Status}
      Ini_Info_Win;
      TextColor(Brown);
      writeln('Bit 11: Timer2: 0=10us  1=1ms');
      writeln('Bit 10: Timer2: Timeout      ');
      writeln('Bit 09: Timer1: Timeout      ');
      writeln('Bit 08: CMD/DATA receive     ');
      writeln('Bit 07: CMD/DATA transmit    ');
      writeln('Bit 06: Fifo full            ');
      writeln('Bit 05: Fifo empty           ');
      writeln('Bit 04: Valid Word           ');
      writeln('Bit 03: Ready for Write      ');
      writeln('Bit 02: Data Req             ');
      writeln('Bit 01: Data Ready           ');
      write  ('Bit 00: Interlock            ');
      TextColor(Black);
   End; {displ_dyn_stat_bits}

 PROCEDURE Displ_Ifc_Stat;
  Begin
     {Info-Anzeige der Bit-Belegung IFC-Status}
      ini_info_win;
      writeln('Bit 15: Intrlck_Mask  1-Enable');
      writeln('Bit 14: Dta_Rdy_Mask  1-Enable');
      writeln('Bit 13: Dta_Req_Mask  1-Enable');
      writeln('Bit 12: Intrlck-Sign  0-aktiv ');
      writeln('Bit 11: Dta-Rdy-Sign  0-aktiv ');
      writeln('Bit 10: Dta-Req-Sign  0-aktiv ');
      writeln('Bit 09: F-Gen SW3 To  0-aktiv ');
      writeln('Bit 08: Powerup-Bit   0-aktiv ');
      writeln;
      writeln('Bit 07: 0                     ');
      writeln(' "  |   |                     ');
      write  ('Bit 00: 0                     ');
   End; {displ_ifc_stat}

 PROCEDURE Displ_HS_Status;
  Begin
     {Info-Anzeige der Bit-Belegung Hochstrom-Maske}
      ini_info_win;
      writeln('Bit 15: HS Gate Enabl 0-Disabl');
      writeln('Bit 14: HS Enable     0-Disabl');
      writeln('Bit 13: HS v. Softw.  0-aktiv ');
      writeln('Bit 12: HS-SumIntl FF 0-aktiv ');
      writeln('Bit 11: HS-Sig live   0-aktiv ');
      writeln('Bit 10: HS-Sig FF     0-aktiv ');
      writeln('Bit 09: HS-Opto live  0-aktiv ');
      writeln('Bit 08: HS-Opto FF    0-aktiv ');
      writeln;
      writeln('Bit 07: 0                     ');
      writeln(' "  |   |                     ');
      write  ('Bit 00: 0                     ');
   End; {displ_HS_Status}

 PROCEDURE Displ_HS_Cmd;
  Begin
     {Info-Anzeige der Bit-Belegung Hochstrom-Maske}
      Set_Text_Win;
      Window(01, 11, 35, 22);
      TextBackground(Cyan);
      TextColor(Black);               {Setze Schriftfarbe}
      ClrScr;
      writeln('7F H : Set   Broadcast           ');
      writeln('7E H : Reset Broadcast           ');
      writeln('7D H : Reset RCV-Error (Val Word)');
      writeln('  ');
      writeln('  ');
      writeln('7C H : Enable  HS-INL    Gate    ');
      writeln('7B H : Disable HS-INL    Gate    ');
      writeln('7A H : Enable  HS-INL            ');
      writeln('79 H : Disable HS-INL            ');
      writeln('78 H : Set     HS-INL v. Rechner ');
      writeln('77 H : Reset   HS-INL v. Rechner ');
      write  ('76 H : Reset   HS-INL    Status  ');
   End; {Displ_HS_Cmd}


 PROCEDURE Displ_HS_Ctrl;
  Begin
     {Info-Anzeige der Bit-Belegung Hochstrom-Maske}
      Ini_Info_Win;
      TextColor(Blue);
      writeln('Bit 15: MIL-Spg. 15V   1-aktiv');
      writeln('Bit 14: Pigy/DTACK-Err 0-aktiv');
      writeln('Bit 13: IRQ VG-Leiste  1-aktiv');
      writeln('Bit 12: Mode Mbus VGPin7 0-akt');
      writeln('Bit 11: JmpSw1-Str 0=gest aktv');
      writeln('Bit 10: JmpEn-IO   0=gest aktv');
      writeln('Bit 09: Broadcast     1-aktiv ');
      writeln('Bit 08: Receive Error 1-aktiv ');
      writeln;
      writeln('Bit 07: 0                     ');
      writeln(' "  |   |                     ');
      write  ('Bit 00: 0                     ');
      TextColor(Black);
  End; {displ_HS_Ctrl}

   procedure Ini_Stat_Win;
   begin                             {Definitionen gelten bis neu definiert}
    Window(1, 1, 80, 2);             {Definiert ein Textfenster: Spalte/Zeile}
    TextBackground(Magenta);         {Setze Hintergrund fÅr Textfenster}
    TextColor(Yellow);               {Setze Schriftfarbe}
    ClrScr;                          {Clear Window}
    GotoXY(1, 1);                    {Cursor auf Anfang Fenster}
   end;


  {Falls Min u. Max = 0: Standard Integer-Werte: -32768 .. + 32767}
function Read_Int (Min, Max: Integer; var Neu: Integer): Boolean;
 label 1;
 var User_Int: LongInt;
     IoRes   : Integer;
     Answer  : Char;

 begin
   Read_Int := False;
   if ((Min = 0) and (Max = 0)) then
   begin
    Min := -32768;
    Max := +32767;
   end;
   repeat
     Ini_Msg_Win;
     Write ('Bitte Integer (ganze Zahl) im Bereich [',Min,'..',Max,'] eingeben oder [Q]uit: ');
     {$I-}                            {Compiler Check aus, Error selber abfangen}
     Read (User_Int);
     {$I+}
     IoRes := IoResult;
     if not ((Min <= User_Int) and (User_Int <= Max) and (IoRes = 0)) then
      begin
        Ini_Err_Win;
        Write ('ERROR: Eingabe nicht korrekt!!     Abort mit <Esc> oder wiederholen mit <CR>: ');
        Answer := ReadKey;
        if Answer = #27 then
         begin
          Ini_Msg_Win;
          Write ('Abort ');
          goto 1;
         end;
      end;
   until (Min <= User_Int) and (User_Int <= Max) and (IoRes = 0);
   Read_Int := True;
   Neu := User_Int;
1: Set_Text_Win;
 end; {Read_Int}

  {Falls Min u. Max = 0: Standard Integer-Werte: FFFF FFFF ... + EFFF FFFF}
function Read_LongInt (Min, Max: LongInt; var Neu: LongInt): Boolean;
 label 1;
 var User_LongInt: LongInt;
     IoRes       : Integer;
     Answer      : Char;
 begin
   Read_LongInt := False;
   if ((Min = 0) and (Max = 0)) then
   begin
    Min := $80000000;
    Max := $7FFFFFFF;
   end;
   repeat
     Ini_Msg_Win;
     Write ('Bitte Integer im Bereich [',Min,'..',Max,'] eingeben oder [Q]uit: ');
     {$I-}                            {Compiler Check aus, Error selber abfangen}
     Read (User_LongInt);
     {$I+}
     IoRes := IoResult;
     if not ((Min <= User_LongInt) and (User_LongInt <= Max) and (IoRes = 0)) then
      begin
        Ini_Err_Win;
        Write ('ERROR: Eingabe nicht korrekt!!     Abort mit <Esc> oder wiederholen mit <CR>: ');
        Answer := ReadKey;
        if Answer = #27 then
         begin
          Ini_Msg_Win;
          Write ('Abort ');
          goto 1;
         end;
      end;
   until (Min <= User_LongInt) and (User_LongInt <= Max) and (IoRes = 0);
   Read_LongInt := True;
   Neu := User_LongInt;
1: Set_Text_Win;
 end; {Read_LOngInt}


 procedure Cursor(Sichtbar:Boolean);
{ var
   schirmanfang : LongInt;
   reg:Registers;

   procedure Karte;           //Stelle Kartentyp fest
   var
     Treiber,Modus:Integer;
   begin
     Treiber:=Detect;
     DetectGraph(Treiber,Modus);
     case Treiber of
       1..6,8..9 : Schirmanfang:=$b800;
       -2,7,10   : Schirmanfang:=$b000;
     end;
   end;       }

 begin{ //Cursor
   reg.ah:=1;
   if sichtbar then
   begin
     if schirmanfang=$b800 then begin
       reg.ch:=6;
       reg.cl:=7;
     end
    else
     begin
       reg.ch:=12;
       reg.cl:=13;
     end;
     Intr(16,reg);
   end
  else
   begin
     reg.ch:=32;
     reg.cl:=7;
     Intr(16,reg);
   end;      }
 end;

end.  { UNIT DATECH_1 }


