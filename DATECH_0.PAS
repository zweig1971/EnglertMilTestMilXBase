unit DATECH_0;      {Eine zusÑtzliche Datentechnik Library TURBO PASCAL V 7.0}
{                         Hier hauptsÑchlich Modulbus-Routinen
  Changes:
  19.11.97      Wegen Codegrenzen von Datech_1.pas neue Lib angelegt
  20.11.97      Byte u. Bits
  01.12.97      Mod24bit I/O Skalierung
  15.04.98      32-Bit WrRd-Test
  23.07.98      Identkodes erweitert
  05.11.98      Ifk_Online: Auf C0 H umgestellt
  12.11.98      ID_Check  aufgenommen
  23.12.98      ID-Check fÅr FG450.012 aktiviert
  07.09.99      Modul_wrRd32 external; AskIFK separat
  09.09.99      Z_Mod_Max auf 21 erhîht wegen Bildschirm lîschen
  29.11.00      Y: punkt 5: Wr-Rd-32bit IO: Ini_WrRd32_Win;
                Beim RÅcklesen von 32-Bit gilt andere Subadresse 04, 06
  20.02.01      Y: Punkt 4: Modulbus Wr/Rd mit variabler Subadresse
  01.03.01      Y: Punkt D: erweiterter Punkt5: Rd/Wr mit variabler Subadresse
  09.08.01      Pfeilrichtung in Mil_Ask_Mod geÑndert
                Y Punkt 5: Wr/Rd32 mit beliebiger Subadresse
}
{$S-}
 interface                 { Teil der UNIT-Deklaration }
 uses Crt32, Datech, Datech_1, Datech_2;   {graph, dos wegen cursor}

 type
  TID_Mode = (Modul, Slot);
  TID_Type = record
               Soll: Byte;
               Ist : Byte;
               Mode: TID_Mode;
             end;

  TIfk_IdErr = (NoIdErr, MilRd, IfkAdr, IfkID); {fÅr Modulbus}

  TSkal= record
           Mod_Id : Byte;
           FG_Nr  : String[9];
           Name   : String[16];
           SkalBit0_False:String[8];
           SkalBit0_True :String[8];
           SkalBit1_False:String[8];
           SkalBit1_True :String[8];
           SkalBit2_False:String[8];
           SkalBit2_True :String[8];
           SkalBit3_False:String[8];
           SkalBit3_True :String[8];
           SkalBit4_False:String[8];
           SkalBit4_True :String[8];
           SkalBit5_False:String[8];
           SkalBit5_True :String[8];
           SkalBit6_False:String[8];
           SkalBit6_True :String[8];
           SkalBit7_False:String[8];
           SkalBit7_True :String[8];
          end;

                 {Proceduren der Au·enwelt bekanntmachen}
procedure Menue_Base;
procedure Telefon;
procedure Mil_Ask_Mod;    {Frage User nach I/O-Modul-Adresse}
procedure Modul_Bus;
procedure Mil_Displ_IO_Modul;
procedure Check_ModBus_Ifk (Ifk_Nr: Byte; var Ret_Code: TIfk_IdErr);
procedure Ask_Ifc_Mod_Adr;
procedure Modul_WrRd32;
procedure Modul_APK;
function  ID_Check (Mod_Adr: TModAdr; var Ident: TID_Type): Boolean;


implementation                                    {Teil der UNIT-Deklaration}


  function ID_Check (Mod_Adr: TModAdr; var Ident: TID_Type): Boolean;
   var Id_Word : Word;
       MilErr  : TMilErr;
   begin
     ID_Check := False;                            {Default}
     Mil.Rd_ModBus (Id_Word, Mod_Adr, MilErr);     {Lese Modul-Id}
     if MilErr = No_Err then
      begin
       case Ident.Mode of
        Modul: begin                               {Richtiges Modul?}
                 Ident.Ist     := Hi(Id_Word);     {Hi-Byte=Kartenident}
                 if  Ident.Soll = Ident.Ist then  ID_Check := True;
               end;
        Slot : begin                               {Richtiger Slot?}
                 Ident.Ist     := Lo(Id_Word);     {Lo-Byte=VG-Leiste=Slot-ID}
                 if  Ident.Soll = Ident.Ist then  ID_Check := True; {Richtiger Slot?}
               end;
         end;
      end;
   end; {ID_Check}




 procedure Menue_Base;    {fester MenÅ-Teil: fÅr alle Programme gleich}
  begin
   Ini_Text_Win;
   GotoXY(5, 1);
   Writeln('*****************************  TEST-MENUE  ******************************');
   GotoXY(5, 2);
   Writeln('[A]<-- Welche IFK testen?                   Welche IFK am MIL-Bus? -->[0]');
   GotoXY(5, 3);
   Writeln('[B]<-- Lese IFK Status(C9)+En-Int,Pwrup   öberwache Online IFK(C0) -->[1]');
   GotoXY(5, 4);
   Writeln('[C]<-- Lese PC-Karte Status             Lese IFK Global-Status(CA) -->[2]');
   GotoXY(5, 5);
   Writeln('[D]<-- Lese PC-Karte Daten RCV-Reg.                                -->[3]');
   GotoXY(5, 6);
   Writeln('[E]<-* Lese IFK Daten (m. Fct-Code)        Lese IFK Status C0..C2  -->[4]');
   TextColor(Blue);               {Setze Schriftfarbe}
   GotoXY(5, 7);
   Writeln('[F]<-- Fct-Code- u. Piggy-ID Tabelle       Hex <--> Volt (+/-10V)  -->[5]');
   TextColor(Black);               {Setze Schriftfarbe}
   GotoXY(5, 8);
   Writeln('[G]<-- Sende Daten z. IFK ohne Fct-Code    Zeige Interrupt-Mask PC -->[6]');
   GotoXY(5, 9);
   Writeln('[H]<-- Sende Fct-Code zur IFK                                      -->[7]');
   GotoXY(5, 10);
   Writeln('[I]<-* Sende Daten zur IFK (m. Fct-Code)       Wr/Rd-Echo(0..FFFF) -->[8]');
   GotoXY(5, 11);
   Writeln('[J]<-* Sende/Lese User-Defin. Daten           IFK-Mode (IFA,FG,MB) -->[9]');
   GotoXY(5, 12);
   Writeln('[K]<-- Sende/Lese Daten (0..FFFF)                        Modul-Bus -->[Y]');
   GotoXY(5, 13);
   Write  ('[L]<-- Sende 1/2 Fct-Codes an 1/2 IFK-Adr             ');
   TextColor(Blue); Write ('Telefonliste'); TextColor(Black); Write(' -->[Z]');
  end;


 procedure Telefon;
  begin
   Ini_Text_Win;
   TextColor (Blue);
   GotoXY (20,01); Writeln (' Telefonliste mit wichtigen Service-Nummern');
   TextColor (Yellow);
   GotoXY (01,02); Write (' HKR-UNILAC: '); TextColor(Black); Write('2222');      Write('          ');  TextColor (Yellow);
                   Write (' HKR-SIS: ');    TextColor(Black); Write('2221/2244'); Write('             ');  TextColor (Yellow);
                   Write (' HKR-ESR: ');    TextColor(Black); Write('2245/2315'); WriteLn;
   TextColor (Blue);
   GotoXY (01,03); Writeln (' NAME                       TEL         PSA    RAUM         ABTEILUNG');
   TextColor (Yellow);
                   Write (' Behr, Karl Heinz           ');                         TextColor(Black);
                                                       Writeln('2732/2730   8621   2.272  OS      KC     '); TextColor(Yellow);
                   Write (' Bock, Walter               ');                         TextColor(Black);
                                                       Writeln('2357/2353   3571   2.111  Nord    EET    '); TextColor(yellow);
                   Write (' Breitenberger, Gerhard     ');                         TextColor(Black);
                                                       Writeln('2377        5271   2.146  Nord    EET    '); TextColor(yellow);
                   Write (' Dick, Gerhard              ');                         TextColor(Black);
                                                       Writeln('2357/2353   3521   2.111  Nord    EET    '); TextColor(yellow);
                   Write (' Fischer, Herbert           ');                         TextColor(Black);
                                                       Writeln('2357/2353   5301   2.007  SH4     EET    '); TextColor(yellow);
                   Write (' Hartmann, Rolf             ');                         TextColor(Black);
                                                       Writeln('2362               2.118  Nord    BELAB  '); TextColor(yellow);
                   Write (' Hechler, Ludwig            ');                         TextColor(Black);
                                                       Writeln('2391/2267          2.161  Nord    PR     '); TextColor(yellow);
                   Write (' Kainberger, Peter          ');                         TextColor(Black);
                                                       Writeln('2341/2267   3891   2.160  Nord    Fremdfirma');
