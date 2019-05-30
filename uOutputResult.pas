unit uOutputResult;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  System.Generics.Collections;

type

  PScanResult = ^TScanResult;
  TScanResult = record
    FCount : string;
    FPattern : string;
    FUrl : string;
  end;

  // singleton
  TOutputResult = class(TObject)
  strict private
    class var FInstance: TOutputResult;
    constructor Create;
    destructor Destroy;override;
  private
    class var FMutex : TMutex;
    class var FLstResult : TList<PScanResult>;
  public
    class function GetInstance: TOutputResult;
    class function ReadResult(const AIndex: Integer; var AUrl, APattern, ACount: string): Boolean;
    class function SaveToFile(AFileName: string): Boolean;
    class function GetCount: Integer;
    class procedure ClearList;
    class procedure ReleaseInstance;
    class procedure WriteResult(const AUrl, APattern, ACount: string);
  end;

implementation

uses
  System.IOUtils;

constructor TOutputResult.Create;
begin
  inherited;
  FMutex := TMutex.Create();
  FLstResult := TList<PScanResult>.Create();
end;

destructor TOutputResult.Destroy;
begin
  FInstance := nil;
  ClearList;
  FLstResult.Free;
  FMutex.Free;
  inherited;
end;

class procedure TOutputResult.ClearList;
var
  tmpRec :  PScanResult;
begin
  while FLstResult.Count > 0 do
  begin
   tmpRec := FLstResult.Items[0];
   FLstResult.Delete(0);
   dispose(tmpRec);
  end;

end;

class function TOutputResult.GetInstance: TOutputResult;
begin
  If FInstance = nil Then
    FInstance := uOutputResult.TOutputResult.Create();

  Result := FInstance;
end;

class procedure TOutputResult.ReleaseInstance;
begin
  FreeAndNil(FInstance)
 end;


class procedure TOutputResult.WriteResult(const AUrl, APattern, ACount: string);
var
  tmpScanResult : PScanResult;
begin
  FMutex.Acquire;
  try
    new(tmpScanResult);
    with tmpScanResult^ do
    begin
      FUrl := AUrl;
      FPattern := APattern;
      FCount := ACount;
    end;
    FLstResult.Add(tmpScanResult)
  finally
    FMutex.Release;
  end;
end;

class function TOutputResult.ReadResult(const AIndex: Integer; var AUrl, APattern, ACount: string):Boolean;

begin
  if AIndex <=  FLstResult.Count then
  begin
    ACount := FLstResult[AIndex].FCount;
    APattern := FLstResult[AIndex].FPattern;
    AUrl := FLstResult[AIndex].FUrl;
    Result := true
  end
  else
    Result := false;
end;


class function TOutputResult.SaveToFile(AFileName: string): Boolean;
var
  tmpScanResult : PScanResult;
  savefile : TStringList;
begin
  Result := false;
  if assigned(FLstResult) then
    if FLstResult.Count > 0 then
    begin
      savefile := TStringList.Create;
      try
        savefile.Add('URL,           Pattern,            Count');
        for tmpScanResult in FLstResult do
          savefile.Add(tmpScanResult.FUrl+','+tmpScanResult.FPattern+','+tmpScanResult.FCount);
        savefile.SaveToFile(AFileName);
        Result := true;
      finally
        savefile.Free
      end;
    end;
end;

class function TOutputResult.GetCount: Integer;
begin
  Result := FLstResult.Count
end;

end.
