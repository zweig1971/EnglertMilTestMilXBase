unit DATECH_2;  {Eine zusÑtzliche Datentechnik Library TURBO PASCAL V 7.0}
{
  Changes:
  11.05.99      Neue MagTab
}
{$S-}
interface                       { Teil der UNIT-Deklaration }
uses Crt32, Datech_1;     {graph, dos wegen cursor}

                 {Proceduren der Au·enwelt bekanntmachen}

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


implementation                                    {Teil der UNIT-Deklaration}

   procedure Ini_Stat_Win;
   begin                             {Definitionen gelten bis neu definiert}
    Window(1, 1, 80, 2);             {Definiert ein Textfenster: Spalte/Zeile}
    TextBackground(Magenta);         {Setze Hintergrund fÅr Textfenster}
    TextColor(Yellow);               {Setze Schriftfarbe}
    ClrScr;                          {Clear Window}
    GotoXY(1, 1);                    {Cursor auf Anfang Fenster}
   end;

  const IFC_Color = White;

  procedure Status_Tab1 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '              Tabelle[1]: SIS-Magnete SVE        Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';

   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00  GerÑt AUS         3A  Byte C0H       16  xx Hand (local)  22A  Byte C2H');
    Writeln ('    01  xy Unterspg Phas  3C                 17  y StraSchuIntrl  22C         ');
    Writeln ('    02  xy Temp. NG       4A                 18  Last1 Aus        23A         ');
    Writeln ('    03  xy KÅhlwasser NG  4C                 19  Last2 Aus        23C         ');
    Writeln ('    04  xy öberstrom      5A                 20  Last3 Aus        24A         ');
    Writeln ('    05  PolaritÑt minus   5C                 21  Last4 Aus        24C         ');
    Writeln ('    06  xy Temp. Last     6A                 22  Last5 Aus        25A         ');
    Writeln ('    07  xy H2O-Last       6C                 23  Reserve (High)   25C         ');
    Writeln;
    Writeln ('    08  y PrimÑrstr > Ip 26A  Byte C1H                                        ');
    Writeln ('    09  y PrimÑrstr >Ip1 26C                                                  ');
    Writeln ('    10  y TransiFehlV1-4 27A                                                  ');
    Writeln ('    11  y TransiFehl  V5 27C                                                  ');
    Writeln ('    12  y Gleichspg Ud1  28A                                                  ');
    Writeln ('    13  y Hilfs UB0 Fehl 28C                                                  ');
    Writeln ('    14  y DCCT Fehl Holc 29A                                                  ');
    Writeln ('    15  y Erdschlu·      29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab2 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '            Tabelle[2]: Tekelec-EH-Umlenker      Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  xx Hand          22A  Byte C2H');
    Writeln ('    01 xy Unterspng Netz  3C                 17  High             22C         ');
    Writeln ('    02 xy Temp.  NG Trafo 4A                 18  Last1 Aus        23A         ');
    Writeln ('    03 xy Wasser NG       4C                 19  Last2 Aus        23C         ');
    Writeln ('    04 xy öberstrom I >   5A                 20  Last3 Aus        24A         ');
    Writeln ('    05    Reserve (High)  5C                 21  Last4 Aus        24C         ');
    Writeln ('    06 xy Temp.  Last     6A                 22  Last5 Aus        25A         ');
    Writeln ('    07 xy H2O     "       6C                 23  Reserve (High)   25C         ');
    Writeln;
    Writeln ('    08 y ö-Strom Prim Ip 26A  Byte C1H                                        ');
    Writeln ('    09 y Reserve (High)  26C                                                  ');
    Writeln ('    10 y TransiFehl T1-4 27A                                                  ');
    Writeln ('    11 y Reserve (High)  27C                                                  ');
    Writeln ('    12 y Temp Transistr  28A                                                  ');
    Writeln ('    13 y Temp Gleichrich 28C                                                  ');
    Writeln ('    14 y Sicherung Kond  29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab3 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '         Tabelle[3]: Tekelec-NetzgerÑte LSB4     Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  xx Hand          22A  Byte C2H');
    Writeln ('    01 xy Unterspannung   3C                 17  High             22C         ');
    Writeln ('    02 xy Temp.  NG Trafo 4A                 18  Last1 Aus        23A         ');
    Writeln ('    03 xy Wasser NG       4C                 19  (Last2 Aus)      23C         ');
    Writeln ('    04 xy öberstrom I >   5A                 20  (Last3 Aus)      24A         ');
    Writeln ('    05    Reserve (High)  5C                 21  (Last4 Aus)      24C         ');
    Writeln ('    06 xy Temp.  Last     6A                 22  (Last5 Aus)      25A         ');
    Writeln ('    07 xy H2O      "      6C                 23  Reserve (High)   25C         ');
    Writeln;
    Writeln ('    08 y Reserve (High)  26A  Byte C1H                                        ');
    Writeln ('    09 y ö-Strom Pri Ip1 26C                                                  ');
    Writeln ('    10 y Trans Fehl T1-4 27A                                                  ');
    Writeln ('    11 y Reserve (High)  27C                                                  ');
    Writeln ('    12 y Temp Transistr  28A                                                  ');
    Writeln ('    13 y Temp Gleichrich 28C                                                  ');
    Writeln ('    14 y Reserve (High)  29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab4 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '          Tabelle[4]: Danfysik-NetzgerÑte EH     Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  xx Hand          22A  Byte C2H');
    Writeln ('    01 xy Unterspannung   3C                 17  High             22C         ');
    Writeln ('    02 xy Temp.   NG      4A                 18  Last1 Aus        23A         ');
    Writeln ('    03 xy Wasser  NG      4C                 19  Last2 Aus        23C         ');
    Writeln ('    04 xy öberstrom I >   5A                 20  Last3 Aus        24A         ');
    Writeln ('    05    Reserve (High)  5C                 21  Last4 Aus        24C         ');
    Writeln ('    06 xy Temp.  Last     6A                 22  Last5 Aus        25A         ');
    Writeln ('    07 xy H2O     "       6C                 23  Reserve (High)   25C         ');
    Writeln;
    Writeln ('    08 y ö-Strom Prim Ip 26A  Byte C1H                                        ');
    Writeln ('    09 y Reserve (High)  26C                                                  ');
    Writeln ('    10 y TransiFehl T1-4 27A                                                  ');
    Writeln ('    11 y Reserve (High)  27C                                                  ');
    Writeln ('    12 y (Temp Trnsistr) 28A                                                  ');
    Writeln ('    13 y Mitnahme (Stîrg)28C                                                  ');
    Writeln ('    14 y Reserve (High)  29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab5 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '           Tabelle[5]: SVE 1 - SIS               Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A Byte C0H       16 y Laufz-Last-Tren  22A Byte C2H');
    Writeln ('    01 y 0 =Last-Trenn zu 3C                17 y GS - Drosseln    22C        ');
    Writeln ('    02 y SIS - 12 Aus     4A                18 y Magkabl Temp+H2O 23A        ');
    Writeln ('    03 y SIS - 18 Aus     4C                19 y Magnete Temp+H2O 23C        ');
    Writeln ('    04 y Hand             5A                20 y 20 KV Filter     24A        ');
    Writeln ('    05   Nicht betrbereit 5C                21 y 24 V und U <     24C        ');
    Writeln ('    06 y öberstrom I >    6A                22   60 V und U <     25A        ');
    Writeln ('    07 y öberstrom I >>   6C                23 y Erd/TempTraf/Gas 25C        ');
    Writeln;
    Writeln ('    08 y Trafo Fehler    26A  Byte C1H                                        ');
    Writeln ('    09   Mitn.Qkupl 20kV 26C                                                  ');
    Writeln ('    10 y Not - Aus       27A                                                  ');
    Writeln ('    11   Hilfenerg. Rglg 27C                                                  ');
    Writeln ('    12 y Stromricht Rglg 28A                                                  ');
    Writeln ('    13 y Stromri. Leistg 28C                                                  ');
    Writeln ('    14 y Paralell Einspg 29A                                                  ');
    Writeln ('    15 y PE KÅhlung      29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab6 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '          Tabelle[6]: SVE 2 - SIS                Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A Byte C0H       16 y Laufz-Last-Tren  22A Byte C2H');
    Writeln ('    01 y 0 =Last-Trenn zu 3C                17 y GS - Drosseln    22C        ');
    Writeln ('    02   Reserve (High)   4A                18 y Magkabl Temp+H2O 23A        ');
    Writeln ('    03   Reserve (High)   4C                19 y Magnete Temp+H2O 23C        ');
    Writeln ('    04 y Hand             5A                20 y 20 KV Filter     24A        ');
    Writeln ('    05   Nicht betrbereit 5C                21 y 24 V und U <     24C        ');
    Writeln ('    06 y öberstrom I >    6A                22   60 V und U <     25A        ');
    Writeln ('    07 y öberstrom I >>   6C                23 y Erd/TempTraf/Gas 25C        ');
    Writeln;
    Writeln ('    08 y Trafo Fehler    26A  Byte C1H                                        ');
    Writeln ('    09   Mitn.Qkupl 20kV 26C                                                  ');
    Writeln ('    10 y Not - Aus       27A                                                  ');
    Writeln ('    11   Hilfenerg. Rglg 27C                                                  ');
    Writeln ('    12 y Stromricht Rglg 28A                                                  ');
    Writeln ('    13 y Stromri. Leistg 28C                                                  ');
    Writeln ('    14 y Paralell Einspg 29A                                                  ');
    Writeln ('    15 y PE KÅhlung      29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_Tab7 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '     Tabelle[7]: SVE 1 - ESR  2 - ESR  3 - ESR   Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A Byte C0H       16 y Laufz-Last-Tren  22A Byte C2H');
    Writeln ('    01 y 0 =Last-Trenn zu 3C                17 y GS - Drosseln    22C        ');
    Writeln ('    02   Reserve (High)   4A                18 y Magkabl Temp+H2O 23A        ');
    Writeln ('    03   Reserve (High)   4C                19 y Magnete Temp+H2O 23C        ');
    Writeln ('    04 y Hand             5A                20 y 20 KV Filter     24A        ');
    Writeln ('    05   Nicht betrbereit 5C                21 y 24 V und U <     24C        ');
    Writeln ('    06 y öberstrom I >    6A                22   60 V und U <     25A        ');
    Writeln ('    07 y öberstrom I >>   6C                23 y Erd/TempTraf/Gas 25C        ');
    Writeln;
    Writeln ('    08 y Trafo Fehler    26A  Byte C1H                                        ');
    Writeln ('    09   Mitn.Qkupl 20kV 26C                                                  ');
    Writeln ('    10 y Not - Aus       27A                                                  ');
    Writeln ('    11   Hilfenerg. Rglg 27C                                                  ');
    Writeln ('    12 y Stromricht Rglg 28A                                                  ');
    Writeln ('    13 y Stromri. Leistg 28C                                                  ');
    Writeln ('    14 y Paralell Einspg 29A                                                  ');
    Writeln ('    15 y PE KÅhlung      29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_Tab8 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '  Tabelle[8]: SVE 5 -, 6 -, 7 -, 10 -, 12 - ESR  Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  Hand            22A  Byte C2H');
    Writeln ('    01 y Phase            3C                 17  Reserve (High)  22C         ');
    Writeln ('    02 y SVE Temperatur   4A                 18  Reserve (High)  23A         ');
    Writeln ('    03 y SVE Wasser       4C                 19  Reserve (High)  23C         ');
    Writeln ('    04 y öberstrom I >    5A                 20  Reserve (High)  24A         ');
    Writeln ('    05   Reserve (High)   5C                 21  Reserve (High)  24C         ');
    Writeln ('    06 y Temp.  Magnet    6A                 22  Reserve (High)  25A         ');
    Writeln ('    07 y Wasser   "       6C                 23  Reserve (High)  25C         ');
    Writeln;
    Writeln ('    08 y I primÑr        26A  Byte C1H                                        ');
    Writeln ('    09   Reserve (High)  26C                                                  ');
    Writeln ('    10 y Transistor Bank 27A                                                  ');
    Writeln ('    11   Reserve (High)  27C                                                  ');
    Writeln ('    12   Reserve (High)  28A                                                  ');
    Writeln ('    13   Reserve (High)  28C                                                  ');
    Writeln ('    14 y DCCT sat.       29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_Tab9 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '          Tabelle[9]: SVE 4 - 9  ESR             Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  Hand            22A  Byte C2H');
    Writeln ('    01 y Phase            3C                 17  Reserve (High)  22C          ');
    Writeln ('    02 y SVE Temperatur   4A                 18  Reserve (High)  23A          ');
    Writeln ('    03 y SVE Wasser       4C                 19  Reserve (High)  23C          ');
    Writeln ('    04 y öberstrom I >    5A                 20  Reserve (High)  24A          ');
    Writeln ('    05 y Reserve (High)   5C                 21  Reserve (High)  24C          ');
    Writeln ('    06 y Temp. Magnet     6A                 22  Reserve (High)  25A          ');
    Writeln ('    07 y Wasser    "      6C                 23  Reserve (High)  25C          ');
    Writeln;
    Writeln ('    08 y öberstrom IP    26A  Byte C1H                                        ');
    Writeln ('    09 y öberstrom IP1   26C                                                  ');
    Writeln ('    10 y TransiFehlrT1-4 27A                                                  ');
    Writeln ('    11 y TransiFehler T5 27C                                                  ');
    Writeln ('    12 y Ud1 > Kond.bank 28A                                                  ');
    Writeln ('    13 y UB0 < Vers.Anst 28C                                                  ');
    Writeln ('    14 y DCCT sat. I >   29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_TabA (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '           Tabelle[A]: SVE 2 - H   3 - H         Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  Hand            22A  Byte C2H');
    Writeln ('    01 y Phase            3C                 17  Reserve (High)  22C          ');
    Writeln ('    02 y SVE Temperatur   4A                 18  Reserve (High)  23A          ');
    Writeln ('    03 y SVE Wasser       4C                 19  Reserve (High)  23C          ');
    Writeln ('    04 y öberstrom I >    5A                 20  Reserve (High)  24A          ');
    Writeln ('    05 y PolaritÑt        5C                 21  Reserve (High)  24C          ');
    Writeln ('    06 y Temp Magnet/Kabl 6A                 22  Reserve (High)  25A          ');
    Writeln ('    07 y Wasser    "      6C                 23  Reserve (High)  25C          ');
    Writeln;
    Writeln ('    08 y Trafo I>Dreieck 26A  Byte C1H                                        ');
    Writeln ('    09 y Trafo I > Stern 26C                                                  ');
    Writeln ('    10 y Thyristor Si    27A                                                  ');
    Writeln ('    11 y Leistgschalt I> 27C                                                  ');
    Writeln ('    12 y Passivfilter    28A                                                  ');
    Writeln ('    13 y TÅrkontakt      28C                                                  ');
    Writeln ('    14 y DCCT sat.       29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_TabB (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '           Tabelle[B]: SVE-Brucker m. Einschub   Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  y Hand          22A  Byte C2H');
    Writeln ('    01 x U-Spg. PhasFehlr 3C                 17  Reserve (High)  22C          ');
    Writeln ('    02 x Temperatur NG    4A                 18  Last1   (High)  23A          ');
    Writeln ('    03 x Wasser     NG    4C                 19  Last2 Aus(offen)23C          ');
    Writeln ('    04 x öberstrom        5A                 20  Last3 Aus(offen)24A          ');
    Writeln ('    05 x Polwender Minus  5C                 21  Last4 Aus(offen)24C          ');
    Writeln ('    06 x Temp.  Last      6A                 22  Last5 Aus(offen)25A          ');
    Writeln ('    07 x Wasser Last      6C                 23  Reserve (High)  25C          ');
    Writeln;
    Writeln ('    08   Reserve (High)  26A  Byte C1H                                        ');
    Writeln ('    09   Reserve (High)  26C                                                  ');
    Writeln ('    10   Reserve (High)  27A                                                  ');
    Writeln ('    11   Reserve (High)  27C                                                  ');
    Writeln ('    12   Reserve (High)  28A                                                  ');
    Writeln ('    13   Reserve (High)  28C                                                  ');
    Writeln ('    14   Reserve (High)  29A                                                  ');
    Writeln ('    15   Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_TabC (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '           Tabelle[C]: SVE-Brucker 8-Bit-Status  Stand: 25.11.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H                                         ');
    Writeln ('    01 x U-Spg. PhasFehlr 3C                                                  ');
    Writeln ('    02 x Temperatur NG    4A                                                  ');
    Writeln ('    03 x Wasser     NG    4C                                                  ');
    Writeln ('    04 x öberstrom        5A                                                  ');
    Writeln ('    05 x Polwender Minus  5C                                                  ');
    Writeln ('    06 x Temp.  Last      6A                                                  ');
    Writeln ('    07 x Wasser Last      6C                                                  ');
    Writeln;
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;


 procedure Status_TabD (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '           Tabelle[D]: EZR-MV                    Stand: 26.02.98' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  y Hand          22A  Byte C2H');
    Writeln ('    01 x Ext. Fehler Mem. 3C                 17  HV nicht bereit 22C          ');
    Writeln ('    02 x Ext. Fehler      4A                 18  HF aus (Last1)  23A          ');
    Writeln ('    03 x Ausfall KÅhlung  4C                 19  offen  (Last2)  23C          ');
    Writeln ('    04 x I Anode zu gro·  5A                 20  offen  (Last3)  24A          ');
    Writeln ('    05 x ARC (Lichtbogen) 5C                 21  offen  (Last4)  24C          ');
    Writeln ('    06 x PrÅck  >         6A                 22  offen  (Last5)  25A          ');
    Writeln ('    07 x TÅr offen        6C                 23  Reserve (High)  25C          ');
    Writeln;
    Writeln ('    08   Reserve (High)  26A  Byte C1H                                        ');
    Writeln ('    09   T zu kalt Fila  26C                                                  ');
    Writeln ('    10   Delta HV (1min) 27A                                                  ');
    Writeln ('    11   Reserve (High)  27C                                                  ');
    Writeln ('    12   Modus Vorheizen 28A                                                  ');
    Writeln ('    13   Reserve (High)  28C                                                  ');
    Writeln ('    14   Reserve (High)  29A                                                  ');
    Writeln ('    15   Body Current    29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_TabE (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '               Tabelle[E]: Hochspannung          Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY (Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  xx Hand (local)  22A  Byte C2H');
    Writeln ('    01   x Unterspannung  3C                 17  StraSchuIntrl    22C         ');
    Writeln ('    02   x Ext. Interlock 4A                 18  Last1 Aus (High) 23A (no IBegr');
    Writeln ('    03   x Temperatur     4C                 19  Last2 Aus (offen)23C (no UBegr');
    Writeln ('    04   x HV-Kammern Aus 5A                 20  Last3 Aus (offen)24A         ');
    Writeln ('    05   PolaritÑt minus  5C                 21  Last4 Aus (offen)24C         ');
    Writeln ('    06   x HV-Interlock   6A                 22  Last5 Aus (offen)25A         ');
    Writeln ('    07   x Reserve (High) 6C                 23  Reserve (High)   25C         ');
    Writeln;
    Writeln ('    08   Spannungsmode   26A  Byte C1H                                        ');
    Writeln ('    09   Strommode       26C                                                  ');
    Writeln ('    10   Standby Lstg.aus27A                                                  ');
    Writeln ('    11   HV 50%          27C                                                  ');
    Writeln ('    12   Reserve (High)  28A                                                  ');
    Writeln ('    13   Reserve (High)  28C                                                  ');
    Writeln ('    14   Reserve (High)  29A                                                  ');
    Writeln ('    15   Reserve (High)  29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_TabF (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '               Tabelle[F]: HF: SIS + ESR         Stand: 21.11.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY (Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16 xx KavitÑt H2O    22A  Byte C2H');
    Writeln ('    01   xy Hand (local)  3C                 17 y  "    LÅfter    22C         ');
    Writeln ('    02   xy intern H2O    4A                 18 y  "    Temp. H2O 23A         ');
    Writeln ('    03   xy extern H2O    4C                 19 y  " öberschl GAP 23C         ');
    Writeln ('    04   xy Temp. Luft    5A                 20 y  " Schlu·   GAP 24A         ');
    Writeln ('    05   xy Phase Netz    5C                 21 y  " Vakuum       24C         ');
    Writeln ('    06   xy I  >  Netz    6A                 22 y Reserve (High)  25A         ');
    Writeln ('    07   xy Netzg TÅr+Not 6C                 23 y KavitÑt TÅr+Not 25C         ');
    Writeln;
    Writeln ('    08   y Endstufe H2O  26A  Byte C1H                                        ');
    Writeln ('    09   y  "     LÅfter 26C                                                  ');
    Writeln ('    10   y  " Temp. H2O  27A                                                  ');
    Writeln ('    11   y  " Manometer  27C                                                  ');
    Writeln ('    12   y  " HV-Stecker 28A                                                  ');
    Writeln ('    13   y  " IgnitrZÅnd 28C                                                  ');
    Writeln ('    14   y Reserve (High)29A                                                  ');
    Writeln ('    15   y Endst TÅr+Not 29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;


  procedure Status_Tab10 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '     Tabelle[10]: 8-Bit-Status o. Schaltkarte    Stand: 24.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY (Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H                                         ');
    Writeln ('    01   Hand (local)     3C                                                  ');
    Writeln ('    02   n. Schnittstplan 4A                                                  ');
    Writeln ('    03        "           4C                                                  ');
    Writeln ('    04        "           5A                                                 ');
    Writeln ('    05        "           5C                                                 ');
    Writeln ('    06        "           6A                                                 ');
    Writeln ('    07        "           6C                                                 ');
    Writeln;
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln (' ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab11 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '     Tabelle[11]: Phasensonden (DPX)             Stand: 12.12.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY (Spalte_Start+01, Zeile_Start);
    Writeln ('   00  Powr VerstÑrk Aus 3A  Byte C0H                                         ');
    Writeln ('    01  Powr Sumierer Aus 3C                                                  ');
    Writeln ('    02  Powr Multiplx Aus 4A                                                  ');
    Writeln ('    03  Blendanschl Nicht 4C                                                  ');
    Writeln ('    04  Bedien Blend Hand 5A                                                 ');
    Writeln ('    05  Tunnelkarte Nicht 5C                                                 ');
    Writeln ('    06  LSB-Karte   Nicht 6A                                                 ');
    Writeln ('    07  Reserve           6C                                                 ');
    Writeln;
    Writeln ('  ');
    Writeln ('  ');
    Writeln ('  ');
    Writeln ('  ');
    Writeln ('  ');
    Writeln ('  ');
    Writeln ('  ');
    Writeln ('  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

  procedure Status_Tab12 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '     Tabelle[12]: SIS-Magnet S11MU3R (JÑger)     Stand: 25.02.97' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';

   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00     GerÑt AUS      3A  Byte C0H       16  xx Hand (local)  22A  Byte C2H');
    Writeln ('    01  xy Unterspg Phas  3C                 17  y Einsperre 1min 22C         ');
    Writeln ('    02  xy Temp. NG       4A                 18  öStrom TransBank 23A         ');
    Writeln ('    03  xy KÅhlwasser NG  4C                 19  SchutzÅnd V8-V16 23C         ');
    Writeln ('    04  xy öberstrom Sek. 5A                 20  öSpg LinearBank  24A         ');
    Writeln ('    05     öStrom Prim 2  5C                 21  TrFehl V5/LinBank24C         ');
    Writeln ('    06  xy Temp. Last     6A                 22  DCCT T11 I gesÑtt25A         ');
    Writeln ('    07  xy H2O-Last       6C                 23  Erdschl. Warnung 25C         ');
    Writeln;
    Writeln ('    08  y öSpannung Ud1  26A  Byte C1H                                        ');
    Writeln ('    09  y öSpannung Uc   26C                                                  ');
    Writeln ('    10  y Sicherung F22  27A                                                  ');
    Writeln ('    11  y Sicherung F21  27C                                                  ');
    Writeln ('    12  y TransistorV1-V428A                                                  ');
    Writeln ('    13  y DCCT T9 IgesÑt 28C                                                  ');
    Writeln ('    14  y Delta Uc >Puls 29A                                                  ');
    Writeln ('    15  y C7 ZwangsEntldg29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_Tab13 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '      Tabelle[13]: SIS + ESR mit DAC (Fîldi)     Stand: 26.09.96' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  Hand            22A  Byte C2H');
    Writeln ('    01 y Phase            3C                 17  Reserve (High)  22C         ');
    Writeln ('    02 y SVE Temperatur   4A                 18  Reserve (High)  23A         ');
    Writeln ('    03 y SVE Wasser       4C                 19  Reserve (High)  23C         ');
    Writeln ('    04 y öberstrom I >    5A                 20  Reserve (High)  24A         ');
    Writeln ('    05   Polwender Minus  5C                 21  Reserve (High)  24C         ');
    Writeln ('    06 y Temp.  Magnet    6A                 22  Reserve (High)  25A         ');
    Writeln ('    07 y Wasser   "       6C                 23  Reserve (High)  25C         ');
    Writeln;
    Writeln ('    08 y I primÑr        26A  Byte C1H                                        ');
    Writeln ('    09   Reserve (High)  26C                                                  ');
    Writeln ('    10 y Transistor Bank 27A                                                  ');
    Writeln ('    11   Reserve (High)  27C                                                  ');
    Writeln ('    12   Reserve (High)  28A                                                  ');
    Writeln ('    13   Reserve (High)  28C                                                  ');
    Writeln ('    14 y DCCT sat.       29A                                                  ');
    Writeln ('    15 y Erdschlu·       29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;

 procedure Status_Tab14 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '      Tabelle[14]: 15kV-Chopper                  Stand: 15.04.99' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';
   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00   GerÑt AUS        3A  Byte C0H       16  Hand            22A  Byte C2H');
    Writeln ('    01 y Untrspg PhasFehl 3C                 17                  22C         ');
    Writeln ('    02 y Sicherung Q1     4A                 18  Last 1 aus      23A         ');
    Writeln ('    03   Reserve (High)   4C                 19  Reserve (High)  23C         ');
    Writeln ('    04   Reserve (High)   5A                 20  Reserve (High)  24A         ');
    Writeln ('    05   Reserve (High)   5C                 21  Reserve (High)  24C         ');
    Writeln ('    06 y Ext. Stîrung     6A                 22  Reserve (High)  25A         ');
    Writeln ('    07 y HV + Netz        6C                 23  Reserve (High)  25C         ');
    Writeln;
    Writeln ('    08   Reserve (High)  26A  Byte C1H                                        ');
    Writeln ('    09   Reserve (High)  26C                                                  ');
    Writeln ('    10 y HV-Schaltr Fehl 27A                                                  ');
    Writeln ('    11   Reserve (High)  27C                                                  ');
    Writeln ('    12   Reserve (High)  28A                                                  ');
    Writeln ('    13   Reserve (High)  28C                                                  ');
    Writeln ('    14   Reserve (High)  29A                                                  ');
    Writeln ('    15   Reserve (High)  29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
   end;  {Tab14}

  procedure Status_Tab15 (Spalte_Start, Zeile_Start: Byte);
  const
   Stat_Line1 =
     '      Tabelle[15]: Unilac-HIS Magnete SVE 21-38U (JÑger) 11.5.99' +
     '0/1 Bit Bedeutung        Pin  Bemerkng   0/1 Bit Bedeutung        Pin  Bemerkng';

   begin
    Ini_Stat_Win;
    GotoXY(1, 1);
    Write ('Ifc-Adr[Hex]: '); TextColor(IFC_Color); Write(hex_byte(Ifc_Test_Nr));
    TextColor(Yellow);

    Write(Stat_Line1);
    Ini_Text_Win;
    GotoXY(Spalte_Start+01, Zeile_Start);
    Writeln ('   00  GerÑt AUS         3A  Byte C0H       16  xx Hand (local)  22A  Byte C2H');
    Writeln ('    01  xy Unterspg Phas  3C                 17  y StraSchuIntrl  22C         ');
    Writeln ('    02  xy Temp. NG       4A                 18  Last1 Aus        23A         ');
    Writeln ('    03  xy KÅhlwasser NG  4C                 19  Last2 Aus        23C         ');
    Writeln ('    04  I-Last max o. eff 5A                 20  Last3 Aus        24A         ');
    Writeln ('    05  Reserve (High)    5C                 21  Last4 Aus        24C         ');
    Writeln ('    06  xy Temp. Last     6A                 22  Last5 Aus        25A         ');
    Writeln ('    07  xy H2O-Last       6C                 23  Reserve (High)   25C         ');
    Writeln;
    Writeln ('    08  Reserve (High)       Byte C1H                                        ');
    Writeln ('    09  I-Netz           26C                                                  ');
    Writeln ('    10  y TransiFehlV1-4 27A                                                  ');
    Writeln ('    11  y TransiFehl  V5 27C                                                  ');
    Writeln ('    12  y Gleichspg Ud1  28A                                                  ');
    Writeln ('    13  Reserve (High)   28C                                                  ');
    Writeln ('    14  y DCCT Fehl Holc 29A                                                  ');
    Writeln ('    15  y Erdschlu·      29C                                                  ');
    Writeln;
    Ini_Jumper_Win;
    TextColor(Yellow);
    Writeln ('Text bzw. Fehler entspricht Nullbezug!! 0 = Fehler, 1 = o. k., F = Lesefehler');
    Writeln ('Alle EingÑnge Pulldown!! x  = Summen-Interlock (x + xx: Schaltkarte gebildet)');
    TextColor(White);
    Write ('Loop:'); TextColor(Yellow);
    Write   ('                    xx = Sum-Intl-Opt, falls Jumpr unten, y=GerÑt gebild');
    Set_Text_Win;
    GotoXY(01,22);
    TextColor(Brown);
    Write (' Rd_Err:        SW[H]:     SW[V]:            SW[A]:            SW[Amax]:       ');
    TextColor(Black);
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
   end;          }

 begin {Cursor}
{   reg.ah:=1;
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
   end;       }
 end;

end.  { UNIT DATECH_1 }

