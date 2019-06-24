unit MD.Input;

interface

uses
  FMX.Edit, FMX.Types, System.UITypes, System.Classes, System.Types, FMX.ActnList,
  FMX.Graphics, MD.ColorPalette;

type
  TMDEdit = class(TEdit)
  private
    FMaterialColor: TMaterialColor;
    FFocusedMaterialColor: TMaterialColor;
    FPromptTextColor: TMaterialColor;
    procedure SetFocusedMaterialColor(const Value: TMaterialColor);
    procedure SetMaterialColor(const Value: TMaterialColor);
    procedure SetPromptTextColor(const Value: TMaterialColor);
    { private declarations }
  protected
    { protected declarations }
    procedure Tap(const Point: TPointF); override;
    procedure CMGesture(var EventInfo: TGestureEventInfo); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    function DefinePresentationName: string; override;
    function GetDefaultStyleLookupName: string; override;
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { published declarations }
    property MaterialColor: TMaterialColor read FMaterialColor write SetMaterialColor;
    property FocusedMaterialColor: TMaterialColor read FFocusedMaterialColor write SetFocusedMaterialColor;
    property PromptTextColor: TMaterialColor read FPromptTextColor write SetPromptTextColor;
  end;

implementation

uses
  FMX.MDEdit.Style;

{ TMDEdit }

procedure TMDEdit.CMGesture(var EventInfo: TGestureEventInfo);
begin
{$IFDEF ANDROID}
  if EventInfo.GestureID = igiLongTap then
    inherited MouseDown(TMouseButton.mbLeft, [ssLeft], 0, 0);
{$ELSE}
  inherited;
{$ENDIF}
end;

constructor TMDEdit.Create(AOwner: TComponent);
begin
  inherited;
    FMaterialColor:= TMaterialColorRec.Grey500;
    FFocusedMaterialColor:= TMaterialColorRec.Blue500;
    FPromptTextColor:= TMaterialColorRec.Grey500;
end;

function TMDEdit.DefinePresentationName: string;
begin
  // inherited;
  Result := 'MDEdit-' + GetPresentationSuffix;
end;

destructor TMDEdit.Destroy;
begin

  inherited;
end;

function TMDEdit.GetDefaultStyleLookupName: string;
begin
  // inherited;
  Result := 'mdeditstyle';
end;

procedure TMDEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
{$IFNDEF ANDROID}
  inherited;
{$ENDIF}
end;

procedure TMDEdit.SetFocusedMaterialColor(const Value: TMaterialColor);
begin
  FFocusedMaterialColor := Value;
end;

procedure TMDEdit.SetMaterialColor(const Value: TMaterialColor);
begin
  FMaterialColor := Value;
end;

procedure TMDEdit.SetPromptTextColor(const Value: TMaterialColor);
begin
  FPromptTextColor := Value;
end;

procedure TMDEdit.Tap(const Point: TPointF);
begin
{$IFDEF ANDROID}
  inherited MouseDown(TMouseButton.mbLeft, [ssLeft], Point.X, Point.Y);
{$ELSE}
  inherited;
{$ENDIF}
end;

initialization

{$WARNINGS OFF}
  RegisterFmxClasses([TMDEdit]);
{$WARNINGS ON}

end.