TextColor(yellow);  Write (' Krause, Udo                ');                         TextColor(Black);
                                                       Writeln('2387        6301   2.158a Nord    PR    ');  TextColor(yellow);
                   Write (' KÅhn, Maria                ');                         TextColor(Black);
                                                       Writeln('2391/2267          2.161  Nord    BELAB  '); TextColor(yellow);
                   Write (' Matthîfer, Karl-Heinz      ');                         TextColor(Black);
                                                       Writeln('2357/2353   3551   2.111  Nord    EET    '); TextColor(yellow);
                   Write (' Ninov, Viktor              ');                         TextColor(Black);
                                                       Writeln('2735/2736          2.275  OS      KC     '); TextColor(yellow);
                   Write (' Ramakers, Heinz            ');                         TextColor(Black);
                                                       Writeln('2377        3771   2.146  Nord    EET    '); TextColor(yellow);
                   Write (' Rebscher, Michael          ');                         TextColor(Black);
                                                       Writeln('2362               2.118  Nord    BELAB  '); TextColor(yellow);
                   Write (' Riehl, GÅnther             ');                         TextColor(Black);
                                                       Writeln('2390               2.160  Nord    PR     '); TextColor(yellow);
                   Write (' Steck, Markus              ');                         TextColor(Black);
                                                       Writeln('2406               3.009  Nord    ESR    '); TextColor(yellow);
                   Write ('    "   (HKR)               ');                         TextColor(Black);
                                                       Writeln('2315                                     '); TextColor(yellow);
                   Write (' Steiner, Rudolf            ');                         TextColor(Black);
                                                       Writeln('2392        3691   2.165  Nord    BEL    '); TextColor(yellow);
                   Write (' Werkmann, Reinhold         ');                         TextColor(Black);
                                                       Writeln('2364               2.118  Nord    BELAB  '); TextColor(yellow);


   Ini_Msg_Win;
   Write ('                                                 Weiter mit beliebiger Taste!!');
   repeat until KeyEPressed;
  end; {Telefon}

   procedure Displ_Mod_Headline;
    begin
     Ini_Text_Win; TextColor(Blue);
     GotoXY(05,01); write('--- Finde IFC-Karten, Module und Identkodes (ModAdr '); TextColor(Yellow);
     Write ('0'); TextColor(Blue); Write(' nicht erlaubt!!) ---');
{     GotoXY(15,01); write('----- Finde IFC-Karten, Module und Identkodes -----');
}     Set_Color_Alarm;
     GotoXY(01,02); write('IFC-Adr Modul-Adr  Ident Card  VG   Skl MoAdr  EPLD Frei  Sta2 Sta1  Sta4 Sta3');
     Set_Color_Norm;
     TextColor(yellow);
     GotoXY(01,03); write(' [Hex]    [Hex]    [Dez]-<FE  FF>   <FC  FD>   <FA  FB>   <F8  F9>   <F6  F7>');
     Ini_Msg_Win;
     Write('Weiter mit  <SPACE>,  Ende mit [X]');
     Set_Text_Win;
    end;

   procedure Displ_Mod_Info (Ifc_Adr: Byte; Mod_Adr: Byte; Z_Mod: Byte);
    label 100;
    const S_Mod_ID_Dta  = 28;      {Default Spalte fÅr Modulidentdaten}
    var   IOsub_Adr    : Byte;
          Fct_11_Dta   : Word;
          S_Mod_Akt    : Byte;
          V            : Byte;
          Fct          : TFct;
          MilErr    : TMilErr;
          Id_Dez    : Byte;
    begin
     Set_Text_Win;
     if Mod_Adr = $FF then               {fÅr diese IFK kein Modul vorhanden}
      begin
        GotoXY(04,Z_Mod); write(Hex_Byte(Ifc_Adr));
        Goto 100;
      end;

     S_Mod_Akt := S_Mod_ID_Dta;
     GotoXY(04,Z_Mod); write(Hex_Byte(Ifc_Adr),'       ',Hex_Byte(Mod_Adr));
     IOsub_Adr := $FE;                           {Word-Adr fÅr Identdaten}

     for V := 1 to 5  do                         {Lese 3 Worte mit Identdaten}
      begin
        Fct.B.Adr  := Ifc_Adr;
        Fct_11_Dta:= (Mod_Adr*256) + IOsub_Adr;  {Modul-Adr ins Hibyte, Subadr Lowbyte}
        Fct.B.Fct  := Fct_Wr_Iob_Adr;
        Mil.Wr (Fct_11_Dta, Fct, MilErr);        {Adr zum I/O-Bus}

        Fct.B.Fct  :=  Fct_Rd_Iob_Dta;           {Lesen Daten von APL-IO-Bus}
        Mil.Rd (Read_Data, Fct, MilErr);

        if (IOsub_Adr = $FE) then   {ID-Daten}
         begin
          GotoXY(S_Mod_Akt-7,Z_Mod);
          Id_Dez := (Read_Data and $FF00) shr 8;
          Write (Id_Dez:3);
          if (Lo(Read_Data) = Hi(Read_Data)) then
            TextBackGround(Green)       {falls LP-ID = VG-ID grÅn anzeigen}
          else
            TextBackGround(White);
         end;

         GotoXY(S_Mod_Akt,Z_Mod);
         Write (hex_word(Read_Data));
         S_Mod_Akt := S_Mod_Akt + 11;
         IOsub_Adr := IOsub_Adr - 2;
         TextBackGround(White);
      end; {Displ_Mod_Info}
   100:
   end; {Displ_Mod_Info}

 procedure Mil_Displ_IO_Modul;
   LABEL 99;
   const  Z_Mod_Start = 4;
          Z_Mod_Max   = 21;{-Z_Mod_Start;} {Max. Zeilen TextWindow minus Start-Zeile}
   VAR
     error_cnt : LONGINT;
     MilErr    : TMilErr;
     Fct       : TFct;
     Rcv_Data  : Word;
     M         : Byte;
     I         : Byte;
     Mod_Zeile : Word;

     Ifb_Online: ARRAY [1..255] OF BOOLEAN;
     Ifb_Adr   : Word;
     Ifc_Total : Word;
     Mod_Total : Word;
     Mod_RetAdr: Byte;
     Id_Dez    : Byte;
     Mod_Err   : TOnlineErr;
     Life_Mode   : TLife_XY;

   Begin
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := 02;        {02;}
    Life_Mode.PosY    := 01;        {12;}
    Life_Mode.Time    := Life_Time_Slow;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}
    Life_Sign_XY (Life_Mode);

    transf_cnt := 0;
    error_cnt  := 0;
    timout_wr  := 0;
    Ifc_Total  := 0;
    Mod_Total  := 0;

    Ini_Text_Win;
    Mil_Ask_Ifc;
    Ini_Text_Win;
    Displ_Mod_Headline;
    Mod_Zeile := Z_Mod_Start;
    Ifb_Adr   := Ifc_Test_Nr;
    Std_Msg;
    Ch := Taste_Return;

    repeat
     if Ch = ' ' then
      begin
        Std_Msg;
        Single_Step := True;
        Set_Text_Win; {Damit énderungen bemerkt werden: Display lîschen!!}

        for I := Z_Mod_Start to (Z_Mod_Max)  do
         begin
          GotoXY (01, I); ClrEol;
         end;
        M := 0;
        repeat
         M := M + 1;                   {alle mîglichen Modul-Adr abfragen}
         Mil.Mod_Online (Ifb_Adr, M, Mod_RetAdr, Mod_Err);
         If Mod_Err = NoErr then
          begin
            Displ_Mod_Info (Ifb_Adr, M, Mod_Zeile);
            Mod_Zeile := Mod_Zeile + 1;
            if (Mod_Zeile mod 23) = 0 then Mod_Zeile := Z_Mod_Start;
          end;

         if M > $1F then
           begin
             M := 0;
             Mod_Zeile := Z_Mod_Start;
           end;
         until M=0;
       Life_Sign_XY (Life_Mode);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;
     if not Single_Step then
      begin
       M := 0;
       repeat
         M := M + 1;                   {alle mîglichen Modul-Adr abfragen}
         Mil.Mod_Online (Ifb_Adr, M, Mod_RetAdr, Mod_Err);
         If Mod_Err = NoErr then
          begin
            Displ_Mod_Info (Ifb_Adr, M, Mod_Zeile);
            Mod_Zeile := Mod_Zeile + 1;
            if (Mod_Zeile mod 23) = 0 then Mod_Zeile := Z_Mod_Start;
          end;

         if M > $1F then
           begin
             M := 0;
             Mod_Zeile := Z_Mod_Start;
           end;
        until M=0;
       Life_Sign_XY (Life_Mode);
       Set_Text_win;               {Damit énderungen bemerkt werden: }
       Mil.Timer2_Wait (50000);    {Display jedesmal lîschen!! }
       for I := Z_Mod_Start to (Z_Mod_Max) do
        begin
         GotoXY (01, I); ClrEol;
        end;
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
 99:  Cursor(True);
 end; {Mil_Displ_IO_Modul;}


 procedure Modul_Ident_List;
  const Z_Base = 6;
        Z_APK  = 18;
  begin
    Ini_Text_Win;
    TextColor(Yellow);
    GotoXY (18,Z_Base-4);  Write ('Liste Identkodes fÅr Module: ');
    TextColor(yellow);
    GotoXY (02,Z_Base-3);  Write (' v-- Kode --v            ');
    GotoXY (02,Z_Base-2);  Write (' [Dez]  [Hex]   Beschreibung ');
    TextColor(Blue);
    GotoXY (02,Z_Base-1);  Write (' 251     FB     IFK fÅr Modulbus   FG 380.211 Ident lesen mit Fct CC [H])!');
    GotoXY (02,Z_Base  );  Write (' 253     FD     IFK fÅr Modulbus   FG 450.012 Ident lesen mit Fct CC [H])!');
    TextColor(Black);
    GotoXY (02,Z_Base+2);  Write ('  31     1F     FG 450.310 Schaltkarte                ');
    GotoXY (02,Z_Base+3);  Write ('  32     20     FG 450.320 24-Bit Digital I/O         ');
    GotoXY (02,Z_Base+4);  Write ('  33     21     FG 450.330 24-Bit Status-Karte        ');
    GotoXY (02,Z_Base+5);  Write ('  34     22     FG 450.340 Analog I/O (+/-10V) mit Mux');
    GotoXY (02,Z_Base+6);  Write ('  35     23     FG 450.350 12-fach Event-Generator    ');
    GotoXY (02,Z_Base+7);  Write ('  36     24     FG 450.361 32-Bit I/O                 ');
    GotoXY (02,Z_Base+8);  Write ('  37     25     FG 450.370 Puls Zentrale Sequenzer    ');
    GotoXY (02,Z_Base+9);  Write ('  38     26     FG 450.380 GatePuls Generator         ');
    Ini_Msg_Win;
    Write ('Weiter mit <Space> ');
    Ch := NewReadKey;

    Ini_Text_Win;
    TextColor(Yellow);
    GotoXY (18,Z_Base-3);   Write ('Liste Identkodes fÅr Anpa·karten (APK): '); TextColor(yellow);
    GotoXY (02,Z_Base-1);   Write ('[Dez]  [Hex]   Beschreibung '); TextColor(Blue);
    GotoXY (02,Z_Base+1);   Write ('  xx     yy    FG 450.xxx Optokoppler                    ');

    Ini_Msg_Win;
    Write ('Weiter mit <Space> ');
    Ch := NewReadKey;
  end;

 procedure Check_ModBus_Ifk (Ifk_Nr: Byte; var Ret_Code: TIfk_IdErr);
   { IfkID_450012    = $FD spezielle IFK fÅr Modulbus: lesen mit Fct CC[H] }
   { ModBus_Ifk_Pigy = $06 :IFK 380.201 mit Modulbus-Piggy       Fct 8E[H]
     Achtung: dieses Piggy wird es nicht geben --> Ersatz FG380.210 bzw.211
    }
  var Id_Data     : Word;
      Id_Pigy_Data: Word;
      MilErr      : TMilErr;
      Fct         : TFct;
      Dummy_Adr   : Byte;
      OnlineErr   : TOnlineErr;
  begin
    Ret_Code   := NoIdErr;
    Fct.B.Adr  := Ifk_Nr;

    Mil.Ifc_Online (Ifk_Nr, Dummy_Adr, OnlineErr);  {IFK online?}
    if OnlineErr <> NoErr then
     begin
      Ret_Code := IfkAdr;
      Exit;
     end;

    Fct.B.Fct  := Fct_Rd_Ifk_ID;      {Lese Ident der IFK}
    Mil.Rd (Id_Data, Fct, MilErr);
    if MilErr = No_Err then
     begin
      if not ((Ifk_ID_450012_ModBus = Hi(Id_Data)) or (Ifk_ID_380211_ModBus = Hi(Id_Data))) then
         begin                  {keine modulbusfÑhige IFK vorhanden!}
           Ret_Code := IfkID;
           Exit;
         end; {if not IfkID_45001}
     end
    else
     begin                  {Mil Lesefehler}
       Ret_Code := MilRd;
     end;  {if MilErr bei Lesen des Ident der IFK}
  end; {Check_ModBus_Ifk}


 procedure Mil_Detect_IO_Modul;
   LABEL 99;
   const  Z_Mod_Start = 4;
          Z_Max       = 23;
   type
    TIfk_Online = record
                   Vorh : Boolean;
                   Mbus : Boolean;
                  end;
   VAR
     error_cnt : LONGINT;
     MilErr    : TMilErr;
     Fct       : TFct;
     Rcv_Data  : Word;
     Mod_Zeile : Word;
     Ifb_Online: array [1..255] of TIfk_Online;

     Ifc_Total : Word;
     Mod_Total : Word;
     Id_Dez    : Byte;
     RetAdr    : Byte;
     OnlineErr : TOnlineErr;
     Mod_RetAdr: Byte;
     Mod_Err   : TOnlineErr;
     Life_Mode : TLife_XY;
     Mod_Start : Byte;

   procedure Find_Modul;
    label 1;
    var
      M         : Byte;
      I,V       : Byte;
      Ifb_Adr   : Word;
      Rd_StatDta: Word;

    begin
      transf_cnt := 0;
      error_cnt  := 0;
      timout_wr  := 0;
      Ifc_Total  := 0;
      Mod_Total  := 0;

      for V := Z_Mod_Start to Z_Max do                 {Alte Werte lîschen}
        begin GotoXY (01,V); ClrEol; end;

      for ifb_adr := 1 to 255 do                       {Array lîschen}
       begin
        Ifb_Online[ifb_adr].Vorh := False;
        Ifb_Online[ifb_adr].Mbus := False;
       end;

      for Ifb_Adr := 1 TO 255 DO
       Begin
        Mil.Ifc_Online (Ifb_adr, RetAdr, OnlineErr);
        if OnlineErr = NoErr then
         begin
          Ifb_Online[Ifb_Adr].Vorh := TRUE;
          Ifc_Total := Ifc_Total + 1;
          {Feststellen, ob IFK modulbus-fÑhig ist}
          {Wenn mit Fct-Code C9 die Adresse zurÅckkommt, dann ist es eine
           alte IFK des Typs FG380.102 und ist nicht modulbusfÑhig}
          Fct.B.Adr := Ifb_Adr;
          Fct.B.Fct := Fct_Rd_Status;               {C9-Status}
          Mil.Rd (Rd_StatDta, Fct, MilErr);
          if MilErr = No_Err then
           begin                    {C9: nur bei IFK 380.20x ist Lo-Byte = Null}
            if Lo(Rd_StatDta) = 0 then
              begin                              {es kînnte eine FG380.20x sein}
                Fct.B.Fct := Fct_Rd_Stat0;                           {C0-Status}
                Mil.Rd (Rd_StatDta, Fct, MilErr);
                if MilErr = No_Err then
                  begin   {Status C0 prÅfen: bei FG380.20x ist Lo-Byte immer Adr}
                   if Lo(Rd_StatDta) = Ifb_Adr then
                    begin                            {ja, es ist FG 380.20x}
                      Fct.B.Fct := Fct_Rd_IFK_ID;    {IFK-Ident lesen}
                      Mil.Rd (Rd_StatDta, Fct, MilErr);
                      if (Hi(Rd_StatDta) = Ifk_ID_380211_ModBus) or
                         (Hi(Rd_StatDta) = Ifk_ID_450012_ModBus) then
                         ifb_online[ifb_adr].Mbus := True; {Hurra: Modulbuskarte!!}
                    end;  {if LByte = 0}
                  end;    {if MillErr}
              end;        {if LByte C9=0}
           end;           {if Error C9-Rd}
         end;
      end;

      Set_Text_Win;
      M := 0;
      Ifb_Adr := 1;
      Mod_Zeile := Z_Mod_Start;
      repeat                    {stelle alle IFK dar: mit oder ohne Modulbus}
         Set_Text_Win;
         if Ifb_Online [Ifb_Adr].Vorh then     {IFK ist online}
          begin
            if Ifb_Online [Ifb_Adr].Mbus then {IFK modulbusfÑhig: suche Module}
              begin
               Mod_Start := Mod_Total;         {Rette Anzahl Module}
               for M := ModAdr_Min to ModAdr_Max do  {alle erlaubten Modul-Adr abfragen}
                begin
                 Mil.Mod_Online (Ifb_Adr, M, Mod_RetAdr, Mod_Err);
                 If Mod_Err = NoErr then
                   begin
                     Mod_Total := Mod_Total + 1 ;
                     Displ_Mod_Info (Ifb_Adr, M, Mod_Zeile);
                     Mod_Zeile := Mod_Zeile + 1;
                     if (Mod_Zeile mod 21) = 0 then
                      begin
                        Mod_Zeile := Z_Mod_Start;
                        repeat until KeyPressed;      {Seitenweise anzeigen}
                        Ini_Text_Win;
                        Displ_Mod_Headline;
                        Ini_Msg_Win;
                        Write('Weiter mit  <SPACE>,  Ende mit [X]');
                        repeat until KeyPressed;
                        Ch := ReadKey;
                        if Ch in ['x','X'] then
                          begin
                           Ch := ' ';    {verhindert Abort}
                           goto 1;
                          end; {Ch in x}
                       end;    {if ModZeile 21}
                   end;        {if mod_err = noerr}
                end;   {for M = Min.. Max suche alle Module fÅr eine IFK}

          if Mod_Total = Mod_Start then   {An dieser IFK kein Modul}
            begin                         {nur die IFK-Adr aufs Display}
              Displ_Mod_Info (Ifb_Adr, $FF, Mod_Zeile);
              Mod_Zeile := Mod_Zeile + 1;
              if (Mod_Zeile mod 21) = 0 then
               begin
                 Mod_Zeile := Z_Mod_Start;
                 repeat until KeyPressed;      {Seitenweise anzeigen}
                 Ini_Text_Win;
                 Displ_Mod_Headline;
                 Ini_Msg_Win;
                 Write('Weiter mit  <SPACE>,  Ende mit [X]');
                 repeat until KeyPressed;
                 Ch := ReadKey;
                 if Ch in ['x','X'] then
                   begin
                    Ch := ' ';    {verhindert Abort}
                    goto 1;
                   end;
               end; {if ModZeile 21}
            end;  {if kein Modul an der IFK}
           end    {IFK = Modulbus-Karte}
          else
           begin
            Displ_Mod_Info (Ifb_Adr, $FF, Mod_Zeile);
            Mod_Zeile := Mod_Zeile + 1;
            if (Mod_Zeile mod 21) = 0 then
             begin
               Mod_Zeile := Z_Mod_Start;
               repeat until KeyPressed;      {Seitenweise anzeigen}
               Ini_Text_Win;
               Displ_Mod_Headline;
               Ini_Msg_Win;
               Write('Weiter mit  <SPACE>,  Ende mit [X]');
               repeat until KeyPressed;
               Ch := ReadKey;
               if Ch in ['x','X'] then
                 begin
                  Ch := ' ';    {verhindert Abort}
                  goto 1;
                 end;
             end; {if ModZeile 21}
            end; {IFK online und keine Modbus-Karte}
             Ifb_Adr := Ifb_Adr + 1;
           end {if ifb_online}
          else                           {diese IFK-Adresse nicht online}
           Ifb_Adr := Ifb_Adr + 1;       {nÑchste Adresse}
        until Ifb_Adr > $FF;
    1:
    end;  {Find_Modul}

  Begin                             {Mil_Detect_IO_Modul}
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := 2;
    Life_Mode.PosY    := 1;
    Life_Mode.Time    := Life_Time_Slow;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}

    Ini_Text_Win;
    Displ_Mod_Headline;
    Std_Msg;
    Ch := Taste_Return;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Set_Text_Win;
       Find_Modul;
       Life_Sign_XY (Life_Mode);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;
     if not Single_Step then
      begin
       Find_Modul;
       Life_Sign_XY (Life_Mode);
       Mil.Timer2_Wait (100000);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                   end;
        Taste_F12: begin
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
 End; {Mil_Detect_IO_Modul}


 PROCEDURE Mil_Ask_Mod;
  label 99;
  CONST start_zeile = 4;
        start_spalte =5;
        zeile_max    =22;
        spalte_offset=20;

  VAR answer : CHAR;
      Status : Boolean;
      Mod_total      : WORD;
      Mod_total_err  : WORD;
      Mod_Adr        : Integer;
      Mod_Online : ARRAY[0..ModAdr_Max] OF BOOLEAN;

      zeile,spalte: BYTE;
      hex_str    : STRING[10];
      i,n        : WORD;
      RetAdr     : Byte;
      OnlineErr  : TOnlineErr;
      Ende       : Boolean;
      Mod_RetAdr : Byte;

  begin
    Zeile := Start_Zeile;
    Spalte:= Start_Spalte;
    Mod_Total     := 0;
    Mod_Total_Err := 0;
    for I := 0 to ModAdr_Max do  Mod_Online [I] := False;

    Ini_Text_Win;
    Ini_Msg_Win;
    if Ifc_Test_Nr = 0 then
     begin
      Ini_Err_Win;
      Write ('ERROR: Nicht erlaubt IFK-Nr ', Hex_byte(Ifc_Test_Nr),' [Hex]!   Weiter mit <Space> ');
      Ch := NewReadKey;
      Exit;
     end;

    Mil.Ifc_Online (Ifc_Test_Nr, RetAdr, OnlineErr);
    if OnlineErr <> NoErr then
     begin
      Ini_Err_Win;
      Write ('ERROR: IFK-Nr ', Hex_Byte(Ifc_Test_Nr),' [Hex] meldet sich nicht!    Weiter mit <Space> ');
      Ch := NewReadKey;
      Exit;
     end
    else
     begin
      if RetAdr <> Ifc_Test_Nr then
       begin
        Ini_Err_Win;
        Write ('ERROR: Antwort v. falscher IFK-Adr!  '); TextColor(Yellow+128);
        Write('Soll: ', Hex_Byte(Ifc_Test_Nr),'[H]  Ist: ', Hex_Byte(RetAdr),'[H]');
        TextColor(Red); Write (' Weiter mit <Space> ');
        Ch := NewReadKey;
        Exit;
       end;
     end;

    {Die IFK ist also vorhanden und reagiert: jetzt vorhandene Module anzeigen}
    for Mod_Adr := 0 to ModAdr_Max do
      Begin
        Mil.Mod_Online (Ifc_Test_Nr, Mod_Adr, Mod_RetAdr, OnlineErr);
        If (OnlineErr = NoErr) and (Mod_Adr = Mod_RetAdr) then
         begin
            Mod_Online [Mod_Adr] := True;
            Set_Text_Win;  TextColor (Black);
            GotoXY (spalte, zeile);
            write(hex_Byte(Mod_Adr));                           {Solladresse}
            zeile := zeile + 1;
            IF (zeile > zeile_max )  THEN
             begin
               spalte := spalte + spalte_offset;
               zeile  := start_zeile;
             end;
            Mod_Total := Mod_Total + 1;
          end {if noerr}
         else
          begin   {Online-Error!!}
            if OnlineErr = AdrErr then
             begin
               Mod_Total_Err := Mod_Total_Err + 1;
               Ini_Err_Win;
               Write ('ERROR: Antwort v. falscher MOD-Adr!  '); TextColor(Yellow+128);
               Write('Soll: ', Hex_Byte(Mod_Adr),'[H]  Ist: ', Hex_Byte(Mod_RetAdr),'[H]');
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
    if  Mod_Total_Err <> 0 then
     begin
       TextColor(Red);
       GotoXY (03,01);
       Write ('Es melden sich ['); TextColor (Yellow);  Write (Mod_Total_Err); TextColor(Red);
       Write('] I/O-Karte(n) mit falscher Mod-Adresse!!!');
       TextColor(Black);
     end;

    GotoXY (03,02); TextColor(Blue);
    Write ('Es melden sich ['); TextColor (Yellow); Write (Mod_Total); TextColor(Blue);
    Write('] I/O-Karte(n) "ONLINE": '); TextColor (Black);

    if Mod_Total <> 0 then
     begin
       Mod_Adr := -1;
       repeat
        Mod_Adr     := Mod_Adr + 1;
        Mod_Test_Nr := Mod_Adr;
       until Mod_Online [Mod_Adr] or (Mod_Adr > ModAdr_Max);
     end
    else
     begin
      Ini_Err_Win;
      Write ('Keine I/O-Karte Online ! Hex-Adresse eingeben <J> oder Ende <CR> ');
      repeat until KeyEPressed;
      answer := NewReadKey;
      if answer in ['j','J'] then Mod_Test_Nr := Ask_Hex_Byte;
      goto 99;
     end;

    Ini_Msg_Win;
    Write ('Online Mod-Adr ['); TextColor(Red+128); Write (Hex_Byte(Mod_Test_Nr)); TextColor(Yellow);
    Write (']  Åbernehmen mit <CR>, Auswahl ',chr($19),' ',chr($18),' oder Hex-Eingabe <J>: ');
    answer := NewReadKey;

    repeat
       if KeyEPressed then answer := NewReadKey;
       if answer in ['j','J'] then
         begin
           Mod_Test_Nr := Ask_Hex_Byte;
           Ini_Msg_Win;
           Write ('Online Mod-Adr ['); TextColor(Red+128); Write (Hex_Byte(Mod_Test_Nr)); TextColor(Yellow);
           Write (']  Åbernehmen mit <CR>, Auswahl ',chr($19),' ',chr($18),' oder Hex-Eingabe <J>: ');
           answer :=  ' ';
         end;

       if answer = #0 then
        begin
         answer := NewReadKey;
         case ord (answer) of
         Taste_Pfeil_Ab  : begin
                             Mod_Adr := Mod_Test_Nr;
                             repeat
                              Mod_Adr := Mod_Adr + 1;
                              if Mod_Adr =  ModAdr_Max then Mod_Adr := ModAdr_Max;
                              if Mod_Online [Mod_Adr] then Mod_Test_Nr := Mod_Adr;
                             until Mod_Online [Mod_Adr] or (Mod_Adr = ModAdr_Max);
                             Ini_Msg_Win;
                             Write ('Online Mod-Adr ['); TextColor(Red+128); Write (Hex_Byte(Mod_Test_Nr)); TextColor(Yellow);
                             Write (']  Åbernehmen mit <CR>, Auswahl ',chr($19),' ',chr($18),' oder Hex-Eingabe <J>: ');
                            end;

          Taste_Pfeil_Auf  : begin
                             Mod_Adr := Mod_Test_Nr;
                             repeat
                              Mod_Adr := Mod_Adr - 1;
                              if Mod_Adr = -1 then Mod_Adr := 0;
                              if Mod_Online [Mod_Adr] then Mod_Test_Nr := Mod_Adr;
                             until Mod_online [Mod_Adr] or (Mod_Adr = 0);
                             Ini_Msg_Win;
                             Write ('Online Mod-Adr ['); TextColor(Red+128); Write (Hex_Byte(Mod_Test_Nr)); TextColor(Yellow);
                             Write (']  Åbernehmen mit <CR>, Auswahl ',chr($19),' ',chr($18),' oder Hex-Eingabe <J>: ');
                            end;
         end;  {Case}
     end;
    until answer = chr($0D);
  99:
 end;  {MIL_Ask_Mod}

 procedure Ask_Ifc_Mod_Adr;
  begin
   Ini_Text_Win;
   Mil_Ask_Ifc;      {globale IFK:         Ifc_Test_Nr}
   Mil_Ask_Mod;      {globale Modul-Karte: Mod_Test_Nr}
  end; {Test_Adr}

  procedure Ini_Online_Win;
   begin
    Window(73, 10, 79, 23);
    TextBackground(Cyan);
    TextColor(yellow);               {Setze Schriftfarbe}
    ClrScr;
   end;

  procedure Clr_Online_Win;
   begin
    Window(73, 10, 79, 23);
    TextBackground(White);
    TextColor(Black);               {Setze Schriftfarbe}
    ClrScr;
   end;
{x}
 procedure Show_Ifk_Online;
  var I        : Word;
      RetAdr   : Byte;
      OnlineErr: TOnlineErr;
  begin
    Ini_Online_Win;
    Write ('- IFK -'); Write ('online:'); TextColor(Black);

    for I := 1 to 255 do
     begin
       Mil.Ifc_Online (I, RetAdr, OnlineErr);
       if OnlineErr = NoErr then Writeln ('  ',(Hex_Byte (RetAdr)));
     end; {for}
  end; {Show_Ifk_Online}

 procedure Show_Mod_Online;
  var I         : Word;
      Mod_RetAdr: Byte;
      OnlineErr : TOnlineErr;
  begin
    Ini_Online_Win;
    Write ('IFK: '); TextColor(Blue); Write(Hex_Byte(Ifc_Test_Nr)); TextColor(yellow);
    Write ('Module '); Write ('online:');
    TextColor(Black);
    if Ifc_Test_Nr = 0 then
     begin
       Writeln;
       Write (' ??? ');
     end
    else
     begin
       for I := 0 to $1F do
        begin
          Mil.Mod_Online (Ifc_Test_Nr, I, Mod_RetAdr, OnlineErr);
          if OnlineErr = NoErr then Writeln ('  ',(Hex_Byte (Mod_RetAdr)));
        end; {for}
     end; {if Test=0}
  end; {Show_Mod_Online}

 procedure Show_Bit_Zuordnung (S_Base: Byte; ZBase: Byte);
  const S_Off = 38;
  begin
    Set_Text_Win; TextColor(Blue);
    GotoXY(S_Base, ZBase  );  Write ('    v------ Sub-Adr 0 (=K0) ------v   '); TextColor(Yellow);
    GotoXY(S_Base, ZBase+1);  Write ('      - Byte 4 -      - Byte 3 -      ');
    GotoXY(S_Base, ZBase+2);  Write ('    Bit         Bit Bit         Bit   '); TextColor(Yellow);
    GotoXY(S_Base, ZBase+3);  Write ('    31...........24 23...........16   ');
    TextColor(Blue);
    GotoXY(S_Off, ZBase  );   Write ('    v------ Sub-Adr 2 (=K1) ------v   '); TextColor(Yellow);
    GotoXY(S_Off, ZBase+1);   Write ('      - Byte 2 -      - Byte 1 -      ');
    GotoXY(S_Off, ZBase+2);   Write ('    Bit         Bit Bit         Bit   '); TextColor(Yellow);
    GotoXY(S_Off, ZBase+3);   Write ('    15...........08 07...........00   '); TextColor(Black);
  end;

 procedure Modul_Bit_Zuordnung;
  begin
    Ini_Text_Win;
    Show_Bit_Zuordnung (01, 10);   {Spalte, Zeile}
    Ini_Msg_Win;
    Write ('Weiter mit beliebiger Taste : ');
    Ch := NewReadKey;
    Ch:= '?';
  end; {Modul_Bit_Zuordnung}

 procedure  Ini_TastMod_Win;
  begin
   Window(02, 19, 70, 24); TextBackground(Green); TextColor(Yellow);
   Writeln ('v------------ WRITE -------------v  v----- READ -----v');
   Writeln ('F1: Mod-Adr        F5: Sub0  [Hex]  F9 : Mod-Adr      ');
   Writeln ('F2: Ifk-Adr        F6: Sub2  [Hex]  F10: Ifk-Adr      ');
   Writeln ('F3: Sub0 Ein/Aus   F7: Sub0/2 <-->  F11: Sub0  Ein/Aus');
   Write   ('F4: Sub2    "      F8: Wr-Data 0.0  F12: Sub2     "   ');
  end;


 type
  TModeSubAdr = record
                 WrMode : Boolean;  {Anzeigen und Schreiben: Ja/Nein}
                 WrSub0 : Boolean;
                 WrSub2 : Boolean;
                 RdSub0 : Boolean;
                 RdSub2 : Boolean;
               end;


  TCardAdr    = record
                 IfkNr  : Byte;
                 ModAdr : Byte;
                end;

  TCardSubAdr = record
                 IfkNr  : Byte;
                 ModAdr : Byte;
                 SubAdr : Byte;
                end;

  TBackColor = (Gruen, Rot, Weiss, Magent, Blau, Gelb, Blank, BlankLoop, OnlinErr);


 procedure Win_Bin_Xy (X: Byte; Y: Byte; WData: Word; BackColor: TBackColor; RdError: Boolean);
  var  Bit16_Strg: Str19;
  begin
   if BackColor = Gruen then TextBackground(Green);
   if BackColor = Rot   then TextBackground(Red);
   if BackColor = Weiss then TextBackground(White);
   if BackColor = Gelb  then TextBackground(Yellow);
   if BackColor = Blank then TextBackground(White);

   Hex_Bin_Str (WData, Bit16_Strg);
   GotoXY(X,Y);   TextColor(Black);
   case BackColor of
    Blank    :   Write ('                   ');
    OnlinErr :  begin
                 TextBackground(Red); TextColor(Yellow);
                 Write ('Modul Online Error!');
                 TextColor(Black);
                end;
    else
     Write(Bit16_Strg);
   end; {case}
  end; {Win_Bin_Xy}


 procedure Win_Hex4_Xy (X: Byte; Y: Byte; WData: Word; BackColor: TBackColor; RdError: Boolean);
  begin
   if BackColor = Gruen then TextBackground(Green);
   if BackColor = Rot   then TextBackground(Red);
   if BackColor = Weiss then TextBackground(White);
   if BackColor = Gelb  then TextBackground(Yellow);
   if BackColor = Blank then TextBackground(White);
   if BackColor = BlankLoop then TextBackground(White);
   GotoXY (X,Y);
   if (BackColor = Blank) or (BackColor = BlankLoop) then
     begin
      Write ('    ');
     end
   else
     begin
      if BackColor = Rot then TextColor(Yellow);
      if RdError then Write ('MIL?') else Write (Hex_Word(WData));
     end;
  end; {Win_Hex4_Xy}


 procedure Ini_WrRd32_Win;
  begin
   Window(65, 14, 79, 23);
   TextBackground(Cyan);
   TextColor(yellow);               {Setze Schriftfarbe}
   ClrScr; TextColor(magenta);
   Write (' WR/RD 32bit-IO'); TextColor(red);
   Write (' --------------');
   Write ('   Achtung:    '); TextColor(yellow);
   Write ('Mit extrn Kabel');
   Write (' RÅcklesen von ');
   Write ('gleicher Adress');
   Write ('mîglich:Sub 0,2');
   Write ('Default:Sub 4,6');
   Write ('Mit F3 Sub-Adr ');
   Write ('   wechseln!  ');
  end;

 procedure Clr_WrRd32_Win;
  begin
   Window(65, 14, 79, 23);
   TextBackground(White);
   ClrScr;
  end;

 procedure Modul_Konfig;
  const
   Z_BaseKonfig = 08;
   S_BaseKonfig = 02;
   Z_IfkAdr     = Z_BaseKonfig-5;
   S_IfkAdr     = S_BaseKonfig+18;
   S_HexWert    = S_IfkAdr    +16;
   S_FGNrTxt    = S_IfkAdr    +25;
   S_FGNr       = S_IfkAdr    +32;

   Z_ModAdr     = Z_IfkAdr+1;
   Z_ModId      = Z_IfkAdr+2;
   Z_ModSkal    = Z_IfkAdr+3;

   Z_InOut      = Z_BaseKonfig +4;
   S_InOut_Byt4 = S_BaseKonfig +4;
   S_InOut_Byt3 = S_BaseKonfig +20;
   S_InOut_Byt2 = S_BaseKonfig +40;
   S_InOut_Byt1 = S_BaseKonfig +56;


   ID_24Bit_IO  = $20;
   ID_24Bit_Sta = $21;
   ID_32Bit_IO  = $24;

   Skal_Null: TSkal =
   (Mod_Id : 0;
    FG_Nr  : '??       ';
    Name   : 'Undefiniert     ';
    SkalBit0_False: '        ';
    SkalBit0_True : '        ';
    SkalBit1_False: '        ';
    SkalBit1_True : '        ';
    SkalBit2_False: '        ';
    SkalBit2_True : '        ';
    SkalBit3_False: '        ';
    SkalBit3_True : '        ';
    SkalBit4_False: '        ';
    SkalBit4_True : '        ';
    SkalBit5_False: '        ';
    SkalBit5_True : '        ';
    SkalBit6_False: '        ';
    SkalBit6_True : '        ';
    SkalBit7_False: '        ';
    SkalBit7_True : '        ');

   Skal_24BitIO: TSkal =
   (Mod_Id : ID_24Bit_IO;
    FG_Nr  : 'FG450.320';
    Name   : '24-Bit I/O-Modul';
    SkalBit0_False: 'Output  ';
    SkalBit0_True : 'Input   ';
    SkalBit1_False: 'Output  ';
    SkalBit1_True : 'Input   ';
    SkalBit2_False: 'Output  ';
    SkalBit2_True : 'Input   ';
    SkalBit3_False: '        ';
    SkalBit3_True : '        ';
    SkalBit4_False: 'Hi-Aktiv';
    SkalBit4_True : 'Lo-Aktiv';
    SkalBit5_False: 'Hi-Aktiv';
    SkalBit5_True : 'Lo-Aktiv';
    SkalBit6_False: 'Hi-Aktiv';
    SkalBit6_True : 'Lo-Aktiv';
    SkalBit7_False: '        ';
    SkalBit7_True : '       ');

  Skal_24BitStat: TSkal =
   (Mod_Id : ID_24Bit_Sta;
    FG_Nr  : 'FG450.330';
    Name   : '24-Bit Status   ';
    SkalBit0_False: 'Output  ';
    SkalBit0_True : 'Input   ';
    SkalBit1_False: 'Output  ';
    SkalBit1_True : 'Input   ';
    SkalBit2_False: 'Output  ';
    SkalBit2_True : 'Input   ';
    SkalBit3_False: '        ';
    SkalBit3_True : '        ';
    SkalBit4_False: 'Hi-Aktiv';
    SkalBit4_True : 'Lo-Aktiv';
    SkalBit5_False: 'Hi-Aktiv';
    SkalBit5_True : 'Lo-Aktiv';
    SkalBit6_False: 'Hi-Aktiv';
    SkalBit6_True : 'Lo-Aktiv';
    SkalBit7_False: '        ';
    SkalBit7_True : '        ');


  Skal_32BitIO: TSkal =
   (Mod_Id : ID_32Bit_IO;
    FG_Nr  : 'FG450.361';
    Name   : '32-Bit I/O      ';
    SkalBit0_False: 'K0Mod0=0';
    SkalBit0_True : 'K0Mod0=1';
    SkalBit1_False: 'K0Mod1=0';
    SkalBit1_True : 'K0Mod1=1';
    SkalBit2_False: 'K1Mod0=0';
    SkalBit2_True : 'K1Mod0=1';
    SkalBit3_False: 'K1Mod1=0';
    SkalBit3_True : 'K1Mod1=1';
    SkalBit4_False: '32-Bit  ';
    SkalBit4_True : '16-Bit  ';
    SkalBit5_False: 'AnpkID=0';
    SkalBit5_True : 'AnpkID=1';
    SkalBit6_False: 'K0-16Out';
    SkalBit6_True : 'K0-16Inp';
    SkalBit7_False: 'K1-16Out';
    SkalBit7_True : 'K1-16Inp');

  var
   Life_Mode   : TLife_XY;
   User_In     : Word;

 const
  S_FTast_Min = 02;
  S_FTast_Max = 50;
  Z_Ftast_Min = 23;
  Z_Ftast_Max = 24;

  procedure  Ini_TastKonfig_Win;
   begin
    Window(S_FTast_Min, Z_Ftast_Min, S_FTast_Max, Z_Ftast_Max); TextBackground(Green); TextColor(Yellow);
    Write ('F1: Mod-Adr     F2: Ifk-Adr');
   end;

  procedure Show_Mod_Adr;
   begin
    Set_Text_Win;
    GotoXY (S_HexWert, Z_IfkAdr); Write(Hex_Byte(Ifc_Test_Nr));
    GotoXY (S_HexWert, Z_ModAdr); Write(Hex_Byte(Mod_Test_Nr));
   end; {Show_Mod_Adr}


  procedure Show_ModKonfig;
   var
    ModRdAdr  : TModAdr;
    Mod_Data  : Word;
    MilErr    : TMilErr;
    CardID    : Byte;
    ModSkal   : Byte;
    Modul_Skal: TSkal;

   begin
     Life_Sign_XY (Life_Mode);
     Set_Text_Win;
     ModRdAdr.AdrIfc  := Ifc_Test_Nr;
     ModRdAdr.AdrCard := Mod_Test_Nr;
     {Lese zuerst den Modul Ident}
     ModRdAdr.AdrSub  := ModSub_Adr_ID; {Hi-Byt: Card-ID (LP), Lo-Byt: VG-ID = SlotID (VG)}
     ModRdAdr.AdrMode := AdrNew;
     Mil.Rd_ModBus (Mod_Data, ModRdAdr, MilErr);
     GotoXY (S_HexWert,Z_ModId);
     if MilErr = No_Err then
      begin
        CardID := Hi(Mod_Data);
        Write (Hex_Byte(CardID)); Write ('    ');
      end
     else
      begin
        Write ('Rd Error');
      end;

     {Lese die Skalierung}
     ModRdAdr.AdrSub  := ModSub_Adr_ModAdr;  {Hi: Skal, Lo: ModAdr}
     ModRdAdr.AdrMode := AdrNew;
     Mil.Rd_ModBus (Mod_Data, ModRdAdr, MilErr);
     GotoXY (S_HexWert,Z_ModSkal);
     if MilErr = No_Err then
      begin
        case CardID of                        {Aufgrund Mod_ID -> Skalierung}
         ID_24Bit_IO  : Modul_Skal := Skal_24BitIO;
         ID_24Bit_Sta : Modul_Skal := Skal_24BitStat;
         ID_32Bit_IO  : Modul_Skal := Skal_32BitIO;
        else
         Modul_Skal := Skal_Null;
        end; {Case}
        ModSkal := Hi(Mod_Data);
        Write (Hex_Byte(ModSkal));  Write ('    ');
        GotoXY (S_FGNr, Z_ModId  ); TextColor(Black); Write (Modul_Skal.FG_Nr);
        GotoXY (S_FGNr, Z_ModSkal); TextColor(Black); Write (Modul_Skal.Name );
        GotoXY (S_InOut_Byt4, Z_InOut+0); ClrEol;
        GotoXY (S_InOut_Byt4, Z_InOut+1); ClrEol;

        {Die Skalierung ist gleich fÅr 24-BitI/O und 24BitStatus}
        if (CardID = ID_24Bit_IO) or (CardID = ID_24Bit_Sta) then
         begin
           GotoXY (S_InOut_Byt3, Z_InOut+0);   {In-Out zum Bildschirm}
           if BitTst (ModSkal,2) then Write (Modul_Skal.SkalBit2_True) else  Write (Modul_Skal.SkalBit2_False);
           GotoXY (S_InOut_Byt2, Z_InOut+0);
           if BitTst (ModSkal,1) then Write (Modul_Skal.SkalBit1_True) else  Write (Modul_Skal.SkalBit1_False);
           GotoXY (S_InOut_Byt1, Z_InOut+0);
           if BitTst (ModSkal,0) then Write (Modul_Skal.SkalBit0_True) else  Write (Modul_Skal.SkalBit0_False);

           GotoXY (S_InOut_Byt3, Z_InOut+1);   {Hi-Lo aktiv zum Bildschirm}
           if BitTst (ModSkal,6) then Write (Modul_Skal.SkalBit6_True) else  Write (Modul_Skal.SkalBit6_False);
           GotoXY (S_InOut_Byt2, Z_InOut+1);
           if BitTst (ModSkal,5) then Write (Modul_Skal.SkalBit5_True) else  Write (Modul_Skal.SkalBit5_False);
           GotoXY (S_InOut_Byt1, Z_InOut+1);
           if BitTst (ModSkal,4) then Write (Modul_Skal.SkalBit4_True) else  Write (Modul_Skal.SkalBit4_False);
         end; {if CardID = ID_24Bit_IO}

        if (CardID = ID_32Bit_IO) then   {Die Skalierung fÅr 32-Bit I/O}
         begin
           GotoXY (S_InOut_Byt4, Z_InOut+0);   {In-Out zum Bildschirm}
           if BitTst (ModSkal,7) then Write (Modul_Skal.SkalBit7_True) else  Write (Modul_Skal.SkalBit7_False);
           GotoXY (S_InOut_Byt2, Z_InOut+0);
           if BitTst (ModSkal,6) then Write (Modul_Skal.SkalBit6_True) else  Write (Modul_Skal.SkalBit6_False);

           GotoXY (S_InOut_Byt4, Z_InOut+1);
           if BitTst (ModSkal,3) then Write (Modul_Skal.SkalBit3_True) else  Write (Modul_Skal.SkalBit3_False);
           GotoXY (S_InOut_Byt3, Z_InOut+1);
           if BitTst (ModSkal,2) then Write (Modul_Skal.SkalBit2_True) else  Write (Modul_Skal.SkalBit2_False);

           GotoXY (S_InOut_Byt2, Z_InOut+1);
           if BitTst (ModSkal,1) then Write (Modul_Skal.SkalBit1_True) else  Write (Modul_Skal.SkalBit1_False);
           GotoXY (S_InOut_Byt1, Z_InOut+1);
           if BitTst (ModSkal,0) then Write (Modul_Skal.SkalBit0_True) else  Write (Modul_Skal.SkalBit0_False);

           GotoXY (S_InOut_Byt4, Z_InOut+2);
           if BitTst (ModSkal,4) then Write (Modul_Skal.SkalBit4_True) else  Write (Modul_Skal.SkalBit4_False);
         end; {if (CardID = ID_32Bit_IO)}
      end
     else
      begin
        Write ('Rd Error');
      end;
   end; {Show_ModKonfig}

  begin
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := S_IfkAdr - 2;
    Life_Mode.PosY    := Z_IfkAdr;
    Life_Mode.Time    := Life_Time_Slow;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}

   if Ifc_Test_Nr = 0 then Ask_Ifc_Mod_Adr;

  { Ask_Ifc_Mod_Adr;   }             {Ifc_Test_Nr u. Modul_Test_Nr erfragen}
   Ini_Text_Win; TextColor(yellow); GotoXY (7, 02);
   Write ('---- I/O-Konfiguration (Skalierung) fÅr 24- u. 32-Bit I/O-Module ----'); TextColor(yellow);
   TextColor(Blue);
   GotoXY (S_IfkAdr, Z_IfkAdr);  Write ('IFK-Adr   [H] : ');
   GotoXY (S_IfkAdr, Z_ModAdr);  Write ('Mod-Adr   [H] : ');
   GotoXY (S_IfkAdr, Z_ModId );  Write ('Mod-Ident [H] : ');
   GotoXY (S_IfkAdr, Z_ModSkal); Write ('Mod-Skal  [H] : ');

   GotoXY (S_FGNrTxt, Z_ModId );  Write ('FG-Nr: ');
   GotoXY (S_FGNrTxt, Z_ModSkal); Write ('Name : ');

   GotoXY(S_FTast_Min,Z_Ftast_Min-3); TextColor(Blue);
   Write('Belegung Funktionstasten: ');
   Show_Bit_Zuordnung (S_BaseKonfig,Z_BaseKonfig);            {Spalte, Zeile}
   Show_Mod_Adr;
   Ini_TastKonfig_Win;
   Cursor(False);
   Std_Msg;
   Ch := NewReadKey;

   repeat
    if Ch = ' ' then
     begin
      Std_Msg;
      Single_Step := True;
      Show_ModKonfig;
      repeat until KeyEPressed;
      Ch := NewReadKey;
     end;

    if Ch = #13 then Single_Step := False;
    if not Single_Step then
     begin
      Show_ModKonfig;
     end;

    if Ch = #0 then                  {Sonder-Tasten Abfrage}
     begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Show_Mod_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Test_Nr := User_In;
                       Show_Mod_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F2 : begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Ifc_Test_Nr := User_In;
                       Show_Mod_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F12: begin
                   end;
        Taste_Pfeil_Links : begin
                            end;
        Taste_Pfeil_Rechts: begin
                            end;
       end;  {Case}
     end;   {if Ch}
   if KeyEPressed then Ch := NewReadKey;
  until Ch in ['x','X'];
  Cursor(True);
  Ch := '?';
 end; {Modul_Konfig}

 { Definitionen fÅr Anpa·karten Tests}
 const
  Z_Stat_Win = 4;
  Z_Max      = 22;

  Z_Base = 1;
  Z_Text = Z_Base+1;
  Z_Data = Z_Text+1;
  Z_Mod_Start = 3;

  S_AdrIfk    = 02;
  S_AdrMod    = 05;
  S_LpID      = 09;
  S_SkalHex   = 13;
  S_K1ApkStat = 18;
  S_K1ApkID   = S_K1ApkStat+7;

  S_K0ApkStat = 30;
  S_K0ApkID   = S_K0ApkStat+7;

  S_SumStat = 45;
  S_Apk_Dta = 64;
  S_Stat_Win= 65;
  Apk_Bitnr = 05;       {zeigt in der Skalierung, ob APK vorhanden}


 procedure Ini_SumSts_Win;
  begin
   Window(S_Stat_Win, Z_Stat_Win, 79, 23);
   TextBackground(Cyan);
   TextColor(yellow);               {Setze Schriftfarbe}
   ClrScr; TextColor(Blue);
   Write (' SUM-Sts K1+K0 '); TextColor(yellow);
   Write ('15 K1Inr Drq-En');
   Write ('14 K1Inr Dry-En');
   Write ('13 K0Inr Drq-En');
   Write ('12 K0Inr Dry-En');
   Write ('11 INTR Drq-akt');
   Write ('10 INTR Dry-akt');
   Write ('09 K1 OBF  full');
   Write ('08 K1 IBF  full');
   Write ('               '); TextColor(yellow);
   Write ('               '); TextColor(yellow);
   Write ('07 K0 OBF  full');
   Write ('06 K0 IBF  full');
   Write ('05 32BitRdSqErr');
   Write ('04 32BitWrSqErr');
   Write ('03 frei        ');
   Write ('02 frei        ');
   Write ('01 K1 SumRdErr ');
   Write ('00 K1 SumRdErr');
  end;

 procedure Ini_KanalSts_Win;
  begin
   Window(S_Stat_Win, Z_Stat_Win, 79, 23);
   TextBackground(Cyan);
   TextColor(yellow);               {Setze Schriftfarbe}
   ClrScr; TextColor(Blue);
   Write ('KANAL-Sts K1/K0'); TextColor(yellow);
   Write ('15 INR   Drq-En');
   Write ('14 INR   Dry-En');
   Write ('13 DRQ   Aktiv ');
   Write ('12 DRY   Aktiv ');
   Write ('11 OBF   full  ');
   Write ('10 IBF   full  ');
   Write ('09 RdSeq Err 32');
   Write ('08 WrSeq Err 32');
   Write ('               '); TextColor(yellow);
   Write ('               '); TextColor(yellow);
   Write ('07 frei        ');
   Write ('06 frei        ');
   Write ('05 frei        ');
   Write ('04 frei        ');
   Write ('03 frei        ');
   Write ('02 frei        ');
   Write ('01 Rd ApkID Err');
   Write ('00 Rd Kanal Err');
  end;

 procedure Ini_Apk_Win;
  begin
   Window(1, 5, S_Apk_Dta, Z_Max);
   TextBackground(White);
   TextColor(Black);
   ClrScr;
  end;

 procedure Set_Apk_Win;
  begin
   Window(1, 5, S_Apk_Dta, Z_Max);
   TextBackground(White);
   TextColor(Black);
  end;

 const
  APK_ID_Max    = 2;
  Text_ZeilMax  = 20;

 type
  TSts_Mode   = (Sum, Kanal1, Kanal0);
  TAPK_ID_Text  = string[15];
  TAPK_Text_Ary = record
                   Ident   : Byte;
                   Text_Ary: array [1..Text_ZeilMax] of TAPK_ID_Text;
                  end;

  TAPK_Ary = array [1..APK_ID_Max] of TAPK_Text_Ary;

 const
  APK : TAPK_Ary =
