//-----------------------------
// GSI Gesellschaft für 
// Schwerionenforschung mbH, 
// Darmstadt, Germany 
//
// UnitMil.pas
//
// Autor           : Zweig,Marcus
// Version         : 1.08
// letzte Änderung : 13.02.04
//------------------------------

unit UnitMil;

interface

uses
  Classes, SysUtils;

// Datentypen
type _BYTE  = Byte;
type _WORD  = Word;
type _DWORD = Longword;

// Interrupt aufruf- funktionen
MYDRIVER_INT_HANDLER = procedure(P: Pointer);

var IFKAdress : _Byte;
    Cardauswahl :_Byte;
    error : Boolean;
    IFKOnline: TStrings;
    //FileSaveData:TStrings;
    IFKCount:integer;

{type  (DataSend,CommandSend); }
type _TimerBase  = (Timerbase_10us, Timerbase_1ms);

type t_Error_Char = array [1..25] of char;


const

{ Bitmasken für status_1 }
Interlock          = $1;
Dta_Rdy		   = $2;
Dta_Req		   = $4;
Trm_Rdy		   = $8;
Mil_Rcv_Rdy	   = $10;
Mil_Fifo_Full      = $20;
Mil_Fifo_On	   = $40;
Cmd_Rcv		   = $80;
Timeout_1	   = $100;
Timeout_2	   = $200;
Debounce_On	   = $400;
Frei_D11	   = $800;
Evt_Fifo_Not_Empty = $1000;
Evt_Fifo_Full	   = $2000;
EvFilter_On	   = $4000;
Master_Slave	   = $8000;
Puls_In1	   = $10000;
Puls_In2	   = $20000;
Puls_In3	   = $40000; //Bit18

{ Bitmasken fuer das Control Register 1
 (Ctrl_Reg1, nur setzen)
 --------------------------------------}
Ctrl_EvFilter_On     = $1;
Ctrl_Debounce_On     = $2;
Ctrl_Mil_Fifo_On     = $4;
Ctrl_En_Intr1	     = $8;
Ctrl_En_Intr2	     = $10;
Ctrl_EvFilter_8_12   = $20;
Ctrl_Puls1_Rahmen_On = $40;
Ctrl_Puls2_Rahmen_On = $80;
Ctrl_Puls3_Rahmen_On = $100;
Ctrl_Puls4_Rahmen_On = $200;
Ctrl_Puls5_Rahmen_On = $400;

 { Bitmasken fuer den das EventFilter
  ------------------------------------}
EvFilter_EventOn       = $1;
EvFilter_EventTimerRun = $2;
EvFilter_Start_Puls1   = $4;
EvFilter_Stop_Puls1    = $8;
EvFilter_Start_Puls2   = $10;
EvFilter_Stop_Puls2    = $20;

{ Fehlermeldungen
 ----------------}

StatusOK		  = $0;
VendorID_Error		  = $1;
DeviceID_Error		  = $2;
CountCards_Error	  = $4;
Open_Failure		  = $8;
IncorrectWinDriver	  = $10;
InvalidHandleValue	  = $20;
Failed_Open_WinDrv_Device = $40;
MilBus_Busy		  = $80;
TestTimerError	   	  = $100;
Fifo_Full		  = $200;
CardNrError		  = $400;
NoPCICartOpen		  = $800;
NoPCMil		   	  = $1000;
ReadMilBusTimeOut	  = $2000;
WriteMilBusTimeOut	  = $4000;
FifoNotEmpty		  = $8000;
FifoNotCleared		  = $10000;
NoDataToRead	   	  = $20000;
EventNrError		  = $40000;
IFKNrError		  = $80000;
FailedEnableIntr	  = $100000;
IntMaskError		  = $200000;
GeneralError              = $400000;
MasterSlaveError	  = $800000;
UnrequestedReceiv	  = $1000000;


type switch  =(EventOn, EventOff, EventTimerClear, EventTimerRun,
          EventClear, Puls1_On, Puls1_Off, Puls2_On, Puls2_Off,
          Cntrl_EvFilter_On,Cntrl_EvFilter_Off, Cntrl_Debounce_On,
          Cntrl_Debounce_Off,Cntrl_Mil_FiFo_On, Cntrl_Mil_FiFo_Off,
          Cntrl_En_Intr1, Cntrl_Dis_Intr1,Cntrl_En_Intr2,
          Cntrl_Dis_Intr2, Cntrl_EvFilter_12_Bit, Cntrl_EvFilter_8_Bit,
          Cntrl_Puls1_Rahmen_On, Cntrl_Puls1_Rahmen_Off, Cntrl_Puls2_Rahmen_On,
	  Cntrl_Puls2_Rahmen_Off, Cntrl_Puls3_Rahmen_On, Cntrl_Puls3_Rahmen_Off,
	  Cntrl_Puls4_Rahmen_On, Cntrl_Puls4_Rahmen_Off, Cntrl_Puls5_Rahmen_On,
	  Cntrl_Puls5_Rahmen_Off, PulsBuchse_1, PulsBuchse_2, Puls, RahmenPuls,
          IntSetPriorityNormal, IntSetPriorityHigh, IntSetPriorityCritical);



