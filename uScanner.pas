unit uScanner;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.SyncObjs,
  System.Net.HttpClient;

type

  TURLScanner = class(TThread)
  strict private
    class var FInstances: Integer;

  private
    FNumber : integer;
    FPatterns : integer;
    FStrUrl : string;
    FStrPattern : string;
    FStrResponse : string;
    FHttpObj: THttpClient;
    FEvent : TEvent;
  protected
    procedure Execute; override;
    function GetHtml: Boolean;
    procedure PatternScan;
  public
    constructor Create(AUrl, APattern: string; ANumber: integer; AEvent: TEvent);
    destructor Destroy; override;
  public
  end;


implementation

uses
  System.StrUtils, Main, uOutputResult;

constructor TURLScanner.Create(AUrl, APattern: string; ANumber: integer; AEvent: TEvent);
begin
  inherited Create(true);
  FStrUrl := AUrl;
  FStrPattern := APattern;
  FNumber := ANumber;
  FEvent := AEVent;
  FHttpObj := THttpClient.Create;
  FHttpObj.HandleRedirects := true;
  FHttpObj.MaxRedirects := 3;
  Inc(FInstances);
end;

destructor TURLScanner.Destroy;
begin
  FHttpObj.free;
  inherited
end;

procedure TURLScanner.Execute;
var
  retVal : integer;
  varStr : string;
begin
  retVal := 1;
  Synchronize(
              procedure
              begin
                Main.frmWebScan.lblsbWeb.Text := 'Retrieving url: ' + FStrUrl;
              end);

  if GetHtml then
  begin
    PatternScan;
    varStr := IntToStr(FPatterns);
  end
  else
  begin
    varStr := 'Error';
    retVal := 0;
  end;

  Synchronize(
              procedure
              begin
                Main.frmWebScan.ShowGridRow(FStrUrl,FStrPattern,varStr,FNumber)
              end);

  TOutputResult.WriteResult(FStrUrl,FStrPattern,varStr);
  SetReturnValue(retVal);

  Dec(FInstances);
  if FInstances = 0 then
    FEvent.SetEvent;
end;

function TURLScanner.GetHtml:Boolean;
var
  iResponse: IHTTPResponse;
begin
  try
    iResponse := FHttpObj.Get(FStrUrl);
    FStrResponse := iResponse.ContentAsString();
    Result := true;
  except
    on e: exception do Result := false;
  end;
end;

procedure TURLScanner.PatternScan;
var
  iwhere : integer;
  patrnLen : integer;
begin
  FPatterns := 0;
  patrnLen := Length(FStrPattern);
  iWhere := 1;
  if not FStrPattern.IsEmpty then
    repeat
      iWhere := PosEx(FStrPattern,FStrResponse,iWhere);
      if iWhere > 1 then
      begin
        Inc(FPatterns);
        Inc(iWhere,patrnLen);
      end;
    until iWhere = 0;

end;





end.