(
(Ident   :      02;
 Text_Ary:('   APK-STATUS  ',
           'ID=02 [16xOut] ',
           '15 frei        ',
           '14 +15V int Err',
           '13 +15V ext Err',
           '12             ',
           '11             ',
           '10             ',
           '09             ',
           '08             ',
           '   SKALIERUNG  ',
           '  "1"       "0"',
           '7: In  K1  Out ',
           '6: In  K0  Out ',
           '5: APK-ID   VG ',
           '4: 16  Bit  32 ',
           '3: K1 Modebit1 ',
           '2: K1 Modebit0 ',
           '1: K0 Modebit1 ',
           '0: K0 Modebit0')),

(Ident:         03;
 Text_Ary:('   APK-STATUS  ',
           'ID=03 [16xIN]  ',
           '15 frei        ',
           '14 +15V int Err',
           '13 +15V ext Err',
           '12             ',
           '11             ',
           '10             ',
           '09             ',
           '08             ',
           '   SKALIERUNG  ',
           '  "1"       "0"',
           '7: In  K1  Out ',
           '6: In  K0  Out ',
           '5: APK-ID   VG ',
           '4: 16  Bit  32 ',
           '3: K1 Modebit1 ',
           '2: K1 Modebit0 ',
           '1: K0 Modebit1 ',
           '0: K0 Modebit0'))
); {Ende APK-Text_Array}

 var
  Sts_Mode_Displ    : TSts_Mode;


 procedure Displ_APK_Win (Apk_Idx: Byte);
  var I : Byte;
  begin
   Window(S_Stat_Win, Z_Stat_Win, 79, 23);
   TextBackground(Cyan);
   TextColor(yellow);               {Setze Schriftfarbe}
   ClrScr;
   if Apk_Idx in [1..APK_ID_Max] then
     begin
      for I:=1 to Text_ZeilMax do
       begin
        if I in [1,2,11,12] then TextColor(Blue) else TextColor(yellow);
        Write (APK[Apk_Idx].Text_Ary[I]);
       end;
     end; {if}
  end; {Displ_APK_Win}


 procedure Displ_Apk_Stat (Ifk_Apk: Byte; Mod_Apk: Byte; ID_Apk: Byte);
  var I : Byte;
      M : Byte;
      Mod_RetAdr: Byte;
      Mod_Err   : TOnlineErr;
      Mod_Zeile : Byte;
      Skal      : Word;
      RetAdr    : Byte;
      OnlineErr : TOnlineErr;
      Ifb_Online: ARRAY [1..255] OF BOOLEAN;
      Mod_Online: array [1..ModAdr_Max] of Boolean;

  procedure Displ_Mod_Stat (Adr_Ifk: Byte; Adr_Mod: Byte; Zeile_Mod: Byte);
   var RdDta  : Word;
       ReadAdr: TModAdr;
       MilErr : TMilErr;
       Bit16_String: Str19;
   begin                {Darstellung fÅr Daten eines Moduls}
     Set_Text_Win;
     GotoXY(S_AdrIfk,Zeile_Mod); write(Hex_Byte(Adr_Ifk));
     GotoXY(S_AdrMod,Zeile_Mod); write(Hex_Byte(Adr_Mod));
     {Lese Leiterplatten ID}
     ReadAdr.AdrIfc  := Adr_Ifk;
     ReadAdr.AdrCard := Adr_Mod;
     ReadAdr.AdrSub  := ModSub_Adr_ID;  {Hi-Byt: Card-ID  (LP), Lo-Byt: VG-ID = SlotID (VG)}
     ReadAdr.AdrMode := AdrNew;
     GotoXY(S_LpID ,Zeile_Mod);
     Mil.Rd_ModBus (RdDta, ReadAdr, MilErr);
     if (MilErr = No_Err) then write(Hex_Byte(Hi(RdDta))) else write('??');

     {Skalierung lesen u. gleichzeitig APK-ID auswerten}
     ReadAdr.AdrSub  := ModSub_Adr_ModAdr; {Hi-Byt: Skalierung (VG), Lo-Byt: Modul-Adr}
     GotoXY(S_SkalHex ,Zeile_Mod);
     Mil.Rd_ModBus (RdDta, ReadAdr, MilErr);
     if (MilErr = No_Err) then
      begin
       Skal := Hi(RdDta);
       write(Hex_Byte(Skal));
       {Default Werte fÅr APK-Status u. ID}
       GotoXY(S_K1ApkID   ,Zeile_Mod); write('  ');
       GotoXY(S_K1ApkStat ,Zeile_Mod); write('  ');
       GotoXY(S_K0ApkID   ,Zeile_Mod); write('  ');
       GotoXY(S_K0ApkStat ,Zeile_Mod); write('  ');

       if BitTst (Skal,Apk_Bitnr) then    {Bit5: APK mit ID+Status da}
        TextBackground(Green)             {zeigt Anwesenheit von APK}
       else
        TextBackground(White);

       {zuerst APK1}                  {unabhÑngig von APK's Status anzeigen}
       ReadAdr.AdrSub  := ModSub_Adr_Apk1ID;
       Mil.Rd_ModBus (RdDta, ReadAdr, MilErr);
       GotoXY(S_K1ApkID ,Zeile_Mod);
       if (MilErr = No_Err) then
        begin
        GotoXY(S_K1ApkStat ,Zeile_Mod); write(Hex_Byte(Hi(RdDta)));
        GotoXY(S_K1ApkID   ,Zeile_Mod); write(Hex_Byte(Lo(RdDta)));
        end
       else
        begin    {Mil Err!!}
         GotoXY(S_K1ApkStat ,Zeile_Mod);  write('??');
         GotoXY(S_K1ApkID   ,Zeile_Mod);  write('??');
        end; {if MilErr}

       {jetzt APK0}
       ReadAdr.AdrSub  := ModSub_Adr_Apk0ID;
       Mil.Rd_ModBus (RdDta, ReadAdr, MilErr);
       GotoXY(S_K0ApkID ,Zeile_Mod);
       if (MilErr = No_Err) then
        begin
        GotoXY(S_K0ApkStat ,Zeile_Mod); write(Hex_Byte(Hi(RdDta)));
        GotoXY(S_K0ApkID   ,Zeile_Mod); write(Hex_Byte(Lo(RdDta)));
        end
       else
        begin    {Mil Err!!}
         GotoXY(S_K0ApkStat ,Zeile_Mod);  write('??');
         GotoXY(S_K0ApkID   ,Zeile_Mod);  write('??');
        end; {if MilErr}
      end      {if kein MilErr}
     else
      write('??');

     {Summen-, K0- oder K1-Status lesen}
     TextBackground(White);
     case Sts_Mode_Displ of
      Sum   : ReadAdr.AdrSub:= ModSub_Adr_SumStat;
      Kanal0: ReadAdr.AdrSub:= ModSub_Adr_K0Stat;
      Kanal1: ReadAdr.AdrSub:= ModSub_Adr_K1Stat;
     end;

     ReadAdr.AdrMode := AdrNew;
     GotoXY(S_SumStat ,Zeile_Mod);
     Mil.Rd_ModBus (RdDta, ReadAdr, MilErr);
     if (MilErr = No_Err) then
      begin
        Hex_Bin_Str (RdDta,Bit16_String);
        Write (Bit16_String);
      end
     else
      begin
        Write (' ??????');
      end;
   end; {Displ_Mod_Stat}


  begin  {Displ_Apk_Stat}           {Online-PrÅfung und Zeilen verwaltung}
   Ini_Apk_Win;                     {Vor jedem update: Datenanzeige lîschen}
   ClrScr;
   Mod_Zeile := Z_Mod_Start;

   {Stelle fest, welche Ifk u. Module online sind}
   for I := 1 to 255 do        Ifb_Online[I] := False; {Clear Online-Arrays}
   for I := 1 to ModAdr_Max do Mod_Online[I] := False;
   for I := 1 to 255 do
    begin
     Mil.Ifc_Online (I, RetAdr, OnlineErr);
     if (OnlineErr=NoErr) and (I=RetAdr) then
      begin
        Ifb_Online[I] := True;
      end; {if ifk-Online}
    end;

   if Ifk_Apk = 0 then
    begin                     {fÅr alle online IFK darstellen}
      for I:=1 to 255 do
       begin
         if Ifb_Online[I] then
          begin
           if Mod_Apk = 0 then
            begin  {fÅr alle Module}
              for M := 1 to ModAdr_Max do
               begin
                 Mil.Mod_Online (I, M, Mod_RetAdr, Mod_Err);
                 if (Mod_Err=NoErr) and (M=Mod_RetAdr) then
                  begin
                    Displ_Mod_Stat (I, M, Mod_Zeile);
                    Mod_Zeile := Mod_Zeile + 1;
                    if (Mod_Zeile mod Z_Max) = 0 then Mod_Zeile := Z_Mod_Start;
                    if M = ModAdr_Max then Mod_Zeile := Z_Mod_Start;
                  end; {if Mod online}
               end;  {for M=1}
            end {if Mod_Apk=0}
           else
            begin {if Ifb_Online[I] : fÅr alle IFKs, aber bestimmtes Modul}
             M := Mod_Apk;
             Mil.Mod_Online (I, M, Mod_RetAdr, Mod_Err);
             if (Mod_Err=NoErr) and (M=Mod_RetAdr) then
              begin
                Displ_Mod_Stat (I, M, Mod_Zeile);
                Mod_Zeile := Mod_Zeile + 1;
                if (Mod_Zeile mod Z_Max) = 0 then Mod_Zeile := Z_Mod_Start;
                if M = ModAdr_Max then Mod_Zeile := Z_Mod_Start;
              end; {if Mod online}
            end;
{xxx}
          end; {if Ifk-Online}
       end; {for I=1 to 255}
    end     {if Ifk_Apk = 0}
   else
    begin                      {nur fÅr eine bestimmte IFK darstellen}
      I := Ifk_Apk;
      if Mod_Apk = 0 then
       begin  {fÅr alle Module}
         Set_Apk_Win;
         for M:= 0 to ModAdr_Max do      {alle erlaubten Modul-Adr abfragen}
          begin
            Mil.Mod_Online (I, M, Mod_RetAdr, Mod_Err);
            if Mod_Err = NoErr then
             begin
               Displ_Mod_Stat (I, M, Mod_Zeile);
               Mod_Zeile := Mod_Zeile + 1;
               if (Mod_Zeile mod Z_Max) = 0 then Mod_Zeile := Z_Mod_Start;
             end;
           if M = ModAdr_Max then Mod_Zeile := Z_Mod_Start;
          end;
       end
      else
       begin  {nur fÅr ein Modul}
         M := Mod_Apk;
         Mil.Mod_Online (I, M, Mod_RetAdr, Mod_Err);
         if Mod_Err = NoErr then
          begin
            Displ_Mod_Stat (I, M, Mod_Zeile);
            Mod_Zeile := Mod_Zeile + 1;
            if (Mod_Zeile mod Z_Max) = 0 then Mod_Zeile := Z_Mod_Start;
          end;
         if M = ModAdr_Max then Mod_Zeile := Z_Mod_Start;
       end;
    end; {if Ifk_Apk}
  end; {Displ_Apk_Stat}


 procedure Modul_APK;   {Zeige Status, Ident fÅr Anpasskarten}
 label 99;

 const
  Headline_SumSts = 'Summen-Status K1+K0';
  Headline_K0Sts  = '  Status Kanal 0   ';
  Headline_K1Sts  = '  Status Kanal 1   ';

  type
   THeadl_Mode = (Init, Update);

  var
   MilErr    : TMilErr;
   Fct       : TFct;
   Rcv_Data  : Word;
   Mod_Zeile : Word;

   Id_Dez    : Byte;
   RetAdr    : Byte;
   OnlineErr : TOnlineErr;
   Mod_RetAdr: Byte;
   Mod_Err   : TOnlineErr;
   Life_Mode : TLife_XY;
   User_In   : Integer;

   Ifk_Single_Displ: Byte;
   Mod_Single_Displ: Byte;
   Headline_DisplMode: THeadl_Mode;
   APK_Win_Index     : Byte;
   APK_Win_Aktiv     : Boolean;

 procedure Displ_Apk_Headline (Disp_Mode: THeadl_Mode);
  begin
   case Disp_Mode of
   Init : begin
            Ini_Text_Win; TextBackground(Cyan); TextColor(Blue);
            GotoXY(S_AdrIfk+1,Z_Base);    Write ('Adr');        TextBackground(White); Write(' '); TextBackground(Cyan);
            GotoXY(S_LpID-1,Z_Base);      Write ('LpID');       TextBackground(White); Write(' '); TextBackground(Cyan);
            GotoXY(S_SkalHex,Z_Base);     Write ('Ska');        TextBackground(White); Write(' '); TextBackground(Cyan);
            GotoXY(S_K1ApkStat-1,Z_Base); Write ('Sts-ApK1-ID');
            GotoXY(S_K0ApkStat-1,Z_Base); Write ('Sts-ApK0-ID');
            GotoXY(S_SumStat,Z_Base);
            case Sts_Mode_Displ of
             Sum   :  Write (Headline_SumSts);
             Kanal1:  Write (Headline_K0Sts);
             Kanal0:  Write (Headline_K1Sts);
            end;

            TextBackground(White); Write('  '); TextBackground(Cyan);
            GotoXY(01,Z_Text);
            TextBackground(White); TextColor(yellow);
            GotoXY(S_AdrIfk-1,Z_Text);    Write ('Ifk');
            GotoXY(S_AdrMod,Z_Text);      Write ('Mod');
            GotoXY(S_LpID,Z_Text);        Write ('[H]');
            GotoXY(S_SkalHex,Z_Text);     Write ('[H]');
            GotoXY(S_K1ApkStat-1,Z_Text); Write ('[H]');
            GotoXY(S_K1ApkID,  Z_Text);   Write ('[H]');
            GotoXY(S_K0ApkStat-1,Z_Text); Write ('[H]');
            GotoXY(S_K0ApkID,  Z_Text);   Write ('[H]');
            GotoXY(S_SumStat,Z_Text);     Write ('15......8 7.......0');

            Window(03, 24, 62, 24);
            TextBackground(Green);
            TextColor(Blue); Write ('F1:');    TextColor(Yellow); Write('Sts-Sum  ');
            TextColor(Blue); Write ('F2:');    TextColor(Yellow); Write('Sts-K0  ');
            TextColor(Blue); Write ('F3:');    TextColor(Yellow); Write('Sts-K1  ');
            TextColor(Blue); Write ('F4:');    TextColor(Yellow); Write('Ifk/Mod-Adr ');
            TextColor(Blue); Write (chr($18),chr($19),': '); TextColor(Yellow); Write('Apk-ID');

            Ini_Msg_Win;
            Write('Weiter mit  <SPACE>,  Ende mit [X]');
            Set_Text_Win;
          end; {case Init}
     Update:
          begin
            Set_Text_Win;
            GotoXY(S_SumStat,Z_Base); TextBackground(Cyan); TextColor(Blue);
            case Sts_Mode_Displ of
             Sum   :  Writeln (Headline_SumSts);
             Kanal0:  Writeln (Headline_K0Sts);
             Kanal1:  Writeln (Headline_K1Sts);
            end;
          end;
    end; {case}
  end;



  begin
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := 1;
    Life_Mode.PosY    := 1;
    Life_Mode.Time    := Life_Time_Slow;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}
    Ifk_Single_Displ  := 0;   {alle IFK anzeigen   }
    Mod_Single_Displ  := 0;   {alle Module anzeigen}
    Sts_Mode_Displ    := Sum;
    APK_Win_Index     := 1;
    APK_Win_Aktiv     := False;

    Ini_Text_Win;
    Displ_Apk_Headline (Init);
    Ini_SumSts_Win;

    Std_Msg;
    Ch := Taste_Return;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Displ_Apk_Stat (Ifk_Single_Displ, Mod_Single_Displ, 0);
       Life_Sign_XY (Life_Mode);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       Displ_Apk_Stat (Ifk_Single_Displ, Mod_Single_Displ, 0);
       Life_Sign_XY (Life_Mode);
       Mil.Timer2_Wait (60000);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Sts_Mode_Displ := Sum;
                    Displ_Apk_Headline (Update);
                    Ini_SumSts_Win;
                  end;
        Taste_F2 : begin
                    Sts_Mode_Displ := Kanal0;
                    Displ_Apk_Headline (Update);
                    Ini_KanalSts_Win;
                   end;
        Taste_F3 : begin
                    Sts_Mode_Displ := Kanal1;
                    Displ_Apk_Headline (Update);
                    Ini_KanalSts_Win;
                   end;
        Taste_F4:  begin
                    Ini_Err_Win;
                    Write ('IFK-Anzeige -> 0 = alle bzw. Nr. eingeben! Weiter mit <Space>, Skip <Esc>');
                    Ch := NewReadKey;
                    if not (Ch = chr(Taste_Esc)) then
                     if Read_Int (0,255, User_In) then Ifk_Single_Displ:= abs(User_In);

                    Ini_Err_Win;
                    Write ('Modul-Anzeige -> 0 = alle bzw. Nr. eingeben!  Weiter mit <Space>, Skip <Esc>');
                    Ch := NewReadKey;
                    if not (Ch = chr(Taste_Esc)) then
                     if Read_Int (0,255, User_In) then Mod_Single_Displ:= abs(User_In);

                    Std_Msg;
                    Ch := Taste_Return;
                   end;

        Taste_Pfeil_Auf: begin
                           if APK_Win_Aktiv then
                            begin        {falls aktiv: nÑchstes ID}
                             APK_Win_Index := APK_Win_Index+1;
                             if APK_Win_Index > APK_ID_Max then APK_Win_Index := 1;
                             Displ_APK_Win (APK_Win_Index);
                            end
                           else
                            begin         {falls inaktiv: altes ID}
                             Displ_APK_Win (APK_Win_Index);
                             APK_Win_Aktiv := True;
                            end;
                         end;
        Taste_Pfeil_Ab : begin
                           if APK_Win_Aktiv then
                            begin        {falls aktiv: nÑchstes ID}
                             APK_Win_Index := APK_Win_Index-1;
                             if APK_Win_Index = 0 then APK_Win_Index := APK_ID_Max;
                             Displ_APK_Win (APK_Win_Index);
                            end
                           else
                            begin         {falls inaktiv: altes ID}
                             Displ_APK_Win (APK_Win_Index);
                             APK_Win_Aktiv := True;
                            end;

                         end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
 99:  Cursor(True);
 end;  {Mil_Show_APK}

 procedure Modul_Rd_Sub;
  const
   Z_Tast_Win     = 22;
   Z_Ifk_Adr      = 6;
   Z_Mod_Adr      = Z_Ifk_Adr +1;
   Z_Sub_Adr      = Z_Mod_Adr +1;

   Z_Counter      =6;
   Z_Data_Hex     = 12;
   Z_Data_Bin     = Z_Data_Hex +1;
   Z_Data_Msb     = Z_Data_Bin +1;
   Z_Sub01        = Z_Data_Msb +1;
   Z_Online       = Z_Sub01 + 2;

   S_Counter      = 02;
   S_Ifk_Adr_Text = 30;
   S_Data_Text    = 05;
   S_Data_Hex     = 25;
   S_Data_Bin     = 18;

  var
   Mod_Card : TModAdr;
   User_In  : word;
   Life_Mode: TLife_XY;
   Check_ModOnline : Boolean;

  procedure Ini_Rd_Text;
   begin
    Set_Text_Win;  TextColor(Blue);
    GotoXY(25,Z_Ifk_Adr-3); Writeln ('Lese Daten von Subadresse');
    TextColor(Yellow);
    GotoXY(02,Z_Ifk_Adr-2); Writeln ('FÅr jeden Datentransfer kann ein Modul-Online-Test aktiviert werden [Ein/Aus]');

    TextColor(Blue);
    GotoXY(S_Ifk_Adr_Text,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Ifk_Adr_Text,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Ifk_Adr_Text,Z_Sub_Adr); write('Sub-Adr[H]: ');

    GotoXY(S_Data_Text, Z_Data_Hex);  write('Data [Hex]: ');
    GotoXY(S_Data_Text, Z_Data_Bin);  write('Data [Bin]: ');
    GotoXY(S_Data_Bin,  Z_Data_Msb);  write('MSB             LSB');
    GotoXY(S_Data_Bin,  Z_Sub01   );  write('-- Sub1    Sub 0 --');
    GotoXY(S_Data_Bin,  Z_Sub01   );  write('^Sub n    Sub n+1 ^');
   end;


  procedure  Ini_TastRdSub_Win;
   begin
    Set_Text_Win; TextColor(Blue);
    GotoXY(02,Z_Tast_Win-3); Write('Belegung F-Tasten: ');
    Window(02, Z_Tast_Win, 70, 24); TextBackground(Green); TextColor(Yellow);
    Writeln ('F1:Sub-Adr  F3:Ifk-Adr        F9 :OnlineTest E/A');
    Write   ('F2:Mod-Adr                                      ');
{    Writeln ('F1: Sub-Adr   F5: Mod-Adr   F9: IFK-Adr'); }
   end; {Ini_TastRdSub_Win}

  procedure Modbus_RdSub (RdCard: TModAdr);
   var
    Read_Dta  : Word;
    MilErr    : TMilErr;
    ModRetAdr : Byte;
    OnlineErr : TOnlineErr;

   begin
     Set_Text_Win;
     if Check_ModOnline then
      begin
        Mil.Mod_Online (RdCard.AdrIfc, RdCard.AdrCard, ModRetAdr, OnlineErr);
      end
     else
      begin               {No Online-Test. Stîrt Hardware Fehlersuche}
        OnlineErr := NoErr;
        ModRetAdr := RdCard.AdrCard;
      end;

     if  (OnlineErr <> NoErr) or (RdCard.AdrCard <> ModRetAdr) then
      begin   {Online Error}
        Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Blank,    True);
        Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , OnlinErr, True);
      end
     else
      begin
        Mil.Rd_ModBus (Read_Dta, RdCard, MilErr);
        if MilErr <> No_Err then
         begin  {Error!}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Rot,   True);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , Blank, True);
         end
        else
         begin  {kein Fehler}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Weiss, False);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Read_Dta, Weiss, False);
         end; {if MilErr}
      end; {if onlineErr}
   end; {Modbus_RdSub}

 procedure Display_Adr;
  begin
    Set_Text_Win; TextColor(Black);
    GotoXY(S_Ifk_Adr_Text+12, Z_Ifk_Adr); Write (Hex_byte(Mod_Card.AdrIfc));
    GotoXY(S_Ifk_Adr_Text+12, Z_Mod_Adr); Write (Hex_byte(Mod_Card.AdrCard));
    GotoXY(S_Ifk_Adr_Text+12, Z_Sub_Adr); Write (Hex_byte(Mod_Card.AdrSub));
  end;

  begin
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := S_Data_Text-2;
    Life_Mode.PosY    := Z_Data_Hex ;
    Life_Mode.Time    := Life_Time_Fast;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}

    Mil_Ask_Ifc;
    Mil_Ask_Mod;
    Ini_Text_Win;
    Ini_Rd_Text;
    Ini_TastRdSub_Win;

    Mod_Card.AdrIfc  := Ifc_Test_Nr;  {Defaultwerte setzen}
    Mod_Card.AdrCard := Mod_Test_Nr;
    Mod_Card.AdrSub  := 0;
    Mod_Card.AdrMode := AdrNew;
    Check_ModOnline  := False;

    Display_Adr;
    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Modbus_RdSub (Mod_Card);
       Life_Sign_XY (Life_Mode);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       Modbus_RdSub (Mod_Card);
       Life_Sign_XY (Life_Mode);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Card.AdrSub  := User_In;
                       Display_Adr;
                      end;
                    Std_Msg;
                   end;
          Taste_F2 : begin
                    Show_Mod_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Test_Nr      := User_In;
                       Mod_Card.AdrCard := Mod_Test_Nr;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F3 : begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Ifc_Test_Nr:= User_In;
                       Mod_Card.AdrIfc := Ifc_Test_Nr;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;

        Taste_F9 : begin
                    Set_Text_Win;
                    if Check_ModOnline then
                     begin
                      { TextColor(White);   }
                       GotoXY(S_Data_Bin, Z_Online);  write('                         ');
                       Check_ModOnline := False;
                     end
                    else
                     begin
                       TextColor(Red+128);
                       GotoXY(S_Data_Bin, Z_Online);  write('Modul Online Test aktiv!');
                       Check_ModOnline := True;
                     end;
                    end;
        Taste_F12: begin
                   end;
        Taste_Pfeil_Links : begin
                            end;
        Taste_Pfeil_Rechts: begin
                            end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  end; {Modul_Rd_Sub}

 procedure Modul_Wr_Sub;
  const
   Z_Tast_Win     = 22;
   Z_Ifk_Adr      = 6;
   Z_Mod_Adr      = Z_Ifk_Adr +1;
   Z_Sub_Adr      = Z_Mod_Adr +1;

   Z_Counter      =6;
   Z_Data_Hex     = 12;
   Z_Data_Bin     = Z_Data_Hex +1;
   Z_Data_Msb     = Z_Data_Bin +1;
   Z_Sub01        = Z_Data_Msb +1;
   Z_Online       = Z_Sub01 + 2;

   S_Counter      = 02;
   S_Ifk_Adr_Text = 30;
   S_Data_Text    = 05;
   S_Data_Hex     = 25;
   S_Data_Bin     = 18;

  var
   Mod_Card : TModAdr;
   User_In  : Word;
   Life_Mode: TLife_XY;
   Wr_Data  : Word;
   Check_ModOnline: Boolean;

  procedure Ini_Wr_Text;
   begin
    Set_Text_Win;
    TextColor(Blue);
    GotoXY(25,Z_Ifk_Adr-3); Writeln ('Schreibe Daten zur Subadresse');
    TextColor(Yellow);
    GotoXY(02,Z_Ifk_Adr-2); Writeln ('FÅr jeden Datentransfer kann ein Modul-Online-Test aktiviert werden [Ein/Aus]');

    TextColor(Blue);
    GotoXY(S_Ifk_Adr_Text,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Ifk_Adr_Text,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Ifk_Adr_Text,Z_Sub_Adr); write('Sub-Adr[H]: ');

    GotoXY(S_Data_Text, Z_Data_Hex);  write('Data [Hex]: ');
    GotoXY(S_Data_Text, Z_Data_Bin);  write('Data [Bin]: ');
    GotoXY(S_Data_Bin,  Z_Data_Msb);  write('MSB               LSB');
    GotoXY(S_Data_Bin,  Z_Sub01   );  write('-- Sub1 -- --Sub 0 --');
    GotoXY(S_Data_Bin,  Z_Sub01   );  write('^Sub n      Sub n+1 ^');

   end;


  procedure  Ini_TastRdSub_Win;
   begin
    Set_Text_Win; TextColor(Blue);
    GotoXY(02,Z_Tast_Win-3);        Write('Belegung F-Tasten: ');
    Window(02, Z_Tast_Win, 70, 24); TextBackground(Green); TextColor(Yellow);
    Writeln ('F1:Sub-Adr  F3:Ifk-Adr        F9 :OnlineTest E/A');
    Write   ('F2:Mod-Adr  [<- ->]:DataBits  F12:Daten [Hex]   ');
   end; {Ini_TastRdSub_Win}

  procedure Modbus_WrSub (WrCard: TModAdr; Write_Dta: Word);
   var
    MilErr    : TMilErr;
    ModRetAdr : Byte;
    OnlineErr : TOnlineErr;
   begin
     Set_Text_Win;
     if Check_ModOnline then
      begin
        Mil.Mod_Online (WrCard.AdrIfc, WrCard.AdrCard, ModRetAdr, OnlineErr);
      end
     else
      begin               {No Online-Test. Stîrt Hardware Fehlersuche}
        OnlineErr := NoErr;
        ModRetAdr := WrCard.AdrCard;
      end;

     if  (OnlineErr <> NoErr) or (WrCard.AdrCard <> ModRetAdr) then
      begin   {Online Error}
        Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Write_Dta, Blank,    True);
        Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , OnlinErr, True);
      end
     else
      begin
        Mil.Wr_ModBus (Write_Dta, WrCard, MilErr);
        if MilErr <> No_Err then
         begin  {Error!}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Write_Dta, Rot,   True);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , Blank, True);
         end
        else
         begin  {kein Fehler}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Write_Dta, Weiss, False);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Write_Dta, Weiss, False);
         end; {if MilErr}
      end; {if onlineErr}
   end; {Modbus_RdSub}

 procedure Display_Adr;
  begin
    Set_Text_Win; TextColor(Black);
    GotoXY(S_Ifk_Adr_Text+12, Z_Ifk_Adr); Write (Hex_byte(Mod_Card.AdrIfc));
    GotoXY(S_Ifk_Adr_Text+12, Z_Mod_Adr); Write (Hex_byte(Mod_Card.AdrCard));
    GotoXY(S_Ifk_Adr_Text+12, Z_Sub_Adr); Write (Hex_byte(Mod_Card.AdrSub));
  end;

  begin
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := S_Data_Text-2;
    Life_Mode.PosY    := Z_Data_Hex ;
    Life_Mode.Time    := Life_Time_Fast;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}

    Mil_Ask_Ifc;
    Mil_Ask_Mod;
    Ini_Text_Win;
    Ini_Wr_Text;
    Ini_TastRdSub_Win;

    Mod_Card.AdrIfc  := Ifc_Test_Nr;  {Defaultwerte setzen}
    Mod_Card.AdrCard := Mod_Test_Nr;
    Mod_Card.AdrSub  := 0;
    Mod_Card.AdrMode := AdrNew;
    Wr_Data := 0;
    Check_ModOnline  := False;

    Display_Adr;
    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Modbus_WrSub (Mod_Card, Wr_Data);
       Life_Sign_XY (Life_Mode);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       Modbus_WrSub (Mod_Card, Wr_Data);
       Life_Sign_XY (Life_Mode);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Card.AdrSub := User_In;
                       Mod_Card.AdrMode := AdrNew;
                       Display_Adr;
                      end;
                    Std_Msg;
                   end;
          Taste_F2 : begin
                    Show_Mod_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Test_Nr      := User_In;
                       Mod_Card.AdrCard := Mod_Test_Nr;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F3 : begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Ifc_Test_Nr:= User_In;
                       Mod_Card.AdrIfc := Ifc_Test_Nr;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F9 : begin
                    Set_Text_Win;
                    if Check_ModOnline then
                     begin
                      { TextColor(White);   }
                       GotoXY(S_Data_Bin, Z_Online);  write('                         ');
                       Check_ModOnline := False;
                     end
                    else
                     begin
                       TextColor(Red+128);
                       GotoXY(S_Data_Bin, Z_Online);  write('Modul Online Test aktiv!');
                       Check_ModOnline := True;
                     end;
                    end;
         Taste_F12: begin
                    if Ask_Hex_Break (User_In, Wrd) then
                      begin
                       Wr_Data:= User_In;
                      end;
                    Set_Text_Win;
                    Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Wr_Data, Weiss, False);
                    Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Wr_Data, Weiss, False);
                    Std_Msg;
                   end;
       Taste_Pfeil_Links : begin
                             Set_Text_Win;
                             if   Wr_Data  = 0 then Wr_Data := $1
                             else Wr_Data := Wr_Data shl 1;
                             Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Wr_Data, Weiss, False);
                             Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Wr_Data, Weiss, False);
                                      end;  {Taste_Pfeil_Links}
       Taste_Pfeil_Rechts: begin
                             Set_Text_Win;
                             if   Wr_Data  = 0 then Wr_Data := $1
                             else Wr_Data := Wr_Data shr 1;
                             Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Wr_Data, Weiss, False);
                             Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Wr_Data, Weiss, False);
                           end;  {Taste_Pfeil_Rechts}
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  end; {Modul_Wr_Sub}


 procedure Modul_EPLD_PwrUp;
  const
   Z_Tast_Win     = 22;
   Z_Ifk_Adr      = 6;
   Z_Mod_Adr      = Z_Ifk_Adr +1;
   Z_Sub_Adr      = Z_Mod_Adr +1;

   Z_Counter      =6;
   Z_Data_Hex     = 12;
   Z_Data_Bin     = Z_Data_Hex +1;
   Z_Data_Msb     = Z_Data_Bin +1;
   Z_Sub01        = Z_Data_Msb +1;
   Z_Online       = Z_Sub01 + 2;

   S_Counter      = 02;
   S_Ifk_Adr_Text = 30;
   S_Data_Text    = 05;
   S_Data_Hex     = 25;
   S_Data_Bin     = 18;

  var
   Mod_Card : TModAdr;
   User_In  : word;
   Life_Mode: TLife_XY;
   Check_ModOnline : Boolean;

  procedure Ini_Rd_Text;
   begin
    Set_Text_Win;  TextColor(Blue);
    GotoXY(15,Z_Ifk_Adr-3);
    Writeln ('Lese EPLD-Version + Status-Bits (z.B. PowerUp)');

    TextColor(Blue);
    GotoXY(S_Ifk_Adr_Text,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Ifk_Adr_Text,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Ifk_Adr_Text,Z_Sub_Adr); write('Sub-Adr[H]: ');

    GotoXY(S_Data_Text, Z_Data_Hex);  write('Data [Hex]: ');
    GotoXY(S_Data_Text, Z_Data_Bin);  write('Data [Bin]: ');
    GotoXY(S_Data_Bin,  Z_Data_Msb);  write('MSB             LSB');
    GotoXY(S_Data_Bin,  Z_Sub01   );  write('-- Sub1    Sub 0 --');
    GotoXY(S_Data_Bin,  Z_Sub01   );  write('^Sub n    Sub n+1 ^');
   end;


  procedure  Ini_TastRdSub_Win;
   begin
    Set_Text_Win; TextColor(Blue);
    GotoXY(02,Z_Tast_Win-3); Write('Belegung F-Tasten: ');
    Window(02, Z_Tast_Win, 70, 24); TextBackground(Green); TextColor(Yellow);
    Writeln ('F1: Mod-Adr   F2: Ifk-Adr   F9: Reset PwrUp-Bit');
    Write   ('                                               ');
   end; {Ini_TastRdSub_Win}

 procedure Clear_EPLDSts_Win;
  begin
   Window(S_Stat_Win, Z_Stat_Win, 79, 23);
   TextBackground(White);
   ClrScr;
  end;

 procedure Ini_EPLDSts_Win;
  begin
   Window(S_Stat_Win, Z_Stat_Win, 79, 23);
   TextBackground(Cyan);
   TextColor(yellow);               {Setze Schriftfarbe}
   ClrScr; TextColor(Blue);
   Write ('   MODUL-EPLD  ');
   Write (' Version+Status'); TextColor(yellow);
   Write ('15             ');
   Write ('14             ');
   Write ('13             ');
   Write ('12             ');
   Write ('11 Vers. Bit 8 ');
   Write ('10  "        4 ');
   Write ('09  "        2 ');
   Write ('08 Vers. Bit 1 ');
   Write ('               '); TextColor(yellow);
   Write ('               '); TextColor(yellow);
   Write ('07             ');
   Write ('06             ');
   Write ('05             ');
   Write ('04             ');
   Write ('03 frei        ');
   Write ('02 frei        ');
   Write ('01 frei        ');
   Write ('00 "1" PowerUp');
  end;

  procedure Modbus_RdSub (RdCard: TModAdr);
   var
    Read_Dta  : Word;
    MilErr    : TMilErr;
    ModRetAdr : Byte;
    OnlineErr : TOnlineErr;

   begin
     Set_Text_Win;
     Mil.Mod_Online (RdCard.AdrIfc, RdCard.AdrCard, ModRetAdr, OnlineErr);

     if  (OnlineErr <> NoErr) or (RdCard.AdrCard <> ModRetAdr) then
      begin   {Online Error}
        Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Blank,    True);
        Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , OnlinErr, True);
      end
     else
      begin
        Mil.Rd_ModBus (Read_Dta, RdCard, MilErr);
        if MilErr <> No_Err then
         begin  {Error!}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Rot,   True);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , Blank, True);
         end
        else
         begin  {kein Fehler}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Weiss, False);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Read_Dta, Weiss, False);
         end; {if MilErr}
      end; {if onlineErr}
   end; {Modbus_RdSub}

  procedure Modul_ClrPwrup (RdCard: TModAdr);
   var
    Read_Dta  : Word;
    Wr_Dta    : Word;
    MilErr    : TMilErr;
    ModRetAdr : Byte;
    OnlineErr : TOnlineErr;

   begin
     Set_Text_Win;
     Mil.Mod_Online (RdCard.AdrIfc, RdCard.AdrCard, ModRetAdr, OnlineErr);
     if  (OnlineErr <> NoErr) or (RdCard.AdrCard <> ModRetAdr) then
      begin   {Online Error}
        Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Blank,    True);
        Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , OnlinErr, True);
      end
     else
      begin
        Mil.Rd_ModBus (Read_Dta, RdCard, MilErr);
        if MilErr <> No_Err then
         begin  {Error!}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Rot,   True);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, 0       , Blank, True);
         end
        else
         begin  {kein Fehler}
           Win_Hex4_Xy (S_Data_Hex, Z_Data_Hex, Read_Dta, Weiss, False);
           Win_Bin_XY  (S_Data_Bin, Z_Data_Bin, Read_Dta, Weiss, False);
           {erst ab EPLD-Version 4 gibt es das Powerup-Bit}
           Wr_Dta := BitSet (Read_Dta, 0);  {Daten zurÅckschreiben}
           Mil.Wr_ModBus (Wr_Dta, RdCard, MilErr);
         end; {if MilErr}
      end; {if onlineErr}
   end; {Modbus_RdSub}


 procedure Display_Adr;
  begin
    Set_Text_Win; TextColor(Black);
    GotoXY(S_Ifk_Adr_Text+12, Z_Ifk_Adr); Write (Hex_byte(Mod_Card.AdrIfc));
    GotoXY(S_Ifk_Adr_Text+12, Z_Mod_Adr); Write (Hex_byte(Mod_Card.AdrCard));
    GotoXY(S_Ifk_Adr_Text+12, Z_Sub_Adr); Write (Hex_byte(Mod_Card.AdrSub));
  end;

  begin
    Life_Mode.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
    Life_Mode.PosX    := S_Data_Text-2;
    Life_Mode.PosY    := Z_Data_Hex ;
    Life_Mode.Time    := Life_Time_Fast;
    Life_Mode.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}

    Mil_Ask_Ifc;
    Mil_Ask_Mod;
    Ini_Text_Win;
    Ini_Rd_Text;
    Ini_TastRdSub_Win;

    Mod_Card.AdrIfc  := Ifc_Test_Nr;  {Defaultwerte setzen}
    Mod_Card.AdrCard := Mod_Test_Nr;
    Mod_Card.AdrSub  := ModSub_Adr_EPLD;
    Mod_Card.AdrMode := AdrNew;
    Check_ModOnline  := False;

    Display_Adr;
    Ini_EPLDSts_Win;
    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Modbus_RdSub (Mod_Card);
       Life_Sign_XY (Life_Mode);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       Modbus_RdSub (Mod_Card);
       Life_Sign_XY (Life_Mode);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
{        Taste_F1 : begin
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Card.AdrSub  := User_In;
                       Display_Adr;
                      end;
                    Std_Msg;
                   end;
}          Taste_F1 : begin
                    Clear_EPLDSts_Win;
                    Show_Mod_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Mod_Test_Nr      := User_In;
                       Mod_Card.AdrCard := Mod_Test_Nr;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_EPLDSts_Win;
                    Std_Msg;
                   end;
        Taste_F2 : begin
                    Clear_EPLDSts_Win;
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       Ifc_Test_Nr:= User_In;
                       Mod_Card.AdrIfc := Ifc_Test_Nr;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_EPLDSts_Win;
                    Std_Msg;
                   end;

        Taste_F9 : begin
                    Modul_ClrPwrup (Mod_Card);
                    Modbus_RdSub (Mod_Card);
                    Life_Sign_XY (Life_Mode);
                   end;
        Taste_F12: begin
                   end;
        Taste_Pfeil_Links : begin
                            end;
        Taste_Pfeil_Rechts: begin
                            end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  end; {Modul_EPLD_PwrUp}


 procedure Modul_WrRd; {mit beliebiger Subadresse fÅr Read bzw. Write!!}
  label 99;            {Die 1. 16-Bit auf Sub_Base, 2. 16-Bit auf Sub_Base+2}
  const
   Z_Info     = 01;
   S_Info     = 15;
   Z_Data     = 9;
   S_Data     = 04;
   Z_Sub0_Hex = Z_Data+2;
   Z_Sub2_Hex = Z_Sub0_Hex+1;
   Z_Sub0_Bin = Z_Sub2_Hex+2;
   Z_Sub2_Bin = Z_Sub0_Bin+1;
   Z_Sub0_Life= Z_Sub0_Hex;
   Z_Sub2_Life= Z_Sub2_Hex;
   Z_WrData   = Z_Data+2;
   Z_RdData   = Z_Data+5;

   Z_Ifk_Adr   = Z_Data -3;
   Z_Mod_Adr   = Z_Data -2;
   Z_Sub_Adr   = Z_Data -1;

   S_Ifk_WrAdr = 40;
   S_Mod_WrAdr = S_Ifk_WrAdr;
   S_Sub_WrAdr = S_Ifk_WrAdr;

   S_Ifk_RdAdr = S_Ifk_WrAdr+18;
   S_Mod_RdAdr = S_Ifk_RdAdr;
   S_Sub_RdAdr = S_Ifk_RdAdr;

   S_WrData_Hex= S_Ifk_WrAdr-6;
   S_RdData_Hex= S_Ifk_RdAdr-7;
   S_WrData_Bin= S_Ifk_WrAdr-17;
   S_RdData_Bin= S_Ifk_RdAdr-12;

   Z_RdLife    = Z_Data;
   S_RdLife    = S_Mod_RdAdr-12;
   Z_WrLife    = Z_Data;
   S_WrLife    = S_Mod_WrAdr-12;

  type TWrRd = (Wr, Rd);

  var User_In     : Word;
      Mod_Adr     : Byte;
      Sub_Adr     : Byte;
      Sub_Adr_Wr : Byte;    {Basis-SubAdr fÅr 1. 16-Bit schreiben; 2. 16-Bit: Basis-SubAdr + 2}
      Sub_Adr_Rd : Byte;    {Basis-SubAdr fÅr 1. 16-Bit lesen;     2. 16-Bit: Basis-SubAdr + 2}

      Rd_Sub0_Err : LONGINT;
      Rd_Sub2_Err : LONGINT;
      Ifk_AdrWr   : Byte;
      Ifk_AdrRd   : Byte;
      Mod_AdrWr   : Byte;
      Mod_AdrRd   : Byte;
      Mode_SubAdr : TModeSubAdr;
      RModCrd     : TCardSubAdr;
      WModCrd     : TCardSubAdr;
      Wr_Data_Sub0: Word;
      Wr_Data_Sub2: Word;
      Shift_Mode_Sub0 : Boolean;

   procedure Display_Adr;
    begin
     Set_Text_Win;
     TextColor(Black);
     GotoXY(S_Ifk_WrAdr,Z_Ifk_Adr);   write(Hex_Byte(WModCrd.IfkNr));
     GotoXY(S_Mod_WrAdr,Z_Mod_Adr);   write(Hex_Byte(WModCrd.ModAdr));
     GotoXY(S_Sub_WrAdr,Z_Sub_Adr);   write(Hex_Byte(Sub_Adr_Wr));
     GotoXY(S_Ifk_RdAdr,Z_Ifk_Adr);   write(Hex_Byte(RModCrd.IfkNr));
     GotoXY(S_Mod_RdAdr,Z_Mod_Adr);   write(Hex_Byte(RModCrd.ModAdr));
     GotoXY(S_Sub_RdAdr,Z_Sub_Adr);   write(Hex_Byte(Sub_Adr_Rd));
    end;

   procedure Display_Ini;
   begin
    Ini_Text_Win;        TextColor(Yellow);
    GotoXY(05,Z_Info  ); write('--- Modul-Bus Daten auf beliebige Sub-Adr n+0 u. n+2 schreiben/lesen ---');
    TextColor(Blue);
    GotoXY(08,Z_Info+1); write('Setze Modul-Adr mit Fct-Code 11 [H], Wr/Rd mit Fct-Code 10/90 [H]');
    GotoXY(17,Z_Info+2); write('     v--SubAdr[+0] =K0--v   v--SubAdr[+2] =K1--v     ');
    GotoXY(17,Z_Info+3); write('[Bit 31................16   15................00 Bit]');
    TextColor(Blue);
    GotoXY(S_Ifk_WrAdr-12,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Mod_WrAdr-12,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Sub_WrAdr-12,Z_Sub_Adr); write('Sub-Adr[H]: ');

    GotoXY(S_Ifk_RdAdr-12,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Mod_RdAdr-12,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Sub_RdAdr-12,Z_Sub_Adr); write('Sub-Adr[H]: ');
    Display_Adr;

    TextColor(Blue);
    GotoXY(S_Data,Z_Data  );    write('                           '); TextColor(Brown);
    writeln('Write-Data        Read-Data               ');
    GotoXY(S_Data,Z_Data+1);    writeln('                              [Hex]            [Hex]'); TextColor(Blue);
    GotoXY(S_Data,Z_Sub0_Hex);  writeln('Sub-Adr[0]: ');
    GotoXY(S_Data,Z_Sub2_Hex);  writeln('Sub-Adr[2]: ');

    {Byte-Bezeichnung enzeigen}
    GotoXY(S_RdData_Hex+5,Z_Sub0_Hex); writeln('<Byte3');
    GotoXY(S_RdData_Hex+5,Z_Sub2_Hex); writeln('<Byte1');
    GotoXY(S_RdData_Hex-7,Z_Sub0_Hex); writeln('Byte4>');
    GotoXY(S_RdData_Hex-7,Z_Sub2_Hex); writeln('Byte2>');

    TextColor(Blue);
    GotoXY(S_Data,Z_Sub0_Hex);  writeln('Sub-Adr[0]: ');
    GotoXY(S_Data,Z_Sub2_Hex);  writeln('Sub-Adr[2]: ');

    GotoXY(S_WrData_Bin, Z_Sub2_Bin+1); writeln('MSB             LSB');
    GotoXY(S_RdData_Bin, Z_Sub2_Bin+1); writeln('MSB             LSB');
   end;

  procedure Life_Sign_ModWrRd (DispMode: TWrRd);
   var Wr_Param, Rd_Param: TLife_XY;
   begin
    if DispMode = Wr then
     begin                    GotoXY(S_RdLife ,Z_RdLife);
       Wr_Param.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
       Wr_Param.PosX    := S_WrLife;;
       Wr_Param.PosY    := Z_WrLife;
       Wr_Param.Time    := Life_Time_Super;
       Wr_Param.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}
       Life_Sign_XY (Wr_Param);
     end;

    if DispMode = Rd then
     begin
       Rd_Param.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
       Rd_Param.PosX    := S_RdLife;
       Rd_Param.PosY    := Z_RdLife;
       Rd_Param.Time    := Life_Time_Super;
       Rd_Param.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}
       Life_Sign_XY (Rd_Param);
     end;
   end; {Life_Sign_ModWrRd}

                  {Erweitert um die Subadresse!}
 procedure Transf_And_Displ_ModbusData  (DispMode : TModeSubAdr;
                                         RdCard   : TCardSubAdr;
                                         WrCard   : TCardSubAdr;
                                         Sub0WrDta: Word;
                                         Sub2WrDta: Word);
  var Color   : TBackColor;
      ModRdDta: Word;
      WrAdr   : TModAdr;
      RdAdr   : TModAdr;
      MilErr  : TMilErr;
      RdErr   : Boolean;
  begin                                             {DataTo_ModBus_And_Displ}
    if DispMode.WrMode then          {Daten schreiben und nicht nur anzeigen}
     begin
{       if DispMode.WrSub0 then   }
        begin                                {Daten schreiben}
          WrAdr.AdrIfc  := WrCard.IfkNr;
          WrAdr.AdrCard := WrCard.ModAdr;
          WrAdr.AdrSub  := WrCard.SubAdr;
          WrAdr.AdrMode := AdrNew;
          Mil.Wr_ModBus (Sub0WrDta, WrAdr, MilErr);
          Life_Sign_ModWrRd (Wr);
        end;
{
       if DispMode.WrSub2 then
        begin
          WrAdr.AdrIfc  := WrCard.IfkNr;
          WrAdr.AdrCard := WrCard.ModAdr;
          WrAdr.AdrSub  := WrCard.SubAdr+2;
          WrAdr.AdrMode := AdrNew;
          Mil.Wr_ModBus (Sub2WrDta, WrAdr, MilErr);
          Life_Sign_ModWrRd (Wr);
        end;
}
     end; {if DispMode.WrMode}

                        {Ab hier Daten nur anzeigen}
    Set_Text_Win;
    if DispMode.WrSub0 then Color := Gruen else Color := Weiss;
    Win_Hex4_XY (S_WrData_Hex, Z_Sub0_Hex, Sub0WrDta, Color, False);
    Win_Bin_XY  (S_WrData_Bin, Z_Sub0_Bin, Sub0WrDta, Color, False);

    if DispMode.WrSub2 then Color := Gruen else Color := Weiss;
    Win_Hex4_XY (S_WrData_Hex, Z_Sub2_Hex, Sub2WrDta, Color, False);
    Win_Bin_XY  (S_WrData_Bin, Z_Sub2_Bin, Sub2WrDta, Color, False);

    if DispMode.RdSub0 then
     begin
      Color := Gruen; Life_Sign_ModWrRd (Rd); RdErr := False;
      RdAdr.AdrIfc  := RdCard.IfkNr;
      RdAdr.AdrCard := RdCard.ModAdr;
      RdAdr.AdrSub  := RdCard.SubAdr;
      RdAdr.AdrMode := AdrNew;
      Mil.Rd_ModBus (ModRdDta,RdAdr,MilErr);
      if MilErr <> No_Err then RdErr := True;
     end
    else Color := Blank;
    Win_Hex4_XY (S_RdData_Hex, Z_Sub0_Hex, ModRdDta, Color, RdErr);
    Win_Bin_XY  (S_RdData_Bin, Z_Sub0_Bin, ModRdDta, Color, RdErr);

    if DispMode.RdSub2 then
     begin Color := Gruen; Life_Sign_ModWrRd (Rd); RdErr := False;
      RdAdr.AdrIfc  := RdCard.IfkNr;
      RdAdr.AdrCard := RdCard.ModAdr;
      RdAdr.AdrSub  := RdCard.SubAdr+2;
      RdAdr.AdrMode := AdrNew;
      Mil.Rd_ModBus (ModRdDta,RdAdr,MilErr);
      if MilErr <> No_Err then RdErr := True;
     end
    else Color := Blank;
    Win_Hex4_XY (S_RdData_Hex, Z_Sub2_Hex, ModRdDta, Color, RdErr);
    Win_Bin_XY  (S_RdData_Bin, Z_Sub2_Bin, ModRdDta, Color, RdErr);
  end;   {DataTo_ModBus_And_Displ}

 procedure Show_Shift_Mode (ShifMod0: Boolean);
  begin
   Set_Text_Win; TextColor(Yellow);
   if ShifMod0 then
    begin
      GotoXY (02,Z_Sub0_Hex); Write (chr($1D));   {waagrechter Doppelpfeil}
      GotoXY (02,Z_Sub2_Hex); Write (' ');
    end
   else
    begin
      GotoXY (02,Z_Sub2_Hex); Write (chr($1D));
      GotoXY (02,Z_Sub0_Hex); Write (' ');
    end;
   TextColor(Yellow);
  end;

 procedure  Ini_TastModSub_Win;
  begin
   Window(02, 19, 70, 24); TextBackground(Green); TextColor(Yellow);
   Writeln ('v------------ WRITE -------------v  v----- READ -----v');
   Writeln ('F1: Mod/Sub-Adr    F5: Sub0  [Hex]  F9 : Mod/Sub-Adr  ');
   Writeln ('F2: Ifk-Adr        F6: Sub2  [Hex]  F10: Ifk-Adr      ');
   Writeln ('F3: Sub0 Ein/Aus   F7: Sub0/2 <-->  F11: Sub0  Ein/Aus');
   Write   ('F4: Sub2    "      F8: Wr-Data 0.0  F12: Sub2     "   ');
  end;


  begin    {Modbus_WrRd}
    if Ifc_Test_Nr = 0 then Ask_Ifc_Mod_Adr;
                    {Ifc_Test_Nr u. Modul_Test_Nr erfragen}
    Sub_Adr_Wr     := 0; {Basis-SubAdr fÅr 1. 16-Bit schreiben; 2. 16-Bit: Basis-SubAdr + 2}
    Sub_Adr_Rd     := 0; {Basis-SubAdr fÅr 1. 16-Bit lesen;     2. 16-Bit: Basis-SubAdr + 2}
    WModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrWr}
    WModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrWr}
    WModCrd.SubAdr := Sub_Adr_Wr;  {Mod_AdrWr}
    RModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrRd}
    RModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrRd}
    RModCrd.SubAdr := Sub_Adr_Rd;   {Sub_AdrRd}
    Wr_Data_Sub0   := 0;     {Sub0 und Sub2 fÅr 32-Bit-Mode}
    Wr_Data_Sub2   := 0;

    Mode_SubAdr.WrMode := False;  {Anzeigen und Schreiben: Ja/Nein}
    Mode_SubAdr.WrSub0 := False;  {fÅr jede Adresse 16-Bit Wr/Rd-Mode festlegen}
    Mode_SubAdr.WrSub2 := False;
    Mode_SubAdr.RdSub0 := True;
    Mode_SubAdr.RdSub2 := True;

    Shift_Mode_Sub0    := False;
    Ini_Text_Win;
    Display_Ini;
    Ini_TastModSub_Win;
    Show_Shift_Mode (Shift_Mode_Sub0);
    Cursor(False);       {Software-Gerippe fÅr Single-Step und Loop}
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step        := True;
       Mode_SubAdr.WrMode := True;     {falls enabled: auch Daten schreiben}
       RModCrd.SubAdr    := Sub_Adr_Rd;
       WModCrd.SubAdr    := Sub_Adr_Wr;
       Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;
     if not Single_Step then
      begin
       Mode_SubAdr.WrMode := True; {falls enabled: auch Daten schreiben}
       RModCrd.SubAdr    := Sub_Adr_Rd;
       WModCrd.SubAdr    := Sub_Adr_Wr;
       Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Ini_Msg_Win;
                    Write ('Write [M]odul- oder [S]ub-Adr eingeben?: ');
                    Ch := NewReadKey;
                    case Ch of
                     'm','M' : begin
                                Show_Mod_Online;
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   WModCrd.ModAdr:= User_In;
                                   Display_Adr;
                                  end;
                                Clr_Online_Win;
                                end;
                     's','S' : begin
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   Sub_Adr_Wr:= User_In;
                                   Display_Adr;
                                  end;
                               end;
                    end; {case}
                    Std_Msg;
                   end;
        Taste_F2 : begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        WModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F3:  begin
                     if   Mode_SubAdr.WrSub0 then Mode_SubAdr.WrSub0 := False
                     else Mode_SubAdr.WrSub0 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F4: begin
                     if   Mode_SubAdr.WrSub2 then Mode_SubAdr.WrSub2 := False
                     else Mode_SubAdr.WrSub2 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F5: begin
                    if Ask_Hex_Break (User_In, Wrd) then
                     begin
                      Wr_Data_Sub0 := User_In;
                      Mode_SubAdr.WrMode := False;
                      Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                     end;
                    Std_Msg;
                  end;
        Taste_F6: begin
                    if Ask_Hex_Break (User_In, Wrd) then
                     begin
                      Wr_Data_Sub2 := User_In;
                      Mode_SubAdr.WrMode := False;
                      Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                     end;
                    Std_Msg;
                  end;
        Taste_F7: begin
                    if Shift_Mode_Sub0 then Shift_Mode_Sub0 := False
                    else Shift_Mode_Sub0 := True;
                    Show_Shift_Mode (Shift_Mode_Sub0);
                    Mode_SubAdr.WrMode := False;
                    Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F8: begin                     {Write Data 0}
                    Wr_Data_Sub0 := 0;
                    Wr_Data_Sub2 := 0;
                    Mode_SubAdr.WrMode := False;
                    Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F9: begin
                    Ini_Msg_Win;
                    Write ('Read [M]odul- oder [S]ub-Adr eingeben?: ');
                    Ch := NewReadKey;
                    case Ch of
                     'm','M' : begin
                                Show_Mod_Online;
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   RModCrd.ModAdr:= User_In;
                                   Display_Adr;
                                  end;
                                Clr_Online_Win;
                                end;
                     's','S' : begin
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   Sub_Adr_Rd:= User_In;
                                   Display_Adr;
                                  end;
                               end;
                    end; {case}
                    Std_Msg;
                   end;
        Taste_F10: begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        RModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F11: begin
                     if   Mode_SubAdr.RdSub0 then Mode_SubAdr.RdSub0 := False
                     else Mode_SubAdr.RdSub0 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F12: begin
                     if   Mode_SubAdr.RdSub2 then Mode_SubAdr.RdSub2 := False
                     else Mode_SubAdr.RdSub2 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
       Taste_Pfeil_Links : begin
                            if Shift_Mode_Sub0 then
                              begin
                                if Wr_Data_Sub0 = $0000 then Wr_Data_Sub0 := $1
                                else Wr_Data_Sub0 := Wr_Data_Sub0 shl 1;
                              end {if Shift-Mode}
                            else
                              begin
                                if Wr_Data_Sub2 = $0000 then Wr_Data_Sub2 := $1
                                else Wr_Data_Sub2 := Wr_Data_Sub2 shl 1;
                              end; {if Shift-Mode}
                            Mode_SubAdr.WrMode := False;
                            Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                           end;  {Taste_Pfeil_Links}
        Taste_Pfeil_Rechts: begin
                            if Shift_Mode_Sub0 then
                              begin
                                if Wr_Data_Sub0 = $0000 then Wr_Data_Sub0 := $1
                                else Wr_Data_Sub0 := Wr_Data_Sub0 shr 1;
                              end {if Shift-Mode}
                            else
                              begin
                                if Wr_Data_Sub2 = $0000 then Wr_Data_Sub2 := $1
                                else Wr_Data_Sub2 := Wr_Data_Sub2 shr 1;
                              end; {if Shift-Mode}
                            Mode_SubAdr.WrMode := False;
                            Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                         end;  {Taste_Pfeil_Rechts}
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  99:  Cursor(True);
  end; {Modul_WrRd}

