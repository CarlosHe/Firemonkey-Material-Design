unit FMX.MDAutocompleteEdit.Style;

interface

uses
  FMX.Edit.Style, FMX.Controls.Presentation, FMX.Controls.Model, FMX.Presentation.Messages,
  FMX.Controls, FMX.Graphics, FMX.ListBox, System.Classes, System.Types, FMX.Presentation.Style, FMX.MDEdit.Style;

type

  TStyledMDAutocompleteEdit = class(TStyledMDEdit)
  private
    FSuggestions: TArray<string>;
    FPopup: TPopup;
    FListBox: TListBox;
    FDropDownCount: Integer;
    FOutlinedPathData: TPathData;
  protected
    procedure Paint; override;
    procedure MMDataChanged(var AMessage: TDispatchMessageWithValue<TDataRecord>); message MM_DATA_CHANGED;
    procedure PMSetSize(var AMessage: TDispatchMessageWithValue<TSizeF>); message PM_SET_SIZE;
    procedure DoChangeTracking; override;
    procedure RebuildSuggestionList;
    procedure RecalculatePopupHeight;
    procedure KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TStyledMDAutocompleteEditProxy = class(TStyledPresentationProxy<TStyledMDAutocompleteEdit>);

implementation

uses
  FMX.Presentation.Factory, FMX.Types, System.SysUtils, System.Math, System.UITypes;

{ TStyledMDAutocompleteEdit }

constructor TStyledMDAutocompleteEdit.Create(AOwner: TComponent);
begin
  inherited;
  FPopup := TPopup.Create(nil);
  FPopup.Parent := Self;
  FPopup.PlacementTarget := Self;
  FPopup.Placement := TPlacement.Bottom;
  FPopup.Width := Width;
  FListBox := TListBox.Create(nil);
  FListBox.Parent := FPopup;
  FListBox.Align := TAlignLayout.Client;
  FDropDownCount := 5;

  FOutlinedPathData:= TPathData.Create;
end;

destructor TStyledMDAutocompleteEdit.Destroy;
begin
  FPopup := nil;
  FListBox := nil;
  FOutlinedPathData.Free;
  inherited;
end;

procedure TStyledMDAutocompleteEdit.DoChangeTracking;

  function HasSuggestion: Boolean;
  var
    I: Integer;
  begin
    I := 0;
    Result := False;
    while not Result and (I < Length(FSuggestions)) do
    begin
      Result := FSuggestions[I].ToLower.StartsWith(Model.Text.ToLower);
      if not Result then
        Inc(I)
      else
        Exit(Result);
    end;
  end;

  function IndexOfSuggestion: Integer;
  var
    Found: Boolean;
    I: Integer;
  begin
    Found := False;
    I := 0;
    Result := -1;
    while not Found and (I < FListBox.Count) do
    begin
      Found := FListBox.Items[I].ToLower.StartsWith(Model.Text.ToLower);
      if not Found then
        Inc(I)
      else
        Exit(I);
    end;
  end;

begin
  inherited;
  if HasSuggestion then
  begin
    RebuildSuggestionList;
    RecalculatePopupHeight;
    Index := IndexOfSuggestion;
    if Model.Text.IsEmpty then
      FListBox.ItemIndex := -1
    else
      FListBox.ItemIndex := Index;
    FPopup.IsOpen := True;
  end
  else
    FPopup.IsOpen := False;
end;

procedure TStyledMDAutocompleteEdit.KeyDown(var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  inherited;
  case Key of
    vkReturn:
      if FListBox.Selected <> nil then
      begin
        Model.Text := FListBox.Selected.Text;
        Edit.GoToTextEnd;
        FPopup.IsOpen := False;
      end;
    vkEscape:
      FPopup.IsOpen := False;
    vkDown:
      if FListBox.Selected <> nil then
        FListBox.ItemIndex := Min(FListBox.Count - 1, FListBox.ItemIndex + 1);
    vkUp:
      if FListBox.Selected <> nil then
        FListBox.ItemIndex := Max(0, FListBox.ItemIndex - 1);
  end;
end;

procedure TStyledMDAutocompleteEdit.MMDataChanged(var AMessage: TDispatchMessageWithValue<TDataRecord>);
var
  Data: TDataRecord;
begin
  Data := AMessage.Value;
  if Data.Value.IsType < TArray < string >> and (Data.Key = 'suggestion_list') then
    FSuggestions := AMessage.Value.Value.AsType<TArray<string>>;
end;

procedure TStyledMDAutocompleteEdit.Paint;
begin
  inherited;
  Canvas.DrawPath(FOutlinedPathData, Self.Opacity);
end;

procedure TStyledMDAutocompleteEdit.PMSetSize(var AMessage: TDispatchMessageWithValue<TSizeF>);
begin
  inherited;
  FPopup.Width := Width;
end;

procedure TStyledMDAutocompleteEdit.RebuildSuggestionList;
var
  Word: string;
begin
  FListBox.Clear;
  FListBox.BeginUpdate;
  try
    for Word in FSuggestions do
      if Word.ToLower.StartsWith(Model.Text.ToLower) then
        FListBox.Items.Add(Word);
  finally
    FListBox.EndUpdate;
  end;
end;

procedure TStyledMDAutocompleteEdit.RecalculatePopupHeight;
begin
  FPopup.Height := FListBox.ListItems[0].Height * Min(FDropDownCount, FListBox.Items.Count) + FListBox.BorderHeight;
  FPopup.PopupFormSize := TSizeF.Create(FPopup.Width, FPopup.Height);
end;

initialization
  TPresentationProxyFactory.Current.Register('MDAutocompleteEdit-style', TStyledMDAutocompleteEditProxy);
finalization
  TPresentationProxyFactory.Current.Unregister('MDAutocompleteEdit-style', TStyledMDAutocompleteEditProxy);
end.
