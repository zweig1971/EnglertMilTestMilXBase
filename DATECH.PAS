unit DATECH;                        {Datentechnik Library TURBO PASCAL V 7.0}
{
  EnthÑlt allgemeine Konstanten und Proceduren fÅr PC-Mil-Anwendungen.
  Beachten: Die MIL-Bus Operationen benutzen den Timer 1 !!

  Changes:
  03.12.93      Erstellung
  07.12.93      Ask_Hex_Word
  05.01.94      Write_real_sw Vorzeichen korrigiert
  13.01.94      Neu: Hex_Bin_Str  als Ersatz fÅr hex_bin
  14.01.94      PcMil-Routinen ersetzt durch Mil-Routinen nach WPan: T_Mil
  07.02.94      Port_Tmr2_1ms=$22E; Timer2: Data "0"=10us, Data "1"=1 ms
  09.02.94      Erweiterung T_Mil fÅr APL IO-Bus
  17.02.94      BitTst hinzugefÅgt
  17.03.94      Konstanten fÅr Intr-Masken zugefÅgt
  24.03.94      Single Loop zugefÅgt
  01.06.94      Set_Color
  24.03.95      T_Mil fÅr MIL-Hardware-Tests um reine Write-Data-Funktion
                erweitert.
  19.04.95      Mil.Rd: Timeout Valid-Word 60 us nach dem Fct-Code !!
  17.07.95      Fct-Codes erweitert fÅr neue IFK
  18.07.95      Ifc_Online auf OnlineErr umgestellt: bessere Diagnose!
  06.09.95      Rd_Real_Sw (MaxWert: Real): Word; : neg. Vorzeichen zulassen
  12.09.95      T_Mil.Ifc_Online: vor dem Reset laufenden Transfer abwarten!
  15.09.95      Displ_PC_Stat u. a. aus der MIL-Base Åbernommen, damit Codesegment
                bei Anwenderprogrammen nicht zu gro·
  21.09.95      Neue Magnettabellen SVE usw.
  29.11.95      Funktionstasten Codes aufgenommen
  30.11.95      Mil_Detect_Ifc; Mil_Detect_Ifc_Compare; Mil_Echo: neu eingefÅgt;
  06.12.95      Write_Real_10_Uni: Universelle Real Ausgabe ADC/DAC mit
                variabler Anzahl AuflîsungsBits: z. B. 8, 10, 12, 15 Bit
  12.12.95      Read_Real_10 verfeinert 7FFF 8000
  03.01.96      Read IFC-Status enable/disable Åber F-Taste
  08.02.96      Status-Tabellen erweitert mit F-Tasten; Intr-Mask
                +/- 10V Read_real_10 korrigiert mit ROUND
  14.02.96      Wegen Åberschreiten der Segment-Grenze fÅr DATECH.PAS
                radikal nach DATECH_1 ausgelagert!
  19.02.96      MIL-Mag: status-tab ausgelagert
  01.03.96      Find_First_Online
  08.03.96      E: 3 Functionscodes MIL_RD_DATA
  02.05.96      function Conv_Real_Hex (R_Zahl: Real): Word;
  06.05.96      Mil_Wr erweitert mit F-Tasten
  25.06.96      Mil_Ask_Ifc: Auch bei 0 IFK: Eingabe von Adr-Nr erlaubt
  26.08.96      B: Status-Abfrage mit Adr-PrÅfung
  16.09.96      MIL_Detect: Spalten-Zahl limitiert
  21.11.96      IoSubAdr: Adr.IoSub > 7
  30.04.97      Erweiterung mit Wr_ModBus/Rd_ModBus : Modulbus-Routinen
  13.05.97      Ident fÅr IFK-Piggy
  30.07.97      Dual-Mode erweitert
  01.08.97      Dual-Mode mit Mindest-Abstand: Mil.Wr_Delay (W_Data, Fct, MilErr);
  20.10.97      T_Mil.Wr_Delay : Wait_Time Parameter neu
  31.10.97      T_Mil.Rd_Delay : Wartezeit zwischen WrRdy und FctCode Read1 u. Read2
  06.11.97      Mil_Ask_Ifc: wiederholte Abfrage der Online-Adressen
  17.11.97      MIL_Wr erweitert
  19.11.97      Modbus_WrRd
  02.04.98      Mil_Loop Åberarbeitet
  20.10.98      Wegen FG 380.203 Update: IFK-Adresse wird bei Statuslesen
                nur noch bei Fct-Code C0 [Hex] zurÅckgeliefert!!
                Alle anderen ist Low-Byte 00 !!! s. a. Mil_Stat_All
  26.10.98      auch Mil_Rd_Ifc_Stat; geÑndert
  12.11.98      Hex_Bin8_Str neu
  10.12.98      check_ifc_adr erweitert
  07.04.99      Mil_IfkMode
  03.02.00      Mil_IfkMode update FG380.211: IFk-Steckplatzkodierung
  09.02.00      TimeValWrd = 8; erhîht Et
  12.04.00      IFK-Mode Modulbus todgelegt, weil durch Verdrahtung vorgegeben!
                in Procedure Mil_IfkMode;
  10.08.00      Timeout: TimeValWrd  erhîht Et
  14.08.00      TimeWrRdy  = 10;  auf 100 us erhîht 14.08.2000
  09.03.00      Pfeilrichtung bei AskIFC geÑndert
}
{$S-}

interface                 { Teil der UNIT-Deklaration }
uses Crt32, Datech_1;

const
 Dta_Mode   = 0;
 Cmd_Mode   = 1;
 Reset_Mil  = 1;
 TimeWrRdy  = 10;  {auf 100 us erhîht 14.08.2000}
 TimeValWrd = 10; {10 x 10us}  {Durch DOS-Interrupts f. Realtimeclock auch mehr}
                 {testweise, wegen mil_u128.exe, erhîht: 10.8.00 Et}
 msg_any_key =
      'Weiter mit beliebiger Taste!                                     ';
 msg_single_step =                      {nicht fÅr Neuentwicklung}
      'Loop- u. Single-Test mit [Q] beenden!    Single-Step mit [SPACE] ';
                                    {Error-Codes}
 err_undefind    = 0;
 err_ok          = 1;
 err_ifc_adr     = 2;   {Adresse nicht im Bereich 1..255}
 err_adr_offline = 3;   {IFC-Adr meldet sich nicht mit FCT-Code C9 Hex}
 err_rd_timeout  = 6;   {keine Antwort beim Lesen von Daten}
 err_wr_data     = 7;   {Daten werden nicht geschrieben}

 err_msg_max     = 8;  {Max-Index fÅr Error-Message-Array}
 err_msg_00      = 'Fehler undefiniert!';
 err_msg_01      = 'Kein Fehler!';
 err_msg_02      = 'IFC-Adr nicht im Bereich 1..255!';
 err_msg_03      = 'IFC-Adr meldet sich nicht mit Fct-Code C9 [H]!';
 err_msg_04      = 'Keine Antwort beim Lesen des Flash-Piggy-Ident!';
 err_msg_05      = 'Falscher Ident fÅr Flash-Piggy!';
 err_msg_06      = 'Keine Antwort beim Lesen der Flash-Daten!';
 err_msg_07      = 'Daten werden nicht geschrieben!';
 err_msg_08      = 'Erase-Chip Kommando war nicht erfolgreich!';

 err_msg_ary :  array [0..err_msg_max] of string =
                 (
                  err_msg_00,err_msg_01,err_msg_02,err_msg_03,err_msg_04,
                  err_msg_05,err_msg_06,err_msg_07,err_msg_08
                 );

type
 Str19   = string[19];
 Str10   = String[10];
 Str4    = STRING[4];
 num_str = STRING[10];
 TPcStat = record case Word of          {Interner PC-Mil Interface}
            1: ( B : set of             {Bits nur lesebar}
                  (Intl,           {Bit0}
                   Drdy,
                   Dreq,
                   RdyWr,
                   ValWrd,
                   FfoEty,
                   FfoFul,
                   CmdDta,          {Bit7}
                   RcvCmdDta,
                   Tmr1Tmout,
                   Tmr2Tmout,
                   Tmr2_1ms,        {Bit 11}
                   Frei_12,
                   Frei_13,
                   Frei_14,
                   Frei_15);
                  );
            2: ( W: WORD;);
           end;
{ Beispiel fÅr Mîglichkeit Bits per Namen auch zu setzen
        EnCmdStat  = (GpEn,Frei_1,EnIntr,Frei_3,EnStartEvent,EnStopEvent,EnTif1Event, EnTif2Event);
        TEnCmdStat = packed array [EnCmdStat] of Boolean;
        TGpEnCmd   = record case Byte of
                      1: (Bit: TEnCmdStat);
                      2: (Byt: Byte);
                     end;
        EnStat.Bit[GpEn] := True;
}

 TIfkCAStat = record case Word of   {Interner Status IFK-Karte}
            1: ( B : set of         {Bits nur lesebar}
                  (Frei_00,         {Bit0}
                   Frei_01,
                   Frei_02,
                   Frei_03,
                   Frei_04,
                   Frei_05,
                   Frei_06,
                   Frei_07,          {Bit7}
                   RcvErr,
                   Broadcast,
                   JumprEnIO,
                   JumprSwStr,        {Bit 11}
                   SelModbus,
                   IrqVG,
                   Pigy_Dtack_Err,
                   Mil_15V);
                  );
            2: ( W: WORD;);
           end;

 TAdrSw   = record
             Adr: Byte;
             Fct: Byte;
             Sw : Integer;
            end;

 TRdData  = record
             IfcAdr  : Byte;
             FctCode : Byte;
             RdData  : Integer;
             ErrCode : Word;
            end;

 TRealSw  = record
             Sw   : Integer;
             Maxw : Real;
            end;

 TIoAdr   = record                       {FÅr I/O-Karte APL FG 385....}
             IfcAdr : Byte;   {MIL-IFC-Adressse 8 Bit}
             IoCard : Byte;   {APL-IO-Bus Karten-Adr. Bit A3..A7}
             IoSub  : Byte;   {APL-IO-Bus Sub-Adr.    Bit A0..A2}  {Byte-Adr; Aktuell 5 Adr. benutzt}
            end;

 TAdrMode = (AdrNew, AdrOld); {Modulbus: Adresse neu schreiben bzw. alte Adresse benutzen: spart Zeit}
 TModAdr  = record                       {FÅr I/O-Karte APL FG 450....}
             AdrIfc : Byte;   {MIL-IFC-Adressse 8 Bit}
             AdrCard: Byte;   {APL-Mod-Bus Karten-Adr. Bit 13..8 = 5 Bit}
             AdrSub : Byte;   {APL-Mod-Bus Sub-Adr.    Bit  7..0 = 8 Bit}
             AdrMode: TAdrMode; {auf vorherige oder neue Adr schreiben/lesen}
            end;

  TSw_Mode= (V, H, A);  {Volt, Hex, Ampere}
  TSw   = record
           Mode: TSw_Mode;
           Max : Real;
           User: Word;
          end;


  T_Mil =
   object
     procedure Reset;                      {Reset PC-Mil-Interface          }
     procedure WrFct (Fct: TFct; var MilErr: TMilErr);
     procedure Wr (Data: Word; Fct: TFct; var MilErr: TMilErr);
     procedure Rd (var Data: Word; Fct: TFct; var MilErr: TMilErr);
     procedure Ifc_Online (IfcAdr: Word; var RetAdr: Byte; var OnlineErr: TOnlineErr);
     procedure WrDta (Data: Word; var MilErr: TMilErr);
     procedure Wr_Delay (Data          : Word; Fct: TFct; Wait_Time: Byte; var MilErr: TMilErr);
     procedure Rd_Delay (var Data: Word; Fct: TFct; Wait_Time: Byte; var MilErr: TMilErr);

     procedure Timer1_Set(Time: Word);     { Startet Timer1: time*10us      }
     function  Timeout1: Boolean;          { Testet Timer1 auf Timeout      }
     procedure Timer1_Wait(Time: Word);    { Wartet mit Timer1: time*10us   }

     procedure Timer2_Set(Time: LongInt);  { Startet Timer2: Basis 10 us    }
     function  Timeout2: Boolean;          { Testet Timer2 auf Timeout      }
     procedure Timer2_Wait(Time: LongInt); { Wartet mit Timer2              }
               {fÅr sog. I/O-Bus FG385.xxx}
     procedure Wr_IoBus (    Data: Word; Adr: TIoAdr;   var MilErr: TMilErr);
     procedure Rd_IoBus (var Data: Word; Adr: TIoAdr;   var MilErr: TMilErr);
               {fÅr Modul-Bus FG450.xxx}
     procedure Mod_Online (Ifc_Adr: Byte; Mod_Adr: Byte; var Mod_RetAdr: Byte; var OnlineErr: TOnlineErr);
     procedure Wr_ModBus (    Data: Word; Adr: TModAdr;  var MilErr: TMilErr);
     procedure Rd_ModBus (var Modbus_Data: Word; Adr: TModAdr;  var MilErr: TMilErr);
   end; { T_Mil }

var
 Mil        : T_Mil;                                  {neues Object nach WPan}
 Bit16_Str  : string[19];

 status    : BOOLEAN;
 loop      : BOOLEAN;
 read_data : WORD;
 write_data: WORD;
 mil_data  : WORD;
 user_input: CHAR;

 rd_timeout: BOOLEAN;
 timout_cnt: LONGINT;
 timout_rd : LONGINT;
 timout_wr : LONGINT;

                      {Proceduren der Au·enwelt bekanntmachen}
procedure Hex_Bin_Str (Data          : Word;              {Ersatz f. Hex_Bin}
                       var Bit16_String: Str19
                      );

procedure Hex_Bin8_Str(Data          : Byte;              {Ersatz f. Hex_Bin}
                       var Bit8_String: Str10
                      );

procedure Write_Real_10         (Data: Integer);
procedure Write_Real_10V_Bipol  (Data: Word);
procedure Write_Real_10V_Unipol (Data: Word);
procedure Write_Real_Sw (Param: TRealSw);
procedure Find_First_Online;
procedure Mil_Detect_Ifc;
procedure Mil_Detect_Ifc_Compare;
procedure Mil_Wr_Fctcode;
procedure Mil_WrData (Mil_Data: Word);
procedure Mil_Wr_Rd  (Write_Data: WORD);
procedure Mil_Wr     (Wr_Data: Word);
procedure Mil_Echo   (Ifk_Test_Nr: Word);

procedure Mil_Stat_All     (Ifk_Test_Nr: Word);
procedure Mil_Rd_Ifc_Stat  (Ifk_Test_Nr: Word);
procedure Mil_Rd_Status;
procedure Mil_Rd_HS_Ctrl   (Ifk_Test_Nr: Word);
procedure Mil_Rd_HS_Status (Ifk_Test_Nr: Word);
procedure Mil_HS_Stat_Cmd  (Ifk_Test_Nr: Word);
procedure Int_Mask;
procedure Convert_Hex_Volt;
procedure Mil_Ask_Ifc;
procedure New_Ifc_Adr;
procedure Mil_Loop;
procedure Mil_Rd_Data;

procedure Mil_Rd_Fifo;
procedure Mil_Dual_Mode;
procedure Life_Sign_XY (Param: TLife_XY);
procedure Mil_IfkMode;

function Check_Ifc_Adr (Ifc_Adress: Byte): Boolean;
function Rd_Real_10: Word;                               {nur 0..+10.0 Eingabe}
function Rd_Real_Sw (MaxWert: Real): Word;               {+/- 10.0 Eingabe}
function Ask_Sw_Break (var SW : TSw): Boolean;           {lese wahlweise Volt, Hex, Amp}
function Ask_Hex_LongInteger_Break (var In_Data: LongInt): Boolean; {Abort m. Esc}

function Conv_Real_Hex (R_Zahl: Real): Word;
function BitTst (Data: Word; BitNr: Byte): Boolean;
function BitSet (Data: Word; BitNr: Byte): Word;         {Bit wird ge"odert"}
function BitClr (Data: Word; BitNr: Byte): Word;
function BitInv (Data: Word; BitNr: Byte): Word;

implementation                                    {Teil der UNIT-Deklaration}
procedure Mil_Dual_Mode;
 label 99;
 const
  Z_Base  = 8;
  Z_Adr   = Z_Base+0;
  Z_FctWr = Z_Base+1;
  Z_FctRd = Z_Base+2;
  Z_Wr    = Z_Base+4;
  Z_Rd    = Z_Base+5;
  Z_Err   = Z_Base+6;
  Z_MilErr= Z_Base+7;
  Z_MilTxt= Z_base+8;
  Z_Transf= Z_Base-2;
  Z_FTast_Win = 22;
  Z_MinMax=19;

  S_Base1 = 3;
  S_Base2 = 50;
  S_Transf= S_Base1+22;
  S_Dat1  = S_Base1+12;
  S_Dat2  = S_Base2+12;
  S_FTast_Win = 55;

  Min_Text = '        ';
  Max_Time = 1;               {n x 10us}
  Max_Text = ' + 10 us';      {entsprechend Max_time!!}
  Max_Off  = 24;

 var
   MilErr      : TMilErr;
   Fct         : TFct;
   User_Word   : Word;
   Transf_Count: LongInt;
   Err1_Count  : LongInt;
   Err2_Count  : LongInt;
   MilErrCount1: LongInt;
   MilErrCount2: LongInt;
   Wait_WrRd   : Integer;
   Wr_Data1_LInt : LongInt;
   Wr_Data2_LInt : LongInt;
   Abstand_Max   : Boolean;

 procedure  Ini_Dual_Win;
  begin
   Window(S_FTast_Win, Z_FTast_Win, 79, 23);
   TextBackground(Green);
   TextColor(Yellow);               {Setze Schriftfarbe}
   ClrScr;
  end;

 procedure Data_Transfer (S_Step: Boolean);{Datenanzeige nur bei Single-Step}
  var W_Data    : Word;
      R_Data    : Word;
      Transf_Err: Boolean;
      W_Data_Int: LongInt;
      R_Data_Int: LongInt;
   begin
    Mil.Reset;                   {schafft klare Fifo-VerhÑltnisse}
    Transf_Err  := False;
    Transf_Count:= Transf_Count + 1;

    if Abstand_Max then Mil.Timer2_Wait(Max_Time);
{Write Data1}
    Fct.B.Adr   := Dual[1].Adr;
    Fct.B.Fct   := Dual[1].Fct;
    W_Data      := Dual[1].Dta;

    if Abstand_Max then Mil.Wr_Delay (W_Data, Fct, Max_Time, MilErr)
    else Mil.Wr (W_Data, Fct, MilErr);

{Read Data1}
    Fct.B.Adr   := Dual[1].Adr;
    Fct.B.Fct   := Dual[1].Fct_Rd;
    W_Data_Int  := abs(Dual[1].Dta);

    if Abstand_Max then Mil.Rd_Delay (R_Data, Fct, Max_Time, MilErr)
    else  Mil.Rd (R_Data, Fct, MilErr);
    R_Data_Int  := abs(R_Data);
    if (MilErr<>No_Err) or (R_Data_Int<>W_Data_Int) then Transf_Err := True;
    if S_Step then
     begin
      Set_Text_Win;
      GotoXY(S_Dat1, Z_Wr);  write(Hex_Word(W_Data_Int));
      GotoXY(S_Dat1, Z_Rd);  write(Hex_Word(R_Data));
      GotoXY(S_Dat1, Z_MilTxt); Write ('                    '); {Clr Text}
     end;

    if Transf_Err then
     begin
      Set_Text_Win;
      GotoXY(S_Dat1, Z_Wr);  write(Hex_Word(W_Data_Int));

      if (MilErr<>No_Err) then
       begin                                              {MilErr}
        MilErrCount1 := MilErrCount1 +1;
        GotoXY(S_Dat1, Z_Rd);  write('    ');             {Clr Rd-Daten}
        GotoXY(S_Dat1, Z_MilErr);  write(MilErrCount1:10);
        GotoXY(S_Dat1, Z_MilTxt);
        TextColor(Red);
        case MilErr of
          Fc_To     : Write ('PC: W/R ->    WrRdy');
          Rd_To     : Write ('Rd-Timeout: Val Wrd');
          Wr_To     : Write ('PC: Wr-Mode>WrRdy  ');
          Io_Adr    : Write ('I/O-Adr            ');
          Io_AdrMode: Write ('I/O-AdrMode        ');
        end;
        TextColor(Black);
       end
      else
       begin                                {kein MilErr, Datenfehler?}
         if (R_Data_Int <> W_Data_Int) then
          begin
           TextColor(Red);
           GotoXY(S_Dat1, Z_Rd);  write(Hex_Word(R_Data_Int));
           TextColor(Black);
           Err1_Count   := Err1_Count +1;
           GotoXY(S_Dat1, Z_Err);  write(Err1_Count:10);
           GotoXY(S_Dat1, Z_MilTxt); Write ('                    '); {Clr Text}
          end;
       end; {if No_Milerr}
     end;   {if TransfErr}

{Write Data2}
    Fct.B.Adr   := Dual[2].Adr;
    Fct.B.Fct   := Dual[2].Fct;
    W_Data      := Dual[2].Dta;
    if Abstand_Max then Mil.Wr_Delay (W_Data, Fct, Max_Time, MilErr)
    else Mil.Wr (W_Data, Fct, MilErr);

