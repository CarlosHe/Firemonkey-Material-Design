unit MD.Checkbox;

interface

uses
  System.Classes, FMX.Objects, System.SysUtils, MD.ColorPalette, FMX.Graphics,
  MD.Classes, FMX.Types, FMX.Controls, System.Types, System.UITypes, FMX.Ani;

type

  TCheckAlign = (After, Before);

  TMDCheckbox = class(TControl)
  private
    FContainer: TControl;
    FIsChecked: boolean;
    FSelectedPath: TPath;
    FCheckText: TText;
    FIsIndeterminate: boolean;
    FMaterialColor: TMaterialColor;
    FOnCheckedChange: TNotifyEvent;
    FOnIndeterminateChange: TNotifyEvent;
    FCheckAlign: TCheckAlign;
    FMaterialTextSettings: TTextSettings;
    FOnCheckAlignChange: TNotifyEvent;
    procedure SetIsChecked(const Value: boolean);
    function GetIsChecked: boolean;
    procedure SetIsIndeterminate(const Value: boolean);
    function GetIsIndeterminate: boolean;
    procedure SetCheckAlign(const Value: TCheckAlign);
    procedure SetMaterialColor(const Value: TMaterialColor);
    procedure SetOnCheckedChange(const Value: TNotifyEvent);
    procedure SetOnIndeterminateChange(const Value: TNotifyEvent);
    procedure SetText(const Value: string);
    procedure SetTextSettings(const Value: TTextSettings);
    function GetTextSettings: TTextSettings;
    function GetText: string;
    procedure SetOnCheckAlignChange(const Value: TNotifyEvent);
    { private declarations }
  protected
    { protected declarations }
    procedure UpdateCheckPath;
    procedure StartRippleEffect;
    procedure RippleEffect(AMaterialColor: TMaterialColor; X, Y: Single);
    procedure RippleEffectFinish(Sender: TObject);

    procedure Resize; override;
    procedure HitTestChanged; override;
    procedure DoCheckClick(Sender: TObject);
    procedure DoCheckTap(Sender: TObject; const Point: TPointF);
    procedure DoCheckedChange;
    procedure DoIndeterminateChange;
    procedure DoCheckAlignChange;
    procedure DoMaterialTextSettingsChanged(Sender: TObject);
  public
    { public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { published declarations }
    property Align;
    property Anchors;
    property HitTest;
    property ClipParent;
    property Cursor;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Locked;
    property Height;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property TouchTargetExpansion;
    property Visible;
    property Width;

    property IsChecked: boolean read GetIsChecked write SetIsChecked;
    property IsIndeterminate: boolean read GetIsIndeterminate write SetIsIndeterminate;
    property CheckAlign: TCheckAlign read FCheckAlign write SetCheckAlign;

    property MaterialColor: TMaterialColor read FMaterialColor write SetMaterialColor;
    property Text: string read GetText write SetText;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;

    { Events }
    property OnPainting;
    property OnPaint;
    property OnResize;
    { Drag and Drop events }
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
    { Mouse events }
    property OnClick;
    // property OnDblClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseEnter;
    property OnMouseLeave;

    property OnCheckedChange: TNotifyEvent read FOnCheckedChange write SetOnCheckedChange;
    property OnIndeterminateChange: TNotifyEvent read FOnIndeterminateChange write SetOnIndeterminateChange;
    property OnCheckAlignChange: TNotifyEvent read FOnCheckAlignChange write SetOnCheckAlignChange;

  end;

implementation

const

  UNSELECTED_ICON = 'M 19 5 v 14 H 5 V 5 h 14 m 0 -2 H 5 c -1.1 0 -2 0.9 -2 2 v 14 c 0 1.1 0.9 2 2 2 h 14 c 1.1 0 2 -0.9 2 -2 V 5 c 0 -1.1 -0.9 -2 -2 -2 Z';
  SELECTED_ICON =
    'M 19 3 H 5 c -1.11 0 -2 0.9 -2 2 v 14 c 0 1.1 0.89 2 2 2 h 14 c 1.11 0 2 -0.9 2 -2 V 5 c 0 -1.1 -0.89 -2 -2 -2 Z m -9 14 l -5 -5 l 1.41 -1.41 L 10 14.17 l 7.59 -7.59 L 19 8 l -9 9 Z';
  INDETERMINATE_ICON = 'M 19 3 H 5 c -1.1 0 -2 0.9 -2 2 v 14 c 0 1.1 0.9 2 2 2 h 14 c 1.1 0 2 -0.9 2 -2 V 5 c 0 -1.1 -0.9 -2 -2 -2 Z m -2 10 H 7 v -2 h 10 v 2 Z';

  { TMDCheckbox }

constructor TMDCheckbox.Create(AOwner: TComponent);
var
  LClass: TTextSettingsClass;
begin
  inherited;

  Height := 40;
  Width := 140;
  HitTest := True;

  FMaterialColor := TMaterialColorRec.Blue500;

  FContainer := TControl.Create(Self);
  FContainer.Align := TAlignLayout.Client;
  FContainer.HitTest := True;
  FContainer.Cursor := crHandPoint;
  FContainer.SetSubComponent(True);
  FContainer.Stored := False;
{$IF DEFINED(MSWINDOWS) or DEFINED(IOS) }
  FContainer.OnClick := DoCheckClick;
{$ENDIF}
{$IF DEFINED(ANDROID) or DEFINED(OSX) }
  FContainer.OnTap := DoCheckTap;
{$ENDIF}
  AddObject(FContainer);

  FSelectedPath := TPath.Create(FContainer);
  FSelectedPath.Align := TAlignLayout.Left;
  FSelectedPath.HitTest := False;
  FSelectedPath.Margins.Top := 12;
  FSelectedPath.Margins.Left := 12;
  FSelectedPath.Margins.Bottom := 12;
  FSelectedPath.Margins.Right := 12;
  FSelectedPath.Width := 16;
  FSelectedPath.Locked := True;
  FSelectedPath.WrapMode := TPathWrapMode.Fit;
  FSelectedPath.Stroke.Kind := TBrushKind.None;
  FSelectedPath.Fill.Color := FMaterialColor;
  FSelectedPath.Data.Data := UNSELECTED_ICON;
  FSelectedPath.SetSubComponent(True);
  FSelectedPath.Stored := False;
  FContainer.AddObject(FSelectedPath);

  FCheckText := TText.Create(FContainer);
  FCheckText.Align := TAlignLayout.Client;
  FCheckText.HitTest := False;
  FCheckText.Margins.Top := 12;
  FCheckText.Margins.Left := -4;
  FCheckText.Margins.Bottom := 12;
  FCheckText.Margins.Right := 12;
  FCheckText.Locked := True;
  FCheckText.SetSubComponent(True);
  FCheckText.Stored := True;
  FContainer.AddObject(FCheckText);

  LClass := nil;
  if LClass = nil then
    LClass := TMaterialTextSettings;

  FMaterialTextSettings := LClass.Create(Self);
  FMaterialTextSettings.OnChanged := DoMaterialTextSettingsChanged;
  FMaterialTextSettings.BeginUpdate;
  try
    FMaterialTextSettings.HorzAlign := TTextAlign.Leading;
    FMaterialTextSettings.Font.Size := 16;
    FMaterialTextSettings.Font.Family := 'Roboto';
    FMaterialTextSettings.IsAdjustChanged := True;
  finally
    FMaterialTextSettings.EndUpdate;
  end;
  FCheckText.TextSettings.Assign(FMaterialTextSettings);
end;

destructor TMDCheckbox.Destroy;
begin
  FreeAndNil(FSelectedPath);
  FreeAndNil(FMaterialTextSettings);
  inherited;
end;

procedure TMDCheckbox.DoCheckAlignChange;
begin
  if Assigned(FOnCheckAlignChange) then
    FOnCheckAlignChange(Self);
end;

procedure TMDCheckbox.DoCheckClick(Sender: TObject);
begin
  SetIsChecked(not FIsChecked);
  Click;
  StartRippleEffect;
end;

procedure TMDCheckbox.DoCheckedChange;
begin
  if Assigned(FOnCheckedChange) then
    FOnCheckedChange(Self);
end;

procedure TMDCheckbox.DoCheckTap(Sender: TObject; const Point: TPointF);
begin
  SetIsChecked(not FIsChecked);
  StartRippleEffect;
end;

procedure TMDCheckbox.DoIndeterminateChange;
begin
  if Assigned(FOnIndeterminateChange) then
    FOnIndeterminateChange(Self);
end;

procedure TMDCheckbox.DoMaterialTextSettingsChanged(Sender: TObject);
begin
  FCheckText.TextSettings.Assign(FMaterialTextSettings);
end;

function TMDCheckbox.GetIsChecked: boolean;
begin
  Result := FIsChecked;
end;

function TMDCheckbox.GetIsIndeterminate: boolean;
begin
  Result := FIsIndeterminate;
end;

function TMDCheckbox.GetText: string;
begin
  Result := FCheckText.Text;
end;

function TMDCheckbox.GetTextSettings: TTextSettings;
begin
  Result := FMaterialTextSettings;
end;

procedure TMDCheckbox.HitTestChanged;
begin
  inherited;
  if Assigned(FContainer) then
    FContainer.HitTest := Self.HitTest;
end;

procedure TMDCheckbox.Resize;
begin
  inherited;
  if Assigned(FCheckText) then
    FCheckText.RecalcSize;
end;

procedure TMDCheckbox.RippleEffect(AMaterialColor: TMaterialColor; X, Y: Single);
var
  LCircle: TCircle;
  LAnimation: TFloatAnimation;
begin
  LAnimation := TFloatAnimation.Create(nil);
  LCircle := TCircle.Create(LAnimation);

  LCircle.Parent := Self;
  LAnimation.Parent := LCircle;

  LCircle.Fill.Color := AMaterialColor;
  LCircle.Stroke.Kind := TBrushKind.None;
  LCircle.HitTest := False;
  LCircle.Height := 5;
  LCircle.Width := 5;
  LCircle.Position.X := X - LCircle.Width / 2;
  LCircle.Position.Y := Y - LCircle.Height / 2;
  LCircle.Opacity := 0;

  LCircle.AnimateFloat('Opacity', 0.5, 0.2, TAnimationType.InOut, TInterpolationType.Linear);
  LCircle.AnimateFloat('Height', Self.Height, 0.3, TAnimationType.InOut, TInterpolationType.Linear);
  LCircle.AnimateFloat('Width', Self.Height, 0.3, TAnimationType.InOut, TInterpolationType.Linear);

  LCircle.AnimateFloat('Position.X', X - Self.Height / 2, 0.3, TAnimationType.InOut, TInterpolationType.Linear);
  LCircle.AnimateFloat('Position.Y', Y - Self.Height / 2, 0.3, TAnimationType.InOut, TInterpolationType.Linear);

  LCircle.StopPropertyAnimation('Opacity');

  LAnimation.AnimationType := TAnimationType.InOut;
  LAnimation.Interpolation := TInterpolationType.Linear;
  LAnimation.OnFinish := RippleEffectFinish;
  LAnimation.Duration := 0.4;
  LAnimation.PropertyName := 'Opacity';
  LAnimation.StartFromCurrent := True;
  LAnimation.StopValue := 0;
  LAnimation.Start;
end;

procedure TMDCheckbox.RippleEffectFinish(Sender: TObject);
var
  LAnimation: TFloatAnimation;
begin
  LAnimation := TFloatAnimation(Sender);
  FreeAndNil(LAnimation);
end;

procedure TMDCheckbox.SetCheckAlign(const Value: TCheckAlign);
begin
  if FCheckAlign <> Value then
  begin
    FCheckAlign := Value;
    case FCheckAlign of
      After:
        begin
          FSelectedPath.Align := TAlignLayout.Left;
          FCheckText.Margins.Left := -4;
          FCheckText.Margins.Right := 12;
        end;
      Before:
        begin
          FSelectedPath.Align := TAlignLayout.Right;
          FCheckText.Margins.Left := 12;
          FCheckText.Margins.Right := -4;
        end;
    end;
    DoCheckAlignChange;
  end;
end;

procedure TMDCheckbox.SetMaterialColor(const Value: TMaterialColor);
begin
  FMaterialColor := Value;
  FSelectedPath.Fill.Color := FMaterialColor;
end;

procedure TMDCheckbox.SetIsChecked(const Value: boolean);
begin
  if FIsChecked <> Value then
  begin
    FIsChecked := Value;
    UpdateCheckPath;
    DoCheckedChange;
  end;
end;

procedure TMDCheckbox.SetIsIndeterminate(const Value: boolean);
begin
  if FIsIndeterminate <> Value then
  begin
    FIsIndeterminate := Value;
    UpdateCheckPath;
    DoIndeterminateChange;
  end;
end;

procedure TMDCheckbox.SetOnCheckAlignChange(const Value: TNotifyEvent);
begin
  FOnCheckAlignChange := Value;
end;

procedure TMDCheckbox.SetOnCheckedChange(const Value: TNotifyEvent);
begin
  FOnCheckedChange := Value;
end;

procedure TMDCheckbox.SetOnIndeterminateChange(const Value: TNotifyEvent);
begin
  FOnIndeterminateChange := Value;
end;

procedure TMDCheckbox.SetText(const Value: string);
begin
  FCheckText.Text := Value;
end;

procedure TMDCheckbox.SetTextSettings(const Value: TTextSettings);
begin
  FCheckText.TextSettings.Assign(Value);
end;

procedure TMDCheckbox.StartRippleEffect;
begin
  if FIsChecked then
    RippleEffect(FMaterialColor, FSelectedPath.Position.X + FSelectedPath.Width / 2, FSelectedPath.Position.Y + FSelectedPath.Height / 2)
  else
    RippleEffect(TMaterialColorRec.Black, FSelectedPath.Position.X + FSelectedPath.Width / 2, FSelectedPath.Position.Y + FSelectedPath.Height / 2)
end;

procedure TMDCheckbox.UpdateCheckPath;
begin
  if (FIsChecked) and (FIsIndeterminate) then
    FSelectedPath.Data.Data := INDETERMINATE_ICON;
  if (FIsChecked) and (not FIsIndeterminate) then
    FSelectedPath.Data.Data := SELECTED_ICON;
  if (not FIsChecked) then
    FSelectedPath.Data.Data := UNSELECTED_ICON;
end;

end.
