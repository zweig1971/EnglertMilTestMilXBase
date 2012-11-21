PROGRAM MilxBase;
{$APPTYPE CONSOLE}
{ Autor des Basis-Programmes Mil_Base.PAS: G. Englert;      Erstellt 12.04.95
  Basis-Programm als Grundlage fÅr anwender-spezifische Erweiterungen
  Achtung: Bei Erweiterungen den Namen des Programmes Ñndern in MIL_xxxx.PAS
  Wegen Jahr 2000: File-Datum unter DOS ist ab 1.1.2000 -> 01.01.80

  énderungs-Protokoll:
  23.06.95    Et        Funktionscode-Tabelle
  29.06.95    Et        Statusbits fÅr C0, C1, C2, C3
  13.07.95    Et        neue Functions-Code-Tabelle
  23.08.95    Et        Statusbits-Tabellen
  15.09.95    Et        Wegen zu gro·em Codesegment (ca. 64k) einige Proceduren
                        in die DATECH.PAS ausgelagert
                        z. B. Displ_PC_Stat; Displ_HS_Status; Displ_HS_Ctrl;
  21.09.95    Et        Status-Tabs erweitert: in DATECH.PAS
  06.10.95    Et        Statuslesen C0-C2 mit Timeout-Anzeige
  30.11.95    Et        MIL-Detect-Compare: Anzeige korrigiert
  08.12.95    Et        Anzeige Interrupt-Maske
  11.01.95    Et        procedure Mil-Loop Fifo leeren eingebaut
  04.02.96    Et        Status-Tabelle [5] erweitert
  14.02.96              ZusÑtzliche Unit: DATECH_1
  25.04.96              MenÅ A erweiterte Auswahl
  25.06.96              MenÅ A: Auch bei 0 IFK: Eingabe von Adr-Nr erlaubt
  04.09.96              MenÅ 4: PrÅfung der RetAdr bei C0, C1, C3
  15.10.96              MenÅ E: Darstellung der Fct-Codes vertauscht
  25.03.97              BELAB und Farbe Blue fÅr Anwender
  06.05.97              Modul_Bus Erweiterung, globale Mod_Test_Nr
  28.07.97              Dual-Mode: Read-Daten öberprÅfung eingebaut; spez fÅr DEVBus-Expander
  08.08.97              IFC-Nr Abfrage neu
  02.09.97              B: Status lesen bei IFK-Nr wechsel jetzt ok.
  12.11.98              Brown als Farbe vermeiden, da ATI-Karten Frabe falsch darstellen!!
  04.01.99              Y: Finde IFK`s
  06.04.99              IFK-Mode ins Menue Punkt 8/9
  23.02.00              Wegen MIL-Timeout neu compiliert
}
{$S-}
uses
  Crt32,
  Datech,
  Datech_0,
  Datech_1,
  DATECH_2 in 'DATECH_2.PAS';

{spez. MIL-Routinen in Units Datech..}

const
 Head_Line =
      'BELAB                                MILxBASE   ' +
      '                    [09.03.2001]' +
      '                        Allgemeines Devicebus Testprogramm                     ';

 procedure menue_win;
  var answer: CHAR;
 begin
  Ini_Headl_Win;
  Write(Head_Line);
  Menue_Base;            {Festliegender Teil des MenÅs: s. a. DATECH_0.PAS}
  TextColor(Blue);

   {Ab hier kann der Anwender seine MenÅ-Punkte eintragen}

{
  GotoXY(5, 14);
  Writeln('       [M]<--                                                            ');
  GotoXY(5, 15);
  Writeln('       [N]<--                                                            ');
  GotoXY(5, 16);
  Writeln('       [O]<--                                                            ');
  GotoXY(5, 17);
  Writeln('       [P]<--                                                            ');
  GotoXY(5, 18);
  Writeln('       [Q]<--                                                            ');
  GotoXY(5, 19);
  Writeln('       [R]<--                                                            ');
  GotoXY(5, 20);
  Write  ('       [S]<--                                                            ');
  GotoXY(5, 21);
  Write  ('       [T]<--                                                            ');
  GotoXY(5, 22);
  Write  ('       [U]<--                                                            ');
}
  Ini_Msg_Win;
  Write('Bitte Auswahl eingeben:                                          EXIT: X-Taste ');
 end; {menue_win}
{
Bisherige Routinen f. alle Anwender gleich! Ab hier spezielle User-Routinen
}

begin                      { Hauptprogramm }
  Ifc_Test_Nr := 0;
  Mod_Test_Nr := 0;
  repeat
    Menue_Win;
    //User_Input  := NewReadKey;
    User_Input := readkey;
    Single_Step := True;
    case User_Input of
     '0'      : Mil_Detect_Ifc;
     '1'      : Mil_Detect_Ifc_Compare;
     '2'      : begin
		  Mil_Ask_Ifc;
                  Mil_Rd_HS_Ctrl (Ifc_Test_Nr);
                end;
     '3'      : begin
		{  Mil_Ask_Ifc;                    }
                {  Mil_Rd_HS_Status (Ifc_Test_Nr); }
                end;
     '4'      : begin
		  Mil_Ask_Ifc;
                  Mil_Stat_All (Ifc_Test_Nr);
                end;
     '5'      : begin
                  Convert_Hex_Volt;
                end;
     '6'      : begin
                  Int_Mask;
                end;
     '8'      : begin
		  Mil_Ask_Ifc ;
                  Mil_Echo (Ifc_Test_Nr);
                end;
     '9'      : begin
		  Mil_Ask_Ifc ;
                  Mil_IfkMode;
                end;
     'a', 'A' :  Mil_Ask_Ifc;
     'b', 'B' : begin
		 Mil_Ask_Ifc;
                 Mil_Rd_Ifc_Stat (Ifc_Test_Nr);
                end;
     'c', 'C' : begin
                  Mil_Rd_Status;
                end;
     'd', 'D' : begin
                  Mil_Rd_Fifo;
                end;
     'e', 'E' : begin
		  Mil_Ask_Ifc;
                  Mil_Rd_Data;
		end;
     'f', 'F' : begin
                  Functioncode_Table;
                end;
     'g', 'G' : begin
		  Mil_Ask_Ifc;
                  if Ask_Data_Break (Mil_Data) then Mil_WrData (Mil_Data);
                end;
     'h', 'H' : begin
		  Mil_Ask_Ifc;
		  Mil_Wr_Fctcode;
                end;
     'i', 'I' : begin
		  Mil_Ask_Ifc;
                  Mil_Data := 0;
                  Mil_Wr (Mil_Data);
                end;
     'j', 'J' : begin
		  Mil_Ask_Ifc;
                  if Ask_Data_Break (Mil_Data) then Mil_Wr_Rd (Mil_Data);
                end;
     'k', 'K' : begin
		  Mil_Ask_Ifc;
		  Mil_Loop;
                end;
     'l', 'L' : begin
                  Mil_Dual_Mode;
                end;
     'y', 'Y' : begin
                  Modul_Bus;
                end;
     'z', 'Z' : begin
                  Telefon;
                end;
     {Ab hier User-Erweiterungen!!}
          'm', 'M' : begin
                     end;
          'n', 'N' : begin
                     end;
          'o', 'O' : begin
                     end;
          'p', 'P' : begin
                     end;
          'q', 'Q' : begin
                     end;
          'r', 'R' : begin
                     end;
          's', 'S' : begin
                     end;
          't', 'T' : begin
                     end;
          'u', 'U' : begin
                     end;
    end; {CASE}
  until user_input in ['x','X'];
  Window(1, 1, 80, 25);
  TextBackground(Black);
  ClrScr;
end. {mil_base}


                     {Software-Gerippe fÅr Single-Step und Loop}
    Cursor(False);
    Std_Msg;
    Ch := NewReadKey;

    repeat
     if Ch = ' ' then
      begin
       Std_Msg;
       Single_Step := True;
       {User Action }
       repeat until KeyEPressed;
       Ch := NewReadKey;
      end;

     if Ch = #13 then Single_Step := False;

     if not Single_Step then
      begin
       {User Action}
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