{Read Data2}
    Transf_Err  := False;
    Fct.B.Adr   := Dual[2].Adr;
    Fct.B.Fct   := Dual[2].Fct_Rd;
    W_Data_Int  := abs(Dual[2].Dta);

    if Abstand_Max then Mil.Rd_Delay (R_Data, Fct, Max_Time, MilErr)
    else  Mil.Rd (R_Data, Fct, MilErr);
    R_Data_Int := abs(R_Data);
    if (MilErr<>No_Err) or (R_Data_Int<>W_Data_Int) then Transf_Err := True;
    if S_Step then
     begin
      Set_Text_Win;
      GotoXY(S_Dat2, Z_Wr);  write(Hex_Word(W_Data_Int));
      GotoXY(S_Dat2, Z_Rd);  write(Hex_Word(R_Data));
      GotoXY(S_Dat2, Z_MilTxt); Write ('                    '); {Clr Text}
     end;

    if Transf_Err then
     begin
      Set_Text_Win;
      GotoXY(S_Dat2, Z_Wr);     Write(Hex_Word(W_Data_Int));

      if (MilErr<>No_Err) then
       begin                             {MilErr}
        MilErrCount2 := MilErrCount2 +1;
        GotoXY(S_Dat2, Z_Rd);  write('    ');             {Clr Rd-Daten}
        GotoXY(S_Dat2, Z_MilErr);  write(MilErrCount2:10);
        GotoXY(S_Dat2, Z_MilTxt);
        TextColor(Red);
        case MilErr of
          Fc_To     : Write ('PC: W/R ->    WrRdy');
          Rd_To     : Write ('Rd-Timeout: Val Wrd');
          Wr_To     : Write ('PC: Wr-Mode>WrRdy  ');
          Io_Adr    : Write ('I/O-Adr            ');
          Io_AdrMode: Write ('I/O-AdrMode        ');
        end;
        TextColor(Black);
       end
      else
       begin                                {kein MilErr, Datenfehler?}
         if (R_Data_Int <> W_Data_Int) then
          begin
           TextColor(Red);
           GotoXY(S_Dat2, Z_Rd);  write(Hex_Word(R_Data_Int));
           TextColor(Black);
           Err2_Count   := Err2_Count +1;
           GotoXY(S_Dat2, Z_Err);  write(Err2_Count:10);
           GotoXY(S_Dat2, Z_MilTxt); Write ('                    '); {Clr Text}
          end;
       end; {if No_Milerr}
     end;   {if TransfErr}
  end; {Data_Transfer}

 procedure Clr_Counters;
  begin
    Set_Text_Win;
    Transf_Count  := 0;
    MilErrCount1  := 0;
    MilErrCount2  := 0;
    Err1_Count    := 0;
    Err2_Count    := 0;
    GotoXY(S_Dat1, Z_Err);    write(Err1_Count:10);
    GotoXY(S_Dat2, Z_Err);    write(Err1_Count:10);
    GotoXY(S_Dat1, Z_MilErr); write(MilErrCount1:10);
    GotoXY(S_Dat2, Z_MilErr); write(MilErrCount2:10);
    GotoXY(S_Dat1, Z_MilTxt); Write ('                    ');
    GotoXY(S_Dat2, Z_MilTxt); Write ('                    ');
    if Single_Step then
     begin
       GotoXY(S_Transf+14,Z_Transf); write(Transf_Count:10);
     end;
    GotoXY(S_Dat1, Z_Wr);  write('    ');             {Clr Wr-Daten}
    GotoXY(S_Dat2, Z_Wr);  write('    ');             {Clr Wr-Daten}
    GotoXY(S_Dat1, Z_Rd);  write('    ');             {Clr Rd-Daten}
    GotoXY(S_Dat2, Z_Rd);  write('    ');             {Clr Rd-Daten}
  end;

 procedure Set_Test_Data;
  begin
    Wr_Data1_LInt  := Dual[1].Dta;
    Wr_Data2_LInt  := Dual[2].Dta;
    Wr_Data1_LInt  := Wr_Data1_LInt + 1;
    Wr_Data2_LInt  := Wr_Data2_LInt - 1;
    if Wr_Data1_LInt > $FFFF then Dual[1].Dta := 0     else Dual[1].Dta := Wr_Data1_LInt;
    if Wr_Data2_LInt = 0     then Dual[2].Dta := $FFFF else Dual[2].Dta := Wr_Data2_LInt;;
  end;

  Begin  {Dual_Mil_Mode: Hauptroutine}
    Dual[1].Adr   := 0;        {Init Dual-Mode Array}
    Dual[1].Fct   := 0;
    Dual[1].Fct_Rd:= 0;
    Dual[1].Dta_ok:= False;
    Dual[1].Dta   := 0;
    Dual[2].Adr   := 0;
    Dual[2].Fct   := 0;
    Dual[2].Fct_Rd:= 0;
    Dual[2].Dta_ok:= False;
    Dual[2].Dta   := 0;

    Transf_Count  := 0;
    MilErrCount1  := 0;
    MilErrCount2  := 0;
    Err1_Count    := 0;
    Err2_Count    := 0;
    Transf_Count  := 0;
    Wait_WrRd     := 0;
    Abstand_Max   := True;   {Teste zuerst mit max. Abstand}

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
    GotoXY(5, 22);
    write ('Welche MIL-Adr Nr. 1 ?');
    if Ask_Hex_Break (User_Word, Byt) then
     Dual[1].Adr := Lo (User_Word)  else Exit;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
    GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
    GotoXY(5, 22);
    write ('Welche MIL-Adr Nr. 2 ?');
    if Ask_Hex_Break (User_Word, Byt) then
     Dual[2].Adr := Lo (User_Word)  else Exit;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
    GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
    GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
    GotoXY(5, 22);
    write ('Welchen (Write-) Function-Code fÅr Adr Nr. 1 ?');
    if Ask_Hex_Break (User_Word, Byt) then
     Dual[1].Fct := Lo (User_Word)  else Exit;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
    GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
    GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
    GotoXY(5, 17);  write (' Fct 1      : ', hex_byte(Dual[1].Fct));
    GotoXY(5, 22);
    write ('Welchen (Write-) Function-Code fÅr Adr Nr. 2 ?');
    if Ask_Hex_Break (User_Word, Byt) then
     Dual[2].Fct := Lo (User_Word)  else Exit;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
    GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
    GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
    GotoXY(5, 17);  write (' Fct 1      : ', hex_byte(Dual[1].Fct));
    GotoXY(5, 18);  write (' Fct 2      : ', hex_byte(Dual[2].Fct));

    Ini_Msg_Win;
    write ('Soll Datentest [0 ...FFFF] automatisch erfolgen?  [J/N<CR>]: ');
    repeat until KeyPressed;
    Ch := ReadKey;

 if Ch in ['j','J'] then    {automat. Datentest}
  begin
    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(01,04); write('Dual Mode: Sende 2 Fct-Codes + Daten [0..FFFF] mit PrÅfung auf 1 oder 2 Adressen');
    GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
    GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
    GotoXY(5, 17);  write (' Fct 1 Wr   : ', hex_byte(Dual[1].Fct));
    GotoXY(5, 18);  write (' Fct 2 Wr   : ', hex_byte(Dual[2].Fct));

    GotoXY(5, 22);
    write ('Welchen Read-Function-Code fÅr Adr Nr. 1 ?');
    if Ask_Hex_Break (User_Word, Byt) then
     Dual[1].Fct_Rd := Lo (User_Word)  else Exit;
    Set_Text_Win;
    TextColor(Brown);
    GotoXY(5, 19);  write (' Fct 1 Rd   : ', hex_byte(Dual[1].Fct_Rd));

    GotoXY(5, 22);
    write ('Welchen Read-Function-Code fÅr Adr Nr. 2 ?');
    if Ask_Hex_Break (User_Word, Byt) then
     Dual[2].Fct_Rd := Lo (User_Word)  else Exit;

    Set_Text_Win;
    TextColor(Brown);
    GotoXY(5, 20);  write (' Fct 2 Rd   : ', hex_byte(Dual[2].Fct_Rd));
    GotoXY(5, 22);  ClrEol;

    Ini_Msg_Win;
    write ('Dateneingabe ok? [J/N]: ');
    repeat until KeyPressed;
    Ch := ReadKey;
    if not (Ch in ['j','J']) then Exit;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(01,Z_Base - 5); write('Dual Mode: Sende 2 Fct-Codes + Daten [0..FFFF] auf 2 Adressen mit Daten-PrÅfung!');

    TextColor(Blue);
    GotoXY(S_Base1   , Z_Base-1); write('Interface-Karte 1 [Hex]'); TextColor(Brown);
    GotoXY(S_Base1   , Z_Base );  write('IFK-Adr   : ');
    GotoXY(S_Base1   , Z_FctWr);  write('Fct-Wr    : ');
    GotoXY(S_Base1   , Z_FctRd);  write('Fct-Rd    : ');
    TextColor(Blue);
    GotoXY(S_Base2   , Z_Base-1); write('Interface-Karte 2 [Hex]'); TextColor(Brown);
    GotoXY(S_Base2   , Z_Base );  write('IFK-Adr   : ');
    GotoXY(S_Base2   , Z_FctWr);  write('Fct-Wr    : ');
    GotoXY(S_Base2   , Z_FctRd);  write('Fct-Rd    : ');

    GotoXY(S_Transf  , Z_Transf); write('Transf. Count: ');
    GotoXY(S_Transf+14,Z_Transf); TextColor(Black); write(Transf_Count:10);

    TextColor(Brown);
    GotoXY(S_Base1   , Z_Wr);    write('Write Data: ');
    GotoXY(S_Base1   , Z_Rd);    write('Read  Data: ');
    GotoXY(S_Base1   , Z_Err);   write('DataErrCnt: ');
    GotoXY(S_Base1   , Z_MilErr);Write('Mil ErrCnt: ');
    GotoXY(S_Base1   , Z_MilTxt);Write('Mil ErrTxt: ');

    GotoXY(S_Base2   , Z_Wr);    write('Write Data: ');
    GotoXY(S_Base2   , Z_Rd);    write('Read  Data: ');
    GotoXY(S_Base2   , Z_Err);   write('DataErrCnt: ');
    GotoXY(S_Base2   , Z_MilErr);Write('Mil ErrCnt: ');
    GotoXY(S_Base2   , Z_MilTxt);Write('Mil ErrTxt: ');

    TextColor(Black);
    GotoXY(S_Dat1    , Z_Adr);    Write(hex_byte(Dual[1].Adr));
    GotoXY(S_Dat1    , Z_FctWr);  Write(hex_byte(Dual[1].Fct));
    GotoXY(S_Dat1    , Z_FctRd);  Write(hex_byte(Dual[1].Fct_Rd));

    GotoXY(S_Dat2    , Z_Adr);    Write(hex_byte(Dual[2].Adr));
    GotoXY(S_Dat2    , Z_FctWr);  Write(hex_byte(Dual[2].Fct));
    GotoXY(S_Dat2    , Z_FctRd);  Write(hex_byte(Dual[2].Fct_Rd));

    Ini_Dual_Win; Writeln ('F1 : Clear Count        ');
                  Write   ('F5 : WrDta/WrFct min/max');

    Set_Text_Win; TextColor(Brown);
    GotoXY(S_FTast_Win, Z_FTast_Win-3); Write('Belegung F-Tasten:');

    GotoXY(S_Base1, Z_MinMax  );
    Write ('Abstand zw. Data u. Fct/Fct-Codes =');
    TextCOlor(Black);
    GotoXY(S_Base1, Z_MinMax+1); Write ('1..5 us je n. CPU-Speed');
    GotoXY(S_Base1+Max_Off, Z_MinMax+1);
    if Abstand_Max then
     begin
     TextColor(Red); Write (Max_Text);
     end
    else Write (Min_Text);

    Dual[1].Dta := $0;
    Dual[2].Dta := $FFFF;

    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Data_Transfer (Single_Step);           {Mit den Daten aus dem Dual-Array}
       Set_Test_Data;
       Set_Text_Win;
       GotoXY(15,Z_Base - 4); ClrEol;
       GotoXY(S_Transf+14,Z_Transf); TextColor(Black); write(Transf_Count:10);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then
      begin
       Single_Step := False;
       Set_Text_Win;
       TextColor(Yellow);
       GotoXY(15,Z_Base - 4); write('Im Loop-Mode Datenanzeige nur im Fehlerfall!!');
       GotoXY(S_Transf+14,Z_Transf); TextColor(Red + 128);
       Write('   Loop   ');
       GotoXY(S_Dat1, Z_Wr);  write('    ');             {Clr Wr-Daten}
       GotoXY(S_Dat2, Z_Wr);  write('    ');             {Clr Wr-Daten}
       GotoXY(S_Dat1, Z_Rd);  write('    ');             {Clr Rd-Daten}
       GotoXY(S_Dat2, Z_Rd);  write('    ');             {Clr Rd-Daten}
      end; {loop}

     if not Single_Step then
      begin
       Data_Transfer (Single_Step);       {Mit den Daten aus dem Dual-Array}
       Set_Test_Data;
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                     Single_Step := True;
                     Clr_Counters;
                   end;
        Taste_F5 : begin
                     Single_Step := True;
                     Clr_Counters;
                     if Abstand_Max then Abstand_Max := False
                     else Abstand_Max := True;
                     GotoXY(S_Base1+Max_Off, Z_MinMax+1);
                     if Abstand_Max then
                      begin
                      TextColor(Red); Write (Max_Text);
                      end
                     else Write (Min_Text);
                   end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  end
 else
  begin  {kein automat. Datentest, sondern fixe Daten!}
    Ini_Msg_Win;
    write ('Sollen zu Fct-Code 1 auch Daten gesendet werden? [J/N]: ');
    repeat until KeyPressed;
    Ch := ReadKey;
    if Ch in ['j','J'] then
     begin
       Dual[1].Dta    := Ask_Data;
       Dual[1].Dta_ok := True;
       Ini_Text_Win;
       TextColor(Brown);
       GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
       GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
       GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
       GotoXY(5, 17);  write (' Fct 1      : ', hex_byte(Dual[1].Fct));
       GotoXY(5, 18);  write (' Fct 2      : ', hex_byte(Dual[2].Fct));
       GotoXY(5, 19);  write (' Dat 1      : ', hex_word(Dual[1].Dta));
     end
    else
     begin
      Dual[1].Dta_ok := False;
      Set_Text_Win;
      GotoXY(5, 22);
      write ('                                                                ');
     end;

    Ini_Msg_Win;
    write ('Sollen zu Fct-Code 2 auch Daten gesendet werden? [J/N]: ');
    repeat until KeyPressed;
    Ch := ReadKey;
    if Ch in ['j','J'] then
     begin
       Dual[2].Dta    := Ask_Data;
       Dual[2].Dta_ok := True;
       Ini_Text_Win;
       TextColor(Brown);
       GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
       GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
       GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
       GotoXY(5, 17);  write (' Fct 1      : ', hex_byte(Dual[1].Fct));
       GotoXY(5, 18);  write (' Fct 2      : ', hex_byte(Dual[2].Fct));
       if Dual[1].Dta_ok then
        begin
         GotoXY(5, 19);  write (' Dat 1      : ', hex_word(Dual[1].Dta));
        end;
       GotoXY(5, 20);  write (' Dat 2      : ', hex_word(Dual[2].Dta));
     end
    else
     begin
      Dual[2].Dta_ok := False;
      Ini_Text_Win;
      TextColor(Brown);
      GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
      GotoXY(5, 15);  write (' Adr 1      : ', hex_byte(Dual[1].Adr));
      GotoXY(5, 16);  write (' Adr 2      : ', hex_byte(Dual[2].Adr));
      GotoXY(5, 17);  write (' Fct 1      : ', hex_byte(Dual[1].Fct));
      GotoXY(5, 18);  write (' Fct 2      : ', hex_byte(Dual[2].Fct));
      if Dual[1].Dta_ok then
       begin
        GotoXY(5, 19);  write (' Dat 1      : ', hex_word(Dual[1].Dta));
       end;
     end;

    Ini_Msg_Win;
    write ('Dateneingabe ok? [J/N]: ');
    repeat until KeyPressed;
    Ch := ReadKey;
    if not (Ch in ['j','J']) then Exit;

    Ini_Text_Win;
    Transf_Cnt := 0;
    TextColor(Brown);
    GotoXY(03,04); write('--- Dual Mode: Sende 2 Fct-Codes und/oder 2 Daten auf 1 oder 2 Adressen ---');
    GotoXY(10,07); write  ('Fct-Word1 [Fct/Adr]: ',hex_byte(Dual[1].Fct),hex_byte(Dual[1].Adr) ,' [H]');
    GotoXY(10,08); write  ('Fct-Word2 [Fct/Adr]: ',hex_byte(Dual[2].Fct),hex_byte(Dual[2].Adr) ,' [H]');

    GotoXY(50,07);
    if Dual[1].Dta_ok then write ('Data 1: ',hex_word(Dual[1].Dta),' [H]')
    else  write ('                        ');

    GotoXY(50,08);
    if Dual[2].Dta_ok then write  ('Data 2: ',hex_word(Dual[2].Dta),' [H]')
    else  write ('                        ');

    GotoXY(6, 11); writeln('Wr_Fct_Cnt :');
    GotoXY(29,12); writeln('^  ^');
    TextColor(Black);

    Ch := ' ';
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
       Ch := ReadKey;
       if  Ch in ['x','X'] then Goto 99;
      end;

    repeat
     repeat
       Set_Text_win;
       Transf_Cnt := Transf_Cnt+ 1;
       GotoXY(25,11);  Write(Transf_Cnt:10);

       if  Dual[1].Dta_ok then
        begin
         Mil.Timer2_Wait(5);
         Mil.WrDta (Dual[1].Dta, MilErr);
        end;

       Mil.Timer2_Wait(5);
       Fct.B.Adr := Dual[1].Adr;
       Fct.B.Fct := Dual[1].Fct;
       Mil.WrFct (Fct, MilErr);

       if  Dual[2].Dta_ok then
        begin
         Mil.Timer2_Wait(5);
         Mil.WrDta (Dual[2].Dta, MilErr);
        end;

       Mil.Timer2_Wait(5);                                     { Wartet 5x10us}
       Fct.B.Adr := Dual[2].Adr;;
       Fct.B.Fct := Dual[2].Fct;;
       Mil.WrFct (Fct, MilErr);

     until KeyPressed or (Ch = ' ');
     if Ch = ' ' then
       begin
         Std_Msg;
         repeat until KeyPressed;
       end;
     Ch := ReadKey;
    until Ch in ['x','X'];
  end; {fixe Daten}