{xxx}
 procedure Modul_WrRd32;   {jetzt beliebige Subadresse}
  const
   Z_Info     = 01;
   S_Info     = 15;
   Z_Data     = 9;
   S_Data     = 04;

   Z_Sub0_Hex = Z_Data+2;
   Z_Sub2_Hex = Z_Sub0_Hex+1;
   Z_Sub0_Bin = Z_Sub2_Hex+2;
   Z_Sub2_Bin = Z_Sub0_Bin+1;
   Z_Sub0_Life= Z_Sub0_Hex;
   Z_Sub2_Life= Z_Sub2_Hex;
   Z_WrData   = Z_Data+2;
   Z_RdData   = Z_Data+5;

   Z_Ifk_Adr   = Z_Data -4;
   Z_Mod_Adr   = Z_Ifk_Adr+1;
   Z_Sub_Adr   = Z_Ifk_Adr+2;
   S_Ifk_WrAdr = 40;
   S_Mod_WrAdr = S_Ifk_WrAdr;
   S_Ifk_RdAdr = S_Ifk_WrAdr+18;
   S_Mod_RdAdr = S_Ifk_RdAdr;
   S_Sub_WrAdr = S_Ifk_WrAdr;
   S_Sub_RdAdr = S_Ifk_RdAdr;

   S_WrData_Hex= S_Ifk_WrAdr-6;
   S_RdData_Hex= S_Ifk_RdAdr-7;
   S_WrData_Bin= S_Ifk_WrAdr-17;
   S_RdData_Bin= S_Ifk_RdAdr-12;
   S_Comp_Mode = 19;

   Z_RdLife    = Z_Data;
   S_RdLife    = S_Mod_RdAdr-12;
   Z_WrLife    = Z_Data;
   S_WrLife    = S_Mod_WrAdr-12;

  type
       TCompare= (Long32, Wr16Hi_Rd16Hi, Wr16Lo_Rd16Lo, Wr16Hi_Rd16Lo, Wr16Lo_Rd16Hi);
       TWrRd   = (Wr, Rd);
       TData32 = record case Byte of
                  1: (li: LongInt);
                  2: (wrd: packed record
                           l : Word;
                           h : Word;
                           end)
                 end;

  var User_In     : Word;
      User_LongIn : LongInt;
      Mod_Adr     : Byte;
      Sub_Adr     : Byte;
      Sub_Adr_Wr  : Byte;    {Basis-SubAdr fÅr 1. 16-Bit schreiben; 2. 16-Bit: Basis-SubAdr + 2}
      Sub_Adr_Rd  : Byte;    {Basis-SubAdr fÅr 1. 16-Bit lesen;     2. 16-Bit: Basis-SubAdr + 2}

      Rd_Sub0_Err : LONGINT;
      Rd_Sub2_Err : LONGINT;
      Ifk_AdrWr   : Byte;
      Ifk_AdrRd   : Byte;
      Mod_AdrWr   : Byte;
      Mod_AdrRd   : Byte;
      Mode_SubAdr : TModeSubAdr;
      RModCrd     : TCardSubAdr;
      WModCrd     : TCardSubAdr;
{
      Wr_Data_Sub0: Word;
      Wr_Data_Sub2: Word;
}      Shift_Mode_Sub0 : Boolean;
      FixDataMode: Boolean;
      Start_Loop : Boolean;
      Transf_Cnt : LongInt;
      Error_Cnt  : LongInt;
      Color      : TBackColor;
      Compare32  : TCompare;
      I_32       : TData32;
      SubAdr4u6  : Boolean;


  procedure  Ini_TastMod32_Win;
   begin
    Window(02, 20, 70, 24); TextBackground(Green); TextColor(Yellow);
    Writeln ('v------------ WRITE -------------v  v----- READ -----v');
    Writeln ('F1:Mod/SubAdr   F5:Wr-Data fix/var  F9 :Mod/Sub-Adr   ');
    Writeln ('F2:Ifk-Adr      F6:Wr-Data [Hex]    F10:Ifk-Adr       ');
    Writeln ('F3:             F7:Clr Data+Count   F11:32/16Bit check');
{   Writeln ('F3:Sub0/2:4/6   F7:Clr Data+Count   F11:32/16Bit check'); }
   end;

  procedure Win32_Hex4_Xy (X: Byte; Y: Byte; WData: Word;
                         BackColor: TBackColor; RdError: Boolean);
   begin
    if BackColor = Gruen     then TextBackground(Green);
    if BackColor = Rot       then TextBackground(Red);
    if BackColor = Weiss     then TextBackground(White);
    if BackColor = Magent    then TextBackground(Magenta);
    if BackColor = Blau      then TextBackground(Blue);
    if BackColor = Blank     then TextBackground(White);
    if BackColor = BlankLoop then TextBackground(White);

    GotoXY (X,Y);
    if (BackColor = Blank) or (BackColor = BlankLoop) then
      begin
       Write ('    ');
      end
    else
      begin
       if BackColor = Rot then TextColor(Yellow);
       if RdError then Write ('MIL?') else Write (Hex_Word(WData));
      end;

    if (BackColor = BlankLoop) then
     begin
       GotoXY(S_Data+12,Z_Data); TextColor(Red+128);
       Write ('    Loop! ');
     end;
    TextColor(Black);
   end; {Win32_Hex4_XY}
{xxx}
   procedure Display_Adr;
    begin
     Set_Text_Win;
     TextColor(Black);
     GotoXY(S_Ifk_WrAdr,Z_Ifk_Adr);   write(Hex_Byte(WModCrd.IfkNr));
     GotoXY(S_Mod_WrAdr,Z_Mod_Adr);   write(Hex_Byte(WModCrd.ModAdr));
     GotoXY(S_Sub_WrAdr,Z_Sub_Adr);   write(Hex_Byte(Sub_Adr_Wr));

     GotoXY(S_Ifk_RdAdr,Z_Ifk_Adr);   write(Hex_Byte(RModCrd.IfkNr));
     GotoXY(S_Mod_RdAdr,Z_Mod_Adr);   write(Hex_Byte(RModCrd.ModAdr));
     GotoXY(S_Sub_RdAdr,Z_Sub_Adr);   write(Hex_Byte(Sub_Adr_Rd));
    end;
{
   procedure Display_SubAdr;
    begin
     Set_Text_Win;        TextColor(Yellow);
     if SubAdr4u6 then begin
     GotoXY(17,Z_Info+2); write('     v--Sub-Adr['); TextColor(red);
                          write('4'); TextColor(yellow); write('] =K0--v   v--Sub-Adr['); TextColor(red);
                          write('6'); TextColor(yellow); write('] =K1--v    ');
       end
     else begin
     GotoXY(17,Z_Info+2); write('     v--Sub-Adr['); TextColor(red);
                          write('0'); TextColor(yellow); write('] =K0--v   v--Sub-Adr['); TextColor(red);
                          write('2'); TextColor(yellow); write('] =K1--v    ');
       end;
    end;
}
 procedure Displ_Compare_Mode;
  begin
   Set_Text_Win; TextColor(Black);
   GotoXY(S_Comp_Mode,Z_WrData+2);
   case Compare32 of
       Long32       : write('32-Bit     ');
       Wr16Hi_Rd16Hi: write('W16Hi-R16Lo');
       Wr16Lo_Rd16Lo: write('W16Lo-R16Lo');
       Wr16Hi_Rd16Lo: write('W16Hi-R16Lo');
       Wr16Lo_Rd16Hi: write('W16Lo-R16Hi');
   end; {case}
  end;

   procedure Display_Ini;
   begin
    Ini_Text_Win;        TextColor(Yellow);
{    GotoXY(16,Z_Info+0); write('---- Modul-Bus Daten schreiben/lesen/prÅfen ----');
    TextColor(Blue); }
    GotoXY(08,Z_Info+1); write('Setze Modul-Adr mit Fct-Code 11 [H], Wr/Rd mit Fct-Code 10/90 [H]');
{
    Display_SubAdr;
    if SubAdr4u6 then begin
    GotoXY(17,Z_Info+2); write('     v--Sub-Adr[4] =K0--v   v--Sub-Adr[6] =K1--v    ');
      end
    else begin
    GotoXY(17,Z_Info+2); write('     v--Sub-Adr[0] =K0--v   v--Sub-Adr[2] =K1--v    ');
      end;
}
    GotoXY(17,Z_Info+2); write('     v-- SubAdr[n]=K0 --v   v-- SubAdr[n]=K1 --v     ');
    GotoXY(17,Z_Info+3); write('[Bit 31................16   15................00 Bit]');
    GotoXY(17,Z_Info+4); write('     ^-Byte3-^  ^-Byte2-^   ^-Byte1-^  ^-Byte0-^     ');

    TextColor(Blue);
    GotoXY(S_Ifk_WrAdr-12,Z_Ifk_Adr);   write('IFK-Adr[H]: ');
    GotoXY(S_Mod_WrAdr-12,Z_Mod_Adr);   write('Mod-Adr[H]: ');
    GotoXY(S_Mod_WrAdr-12,Z_Sub_Adr);   write('Sub-Adr[H]: ');

    GotoXY(S_Ifk_RdAdr-12,Z_Ifk_Adr);   write('IFK-Adr[H]: ');
    GotoXY(S_Mod_RdAdr-12,Z_Mod_Adr);   write('Mod-Adr[H]: ');
    GotoXY(S_Mod_RdAdr-12,Z_Sub_Adr);   write('Sub-Adr[H]: ');

    TextColor(yellow);
    GotoXY(S_Mod_WrAdr-12,Z_Mod_Adr+2); write('^-- WrAdr --^ ');
    GotoXY(S_Mod_RdAdr-12,Z_Mod_Adr+2); write('^-- RdAdr --^ ');
    Display_Adr;
    TextColor(Blue);
    GotoXY(S_Data,Z_Data  );    writeln('Wr-Data-Cnt: ');
    GotoXY(S_Data,Z_Data+1);    writeln('                ^  ^  ');
    GotoXY(S_Data,Z_WrData);    writeln('Write-Data[H]: ');
    GotoXY(S_Data,Z_WrData+1);  writeln('Error-Data[H]: ');
    TextColor(Yellow);
    GotoXY(S_Data,Z_WrData+2);  write('Compare-Mode-> ');
    Displ_Compare_Mode;
    TextColor(Blue);
    GotoXY(S_WrData_Hex+2,Z_WrData+2);  writeln('----');
    GotoXY(S_WrData_Hex-3,Z_WrData+2);  writeln('----');

    GotoXY(S_Data,Z_RdData);    writeln('Read-Data [H]: ');
    GotoXY(S_Data,Z_RdData+1);  writeln('Error-Data[H]: ');
    GotoXY(S_Data,Z_RdData+2);  writeln('Error-Count: ');
   end;

 procedure Transf_And_Displ_ModbusData  (Loop_Start: Boolean;
                                         StepSingle: Boolean;
                                         RdCard    : TCardSubAdr;
                                         WrCard    : TCardSubAdr);
  var ModRdDta: Word;
      WrAdr   : TModAdr;
      RdAdr   : TModAdr;
      MilErr  : TMilErr;
      RdErr   : Boolean;
      RdDta32 : TData32;
      WrDta32 : TData32;

  begin                                             {DataTo_ModBus_And_Displ}
     WrDta32.li := I_32.li;
     Transf_Cnt := Transf_Cnt + 1;
     RdErr      := False;

     case Compare32 of
       Long32 : begin
                  {Subadr 2 = Low-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := WrCard.SubAdr+2;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.l, WrAdr, MilErr);

                  {Subadr 0 = Hi-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := WrCard.SubAdr+0;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.h, WrAdr, MilErr);

                  {Subadr 2/6 = Low-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  RdAdr.AdrSub  := RdCard.SubAdr+2;
{                  if SubAdr4u6 then RdAdr.AdrSub := 6 else RdAdr.AdrSub := 2;}
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.l,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  {Subadr 0/4 = Hi-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  RdAdr.AdrSub  := RdCard.SubAdr+0;
{                 if SubAdr4u6 then RdAdr.AdrSub := 4 else RdAdr.AdrSub := 0; }
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.h,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                  end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Color, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Color, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (RdDta32.li <> WrDta32.li)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Color, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Color, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Color, RdErr);
                   end;
                end; {Long32}

       Wr16Hi_Rd16Hi:
               begin
                   {Subadr 0 = Hi-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := WrCard.SubAdr+0;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.h, WrAdr, MilErr);

                  {Subadr 0 = Hi-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  RdAdr.AdrSub  := RdCard.SubAdr+0;
{                  if SubAdr4u6 then RdAdr.AdrSub := 4 else RdAdr.AdrSub := 0;}
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.h,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Blank, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Blank, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Color, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (RdDta32.wrd.h <> WrDta32.wrd.h)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Blank, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Color, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Blank, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Color, RdErr);
                   end;
                end;  {Hi16}

       Wr16Lo_Rd16Lo:
                begin
                  {Subadr 2 = Low-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := WrCard.SubAdr+2;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.l, WrAdr, MilErr);

                  {Subadr 2 = Low-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  RdAdr.AdrSub  := RdCard.SubAdr+2;
{                 if SubAdr4u6 then RdAdr.AdrSub := 6 else RdAdr.AdrSub := 2;}
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.l,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Blank, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Color, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Blank, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (RdDta32.wrd.l <> WrDta32.wrd.l)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Blank, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Color, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Blank, RdErr);
                   end;
                 end;

       Wr16Hi_Rd16Lo:
                begin
                   {Subadr 0 = Hi-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := WrCard.SubAdr+0;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.h, WrAdr, MilErr);

                  {Subadr 2 = Low-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  RdAdr.AdrSub  := RdCard.SubAdr+2;
{                 if SubAdr4u6 then RdAdr.AdrSub := 6 else RdAdr.AdrSub := 2;}
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.l,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Blank, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Color, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Blank, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (WrDta32.wrd.h <> RdDta32.wrd.l)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Blank, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Color, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Color, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Blank, RdErr);
                   end;
                end;

       Wr16Lo_Rd16Hi:
                begin
                  {Subadr 2 = Low-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := WrCard.SubAdr+2;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.l, WrAdr, MilErr);

                  {Subadr 0 = Hi-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  RdAdr.AdrSub  := RdCard.SubAdr+0;
{                 if SubAdr4u6 then RdAdr.AdrSub := 4 else RdAdr.AdrSub := 0; }
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.h,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Blank, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Blank, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Color, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (WrDta32.wrd.l <> RdDta32.wrd.h)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Blank, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Blank, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Color, RdErr);
                   end;
                end;
     end; {case Compare32}
  end;   {DataTo_ModBus_And_Displ}

  procedure Disp_FV_Mode;
   begin
     Set_Text_Win;
     TextBackground(Magenta); TextColor(Yellow);
     GotoXY(02,Z_WrData);
     if FixDataMode then
       begin
         Writeln ('f');
       end
      else
       begin
         Writeln ('v');
       end;
   end;
 procedure Reset_Counters;
  begin
   I_32.li    := 0;
   Transf_Cnt := 0;
   Error_Cnt  := 0;
   Set_Text_Win;
   GotoXY(S_Data+12,Z_Data);     Writeln (Transf_Cnt:10);
   GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
   {Write Daten anzeigen}
   GotoXY (S_WrData_Hex+2, Z_WrData);    Write ('0000');
   GotoXY (S_WrData_Hex-3, Z_WrData);    Write ('0000');
   {Read Daten blank}
   GotoXY (S_WrData_Hex+2, Z_RdData);    Write ('    ');
   GotoXY (S_WrData_Hex-3, Z_RdData);    Write ('    ');
   {Error-Daten blank}
   GotoXY (S_WrData_Hex+2, Z_WrData+1);  Write ('    ');
   GotoXY (S_WrData_Hex-3, Z_WrData+1);  Write ('    ');
   GotoXY (S_WrData_Hex+2, Z_RdData+1);  Write ('    ');
   GotoXY (S_WrData_Hex-3, Z_RdData+1);  Write ('    ');
  end;

 procedure Incr_Data;
  begin
    case Compare32 of
     Long32       : begin
                      if I_32.li = $FFFFFFFF then
                        I_32.li:= 0
                      else
                        I_32.li:= I_32.li + 1;
                    end; {Long32}
     Wr16Hi_Rd16Hi, Wr16Hi_Rd16Lo:
                     begin
                      if I_32.wrd.h = $FFFF then
                        I_32.li:= 0
                      else
                        I_32.wrd.h:= I_32.wrd.h + 1;
                    end;

     Wr16Lo_Rd16Lo, Wr16Lo_Rd16Hi:
                    begin
                      if I_32.wrd.l = $FFFF then
                        I_32.li:= 0
                      else
                        I_32.wrd.l:= I_32.wrd.l + 1;
                    end;
    end; {case}
  end;

  begin    {Modbus_WrRd32_Subx}
    Sub_Adr_Wr     := 0; {Basis-SubAdr fÅr 1. 16-Bit schreiben; 2. 16-Bit: Basis-SubAdr + 2}
    Sub_Adr_Rd     := 0; {Basis-SubAdr fÅr 1. 16-Bit lesen;     2. 16-Bit: Basis-SubAdr + 2}
    WModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrWr}
    WModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrWr}
    WModCrd.SubAdr := Sub_Adr_Wr;  {Mod_AdrWr}
    RModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrRd}
    RModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrRd}
    RModCrd.SubAdr := Sub_Adr_Rd;   {Sub_AdrRd}
{
    Wr_Data_Sub0    := 0;
    Wr_Data_Sub2    := 0;
}    Shift_Mode_Sub0 := False;
    FixDataMode     := False;
    SubAdr4u6       := True;  {DatenrÅcklesung 32-Bit -> Outregister}
    Transf_Cnt      := 0;
    Error_Cnt       := 0;
    Compare32       := Long32;  {32-Bit-Vergleich}

    Ini_Text_Win;
    Display_Ini;
    Disp_FV_Mode;
    Ini_TastMod32_Win;
    Ini_WrRd32_Win;
    Cursor(False);       {Software-Gerippe fÅr Single-Step und Loop}
    Std_Msg;
    Ch := NewReadKey;
    I_32.li := 0;           {Datencounter bei variablen Daten}

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Start_Loop  := False;
       Mode_SubAdr.WrMode := True;   {falls enabled: auch Daten schreiben}
       RModCrd.SubAdr     := Sub_Adr_Rd;
       WModCrd.SubAdr     := Sub_Adr_Wr;
       Transf_And_Displ_ModbusData (Start_Loop, Single_Step, RModCrd, WModCrd{, FixDataMode});
       if not FixDataMode then Incr_Data; {feste oder variable Daten schreiben}
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then
      begin
        Single_Step := False;
        Start_Loop  := True;   {Loop-Anzeige aktivieren!}
       RModCrd.SubAdr    := Sub_Adr_Rd;
       WModCrd.SubAdr    := Sub_Adr_Wr;
        Transf_And_Displ_ModbusData (Start_Loop, Single_Step, RModCrd, WModCrd{, FixDataMode});
      end;

     if not Single_Step then
      begin
       if not FixDataMode then Incr_Data; {feste oder variable Daten schreiben}
       Mode_SubAdr.WrMode := True; {falls enabled: auch Daten schreiben}
      RModCrd.SubAdr    := Sub_Adr_Rd;
      WModCrd.SubAdr    := Sub_Adr_Wr;
       Start_Loop  := False;
       Transf_And_Displ_ModbusData (Start_Loop, Single_Step, RModCrd, WModCrd{, FixDataMode});
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Ini_Msg_Win;
                    Write ('Write [M]odul- oder [S]ub-Adr eingeben?: ');
                    Ch := NewReadKey;
                    case Ch of
                     'm','M' : begin
                                Clr_WrRd32_Win;
                                Show_Mod_Online;
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   WModCrd.ModAdr:= User_In;
                                   Display_Adr;
                                  end;
                                Clr_Online_Win;
                                end;
                     's','S' : begin
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   Sub_Adr_Wr:= User_In;
                                   Display_Adr;
                                  end;
                               end;
                    end; {case}
                    Ini_WrRd32_Win;
                    Std_Msg;
                  end;

        Taste_F2 : begin
                    Clr_WrRd32_Win;
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        WModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Std_Msg;
                   end;
{
        Taste_F3 : begin
                    if SubAdr4u6 then SubAdr4u6:= False else SubAdr4u6 := True;
                    Display_SubAdr;
                    Std_Msg;
                   end;
}
        Taste_F5: begin
                    if FixDataMode then FixDataMode:=False else FixDataMode:=True;
                    Disp_FV_Mode;
                    Std_Msg;
                  end;

         Taste_F6: begin
                   if Ask_Hex_LongInteger_Break (User_LongIn) then
                     begin
                      I_32.li := User_LongIn;
                     end;
                    Std_Msg;
                    Ch := '?';
                  end;

        Taste_F7: begin
                   Reset_Counters;
                   Single_Step := True;
                   Ch := '?';
                  end;

        Taste_F8: begin
                  end;

        Taste_F9: begin
                    Ini_Msg_Win;
                    Write ('Read [M]odul- oder [S]ub-Adr eingeben?: ');
                    Ch := NewReadKey;
                    case Ch of
                     'm','M' : begin
                                Clr_WrRd32_Win;
                                Show_Mod_Online;
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   RModCrd.ModAdr:= User_In;
                                   Display_Adr;
                                  end;
                                Clr_Online_Win;
                                end;
                     's','S' : begin
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   Sub_Adr_Rd:= User_In;
                                   Display_Adr;
                                  end;
                               end;
                    end; {case}
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Reset_Counters;
                    Std_Msg;
                   end;
        Taste_F10: begin
                    Clr_WrRd32_Win;
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        RModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Std_Msg;
                   end;
        Taste_F11: begin
                     Ini_Msg_Win;
                     Cursor(True);
                     Write ('?? 32-Bit: [');
                     TextColor(Blue); Write ('1'); TextColor(Yellow); Write(']Alle, [');
                     TextColor(Blue); Write ('2'); TextColor(Yellow); Write(']High16, [');
                     TextColor(Blue); Write ('3'); TextColor(Yellow); Write(']Low16, [');
                     TextColor(Blue); Write ('4'); TextColor(Yellow); Write(']Wr16Hi_Rd16Lo, [');
                     TextColor(Blue); Write ('5'); TextColor(Yellow); Write(']Wr16Lo_Rd16Hi: ');
                     Ch := NewReadKey;
                     case Ch of
                      '1' : Compare32 := Long32;
                      '2' : Compare32 := Wr16Hi_Rd16Hi;
                      '3' : Compare32 := Wr16Lo_Rd16Lo;
                      '4' : Compare32 := Wr16Hi_Rd16Lo;
                      '5' : Compare32 := Wr16Lo_Rd16Hi;
                     end; {case}
                     Single_Step := True;
                     Displ_Compare_Mode;
                     Reset_Counters;
                     Std_Msg;
                     Cursor(False);
                   end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
   Cursor(True);
  end; {Modul_WrRd32}


 procedure Modul_Bus;
 const Z_Base = 10;
       Z_Max  = 6;
 var User_Int : Integer;
 begin
  repeat
   Ini_Text_Win;
   TextColor(Yellow);               {Setze Schriftfarbe}
   GotoXY(02, Z_Base-1); Write ('Test-Routinen fÅr Modul-Bus bzw. I/O-Bus ');
   TextColor(Blue);
   GotoXY(02, Z_Base+0);  Write ('0: Welche IFK`s u. Module am Devicebus?                           ');
   GotoXY(02, Z_Base+1);  Write ('1: Welche Module an einer IFK?                                    ');
   GotoXY(02, Z_Base+2);  Write ('2: Modul  lesen                                                   ');
   GotoXY(02, Z_Base+3);  Write ('3: Modul  schreiben                                               ');
   GotoXY(02, Z_Base+4);  Write ('4: Modul  schreiben/lesen                                         ');
   GotoXY(02, Z_Base+5);  Write ('5: Modul  schreiben/lesen/vergleichen   [16/32-Bit]               ');
   GotoXY(02, Z_Base+6);  Write ('6: Modul  Konfiguration fÅr 24/32-Bit I/O [Skalierung]            ');
   GotoXY(02, Z_Base+7);  Write ('7: Summen- u. Anpa·karten-Status (APK = grÅn)                     ');
   GotoXY(02, Z_Base+8);  Write ('8: Ident-Kodeliste fÅr Module u. Anpa·karten                      ');
   GotoXY(02, Z_Base+9);  Write ('9: Zuordnung Bit-, Byte- und Sub-Adr am Modulbus                  ');
   GotoXY(02, Z_Base+10); Write ('A: Set IFK-Mode (IFA, Modulbus, Funktionsgenerator)           ');
   GotoXY(02, Z_Base+11); Write ('B: Modul  lesen EPLD-Version + Reset Powerup-Bit              ');
{   GotoXY(02, Z_Base+12); Write ('D: Modul  Wr/Rd/Vergleich 32/16-Bit mit variabler Subadr      ');
}   Ini_Msg_Win;
   Write ('Bitte Auswahl-Nummer oder E[X]it eingeben: ');
   Ch := NewReadKey;
      case Ch of                 { 0 : Ask_Ifc_Mod_Adr; }
       '0' : Mil_Detect_IO_Modul;
       '1' : Mil_Displ_IO_Modul;
       '2' : Modul_Rd_Sub;  {mit und ohne Online!!!}
       '3' : Modul_Wr_Sub;
       '4' : Modul_WrRd;
       '5' : begin Mil_Ask_Ifc; Mil_Ask_Mod; Modul_WrRd32; end;
       '6' : Modul_Konfig;
       '7' : Modul_APK;
       '8' : Modul_Ident_List;
       '9' : Modul_Bit_Zuordnung;
   'a','A' : begin Mil_Ask_Ifc; Mil_IfkMode; end;
   'b','B' : begin Modul_EPLD_PwrUp; end;
{   'd','D' : begin Mil_Ask_Ifc; Mil_Ask_Mod; Modul_WrRd32_Subx; end;}  {erweitert Punkt 5}
       'x','X' : Exit;
      end;
   until 1=2;
   Ch := '?';
 end; {Modul_Bus}