procedure MILDRIVER_VersionNr(var version:_BYTE);
                              cdecl; external 'PCIMilTreiber.dll';

function PCI_PCIcardCount():_DWORD;cdecl; external 'PCIMilTreiber.dll';

function PCI_DriverOpen(CardNr:_BYTE):_DWORD;cdecl; external 'PCIMilTreiber.dll';

function PCI_IfkOnline(CardNr:_BYTE;IFCNr:_BYTE;var ReturnIFKNR:_BYTE;
                       var ErrorStatus:_DWORD):_DWORD;
                       cdecl; external 'PCIMilTreiber.dll';

function PCI_IfkRead(CardNr:_BYTE; IFKAdress:_BYTE;
                     IFKFunktionCode:_BYTE; var data: _WORD;
                     var ErrorStatus:_DWORD):_DWORD;
                     cdecl; external 'PCIMilTreiber.dll';

function PCI_IfkWrite(CardNr:_BYTE; FKAdress:_BYTE;
                      IFKFunktionCode:_BYTE;
                      data:_WORD; var ErrorStatus:_DWORD):_DWORD;
                      cdecl; external 'PCIMilTreiber.dll';

function PCI_PCIcardReset(CardNr:_BYTE; var ErrorStatus:_DWORD):_DWORD;
                          cdecl; external 'PCIMilTreiber.dll';

function PCI_FctCodeSnd(CardNr:_BYTE; IFKAdress:_BYTE;
                        FunktionCode:_BYTE;
                        var ErrorStatus:_DWORD):_DWORD;
                        cdecl; external 'PCIMilTreiber.dll';

function PCI_ErrorString(status:_DWORD; var error_string:t_Error_Char):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_TimerWait(CardNr:_BYTE; Time:_WORD;TimeBase:_BYTE;
                       var ErrorStatus:_DWORD):_DWORD;
                       cdecl; external 'PCIMilTreiber.dll';

function PCI_TimerSet(CardNr:_BYTE; Time:_WORD;
                      TimeBase:_BYTE;var ErrorStatus:_DWORD):_DWORD;
                      cdecl; external 'PCIMilTreiber.dll';