99:
End; {Mil_WrDual_Fct}


 procedure New_Ifc_Adr;
  VAR answer : CHAR;
  Begin
    status := FALSE;
    WHILE NOT status DO
     Begin
      Ifc_Test_Nr := Ask_Hex_Byte;
      IF ifc_test_nr IN [1..255] THEN status := TRUE;
     End;
  End; {ask_ifc}



 PROCEDURE Mil_Rd_Ifc_Stat;
  label 99;
  const
   Z_StatCount = 8;
   Z_StatHex   = 10;
   Z_StatBin   = Z_StatHex + 1;
   Z_MilBus    = 13;
   Z_MilInt    = Z_MilBus+1;
   Z_MilDry    = Z_MilBus+2;
   Z_MilReq    = Z_MilBus+3;


  var read_data,fct_code : WORD;
      MilErr : TMilErr;
      Fct    : TFct;
      Transf_Cnt: LongInt;
      Timout_Cnt: LongInt;
      Adress    : Word;

   PROCEDURE show_stat_reg;
    var Bit16_Strg: Str19;
        Read_Data : Word;
    Begin
     Fct.B.Adr := Ifk_Test_Nr;
     Fct.B.Fct := Fct_Rd_Stat0;   {Wegen Update FG380.203: nicht Fct_Rd_Status;}
     Mil.Rd (read_data, Fct, MilErr);
     if MilErr = No_Err then
      begin
        {PrÅfe zuerst, ob IFK Soll=Ist-Adresse}
        if Lo (Read_Data) <> Fct.B.Adr then
         begin
          Ini_Err_Win;
          Write ('ERROR: Antwort v. falscher IFK-Adr!  '); TextColor(Yellow+128);
          Write('Soll: ', Hex_Byte(Fct.B.Adr),'[H]  Ist: ', Hex_Byte(Lo(Read_Data)),'[H]');
          TextColor(Red); Write ('  [W]eiter [Q]uit');
          repeat
            Ch := NewReadKey;
            if Ch in ['q','Q'] then
             begin
              Ch := ' ';
              Exit;
             end;
          until Ch in ['w','W'];
          Ini_Msg_Win;
          Write('Stop/Single Step mit <SPACE>, Loop mit <CR>, neue Adr mit <F10>   Ende mit [X]');
         end;        {if Soll-Adr<> ist-Adr}


        Fct.B.Fct := Fct_Rd_Status;   {Wegen Update FG380.203: jetzt erst Statuslesen}
        Mil.Rd (Read_Data, Fct, MilErr);
        GotoXY(28, Z_StatHex);  Write(hex_word(Read_Data));
        Hex_Bin_Str (Read_Data, Bit16_Strg);
        GotoXY(22, Z_StatBin);  Write(Bit16_Strg);
      end
     else
      begin
        GotoXY(28, Z_StatHex);  write('    ');
        TextColor (Red);
        GotoXY(22, Z_StatBin);  write('   Read Error!!    ');
        TextColor (Black);
      end;
     Set_Text_Win;
    End; {show_stat_reg; }

 type  Intrl_Mask = (Int, Drdy, Dreq);

  procedure Ifc_Mask_Toggle (Bit: Intrl_Mask);
   label 100;
   var Write_Data : Word;
       Rd_Data    : Word;

   begin
    Fct.B.Adr := Ifk_Test_Nr;
    Fct.B.Fct := Fct_Rd_Status;
    Mil.Rd (Rd_Data, Fct, MilErr);
    if MilErr = No_Err then
     begin
      Fct.B.Adr :=  Ifk_Test_Nr;
      Fct.B.Fct := Fct_Set_IntMask;
      case Bit of
        Int  : begin
                 if (Rd_Data and ifc_irmask_intl) = ifc_irmask_intl then
                    Write_Data := Rd_Data and $7FFF
                 else
                    Write_Data := Rd_Data or ifc_irmask_intl;
                 Mil.Wr (Write_Data, Fct, MilErr);
               end;
        Drdy : begin
                 if (Rd_Data and ifc_irmask_drdy) = ifc_irmask_drdy then
                    Write_Data := Rd_Data and $BFFF
                 else
                    Write_Data := Rd_Data or ifc_irmask_drdy;
                 Mil.Wr (Write_Data, Fct, MilErr);
               end;
        Dreq : begin
                 if (Rd_Data and ifc_irmask_dreq) = ifc_irmask_dreq then
                    Write_Data := Rd_Data and $DFFF
                 else
                    Write_Data := Rd_Data or ifc_irmask_dreq;
                 Mil.Wr (Write_Data, Fct, MilErr);
               end;
      end; {Case}
     end {if MilErr}
    else
     begin {Mil-Lesefehler}

     end;
   end; {Ifc_Mask_Toggle}

 procedure Intr_FTast_Win;
  begin
   Set_Text_Win; TextColor(Brown);
   GotoXY(06,18); Write ('Belegung F-Tasten: ');
   Window(06, 21, 60, 22);
   TextBackground(Green); TextColor(Yellow);
   Writeln ('F1:Intl-Mask  F3:Dreq-Mask  F9 :ClrPwrupBit');
   Write   ('F2:Drdy-Mask  F4:   ---     F10:Ifk-Adr    ');
  end;

  Begin
   Ini_Text_Win;
   Displ_Ifc_Stat;              {Bitbelegung}
   Set_Text_Win;
   Fct.B.Adr := Ifk_Test_Nr;
   Fct.B.Fct := Fct_Rd_Status;

   Transf_cnt := 0;
   Timout_cnt := 0;
   TextColor(Brown);
   GotoXY(02,01); write('Hinweis: Mit dem MIL-Monitor (F 414) im ACTIV-Mode kînnen DReq, DRdy, Intl ');
   GotoXY(02,02); write('ÅberprÅft werden. Dazu am Monitor die Knîpfe INTRL, DRDY, DREQ betÑtigen!  ');
   TextColor(Yellow);               {Setze Schriftfarbe}
   GotoXY(01,03); write('** Interrupt_Maske lÑ·t sich mit F-Tasten toggeln: F1=Intrl, F2=Drdy, F3=Dreq **');
   TextColor(Brown);               {Setze Schriftfarbe}
   GotoXY(22,05); write('----- Lese Status von der IFC-Karte -----');
   GotoXY(25,06); write('Function-Word (Fct + Adr): '); TextColor(Blue);
   Write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]');
   GotoXY(50,08); write('Bedeutung der IFK Status-Bits:');

   GotoXY(06,Z_StatCount);    write('Rd_Stat_Cnt:');
   GotoXY(26,Z_StatCount+1);  write('^  ^');

   GotoXY(06,Z_StatHex);      write('Stat-Data[Hex]');
   GotoXY(06,Z_StatBin);      write('Stat-Data[Bin]');
   GotoXY(22,Z_StatBin+1);    write('MSB             LSB');

   TextColor(Brown);               {Setze Schriftfarbe}
   GotoXY(06,Z_MilBus);  write('MIL-Bus-Leitungen: ');
   TextColor(Blue);               {Setze Schriftfarbe}
   GotoXY(06,Z_MilInt);  write('INTRL (0-aktiv): ');
   GotoXY(06,Z_MilDry);  write('DRDY  (0-aktiv): ');
   GotoXY(06,Z_MilReq);  write('DREQ  (0-aktiv): '); TextColor(Black);
   Intr_FTast_Win;

   Ch := ' ';
   Ini_Msg_Win;
   Write('Stop/Single Step mit <SPACE>, Loop mit <CR>, neue Adr mit <F10>   Ende mit [X]');
   Cursor(False);

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(20, Z_StatCount); Write(Transf_Cnt:12);
      Show_Stat_Reg;
      //Read_Data := PORTW [Port_Stat]; {sonst nur Åber Variable Mil : T_Mil}

      TextColor(Red);
      if BitTst (Read_Data, 0) then              {Intrl}
       begin GotoXY(23,Z_MilInt);  write(' 0 '); end
      else
       begin GotoXY(23,Z_MilInt);  write(' 1 '); end;

      if BitTst (Read_Data, 1) then              {DRdy}
       begin GotoXY(23,Z_MilDry);  write(' 0 '); end
      else
       begin GotoXY(23,Z_MilDry);  write(' 1 '); end;

      if BitTst (Read_Data, 2) then              {DReq}
       begin GotoXY(23,Z_MilReq);  write(' 0 '); end
      else
       begin GotoXY(23,Z_MilReq);  write(' 1 '); end;

      TextColor(Black);
      Mil.Timer2_Wait(1000);
    until KeyPressed or (Ch = ' ');

    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR>, neue Adr mit <F10>   Ende mit [X]');
       repeat until KeyPressed;
      end;

    if KeyPressed then Ch := Readkey;
    if Ch = #0 then
     begin
       Ch := ReadKey;
       case ord (Ch) of
        Taste_F1 : Ifc_Mask_Toggle (Int);
        Taste_F2 : Ifc_Mask_Toggle (Drdy);
        Taste_F3 : Ifc_Mask_Toggle (Dreq);
        Taste_F9 : begin
                    Fct.B.Adr := Ifk_Test_Nr;
                    Fct.B.Fct := Fct_Rd_Status;        {Intrl-Status lesen}
                    Mil.Rd (Read_Data, Fct, MilErr);
                    if MilErr = No_Err then
                     begin
                      Fct.B.Fct  := Fct_Set_IntMask;    {vorbereiten}
                      Write_Data := Read_Data or $0100;   {Powerupbit }
                      Mil.Wr (Write_Data, Fct, MilErr); {Clear Powerup}
                     end; {if MilErr = No_Err}
                   end;
        Taste_F10: begin
                     if Ask_Hex_Break (Adress, Byt) then
                      begin                            {alte Intr. sperren}
                       Fct.B.Adr := Ifk_Test_Nr;
                       Fct.B.Fct := Fct_Set_IntMask;
                       Write_Data:= $FFFF; {Intr-Maske sperren}
                       Mil.Wr (Write_Data, Fct, MilErr);

                       Ifk_Test_Nr := Adress;           {neu}
                       Set_Text_Win; TextColor(Blue);
                       GotoXY(54, 6); Write (Hex_Byte(Ifk_Test_Nr));
                       Fct.B.Adr := Ifk_Test_Nr;
                       Fct.B.Fct := Fct_Set_IntMask;
                       Write_Data:= 0; {Intr-Maske Enable}
                       Mil.Wr (Write_Data, Fct, MilErr);
                      end;
                     Ini_Msg_Win;
                     Write('Stop/Single Step mit <SPACE>, Loop mit <CR>, neue Adr mit <F10>   Ende mit [X]');
                     Ch := ' ';
                     Set_Text_Win;
                   end;
       end; {case}
     end;
   until Ch in ['x','X'];
  99: Cursor(True);
 End; {mil_rd_ifc_stat}


 PROCEDURE Mil_Rd_HS_Ctrl (IFK_Test_Nr: Word);
  Label 99;
  const
   Z_StatCount = 8;
   Z_StatHex   = Z_StatCount +3;
   Z_StatBin   = Z_StatHex   +1;


  VAR read_data,fct_code : WORD;
      MilErr : TMilErr;
      Fct    : TFct;
      transf_cnt : LongInt;
      timout_cnt : LongInt;
      Ch : Char;
      Adress    : Word;

   PROCEDURE show_stat_reg;
    var Bit16_Strg: Str19;
    Begin
     Fct.B.Adr := IFK_Test_Nr;
     Fct.B.Fct := Fct_Rd_HS_Ctrl;
     Mil.Rd (Read_Data, Fct, MilErr);
     if MilErr  <> No_Err then
      begin
       GotoXY(28, Z_StatHex); write ('    ');
       GotoXY(22, Z_StatBin); Textcolor(Red);
       Write('   Read Error!!    ');
      end
     else
      begin
       GotoXY(28, Z_StatHex);  write(hex_word(read_data));
       Hex_Bin_Str (read_data,bit16_strg);
       GotoXY(22, Z_StatBin);  write(bit16_strg);
      end;
     TextColor(Black);
    End;

 procedure Broad_FTast_Win;
  begin
   Set_Text_Win; TextColor(Brown);
   GotoXY(06,18); Write ('Belegung F-Tasten: ');
   Window(06, 21, 60, 22);
   TextBackground(Green); TextColor(Yellow);
   Writeln ('F1: Set   Broadcast   F9 : Reset IFK ');
   Write   ('F2: Reset Broadcast   F10: Ifk-Adr   ');
  end;


  Begin
    Ini_Text_Win;
    Displ_HS_Ctrl;
    Set_Text_Win;
    GotoXY(50,8); TextColor(Brown);
    Write ('Bedeutung Status-Bits: ');

    Fct.B.Adr := IFK_Test_Nr;
    Fct.B.Fct := Fct_Rd_HS_Ctrl;
    transf_cnt := 0;
    timout_cnt := 0;
    TextColor(Brown);
    GotoXY(02,03); write('     Achtung: Diese Funktion nur mit den "neuen" IFK-Karten FG380.20x!');
    GotoXY(15,05); write('----- Lese Ctrl-Register von der IFC-Karte -----');
    GotoXY(25,06); write  ('Function-Word (Fct + Adr): '); TextColor(Blue);
    Write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]');

    GotoXY(06,Z_StatCount  );  write('Rd_Stat_Cnt:');
    GotoXY(26,Z_StatCount+1);  write('^  ^');
    GotoXY(06,Z_StatHex);      write('Stat-Data[Hex]');
    GotoXY(06,Z_StatBin);      write('Stat-Data[Bin]');
    GotoXY(22,Z_StatBin+1);    write('MSB             LSB');

    Broad_FTast_Win;
    TextColor(Black);
    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Set_Text_win;
       Transf_Cnt := Transf_Cnt+ 1;
       GotoXY(20, Z_StatCount); Write(transf_cnt:12);
       Show_Stat_Reg;
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       Set_Text_win;
       Transf_Cnt := Transf_Cnt+ 1;
       GotoXY(20, Z_StatCount); Write(transf_cnt:12);
       Show_Stat_Reg;
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                     Fct.B.Adr := Ifk_Test_Nr;
                     Fct.B.Fct := Fct_En_Broad;
                     Mil.WrFct (Fct, MilErr);
                   end; {F1}
        Taste_F2 : begin
                     Fct.B.Adr := Ifk_Test_Nr;
                     Fct.B.Fct := Fct_Dis_Broad;
                     Mil.WrFct (Fct, MilErr);
                   end; {F2}
        Taste_F3 : begin
                     Fct.B.Adr := Ifk_Test_Nr;
                     Fct.B.Fct := Fct_Reset;
                     Mil.WrFct (Fct, MilErr);
                   end;
        Taste_F10: begin
                     if Ask_Hex_Break (Adress, Byt) then
                      begin
                       Ifk_Test_Nr := Adress;
                       Fct.B.Adr := Ifk_Test_Nr;
                       Fct.B.Fct := Fct_Rd_HS_Ctrl;
                       Set_Text_Win; TextColor(Brown);
                       GotoXY(25,06); write  ('Function-Word (Fct + Adr): '); TextColor(Blue);
                       Write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]');
                       Std_Msg;
                      end;
                   end;
       end; {case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  99:  Cursor(True);
 end;


 PROCEDURE Mil_Rd_HS_Status;
  Label 99;
  var Bit16_Strg: Str19;

  VAR read_data,fct_code : WORD;
      MilErr : TMilErr;
      Fct    : TFct;
      transf_cnt : LongInt;
      timout_cnt : LongInt;
      Ch : Char;

   PROCEDURE show_stat_reg;
    Begin
     Mil.Rd (read_data, Fct, MilErr);
     if MilErr  <> No_Err then
      begin
       GotoXY(28, 14); write ('    ');
       GotoXY(22, 16);
       write('   Read Error!!    ');
      end
     else
      begin
       GotoXY(28, 14);  write(hex_word(read_data));
       Hex_Bin_Str (read_data,bit16_strg);
       GotoXY(22, 16);  write(bit16_strg);
      end;
    End;

  Begin
    Ini_Text_Win;
    Displ_HS_Status;
    Set_Text_Win;
    Fct.B.Adr := IFK_Test_Nr;
    Fct.B.Fct := Fct_Rd_HS_Status;

    transf_cnt := 0;
    timout_cnt := 0;
    TextColor(Yellow);
    GotoXY(02,03); write('  Achtung: Diese Funktion nur mit der "neuen" IFC-Karte (z.B. FG 380.200)!!');
    TextColor(Brown);
    GotoXY(15,06); write('----- Lese Hochstrom-Interlock-Maske von der IFC-Karte -----');
    GotoXY(25,07); write  ('Function-Word (Fct + Adr): '); TextColor(Black);
    Write (hex_word(Fct.W));  TextColor(Brown);  Write(' [H]');
    GotoXY(06,11);  write('Rd_Stat_Cnt:');
    GotoXY(26,12);  write('^  ^');
    GotoXY(06,14);  write('Stat-Data[Hex]');
    GotoXY(06,16);  write('Stat-Data[Bin]');
    GotoXY(22,17);  write('MSB             LSB');
    TextColor(Black);
   Ch := ' ';
   if Ch = ' ' then
     begin
      Ini_Msg_Win;
      Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
      repeat until KeyPressed;
      Ch := ReadKey;
      if  Ch in ['x','X'] then Goto 99;
     end;

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(20, 11); write(transf_cnt:12);
      show_stat_reg;
    until KeyPressed or (Ch = ' ');
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;
   until Ch in ['x','X'];
   99:
 End;

 procedure Mil_Stat_All;
  Label 99;
  const Z_C0 = 14;
        Z_C1 = 15;
        Z_C2 = 16;
        Z_C3 = 17;
        Z_Stat = 19;

  type Tstat = record case Byte of
              1: ( adr     : Byte;
                   c0      : Byte;
                   c1      : Byte;
                   c2      : Byte;
                   Count   : Byte;
                  );
              2: ( adrc0 : Word;
                   c1c2  : Word;
                 );
              end;

  var Bit16_Strg: Str19;
      read_data,fct_code : WORD;
      MilErr : TMilErr;
      Fct    : TFct;
      transf_cnt : LongInt;
      timout_cnt : LongInt;
      Ch         : Char;
      Stat       : Tstat;
      Temp       : Byte;
      X          : Byte;
      Adress     : Word;

   procedure Status_Init;
    begin
      Stat.Adrc0    := 0;
      Stat.C1c2     := 0;
      Stat.Count    := 0;
    end;

   PROCEDURE Show_Stat_Reg (Funct_Code: Byte);
    var Zeile : Byte;
        N     : Byte;
    Begin
     Fct.B.Adr := IFK_Test_Nr;
     case Funct_Code of
      $C0 : begin Fct.B.Fct:= Fct_Rd_Stat0; Zeile := Z_C0; end;
      $C1 : begin Fct.B.Fct:= Fct_Rd_Stat1; Zeile := Z_C1; end;
      $C2 : begin Fct.B.Fct:= Fct_Rd_Stat2; Zeile := Z_C2; end;
     end;

     Read_Data := 0;
     Set_Text_Win;
     GotoXY(03,Z_C0);  write('  ');
     GotoXY(03,Z_C1);  write('  ');
     GotoXY(03,Z_C2);  write('  ');
     TextColor(Yellow);
     GotoXY(03,Zeile); write('->');
     TextColor(Black);
     Mil.Rd (Read_Data, Fct, MilErr);
     if MilErr <> No_Err then
      begin
       timout_cnt := timout_cnt + 1;
       GotoXY(22, Zeile);
       TextColor(Red);
       write('    Read Error!!                    ');
       TextColor(Black);
      end
     else                     {Kein Mil-Error}
      begin                   {Rette Adr und sukzessive alle 3 Status-Werte}
        GotoXY(48, Zeile);  Write(hex_word(Read_Data));
        Hex_Bin_Str (Read_Data,Bit16_Strg);
        GotoXY(22, Zeile);  Write(Bit16_Strg);

        {PrÅfe zuerst, ob IFK Soll=Ist-Adresse: gilt nur fÅr C0 Hex}
        if Funct_Code = $C0 then
         begin
         end;

          if Lo (Read_Data) <> Fct.B.Adr then
           begin
            Ini_Err_Win;
            Write ('ERROR: Antwort v. falscher IFK-Adr!  '); TextColor(Yellow+128);
            Write('Soll: ', Hex_Byte(Fct.B.Adr),'[H]  Ist: ', Hex_Byte(Lo(Read_Data)),'[H]');
            TextColor(Red); Write ('  Weiter <Space> ');
            Ch := NewReadKey;
           end;        {if Soll-Adr<> ist-Adr}


{Darstellung als 32-Bit-Word wie SE, wegen besserem Vergleich mit PR-Gruppe}
        case Funct_Code of
         $C0 : begin
                 Stat.AdrC0 := Read_Data;  {Low-Word mit Adresse !!}
                 Stat.Count := 1;
               end;
         $C1 : begin
                 Stat.C1    := Hi(Read_Data);
                 Stat.Count := Stat.Count + 1;
               end;
         $C2 : begin
                 Stat.C2    := Hi(Read_Data);
                 Stat.Count := Stat.Count + 1;
               end;
        end; {case}
      end;   {if errer}

       if Funct_Code = $C2 then
        begin
          if Stat.Count = 3 then
           begin
            Hex_Bin_Str (Stat.AdrC0,bit16_strg);    {Darstellung als 2 x 16 Bit}
            GotoXY(42, Z_Stat); write(bit16_strg);
            Hex_Bin_Str (Stat.C1c2,bit16_strg);
            GotoXY(22, Z_Stat); write(bit16_strg);
           end
          else
           begin
            GotoXY(22, Z_Stat); ClrEol;
           end;
         end; {if fct_code}
     Mil.Timer2_Wait (8000);  {warte}
    End; {show_stat_reg}

 procedure Displ_Status;
  begin
   Set_Text_win;
   Transf_Cnt := Transf_Cnt+ 1;
   GotoXY(20, 09); write(transf_cnt:12);
   GotoXY(20, 11); write(timout_cnt:12);

   Status_Init;
   show_stat_reg ($C0);
   show_stat_reg ($C1);
   show_stat_reg ($C2);
  end;


 procedure C0_FTast_Win;
  const Z_Tast_Win = 13;

  begin
   Set_Text_Win; TextColor(Brown);
   GotoXY(60,Z_Tast_Win); Write ('Belegung F-Tasten: ');
   Window(60,Z_Tast_Win+3, 79, Z_Tast_Win+4);
   TextBackground(Green); TextColor(Yellow);
   Write ('F10: Ifk-Adr      ');
  end;


  Begin
    Cursor(False);
    Status_Init;
    Ini_Text_Win;
    Fct.B.Adr := IFK_Test_Nr;
    Fct.B.Fct := Fct_Rd_Status;

    transf_cnt := 0;
    timout_cnt := 0;
    TextColor(Brown);
    GotoXY(15,06); write('----- Lese Status C0, C1, C2   von der IFC-Karte -----');
    GotoXY(35,07); write  ('IFC-Adr: '); TextColor(Blue);
    Write (Hex_Byte(Fct.B.Adr)); TextCOlor(Brown); Write(' [H]');

    GotoXY(22,Z_C0-1); write('+STATUS + +ADRESSE+');
    GotoXY(47,Z_C0-1); write('+DATA+');

    GotoXY(06,09);  write('Rd_Stat_Cnt:');
    GotoXY(26,10);  write('^  ^');
    GotoXY(06,11);  write('Rd_Error   :');

    GotoXY(05,Z_C0); write('Status    C0 >');
    GotoXY(05,Z_C1); write('Status    C1 >');
    GotoXY(05,Z_C2); write('Status    C2 >');
    GotoXY(22,Z_C3+0);   write('[MSB           LSB]       [Hex]');
    GotoXY(05,Z_Stat);   write ('32-Bit-Status:');
    GotoXY(05,Z_Stat+2); write ('Bit-Nummer   :');

    GotoXY(05,Z_Stat+1);
    for X := 0 to 3 do     {senkrechte Pfeile}
     begin
       GotoXY(22+X*8+X*2,Z_Stat+1);  Write(chr($18));
     end;
    GotoXY(60, Z_Stat+1);  Write(chr($18));

    {Bit-Zahlen}
    GotoXY(22, Z_Stat+2);  Write(31);
    GotoXY(32, Z_Stat+2);  Write(23);
    GotoXY(42, Z_Stat+2);  Write(15);
    GotoXY(52, Z_Stat+2);  Write(07);
    GotoXY(60, Z_Stat+2);  Write(00);
    C0_FTast_Win;
    TextColor(Black);

    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Displ_Status;
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       Displ_Status;
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F10: begin
                     if Ask_Hex_Break (Adress, Byt) then
                      begin
                       Ifk_Test_Nr := Adress;
                       Fct.B.Adr := Ifk_Test_Nr;
                       Set_Text_Win;
                       TextColor(Brown); GotoXY(35,07); write  ('IFC-Adr: '); TextColor(Blue);
                       Write (Hex_Byte(Fct.B.Adr)); TextColor(Brown); Write(' [H]');
                       Std_Msg;
                      end;
                   end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
 99:  Cursor(True);
 end;  {Mil_Stat_All}


 PROCEDURE Mil_HS_Stat_Cmd;
  Label 99;
  const S_Text = 20;
        S_Data = S_Text + 14;
        Z_Start= 4;

  var Bit16_Strg: Str19;
      read_data,fct_code : WORD;
      MilErr : TMilErr;
      Fct    : TFct;
      Fct_HS : TFct;
      transf_cnt : LongInt;
      timout_cnt : LongInt;
      Ch : Char;

   PROCEDURE show_stat_reg;
    Begin
     Set_Text_Win;
     Mil.Rd (read_data, Fct, MilErr);
     if MilErr  <> No_Err then
      begin
       GotoXY(S_Data+9, Z_Start+1); write ('    ');
       GotoXY(S_Data+2, Z_Start+2); write('   Read Error!!    ');
      end
     else
      begin
       GotoXY(S_Data+9, Z_Start+1);  write(hex_word(read_data));
       Hex_Bin_Str (read_data,bit16_strg);
       GotoXY(S_Data+2, Z_Start+2);  write(bit16_strg);
      end;
    End;

  Begin
    Ini_Text_Win;
    Displ_HS_Status;
    Displ_HS_Cmd;
    set_text_win;
    Fct.B.Adr := IFK_Test_Nr;
    Fct.B.Fct := Fct_Rd_HS_Status;

    transf_cnt := 0;
    timout_cnt := 0;
    TextColor(Brown);
    GotoXY(03,01); write('  Achtung: Diese Funktion nur mit der "neuen" IFC-Karte (z.B. FG 380.200)!!');
    GotoXY(07,02); write('  Lese Status HS-Interlock mit Fct_Code CB[Hex] bzw. Sende Fct-Codes ');

    GotoXY(S_Text,Z_Start);      write('Rd_Stat_Cnt   :');
    GotoXY(S_Text,Z_Start+1);    write('Stat-Data[Hex]:');
    GotoXY(S_Text,Z_Start+2);    write('Stat-Data[Bin]:');
    GotoXY(S_Text+16,Z_Start+3); write('MSB             LSB');
    GotoXY(01,8);  write('HS-Kommandos');
    GotoXY(72,8);  write('HS-Status');
    TextColor(Black);

   Ch := ' ';
   if Ch = ' ' then
     begin
      Ini_Msg_Win;
      Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
      repeat until KeyPressed;
      Ch := ReadKey;
      if  Ch in ['x','X'] then Goto 99;
     end;

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(S_Data+1,Z_Start); write(transf_cnt:12);
      show_stat_reg;
    until KeyPressed or (Ch = ' ');

    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> , [F]ct-Code, Ende mit [X]');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;

    if Ch in ['f','F'] then
      begin
       Set_Text_Win;
       GotoXY(5, 22);
       write ('Welchen Write-Function-Code [01..7F] ??');
       Fct_HS.B.Adr := IFK_Test_Nr;
       Fct_HS.B.Fct := ask_hex_byte;
       Set_Text_Win;
       GotoXY(5, 22); ClrEol;
       Mil.WrFct (Fct_HS, MilErr);
       show_stat_reg;
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> , [F]ct-Code, Ende mit [X]');
       Ch := ' ';
      end;
   until Ch in ['x','X'];
   99:
 End;

 function BitInv (Data: Word; BitNr: Byte): Word;
  var BitMask : Word;
  begin                                               {Bit ist 1}
    BitMask := 1;
    BitMask := BitMask shl BitNr;
    if (Data and BitMask) = BitMask then
      begin
       BitInv := Data and (not BitMask);
      end
    else
      begin                                            {Bit ist 0}
       BitInv := Data or BitMask;
      end;
  end;

 function BitTst (Data: Word; BitNr: Byte): Boolean;
  var BitMask : Word;
  begin
    BitMask := 1;
    BitMask := BitMask shl BitNr;             {Bit 0..15}
    if (Data and BitMask) = BitMask then
      BitTst := True
    else
      BitTst := False;
  end;

 function BitSet (Data: Word; BitNr: Byte): Word;
  var BitMask : Word;
  begin
    BitMask := 1;
    BitMask := BitMask shl BitNr;             {Bit 0..15}
    BitSet:= Data or BitMask
  end;

 function BitClr (Data: Word; BitNr: Byte): Word;
  var BitMask : Word;
  begin
    BitMask := 1;
    BitMask := BitMask shl BitNr;             {Bit 0..15}
    BitMask := not BitMask;                   {Bits invertieren}
    BitClr  := Data and BitMask;
  end;


 procedure T_Mil.Reset;
  begin
//   Portw[Port_Rset] := Reset_Mil;         {Schafft klare VerhÑltnisse!!}
  end;

 function T_Mil.Timeout1; {: Boolean;}
  begin
{   if Portw[Port_Stat] and Stat_Timeout1 = Stat_Timeout1 then
    Timeout1 := True
   else
    Timeout1 := False; }
  end;

 procedure T_Mil.Timer1_Set(Time: Word);  {setzt u. startet den Timer: 10 us Ticks}
  begin
   //Portw[Port_Tmr1] := Time;
  end;

 procedure T_Mil.Timer1_Wait(Time : Word);
  begin
{   Portw[Port_Tmr1] := Time;
  repeat until (Portw[Port_Stat] and Stat_Timeout1) = Stat_Timeout1;  }
  end;

 function T_Mil.Timeout2 : Boolean;
  begin
{   if Portw[Port_Stat] and Stat_Timeout2 = Stat_Timeout2 then
    Timeout2 := True
   else
    Timeout2 := False; }
  end;

 procedure T_Mil.Timer2_Set(Time: LongInt);  {setzt u. startet den Timer2:  }
                                             {time <= $FFFF dann time*10us  }
                                             {time >  $FFFF dann time/100*ms}
  begin
 { if Time <= $FFFF then
   begin
    PORTW[Port_Tmr2_1ms] := 0;               //auf 10 us schalten
    Portw[Port_Tmr2]     := Word(Time);
   end
  else
   begin
    Portw[Port_Tmr2_1ms] := 1;               //auf 1 ms schalten
    Portw[Port_Tmr2]     := Word(Time div 100);
   end;                 }
 end;

 procedure T_Mil.Timer2_Wait(Time: LongInt);
  begin
{   if Time <= $FFFF then
    begin
     PORTW[Port_Tmr2_1ms] := 0;               //auf 10 us schalten
     Portw[Port_Tmr2] := Word(Time);
    end
   else
    begin
     Portw[Port_Tmr2_1ms] := 1;               //auf 1 ms schalten
     Portw[Port_Tmr2]     := Word(Time div 100);
    end;
   repeat until (Portw[Port_Stat] and Stat_Timeout2) = Stat_Timeout2;  }
 end;

 procedure T_Mil.WrFct (Fct: TFct; var MilErr: TMilErr);
//  var Time_Out: Boolean;
  begin
{   Portw[Port_Tmr1]:= TimeWrRdy;
   repeat
    Time_Out:= Mil.Timeout1;
   until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;
   if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
    begin
     Portw[Port_Mode]:= Cmd_Mode;
     Portw[Port_Data] := Fct.W;       // Funktioncode schreiben
     MilErr:= No_Err;
     end
   else
     MilErr:= Fc_To;          }
  end; {mil.wr_fct}

 procedure T_Mil.Rd (var Data: Word; Fct: TFct; var MilErr: TMilErr);
//  var Time_Out: Boolean;
  begin
{   Portw[Port_Tmr1] := TimeWrRdy;                           //Timer 1 starten
   repeat
    Time_Out := Timeout1;
   until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;

   if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
    begin
     Portw[Port_Mode] := Cmd_Mode;
     Portw[Port_Data] := Fct.W;                     //Funktionscode schreiben
     Portw[Port_Tmr1] := TimeValWrd;  //spÑtestens nach 60 us muss valid word da sein
     repeat
      Time_Out:= Timeout1;
     until ((Portw[Port_Stat] and Stat_Val_Wrd) = Stat_Val_Wrd) or Time_Out;
     if ((Portw[Port_Stat] and Stat_Val_Wrd) = Stat_Val_Wrd) then
      begin
       Data   := Portw[Port_Data];                         //Mil-Daten lesen
       MilErr := No_Err;
      end
     else
       MilErr := Rd_To;
    end
   else
      MilErr  := Fc_To; }
 end; {mil.rd}

 procedure T_Mil.Rd_Delay (var Data:Word; Fct:TFct; Wait_Time:Byte; var MilErr: TMilErr);
// var Time_Out: Boolean;
  begin
{   Portw[Port_Tmr1] := TimeWrRdy;                           //Timer 1 starten
   repeat
    Time_Out := Timeout1;
   until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;

   if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
    begin
     Timer1_Wait(Wait_Time);    //Wartezeit fÅr Mil_Expander: Warte n x10 us
     Portw[Port_Mode] := Cmd_Mode;
     Portw[Port_Data] := Fct.W;                     //Funktionscode schreiben
     Portw[Port_Tmr1] := TimeValWrd;  //jetzt mu· spÑtestens nach 60 us valid word da sein
     repeat
      Time_Out:= Timeout1;
     until ((Portw[Port_Stat] and Stat_Val_Wrd) = Stat_Val_Wrd) or Time_Out;
     if ((Portw[Port_Stat] and Stat_Val_Wrd) = Stat_Val_Wrd) then
      begin
       Data   := Portw[Port_Data];                         //Mil-Daten lesen
       MilErr := No_Err;
      end
     else
       MilErr := Rd_To;
    end
   else
      MilErr  := Fc_To;       }
 end; //mil.rd_Delay

procedure T_Mil.Wr (Data: Word; Fct: TFct; var MilErr: TMilErr);
 // var Time_Out: Boolean;
  begin
{   Portw[Port_Tmr1]:= TimeWrRdy;
   repeat
    Time_Out := Timeout1;
   until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;

   if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
    begin
     Portw[Port_Mode] := Dta_Mode;
     Portw[Port_Data] := Data;                     //erst Mil-Daten schreiben
     Portw[Port_Tmr1] := TimeWrRdy;
     repeat
      Time_Out := Timeout1;
     until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;
     if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
      begin
       Portw[Port_Mode] := Cmd_Mode;              //Dann Funktionscode senden
       Portw[Port_Data] := Fct.W;
       MilErr := No_Err;
      end
     else
       MilErr := Wr_To;
    end
  else
    MilErr := Fc_To;}
 end; {mil.wr }

 procedure T_Mil.Wr_Delay (Data: Word; Fct: TFct; Wait_Time:Byte; var MilErr: TMilErr);
//  var Time_Out: Boolean; {Wegen Hardware-Tests: Midestabstand zw. Fct u. Data}
  begin
{   Portw[Port_Tmr1]:= TimeWrRdy;
   repeat
    Time_Out := Timeout1;
   until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;

   if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
    begin
     Portw[Port_Mode] := Dta_Mode;
     Portw[Port_Data] := Data;                     //erst Mil-Daten schreiben
     Portw[Port_Tmr1] := TimeWrRdy;
     repeat
      Time_Out := Timeout1;
     until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;
     if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
      begin
       Timer1_Wait(Wait_Time);                            //Warte n  x10 us
       Portw[Port_Mode] := Cmd_Mode;              //Dann Funktionscode senden
       Portw[Port_Data] := Fct.W;
       MilErr := No_Err;
      end
     else
       MilErr := Wr_To;
    end
  else
    MilErr := Fc_To;   }
 end; {mil.wr_delay}


 procedure T_Mil.WrDta (Data: Word; var MilErr: TMilErr);
 // var Time_Out: Boolean;      {speziell ohne Fct-Code, wegen Hardware-Tests}
  begin
 {  Portw[Port_Tmr1]:= TimeWrRdy;
   repeat
    Time_Out := Timeout1;
   until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;
   if ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) then
    begin
     Portw[Port_Mode] := Dta_Mode;
     Portw[Port_Data] := Data;                     //erst Mil-Daten schreiben
     Portw[Port_Tmr1] := TimeWrRdy;
     repeat
      Time_Out := Timeout1;
     until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;
    end
   else
    MilErr := Wr_To; }
 end; {T.WrDta}

