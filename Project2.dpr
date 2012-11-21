program Project2;
{$APPTYPE CONSOLE}

uses
    crt32;

CONST
 head_line =
      'Datentechnik                         MIL_MAG    ' +
      '                    [20.03.2001]' +
      '                                  Magnetservice                                ';


procedure Ini_Text_Win;
  begin
   Window(1, 3, 80, 24);
   TextBackground(White);
   TextColor(Black);               {Setze Schriftfarbe}
   ClrScr;
end;

procedure ini_headl_win;
  begin                             {Definitionen gelten bis neu definiert}
    Window(1, 1, 80, 2);             {Definiert ein Textfenster: Spalte/Zeile}
    TextBackground(Magenta);         {Setze Hintergrund fÅr Textfenster}
    TextColor(Yellow);               {Setze Schriftfarbe}
    ClrScr;                          {Clear Window}
    GotoXY(1, 1);                    {Cursor auf Anfang Fenster}
   end;





begin
   ini_headl_win;
   Write(head_line);

   Ini_Text_Win;
   GotoXY(5, 3);
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

   readln;
end. 