end.  { UNIT DATECH_0 }


{xxxxxxxxxx Nachfolgenden Code erstmal retten}

 procedure Modul_WrRd; {mit beliebiger Subadresse fÅr Read bzw. Write!!}
  label 99;            {Die 1. 16-Bit auf Sub_Base, 2. 16-Bit auf Sub_Base+2}
  const
   Z_Info     = 01;
   S_Info     = 15;
   Z_Data     = 9;
   S_Data     = 04;
   Z_Sub0_Hex = Z_Data+2;
   Z_Sub2_Hex = Z_Sub0_Hex+1;
   Z_Sub0_Bin = Z_Sub2_Hex+2;
   Z_Sub2_Bin = Z_Sub0_Bin+1;
   Z_Sub0_Life= Z_Sub0_Hex;
   Z_Sub2_Life= Z_Sub2_Hex;
   Z_WrData   = Z_Data+2;
   Z_RdData   = Z_Data+5;

   Z_Ifk_Adr   = Z_Data -3;
   Z_Mod_Adr   = Z_Data -2;
   Z_Sub_Adr   = Z_Data -1;

   S_Ifk_WrAdr = 40;
   S_Mod_WrAdr = S_Ifk_WrAdr;
   S_Sub_WrAdr = S_Ifk_WrAdr;

   S_Ifk_RdAdr = S_Ifk_WrAdr+18;
   S_Mod_RdAdr = S_Ifk_RdAdr;
   S_Sub_RdAdr = S_Ifk_RdAdr;

   S_WrData_Hex= S_Ifk_WrAdr-6;
   S_RdData_Hex= S_Ifk_RdAdr-7;
   S_WrData_Bin= S_Ifk_WrAdr-17;
   S_RdData_Bin= S_Ifk_RdAdr-12;

   Z_RdLife    = Z_Data;
   S_RdLife    = S_Mod_RdAdr-12;
   Z_WrLife    = Z_Data;
   S_WrLife    = S_Mod_WrAdr-12;

  type TWrRd = (Wr, Rd);

  var User_In     : Word;
      Mod_Adr     : Byte;
      Sub_Adr     : Byte;
      Sub_Adr_Wr : Byte;    {Basis-SubAdr fÅr 1. 16-Bit schreiben; 2. 16-Bit: Basis-SubAdr + 2}
      Sub_Adr_Rd : Byte;    {Basis-SubAdr fÅr 1. 16-Bit lesen;     2. 16-Bit: Basis-SubAdr + 2}

      Rd_Sub0_Err : LONGINT;
      Rd_Sub2_Err : LONGINT;
      Ifk_AdrWr   : Byte;
      Ifk_AdrRd   : Byte;
      Mod_AdrWr   : Byte;
      Mod_AdrRd   : Byte;
      Mode_SubAdr : TModeSubAdr;
      RModCrd     : TCardSubAdr;
      WModCrd     : TCardSubAdr;
      Wr_Data_Sub0: Word;
      Wr_Data_Sub2: Word;
      Shift_Mode_Sub0 : Boolean;

   procedure Display_Adr;
    begin
     Set_Text_Win;
     TextColor(Black);
     GotoXY(S_Ifk_WrAdr,Z_Ifk_Adr);   write(Hex_Byte(WModCrd.IfkNr));
     GotoXY(S_Mod_WrAdr,Z_Mod_Adr);   write(Hex_Byte(WModCrd.ModAdr));
     GotoXY(S_Sub_WrAdr,Z_Sub_Adr);   write(Hex_Byte(Sub_Adr_Wr));
     GotoXY(S_Ifk_RdAdr,Z_Ifk_Adr);   write(Hex_Byte(RModCrd.IfkNr));
     GotoXY(S_Mod_RdAdr,Z_Mod_Adr);   write(Hex_Byte(RModCrd.ModAdr));
     GotoXY(S_Sub_RdAdr,Z_Sub_Adr);   write(Hex_Byte(Sub_Adr_Rd));
    end;

   procedure Display_Ini;
   begin
    Ini_Text_Win;        TextColor(Yellow);
    GotoXY(05,Z_Info  ); write('--- Modul-Bus Daten auf beliebige Sub-Adr n+0 u. n+2 schreiben/lesen ---');
    TextColor(Blue);
    GotoXY(08,Z_Info+1); write('Setze Modul-Adr mit Fct-Code 11 [H], Wr/Rd mit Fct-Code 10/90 [H]');
    GotoXY(17,Z_Info+2); write('     v--SubAdr[+0] =K0--v   v--SubAdr[+2] =K1--v     ');
    GotoXY(17,Z_Info+3); write('[Bit 31................16   15................00 Bit]');
    TextColor(Blue);
    GotoXY(S_Ifk_WrAdr-12,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Mod_WrAdr-12,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Sub_WrAdr-12,Z_Sub_Adr); write('Sub-Adr[H]: ');

    GotoXY(S_Ifk_RdAdr-12,Z_Ifk_Adr); write('IFK-Adr[H]: ');
    GotoXY(S_Mod_RdAdr-12,Z_Mod_Adr); write('Mod-Adr[H]: ');
    GotoXY(S_Sub_RdAdr-12,Z_Sub_Adr); write('Sub-Adr[H]: ');
    Display_Adr;

    TextColor(Blue);
    GotoXY(S_Data,Z_Data  );    write('                           '); TextColor(Brown);
    writeln('Write-Data        Read-Data               ');
    GotoXY(S_Data,Z_Data+1);    writeln('                              [Hex]            [Hex]'); TextColor(Blue);
    GotoXY(S_Data,Z_Sub0_Hex);  writeln('Sub-Adr[0]: ');
    GotoXY(S_Data,Z_Sub2_Hex);  writeln('Sub-Adr[2]: ');

    {Byte-Bezeichnung enzeigen}
    GotoXY(S_RdData_Hex+5,Z_Sub0_Hex); writeln('<Byte3');
    GotoXY(S_RdData_Hex+5,Z_Sub2_Hex); writeln('<Byte1');
    GotoXY(S_RdData_Hex-7,Z_Sub0_Hex); writeln('Byte4>');
    GotoXY(S_RdData_Hex-7,Z_Sub2_Hex); writeln('Byte2>');

    TextColor(Blue);
    GotoXY(S_Data,Z_Sub0_Hex);  writeln('Sub-Adr[0]: ');
    GotoXY(S_Data,Z_Sub2_Hex);  writeln('Sub-Adr[2]: ');

    GotoXY(S_WrData_Bin, Z_Sub2_Bin+1); writeln('MSB             LSB');
    GotoXY(S_RdData_Bin, Z_Sub2_Bin+1); writeln('MSB             LSB');
   end;

  procedure Life_Sign_ModWrRd (DispMode: TWrRd);
   var Wr_Param, Rd_Param: TLife_XY;
   begin
    if DispMode = Wr then
     begin                    GotoXY(S_RdLife ,Z_RdLife);
       Wr_Param.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
       Wr_Param.PosX    := S_WrLife;;
       Wr_Param.PosY    := Z_WrLife;
       Wr_Param.Time    := Life_Time_Super;
       Wr_Param.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}
       Life_Sign_XY (Wr_Param);
     end;

    if DispMode = Rd then
     begin
       Rd_Param.Mode    := Norm;      {Parameter fÅr Lebenszeichen definieren}
       Rd_Param.PosX    := S_RdLife;
       Rd_Param.PosY    := Z_RdLife;
       Rd_Param.Time    := Life_Time_Super;
       Rd_Param.Disp_Win:= Set_Text_Win; {Darstellungs-Fenster}
       Life_Sign_XY (Rd_Param);
     end;
   end; {Life_Sign_ModWrRd}

                  {Erweitert um die Subadresse!}
 procedure Transf_And_Displ_ModbusData  (DispMode : TModeSubAdr;
                                         RdCard   : TCardSubAdr;
                                         WrCard   : TCardSubAdr;
                                         Sub0WrDta: Word;
                                         Sub2WrDta: Word);
  var Color   : TBackColor;
      ModRdDta: Word;
      WrAdr   : TModAdr;
      RdAdr   : TModAdr;
      MilErr  : TMilErr;
      RdErr   : Boolean;
  begin                                             {DataTo_ModBus_And_Displ}
    if DispMode.WrMode then          {Daten schreiben und nicht nur anzeigen}
     begin
{       if DispMode.WrSub0 then   }
        begin                                {Daten schreiben}
          WrAdr.AdrIfc  := WrCard.IfkNr;
          WrAdr.AdrCard := WrCard.ModAdr;
          WrAdr.AdrSub  := WrCard.SubAdr;
          WrAdr.AdrMode := AdrNew;
          Mil.Wr_ModBus (Sub0WrDta, WrAdr, MilErr);
          Life_Sign_ModWrRd (Wr);
        end;
{
       if DispMode.WrSub2 then
        begin
          WrAdr.AdrIfc  := WrCard.IfkNr;
          WrAdr.AdrCard := WrCard.ModAdr;
          WrAdr.AdrSub  := WrCard.SubAdr+2;
          WrAdr.AdrMode := AdrNew;
          Mil.Wr_ModBus (Sub2WrDta, WrAdr, MilErr);
          Life_Sign_ModWrRd (Wr);
        end;
}
     end; {if DispMode.WrMode}

                        {Ab hier Daten nur anzeigen}
    Set_Text_Win;
    if DispMode.WrSub0 then Color := Gruen else Color := Weiss;
    Win_Hex4_XY (S_WrData_Hex, Z_Sub0_Hex, Sub0WrDta, Color, False);
    Win_Bin_XY  (S_WrData_Bin, Z_Sub0_Bin, Sub0WrDta, Color, False);

    if DispMode.WrSub2 then Color := Gruen else Color := Weiss;
    Win_Hex4_XY (S_WrData_Hex, Z_Sub2_Hex, Sub2WrDta, Color, False);
    Win_Bin_XY  (S_WrData_Bin, Z_Sub2_Bin, Sub2WrDta, Color, False);

    if DispMode.RdSub0 then
     begin
      Color := Gruen; Life_Sign_ModWrRd (Rd); RdErr := False;
      RdAdr.AdrIfc  := RdCard.IfkNr;
      RdAdr.AdrCard := RdCard.ModAdr;
      RdAdr.AdrSub  := RdCard.SubAdr;
      RdAdr.AdrMode := AdrNew;
      Mil.Rd_ModBus (ModRdDta,RdAdr,MilErr);
      if MilErr <> No_Err then RdErr := True;
     end
    else Color := Blank;
    Win_Hex4_XY (S_RdData_Hex, Z_Sub0_Hex, ModRdDta, Color, RdErr);
    Win_Bin_XY  (S_RdData_Bin, Z_Sub0_Bin, ModRdDta, Color, RdErr);

    if DispMode.RdSub2 then
     begin Color := Gruen; Life_Sign_ModWrRd (Rd); RdErr := False;
      RdAdr.AdrIfc  := RdCard.IfkNr;
      RdAdr.AdrCard := RdCard.ModAdr;
      RdAdr.AdrSub  := RdCard.SubAdr+2;
      RdAdr.AdrMode := AdrNew;
      Mil.Rd_ModBus (ModRdDta,RdAdr,MilErr);
      if MilErr <> No_Err then RdErr := True;
     end
    else Color := Blank;
    Win_Hex4_XY (S_RdData_Hex, Z_Sub2_Hex, ModRdDta, Color, RdErr);
    Win_Bin_XY  (S_RdData_Bin, Z_Sub2_Bin, ModRdDta, Color, RdErr);
  end;   {DataTo_ModBus_And_Displ}

 procedure Show_Shift_Mode (ShifMod0: Boolean);
  begin
   Set_Text_Win; TextColor(Yellow);
   if ShifMod0 then
    begin
      GotoXY (02,Z_Sub0_Hex); Write (chr($1D));   {waagrechter Doppelpfeil}
      GotoXY (02,Z_Sub2_Hex); Write (' ');
    end
   else
    begin
      GotoXY (02,Z_Sub2_Hex); Write (chr($1D));
      GotoXY (02,Z_Sub0_Hex); Write (' ');
    end;
   TextColor(Yellow);
  end;

 procedure  Ini_TastModSub_Win;
  begin
   Window(02, 19, 70, 24); TextBackground(Green); TextColor(Yellow);
   Writeln ('v------------ WRITE -------------v  v----- READ -----v');
   Writeln ('F1: Mod/Sub-Adr    F5: Sub0  [Hex]  F9 : Mod/Sub-Adr  ');
   Writeln ('F2: Ifk-Adr        F6: Sub2  [Hex]  F10: Ifk-Adr      ');
   Writeln ('F3: Sub0 Ein/Aus   F7: Sub0/2 <-->  F11: Sub0  Ein/Aus');
   Write   ('F4: Sub2    "      F8: Wr-Data 0.0  F12: Sub2     "   ');
  end;


  begin    {Modbus_WrRd}
    if Ifc_Test_Nr = 0 then Ask_Ifc_Mod_Adr;
                    {Ifc_Test_Nr u. Modul_Test_Nr erfragen}
    Sub_Adr_Wr     := 0; {Basis-SubAdr fÅr 1. 16-Bit schreiben; 2. 16-Bit: Basis-SubAdr + 2}
    Sub_Adr_Rd     := 0; {Basis-SubAdr fÅr 1. 16-Bit lesen;     2. 16-Bit: Basis-SubAdr + 2}
    WModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrWr}
    WModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrWr}
    WModCrd.SubAdr := Sub_Adr_Wr;  {Mod_AdrWr}
    RModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrRd}
    RModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrRd}
    RModCrd.SubAdr := Sub_Adr_Rd;   {Sub_AdrRd}
    Wr_Data_Sub0   := 0;     {Sub0 und Sub2 fÅr 32-Bit-Mode}
    Wr_Data_Sub2   := 0;

    Mode_SubAdr.WrMode := False;  {Anzeigen und Schreiben: Ja/Nein}
    Mode_SubAdr.WrSub0 := False;  {fÅr jede Adresse 16-Bit Wr/Rd-Mode festlegen}
    Mode_SubAdr.WrSub2 := False;
    Mode_SubAdr.RdSub0 := True;
    Mode_SubAdr.RdSub2 := True;

    Shift_Mode_Sub0    := False;
    Ini_Text_Win;
    Display_Ini;
    Ini_TastModSub_Win;
    Show_Shift_Mode (Shift_Mode_Sub0);
    Cursor(False);       {Software-Gerippe fÅr Single-Step und Loop}
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step        := True;
       Mode_SubAdr.WrMode := True;     {falls enabled: auch Daten schreiben}
       RModCrd.SubAdr    := Sub_Adr_Rd;
       WModCrd.SubAdr    := Sub_Adr_Wr;
       Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;
     if not Single_Step then
      begin
       Mode_SubAdr.WrMode := True; {falls enabled: auch Daten schreiben}
       RModCrd.SubAdr    := Sub_Adr_Rd;
       WModCrd.SubAdr    := Sub_Adr_Wr;
       Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Ini_Msg_Win;
                    Write ('Write [M]odul- oder [S]ub-Adr eingeben?: ');
                    Ch := NewReadKey;
                    case Ch of
                     'm','M' : begin
                                Show_Mod_Online;
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   WModCrd.ModAdr:= User_In;
                                   Display_Adr;
                                  end;
                                Clr_Online_Win;
                                end;
                     's','S' : begin
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   Sub_Adr_Wr:= User_In;
                                   Display_Adr;
                                  end;
                               end;
                    end; {case}
                    Std_Msg;
                   end;
        Taste_F2 : begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        WModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F3:  begin
                     if   Mode_SubAdr.WrSub0 then Mode_SubAdr.WrSub0 := False
                     else Mode_SubAdr.WrSub0 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F4: begin
                     if   Mode_SubAdr.WrSub2 then Mode_SubAdr.WrSub2 := False
                     else Mode_SubAdr.WrSub2 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F5: begin
                    if Ask_Hex_Break (User_In, Wrd) then
                     begin
                      Wr_Data_Sub0 := User_In;
                      Mode_SubAdr.WrMode := False;
                      Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                     end;
                    Std_Msg;
                  end;
        Taste_F6: begin
                    if Ask_Hex_Break (User_In, Wrd) then
                     begin
                      Wr_Data_Sub2 := User_In;
                      Mode_SubAdr.WrMode := False;
                      Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                     end;
                    Std_Msg;
                  end;
        Taste_F7: begin
                    if Shift_Mode_Sub0 then Shift_Mode_Sub0 := False
                    else Shift_Mode_Sub0 := True;
                    Show_Shift_Mode (Shift_Mode_Sub0);
                    Mode_SubAdr.WrMode := False;
                    Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F8: begin                     {Write Data 0}
                    Wr_Data_Sub0 := 0;
                    Wr_Data_Sub2 := 0;
                    Mode_SubAdr.WrMode := False;
                    Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F9: begin
                    Ini_Msg_Win;
                    Write ('Read [M]odul- oder [S]ub-Adr eingeben?: ');
                    Ch := NewReadKey;
                    case Ch of
                     'm','M' : begin
                                Show_Mod_Online;
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   RModCrd.ModAdr:= User_In;
                                   Display_Adr;
                                  end;
                                Clr_Online_Win;
                                end;
                     's','S' : begin
                                if Ask_Hex_Break (User_In, Byt) then
                                  begin
                                   Sub_Adr_Rd:= User_In;
                                   Display_Adr;
                                  end;
                               end;
                    end; {case}
                    Std_Msg;
                   end;
        Taste_F10: begin
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        RModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Std_Msg;
                   end;
        Taste_F11: begin
                     if   Mode_SubAdr.RdSub0 then Mode_SubAdr.RdSub0 := False
                     else Mode_SubAdr.RdSub0 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
        Taste_F12: begin
                     if   Mode_SubAdr.RdSub2 then Mode_SubAdr.RdSub2 := False
                     else Mode_SubAdr.RdSub2 := True;
                     Mode_SubAdr.WrMode := False;
                     Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                   end;
       Taste_Pfeil_Links : begin
                            if Shift_Mode_Sub0 then
                              begin
                                if Wr_Data_Sub0 = $0000 then Wr_Data_Sub0 := $1
                                else Wr_Data_Sub0 := Wr_Data_Sub0 shl 1;
                              end {if Shift-Mode}
                            else
                              begin
                                if Wr_Data_Sub2 = $0000 then Wr_Data_Sub2 := $1
                                else Wr_Data_Sub2 := Wr_Data_Sub2 shl 1;
                              end; {if Shift-Mode}
                            Mode_SubAdr.WrMode := False;
                            Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                           end;  {Taste_Pfeil_Links}
        Taste_Pfeil_Rechts: begin
                            if Shift_Mode_Sub0 then
                              begin
                                if Wr_Data_Sub0 = $0000 then Wr_Data_Sub0 := $1
                                else Wr_Data_Sub0 := Wr_Data_Sub0 shr 1;
                              end {if Shift-Mode}
                            else
                              begin
                                if Wr_Data_Sub2 = $0000 then Wr_Data_Sub2 := $1
                                else Wr_Data_Sub2 := Wr_Data_Sub2 shr 1;
                              end; {if Shift-Mode}
                            Mode_SubAdr.WrMode := False;
                            Transf_And_Displ_ModbusData (Mode_SubAdr, RModCrd, WModCrd, Wr_Data_Sub0, Wr_Data_Sub2);
                         end;  {Taste_Pfeil_Rechts}
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
  99:  Cursor(True);
  end; {Modul_WrRd}

 procedure Modul_WrRd32; {Test fÅr 32-Bit-I/O mit Datenvergleich fÅr 32-
           oder 16 Bit. Beachten: DatenrÅcklesen von dem selben 32-BitIO
           ist default mÑssig auf Subadr 4 u. 6 (Outreg) eingestellt
           = internes Reg! Falls Åber externes Kabel Daten rÅckgelesen werden,
           muss auf Subadr 0 u. 2 umgestellt werden (F3) }
  const
   Z_Info     = 01;
   S_Info     = 15;

   Z_Data     = 10;
   S_Data     = 04;
   Z_Sub0_Hex = Z_Data+2;
   Z_Sub2_Hex = Z_Sub0_Hex+1;
   Z_Sub0_Bin = Z_Sub2_Hex+2;
   Z_Sub2_Bin = Z_Sub0_Bin+1;
   Z_Sub0_Life= Z_Sub0_Hex;
   Z_Sub2_Life= Z_Sub2_Hex;
   Z_WrData   = Z_Data+2;
   Z_RdData   = Z_Data+5;

   Z_Ifk_Adr   = Z_Data -3;
   Z_Mod_Adr   = Z_Data -2;
   S_Ifk_WrAdr = 40;
   S_Mod_WrAdr = S_Ifk_WrAdr;
   S_Ifk_RdAdr = S_Ifk_WrAdr+18;
   S_Mod_RdAdr = S_Ifk_RdAdr;

   S_WrData_Hex= S_Ifk_WrAdr-6;
   S_RdData_Hex= S_Ifk_RdAdr-7;
   S_WrData_Bin= S_Ifk_WrAdr-17;
   S_RdData_Bin= S_Ifk_RdAdr-12;

   Z_RdLife    = Z_Data;
   S_RdLife    = S_Mod_RdAdr-12;
   Z_WrLife    = Z_Data;
   S_WrLife    = S_Mod_WrAdr-12;

  type
       TCompare= (Long32, Wr16Hi_Rd16Hi, Wr16Lo_Rd16Lo, Wr16Hi_Rd16Lo, Wr16Lo_Rd16Hi);
       TWrRd   = (Wr, Rd);
       TData32 = record case Byte of
                  1: (li: LongInt);
                  2: (wrd: packed record
                           l : Word;
                           h : Word;
                           end)
                 end;

  var User_In     : Word;
      User_LongIn : LongInt;
      Mod_Adr     : Byte;
      Sub_Adr     : Byte;
      Rd_Sub0_Err : LONGINT;
      Rd_Sub2_Err : LONGINT;
      Ifk_AdrWr   : Byte;
      Ifk_AdrRd   : Byte;
      Mod_AdrWr   : Byte;
      Mod_AdrRd   : Byte;
      Mode_SubAdr : TModeSubAdr;
      RModCrd     : TCardAdr;
      WModCrd     : TCardAdr;
      Wr_Data_Sub0: Word;
      Wr_Data_Sub2: Word;
      Shift_Mode_Sub0 : Boolean;
      FixDataMode: Boolean;
      Start_Loop : Boolean;
      Transf_Cnt : LongInt;
      Error_Cnt  : LongInt;
      Color      : TBackColor;
      Compare32  : TCompare;
      I_32       : TData32;
      SubAdr4u6  : Boolean;




  procedure  Ini_TastMod32_Win;
   begin
    Window(02, 20, 70, 24); TextBackground(Green); TextColor(Yellow);
    Writeln ('v----------- WRITE -------------v v------ READ ------v');
    Writeln ('F1: Mod-Adr    F5: Wr-Data fix/var F9 : Mod-Adr       ');
    Writeln ('F2: Ifk-Adr    F6: Wr-Data [Hex]   F10: Ifk-Adr       ');
    Writeln ('F3: Sub0/2:4/6 F7: Clr Data+Count  F11: 32/16Bit check');
   end;

  procedure Win32_Hex4_Xy (X: Byte; Y: Byte; WData: Word;
                         BackColor: TBackColor; RdError: Boolean);
   begin
    if BackColor = Gruen     then TextBackground(Green);
    if BackColor = Rot       then TextBackground(Red);
    if BackColor = Weiss     then TextBackground(White);
    if BackColor = Magent    then TextBackground(Magenta);
    if BackColor = Blau      then TextBackground(Blue);
    if BackColor = Blank     then TextBackground(White);
    if BackColor = BlankLoop then TextBackground(White);

    GotoXY (X,Y);
    if (BackColor = Blank) or (BackColor = BlankLoop) then
      begin
       Write ('    ');
      end
    else
      begin
       if BackColor = Rot then TextColor(Yellow);
       if RdError then Write ('MIL?') else Write (Hex_Word(WData));
      end;

    if (BackColor = BlankLoop) then
     begin
       GotoXY(S_Data+12,Z_Data); TextColor(Red+128);
       Write ('    Loop! ');
     end;
    TextColor(Black);
   end; {Win32_Hex4_XY}

   procedure Display_Adr;
    begin
     Set_Text_Win;
     TextColor(Black);
     GotoXY(S_Ifk_WrAdr,Z_Ifk_Adr);   write(Hex_Byte(WModCrd.IfkNr));
     GotoXY(S_Mod_WrAdr,Z_Mod_Adr);   write(Hex_Byte(WModCrd.ModAdr));
     GotoXY(S_Ifk_RdAdr,Z_Ifk_Adr);   write(Hex_Byte(RModCrd.IfkNr));
     GotoXY(S_Mod_RdAdr,Z_Mod_Adr);   write(Hex_Byte(RModCrd.ModAdr));
    end;

   procedure Display_SubAdr;
    begin
     Set_Text_Win;        TextColor(Yellow);
     if SubAdr4u6 then begin
     GotoXY(17,Z_Info+2); write('     v--Sub-Adr['); TextColor(red);
                          write('4'); TextColor(yellow); write('] =K0--v   v--Sub-Adr['); TextColor(red);
                          write('6'); TextColor(yellow); write('] =K1--v    ');
       end
     else begin
     GotoXY(17,Z_Info+2); write('     v--Sub-Adr['); TextColor(red);
                          write('0'); TextColor(yellow); write('] =K0--v   v--Sub-Adr['); TextColor(red);
                          write('2'); TextColor(yellow); write('] =K1--v    ');
       end;
    end;

   procedure Display_Ini;
   begin
    Ini_Text_Win;        TextColor(Yellow);
    GotoXY(16,Z_Info+0); write('---- Modul-Bus Daten schreiben/lesen/prÅfen ----');
    TextColor(Blue);
    GotoXY(08,Z_Info+1); write('Setze Modul-Adr mit Fct-Code 11 [H], Wr/Rd mit Fct-Code 10/90 [H]');
    Display_SubAdr;
{
    if SubAdr4u6 then begin
    GotoXY(17,Z_Info+2); write('     v--Sub-Adr[4] =K0--v   v--Sub-Adr[6] =K1--v    ');
      end
    else begin
    GotoXY(17,Z_Info+2); write('     v--Sub-Adr[0] =K0--v   v--Sub-Adr[2] =K1--v    ');
      end;
}
    GotoXY(17,Z_Info+3); write('[Bit 31................16   15................00 Bit]');
    GotoXY(17,Z_Info+4); write('     ^-Byte3-^  ^-Byte2-^   ^-Byte1-^  ^-Byte0-^     ');

    TextColor(Blue);
    GotoXY(S_Ifk_WrAdr-12,Z_Ifk_Adr);   write('IFK-Adr[H]: ');
    GotoXY(S_Mod_WrAdr-12,Z_Mod_Adr);   write('Mod-Adr[H]: ');


    GotoXY(S_Ifk_RdAdr-12,Z_Ifk_Adr);   write('IFK-Adr[H]: ');
    GotoXY(S_Mod_RdAdr-12,Z_Mod_Adr);   write('Mod-Adr[H]: ');
    TextColor(yellow);
    GotoXY(S_Mod_WrAdr-12,Z_Mod_Adr+1); write('^-- WrAdr --^ ');
    GotoXY(S_Mod_RdAdr-12,Z_Mod_Adr+1); write('^-- RdAdr --^ ');
    Display_Adr;
    TextColor(Blue);
    GotoXY(S_Data,Z_Data  );    writeln('Wr-Data-Cnt: ');
    GotoXY(S_Data,Z_Data+1);    writeln('                ^  ^  ');
    GotoXY(S_Data,Z_WrData);    writeln('Write-Data[H]: ');
    GotoXY(S_Data,Z_WrData+1);  writeln('Error-Data[H]: ');

    GotoXY(S_WrData_Hex+2,Z_WrData+2);  writeln('----');
    GotoXY(S_WrData_Hex-3,Z_WrData+2);  writeln('----');

    GotoXY(S_Data,Z_RdData);    writeln('Read-Data [H]: ');
    GotoXY(S_Data,Z_RdData+1);  writeln('Error-Data[H]: ');
    GotoXY(S_Data,Z_RdData+2);  writeln('Error-Count: ');
   end;

 procedure Transf_And_Displ_ModbusData  (Loop_Start: Boolean;
                                         StepSingle: Boolean;
                                         RdCard    : TCardAdr;
                                         WrCard    : TCardAdr);
  var ModRdDta: Word;
      WrAdr   : TModAdr;
      RdAdr   : TModAdr;
      MilErr  : TMilErr;
      RdErr   : Boolean;
      RdDta32 : TData32;
      WrDta32 : TData32;

  begin                                             {DataTo_ModBus_And_Displ}
     WrDta32.li := I_32.li;
     Transf_Cnt := Transf_Cnt + 1;
     RdErr      := False;

     case Compare32 of
       Long32 : begin
                  {Subadr 2 = Low-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := 2;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.l, WrAdr, MilErr);

                  {Subadr 0 = Hi-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := 0;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.h, WrAdr, MilErr);

                  {Subadr 2/6 = Low-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  if SubAdr4u6 then RdAdr.AdrSub := 6 else RdAdr.AdrSub := 2;
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.l,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  {Subadr 0/4 = Hi-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  if SubAdr4u6 then RdAdr.AdrSub := 4 else RdAdr.AdrSub := 0;
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.h,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                  end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Color, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Color, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (RdDta32.li <> WrDta32.li)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Color, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Color, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Color, RdErr);
                   end;
                end; {Long32}

       Wr16Hi_Rd16Hi:
               begin
                   {Subadr 0 = Hi-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := 0;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.h, WrAdr, MilErr);

                  {Subadr 0 = Hi-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  if SubAdr4u6 then RdAdr.AdrSub := 4 else RdAdr.AdrSub := 0;
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.h,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Blank, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Blank, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Color, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (RdDta32.wrd.h <> WrDta32.wrd.h)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Blank, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Color, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Blank, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Color, RdErr);
                   end;
                end;  {Hi16}

       Wr16Lo_Rd16Lo:
                begin
                  {Subadr 2 = Low-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := 2;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.l, WrAdr, MilErr);

                  {Subadr 2 = Low-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  if SubAdr4u6 then RdAdr.AdrSub := 6 else RdAdr.AdrSub := 2;
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.l,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Blank, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Color, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Blank, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (RdDta32.wrd.l <> WrDta32.wrd.l)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Blank, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Color, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Blank, RdErr);
                   end;
                 end;

       Wr16Hi_Rd16Lo:
                begin
                   {Subadr 0 = Hi-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := 0;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.h, WrAdr, MilErr);

                  {Subadr 2 = Low-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  if SubAdr4u6 then RdAdr.AdrSub := 6 else RdAdr.AdrSub := 2;
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.l,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Blank, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Color, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Blank, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (WrDta32.wrd.h <> RdDta32.wrd.l)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Blank, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Color, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Color, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Blank, RdErr);
                   end;
                end;

       Wr16Lo_Rd16Hi:
                begin
                  {Subadr 2 = Low-Word schreiben}
                  WrAdr.AdrIfc  := WrCard.IfkNr;
                  WrAdr.AdrCard := WrCard.ModAdr;
                  WrAdr.AdrSub  := 2;
                  WrAdr.AdrMode := AdrNew;
                  Mil.Wr_ModBus (WrDta32.wrd.l, WrAdr, MilErr);

                  {Subadr 0 = Hi-Word Daten lesen}
                  RdAdr.AdrIfc  := RdCard.IfkNr;
                  RdAdr.AdrCard := RdCard.ModAdr;
                  if SubAdr4u6 then RdAdr.AdrSub := 4 else RdAdr.AdrSub := 0;
                  RdAdr.AdrMode := AdrNew;
                  Mil.Rd_ModBus (RdDta32.wrd.h,RdAdr,MilErr);
                  if MilErr <> No_Err then RdErr := True;

                  Set_Text_Win;
                  if Loop_Start then
                   begin
                    Color := BlankLoop;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, WrDta32.wrd.h, Color, False);
                   end
                  else
                   begin
                    if StepSingle then
                     begin
                      Set_Text_Win;
                      TextBackground(White);
                      GotoXY(S_Data+12,Z_Data); Writeln (Transf_Cnt:10);
                      Color := Gruen;  TextColor(Black);
                      Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData, WrDta32.wrd.l, Color, False);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData, WrDta32.wrd.h, Blank, False);

                      Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData, RdDta32.wrd.l, Blank, RdErr);
                      Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData, RdDta32.wrd.h, Color, RdErr);
                     end
                    else
                      Color := Blank;
                   end;

                  if (RdErr or (WrDta32.wrd.l <> RdDta32.wrd.h)) then
                   begin
                    Error_Cnt := Error_Cnt +1;
                    TextBackground(White); TextColor(Black);
                    GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
                    Color := Rot;
                    Win32_Hex4_XY (S_WrData_Hex+2, Z_WrData+1, WrDta32.wrd.l, Color, False);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_WrData+1, WrDta32.wrd.h, Blank, False);

                    Win32_Hex4_XY (S_WrData_Hex+2, Z_RdData+1, RdDta32.wrd.l, Blank, RdErr);
                    Win32_Hex4_XY (S_WrData_Hex-3, Z_RdData+1, RdDta32.wrd.h, Color, RdErr);
                   end;
                end;
     end; {case Compare32}
  end;   {DataTo_ModBus_And_Displ}

  procedure Disp_FV_Mode;
   begin
     Set_Text_Win;
     TextBackground(Magenta); TextColor(Yellow);
     GotoXY(02,Z_WrData);
     if FixDataMode then
       begin
         Writeln ('f');
       end
      else
       begin
         Writeln ('v');
       end;
   end;
 procedure Reset_Counters;
  begin
   I_32.li    := 0;
   Transf_Cnt := 0;
   Error_Cnt  := 0;
   Set_Text_Win;
   GotoXY(S_Data+12,Z_Data);     Writeln (Transf_Cnt:10);
   GotoXY(S_Data+12,Z_RdData+2); Writeln (Error_Cnt:10);
   {Write Daten anzeigen}
   GotoXY (S_WrData_Hex+2, Z_WrData);    Write ('0000');
   GotoXY (S_WrData_Hex-3, Z_WrData);    Write ('0000');
   {Read Daten blank}
   GotoXY (S_WrData_Hex+2, Z_RdData);    Write ('    ');
   GotoXY (S_WrData_Hex-3, Z_RdData);    Write ('    ');
   {Error-Daten blank}
   GotoXY (S_WrData_Hex+2, Z_WrData+1);  Write ('    ');
   GotoXY (S_WrData_Hex-3, Z_WrData+1);  Write ('    ');
   GotoXY (S_WrData_Hex+2, Z_RdData+1);  Write ('    ');
   GotoXY (S_WrData_Hex-3, Z_RdData+1);  Write ('    ');
  end;

 procedure Incr_Data;
  begin
    case Compare32 of
     Long32       : begin
                      if I_32.li = $FFFFFFFF then
                        I_32.li:= 0
                      else
                        I_32.li:= I_32.li + 1;
                    end; {Long32}
     Wr16Hi_Rd16Hi, Wr16Hi_Rd16Lo:
                     begin
                      if I_32.wrd.h = $FFFF then
                        I_32.li:= 0
                      else
                        I_32.wrd.h:= I_32.wrd.h + 1;
                    end;

     Wr16Lo_Rd16Lo, Wr16Lo_Rd16Hi:
                    begin
                      if I_32.wrd.l = $FFFF then
                        I_32.li:= 0
                      else
                        I_32.wrd.l:= I_32.wrd.l + 1;
                    end;
    end; {case}
  end;

  begin    {Modbus_WrRd32}
    WModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrWr}
    WModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrWr}
    RModCrd.IfkNr  := Ifc_Test_Nr;  {Ifk_AdrRd}
    RModCrd.ModAdr := Mod_Test_Nr;  {Mod_AdrRd}

    Wr_Data_Sub0    := 0;
    Wr_Data_Sub2    := 0;
    Shift_Mode_Sub0 := False;
    FixDataMode     := False;
    SubAdr4u6       := True;  {DatenrÅcklesung 32-Bit -> Outregister}
    Transf_Cnt      := 0;
    Error_Cnt       := 0;
    Compare32       := Long32;  {32-Bit-Vergleich}

    Ini_Text_Win;
    Display_Ini;
    Disp_FV_Mode;
    Ini_TastMod32_Win;
    Ini_WrRd32_Win;
    Cursor(False);       {Software-Gerippe fÅr Single-Step und Loop}
    Std_Msg;
    Ch := NewReadKey;
    I_32.li := 0;           {Datencounter bei variablen Daten}

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       Start_Loop  := False;
       Mode_SubAdr.WrMode := True;   {falls enabled: auch Daten schreiben}
       Transf_And_Displ_ModbusData (Start_Loop, Single_Step, RModCrd, WModCrd{, FixDataMode});
       if not FixDataMode then Incr_Data; {feste oder variable Daten schreiben}
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then
      begin
        Single_Step := False;
        Start_Loop  := True;   {Loop-Anzeige aktivieren!}
        Transf_And_Displ_ModbusData (Start_Loop, Single_Step, RModCrd, WModCrd{, FixDataMode});
      end;

     if not Single_Step then
      begin
       if not FixDataMode then Incr_Data; {feste oder variable Daten schreiben}
       Mode_SubAdr.WrMode := True; {falls enabled: auch Daten schreiben}
       Start_Loop  := False;
       Transf_And_Displ_ModbusData (Start_Loop, Single_Step, RModCrd, WModCrd{, FixDataMode});
      end;

     if Ch = #0 then                  {Sonder-Tasten Abfrage}
      begin
       Ch := NewReadKey;
       case ord (Ch) of
        Taste_F1 : begin
                    Clr_WrRd32_Win;
                    Show_Mod_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       WModCrd.ModAdr:= User_In;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Std_Msg;
                   end;

        Taste_F2 : begin
                    Clr_WrRd32_Win;
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        WModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Std_Msg;
                   end;

        Taste_F3 : begin
                    if SubAdr4u6 then SubAdr4u6:= False else SubAdr4u6 := True;
                    Display_SubAdr;
                    Std_Msg;
                   end;

        Taste_F5: begin
                    if FixDataMode then FixDataMode:=False else FixDataMode:=True;
                    Disp_FV_Mode;
                    Std_Msg;
                  end;

         Taste_F6: begin
                   if Ask_Hex_LongInteger_Break (User_LongIn) then
                     begin
                      I_32.li := User_LongIn;
                     end;
                    Std_Msg;
                    Ch := '?';
                  end;

        Taste_F7: begin
                   Reset_Counters;
                   Single_Step := True;
                   Ch := '?';
                  end;

        Taste_F8: begin
                  end;

        Taste_F9: begin
                    Clr_WrRd32_Win;
                    Show_Mod_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                       RModCrd.ModAdr:= User_In;
                       Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Reset_Counters;
                    Std_Msg;
                   end;
        Taste_F10: begin
                    Clr_WrRd32_Win;
                    Show_Ifk_Online;
                    if Ask_Hex_Break (User_In, Byt) then
                      begin
                        RModCrd.IfkNr := User_In;
                        Display_Adr;
                      end;
                    Clr_Online_Win;
                    Ini_WrRd32_Win;
                    Std_Msg;
                   end;
        Taste_F11: begin
                     Ini_Msg_Win;
                     Cursor(True);
                     Write ('?? 32-Bit: [');
                     TextColor(Blue); Write ('1'); TextColor(Yellow); Write(']Alle, [');
                     TextColor(Blue); Write ('2'); TextColor(Yellow); Write(']High16, [');
                     TextColor(Blue); Write ('3'); TextColor(Yellow); Write(']Low16, [');
                     TextColor(Blue); Write ('4'); TextColor(Yellow); Write(']Wr16Hi_Rd16Lo, [');
                     TextColor(Blue); Write ('5'); TextColor(Yellow); Write(']Wr16Lo_Rd16Hi: ');
                     Ch := NewReadKey;
                     case Ch of
                      '1' : Compare32 := Long32;
                      '2' : Compare32 := Wr16Hi_Rd16Hi;
                      '3' : Compare32 := Wr16Lo_Rd16Lo;
                      '4' : Compare32 := Wr16Hi_Rd16Lo;
                      '5' : Compare32 := Wr16Lo_Rd16Hi;
                     end; {case}
                     Single_Step := True;
                     Reset_Counters;
                     Std_Msg;
                     Cursor(False);
                   end;
      end;  {Case}
     end;
    if KeyEPressed then Ch := NewReadKey;
   until Ch in ['x','X'];
   Cursor(True);
  end; {Modul_WrRd32}
