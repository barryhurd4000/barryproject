unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.SyncObjs, System.Contnrs,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.ListBox, FMX.Edit, System.Rtti,
  FMX.Grid.Style, FMX.Grid, FMX.ScrollBox;

type
  TfrmWebScan = class(TForm)
    lstbxURL: TListBox;
    edtURL: TEdit;
    btnScan: TButton;
    btnAdd: TButton;
    Label1: TLabel;
    edtPattern: TEdit;
    Label2: TLabel;
    Panel1: TPanel;
    grpbxOutput: TGroupBox;
    GroupBox1: TGroupBox;
    statusBarWeb: TStatusBar;
    lblsbWeb: TLabel;
    btnSave: TButton;
    grdResult: TStringGrid;
    StringColumn1: TStringColumn;
    StringColumn2: TStringColumn;
    StringColumn3: TStringColumn;
    ProgBar: TProgressBar;
    progBarTimer: TTimer;
    btnClear: TButton;
    procedure btnScanClick(Sender: TObject);
    procedure edtURLTyping(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure edtPatternTyping(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProgBarTimerTimer(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure edtURLKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure edtPatternKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
  private
    FMutex : TMutex;
    FUrlList : TStringList;

    procedure RunScanner(const APatternStr: string);
  public
    procedure ShowGridRow(const AUrl, APattern, AStatus: string; const ARow: Integer);
  end;

var
  frmWebScan: TfrmWebScan;

implementation

{$R *.fmx}

uses
  WinApi.Windows,
  System.StrUtils,
  uScanner, uOutputResult, uControl;

var
  OutputObj : TOutputResult;

procedure TfrmWebScan.FormCreate(Sender: TObject);
begin
  FMutex := TMutex.Create;
end;

procedure TfrmWebScan.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FUrlList);
  if assigned(OutputObj) then
    OutputObj.ReleaseInstance;
  FreeAndNil(FMutex);
end;


procedure TfrmWebScan.btnAddClick(Sender: TObject);
begin
  if not edtURL.Text.IsEmpty then
  begin
    if not lstbxURL.Enabled then
      lstbxURL.Enabled := true;
    lstbxURL.Items.Add(edtURL.Text);
    edtURL.Text := '';
  end;
end;

procedure TfrmWebScan.btnClearClick(Sender: TObject);
var
  iRow : integer;
begin
  lstbxURL.Clear;
  for iRow := 0 to grdResult.RowCount - 1 do
  begin
    grdResult.Cells[0,iRow] := '';
    grdResult.Cells[1,iRow] := '';
    grdResult.Cells[2,iRow] := '';
  end;
  lblsbWeb.Text := '';
  edtPattern.Text := '';
  btnScan.Enabled := false;
  btnSave.Enabled := false;
  btnClear.Enabled := false;
end;

procedure TfrmWebScan.btnSaveClick(Sender: TObject);
begin
  if assigned(OutputObj) then
  begin
    lblsbWeb.Text := 'Saving csv file to BarryTest.csv';
    OutputObj.SaveToFile('BarryTest.csv');
  end;
end;

procedure TfrmWebScan.btnScanClick(Sender: TObject);
var
  urlStr : string;
begin
  if (lstbxURL.items.count > 0) and (not edtPattern.Text.IsEmpty) then
  begin
    btnSave.Enabled := false;

    if not assigned(FUrlList) then
      FUrlList := TStringList.Create;
    FUrlList.Clear;
    for urlStr in lstbxURL.Items do
      FUrlList.Add(urlStr);

    RunScanner(edtPattern.Text);

    lblsbWeb.Text := '';
  end
  else
    lblsbWeb.Text := 'Enter pattern to search for.';
end;

procedure TfrmWebScan.edtPatternKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn  then
    btnScanClick(sender);
end;

procedure TfrmWebScan.edtPatternTyping(Sender: TObject);
begin
  if not btnScan.Enabled then
    btnScan.Enabled := true
end;

procedure TfrmWebScan.edtURLKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn  then
    btnAddClick(sender);
end;

procedure TfrmWebScan.edtURLTyping(Sender: TObject);
begin
  if not btnAdd.Enabled then
    btnAdd.Enabled := true
end;

procedure TfrmWebScan.ProgBarTimerTimer(Sender: TObject);
begin
  progBarTimer.Enabled := false;

  with progBar do
  begin
    Value := Value + 3;
    if Value > Max then
      Value := Min
  end;

  progBarTimer.Enabled := true;
end;

procedure TfrmWebScan.RunScanner(const APatternStr: string);
begin

  progBarTimer.Enabled := true;

  if assigned(OutputObj) then
    OutputObj.ClearList;
  OutputObj := TOutputResult.GetInstance;

  with TControlThread.Create(FUrlList, APatternStr, procedure
                                                    begin
                                                      progBar.Value := progBar.Max;
                                                      progBarTimer.Enabled:= false;
                                                      lblsbWeb.Text := 'Done...';
                                                      progBar.Value := progBar.Min;
                                                      if OutputObj.GetCount > 0 then
                                                        btnSave.Enabled := true
                                                      else
                                                        btnSave.Enabled := false;
                                                      btnClear.Enabled := btnSave.Enabled;
                                                    end) do
  begin
    Start;
  end;

end;

procedure TfrmWebScan.ShowGridRow(const AUrl, APattern, AStatus : string; const ARow: Integer);
begin
  grdResult.Cells[0,ARow] := AUrl;
  grdResult.Cells[1,ARow] := APattern;
  grdResult.Cells[2,ARow] := AStatus;
  if not btnSave.Enabled then
    btnSave.Enabled := true;
end;


end.