procedure T_Mil.Ifc_Online; {(IfcAdr: Byte; var RetAdr: Byte; var OnlineErr: TOnlineErr) }
{ TOnlineErr= (NoErr, WrTo, RdTo, AdrErr, ModAdrErr)}
{ TMilErr   = (No_Err, Fc_To, Rd_To, Wr_To, Io_Adr)}
{  var RdErr   : TMilErr;
      RdData  : Word;
      Funct   : TFct;
      Time_Out: Boolean;     }
 begin

 if (IfcAdr = 7) then begin
    RetAdr := 7;
    OnlineErr := NoErr;
 end;


 {   RetAdr := 0;

 Portw[Port_Tmr1]:= TimeWrRdy;   //Warten, bis laufender Transfer abgeschlossen
 repeat
  Time_Out := Timeout1;
 until ((Portw[Port_Stat] and Stat_Wrt_Rdy) = Stat_Wrt_Rdy) or Time_Out;

   T_Mil.Reset;                               //schafft klare VerhÑltnisse!!
   Funct.B.Adr  := IfcAdr;
   //Wegen Update FG380.203 kommt nur bei Fct-Code C0[H] Ifk-Adr zuÅck!!
   Funct.B.Fct  :=  Fct_Rd_Stat0;               //C0 Hex
   T_Mil.Rd (RdData, Funct, RdErr);             //TimeoutprÅfung in T.Mil.Rd
   if RdErr = No_Err  then
    begin
      RetAdr      := Lo(RdData);
      if RetAdr = IfcAdr then
       begin
        OnlineErr := NoErr;                      //Adresse im Datenwort stimmt
       end
      else
       begin               //Es kamm zwar eine Antwort, aber von falscher Adr
        OnlineErr  := AdrErr;
       end;
    end  //if RdErr=No_Err
   else
    begin
      if RdErr = Wr_To  then  OnlineErr := WrTo;
      if RdErr = Rd_To  then  OnlineErr := RdTo;
    end;    }
 end;

               {*********** Routinen fÅr APL-IO-BUS ***************}
procedure T_Mil.Wr_Iobus (Data: Word; Adr: TIoAdr; var MilErr: TMilErr);
{ var IoAdr : Word;
     Fct   : TFct;
     IobErr: TMilErr;  }
 begin
   {MilErr := No_Err;
   if Adr.IoSub > 7 then
    begin
     MilErr := Io_Adr;
     Exit;                                 //Abort
    end;
   Fct.B.Adr := Adr.IfcAdr;                  //Adr IFK 380.122
   Fct.B.Fct := Fct_Wr_Iob_Adr;              //Funktionscode IO-Adr setzen
   IoAdr     := Adr.IoCard + Adr.IoSub;      //Bit 7..3  + Bit 2..0
   T_Mil.Wr (IoAdr, Fct, IobErr);            //Zuerst Io-Adr setzten
   if IobErr <> No_Err then
    begin
     MilErr := IobErr;
     Exit;
    end;

   Fct.B.Fct := Fct_Wr_Iob_Dta;              //Funktionscode IO-Daten setzen
   T_Mil.Wr (Data, Fct, IobErr);             //Zuerst Io-Adr setzten

   if IobErr <> No_Err then MilErr := IobErr;  }
 end; //T_Mil.Wr_Iobus

