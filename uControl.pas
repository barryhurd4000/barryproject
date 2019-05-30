unit uControl;

interface

uses
  System.Classes, System.SysUtils,System.SyncObjs, System.Contnrs;

type

  TControlThread = class(TThread)
  private
    FPatternStr : string;
    FUrlList : TStringList;
    FAmRef : TProc;
  protected
    procedure Execute; override;
    procedure RunScanners;
  public
    constructor Create(AUrlList: TStringList; APatternStr: string; AMRef: TProc);
  end;

implementation

uses
  uScanner, uOutputResult, Main;

{ TControlThread }

constructor TControlThread.Create(AUrlList: TStringList; APatternStr: string; AMRef: TProc);
begin
  inherited Create(true);

  FUrlList := TStringList.Create;

  FUrlList.Assign(AUrlList);
  FPatternStr := APatternStr;
  FAmRef := AMRef;
end;


procedure TControlThread.Execute;
begin
  RunScanners;
  FUrlList.free;
end;

procedure TControlThread.RunScanners;
var
  index :integer;
  urlStr : string;
  waitStatus : TWaitResult;
  handleArr: THandleObjectArray;
  threadArr: array of TURLScanner;
  eventPri : TEvent;
begin
  index := 0;
  SetLength(handleArr,FUrlList.count);
  SetLength(threadArr,FUrlList.count);

  eventPri := TEvent.Create(nil,true,false,'EvntPri100ZZ');
  try
    for urlStr in FUrlList do
    begin
      handleArr[index] := eventPri;
      threadArr[index] := TURLScanner.Create(urlStr, FPatternStr, index,eventPri);
      threadArr[index].Start;
      Inc(index);
    end;

    waitStatus := eventPri.WaitFor(60000);
    if waitStatus = wrTimeout then
      Synchronize(
                  procedure
                  begin
                    Main.frmWebScan.lblsbWeb.Text := 'Timeout - Scan may not be completed.';
                  end);

    for index := 0 to FUrlList.count -1 do
      threadArr[index].Free;

    SetLength(threadArr,0);
    SetLength(handleArr,0);
  finally
    eventPri.Free;
    FAmRef();
  end;
end;

end.