function PCI_StatusRegRead(CardNr:_BYTE;var StatusReg:_DWORD;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_MilBusWrite(CardNr:_BYTE; data:_WORD;
                         var ErrorStatus:_DWORD):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_DriverClose(CardNr:_BYTE):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_IntMaskRead(CardNr:_BYTE; var data:_DWORD;
                         var ErrorStatus:_DWORD):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_IntMaskWrite(CardNr:_BYTE; data:_DWORD;
                          var ErrorStatus:_DWORD):_DWORD;
                          cdecl; external 'PCIMilTreiber.dll';

function PCI_IntEnable(CardNr:_BYTE;funcIntHandler:MYDRIVER_INT_HANDLER;
                       pUserDat:Pointer; Priority:_WORD ;
                       var ErrorStatus:_DWORD):_DWORD;
                       cdecl; external 'PCIMilTreiber.dll';

function PCI_IntDisable(CardNr:_BYTE; var ErrorStatus:_DWORD):_DWORD;
                        cdecl; external 'PCIMilTreiber.dll';

function PCI_IntAktiv(CardNr:_BYTE; var IntAktiv:_DWORD;
                      var ErrorStatus:_DWORD):_DWORD;
                      cdecl; external 'PCIMilTreiber.dll';

function PCI_IntNextEnable(CardNr:_BYTE; var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_IntWait(CardNr:_BYTE; var IntAktiv:_DWORD;
                     var ErrorStatus:_DWORD):_DWORD;
                     cdecl; external 'PCIMilTreiber.dll';

function PCI_IntWaitStop(CardNr:_BYTE;var ErrorStatus:_DWORD):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_CntrlRegSet(CardNr:_BYTE; SetValue:switch;
                         var ErrorStatus:_DWORD):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_CntrlRegRead(CardNr:_BYTE;var CntrlRegValue:_BYTE;
                          var ErrorStatus:_DWORD):_DWORD;
                          cdecl; external 'PCIMilTreiber.dll';

function PCI_EvFilterSet(CardNr:_BYTE; EventCodeNr:_WORD;
                         SetEV:switch; var ErrorStatus:_DWORD):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_EvFiFoRead(CardNr:_BYTE;var EventCodeNr:_WORD;
                        var EVFifoNotEmpty:boolean;
                        var ErrorStatus:_DWORD):_DWORD;
                        cdecl; external 'PCIMilTreiber.dll';

function PCI_EvFilterRead(CardNr:_BYTE; EventCodeNr:_WORD;
                          var FilterValue:_BYTE;
                          var ErrorStatus:_DWORD):_DWORD;
                          cdecl; external 'PCIMilTreiber.dll';

function PCI_StatusTest(CardNr:_BYTE;StatusBit:_DWORD;
                        var ErrorStatus:_DWORD):boolean;
                        cdecl; external 'PCIMilTreiber.dll';

function PCI_DataFiFoRead(CardNr:_BYTE;var data:_WORD;
                          var Fifo_not_empty:boolean;
                          var ErrorStatus:_DWORD):_DWORD;
                          cdecl; external 'PCIMilTreiber.dll';

function PCI_MilBusRead(CardNr:_BYTE;var data: _WORD;
                        var Fifo_not_empty:boolean;
                        var ErrorStatus:_DWORD):_DWORD;
                        cdecl; external 'PCIMilTreiber.dll';

function PCI_EvTimerRead(CardNr:_BYTE;var Time:_DWORD;
                         var ErrorStatus:_DWORD):_DWORD;
                         cdecl; external 'PCIMilTreiber.dll';

function PCI_PulsOutSet(CardNr:_BYTE;PulsBuchse:_WORD;
                        EventOn:_WORD;EventOff:_WORD;
                        PulsRahmen:_WORD; OnOff:boolean;
                        var ErrorStatus:_DWORD):_DWORD ;
                        cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls1Start(CardNr:_BYTE;
                            var ErrorStatus:_DWORD):_DWORD;
                            cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls1Stop(CardNr:_BYTE;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls2Start(CardNr:_BYTE;
                            var ErrorStatus:_DWORD):_DWORD;
                            cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls2Stop(CardNr:_BYTE;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls3Start(CardNr:_BYTE;
                            var ErrorStatus:_DWORD):_DWORD;
                            cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls3Stop(CardNr:_BYTE;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls4Start(CardNr:_BYTE;
                            var ErrorStatus:_DWORD):_DWORD;
                            cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls4Stop(CardNr:_BYTE;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls5Start(CardNr:_BYTE;
                            var ErrorStatus:_DWORD):_DWORD;
                            cdecl; external 'PCIMilTreiber.dll';

function PCI_SoftPuls5Stop(CardNr:_BYTE;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_EvFilterClear(CardNr:_BYTE;
                           var ErrorStatus:_DWORD):_DWORD;
                           cdecl; external 'PCIMilTreiber.dll';

function PCI_EvFiFioClear(CardNr:_BYTE;
                          var ErrorStatus:_DWORD):_DWORD;
                          cdecl; external 'PCIMilTreiber.dll';

// Sucht IFKs am Bus und gibt diese als TStrings zurueck
procedure IFKFound(var IFKOnline: TStrings; var CountFound: Integer);

// umwandlung, wie der name schon sagt
function intToBinary(value:LongInt; digits:Byte):string;

implementation

procedure IFKFound(var IFKOnline: TStrings; var CountFound: Integer);

 var counter:integer;
     found:integer;
     ReturnIFKNr:_Byte;
     myStatus:_DWORD;

 begin
     counter := 1;
     CountFound := 0;
     myStatus := 0;


     while(counter <> 255) do
     begin
        found := PCI_IfkOnline(Cardauswahl, counter, ReturnIFKNr, myStatus);
        if(Found = StatusOK) then begin
           CountFound := CountFound + 1;
           with IFKOnline do
           begin
             {counter := IntToHex(counter,3);}
              Add(IntToHex(counter,0));
           end;
        end;
        counter := counter + 1;
     end;
  end;


function intToBinary(value:LongInt; digits:Byte):string;

var i:Byte;
    mask:LongInt;

begin
     SetLength (result, digits);
     for i := 0 to digits-1 do begin
         mask := 1 shl i;
         if(mask and value) = mask then
             result[digits-i] := '1'
         else
             result[digits-i] := '0'
     end
end;

end.