procedure T_Mil.Rd_Iobus (var Data: Word; Adr: TIoAdr; var MilErr: TMilErr);
 label 1;
 {var IoAdr: Word;
     Fct  : TFct;
     IobErr: TMilErr; }
 begin
 {  MilErr := No_Err;
   if Adr.IoSub > 7 then
    begin
     MilErr := Io_Adr;
     Goto 1;                                 //Abort
    end;
   Fct.B.Adr := Adr.IfcAdr;                  //Adr IFK 380.122
   Fct.B.Fct := Fct_Wr_Iob_Adr;              //Funktionscode IO-Adr setzen
   IoAdr     := Adr.IoCard + Adr.IoSub;      //Bit 7..3 + Bit 2..0
   T_Mil.Wr (IoAdr, Fct, IobErr);            //Zuerst Io-Adr setzten
   if IobErr <> No_Err then
    begin
     MilErr := IobErr;
     Goto 1;
    end;

   Fct.B.Fct := Fct_Rd_Iob_Dta;              //Funktionscode IO-Daten lesen
   T_Mil.Rd (Data, Fct, IobErr);
   if IobErr <> No_Err then MilErr := IobErr;
1:                     }
 end; {T_Mil.Rd_Iobus}


            {*********** Routinen fÅr ModulBus ***************}
        {16-bit I/O-Adresse [Bit13..8 = Modul-Adr, Bit7..0 = Sub-Adr]}
 procedure T_Mil.Mod_Online (Ifc_Adr: Byte; Mod_Adr: Byte; var Mod_RetAdr: Byte; var OnlineErr: TOnlineErr);
 { TOnlineErr= (NoErr, WrTo, RdTo, AdrErr, ModAdrErr)}
{  var
   MilErr      : TMilErr;
   Fct         : TFct;
   Ifc_RetAdr  : Byte;
   Rd_Data     : Word;
   ModBus_Adr  : Word;    //Diese Adr wird zur IFK geschrieben }

  begin
{    OnlineErr  := NoErr;
    T_Mil.Ifc_Online (Ifc_Adr, Ifc_RetAdr, OnlineErr); //Ist IFK vorhanden?
    if OnlineErr <> NoErr then Exit;   //Abort: richtige IFK fehlt

    ModBus_Adr := (Mod_Adr shl 8) + ModSub_Adr_ModAdr; //HI: Modul-Adr,Lo: Subadr
    Fct.B.Adr  := Ifc_Adr;
    Fct.B.Fct  := Fct_Wr_Iob_Adr;     //Setze Adr fÅr APL-IO-Bus bzw. Modulbus
    Mil.Wr (ModBus_Adr, Fct, MilErr); //I/O-Adr zur IFK

    Fct.B.Fct  :=  Fct_Rd_Iob_Dta;    //Lesen Daten von Modul-Bus
    Mil.Rd (Rd_Data, Fct, MilErr);    //Antwort: Hibyte=Skalierng, Lobyte=ModAdr
    if MilErr = No_Err then
     begin
      Mod_RetAdr := Lo (Rd_Data);
      if Mod_RetAdr <> Mod_Adr then
       begin
        OnlineErr := ModAdrErr;
        Exit;
       end;
     end
    else
     begin
       OnlineErr := RdTo;
     end;                             }
  end; {IO_Mod_Online}


procedure T_Mil.Wr_ModBus (Data: Word; Adr: TModAdr; var MilErr: TMilErr);
{ var IoAdr : Word;
     Fct   : TFct;      }
 begin
 {  MilErr := No_Err;
   if not ((Adr.AdrMode = AdrNew) or (Adr.AdrMode = AdrOld)) then
    begin
     MilErr := Io_AdrMode;
     Exit;
    end;

   if Adr.AdrMode = AdrNew then            //Modulbus-Adr neu schreiben
    begin
      if Adr.AdrCard > ModAdr_Max then             //Moduladr auf 5-Bit beschrÑnkt
       begin
        MilErr := Io_Adr;
        Exit;                                 //Abort
       end;

      Fct.B.Adr := Adr.AdrIfc;             //Adr IFK 380.102 oder 201
      Fct.B.Fct := Fct_Wr_Iob_Adr;         //Funktionscode IO-Adr setzen
      IoAdr     := Adr.AdrCard;            //Moduladr ins Hibyte
      IoAdr     := IoAdr shl 8;
      IoAdr     := IoAdr + Adr.AdrSub ;    //Subadr ins Lobyte
      T_Mil.Wr (IoAdr, Fct, MilErr);       //Zuerst Io-Adr setzten
      if MilErr <> No_Err then  Exit;
    end;

   Fct.B.Fct := Fct_Wr_Iob_Dta;            //Funktionscode IO-Daten setzen
   T_Mil.Wr (Data, Fct, MilErr);      }    //Zuerst Io-Adr setzten
 end; //T_Mil.Wr_ModBus

{xxx}
procedure T_Mil.Rd_ModBus (var Modbus_Data: Word; Adr: TModAdr; var MilErr: TMilErr);
 var IoAdr: Word;
     Fct  : TFct;
 begin
   MilErr := No_Err;
   if not ((Adr.AdrMode = AdrNew) or (Adr.AdrMode = AdrOld)) then
    begin
     MilErr := Io_AdrMode;
     Exit;
    end;

   if Adr.AdrMode = AdrNew then            {Modulbus-Adr neu schreiben}
    begin
      if Adr.AdrCard > ModAdr_Max then    {Moduladr auf 5-Bit beschrÑnkt}
       begin
        MilErr := Io_Adr;
        Exit;                               {Abort}
       end;

      Fct.B.Adr := Adr.AdrIfc;             {Adr IFK 380.102 oder 201}
      Fct.B.Fct := Fct_Wr_Iob_Adr;         {Funktionscode IO-Adr setzen}
      IoAdr     := Adr.AdrCard;            {Moduladr ins Hibyte}
      IoAdr     := IoAdr shl 8;
      IoAdr     := IoAdr + Adr.AdrSub ;    {Subadr ins Lobyte}
      T_Mil.Wr (IoAdr, Fct, MilErr);       {Zuerst Io-Adr setzten}
      if MilErr <> No_Err then  Exit;
    end;

   Fct.B.Fct := Fct_Rd_Iob_Dta;             {Funktionscode IO-Daten lesen}
   T_Mil.Rd (Modbus_Data, Fct, MilErr);
 end; {T_Mil.Rd_ModBus}


 procedure hex_bin (data:Word);       { Resultat im globalen bit16_str }
 var i,divisor,offset : Word;
 begin
  bit16_str := '0000 0000 0000 0000';
  divisor   := $8000;
  offset    := 0;
  for i := 1 TO 16 do
   begin
    if (data and divisor = divisor) then
     begin
       if i >  4 then offset:= 1;
       if i >  8 then offset:= 2;
       if i > 12 then offset:= 3;
       bit16_str[i+offset] := '1';
     end;
    divisor := divisor shr 1;
   end;
 end; {hex_bin}

  function check_ifc_adr (ifc_adress: Byte): boolean;
  var Ch : char;
  begin
    Check_ifc_adr := true;
    if  not (ifc_adress in [1..255]) then
     begin
      Check_ifc_adr := false;
      Ini_err_win;
      GotoXY(1, 1);
      Write ('ABORT: IFC-Karten-Nr. undefiniert bzw. [00] !!  Press any key to go on! '); ch := readkey;
      Mil_Ask_Ifc;
     end;
  end; {check_ifc_adr}


function Rd_Real_Sw (MaxWert: Real): Word;    {User-Eingabe Real Sollwert}
var Status    : Boolean;                      {15 Bit ADC mit Vorzeichenbit}
    Real_Zahl : Real;
    Sw: Word;
begin                           {RÅckgabe-Wert:   16-bit Hex }
  Status := False;

  repeat
   Ini_Msg_Win;
   Write('Bitte Floating-Point Zahl eingeben [Format +/- 00.000]: ');
   {$I-}                    {Fehleingabe zulassen: Compiler-Check ausschalten}
   Readln(Real_Zahl);
   {$I+}
   if (IoResult <> 0){ or (Real_Zahl < 0)} then
    begin                                           {Fehler selber abfangen!}
     Ini_Err_Win;
     Write('ERROR: Format falsch!!  Weiter mit <CR>');
     ReadKey;
    end
   else
    begin
      if abs (Real_Zahl) > MaxWert then    {Absolutwert, weil +/- 10 Volt}
       begin
        Ini_Err_Win;
        Write('ERROR: +/- Sollwert grî·er als ',MaxWert,' !   Weiter mit <CR>');
        ReadKey;
       end
      else
       Status := True;
    end;
  until Status = True;
  if Real_Zahl > 9.999694825 then Real_Zahl := 9.999694825;

  if Real_Zahl > 0 then
    begin      {positiv}
     Real_Zahl  := (Real_Zahl/305.1757813) * 1000000;
     Rd_Real_Sw := Round(Real_Zahl);         {Real-Zahl in Integer umwandeln}
    end
   else
    begin      {negativ}
     Real_Zahl  := (Real_Zahl/305.1757813) * 1000000;
     Rd_Real_Sw := Round(Real_Zahl);         {Real-Zahl in Integer umwandeln}
    end;
end; {Get_Real_Sw}

procedure Write_Real_10V_Bipol;  {Die Auflîsungsbits als Parameter}
var Real_Zahl : Real;
    Int_Zahl  : Integer;
    Vorzeichen : Char;
begin                        {Bit 15 ist Vorzeichen}
  if (Data and $8000) = 0 then
   begin     {positiv}
     Real_Zahl := Data * 305.1757813/1000000;
     Vorzeichen:= '+';
   end
  else
   begin     {negativ}
     Data := (not Data) + 1;               {Zweier Komplement}
     Real_Zahl := Data * 305.1757813/1000000;
     Vorzeichen:= '-';
   end;
  Write (Vorzeichen, Real_Zahl:9:6);
end;

procedure Write_Real_10V_Unipol;  {Die Auflîsungsbits als Parameter}
var Real_Zahl : Real;
    Int_Zahl  : Integer;
    Vorzeichen : Char;
begin                            {Bit 15 ist kein Vorzeichen: 16 Datenbits!}
  Real_Zahl := Data * 305.1757813/2000000;
  Write (Real_Zahl:9:6);
end;


function Rd_Real_10: Word;    {User-Eingabe Real 0..10.0000}
var Status    : Boolean;
    Real_Zahl : Real;
begin                           {RÅckgabe-Wert:   16-bit Hex }
  Status := FALSE;
  repeat
   Ini_Msg_Win;
   Write('Bitte Flie·komma-Zahl eingeben [Format 00.0000]: ');
   {$I-}                    {Fehleingabe zulassen: Compiler-Check ausschalten}
   Readln(Real_Zahl);
   {$I+}
   if (IoResult <> 0) or (Real_Zahl > 10.0) or (Real_Zahl < 0) then
    begin                                           {Fehler selber abfangen!}
     Ini_Err_Win;
     Write('ERROR: Format falsch oder Zahl nicht 0..10.0 !! Weiter mit <CR>');
     ReadKey;
    end
   else
     Status := True;
  until Status = True;
  Real_Zahl := Real_Zahl*3276.7;      {16-Bit ADC: +/- 10.00 Volt}
  Rd_Real_10 := Round (Real_Zahl);    {Real-Zahl in Integer umwandeln}
end; {Get_Real_10}


procedure Write_Real_10;   {Hexzahl als Real 4-stellig ausgeben}
var Real_Zahl : Real;                      {Cursor vorher plazieren}
begin
  Real_Zahl := Data/3276.7;             {ADC fÅr +/- 10 Volt}
  Write (Real_Zahl:7:4);
end;


procedure Write_Real_Sw (Param: TRealSw);  {mit Vorzeichen Ausgabe}
var Real_Zahl : Real;                      {Cursor vorher plazieren}
begin
   Real_Zahl := (Param.Maxw * Param.Sw)/$7FFF;
   Write (Real_Zahl:8:3);
end;

function Conv_Real_Hex (R_Zahl: Real): Word; {Voltangabe +/10V in Hex convertieren}
var Status    : Boolean;                      {15 Bit ADC mit Vorzeichenbit}
    Real_Zahl : Real;
    sw: Word;
begin                           {RÅckgabe-Wert:   16-bit Hex }
  if R_Zahl >  9.999694825 then R_Zahl := 9.999694825;
  if R_Zahl < -10.0 then R_Zahl :=  10.0;

  if R_Zahl > 0 then
    begin      {positiv}
     R_Zahl:= (R_Zahl/305.1757813) * 1000000;
     Conv_Real_Hex := Round(R_Zahl);         {Real-Zahl in Integer umwandeln}
    end
   else
    begin      {negativ}
     R_Zahl:= (R_Zahl/305.1757813) * 1000000;
     Conv_Real_Hex := Round(R_Zahl);     {Real-Zahl in Integer umwandeln}
    end;
end; {Conv_Real_Hex}



procedure Hex_Bin_Str;
var I,Divisor,Offset : Word;
 begin
  Bit16_String:= '0000 0000 0000 0000';
  Divisor   := $8000;
  Offset    := 0;
  for I := 1 to 16 do
   begin
    if (Data and Divisor = Divisor) then
     begin
       if I >  4 then Offset:= 1;
       if I >  8 then Offset:= 2;
       if I > 12 then Offset:= 3;
       Bit16_String[I+Offset] := '1';
     end;
    Divisor := Divisor shr 1;
   end;
 end; {hex_bin_str}

procedure Hex_Bin8_Str(Data          : Byte;              {Ersatz f. Hex_Bin}
                       var Bit8_String: Str10
                      );
var I,Divisor,Offset : Word;
 begin
  Bit8_String:= '0000 0000';
  Divisor   := $80;
  Offset    := 0;
  for I := 1 to 8 do
   begin
    if (Data and Divisor = Divisor) then
     begin
       if I >  4 then Offset:= 1;
       if I >  8 then Offset:= 2;
       if I > 12 then Offset:= 3;
       Bit8_String[I+Offset] := '1';
     end;
    Divisor := Divisor shr 1;
   end;
 end; {hex_bin_str}



 procedure Mil_Detect_Ifc_Compare;
  label 99;
  CONST start_zeile =  3;
        start_spalte = 5;
        zeile_max    = 18;
        spalte_offset= 20;
        spalte_akt   = 45;
        Online_Max   = 80;
        Disp_Index_Max = 60;     {Maximal darstellbare IFC}

 type
    TOnline_Stat = (On, Off);
    TIntr_Stat   = record
                    Stat_Act    : TOnline_Stat;
                    Stat_Old    : TOnline_Stat;
                    Stat_Err_Cnt: LongInt;
                   end;

    TIfb_Ary = record
                 Dis_Index   : Word;           {relative Position auf Display}
                 Err_Flag    : Boolean;                         {Summenfehler}
                 Adr_Soll    : Byte;
                 Adr_Ist     : Byte;
                 Adr_Diff_Cnt: LongInt;                            {Soll<>Ist}
                 Adr_Ist_Diff: LongInt;     {Istwert diff zum vorherigen Wert}
                 Stat_Act    : TOnline_Stat;
                 Stat_Old    : TOnline_Stat;
                 Stat_Err_Cnt: LongInt;               {Anzahl Status énderung}
               end;

  var
      Ifb_Adr    : Word;
      Ifb_Min    : Byte;
      Ifb_Max    : Byte;
      Ifb_Neu    : Byte;
      Ifb_Alt    : Byte;
      Ifb_Ary    : array [0..255] OF TIfb_Ary;

      INTRL      : TIntr_Stat;
      DRDY       : TIntr_Stat;
      DREQ       : TIntr_Stat;

      Zeile,Spalte: BYTE;
      Hex_Str    : STRING[10];
      I,N,L      : WORD;
      RetAdr     : Byte;
      Test_Cnt   : LongInt;
      Disp_Index_Actuell : Byte;
      Disp_Sel_Adr: Byte;        {Selektive Anzeige fÅr eine IFC-Adr}
      Ch         : Char;
      Disp_Intr_Mode : Boolean;
      Stat_Data  : Word;

   type TLife = (Norm, Blinc);
   procedure Life_Sign (Mode: TLife);
    const S_Aktiv   = 12;
          Z_Aktiv   = 1;
          Life_Time1 = 5000;
          Life_Time2 = 1500;
    var Life_Wait : LongInt;
    begin
      Cursor (False);
      Set_Text_Win;
      if Mode = Norm then
       begin
        Life_Wait := Life_Time2;
        Set_Text_Win;
        TextColor(Yellow);
        GotoXY(S_Aktiv, Z_Aktiv);  Write (chr($7C)); Mil.Timer2_Wait (Life_Wait);
        GotoXY(S_Aktiv, Z_Aktiv);  Write ('/');      Mil.Timer2_Wait (Life_Wait);
        GotoXY(S_Aktiv, Z_Aktiv);  Write (chr($2D)); Mil.Timer2_Wait (Life_Wait);
        GotoXY(S_Aktiv, Z_Aktiv);  Write ('\');      Mil.Timer2_Wait (Life_Wait);
       end
      else
       begin
         TextColor(Red+128);
         GotoXY(S_Aktiv, Z_Aktiv); Write (chr($B2));
       end;
      TextColor(Black);
      Cursor(True);
      Set_Text_Win;
     end; {Life_Sign}


  procedure Ary_Init;
    var I : Byte;
    begin
      Test_Cnt := 0;
      Ifb_Min  := 0;
      Ifb_Max  := 0;
      Ifb_Neu  := 0;
      Ifb_Alt  := 0;

      for I := 0 to 255 do
       begin
         Ifb_Ary[I].Err_Flag    := False;
         Ifb_Ary[I].Dis_Index   := 0;
         Ifb_Ary[I].Adr_Ist     := $FF;
         Ifb_Ary[I].Adr_Soll    := $FF;
         Ifb_Ary[I].Adr_Diff_Cnt:= 0;
         Ifb_Ary[I].Adr_Ist_Diff:= 0;
         Ifb_Ary[I].Stat_Act    := Off;
         Ifb_Ary[I].Stat_Old    := Off;
         Ifb_Ary[I].Stat_Err_Cnt:= 0;
       end;

      {Als Init-Status mu· der aktuelle Status genommen werden, da ja
       gerade die énderungen erfa·t werden sollen!!}
//    Stat_Data := PORTW [Port_Stat]; {sonst nur Åber Variable Mil : T_Mil}
      if BitTst (Stat_Data, 0) then              {Intrl aktiv}
        begin
          INTRL.Stat_Act := On;
          INTRL.Stat_Old := On;
          INTRL.Stat_Err_Cnt := 0;
        end
      else
        begin
          INTRL.Stat_Act := Off;
          INTRL.Stat_Old := Off;
          INTRL.Stat_Err_Cnt := 0;
        end;

      if BitTst (Stat_Data, 1) then              {Drdy aktiv}
        begin
          DRDY.Stat_Act := On;
          DRDY.Stat_Old := On;
          DRDY.Stat_Err_Cnt := 0;
        end
      else
        begin
          DRDY.Stat_Act := Off;
          DRDY.Stat_Old := Off;
          DRDY.Stat_Err_Cnt := 0;
        end;

      if BitTst (Stat_Data, 2) then              {Dreq aktiv}
        begin
          DREQ.Stat_Act := On;
          DREQ.Stat_Old := On;
          DREQ.Stat_Err_Cnt := 0;
        end
      else
        begin
          DREQ.Stat_Act := Off;
          DREQ.Stat_Old := Off;
          DREQ.Stat_Err_Cnt := 0;
          end;
  end;

  procedure Update_Ifb_Online;
   var Ifb : Byte;
       OnlineErr : TOnlineErr;
   begin
     for Ifb := 0 TO 255 DO
       begin
         mil.ifc_online (Ifb, RetAdr, OnlineErr); {TOnlineErr= (NoErr, WrTo, RdTo, AdrErr)}
         If (OnlineErr = NoErr) or (OnlineErr = AdrErr) then   {Es meldet sich eine Karte online}
           begin
             Ifb_Neu := Ifb_Neu + 1;
             Ifb_Ary[Ifb].Stat_Act := On;               {Status Online}
             Ifb_Ary[Ifb].Adr_Soll := Ifb;              {Soll-Adr festhalten}
             {Ist die RetAdr anders als die bisherige Return-Adr?}
             {Sinnvoll nur, wenn schon Daten fÅr diese Abfrage vorhanden}
             {Displ_Index gibt Position der Anzeige an; bei 0 ist Adr noch nicht auf Display}
             if Ifb_Ary[Ifb].Dis_Index <> 0 then   {Displ-Anzeige fÅr diese Adr vorhanden!}
              begin
                if Ifb_Ary[Ifb].Adr_Ist <> RetAdr then
                 begin
                   Ifb_Ary[Ifb].Adr_Ist_Diff:= Ifb_Ary[Ifb].Adr_Ist_Diff + 1;  {Ist-Adr hat sich geÑndert}
                   Ifb_Ary[Ifb].Err_Flag := True;
                 end;
                    {Ifc war schon auf Display; ist jetzt wieder Online -> Error}
                if Ifb_Ary[Ifb].Stat_Old = Off then
                   Ifb_Ary[Ifb].Stat_Err_Cnt := Ifb_Ary[Ifb].Stat_Err_Cnt + 1;
              end
             else
              begin  {Diese IFC-Adr noch nicht auf dem Display}
                Disp_Index_Actuell     := Disp_Index_Actuell + 1;
                Ifb_Ary[Ifb].Dis_Index := Disp_Index_Actuell; {Ifc-Adr an diese Displ.Pos}
              end;

             Ifb_Ary[Ifb].Adr_Ist  := RetAdr;    {neue Ist-Adr speichern}
             if Ifb <> RetAdr then               {Soll <> Ist Adr}
               begin
                 Ifb_Ary[Ifb].Adr_Diff_Cnt := Ifb_Ary[Ifb].Adr_Diff_Cnt + 1;
                 Ifb_Ary[Ifb].Err_Flag := True;
               end;
             Ifb_Ary[Ifb].Stat_Old := On;                    {Status Online}
           end  {if online NoErr}
         else
           begin  {Online_err: Diese karte meldet sich nicht!}
             if Ifb_Ary[Ifb].Stat_Old = On then
               begin
                 Ifb_Ary[Ifb].Err_Flag := True;                {Status Change}
                 Ifb_Ary[Ifb].Stat_Err_Cnt:= Ifb_Ary[Ifb].Stat_Err_Cnt + 1;
               end;
             Ifb_Ary[Ifb].Stat_Act := Off;                   {Status Offline}
             Ifb_Ary[Ifb].Stat_Old := Off;                   {Status Offline}
           end;  {if online Err}

        { Erfasse auch die MIL-Interruptleitungen : mîglichst oft scannen!!}
//      Stat_Data := PORTW [Port_Stat]; {sonst nur Åber Variable Mil : T_Mil}
        if BitTst (Stat_Data, 0) then              {Intrl aktiv}
         begin
           INTRL.Stat_Act := On;
           if INTRL.Stat_Old = Off then             {Status hat sich geÑndert}
            begin
             INTRL.Stat_Err_Cnt := INTRL.Stat_Err_Cnt + 1;
             INTRL.Stat_Old := On;
            end;
         end
        else
         begin                                      {Intrl nicht da}
           INTRL.Stat_Act := Off;
           if INTRL.Stat_Old = On then              {Status hat sich geÑndert}
            begin
             INTRL.Stat_Err_Cnt := INTRL.Stat_Err_Cnt + 1;
             INTRL.Stat_Old := Off;
            end;
         end;

        if BitTst (Stat_Data, 1) then              {Drdy aktiv}
         begin
           DRDY.Stat_Act := On;
           if DRDY.Stat_Old = Off then             {Status hat sich geÑndert}
            begin
             DRDY.Stat_Err_Cnt := DRDY.Stat_Err_Cnt + 1;
             DRDY.Stat_Old := On;
            end;
         end
        else
         begin                                      {Drdy nicht da}
           DRDY.Stat_Act := Off;
           if DRDY.Stat_Old = On then              {Status hat sich geÑndert}
            begin
             DRDY.Stat_Err_Cnt := DRDY.Stat_Err_Cnt + 1;
             DRDY.Stat_Old := Off;
            end;
         end;

        if BitTst (Stat_Data, 2) then              {Dreq aktiv}
         begin
           DREQ.Stat_Act := On;
           if DREQ.Stat_Old = Off then             {Status hat sich geÑndert}
            begin
             DREQ.Stat_Err_Cnt := DREQ.Stat_Err_Cnt + 1;
             DREQ.Stat_Old := On;
            end;
         end
        else
         begin                                      {Dreq nicht da}
           DREQ.Stat_Act := Off;
           if DREQ.Stat_Old = On then              {Status hat sich geÑndert}
            begin
             DREQ.Stat_Err_Cnt := DREQ.Stat_Err_Cnt + 1;
             DREQ.Stat_Old := Off;
            end;
         end;
       end; {FOR}
   end; {Update_Ifb_Online; }

  procedure Displ_Ifb_Ary;
   var I,N : Byte;
       DZeile,DSpalte: Byte;
   begin
    Cursor (False);
    Set_Text_Win;
    TextColor(black);
    for I := 0 to 255 do
     begin
       if Ifb_Ary[I].Dis_Index > 0 then  {Index > 0: anzeigen}
        begin
          if (Ifb_Ary[I].Dis_Index mod Zeile_Max) = 0 then
            DZeile := Start_Zeile + 1
          else
            DZeile  := (Ifb_Ary[I].Dis_Index mod Zeile_Max) + Start_Zeile + 1;

          DSpalte := Start_Spalte + (Ifb_Ary[I].Dis_Index DIV Zeile_Max) * Spalte_Offset;
          if DSpalte > 65 then DSpalte := 65;   {Bildschirm Darstellung begrenzen}

          if Ifb_Ary[I].Err_Flag then  TextColor (Blink);
          if Ifb_Ary[I].Adr_Ist <> Ifb_Ary[I].Adr_Soll then
           begin
             TextColor(Red);
             GotoXY (DSpalte, DZeile);
             write(hex_Byte(Ifb_Ary[I].Adr_Soll));
           end;

          if Ifb_Ary[I].Stat_Act = Off then
           begin
             TextColor(Red);
           end;

          GotoXY (DSpalte+9, DZeile); write(hex_Byte(Ifb_Ary[I].Adr_Ist));  {Istadr}
          TextColor(black);                           {Setze Schriftfarbe}
        end;
     end; {for I}

    if Disp_Intr_Mode then
     begin
      GotoXY(01,22); ClrEol;
      TextColor(Black); GotoXY(01,22); write ('['); TextColor(Magenta); write('Intrl: ');
      TextColor(Black);
      if INTRL.Stat_Act = On then                    {Intrl}
       begin GotoXY(01+7,22);  write('On '); end
      else
       begin GotoXY(01+7,22);  write('Off'); end;

      TextColor(Magenta);   GotoXY(12,22); Write('ErrCnt: ');
      TextColor(Black); Write (INTRL.Stat_Err_Cnt:6);
      TextColor(Black); Write (']');

      GotoXY(28,22); write ('['); TextColor(Magenta); write('Drdy: ');
       TextColor(Black);
      if DRDY.Stat_Act = On then                    {Dreq}
       begin GotoXY(28+6,22);  write('On '); end
      else
       begin GotoXY(28+6,22);  write('Off'); end;
      TextColor(Magenta);   GotoXY(28+10,22); Write('ErrCnt: ');
      TextColor(Black);  Write (Drdy.Stat_Err_Cnt:6); Write (']');

      GotoXY(54,22); write ('['); TextColor(Magenta);   write('Dreq: ');
      TextColor(Black);
      if DREQ.Stat_Act = On then                    {Dreq}
       begin GotoXY(54+6,22);  write('On '); end
      else
       begin GotoXY(54+6,22);  write('Off'); end;
      TextColor(Magenta);  GotoXY(54+10,22); Write('ErrCnt: ');
      TextColor(Black);  Write (Dreq.Stat_Err_Cnt:6);   Write (']');
     end
    else
     begin
      {FÅr eine ausgewÑhlte IFC-Adr alle Info's anzeigen}
      TextColor(Magenta);  GotoXY (01, 22);
      write ('IFC: ');    TextColor(Black); write(hex_Byte(Disp_Sel_Adr)); TextColor(Magenta);
      write ('  SAdr:');  TextColor(Black); write(hex_Byte(Ifb_Ary[Disp_Sel_Adr].Adr_Soll)); TextColor(Magenta);
      write (' IAdr:');   TextColor(Black); write(hex_Byte(Ifb_Ary[Disp_Sel_Adr].Adr_Ist));  TextColor(Magenta);
      write ('  EBit:');
      TextColor(Black);   if Ifb_Ary[Disp_Sel_Adr].Err_Flag then write('1') else write('0');  TextColor(Magenta);
      write ('  Line:');  TextColor(Black); if Ifb_Ary[Disp_Sel_Adr].Stat_Act = On then write('On ') else write('Off');
      TextColor(Magenta);
      write ('  S-I?: '); TextColor(Black); write(Ifb_Ary[Disp_Sel_Adr].Adr_Diff_Cnt:4); TextColor(Magenta);
      write ('  IAd?: '); TextColor(Black); write(Ifb_Ary[Disp_Sel_Adr].Adr_Ist_Diff:4); TextColor(Magenta);
      write ('  Sta?: '); TextColor(Black); write(Ifb_Ary[Disp_Sel_Adr].Stat_Err_Cnt:4); TextColor(Magenta);
      ClrEol;
    end;
   end; {Displ_Ifb_Ary}

 begin             {Begin ifb_detect and compare}
    Cursor (False);
    ini_text_win;
    Disp_Sel_Adr := 0;
    Disp_Intr_Mode := False;

    Disp_Index_Actuell := 0;
    Ary_Init;
    GotoXY (10, 02);
    writeln ('Start der Abfrage durch Eingabe gemÑ· unterster Zeile!!');
    TextColor(Magenta);
    GotoXY(1,1);             Write ('TestCount: ');
    GotoXY(20,1);            Write('IFC-Karten am MIL-Bus ->');
    GotoXY(spalte_akt+00,1); Write('Neu:');
    GotoXY(spalte_akt+09,1); Write('Alt:');
    GotoXY(spalte_akt+18,1); Write('Min:');
    GotoXY(spalte_akt+27,1); Write('Max:');

    TextColor(Blue);
    GotoXY(2,2);  write(' Soll--ADR--Ist      Soll--ADR--Ist      Soll--ADR--Ist      Soll--ADR--Ist');
    GotoXY(2,3);  write(' [Hex]....[Hex]      [Hex]....[Hex]      [Hex]....[Hex]      [Hex]....[Hex]');
    TextColor(Black);

    Update_Ifb_Online;
    Ifb_Alt:= Ifb_Neu;
    Ifb_Min:= Ifb_Neu;
    Ifb_Max:= Ifb_Neu;

    Ch := ' ';
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step <SPACE>, Loop <CR>, <I>nterlock, <W>atch IFC-Adr,     E[X]it');
       repeat until KeyPressed;
       Ch := ReadKey;
       if  Ch in ['x','X'] then Goto 99;
      end;

   repeat
    repeat
     Cursor (False);
     Set_Text_win;
     Ifb_Neu := 0;
     zeile := start_zeile;
     spalte:= start_spalte;
     Update_Ifb_Online;
     Displ_Ifb_Ary;

     if Ifb_Neu > Ifb_Max then Ifb_Max := Ifb_Neu;
     if Ifb_Neu < Ifb_Min then Ifb_Min := Ifb_Neu;

     Life_Sign (Norm);
     Cursor (False);
     TextColor (White);
     GotoXY(spalte_akt+04,01); write('   ');        {Lîsche alten Wert}
     GotoXY(spalte_akt+04,01); write(Ifb_Neu:3);
     GotoXY(spalte_akt+13,01); write('   ');
     GotoXY(spalte_akt+13,01); write(Ifb_Alt:3);
     GotoXY(spalte_akt+22,01); write('   ');
     GotoXY(spalte_akt+22,01); write(Ifb_Min:3);
     GotoXY(spalte_akt+31,01); write('   ');
     GotoXY(spalte_akt+31,01); write(Ifb_Max:3);
     TextColor (Black);
     Mil.Timer2_Wait(2000);
    until KeyPressed or (Ch = ' ');

    if Ch = ' ' then
      begin
       Ifb_Alt := Ifb_Neu;
       Ini_Msg_Win;
       Write('Stop/Single Step <SPACE>, Loop <CR>, <I>nterlock, <W>atch IFC-Adr,     E[X]it');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;

    if Ch in ['i','I'] then
      begin
       Disp_Intr_Mode := True;
      end;

    if Ch in ['w','W'] then
      begin
       Disp_Intr_Mode := False;
       Set_Text_Win;
       GotoXY (01, 22);
       write ('Daten von welcher IFC-Adr beobachten [00..FF] ??'); ClrEol;
       Disp_Sel_Adr := ask_hex_byte;
       Ini_Msg_Win;
       Write('Stop/Single Step <SPACE>, Loop <CR>, <I>nterlock, <W>atch IFC-Adr,     E[X]it');
      end;
   until Ch in ['x','X'];
 99:  TextColor(White);
      Cursor (True);
  end; {Mil_Detect_Ifc_Compare}


 PROCEDURE Mil_Echo;
   LABEL 99;
   VAR
    i,pc_status: WORD;
    error_cnt  : LONGINT;
    mil_status : WORD;
    wr_fct_code, rd_fct_code : WORD;
    MilErr     : TMilErr;
    Fct        : TFct;
    rd_timeout : Boolean;
    timout_rd, timout_wr  : LongInt;
    transf_cnt : LongInt;
    Ch         : Char;
    Rd_data    : Word;

    function Get_Data: WORD;
     var read_data : Word;
     begin
      Fct.B.Fct := Fct_Rd_Echo;
      Mil.Rd (Read_Data, Fct, MilErr);
      if MilErr  <> No_Err then
       begin
        rd_timeout := TRUE;
        timout_rd := timout_rd + 1;
       end
      else
       begin  {kein Timeout}
        rd_timeout:= FALSE;
        get_data  := read_data;
       end;
     end; {Get_Data}

   Begin
    Ini_Text_Win;
    transf_cnt:= 0;
    error_cnt := 0;
    timout_wr := 0; timout_rd := 0;
    Fct.B.Adr := Ifk_Test_Nr;
    TextColor(Brown);
    GotoXY(02,03); write('  MIL-ECHO-Funktion mit der "neuen" IFC-Karte [FG 380.20x] oder MIL-Monitor!!');
    GotoXY(06,04); write('[Daten (0000 .. FFFF) im Loop zur IFC: schreiben/lesen und ÅberprÅfen]');
    GotoXY(4,07);
    write('Achtung: Test benîtigt IFC-Karte mit Fct-Code 13H u. 89H (z.B. FG 380.200)');

    GotoXY(20,08);
    Fct.B.Fct := Fct_Wr_Echo;
    write  ('Wr-Fct-Word: '); TextColor(Blue); Write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]     ');
    Fct.B.Fct := Fct_Rd_Echo;
    write  ('Rd-Fct-Word: '); TextColor(Blue); Write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]');

    GotoXY(6, 11);
    writeln('Wr_Data_Cnt:              Write-Data[H]:                ');
    GotoXY(6, 14);
    writeln('Error_Count:              Read-Data [H]:                ');
    GotoXY(22,12);  writeln('^  ^');
    GotoXY(22,15);  writeln('^  ^');
    GotoXY(53,11);  write('Timeout:');
    GotoXY(53,14);  write('Timeout:');
    TextColor(Black);
    GotoXY(18,14);  write(error_cnt:10);
    GotoXY(61,14);  write(timout_rd:10);
    GotoXY(61,11);  write(timout_wr:10);

    mil.reset;      {Clear Fifo}


    Ch := ' ';
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
       Ch := ReadKey;
       if  Ch in ['x','X'] then Goto 99;
      end;

    i := 0;
    repeat
     repeat
       Set_Text_win;
       transf_cnt:= transf_cnt+ 1;
       GotoXY(18,11); write(transf_cnt:10);
       GotoXY(47,11); write(hex_word(i));

       Fct.B.Fct := Fct_Wr_Echo;
       Mil.Wr (i, Fct, MilErr);
       Rd_data := get_data;
       IF rd_timeout THEN
         Begin
           GotoXY(61,14); write(timout_rd:10);
           GotoXY(47,14); write('    ');
           mil.reset;
         End
       ELSE
         Begin
           GotoXY(47,14);  write(hex_word(Rd_data));
         End;

       IF (NOT rd_timeout) AND (Rd_data <> i) THEN
         Begin
           error_cnt := error_cnt + 1;
           GotoXY(18,14); write(error_cnt:10);
         End;
       i := i + 1;
       if (i = $FFFF + 1) then i := 0;
  until KeyPressed or (Ch = ' ');
     if Ch = ' ' then
       begin
        Ini_Msg_Win;
        Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
        repeat until KeyPressed;
       end;
     Ch := ReadKey;
    until Ch in ['x','X'];
    99:
 End; {Mil_Echo}

 PROCEDURE Mil_Detect_Ifc;
  label 99;
  CONST start_zeile = 4;
        start_spalte =5;
        zeile_max    =22;
        spalte_offset=20;

  VAR ifc_total  : WORD;
      ifb_online : ARRAY[0..255] OF BOOLEAN;
      ifb_adr    : WORD;
      zeile,spalte: BYTE;
      hex_str    : STRING[10];
      i,n        : WORD;
      RetAdr     : Byte;
      OnlineErr  : TOnlineErr;
      Ch         : Char;
      Transf_Cnt : LongInt;

   type TLife = (Norm, Blinc);
   procedure Life_Sign (Mode: TLife);
    const S_Aktiv   = 3;
          Z_Aktiv   = 1;
          Life_Time1 = 5000;
          Life_Time2 = 2000;
    var Life_Wait : LongInt;
    begin
      Cursor (False);
      Set_Text_Win;
      if Mode = Norm then
       begin
        Life_Wait := Life_Time2;
        Set_Text_Win;
        TextColor(Yellow);
        GotoXY(S_Aktiv, Z_Aktiv);  Write (chr($7C)); Mil.Timer2_Wait (Life_Wait);
        GotoXY(S_Aktiv, Z_Aktiv);  Write ('/');      Mil.Timer2_Wait (Life_Wait);
        GotoXY(S_Aktiv, Z_Aktiv);  Write (chr($2D)); Mil.Timer2_Wait (Life_Wait);
        GotoXY(S_Aktiv, Z_Aktiv);  Write ('\');      Mil.Timer2_Wait (Life_Wait);
       end
      else
       begin
         TextColor(Red+128);
         GotoXY(S_Aktiv, Z_Aktiv); Write (chr($B2));
       end;
      TextColor(Black);
      Cursor(True);
      Set_Text_Win;
     end; {Life_Sign}

  Begin
   ini_text_win;
   Ini_Msg_Win;
   Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
   Ch := Taste_Return;

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      ifc_total := 0;
      zeile := start_zeile;
      spalte:= start_spalte;
      Ini_Text_Win;

      GotoXY(06,1); ClrEol;
      TextColor(Blue);
      Write('Am MIL-Bus melden sich mit ['); TextColor(Black);
      Write ('C0H'); TextColor(Blue); Write('] insgesamt IFC-Karten online: ');

      TextColor(Blue);
      GotoXY(2,2);  write(' Soll--ADR--Ist      Soll--ADR--Ist      Soll--ADR--Ist      Soll--ADR--Ist');
      GotoXY(2,3);  write(' [Hex]....[Hex]      [Hex]....[Hex]      [Hex]....[Hex]      [Hex]....[Hex]');
      TextColor(Black);
      Life_Sign (Norm);

      FOR ifb_adr := 0 TO 255 DO
        Begin
          mil.ifc_online (ifb_adr, RetAdr, OnlineErr);
          If (OnlineErr = NoErr) or (OnlineErr = AdrErr) then
            begin
             if (ifb_adr=0) or (ifb_adr<>RetAdr) then
              begin
               TextColor(Red); {Setze Schriftfarbe}
               GotoXY (spalte, zeile);
               hex_str := hex_byte(ifb_adr);
               write(hex_Byte(Ifb_Adr));                           {Solladresse}
              end;

             GotoXY (spalte+8, zeile); write(hex_Byte(RetAdr));  {Istadr}
             TextColor(Black); ClrEol;                    {Setze Schriftfarbe}
             zeile := zeile + 1;
             IF (zeile > zeile_max )  THEN
              begin
                spalte := spalte + spalte_offset;
               if spalte > (80 - spalte_offset) then
                begin
                  Ini_Err_Win;
                  Write ('ERROR: Zuviele Fehler!!  Abbruch!! Weiter beliebige Taste!');
                  repeat until KeyEPressed;
                  Exit; {Zuviele Spalten}
                end;

                zeile  := start_zeile;
              end;
             ifc_total := ifc_total + 1;
            end
          else
            begin     {Online-Error auswerten}

            end; {if OnlineErr}
        End; {FOR}

     GotoXY(69,01); TextColor(White); write(ifc_total); TextColor(Black);
     Mil.Timer2_Wait(70000);
    until KeyPressed or (Ch = ' ');
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;
   until Ch in ['x','X'];
   99:
 End; {detect_ifc}

procedure Int_Mask;                           {INT_MASK.PAS}
{
 Bei DOS: Intr-Vektor-Adressen liegen zwischen 000H...003FFH: 0 .. 1024 Dez.
 Jeder Vector belegt 4 Byte fÅr den Adress-Pointer.
 Das Programm Int_Mask zeigt fÅr den SLAVE-Interrupt-Baustein 8259
 die gerade aktuelle Maske fÅr IRQ_08...15, in dem es das IMR-Register
 ausliest. Eine "0" bedeutet: Intr. aktiv, "1" = Intr. disabled.
}
const                         {Software Interrupts Borland?}
 head_line =
      'Datentechnik                         INT_MASK     ' +
      '                  [24.11.1995]'+
      '        Darstellung Intr-Masken 8259 Master + Slave f. PC   (Turbo Pascal V7.0)';


  Int_00_Vector = $00; {Division durch 0}
  Int_02_Vector = $02; {NMI}
  Int_05_Vector = $05; {Shift-Prt-Scrn}
  Int_1B_Vector = $1B; {Ctrl Break}
  Int_1C_Vector = $1C; {Datum, Uhrzeit Timer}
  Int_23_Vector = $23; {Ctrl C}
  Int_24_Vector = $24; {Critical Error}
  Int_75_Vector = $75; {Floating Point Error}

  Int_36_Vector = $36; {Emulator Interrupts Coprocessor}
  Int_37_Vector = $37; {        "          }
  Int_38_Vector = $38; {        "          }
  Int_39_Vector = $39; {        "          }
  Int_3A_Vector = $3A; {        "          }
  Int_3B_Vector = $3B; {        "          }
  Int_3C_Vector = $3C; {        "          }
  Int_3D_Vector = $3D; {        "          }
  Int_3E_Vector = $3E; {        "          }

  Irq_00_Vector = $08; {Timer}         {Hardware Intr-Vektoren }
  Irq_01_Vector = $09; {Tastatur}
  Irq_02_Vector = $0A; {Slave              ---v }
  Irq_03_Vector = $0B; {COM 2}
  Irq_04_Vector = $0C; {COM 1}
  Irq_05_Vector = $0D; {LPT 2}
  Irq_06_Vector = $0E; {Diskettencontroller}
  Irq_07_Vector = $0F; {LPT 1}

  Irq_08_Vector = $70; {RealTimeClock}
  Irq_09_Vector = $71; {IRQ2 umgeleitet    ---^ }
  Irq_10_Vector = $72; {frei}
  Irq_11_Vector = $73; {frei}
  Irq_12_Vector = $74; {frei}
  Irq_13_Vector = $75; {Coprocessor}
  Irq_14_Vector = $76; {Harddiskcontroller}
  Irq_15_Vector = $77; {frei}


  I8259_Adr_Mastr = $20;  { address of first  8259 Master Intr-Controller}
  I8259_Adr_Slave = $A0;  { address of second 8259 Slave }
  I8259_IMR_Mastr = $21;  { OCW1: port address of the 1st Interrupt Mask Register }
  I8259_IMR_Slave = $A1;  { OCW1: port address of the 2nd Interrupt Mask Register }
  I8259_OCW2_EOI  = $20;  { OCW2: End of Interrupt Command}


VAR
  Oldexit,Altvec : Pointer;
  N              : Word;
  Int_Vector     : Byte;
  Port_Data_Slave: Byte;
  Port_Data_Mastr: Byte;
  Bit16_Str      : Str19;
  Word_Data      : Word;

 PROCEDURE Displ_Int_Mask;
  Begin
     {Info-Anzeige der Bit-Belegung INT-Status}
      ini_info_win;
      writeln('Bit 15: IRQ15 frei? (1=disabl)');
      writeln('Bit 14: IRQ14 HD-Cntrl.       ');
      writeln('Bit 13: IRQ13 Co-Proc.        ');
      writeln('Bit 12: IRQ12 frei? (1=disabl)');
      writeln('Bit 11: IRQ11 frei? (1=disabl)');
      writeln('Bit 10: IRQ10 frei? (1=disabl)');
      writeln('Bit 09: IRQ09 IRQ2 z. Mastr   ');
      writeln('Bit 08: IRQ08 Real Time Clk   ');
      writeln;
      writeln('Bit 07: IRQ07 Master LPT1:    ');
      writeln(' "  |   |     Master usw.     ');
      write  ('Bit 00: IRQ00 Master Timer    ');
   End; {displ_int_stat}

BEGIN
  Ini_Headl_Win;
  Write(head_line);

  Ini_Text_Win;            {Defin. Fenster, lîsche Fenster}
  Displ_Int_Mask;
  Set_Text_Win;            {Textfenster restaurieren ohne Info zu lîschen}
  TextColor(Brown);
  GotoXY(05,07); write('Eine "0" bedeutet: Intr. ist belegt;  "1" bedeutet: Intr. ist frei          ');
  GotoXY(30,08); write('Standard-Belegung');

  GotoXY(06,15); write('Mask-Data[HEX]');
  GotoXY(06,16); write('Mask-Data[BIN]');

  GotoXY(22,17); write('v                 v');
  GotoXY(22,18); write('MSB             LSB');
  GotoXY(22,19); write('IRQ15          IRQ0');
//Port_Data_Slave := Port[I8259_IMR_Slave];
  GotoXY(05,10); write('Adr-$A1-Slave Mask (OCW1) : '); TextColor(Black);
  Write(Hex_Byte(Port_Data_Slave)); TextColor(Brown); Write(' [Hex]');

//Port_Data_Mastr := Port[I8259_IMR_Mastr];
  GotoXY(05,11); write('Adr-$20-Mastr Mask (OCW1) : '); TextColor(Black);
  Write(Hex_Byte(Port_Data_Mastr)); TextColor(Brown); Write(' [Hex]');
 
  Word_Data :=  Port_Data_Slave shl 8;    {slave ins Hi-Byte}
  Word_Data :=  Word_Data + Port_Data_Mastr;
  TextColor(Black);
  GotoXY(28, 15);  write(hex_word(Word_Data));
  Hex_Bin_Str (Word_Data,bit16_str);
  GotoXY(22, 16);  write(bit16_str);

  Ini_Msg_Win;
  Write('Ende mit beliebige Taste!!');
  repeat until Keypressed;
end; {intr_Mask}


procedure Convert_Hex_Volt;
 LABEL 99;
 VAR
   sollwert : Word;
   ch : char;
   Max_Wert : Real;
   V_Eingabe: Boolean;

   Begin
    V_Eingabe := True;
    Ini_Text_Win;
    Ini_Msg_Win;
    Write(' [H]ex oder [V]olt-Eingabe    bzw. Ende mit [X]');
    repeat until KeyPressed;
    Ch := ReadKey;
    if  Ch in ['x','X'] then Goto 99;
    if  Ch in ['h','H'] then V_Eingabe := False;;
    if  Ch in ['v','V'] then V_Eingabe := True;

    max_wert := 10.000;

    Ch := ' ';
    repeat
     repeat
       Ini_Text_Win;
       if V_Eingabe then      {Volt-Eingabe gewÅnscht}
        begin
          Sollwert := Rd_Real_Sw (10.0);
        end
       else                   {Hex-Eingabe gewÅnscht}
        begin
          Sollwert := Ask_Data;
        end;

       Ini_Text_Win;
       Writeln ('         [Hex]     [Volt]  ');
       Write   ('         ');
       write(Hex_Word(Sollwert));
       Write   ('     ');
       Write_Real_10V_Bipol (Sollwert); writeln;

       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, [W]echseln Hex <-> Volt,  Ende mit [X]');
       repeat until KeyPressed;

     until KeyPressed or (Ch = ' ');

     if Ch = ' ' then
       begin
        Ini_Msg_Win;
        Write('Stop/Single Step mit <SPACE>, [W]echseln Hex <-> Volt,  Ende mit [X]');
        repeat until KeyPressed;
       end;

     Ch := ReadKey;
     if Ch in ['w','W'] then V_Eingabe := not (V_Eingabe);
    until Ch in ['x','X'];
    99:
end; {Convert_Hex_Volt}


 PROCEDURE Mil_Wr_Fctcode;
 Label 99;
 VAR
    MilErr : TMilErr;
    Fct    : TFct;
    Ch     : Char;
    Code   : Word;

 procedure  Set_TastFct_Win;
  begin
   Window(39, 22, 80, 23);
   TextBackground(Green);
   TextColor(Black);               {Setze Schriftfarbe}
  end;


 procedure Wr_Function (Fct_Code: TFct);
  begin
    Set_Text_Win;
    Transf_Cnt := Transf_Cnt+ 1;
    GotoXY(20, 11); write(transf_cnt:12);
    Mil.WrFct (Fct_Code, MilErr);
  end; {Wr_Function}


   Begin
    Ini_Text_Win;
    GotoXY(5, 22); TextColor(Brown);
    Write ('Welchen Function-Code zur IFK-Nr. '); textColor(Blue);
    Write(Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write (' [H] ??');
    if Ask_Hex_Break (Code, Byt) then Fct.B.Fct := Code
    else Fct.B.Fct := 0;
    Fct.B.Adr := Ifc_Test_Nr;
    Ini_Text_Win;

    transf_cnt := 0;
    TextColor(Brown);
    GotoXY(19,05); write('----- Schreibe Function-Code zur IFC-Karte -----');
    GotoXY(25,08); write('Function-Word (Fct + Adr): '); TextColor(Black);
    Write(hex_word(Fct.W)); TextColor(Brown); Write (' [H]');

    GotoXY(6, 11); writeln('Wr_Fct_Cnt :');
    GotoXY(26,12); writeln('^  ^');

    Set_TastFct_Win;
    TextColor(Yellow);
    GotoXY(01, 01); Write('F1 :  Fct-Code Ñndern                  ');
    GotoXY(01, 02); Write('F10:  IfcAdr                           ');

    Set_Text_Win;
    TextColor(Brown);
    GotoXY(39,19); write('Belegung Funktions- u. Sondertasten: ');
    TextColor(Black);


    Mil.Reset;                            { clear fifo }
    Ini_Msg_Win;
    Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
    repeat until KeyPressed;
    Ch := NewReadKey;
    if  Ch in ['x','X'] then Goto 99;

    repeat
     Set_Text_Win;
     if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       Wr_Function (Fct);
       repeat until KeyEPressed;
      end;

     if Ch = #13 then  Wr_Function (Fct);

     if Ch = #0 then
      begin
       Ch := NewReadKey;
       case ord (Ch) of
       Taste_F1 : begin
                    if Ask_Hex_Break (Code, Byt) then
                     begin
                      Fct.B.Fct := Code;
                      Set_Text_Win; TextColor(Brown);
                      GotoXY(25,08); write('Function-Word (Fct + Adr): '); TextColor(Black);
                      Write(hex_word(Fct.W)); TextColor(Brown); Write (' [H]');
                     end;
                    Ini_Msg_Win;
                    Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
                  end;
       Taste_F10: begin
                    { New_Ifc_Adr; }
                    if Ask_Hex_Break (Code, Byt) then
                     begin
                       Ifc_Test_Nr := Code;
                       Fct.B.Adr := Ifc_Test_Nr;
                       Set_Text_Win; TextColor(Brown);
                       GotoXY(25,08); write('Function-Word (Fct + Adr): '); TextColor(Black);
                       Write(hex_word(Fct.W)); TextColor(Brown); Write (' [H]');
                     end;
                    Ini_Msg_Win;
                    Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
                  end; {Taste_F10}
     end;  {Case}
    end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
 99:
  End; {mil_wr_fctcode}


 Procedure Mil_Wr;   {Schreibe Daten mit Funktionscode}
  LABEL 99;
   VAR
     error_cnt  : LONGINT;
     MilErr : TMilErr;
     Fct    : TFct;
     Bit16_Strg: Str19;
     Code   : Word;
     Adress : Word;

 procedure  Set_TastWr_Win;
  begin
   Window(39, 21, 80, 23);
   TextBackground(Green);
   TextColor(Black);               {Setze Schriftfarbe}
  end;

   procedure Wr_SW (Data: Word);
    begin
      Mil.Wr (Data, Fct, MilErr);
      Set_Text_Win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(18,11); write(transf_cnt:10);
      GotoXY(47,11); write(hex_word(Data));
      Hex_Bin_Str (Data,bit16_strg);
      GotoXY(47, 13);  write(bit16_strg);
    end; {Wr-Data}

   Begin
    Ini_Text_Win;
    Fct.B.Adr := Ifc_Test_Nr;
    GotoXY(5, 22); TextColor(Brown);
    Write ('Welchen Write-Function-Code fÅr IFK-Nr. '); TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr));
    TextColor(Brown); Write (' [H] ??');
    if Ask_Hex_Break (Code, Byt) then Fct.B.Fct := Code else Goto 99;

{    Wr_Data := 0;  }
    Ini_Text_Win;
    transf_cnt := 0;
    error_cnt  := 0;
    timout_wr  := 0;
    TextColor(Brown);
    GotoXY(15,05); write('----- Schreibe Daten auf den MIL-BUS mit Fct-Code -----');
    GotoXY(25,08); Write('Function-Word (Fct + Adr): '); TextColor(Black);
    Write (hex_word(Fct.W)); TextColor(Brown); Write(' [H]');
    GotoXY(06,11); writeln('Wr-Data-Cnt:           Write-Data [Hex]:                ');
    GotoXY(47,11); write(hex_word(wr_data));
    GotoXY(22,12); writeln('^  ^');
    GotoXY(06,13); writeln('                       Write-Data [BIN]:');
    GotoXY(47,14); write('MSB             LSB'); TextColor(Black);
{    GotoXY(06,13); writeln('Data [BIN] :');
    GotoXY(42,14); write('MSB             LSB'); TextColor(Black);
    GotoXY(47,11); write(hex_word(wr_data));
}
    Set_Text_Win;
    TextColor(Brown);
    GotoXY(39,18); write('Belegung Funktions- u. Sondertasten: ');
    TextColor(Black);

    Set_TastWr_Win;
    TextColor(Yellow);
    GotoXY(01, 01); Write('F1: Sollwert Hex    F10:  IfcAdr         ');
    GotoXY(01, 02); Write('F2: Fct-Code Ñndern                      ');
    GotoXY(01, 03); Write('F5: SW 0.0          <- -> Bit schieben   ');


    Mil.Reset;                            { clear fifo }
    Ini_Msg_Win;
    Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
    repeat until KeyPressed;
    Ch := NewReadKey;
    if  Ch in ['x','X'] then Goto 99;

    repeat
     Set_Text_Win;
     if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       Wr_SW (Wr_Data);
       repeat until KeyEPressed;
      end;

     if Ch = #13 then Wr_SW (Wr_Data);

     if Ch = #0 then
      begin
       Ch := NewReadKey;
       case ord (Ch) of
       Taste_F1 : begin
                   if Ask_Hex_Break (Wr_Data, Wrd) then
                    begin
                      Set_Text_Win;
                      Wr_SW (Wr_Data);
                    end;
                   Ini_Msg_Win;
                   Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
                  end;
       Taste_F2 : begin
                    if Ask_Hex_Break (Code, Byt) then
                     begin
                      Fct.B.Fct := Code;
                      Set_Text_Win; TextColor(Brown);
                      GotoXY(25,08); Write('Function-Word (Fct + Adr): '); TextColor(Black);
                      Write (hex_word(Fct.W)); TextColor(Brown); Write(' [H]');
                     end;
                    Ini_Msg_Win;
                    Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
                  end;
       Taste_F5 : begin
                   Wr_Data := 0;
                   Set_Text_Win;
                   Wr_SW (Wr_Data);
                  end;

       Taste_F10: begin
                   {  New_Ifc_Adr; }
                   if Ask_Hex_Break (Adress, Byt) then
                    begin
                     Ifc_Test_Nr := Adress;
                     Fct.B.Adr   := Ifc_Test_Nr;
                     Set_Text_Win; TextColor(Brown);
                     GotoXY(25,08); Write('Function-Word (Fct + Adr): '); TextColor(Black);
                     Write (hex_word(Fct.W)); TextColor(Brown); Write(' [H]');
                    end;
                   Ini_Msg_Win;
                   Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
                  end; {Taste_F10}

       Taste_Pfeil_Links : begin
                             if Wr_Data = $0000 then Wr_Data := $1
                             else Wr_Data := Wr_Data shl 1;
                             Wr_SW (Wr_Data);
                            end;  {Taste_Pfeil_Links}
       Taste_Pfeil_Rechts: begin
                            if Wr_Data = $0000 then Wr_Data := $8000
                            else Wr_Data := Wr_Data shr 1;
                            Wr_SW (Wr_Data);
                           end;  {Taste_Pfeil_Rechts}
      end;  {Case}
     end;

     if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
 99:
End; {mil_wr}

procedure Mil_WrData (mil_data: Word);   {nur Datenschreiben, ohne Fct-Code}
 label 99;
 var  MilErr : TMilErr;
   begin
    Ini_Text_Win;
    Transf_Cnt:= 0;
    TextColor(Brown);
    GotoXY(15,05); write('----- Schreibe Daten auf den MIL-BUS ohne Fct-Code -----');
    GotoXY(20, 7); write  ('IFK-Adr   :   '); Write(hex_Byte(Ifc_Test_Nr)); Write(' [H]');
    GotoXY(20, 8); write  ('MIL-Daten : '); TextColor(Black); Write (hex_word(mil_data));
    TextColor(Brown); Write(' [H]');
    GotoXY(6, 11); writeln('Datentransf:');
    GotoXY(29,12); writeln('^  ^');

    Ch := ' ';
    if Ch = ' ' then
     begin
      Ini_Msg_Win;
      Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
      repeat until KeyPressed;
      Ch := ReadKey;
      if  Ch in ['x','X'] then Goto 99;
     end;

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(25,11);  Write(Transf_Cnt:10);
      Mil.WrDta (Mil_Data, MilErr);
    until KeyPressed or (Ch = ' ');
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;
   until Ch in ['x','X'];
99:
End; {Mil_WrData}


 procedure Mil_Wr_Rd (Write_Data: WORD);
  Label 99;
   VAR
    i,pc_status: WORD;
    error_cnt  : LONGINT;
    wr_fct_code: WORD;
    rd_fct_code: WORD;
    MilErr     : TMilErr;
    Fct        : TFct;
    Read_Data  : Word;
    Code       : Word;

    function Get_Data: WORD;
     var read_data : Word;
     begin
      Fct.B.Fct := Rd_Fct_Code;
      Mil.Rd (read_data, Fct, MilErr);
      if MilErr  <> No_Err then
       begin
        rd_timeout := TRUE;
        timout_rd := timout_rd + 1;
       end
      else
       begin  {kein Timeout}
        rd_timeout:= FALSE;
        get_data  := read_data;
       end;
     end; {Get_Data}

   Begin
    Ini_Text_Win;
    transf_cnt := 0;
    error_cnt := 0;
    timout_wr := 0; timout_rd := 0;
    Fct.B.Adr := Ifc_Test_Nr;

    GotoXY(5, 22); TextColor(Brown);
    Write ('Welchen Write-Function-Code fÅr IFK-Nr. '); TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr));
    TextColor(Brown); Write (' [H] ??');
    if Ask_Hex_Break (Code, Byt) then wr_fct_code := Code else Goto 99;
{xxx}
    Ini_Text_Win;
    GotoXY(5, 22); TextColor(Brown);
    Write ('Welchen Read-Function-Code fÅr IFK-Nr. '); TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr));
    TextColor(Brown); Write (' [H] ??');
    if Ask_Hex_Break (Code, Byt) then rd_fct_code := Code else Goto 99;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(15,05); write('----- Daten zur IFC: schreiben/lesen und ÅberprÅfen -----');
    Fct.B.Fct := wr_fct_code;
    GotoXY(25, 8);  write ('WR-Fct: '); TextColor(Blue); Write (hex_word(Fct.W)); TextColor(Brown);
    Write(' [H]   RD-Fct: '); TextColor(Blue);
    Fct.B.Fct := rd_fct_code; write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]');
    TextColor(Brown);
    GotoXY(6, 11);  writeln('Wr_Data_Cnt:              Write-Data[H]:                ');
    GotoXY(6, 14);  writeln('Error_Count:              Read-Data [H]:                ');
    GotoXY(22,12);  writeln('^  ^');
    GotoXY(22,15);  writeln('^  ^');
    GotoXY(53,11);  write('Timeout:');
    GotoXY(53,14);  write('Timeout:');
    TextColor(Black);
    GotoXY(18,14);  write(error_cnt:10);
    GotoXY(61,14);  write(timout_rd:10);
    GotoXY(61,11);  write(timout_wr:10);

    Mil.reset;      {Clear Fifo}
    Ch := ' ';
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
       Ch := ReadKey;
       if  Ch in ['x','X'] then Goto 99;
      end;

    repeat
     repeat
       Set_Text_win;
       Transf_Cnt := Transf_Cnt+ 1;
       GotoXY(18,11); write(transf_cnt:10);
       GotoXY(47,11); write(hex_word(write_data));
       Fct.B.Fct := wr_fct_code;
       Mil.Wr (write_data, Fct, MilErr);
       read_data := get_data;
       IF rd_timeout THEN
         Begin
           GotoXY(61,14); write(timout_rd:10);
           GotoXY(47,14); write('    ');
           mil.reset;
         End
       ELSE
         Begin
           GotoXY(47,14);  write(hex_word(read_data));
         End;
       IF (NOT rd_timeout) AND (read_data <> write_data) THEN
        Begin
         error_cnt := error_cnt + 1;
         GotoXY(18,14); write(error_cnt:10);
        End;
     until KeyPressed or (Ch = ' ');
     if Ch = ' ' then
       begin
        Ini_Msg_Win;
        Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
        repeat until KeyPressed;
       end;
     Ch := ReadKey;
    until Ch in ['x','X'];
    99:
 End; {Mil_Wr_Rd}

 procedure Find_First_Online;     {Global: Ifc_Test_Nr}
  var N        : Word;
     RetAdr    : Byte;
     OnlineErr : TOnlineErr;

  begin
   for N:=1 to 255 do    {nehme automatisch 1. IFC als Default-Adr}
    begin
     Mil.Ifc_Online (N, RetAdr, OnlineErr);
     if OnlineErr = NoErr then
      begin
       Ifc_Test_Nr := N;
       //:= 255;            {Loop abbrechen}
      end
     else
       Ifc_Test_Nr := 0;    {Default}
    end;
  end;  {Find_First_Online; }


 PROCEDURE Mil_Ask_Ifc;
  label 99, Start;
  CONST start_zeile = 4;
        start_spalte =5;
        zeile_max    =22;
        spalte_offset=20;

  VAR answer : CHAR;
      Status : Boolean;
      ifc_total      : WORD;
      ifc_total_err  : WORD;
      ifb_online : ARRAY[0..255] OF BOOLEAN;
      ifb_adr    : Integer;
      zeile,spalte: BYTE;
      hex_str    : STRING[10];
      i,n        : WORD;
      RetAdr     : Byte;
      OnlineErr  : TOnlineErr;
      Ende       : Boolean;
      User_In    : Word;

  begin
Start:
    Zeile := Start_Zeile;
    Spalte:= Start_Spalte;
    Ifc_Total     := 0;
    Ifc_Total_Err := 0;

    Ini_Text_Win;
    FOR ifb_adr := 0 TO 255 DO ifb_online [Ifb_Adr] := False;

    FOR ifb_adr := 0 TO 255 DO
      Begin
        mil.ifc_online (ifb_adr, RetAdr, OnlineErr);
        { TOnlineErr= (NoErr, WrTo, RdTo, AdrErr)}
        If (OnlineErr = NoErr) and (Ifb_Adr = RetAdr) then
         begin
            ifb_online [Ifb_Adr] := True;
            Set_Text_Win;  TextColor (Black);
            GotoXY (spalte, zeile);
            write(hex_Byte(Ifb_Adr));                           {Solladresse}
            zeile := zeile + 1;
            IF (zeile > zeile_max )  THEN
             begin
               spalte := spalte + spalte_offset;
               zeile  := start_zeile;
             end;
            ifc_total := ifc_total + 1;
          end {if noerr}
         else
          begin   {Online-Error!!}
            if OnlineErr = AdrErr then
             begin
               Ifc_Total_Err := Ifc_Total_Err + 1;
               Ini_Err_Win;
               Write ('ERROR: Antwort v. falscher IFK-Adr!  '); TextColor(Yellow+128);
               Write('Soll: ', Hex_Byte(ifb_adr),'[H]  Ist: ', Hex_Byte(RetAdr),'[H]');
               TextColor(Red); Write ('  [W]eiter [Q]uit');
               repeat
                 Ch := NewReadKey;
                 if Ch in ['q','Q'] then
                  begin
                   Ch := ' ';
                   Exit;
                  end;
               until Ch in ['w','W'];
             end; {OnlineErr = AdrErr}
          end;
    End; {FOR}

    Set_Text_Win;
    if  Ifc_Total_Err <> 0 then
     begin
       TextColor(Red);
       GotoXY (03,01);
       Write ('Es melden sich ['); TextColor (Yellow);  Write (ifc_total_err); TextColor(Red);
       Write('] IFK-Karte(n) mit falscher IFC-Adresse!!!');
       TextColor(Black);
     end;

    GotoXY (03,02); TextColor(Brown);
    Write ('Es melden sich ['); TextColor (Yellow); Write (ifc_total); TextColor(Brown);
    Write('] IFK-Karte(n) "ONLINE": '); TextColor (Black);

    if ifc_total <> 0 then
     begin
       Ifb_Adr := -1;
       repeat
        Ifb_Adr := Ifb_Adr + 1;
        Ifc_Test_Nr := Ifb_Adr;
       until ifb_online [Ifb_Adr] or (Ifb_Adr > 255);
     end
    else
     begin
      Ini_Err_Win;
      Write ('Keine IFC Online! Neue [A]bfrage, [H]ex-Eingabe oder weiter <CR>');
      answer := NewReadKey;
      if answer = chr($0D)   then goto 99;       {Abort}
      if answer in ['a','A'] then goto Start;
      if answer in ['h','H'] then        {Adresse in Hex eingeben}
       begin
         if Ask_Hex_Break (User_In, Byt) then Ifc_Test_Nr := User_In
         else goto Start;
       end;
     end;

    Ini_Msg_Win;
    Write ('Online Adr ['); TextColor(Red+128); Write (Hex_Byte(Ifc_Test_Nr)); TextColor(Yellow);
    Write ('] Åbernehmen <CR>, wÑhlen ',chr($19),'',chr($18),', neu [A]bfragen oder [H]ex-Eingabe:');
    //answer := NewReadKey;

    answer := readkey;
    repeat
      //if KeyEPressed then answer := NewReadKey;
      if answer in ['a','A'] then goto Start;
      if answer in ['h','H'] then
        begin
          if Ask_Hex_Break (User_In, Byt) then
            begin
             Ifc_Test_Nr := User_In;
             Ini_Msg_Win;
             Write ('Online Adr ['); TextColor(Red+128); Write (Hex_Byte(Ifc_Test_Nr)); TextColor(Yellow);
             Write ('] Åbernehmen <CR>, wÑhlen ',chr($19),'',chr($18),', neu [A]bfragen oder [H]ex-Eingabe:');
             answer :=  ' ';
            end
           else goto Start;
        end;

       if answer = #0 then          {Sondertaste!!}
        begin
         answer := NewReadKey;
         case ord (answer) of
         Taste_Pfeil_Ab  : begin
                             Ifb_Adr := Ifc_Test_Nr;
                             repeat
                              Ifb_Adr := Ifb_Adr + 1;
                              if ifb_adr = 256 then ifb_Adr := 255;
                              if ifb_online [Ifb_Adr] then Ifc_Test_Nr := Ifb_Adr;
                             until ifb_online [Ifb_Adr] or (Ifb_Adr = 255);
                             Ini_Msg_Win;
                             Write ('Online Adr ['); TextColor(Red+128); Write (Hex_Byte(Ifc_Test_Nr)); TextColor(Yellow);
                             Write ('] Åbernehmen <CR>, wÑhlen ',chr($19),'',chr($18),', neu [A]bfragen oder [H]ex-Eingabe:');
                             answer := ' ';
                            end;

          Taste_Pfeil_Auf  : begin
                             Ifb_Adr := Ifc_Test_Nr;
                             repeat
                              Ifb_Adr := Ifb_Adr - 1;
                              if Ifb_Adr = -1 then ifb_Adr := 0;
                              if ifb_online [Ifb_Adr] then Ifc_Test_Nr := Ifb_Adr;
                             until ifb_online [Ifb_Adr] or (Ifb_Adr = 0);
                             Ini_Msg_Win;
                             Write ('Online Adr ['); TextColor(Red+128); Write (Hex_Byte(Ifc_Test_Nr)); TextColor(Yellow);
                             Write ('] Åbernehmen <CR>, wÑhlen ',chr($19),'',chr($18),', neu [A]bfragen oder [H]ex-Eingabe:');
                             answer := ' ';
                            end;
         end;  {Case}
     end;
    until answer = chr($0D);
99:
  end;  {MIL_Ask_Ifc}


 PROCEDURE Mil_Rd_Status;     {Internes Register PC-Karte}
  Label 99;                   {Direkter Zugriff auf Port ist hier Ausnahme!!}
  VAR read_data : WORD;

   PROCEDURE show_stat_reg;
    var bit16_str : Str19;
    Begin
     read_data := 4711;//PORTW [Port_Stat]; {sonst nur Åber Variable Mil : T_Mil}
     GotoXY(28, 15);  write(hex_word(read_data));
     Hex_Bin_Str (read_data, bit16_str);
     GotoXY(22, 16);  write(bit16_str);
    End;

   Begin
    Ini_Text_Win;            {Defin. Fenster, lîsche Fenster}
    Displ_Pc_Stat;           {Zeige die Bitbelegung als Info}
    set_text_win;            {Textfenster restaurieren ohne Info zu lîschen}
    transf_cnt := 0;
    timout_cnt := 0;

    TextColor(Brown);
    GotoXY(02,02); write('Hinweis: DReq, DRdy, Intl erscheinen normalerweise nur, wenn auf der IFC die');
    GotoXY(02,03); write('Intr-Maske mit Fct-Code [12H] enabled wurde bzw. wenn am MIL-Monitor (F 414)');
    GotoXY(02,04); write('im PASSIV-Mode die Leitungen INTRL, DRDY, DREQ betÑtigt werden!             ');

    GotoXY(21,07); write('----- Interner Status PC-Karte -----');
    GotoXY(06,11); write('Rd_Stat_Cnt:');
    GotoXY(26,12); write('^  ^');
    GotoXY(06,15); write('Stat-Data[HEX]');
    GotoXY(06,16); write('Stat-Data[BIN]');
    GotoXY(22,17); write('MSB             LSB');
    TextColor(Black);

   Ch := ' ';
   if Ch = ' ' then
     begin
      Ini_Msg_Win;
      Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
      repeat until KeyPressed;
      Ch := ReadKey;
      if  Ch in ['x','X'] then Goto 99;
     end;

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(20, 11); write(transf_cnt:12);
      show_stat_reg;
    until KeyPressed or (Ch = ' ');
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;
   until Ch in ['x','X'];
   99:
  End; {mil_rd_status}


 PROCEDURE Mil_Loop;
   LABEL 99;
   VAR
    i, pc_status  : WORD;
    error_cnt  : LONGINT;
    mil_status : WORD;
    wr_fct_code, rd_fct_code : WORD;
    MilErr     : TMilErr;
    Fct        : TFct;
    Read_Data  : Word;
    User_In    : Word;

    function Get_Data: WORD;
     var Read_Data : Word;
         Pc_Stat   : TPcStat;
     begin
      Fct.B.Fct := Rd_Fct_Code;
      Mil.Rd (Read_Data, Fct, MilErr);
      if MilErr  <> No_Err then
       begin
        Pc_Stat.W := 4711;//PortW [Port_Stat];           {internen PC-Status lesen}
        if not (FfoEty in Pc_Stat.B) then         {ist Fifo leer?}
         begin                                    {Nein!}
           Mil.Timer2_Wait(10);                   {wait 100 us und leere Fifo}
           repeat
             Read_Data := 4712;//Portw[Port_Data];       {Fifo lesen}
             Pc_Stat.W := 4713;//PortW [Port_Stat];
           until FfoEty in Pc_Stat.B;
         end;
        rd_timeout := TRUE;
        timout_rd := timout_rd + 1;
       end
      else
       begin  {kein Timeout}
        rd_timeout:= FALSE;
        get_data  := read_data;
       end;
     end; {Get_Data}

 procedure Disp_Data (SingleStep: Boolean);
  begin
    Set_Text_Win;
    if SingleStep then
     begin
      GotoXY(18,11); write(transf_cnt:10);
      GotoXY(47,11); write(hex_word(i));
      GotoXY(47,14); write(hex_word(read_data));
     end
    else
     begin
      GotoXY(47,11); write('    ');
      GotoXY(47,14); write('    ');
      GotoXY(18,11); TextColor(Red+128); write('    Loop! ');
     end;
  end;

 procedure Transf_Data (Displ_Mode: Boolean);
  begin
   Set_Text_win;
   Transf_Cnt:= Transf_Cnt + 1;
   Fct.B.Fct := Wr_Fct_Code;
   Mil.Wr (i, Fct, MilErr);
   Read_Data := Get_Data;
   if ((Rd_Timeout) or (Read_Data <> i)) then
    begin      {Anzeige im Fehlerfall}
     if Rd_Timeout then
       begin
         timout_rd := timout_rd + 1;
         GotoXY(61,14); write(timout_rd:10);
         if Displ_Mode then
          begin
            GotoXY(18,11); write(transf_cnt:10);
            GotoXY(47,11); write(hex_word(i));    {Write Daten anzeigen}
          end;
         GotoXY(47,14); write('    ');
         Mil.Reset;
       end;

     if (not Rd_Timeout) and (Read_Data <> i) then
       begin
         Error_Cnt := Error_Cnt + 1;
         GotoXY(18,14); write(Error_Cnt:10);
         if Displ_Mode then
          begin
    Disp_Data (Displ_Mode);
            GotoXY(47,11); write(hex_word(i)); {Single Step: anzeigen}
            GotoXY(47,14); write(hex_word(read_data));
          end;
         TextColor(Blue);
         GotoXY(47,12); write(hex_word(i));  {Error: letzte Daten anzeigen}
         GotoXY(47,15); write(hex_word(read_data));
         TextColor(Black);
       end;
    end       {If Error}
   else
    begin     {Kein Error}
     if Displ_Mode then Disp_Data (Displ_Mode);  {Normale Datenanzeige}
    end;

   i := i + 1;
   if (i = $FFFF + 1) then i := 0;
  end;

   Begin
    Ini_Text_Win;
    transf_cnt:= 0;
    error_cnt := 0;
    timout_wr := 0; timout_rd := 0;
    Fct.B.Adr := Ifc_Test_Nr;

    GotoXY(5, 22);  TextColor(Brown);
    Write ('Eingeben Write-Function-Code [00H...7FH] fÅr IFK-Nr. ');
    TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write(' [H] ??');
    if Ask_Hex_Break (User_In, Byt) then wr_fct_code := User_In
     else Exit;

    Ini_Text_Win;
    GotoXY(5, 22);  TextColor(Brown);
    Write ('Eingeben READ-Function-Code [80H...FFH] fÅr IFK-Nr. ');
    TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write(' [H] ??');
    if Ask_Hex_Break (User_In, Byt) then rd_fct_code := User_In
    else Exit;

    Ini_Text_Win;
    TextColor(Brown);
    GotoXY(02,04); write('---- Daten (0000 .. FFFF) im Loop zur IFK: schreiben/lesen und ÅberprÅfen ----');
    TextColor(Blue);
    GotoXY(20,05); write('Anzeige der letzten Fehlerdaten in blau');
    TextColor(Brown);

    GotoXY(4,07);
    write('Achtung: Dieser Test benîtigt eine IFK-Karte am MIL-BUS mit (FCT + ADR): ');
    GotoXY(15,08);
    Fct.B.Fct := wr_fct_code;
    write  ('Wr-Fct-Code: '); TextColor(Black); Write(hex_word(Fct.W)); TextColor(Brown); Write('[H]     ');
    Fct.B.Fct := rd_fct_code;
    write  ('Rd-Fct-Code: '); TextColor(Black); Write(hex_word(Fct.W)); textColor(Brown); Write('[H]');

    GotoXY(6, 11);
    writeln('Wr_Data_Cnt:              Write-Data[H]:                ');
    GotoXY(6, 12);
    writeln('                          Error-Data[H]:                ');

    GotoXY(6, 14);
    writeln('Error_Count:              Read-Data [H]:                ');
    GotoXY(6, 15);
    writeln('                          Error-Data[H]:                ');

    GotoXY(22,12);  writeln('^  ^');
    GotoXY(22,15);  writeln('^  ^');
    GotoXY(53,11);  write('Timeout:');
    GotoXY(53,14);  write('Timeout:');
    TextColor(Black);
    GotoXY(18,14);  write(error_cnt:10);
    GotoXY(61,14);  write(timout_rd:10);
    GotoXY(61,11);  write(timout_wr:10);
    Mil.Reset;      {Clear Fifo}
    Cursor(False);

    i  := 0;
    Ch := ' ';
    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Transf_Data (Single_Step);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then
      begin
       Single_Step := False;
       Disp_Data (Single_Step);
      end;

     if not Single_Step then
      begin
       Transf_Data (Single_Step);
      end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];

99: Cursor(True);
 End; {mil_loop}


 PROCEDURE Mil_Rd_Data;
  Label 99;
  const X_Pos_Fct1 = 68;
        X_Pos_Fct2 = 46;
        X_Pos_Fct3 = 25;

        X_Pos_Dat1 = 68;
        X_Pos_Dat2 = 46;
        X_Pos_Dat3 = 25;

  VAR Read_Data,pc_status : WORD;
      rd_timeout : BOOLEAN;
      MilErr : TMilErr;
      Fct    : TFct;
      Fct_ok : Boolean;
      Rd_Fct1, Rd_Fct2, Rd_Fct3 : Byte;
      N      : Byte;
      Anzahl : Byte;

   PROCEDURE get_data (Num : Byte);
    var Rd_Dta : Word;
        Bit16_Strg : Str19;
    Begin
     case Num of
      1: Fct.B.Fct := Rd_Fct1;
      2: Fct.B.Fct := Rd_Fct2;
      3: Fct.B.Fct := Rd_Fct3;
     end;

     Mil.Rd (Rd_Dta, Fct, MilErr);
     IF MilErr  <> No_Err THEN
      Begin
        timout_cnt := timout_cnt + 1;
        rd_timeout := TRUE;
        TextColor (Red);
        GotoXY(22,12); write(timout_cnt:12);
        TextColor (Black);

        case Num of
         1: begin
              GotoXY(X_Pos_Dat1, 17);  write('    ');
              GotoXY(17, 18);  write('                   ');
           end;
         2: begin
              GotoXY(X_Pos_Dat2, 17);  write('    ');
              GotoXY(38, 18);  write('                   ');
            end;
         3: begin
              GotoXY(X_Pos_Dat3, 17);  write('    ');
              GotoXY(60, 18);  write('                   ');
           end;
         end; {case}
        mil.reset;
      End
     ELSE
      Begin  {kein Timeout}
       rd_timeout := FALSE;
       case Num of
        1: begin
             GotoXY(X_Pos_Dat1,   17);  write(hex_word(Rd_Dta));
             Hex_Bin_Str (Rd_Dta,bit16_strg);
             GotoXY(X_Pos_Dat1-8, 18);  write(bit16_strg);
           end;
        2: begin
             GotoXY(X_Pos_Dat2,    17);  write(hex_word(Rd_Dta));
             Hex_Bin_Str (Rd_Dta,bit16_strg);
             GotoXY(X_Pos_Dat2-8, 18);  write(bit16_strg);
           end;
        3: begin
             GotoXY(X_Pos_Dat3,   17);  write(hex_word(Rd_Dta));
             Hex_Bin_Str (Rd_Dta,bit16_strg);
             GotoXY(X_Pos_Dat3-8, 18);  write(bit16_strg);
           end;
        end; {case}
      End;
    End; {get_data}

   function Ask_Fctcode (var Code: Byte; Nr: Byte): Boolean;
    var Funct_Ok : Boolean;
        User_In  : Word;
    begin
     repeat
      Ask_Fctcode := False;
      Funct_Ok := False;
      Ini_Text_Win;
      GotoXY(5, 22);  TextColor(Brown);
      Write ('Eingeben READ-Function-Code Nr. ',Nr,'  [80H...FFH]  fÅr IFK-Nr. ');
      TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write(' [H] ??');
      if Ask_Hex_Break (User_In, Byt) then
         Code := User_In
      else
       begin
        Funct_Ok := False;
        Exit;
       end;
      if Code < $80 then
       begin
         Ini_Err_Win;
         write ('Error: Read-Function-Code nicht 80H..FFh!!! Weiter mit <Space> ');
         repeat until keypressed;
         Ch := ReadKey;
       end
      else
       begin
        Funct_Ok    := True;
        Ask_Fctcode := True;
       end;
     until Funct_Ok;
    end; {Ask_Fctcode}

  Begin
    transf_cnt := 0;
    timout_cnt := 0;
    Fct_ok     := False;
    Fct.B.Adr  := Ifc_Test_Nr;

    Ini_Text_Win;
    Ini_Msg_Win;
    Write('Mit wieviel verschied. Funct_Codes lesen 1 oder 3? [<CR> = 1]:  ');
    repeat until Keypressed;
    Ch := ReadKey;

    if Ch = '3' then
     begin
       write('3');
       Anzahl := 3;
       Readln;
     end
    else
       Anzahl := 1;

    if Anzahl = 3 then
     begin
      if not (Ask_Fctcode (Rd_Fct1, 1)) then Exit;
      if not (Ask_Fctcode (Rd_Fct2, 2)) then Exit;
      if not (Ask_Fctcode (Rd_Fct3, 3)) then Exit;

      Ini_Text_Win;
      TextColor(Brown);
      GotoXY(22,05); write('----- Lese Daten von der IFC-Karte -----');
      GotoXY(06,11); writeln('Rd_Data_Cnt  :');
      GotoXY(26,12); writeln('^  ^');
      GotoXY(06,12); writeln('Timeout_Count: ');

      GotoXY(01,15); write('Fct-Word (Fct+Adr): ');
      Fct.B.Fct := Rd_Fct1;
      GotoXY(X_Pos_Fct1,15); Write(hex_word(Fct.W),' [H]');
      Fct.B.Fct := Rd_Fct2;
      GotoXY(X_Pos_Fct2,15); Write(hex_word(Fct.W),' [H]');
      Fct.B.Fct := Rd_Fct3;
      GotoXY(X_Pos_Fct3,15); Write(hex_word(Fct.W),' [H]');

      GotoXY(X_Pos_Fct1+2,14); Write('1');
      GotoXY(X_Pos_Fct2+2,14); Write('2');
      GotoXY(X_Pos_Fct3+2,14); Write('3');

      GotoXY(01,17); writeln('MIL-Data[H]:');
      GotoXY(07,18); writeln('[Bin]:');
      GotoXY(17,19); writeln('MSB             LSB');
      GotoXY(38,19); writeln('MSB             LSB');
      GotoXY(60,19); writeln('MSB             LSB');
      TextColor(Black);
      GotoXY(22,12); writeln(timout_cnt:12);

     Ch := ' ';
     if Ch = ' ' then
       begin
        Ini_Msg_Win;
        Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
        repeat until KeyPressed;
        Ch := ReadKey;
        if  Ch in ['x','X'] then Goto 99;
       end;

      repeat
       repeat
         Set_Text_win;
         Transf_Cnt := Transf_Cnt+ 1;
         GotoXY(22, 11); write(transf_cnt:12);
         get_data (1);

         Transf_Cnt := Transf_Cnt+ 1;
         GotoXY(22, 11); write(transf_cnt:12);
         get_data (2);

         Transf_Cnt := Transf_Cnt+ 1;
         GotoXY(22, 11); write(transf_cnt:12);
         get_data (3);
       until KeyPressed or (Ch = ' ');
       if Ch = ' ' then
         begin
          Ini_Msg_Win;
          Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
          repeat until KeyPressed;
         end;
       Ch := ReadKey;
      until Ch in ['x','X'];
     end  {if Anzahl = 3}
    else
     begin {Anzahl = 1}
      repeat
        Ini_Text_Win;
        GotoXY(5, 22);  TextColor(Brown);
        write ('Welchen READ-Function-Code [80H...FFH] fÅr IFK-Nr. ');
        TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr)); TextColor(Brown); Write(' [H] ??');
        if not Ask_Fctcode (Rd_Fct1, 1) then Exit
         else Fct_ok := True;
      until Fct_ok;

      Fct.B.Fct := Rd_Fct1;  {nur fÅr Anzeige}
      Ini_Text_Win;
      TextColor(Brown);
      GotoXY(22,05); write('----- Lese Daten von der IFC-Karte -----');
{      GotoXY(25,07); write  ('Function-Word (Fct + Adr): ',hex_word(Fct.W),' [H]'); }
      GotoXY(06,11); writeln('Rd_Data_Cnt  :');
      GotoXY(26,12); writeln('^  ^');
      GotoXY(06,12); writeln('Timeout_Count: ');
      TextColor(Black);
      GotoXY(22,12); writeln(timout_cnt:12);
      TextColor(Brown);
      GotoXY(01,15); write('Fct-Word (Fct+Adr): ');
      Fct.B.Fct := Rd_Fct1;
      TextColor(Blue);
      GotoXY(X_Pos_Fct1,15); Write(hex_word(Fct.W)); TextColor(Brown); Write(' [H]');

      GotoXY(01,17); writeln('MIL-Data[H]:');
      GotoXY(07,18); writeln('[Bin]:');
      GotoXY(60,19); writeln('MSB             LSB');
      TextColor(Black);

      IF (Rd_Fct1 = $C9) THEN
       begin
        displ_ifc_stat;                         {Anzeige nur bei C9-Fct-Code}
        set_text_win;            {Textfenster restaurieren ohne Info zu lîschen}
       end;

     Ch := ' ';
     if Ch = ' ' then
       begin
        Ini_Msg_Win;
        Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
        repeat until KeyPressed;
        Ch := ReadKey;
        if  Ch in ['x','X'] then Goto 99;
       end;

     repeat
      repeat
        Set_Text_win;
        Transf_Cnt := Transf_Cnt+ 1;
        GotoXY(22, 11); write(transf_cnt:12);
        get_data (1);
      until KeyPressed or (Ch = ' ');
      if Ch = ' ' then
        begin
         Ini_Msg_Win;
         Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
         repeat until KeyPressed;
        end;
      Ch := ReadKey;
     until Ch in ['x','X'];
    end; {if Anzahl = 1}
    99:
  End; {mil_rd_data}


  PROCEDURE Mil_Rd_Fifo;       {Lese internes Rcv-Datenreg}
  Label 99;
  VAR read_data : WORD;        {Direkter Zugriff auf Port ist hier Ausnahme!!}
   Begin
    Ini_Text_Win;
    transf_cnt := 0;
    TextColor(Brown);
    GotoXY(16,07);  write('----- Lese Datenregister der PC-Karte -----');
    GotoXY(6, 11);  writeln('Rd_Data_Cnt:');
    GotoXY(26,12);  writeln('^  ^');
    GotoXY(6, 14);  writeln('Read-Data[H]');
    TextColor(Black);

   Ch := ' ';
   if Ch = ' ' then
     begin
      Ini_Msg_Win;
      Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
      repeat until KeyPressed;
      Ch := ReadKey;
      if  Ch in ['x','X'] then Goto 99;
     end;

   repeat
    repeat
      Set_Text_win;
      Transf_Cnt := Transf_Cnt+ 1;
      GotoXY(20, 11); write(transf_cnt:12);
      read_data := 4714;//PORTW [Port_Data];    {sonst nur Åber Variable Mil : T_Mil}
      GotoXY(28, 14);  write(hex_word(read_data));
    until KeyPressed or (Ch = ' ');
    if Ch = ' ' then
      begin
       Ini_Msg_Win;
       Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
       repeat until KeyPressed;
      end;
    Ch := ReadKey;
   until Ch in ['x','X'];
   99:
 End; {mil_rd_fifo}

 function Ask_Sw_Break (var SW : TSw): Boolean; {lese wahlweise Volt, Hex, Amp}
 begin
  Ask_Sw_Break := False;
  case SW.Mode of
   V : begin   end;
   H : begin   end;
   A : begin   end;
  end; {case}
 end; {Ask_Sw_Break }

 procedure Life_Sign_XY (Param: TLife_XY);  {universelle Life-Sign-Routine}
  var
   Life_Wait        : LongInt;
   S_Aktiv, Z_Aktiv : Byte;
  begin
    Cursor(False);
    Param.Disp_Win;                     {Schalte auf Darstellungsfenster um}
    S_Aktiv := Param.PosX;
    Z_Aktiv := Param.PosY;
    if Param.Mode = Norm then
     begin
      Life_Wait := Param.Time;
      TextColor(Yellow);
      GotoXY(S_Aktiv, Z_Aktiv);  Write (chr($7C)); Mil.Timer2_Wait (Life_Wait);
      GotoXY(S_Aktiv, Z_Aktiv);  Write ('/');      Mil.Timer2_Wait (Life_Wait);
      GotoXY(S_Aktiv, Z_Aktiv);  Write (chr($2D)); Mil.Timer2_Wait (Life_Wait);
      GotoXY(S_Aktiv, Z_Aktiv);  Write ('\');      Mil.Timer2_Wait (Life_Wait);
      TextColor(Black);
     end
    else
     begin
       TextColor(Red+128);
       GotoXY(S_Aktiv, Z_Aktiv); Write (chr($DB));
       TextColor(Black);
     end;
   end; {Life_Sign_XY}

 procedure Mil_IfkMode;
  label 99;
  const
   Z_Base = 3;
   S_Base = 10;
   Z_Titel = Z_Base + 2;
   Z_Ident = Z_Base + 8;
   Z_Mode  = Z_Ident-1;
   Z_Count = Z_Ident-2;
   S_Ifk   = S_Base + 20;
   S_Ident = S_Base + 57;
   S_Count = S_Ifk+15;

 var
  Test_Count : LongInt;
  MilErr     : TMilErr;
  Fct        : TFct;
  RetAdr     : Byte;

  procedure Set_Mode_Win;
  const Z_Tastwin = 23;
  begin
   Set_Text_Win; TextColor(Brown);
   GotoXY(02,Z_Tastwin-3); Write('Belegung Funktionstasten:');
   Window(02, Z_Tastwin, 80, 23);
   TextBackground(Green);
   TextColor(Black);
  end;

 procedure Read_Ifk_Ident;
  var Rd_Data : Word;
  begin
    Test_Count := Test_Count+1;
    Set_Text_Win;
    TextColor(Black);
    GotoXY(S_Count,Z_Count);  Write (Test_Count);
    GotoXY(S_Ifk,  Z_Ident);  TextColor(Blue); Write (Hex_Byte(Ifc_Test_Nr));

    GotoXY(S_Count, Z_Mode);  TextColor(Black);
    Fct.B.Adr := Ifc_Test_Nr;
    Fct.B.Fct := Fct_Rd_IfkMode;
    Mil.Rd (Rd_Data, Fct, MilErr);
    if MilErr = No_Err then
     begin
       case Rd_Data of
        Ifk_Mode_IFA: Write ('IFK   ');
        Ifk_Mode_MB : Write ('MODBUS');
        Ifk_Mode_FG : Write ('FGEN  ');
       end; {case}
     end
    else
     begin
      Write ('??????');
     end;

    GotoXY(S_Ifk,  Z_Ident+1);
    Fct.B.Adr := Ifc_Test_Nr;
    Fct.B.Fct := Fct_Rd_Stat0;
    Mil.Rd (Rd_Data, Fct, MilErr);
    if MilErr = No_Err then
     begin
      if Lo(Rd_Data) <> Ifc_Test_Nr then
         TextColor (Red+128)
      else
         TextColor (Black);
      Write (Hex_Byte(Lo(Rd_Data)));
     end
    else
     begin
       Write ('??');
     end;

   GotoXY(S_Ident, Z_Ident); TextColor(Blue); Write (Hex_Byte(Ifk_ID_380211_ModBus));
   GotoXY(S_Ident, Z_Ident+1);
   Fct.B.Fct := Fct_Rd_IFK_ID;
   Mil.Rd (Rd_Data, Fct, MilErr);
   if MilErr = No_Err then
    begin
      if Hi(Rd_Data) <> Ifk_ID_380211_ModBus then
         TextColor (Red+128)
      else
         TextColor (Black);
      Write (Hex_Byte(Hi(Rd_Data)));
    end
   else
    begin
      Write ('??');
    end;
  end;

  begin
    Test_Count := 0;

    Ini_Text_Win;
    TextColor(Blue);
    GotoXY(S_Base+5,Z_Titel);    write('Lese Ident-Code u. IFK-Mode der Interface-Karte FG 380.21x');
    GotoXY(S_Base-8,Z_Titel+1);
    Write('[Steckplatzkodierung defin. Funktion als IFA, Modulbus u. Funktionsgenerator!]');

    GotoXY(S_Count-15, Z_Mode);    write('IFK-Mode  : ');
    GotoXY(S_Count-15, Z_Count);   write('Test-Count: ');
    GotoXY(S_Ifk  -17, Z_Ident);   write('IFK-Adr Soll[H]: ');
    GotoXY(S_Ifk  -17, Z_Ident+1); write('   "    Ist [H]: ');
    GotoXY(S_Ident-20, Z_Ident);   write('Ident-Code Soll[H]: ');
    GotoXY(S_Ident-20, Z_Ident+1); write('     "     Ist [H]: ');

    TextColor(Black);
    GotoXY(S_Count,Z_Count); Write (Test_Count);
    GotoXY(S_Ifk,  Z_Ident); Write (Hex_Byte(Ifc_Test_Nr));

    Set_Mode_Win;
    TextColor(Yellow);
{    GotoXY(01, 01); Write('F10:IfkAdr'); }
    GotoXY(01, 01); Write('F1: IFK-Mod   F3: Funkt-Generator    F10: IfkAdr');
    TextColor(Black);
    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Read_Ifk_Ident;
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;
     if not Single_Step then
      begin
       Read_Ifk_Ident;
       Mil.Timer2_Wait (50000);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Fct.B.Adr := Ifc_Test_Nr;
                    Fct.B.Fct := Fct_Wr_ModeReg;
                    Mil.Wr (Ifk_Mode_IFA, Fct, MilErr);
                    Ini_Msg_Win;
                    Write ('Set IFA-Mode');
                    Mil.Timer2_Wait (100000);
                    Std_Msg;
                   end;
        Taste_F2 : begin
 { Den Modulbusmode kann man nicht mehr setzen, sondern er wird durch die
   Verdrahtung der VG-Leiste festgelegt!!!
                    Fct.B.Adr := Ifc_Test_Nr;
                    Fct.B.Fct := Fct_Wr_ModeReg;
                    Mil.Wr (Ifk_Mode_MB, Fct, MilErr);
                    Ini_Msg_Win;
                    Write ('Set Modulbus-Mode');
                    Mil.Timer2_Wait (100000);
                    Std_Msg;
}                  end;
        Taste_F3 : begin
                    Fct.B.Adr := Ifc_Test_Nr;
                    Fct.B.Fct := Fct_Wr_ModeReg;
                    Mil.Wr (Ifk_Mode_FG, Fct, MilErr);
                    Ini_Msg_Win;
                    Write ('Set Functiongenerator-Mode');
                    Mil.Timer2_Wait (100000);
                    Std_Msg;
                   end;

        Taste_F10: begin
                    New_Ifc_Adr;
                    Std_Msg;
                   end;
        Taste_Pfeil_Links : begin
                            end;
        Taste_Pfeil_Rechts: begin
                            end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  99:  Cursor(True);
  end; {IfkMode}



 {Ask_Hex_LongInteger_Break ist Einleseroutine fÅr LongInt-Werte mit Abbruch
  durch Esc-Taste}
{ function Ask_Hex_Break (var In_Data: Word; Mode: TMode): Boolean; }
function Ask_Hex_LongInteger_Break (var In_Data: LongInt): Boolean; {Abort m. Esc}
  label 1;
  var Status  : Boolean;
      Read_Str: Str4;
      Read_Wrd: Word;
      Zeichen : Char;
      N, I    : Byte;
      savex, savey : Byte;    {Rette Cursor-Position}
      Ziffer_Max : Byte;
      Stat_LoWrd : Boolean;

  begin
    Stat_LoWrd    := False;
    Ask_Hex_LongInteger_Break := False;
    Ziffer_Max := 4;
    Ini_Msg_Win;
    Write   ('-> Bitte Hi-Word als 4-stellige Hex-Daten oder Abbruch mit <Esc>: ');

    for I := 1 to Ziffer_Max do Read_Str[I] := '_';
    Read_Str[0] := #4;
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

     Convert_To_Hex (Read_Str,Read_Wrd,Status);
     if Status then
      begin
       In_Data := Read_Wrd;
       In_Data := (In_Data shl 16)
      end
     else goto 1;

    {Low-Word einlesen}
    Ini_Msg_Win;
    Write   ('-> Bitte Low-Word als 4-stellige Hex-Daten oder Abbruch mit <Esc>: ');
    for I := 1 to Ziffer_Max do Read_Str[I] := '_';
    Read_Str[0] := #4;
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

     Convert_To_Hex (Read_Str,Read_Wrd,Status);
     if Status then
      begin
       Ask_Hex_LongInteger_Break := True;
       In_Data := In_Data or Read_Wrd
      end;
1:
  end; {Ask_Hex_LongInteger_Break}




end.  { UNIT DATECH.PAS}


-----------


    i := 0;
    repeat
     repeat
       Set_Text_win;
       transf_cnt:= transf_cnt+ 1;
       Fct.B.Fct := Wr_Fct_Code;
       Mil.Wr (i, Fct, MilErr);
       Read_Data := Get_Data;
       IF rd_timeout THEN
         Begin
           GotoXY(61,14); write(timout_rd:10);
           GotoXY(47,14); write('    ');
           mil.reset;
         End
       ELSE
         Begin
           if Single_Step then
            begin
             Disp_Data (Single_Step);
            end;
         End;

       IF (NOT rd_timeout) AND (read_data <> i) THEN
         Begin
           error_cnt := error_cnt + 1;
           GotoXY(18,14); write(error_cnt:10);
           Disp_Data (Single_Step);
         End;
       i := i + 1;
       if (i = $FFFF + 1) then i := 0;
{       if Single_Step then Ch := ReadKey; }

     until KeyPressed; { or (Ch = ' ');}

     if KeyPressed then Ch := ReadKey;
     if Ch = ' ' then
       begin
        Set_Text_Win;
        Single_Step := True;
        Disp_Data (Single_Step);
        Ini_Msg_Win;
        Write('Stop/Single Step mit <SPACE>, Loop mit <CR> ,  Ende mit [X]');
        repeat until KeyPressed;
       end;

     if Ch = Taste_Return then
       begin
        Single_Step := False;
        Set_Text_Win;
        GotoXY(18,11); TextColor(Red+128); write('  Loop!   ');
       end;
    until Ch in ['x','X'];



----
   IF rd_timeout THEN
     Begin
       GotoXY(61,14); write(timout_rd:10);
       GotoXY(47,14); write('    ');
       Mil.Reset;
     End;

   if Displ_Mode then Disp_Data (Displ_Mode);


   IF (NOT rd_timeout) AND (read_data <> i) THEN
     Begin
       error_cnt := error_cnt + 1;
       GotoXY(18,14); write(error_cnt:10);
       GotoXY(47,11); write(hex_word(i));
       TextColor(Red);
       GotoXY(47,14); write(hex_word(read_data));
       TextColor(Black);
     End;
