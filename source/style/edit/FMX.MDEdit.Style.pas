{ ******************************************************* }
{ }
{ Delphi FireMonkey Platform }
{ }
{ Copyright(c) 2014-2018 Embarcadero Technologies, Inc. }
{ All rights reserved }
{ }
{ ******************************************************* }

unit FMX.MDEdit.Style;

interface

{$SCOPEDENUMS ON}

uses
{$IFDEF UseNativeDraw} FMX.Graphics.Native, {$ENDIF}
  System.Types, System.Classes, System.UITypes, System.Generics.Collections,
  FMX.Platform, FMX.Edit, FMX.Graphics,
  FMX.Types, FMX.Controls, FMX.TextLayout, FMX.Objects, FMX.MagnifierGlass,
  FMX.SpellChecker, FMX.Menus, FMX.Text,
  FMX.Presentation.Messages, FMX.StdCtrls, FMX.Styles.Objects, FMX.Ani,
  FMX.Presentation.Style, FMX.Controls.Presentation, FMX.Controls.Model,
  MD.Input;

type

  { TStyledEdit }

  TSelectionMode = (None, TextSelection, CursorPosChanging);

  TSelectionModeHelper = record helper for TSelectionMode
  const
    smNone = TSelectionMode.None deprecated 'Use TSelectionMode.None';
    smTextSelection = TSelectionMode.TextSelection deprecated 'Use TSelectionMode.TextSelection';
    smCursorPosChanging = TSelectionMode.CursorPosChanging deprecated 'Use TSelectionMode.CursorPosChanging';
  end;

  TSelectionPointType = (Left, Right);

  TSelectionPointTypeHelper = record helper for TSelectionPointType
  const
    sptLeft = TSelectionPointType.Left deprecated 'Use TSelectionPointType.Left';
    sptRight = TSelectionPointType.Right deprecated 'Use TSelectionPointType.Right';
  end;

  TStyledMDEdit = class(TStyledPresentation, ITextInput, ICaret, ITextSpellCheck, ITextSpellCheckActions)
  private
    FPromptText: TLabel;
    FPromptFloatAnimation: TFloatAnimation;
    FBackground: TActiveStyleObject;
    FOutlinedPathData: TPathData;
    FNeedBuildOutlinedPathData: Boolean;
    FFocused: Boolean;

    FTextService: TTextService;
    FFirstVisibleChar: Integer;
    FInvisibleTextWidth: Single;
    FSelectionMode: TSelectionMode;
    FCursorFill: TBrush;
    FContent: TControl;
    FLeftLayout: TControl;
    FButtonsLayout: TControl;
    FPrompt: TControl;
    FTextHeight: Single;
    FLineHeight: Single;
    FLineTop: Single;
    FTextLayout: TTextLayout;
    FCharsBuffer: string;
    { Selection }
    FLeftSelPt: TSelectionPoint;
    FRightSelPt: TSelectionPoint;
    { Loupe }
    FLoupeService: ILoupeService;
    { Spelling }
    FSpellService: IFMXSpellCheckerService;
    FUpdateSpelling: Boolean;
    FSpellingRegions: TRegion;
    FSpellMenuItems: TList<TMenuItem>;
    FSpellHightlightRect: TRectF;
    FSpellFill: TBrush;
    FSpellUnderlineBrush: TStrokeBrush;
    FEditPopupMenu: TPopupMenu;
    procedure UpdateSpelling;
    procedure InsertText(const AText: string);
    function GetSelText: string;
    function GetSelRect: TRectF;
    procedure SetCaretPosition(const Value: Integer);
    function GetCaretPosition: Integer;
    procedure MMCaretPositionChanged(var Message: TDispatchMessageWithValue<Integer>); message MM_EDIT_CARETPOSITION_CHANGED;
    function GetOriginCaretPosition: Integer;
    function GetCoordinatePosition(const Value: Single): Integer;
    procedure UpdateFirstVisibleChar;
    procedure UpdateCaretPosition;
    function GetModel: TCustomEditModel;
    { Standart Text Actions: Cut, Copy, Paste, Delete, Select All }
    procedure DoCopy(Sender: TObject);
    procedure DoCut(Sender: TObject);
    procedure DoDelete(Sender: TObject);
    procedure DoPaste(Sender: TObject);
    procedure DoSelectAll(Sender: TObject);
    { Selections }
    procedure BeginSelection;
    procedure EndSelection;
    function HaveSelectionPickers: Boolean;
    procedure UpdateSelectionPointPositions;
    procedure DoSelPtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DoLeftSelPtChangePosition(Sender: TObject; var X, Y: Single);
    procedure DoLeftSelPtMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure DoRightSelPtChangePosition(Sender: TObject; var X, Y: Single);
    procedure DoRightSelPtMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    { Loupe }
    procedure HideLoupe;
    procedure ShowLoupe;
    procedure SetLoupePosition(const ASelectionPointType: TSelectionPointType); overload;
    procedure SetLoupePosition(const X, Y: Single); overload;
    procedure SetSelectionMode(const AValue: TSelectionMode);
    procedure UpdateTextHeight;
    { ITextSpellCheck }
    function IsSpellCheckEnabled: Boolean;
    function IsCurrentWordWrong: Boolean;
    function GetListOfPrepositions: TArray<string>;
    procedure HighlightSpell;
    procedure HideHighlightSpell;
    { ITextSpellCheckActions }
    procedure Spell(const AWord: string);
    { ITextInput }
    function GetTextService: TTextService;
    procedure IMEStateUpdated;
    function GetTargetClausePointF: TPointF;
    procedure StartIMEInput;
    procedure EndIMEInput;
    function ITextInput.GetSelection = GetSelText;
    function ITextInput.GetSelectionRect = GetSelRect;
    function GetSelectionBounds: TRect;
    function GetSelectionPointSize: TSizeF;
    function HasText: Boolean;
    { Spelling }
    procedure UpdateSpellPopupMenu(const APoint: TPointF);
    procedure SpellFixContextMenuHandler(Sender: TObject);
    procedure UpdateTextLayout;
    function GetEditPopupMenu: TPopupMenu;
    procedure UpdatePromptTextSettings;
  protected
    FNeedChange: Boolean;

    procedure DoAnimationProcess(Sender: TObject);
    procedure DoAnimationFinish(Sender: TObject);
    procedure BuildOutlinedPathData;

    procedure Change; virtual;
    { Messages From Model }
    procedure MMSelLenghtChanged(var AMessage: TDispatchMessageWithValue<Integer>); message MM_EDIT_SELLENGTH_CHANGED;
    procedure MMSelStartChanged(var AMessage: TDispatchMessageWithValue<Integer>); message MM_EDIT_SELSTART_CHANGED;
    procedure MMCheckSpellingChanged(var AMessage: TDispatchMessageWithValue<Boolean>); message MM_EDIT_CHECKSPELLING_CHANGED;
    procedure MMPasswordChanged(var AMessage: TDispatchMessage); message MM_EDIT_ISPASSWORD_CHANGED;
    procedure MMImeModeChanged(var AMessage: TDispatchMessage); message MM_EDIT_IMEMODE_CHANGED;
    procedure MMTextSettingsChanged(var AMessage: TDispatchMessage); message MM_EDIT_TEXT_SETTINGS_CHANGED;
    procedure MMTextChanged(var AMessage: TDispatchMessageWithValue<string>); message MM_EDIT_TEXT_CHANGED;
    procedure MMTextChanging(var AMessage: TDispatchMessageWithValue<string>); message MM_EDIT_TEXT_CHANGING;
    procedure MMEditButtonsChanged(var Message: TDispatchMessage); message MM_EDIT_EDITBUTTONS_CHANGED;
    /// <summary>Notification about changing of <c>MaxLength</c> property value</summary>
    procedure MMMaxLengthChanged(var Message: TDispatchMessage); message MM_EDIT_MAXLENGTH_CHANGED;
    /// <summary>Notification about changing a <c>TextPrompt</c> property</summary>
    procedure MMPromptTextChanged(var Message: TDispatchMessage); message MM_EDIT_PROMPTTEXT_CHANGED;
    /// <summary>Notification about changing of <c>CharCase</c> property value</summary>
    procedure MMCharCaseChanged(var Message: TDispatchMessage); message MM_EDIT_CHARCASE_CHANGED;
    /// <summary>Notification about changing of <c>FilterChar</c> property value</summary>
    procedure MMFilterCharChanged(var Message: TDispatchMessage); message MM_EDIT_FILTERCHAR_CHANGED;
    { Messages from PresentationProxy }
    procedure PMInit(var Message: TDispatchMessage); message PM_INIT;
    procedure PMGetTextContentRect(var Message: TDispatchMessageWithValue<TRectF>); message PM_EDIT_GET_TEXT_CONTENT_RECT;
    procedure PMSetAdjustType(var AMessage: TDispatchMessageWithValue<TAdjustType>); message PM_SET_ADJUST_TYPE;
    { ICaret }
    function ICaret.GetObject = GetCaret;
    procedure ShowCaret;
    procedure HideCaret;
    function GetCaret: TCustomCaret;
    function GetTextSettings: TTextSettings;
    function GetEdit: TCustomEdit;
    /// <summary>Defines <c>TCustomEdit</c> model class</summary>
    function DefineModelClass: TDataModelClass; override;
  protected
    FLastKey: Word;
    FLastChar: System.WideChar;
    FClipboardSvc: IFMXClipboardService;
    procedure RepaintEdit;
    { Styles }
    procedure ApplyStyle; override;
    procedure FreeStyle; override;
    procedure Resize; override;
    procedure DoChangeTracking; virtual;
    function GetPasswordCharWidth: Single;
    function TextWidth(const AStart, ALength: Integer): Single;
    function GetText: string; virtual;
    procedure SetText(const Value: string); virtual;
    procedure SetTextInternal(const Value: string); virtual;
    procedure DoContentPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    { Base Mouse, Touches and Keyboard Events }
    procedure KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
    procedure CMGesture(var EventInfo: TGestureEventInfo); override;
    procedure LongTap(const X, Y: Single);
    procedure DblTap;
    procedure DoRealign; override;
    procedure DoTyping; virtual;
    procedure DoEnter; override;
    procedure DoExit; override;
    { Content alignment }
    procedure RealignContent; virtual;
    procedure RealignButtonsContainer; virtual;
    procedure UpdateLayoutSize;
    property TextHeight: Single read FTextHeight;
    property LineHeight: Single read FLineHeight;
    property LineTop: Single read FLineTop;
    property SelectionMode: TSelectionMode read FSelectionMode write SetSelectionMode;
    { Context menu }
    property EditPopupMenu: TPopupMenu read GetEditPopupMenu;
    function CreatePopupMenu: TPopupMenu; virtual;
    function FindContextMenuItem(const AItemName: string): TMenuItem;
    function ShowContextMenu(const ScreenPosition: TPointF): Boolean; override;
    procedure UpdatePopupMenuItems; virtual;
    property Edit: TCustomEdit read GetEdit;
    property ButtonsLayout: TControl read FButtonsLayout;
    property LeftLayout: TControl read FLeftLayout;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetCharX(a: Integer): Single;
    function ContentRect: TRectF;
    property CaretPosition: Integer read GetCaretPosition write SetCaretPosition;
    /// <summary>Model of <c>TEdit</c></summary>
    property Model: TCustomEditModel read GetModel;
    property SelText: string read GetSelText;
    property Text: string read GetText write SetText;
    property TextSettings: TTextSettings read GetTextSettings;
  end;

implementation

uses
  System.SysUtils, System.Math, System.RTLConsts, System.Character,
  System.TypInfo, FMX.Presentation.Factory,
  FMX.BehaviorManager, FMX.Consts, FMX.Forms, FMX.ActnList;

const
  LOUPE_OFFSET = 10;
  IMEWindowGap = 2; // 2 is small space between conrol and IME window

  CutStyleName = 'cut'; // Do not localize
  CopyStyleName = 'copy'; // Do not localize
  PasteStyleName = 'paste'; // Do not localize
  DeleteStyleName = 'delete'; // Do not localize
  SelectAllStyleName = 'selectall'; // Do not localize
  ButtonsStyleResourceName = 'buttons'; // Do not localize
  LeftButtonsStyleResourceName = 'leftbuttons'; // Do not localize
  PromptStyleResourcename = 'prompt'; // Do not localize
  ContentStyleResourceName = 'content'; // Do not localize
  SelectionStyleResourceName = 'selection'; // Do not localize
  ForegroundStyleResourceName = 'foreground'; // Do not localize
  FontStyleResourceName = 'font'; // Do not localize
  CaretColorStyleResouceName = 'caretcolor'; // Do not localize
  LeftSelectionPointStyleResourceName = 'leftselectionpoint'; // Do not localize
  RightSelectionPointStyleResourceName = 'rightselectionpoint';
  // Do not localize
  PromptVisibilityStyleDataName = 'prompt.Visible'; // do not localize

  { TStyledMDEdit }

procedure TStyledMDEdit.ApplyStyle;
var
  T: TFmxObject;
  BrushObject: TBrushObject;
  ColorObject: TColorObject;
  FontBehavior: IInterface;
  FontFamily: string;
  FontObject: IFontObject;
  Caption: ICaption;
begin
  TextSettings.BeginUpdate;
  Model.DisableNotify;
  try
    Model.TextSettingsInfo.Design := False;
    inherited ApplyStyle;

    { Container for right-hand buttons }
    FindStyleResource<TControl>(ButtonsStyleResourceName, FButtonsLayout);

    { Container for left-hand buttons }
    FindStyleResource<TControl>(LeftButtonsStyleResourceName, FLeftLayout);

    if (FButtonsLayout <> nil) or (FLeftLayout <> nil) then
      RealignButtonsContainer;

    { Content }
    if FindStyleResource<TControl>(ContentStyleResourceName, FContent) then
    begin
      FContent.Align := TAlignLayout.None;
      FContent.Margins.Left := 15;
      FContent.Margins.Right := 15;
      RealignContent;
      FContent.OnPaint := DoContentPaint;
      FContent.RecalcSize;
    end;

    { Text prompt }
    if FindStyleResource<TLabel>(PromptStyleResourcename, FPromptText) then
    begin
      if Supports(FPrompt, ICaption, Caption) then
        Caption.Text := Model.TextPrompt;
      FPromptText.Position.X := 16;
      FPromptText.Font.Size := 20;
      FPromptText.Height := 25;
      FPromptText.Width := Self.Width-32;
      FPromptText.Anchors:= [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
      FPromptText.TextSettings.WordWrap:=False;
      FPromptText.FontColor := $FF757575;
      FPromptText.Opacity := 1;
      FPromptText.HitTest := False;
      FPromptText.TextSettings.VertAlign := TTextAlign.Center;
      FPromptText.Text := Model.TextPrompt;
      FPromptText.RecalcSize;
      FPromptText.Position.Y := (FContent.Height / 2) - (FPromptText.Height / 2);

      FPromptFloatAnimation := TFloatAnimation.Create(FPromptText);
      FPromptFloatAnimation.Parent := FPromptText;
      FPromptFloatAnimation.SetSubComponent(True);
      FPromptFloatAnimation.Stored := False;
      FPromptFloatAnimation.AnimationType := TAnimationType.In;
      FPromptFloatAnimation.Enabled := False;
      FPromptFloatAnimation.StartValue := (FContent.Height / 2) - (FPromptText.Height / 2);
      FPromptFloatAnimation.StopValue := (FPromptText.Height / 2) * -1;
      FPromptFloatAnimation.Duration := 0.15;
      FPromptFloatAnimation.Interpolation := TInterpolationType.Linear;
      FPromptFloatAnimation.PropertyName := 'Position.Y';
      FPromptFloatAnimation.OnProcess := DoAnimationProcess;
      FPromptFloatAnimation.OnFinish := DoAnimationFinish;
    end;

    { Background }
    if FindStyleResource<TActiveStyleObject>('background', FBackground) then
    begin
      FBackground.Source := nil;
    end;

    { Brush selections }
    if FindStyleResource<TBrushObject>(SelectionStyleResourceName, BrushObject) then
      Model.SelectionFill.Assign(BrushObject.Brush);

    { Default text color }
    if FindStyleResource<TBrushObject>(ForegroundStyleResourceName, BrushObject) then
      Model.TextSettingsInfo.DefaultTextSettings.FontColor := BrushObject.Brush.Color;

    { Caret color }
    if FindStyleResource<TColorObject>(CaretColorStyleResouceName, ColorObject) then
      Model.Caret.DefaultColor := ColorObject.Color
    else
      Model.Caret.DefaultColor := TAlphaColorRec.Null;

    { Text font }
    T := FindStyleResource(FontStyleResourceName);
    if Supports(T, IFontObject, FontObject) then
      Model.TextSettingsInfo.DefaultTextSettings.Font := FontObject.Font;
    if Scene <> nil then
    begin
      TBehaviorServices.Current.SupportsBehaviorService(IFontBehavior, FontBehavior, Scene.GetObject);

      if FontBehavior <> nil then
      begin
        IFontBehavior(FontBehavior).GetDefaultFontFamily(Scene.GetObject, FontFamily);
        if FontFamily <> string.Empty then
          Model.TextSettingsInfo.DefaultTextSettings.Font.Family := FontFamily;
      end;
    end;

    { Selection points }
    if FindStyleResource<TSelectionPoint>(LeftSelectionPointStyleResourceName, FLeftSelPt) then
    begin
      FLeftSelPt.OnTrack := DoLeftSelPtChangePosition;
      FLeftSelPt.OnMouseDown := DoLeftSelPtMouseDown;
      FLeftSelPt.OnMouseUp := DoSelPtMouseUp;
      FLeftSelPt.Visible := False;
    end;
    if FindStyleResource<TSelectionPoint>(RightSelectionPointStyleResourceName, FRightSelPt) then
    begin
      FRightSelPt.OnTrack := DoRightSelPtChangePosition;
      FRightSelPt.OnMouseDown := DoRightSelPtMouseDown;
      FRightSelPt.OnMouseUp := DoSelPtMouseUp;
      FRightSelPt.Visible := False;
    end;
    TextSettings.Change;
  finally
    Model.EnableNotify;
    TextSettings.EndUpdate;
    Model.TextSettingsInfo.Design := csDesigning in ComponentState;
  end;
  UpdateTextLayout;
  UpdatePromptTextSettings;
end;

procedure TStyledMDEdit.BeginSelection;
begin
  SelectionMode := TSelectionMode.TextSelection;
  FTextService.BeginSelection;
end;

procedure TStyledMDEdit.BuildOutlinedPathData;
var
  LPromptTextWidth: Single;

  LPromptTextSettings: ITextSettings;

begin

  if not FNeedBuildOutlinedPathData then
    exit;
  FNeedBuildOutlinedPathData := False;

  if FPromptText <> nil then
    if Supports(FPromptText, ITextSettings, LPromptTextSettings) then
    begin
      LPromptTextSettings.StyledSettings := [];
    end;

  if Model.TextPrompt.IsEmpty then
    LPromptTextWidth := -2
  else
  begin
    if Assigned(LPromptTextSettings) then
      TCanvasManager.MeasureCanvas.Font.Assign(LPromptTextSettings.TextSettings.Font);
    LPromptTextWidth := TCanvasManager.MeasureCanvas.TextWidth(Model.TextPrompt) + 4; // do not localize
  end;

  FOutlinedPathData.Clear;
  if (not ParentControl.IsFocused) and (Model.Text.IsEmpty) then
    FOutlinedPathData.MoveTo(TPointF.Create(12, 0))
  else if Model.TextPrompt.IsEmpty then
    FOutlinedPathData.MoveTo(TPointF.Create(12, 0))
  else
    FOutlinedPathData.MoveTo(TPointF.Create(LPromptTextWidth + 16, 0));

  FOutlinedPathData.LineTo(TPointF.Create(SElf.Width - 14, 0));

  FOutlinedPathData.CurveTo(TPointF.Create(SElf.Width - 2, 0), TPointF.Create(SElf.Width - 2, 0), TPointF.Create(SElf.Width - 2, 12));

  FOutlinedPathData.LineTo(TPointF.Create(SElf.Width - 2, SElf.Height - 14));

  FOutlinedPathData.CurveTo(TPointF.Create(SElf.Width - 2, SElf.Height - 2), TPointF.Create(SElf.Width - 2, SElf.Height - 2), TPointF.Create(SElf.Width - 14, SElf.Height - 2));

  FOutlinedPathData.LineTo(TPointF.Create(12, SElf.Height - 2));

  FOutlinedPathData.CurveTo(TPointF.Create(0, SElf.Height - 2), TPointF.Create(0, SElf.Height - 2), TPointF.Create(0, SElf.Height - 14));

  FOutlinedPathData.LineTo(TPointF.Create(0, 12));

  FOutlinedPathData.CurveTo(TPointF.Create(0, 0), TPointF.Create(0, 0), TPointF.Create(12, 0));

  FOutlinedPathData.Translate(FContent.Margins.Left * -1 + 1, FContent.Margins.Top * -1 + 1);

end;

procedure TStyledMDEdit.MMCaretPositionChanged(var Message: TDispatchMessageWithValue<Integer>);
begin
  SetCaretPosition(Message.Value);
end;

procedure TStyledMDEdit.Change;
begin

end;

procedure TStyledMDEdit.CMGesture(var EventInfo: TGestureEventInfo);
var
  LocalPoint: TPointF;
begin
  if EventInfo.GestureID = igiLongTap then
  begin
    LocalPoint := AbsoluteToLocal(EventInfo.Location);
    LongTap(LocalPoint.X, LocalPoint.Y);
  end
  else if EventInfo.GestureID = igiDoubleTap then
    DblTap
  else
    inherited;
end;

function TStyledMDEdit.ContentRect: TRectF;
begin
  if FContent <> nil then
    Result := FContent.BoundsRect
  else
    Result := LocalRect;
end;

constructor TStyledMDEdit.Create(AOwner: TComponent);
var
  PlatformTextService: IFMXTextService;
begin
  inherited;

  FOutlinedPathData := TPathData.Create;
  FNeedBuildOutlinedPathData := True;

  EnableExecuteAction := False;
  FTextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(FClipboardSvc)) then
    FClipboardSvc := nil;
  if TPlatformServices.Current.SupportsPlatformService(IFMXTextService, IInterface(PlatformTextService)) then
    FTextService := PlatformTextService.GetTextServiceClass.Create(SElf, False);
  TPlatformServices.Current.SupportsPlatformService(ILoupeService, IInterface(FLoupeService));

  FCursorFill := TBrush.Create(TBrushKind.Solid, TAlphaColorRec.Black);
  CanFocus := False;
  AutoCapture := True;
  FFirstVisibleChar := 1;
  FInvisibleTextWidth := 0;
  SetAcceptsControls(False);
  Touch.InteractiveGestures := Touch.InteractiveGestures + [TInteractiveGesture.DoubleTap, TInteractiveGesture.LongTap];

  FSpellMenuItems := TList<TMenuItem>.Create;
  FSpellFill := TBrush.Create(TBrushKind.Solid, TAlphaColorRec.Red);
  FSpellUnderlineBrush := TStrokeBrush.Create(TBrushKind.Solid, TAlphaColorRec.Red);
  FSpellUnderlineBrush.Dash := TStrokeDash.Dot;
  FSpellUnderlineBrush.Thickness := 1;
end;

function TStyledMDEdit.CreatePopupMenu: TPopupMenu;
var
  TmpItem: TMenuItem;
begin
  Result := TPopupMenu.Create(SElf);
  Result.Stored := False;

  TmpItem := TMenuItem.Create(Result);
  TmpItem.Parent := Result;
  TmpItem.Text := SEditCut;
  TmpItem.StyleName := CutStyleName;
  TmpItem.OnClick := DoCut;

  TmpItem := TMenuItem.Create(Result);
  TmpItem.Parent := Result;
  TmpItem.Text := SEditCopy;
  TmpItem.StyleName := CopyStyleName;
  TmpItem.OnClick := DoCopy;

  TmpItem := TMenuItem.Create(Result);
  TmpItem.Parent := Result;
  TmpItem.Text := SEditPaste;
  TmpItem.StyleName := PasteStyleName;
  TmpItem.OnClick := DoPaste;

  TmpItem := TMenuItem.Create(Result);
  TmpItem.Parent := Result;
  TmpItem.Text := SEditDelete;
  TmpItem.StyleName := DeleteStyleName;
  TmpItem.OnClick := DoDelete;

  TmpItem := TMenuItem.Create(Result);
  TmpItem.Parent := Result;
  TmpItem.Text := SMenuSeparator;

  TmpItem := TMenuItem.Create(Result);
  TmpItem.Parent := Result;
  TmpItem.Text := SEditSelectAll;
  TmpItem.StyleName := SelectAllStyleName;
  TmpItem.OnClick := DoSelectAll;
end;

procedure TStyledMDEdit.DblTap;
begin
  Edit.SelectWord;
end;

function TStyledMDEdit.DefineModelClass: TDataModelClass;
begin
  Result := TCustomEditModel;
end;

destructor TStyledMDEdit.Destroy;
begin
  if Assigned(FPromptFloatAnimation) then
  begin
    FPromptFloatAnimation.Stop;
  end;

  FOutlinedPathData.Free;

  FLoupeService := nil;
  FreeAndNil(FCursorFill);
  FreeAndNil(FEditPopupMenu);
  FreeAndNil(FTextService);
  FClipboardSvc := nil;
  FSpellService := nil;
  Finalize(FSpellingRegions);
  FreeAndNil(FSpellMenuItems);
  FreeAndNil(FSpellFill);
  FreeAndNil(FSpellUnderlineBrush);
  FreeAndNil(FTextLayout);
  inherited;
end;

procedure TStyledMDEdit.DoAnimationFinish(Sender: TObject);
begin
  ShowCaret;
end;

procedure TStyledMDEdit.DoAnimationProcess(Sender: TObject);
begin
  HideCaret;
end;

procedure TStyledMDEdit.DoChangeTracking;
begin
  UpdateSpelling;
end;

procedure TStyledMDEdit.DoContentPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  i: Integer;
  R: TRectF;
  State: TCanvasSaveState;
  WholeTextWidth: Single;
  EditRectWidth: Single;
  T: string;

  function GetSelectionRectInLocalCoordinate: TRectF;
  begin
    Result := GetSelRect;
    OffsetRect(Result, -ContentRect.Left, -ContentRect.Top);
  end;

  procedure DrawSelection;
  var
    SelectionRect: TRectF;
  begin
    SelectionRect := GetSelectionRectInLocalCoordinate;
    Canvas.FillRect(SelectionRect, 0, 0, AllCorners, AbsoluteOpacity, Model.SelectionFill);
  end;

  procedure DrawLeftAndRightSelectionSide;
  var
    SelectionRect: TRectF;
    HalfCaretWidth: Single;
    SideRect: TRectF;
  begin
    SelectionRect := GetSelectionRectInLocalCoordinate;
    HalfCaretWidth := Model.Caret.Flasher.Size.Width / 2;
    FCursorFill.Color := Model.Caret.Flasher.Color;
    // Draw Left selection side
    SideRect := RectF(SelectionRect.Left - HalfCaretWidth, SelectionRect.Top, SelectionRect.Left + HalfCaretWidth, SelectionRect.Bottom);
    Canvas.FillRect(SideRect, 0, 0, AllCorners, AbsoluteOpacity, FCursorFill);
    // Draw Right selection side
    SideRect := RectF(SelectionRect.Right - HalfCaretWidth, SelectionRect.Top, SelectionRect.Right + HalfCaretWidth, SelectionRect.Bottom);
    Canvas.FillRect(SideRect, 0, 0, AllCorners, AbsoluteOpacity, FCursorFill);
  end;

var
  Shift, BP, EP, J: Integer;
  Rgn: TRegion;
  LText: string;
  VisibleCharPos: Single;
  FEdit: TMDEdit;
begin
  BuildOutlinedPathData;
  FEdit := GetEdit as TMDEdit;
  Canvas.Stroke.Kind := TBrushKind.Solid;
  if ParentControl.IsFocused then
  begin
    Canvas.Stroke.Color := FEdit.FocusedMaterialColor;
    FPromptText.FontColor := FEdit.FocusedMaterialColor;
    Canvas.Stroke.Thickness := 2;
  end
  else
  begin
    Canvas.Stroke.Color := FEdit.MaterialColor;
    FPromptText.FontColor := FEdit.PromptTextColor;
    Canvas.Stroke.Thickness := IfThen(GlobalUseGPUCanvas, 2, 1);
  end;

{$IFDEF UseNativeDraw}Canvas.NativeDraw(TRectF.Create(0, 0, SElf.Width, SElf.Height),
    procedure
    begin {$ENDIF}
      Canvas.DrawPath(FOutlinedPathData, SElf.Opacity);
{$IFDEF UseNativeDraw} end); {$ENDIF}
  if ((FTextService = nil)) or (FTextService.Text.IsEmpty and (not FTextService.HasMarkedText)) then
    exit;
  State := Canvas.SaveState;
  try
    { draw text }
    Canvas.IntersectClipRect(ARect);
    Canvas.Fill.Color := Model.TextSettingsInfo.ResultingTextSettings.FontColor;
    R := FContent.Padding.PaddingRect(ARect);
    if Model.Password then
    begin
      R.Right := R.Left + GetPasswordCharWidth - 1;
      R.Top := LineTop - ContentRect.Top + ((LineHeight - R.Width) / 2);
      R.Bottom := R.Top + RectWidth(R);
      T := FTextService.CombinedText;
      WholeTextWidth := T.Length * GetPasswordCharWidth;
      EditRectWidth := FContent.Padding.PaddingRect(ContentRect).Width;
      if WholeTextWidth < EditRectWidth then
        case Model.TextSettingsInfo.ResultingTextSettings.HorzAlign of
          TTextAlign.Trailing:
            OffsetRect(R, (EditRectWidth - WholeTextWidth), 0);
          TTextAlign.Center:
            OffsetRect(R, ((EditRectWidth - WholeTextWidth) / 2), 0);
        end;
      for i := FFirstVisibleChar to T.Length do
      begin
        Canvas.FillEllipse(R, AbsoluteOpacity, Canvas.Fill);
        OffsetRect(R, R.Width + 1, 0);
      end;
    end
    else
    begin
      FTextService.DrawSingleLine(Canvas, R, FFirstVisibleChar, Model.TextSettingsInfo.ResultingTextSettings.Font, AbsoluteOpacity, FillTextFlags,
        Model.TextSettingsInfo.ResultingTextSettings.HorzAlign, Model.TextSettingsInfo.ResultingTextSettings.VertAlign);
    end;
    { Draw selection }
    if ParentControl.IsFocused and Model.HasSelection then
    begin
      DrawSelection;
      { left picker -> | selected text | <- right picker }
      if HaveSelectionPickers then
        DrawLeftAndRightSelectionSide;
    end;
    // Spell highlighting
    if Model.CheckSpelling and (FSpellService <> nil) and not FTextService.HasMarkedText and not Text.IsEmpty then
    begin
      if FUpdateSpelling then
      begin
        LText := Text;
        Shift := 0;
        while (LText.Length > 0) and FMX.Text.FindWordBound(LText, 0, BP, EP) do
        begin
          if Length(FSpellService.CheckSpelling(LText.Substring(BP, EP - BP + 1))) > 0 then
          begin
            Rgn := FTextLayout.RegionForRange(TTextRange.Create(Shift + BP, EP - BP + 1));
            for J := Low(Rgn) to High(Rgn) do
            begin
              SetLength(FSpellingRegions, Length(FSpellingRegions) + 1);
              FSpellingRegions[High(FSpellingRegions)] := Rgn[J];
              R := ContentRect;
              FSpellingRegions[High(FSpellingRegions)].Offset(-R.Left, -R.Top);
            end;
          end;
          LText := LText.Remove(0, EP + 1);
          Inc(Shift, EP + 1);
        end;
        FUpdateSpelling := False;
      end;
      if Length(FSpellingRegions) > 0 then
      begin
        if FFirstVisibleChar > 1 then
        begin
          Rgn := FTextLayout.RegionForRange(TTextRange.Create(FFirstVisibleChar - 1, 1));
          if Length(Rgn) > 0 then
            VisibleCharPos := Rgn[0].Left
          else
            VisibleCharPos := 0;
        end
        else
          VisibleCharPos := 0;
        for i := Low(FSpellingRegions) to High(FSpellingRegions) do
          Canvas.DrawLine(TPointF.Create(FSpellingRegions[i].Left - VisibleCharPos, FSpellingRegions[i].Bottom), TPointF.Create(FSpellingRegions[i].Right - VisibleCharPos,
            FSpellingRegions[i].Bottom), AbsoluteOpacity, FSpellUnderlineBrush);
      end;
      if not FSpellHightlightRect.IsEmpty then
        Canvas.FillRect(FSpellHightlightRect, 0, 0, [], 0.2, FSpellFill);
    end;
  finally
    Canvas.RestoreState(State);
  end;
end;

procedure TStyledMDEdit.DoCopy(Sender: TObject);
begin
  Edit.CopyToClipboard;
end;

procedure TStyledMDEdit.DoCut(Sender: TObject);
begin
  Edit.CutToClipboard;
end;

procedure TStyledMDEdit.DoDelete(Sender: TObject);
begin
  if Observers.IsObserving(TObserverMapping.EditLinkID) then
    if not TLinkObservers.EditLinkEdit(Observers) then
    begin
      TLinkObservers.EditLinkReset(Observers);
      exit;
    end
    else
      TLinkObservers.EditLinkModified(Observers);
  if Observers.IsObserving(TObserverMapping.ControlValueID) then
    TLinkObservers.ControlValueModified(Observers);

  Edit.DeleteSelection;
end;

procedure TStyledMDEdit.DoEnter;
var
  Form: TCommonCustomForm;
begin
  inherited;
  FFocused := True;
  FPromptText.Repaint;
  if Model.Text.IsEmpty then
  begin
    if Assigned(FPromptFloatAnimation) then
    begin
      FPromptFloatAnimation.Enabled := False;
      FPromptFloatAnimation.Inverse := False;
      FPromptFloatAnimation.Enabled := True;
    end;
    FNeedBuildOutlinedPathData := True;
    if FPromptText <> nil then
    begin
      FPromptText.TextSettings.Font.Size := 16;
      FPromptText.RecalcSize;
    end;

  end
  else
  begin
    TThread.CreateAnonymousThread(
      procedure
      begin
        if Assigned(FPromptFloatAnimation) then
          TThread.Sleep(Round(FPromptFloatAnimation.Duration * 1000));
        if FPromptText <> nil then
        begin
          FPromptText.TextSettings.Font.Size := 16;
          FPromptText.RecalcSize;
        end;
      end).Start;

  end;

  Form := TCommonCustomForm(Root);
  if not Model.ReadOnly and Model.InputSupport and not FTextService.HasMarkedText and
    ((Form = nil) or (Form.FormState - [TFmxFormState.Showing, TFmxFormState.Engaged, TFmxFormState.Modal] = [])) then
    Edit.SelectAll
  else
  begin
    UpdateSelectionPointPositions;
    UpdateCaretPosition;
  end;
end;

procedure TStyledMDEdit.DoExit;
begin
  FFocused := False;
  if Assigned(FPromptText) then
  begin
    FPromptText.Repaint;
  end;
  if Model.Text.IsEmpty then
  begin
    if Assigned(FPromptFloatAnimation) then
    begin
      FPromptFloatAnimation.Enabled := False;
      FPromptFloatAnimation.Inverse := True;
      FPromptFloatAnimation.Enabled := True;
    end;
    if FPromptText <> nil then
    begin
      FPromptText.TextSettings.Font.Size := 20;
      FPromptText.RecalcSize;
    end;
    FNeedBuildOutlinedPathData := True;

  end;
  if FScene <> nil then
  begin
    Model.Change;
    if Observers.IsObserving(TObserverMapping.EditLinkID) then
      TLinkObservers.EditLinkUpdate(Observers);
    if Observers.IsObserving(TObserverMapping.ControlValueID) then
      TLinkObservers.ControlValueUpdate(Observers);
    inherited;
    UpdateSelectionPointPositions;
  end
  else
    inherited;
end;

procedure TStyledMDEdit.DoLeftSelPtChangePosition(Sender: TObject; var X, Y: Single);
var
  CurrentPoint: TPointF;
  NewSelStart: Integer;
  OldSelStart: Integer;
  OldSelLength: Integer;
  NewSelLength: Integer;
  OldSelEnd: Integer;
begin
  if FLeftSelPt = nil then
    exit;
  CurrentPoint := FLeftSelPt.Position.Point;

  OldSelStart := Model.SelStart;
  OldSelLength := Model.SelLength;
  OldSelEnd := Model.SelStart + Model.SelLength;
  NewSelStart := GetCoordinatePosition(X);
  NewSelLength := OldSelLength + OldSelStart - NewSelStart;

  Model.DisableNotify;
  try
    if NewSelStart < OldSelEnd - 1 then
    begin
      X := GetCharX(NewSelStart);
      Model.SelStart := NewSelStart;
      Model.SelLength := NewSelLength;
    end
    else
    begin
      X := GetCharX(OldSelEnd - 1);
      Model.SelStart := OldSelEnd - 1;
      Model.SelLength := 1;
    end;
  finally
    Model.EnableNotify;
  end;
  Y := CurrentPoint.Y;
  SetLoupePosition(TSelectionPointType.Left);
  UpdateSelectionPointPositions;
end;

procedure TStyledMDEdit.DoLeftSelPtMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  BeginSelection;
  SetLoupePosition(TSelectionPointType.Left);
  ShowLoupe;
end;

procedure TStyledMDEdit.DoPaste(Sender: TObject);
begin
  Edit.PasteFromClipboard;
end;

procedure TStyledMDEdit.DoRealign;
begin
  inherited;
  RealignContent;
  RealignButtonsContainer;
  CaretPosition := GetOriginCaretPosition;
end;

procedure TStyledMDEdit.DoRightSelPtChangePosition(Sender: TObject; var X, Y: Single);
var
  CurrentPoint: TPointF;
  NewSelEnd: Integer;
  OldSelStart: Integer;
  OldSelLength: Integer;
  NewSelLength: Integer;
  OldSelEnd: Integer;
  MinSelEnd: Integer;
begin
  if FRightSelPt = nil then
    exit;
  CurrentPoint := FRightSelPt.Position.Point;
  Y := CurrentPoint.Y;

  OldSelStart := Model.SelStart;
  OldSelLength := Model.SelLength;
  OldSelEnd := Model.SelStart + Model.SelLength;
  MinSelEnd := Model.SelStart + 1;
  NewSelEnd := GetCoordinatePosition(X);
  NewSelLength := OldSelLength + NewSelEnd - OldSelEnd;

  Model.DisableNotify;
  try
    if NewSelEnd > MinSelEnd then
    begin
      X := GetCharX(NewSelEnd);
      Model.SelStart := NewSelEnd - NewSelLength;
      Model.SelLength := NewSelLength;
    end
    else
    begin
      X := GetCharX(MinSelEnd);
      Model.SelStart := OldSelStart;
      Model.SelLength := 1;
    end;
  finally
    Model.EnableNotify;
  end;

  SetLoupePosition(TSelectionPointType.Right);
  UpdateSelectionPointPositions;
end;

procedure TStyledMDEdit.DoRightSelPtMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  BeginSelection;
  SetLoupePosition(TSelectionPointType.Right);
  ShowLoupe;
end;

procedure TStyledMDEdit.DoSelectAll(Sender: TObject);
begin
  Edit.SelectAll;
end;

procedure TStyledMDEdit.DoSelPtMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  EndSelection;
end;

procedure TStyledMDEdit.DoTyping;
begin
  if Assigned(Model.OnTyping) then
    Model.OnTyping(PresentedControl);
end;

procedure TStyledMDEdit.EndIMEInput;
begin
  Model.DisableNotify;
  try
    Model.Text := FTextService.CombinedText;
  finally
    Model.EnableNotify;
  end;
  FTextService.Text := FTextService.CombinedText;
  FTextService.CaretPosition := Point(GetOriginCaretPosition + FTextService.CombinedText.Length - FTextService.Text.Length, 0);
  RepaintEdit;
end;

procedure TStyledMDEdit.EndSelection;
begin
  HideLoupe;
  SelectionMode := TSelectionMode.None;
  FTextService.EndSelection;
end;

function TStyledMDEdit.FindContextMenuItem(const AItemName: string): TMenuItem;
var
  MenuObject: TFmxObject;
begin
  Result := nil;
  if FEditPopupMenu <> nil then
  begin
    MenuObject := FEditPopupMenu.FindStyleResource(AItemName);
    if MenuObject is TMenuItem then
      Result := TMenuItem(MenuObject);
  end;
end;

procedure TStyledMDEdit.FreeStyle;
begin
  inherited;
  FContent := nil;
  FButtonsLayout := nil;
  FLeftSelPt := nil;
  FRightSelPt := nil;
  FLeftLayout := nil;
  FPrompt := nil;
  FPromptText := nil;
  FBackground := nil;
  if Assigned(FPromptFloatAnimation) then
    FreeAndNil(FPromptFloatAnimation);
end;

function TStyledMDEdit.GetCaret: TCustomCaret;
begin
  Result := Model.Caret;
end;

function TStyledMDEdit.GetCaretPosition: Integer;
begin
  if FTextService <> nil then
    Result := FTextService.TargetClausePosition.X
  else
    Result := -1;
end;

function TStyledMDEdit.GetCharX(a: Integer): Single;
var
  WholeTextWidth: Single;
  EditRectWidth: Single;
  T: string;
  Rgn: TRegion;
begin
  if FContent <> nil then
  begin
    if Model.Password then
    begin
      T := FTextService.CombinedText;
      WholeTextWidth := T.Length * GetPasswordCharWidth;
      Result := ContentRect.Left;
      if a > 0 then
      begin
        if a <= T.Length then
          Result := Result + (a - FFirstVisibleChar + 1) * GetPasswordCharWidth
        else
          Result := Result + (T.Length - FFirstVisibleChar + 1) * GetPasswordCharWidth;
      end;
      EditRectWidth := FContent.Padding.PaddingRect(ContentRect).Width;
      if WholeTextWidth < EditRectWidth then
        case Model.TextSettingsInfo.ResultingTextSettings.HorzAlign of
          TTextAlign.Trailing:
            Result := Result + (EditRectWidth - WholeTextWidth);
          TTextAlign.Center:
            Result := Result + ((EditRectWidth - WholeTextWidth) / 2);
        end;
    end
    else
    begin
      Rgn := FTextLayout.RegionForRange(TTextRange.Create(0, 1));
      if Length(Rgn) > 0 then
        Result := Rgn[0].Left
      else
        Result := 0;
      if (FFirstVisibleChar - 1) < a then
      begin
        Rgn := FTextLayout.RegionForRange(TTextRange.Create(FFirstVisibleChar - 1, a - FFirstVisibleChar + 1));
        if Length(Rgn) > 0 then
          Result := Result + Rgn[High(Rgn)].Width;
      end;
      if Model.TextSettingsInfo.ResultingTextSettings.HorzAlign <> TTextAlign.Leading then
      begin
        EditRectWidth := FContent.Padding.PaddingRect(ContentRect).Width;
        WholeTextWidth := ContentRect.Width;
        if WholeTextWidth < EditRectWidth then
          case Model.TextSettingsInfo.ResultingTextSettings.HorzAlign of
            TTextAlign.Trailing:
              Result := Result + (EditRectWidth - WholeTextWidth);
            TTextAlign.Center:
              Result := Result + ((EditRectWidth - WholeTextWidth) / 2);
          end;
      end;
    end;
    Result := Result + FContent.Padding.Left;
  end
  else
    Result := 0;
end;

function TStyledMDEdit.GetCoordinatePosition(const Value: Single): Integer;
var
  TmpX, WholeTextWidth, EditRectWidth: Single;
  CombinedText: string;
begin
  Result := FFirstVisibleChar - 1;
  CombinedText := FTextService.CombinedText;

  if not CombinedText.IsEmpty then
  begin
    if Model.Password then
    begin
      WholeTextWidth := CombinedText.Length * GetPasswordCharWidth;

      EditRectWidth := FContent.Padding.PaddingRect(ContentRect).Width;
      TmpX := Value;
      if WholeTextWidth < EditRectWidth then
        case Model.TextSettingsInfo.ResultingTextSettings.HorzAlign of
          TTextAlign.Trailing:
            TmpX := Value - (EditRectWidth - WholeTextWidth);
          TTextAlign.Center:
            TmpX := Value - ((EditRectWidth - WholeTextWidth) / 2);
        end;

      Result := Result + Trunc((TmpX - ContentRect.Left) / GetPasswordCharWidth);
      if Result < 0 then
        Result := 0
      else if Result > CombinedText.Length then
        Result := CombinedText.Length;
    end
    else
      Result := FTextLayout.PositionAtPoint(TPointF.Create(Value + FInvisibleTextWidth, FTextLayout.TextRect.Top + FTextLayout.TextHeight / 2));
  end;
end;

function TStyledMDEdit.GetEdit: TCustomEdit;
begin
  Result := PresentedControl as TCustomEdit
end;

function TStyledMDEdit.GetEditPopupMenu: TPopupMenu;
begin
  if FEditPopupMenu = nil then
    FEditPopupMenu := CreatePopupMenu;
  Result := FEditPopupMenu;
end;

function TStyledMDEdit.GetListOfPrepositions: TArray<string>;
var
  BP, EP: Integer;
begin
  Result := nil;
  if not Text.IsEmpty and (GetOriginCaretPosition >= 0) then
    if FMX.Text.FindWordBound(Text, GetOriginCaretPosition, BP, EP) then
      Result := FSpellService.CheckSpelling(Text.Substring(BP, EP - BP + 1));
end;

function TStyledMDEdit.GetModel: TCustomEditModel;
begin
  Result := inherited GetModel<TCustomEditModel>;
end;

function TStyledMDEdit.GetOriginCaretPosition: Integer;
begin
  if FTextService <> nil then
    Result := FTextService.CaretPosition.X
  else
    Result := -1;
end;

function TStyledMDEdit.GetPasswordCharWidth: Single;
begin
  Result := Model.TextSettingsInfo.ResultingTextSettings.Font.Size / 2;
end;

function TStyledMDEdit.GetSelectionBounds: TRect;
begin
  Result := Rect(Model.SelStart, 0, Model.SelStart + Model.SelLength, 0);
end;

function TStyledMDEdit.GetSelectionPointSize: TSizeF;
begin
  if FLeftSelPt <> nil then
  begin
    FLeftSelPt.ApplyStyleLookup;
    Result := FLeftSelPt.Size.Size;
  end
  else
    Result := TSizeF.Create(0, 0);
end;

function TStyledMDEdit.GetSelRect: TRectF;
var
  Offset, StartPosition, EndPosition: Integer;
begin
  Result := ContentRect;
  Result.Top := Trunc(LineTop);
  Result.Bottom := Result.Top + LineHeight;
{$IFNDEF ANDROID}
  if GetOriginCaretPosition <= Min(Model.SelStart, Model.SelStart + Model.SelLength) then
    Offset := FTextService.CombinedText.Length - FTextService.Text.Length
  else
    Offset := 0;
{$ELSE}
  Offset := 0;
{$ENDIF}
  StartPosition := Model.SelStart + Offset;
  EndPosition := Model.SelStart + Model.SelLength + Offset;
  Result.Left := GetCharX(Min(StartPosition, EndPosition));
  Result.Right := GetCharX(Max(StartPosition, EndPosition));
end;

function TStyledMDEdit.GetSelText: string;
begin
  Result := Model.SelectedText;
end;

function TStyledMDEdit.GetTargetClausePointF: TPointF;
var
  Str: String;
begin
  Str := FTextService.CombinedText.Substring(0, Round(FTextService.TargetClausePosition.X));
  if FFirstVisibleChar > 1 then
    Str := Str.Substring(FFirstVisibleChar - 1, MaxInt);
  Result.X := TextWidth(0, Str.Length);
  Result.Y := (ContentRect.Height / 2) + Model.TextSettingsInfo.ResultingTextSettings.Font.Size / 2 + IMEWindowGap;
  Result.Offset(ContentRect.TopLeft);
  Result := LocalToAbsolute(Result);
end;

function TStyledMDEdit.GetText: string;
begin
  Result := FTextService.CombinedText;
end;

function TStyledMDEdit.GetTextService: TTextService;
begin
  Result := FTextService;
end;

function TStyledMDEdit.GetTextSettings: TTextSettings;
begin
  Result := Model.TextSettingsInfo.TextSettings;
end;

function TStyledMDEdit.HasText: Boolean;
begin
  Result := Text.Length > 0;
end;

function TStyledMDEdit.HaveSelectionPickers: Boolean;
begin
  Result := (FLeftSelPt <> nil) and (FRightSelPt <> nil);
end;

procedure TStyledMDEdit.HideCaret;
begin
  Model.Caret.Hide;
end;

procedure TStyledMDEdit.HideHighlightSpell;
begin
  FSpellHightlightRect := TRectF.Empty;
  Model.Caret.TemporarilyHidden := (Model.SelLength > 0) and (ParentControl <> nil) and ParentControl.IsFocused;
  RepaintEdit;
end;

procedure TStyledMDEdit.HideLoupe;
begin
  if FLoupeService <> nil then
    FLoupeService.Hide;
end;

procedure TStyledMDEdit.HighlightSpell;
var
  BP, EP: Integer;
  Rgn: TRegion;
  R: TRectF;
begin
  if not Text.IsEmpty and (GetOriginCaretPosition >= 0) then
    if FMX.Text.FindWordBound(Text, GetOriginCaretPosition, BP, EP) then
    begin
      Rgn := FTextLayout.RegionForRange(TTextRange.Create(BP, EP - BP + 1));
      if Length(Rgn) > 0 then
      begin
        FSpellHightlightRect := Rgn[0];
        R := ContentRect;
        FSpellHightlightRect.Offset(-R.Left, -R.Top);
      end
      else
        FSpellHightlightRect := TRectF.Empty;
    end;
  Model.Caret.TemporarilyHidden := True;
  RepaintEdit;
end;

procedure TStyledMDEdit.InsertText(const AText: string);
var
  OldText: string;
  SelStart, SelLength: Integer;
begin
  if Model.ReadOnly and not Model.InputSupport then
    exit;

  OldText := Text;
  SelStart := Min(Model.SelStart, Model.SelStart + Model.SelLength);
  SelLength := Abs(Model.SelLength);

  OldText := OldText.Remove(SelStart, SelLength);

  SelStart := CaretPosition;
  if Model.SelLength < 0 then
    SelStart := SelStart + Model.SelLength;
  OldText := OldText.Insert(SelStart, AText);

  Model.DisableNotify;
  try
    Model.SelLength := 0;
  finally
    Model.EnableNotify;
  end;

  if (Model.MaxLength <= 0) or (OldText.Length <= Model.MaxLength) then
  begin
    SetTextInternal(OldText);
    CaretPosition := SelStart + AText.Length;
  end;
end;

function TStyledMDEdit.IsCurrentWordWrong: Boolean;
var
  Rgn: TRegion;
  i: Integer;
begin
  Result := False;
  Rgn := FTextLayout.RegionForRange(TTextRange.Create(GetOriginCaretPosition, 1));
  if Length(Rgn) > 0 then
    for i := Low(FSpellingRegions) to High(FSpellingRegions) do
      if FSpellingRegions[i].Contains(Rgn[0].TopLeft) then
      begin
        Result := True;
        Break;
      end;
end;

function TStyledMDEdit.IsSpellCheckEnabled: Boolean;
begin
  Result := Model.CheckSpelling;
end;

procedure TStyledMDEdit.KeyDown(var Key: Word; var KeyChar: System.WideChar; Shift: TShiftState);
var
  TmpS: string;
  OldCaretPosition: Integer;
  LCaret: Integer;
  IsCtrlOrCmd, KeyHandled: Boolean;
begin
  if not Model.InputSupport then
    exit;
  KeyHandled := False;
  try
    if Observers.IsObserving(TObserverMapping.EditLinkID) then
    begin
      if (Key = vkBack) or (Key = vkDelete) or ((Key = vkInsert) and (ssShift in Shift)) then
        if not TLinkObservers.EditLinkEdit(Observers) then
        begin
          TLinkObservers.EditLinkReset(Observers);
          KeyHandled := True;
          exit;
        end;

      if (KeyChar >= #32) and not TLinkObservers.EditLinkIsValidChar(Observers, KeyChar) then
      begin
        KeyHandled := True;
        exit;
      end;
      case KeyChar of
        ^H, ^V, ^X, #32 .. High(Char):
          if not TLinkObservers.EditLinkEdit(Observers) then
          begin
            TLinkObservers.EditLinkReset(Observers);
            KeyHandled := True;
            exit;
          end;
        #27:
          begin
            TLinkObservers.EditLinkReset(Observers);
            Edit.SelectAll;
            KeyHandled := True;
            exit;
          end;
      end;

      if TLinkObservers.EditLinkIsEditing(Observers) then
        TLinkObservers.EditLinkModified(Observers);
    end;
    if Observers.IsObserving(TObserverMapping.ControlValueID) then
      TLinkObservers.ControlValueModified(Observers);

    inherited;
    OldCaretPosition := GetOriginCaretPosition;
    FLastChar := KeyChar;
    FLastKey := Key;
    IsCtrlOrCmd := Shift * [ssCtrl, ssCommand] <> [];
    case Key of
      vkA:
        if IsCtrlOrCmd and (Shift * [ssAlt, ssShift] = []) then
        begin
          Edit.SelectAll;
          KeyHandled := True;
        end;
      vkC:
        if IsCtrlOrCmd then
        begin
          Edit.CopyToClipboard;
          KeyHandled := True;
        end;
      vkV:
        if IsCtrlOrCmd then
        begin
          Edit.PasteFromClipboard;
          DoTyping;
          KeyHandled := True;
        end;
      vkX:
        if IsCtrlOrCmd and not Model.ReadOnly then
        begin
          Edit.CutToClipboard;
          DoTyping;
          KeyHandled := True;
        end;
      vkZ:
        if IsCtrlOrCmd then
        begin
          if Observers.IsObserving(TObserverMapping.EditLinkID) then
            TLinkObservers.EditLinkReset(Observers);
          if Observers.IsObserving(TObserverMapping.ControlValueID) then
            TLinkObservers.ControlValueUpdate(Observers);
          KeyHandled := True;
        end;
      vkReturn:
        begin
          Model.DisableNotify;
          try
            Model.Typing := False;
          finally
            Model.EnableNotify;
          end;
          Model.Change;
          if Observers.IsObserving(TObserverMapping.EditLinkID) then
            TLinkObservers.EditLinkUpdate(Observers);
          if Observers.IsObserving(TObserverMapping.ControlValueID) then
            TLinkObservers.ControlValueUpdate(Observers);
          if Model.KillFocusByReturn and (Root <> nil) then
            Root.SetFocused(nil);
          // not need to perform KeyHandled := True;
        end;
      vkEnd:
        begin
          CaretPosition := Text.Length;
          KeyHandled := True;
        end;
      vkHome:
        begin
          CaretPosition := 0;
          KeyHandled := True;
        end;
      vkLeft:
        begin
          if IsCtrlOrCmd then
          begin
            CaretPosition := GetPrevLexemeBegin(Text, GetOriginCaretPosition);
            KeyHandled := True;
          end
          else if (GetOriginCaretPosition > 0) and not Text.IsEmpty then
          begin
            if Text.Chars[GetOriginCaretPosition - 1].IsLowSurrogate then
              CaretPosition := GetOriginCaretPosition - 2
            else
              CaretPosition := GetOriginCaretPosition - 1;
            KeyHandled := True;
          end;
        end;
      vkRight:
        begin
          if IsCtrlOrCmd then
          begin
            CaretPosition := GetNextLexemeBegin(Text, GetOriginCaretPosition);
            KeyHandled := True;
          end
          else if (Text.Length > GetOriginCaretPosition) then
          begin
            if Text.Chars[GetOriginCaretPosition].IsHighSurrogate then
              CaretPosition := GetOriginCaretPosition + 2
            else
              CaretPosition := GetOriginCaretPosition + 1;
            KeyHandled := True;
          end;
        end;
      vkDelete:
        begin
          if not Model.ReadOnly then
          begin
            if Model.HasSelection then
            begin
              if Shift = [ssShift] then
                Edit.CutToClipboard
              else
                Edit.DeleteSelection;
              DoTyping;
              KeyHandled := True;
            end
            else
            begin
              TmpS := Text;
              if not TmpS.IsEmpty then
              begin
                if IsCtrlOrCmd then
                begin
                  // Delete whole word
                  LCaret := GetNextLexemeBegin(Text, GetOriginCaretPosition);
                  if LCaret < 0 then
                    exit;
                  TmpS := TmpS.Remove(LCaret, GetOriginCaretPosition - LCaret);
                end
                else
                begin
                  LCaret := GetOriginCaretPosition;
                  // Delete single character
                  if (Text.Length > 1) and (GetOriginCaretPosition < Text.Length) and Text.Chars[GetOriginCaretPosition].IsHighSurrogate then
                    TmpS := TmpS.Remove(GetOriginCaretPosition, 2)
                  else
                    TmpS := TmpS.Remove(GetOriginCaretPosition, 1);
                end;
                SetTextInternal(TmpS);
                CaretPosition := LCaret;
                DoTyping;
                KeyHandled := True;
              end;
            end;
          end;
        end;
      vkBack:
        if not Model.ReadOnly then
        begin
          if Model.HasSelection then
          begin
            Edit.DeleteSelection;
            DoTyping;
            KeyHandled := True;
          end
          else
          begin
            TmpS := Text;
            if not TmpS.IsEmpty then
            begin
              if IsCtrlOrCmd then
              begin
                // Delete whole word
                LCaret := GetPrevLexemeBegin(Text, GetOriginCaretPosition);
                if LCaret < 0 then
                  exit;
                TmpS := TmpS.Remove(LCaret, GetOriginCaretPosition - LCaret);
              end
              else
              begin
                LCaret := GetOriginCaretPosition - 1;
                if TmpS.Chars[LCaret].IsLowSurrogate then
                begin
                  Dec(LCaret);
                  TmpS := TmpS.Remove(LCaret, 2)
                end
                else
                  TmpS := TmpS.Remove(LCaret, 1);
              end;
              SetTextInternal(TmpS);
              CaretPosition := LCaret;
              DoTyping;
              KeyHandled := True;
            end;
          end;
        end;
      vkInsert:
        if Shift = [ssShift] then
        begin
          Edit.PasteFromClipboard;
          DoTyping;
          KeyHandled := True;
        end
        else if IsCtrlOrCmd then
        begin
          Edit.CopyToClipboard;
          KeyHandled := True;
        end;
    end;

    if (KeyChar <> #0) and not Model.FilterChar.IsEmpty and not Model.FilterChar.Contains(KeyChar) then
      KeyChar := #0;

    if Key in [vkEnd, vkHome, vkLeft, vkRight] then
    begin
      Model.DisableNotify;
      try
        if ssShift in Shift then
        begin
          Model.SelStart := GetOriginCaretPosition;
          Model.SelLength := Model.SelLength - (GetOriginCaretPosition - OldCaretPosition);
        end
        else
          Model.SelLength := 0;
        RepaintEdit;
        UpdateSelectionPointPositions;
        KeyHandled := True;
      finally
        Model.EnableNotify;
      end;
    end;

    if (Ord(KeyChar) >= 32) and not Model.ReadOnly then
    begin
      FCharsBuffer := FCharsBuffer + KeyChar;
      if not KeyChar.IsHighSurrogate then
      begin
        Model.DisableNotify;
        try
          Model.Typing := True;
        finally
          Model.EnableNotify;
        end;
        InsertText(FCharsBuffer);
        FCharsBuffer := string.Empty;
        DoTyping;
      end;
      KeyHandled := True;
    end;
    if ResourceControl <> nil then
      ResourceControl.UpdateEffects;
  finally
    if KeyHandled then
    begin
      Key := 0;
      KeyChar := #0;
    end;
  end;
end;

procedure TStyledMDEdit.LongTap(const X, Y: Single);
begin
  if SelectionMode <> TSelectionMode.TextSelection then
  begin
    SelectionMode := TSelectionMode.CursorPosChanging;
    if FLoupeService <> nil then
    begin
      FLoupeService.SetLoupeMode(TLoupeMode.Circle);
      ShowLoupe;
      SetLoupePosition(X, Y);
    end;
  end;
end;

procedure TStyledMDEdit.MMCheckSpellingChanged(var AMessage: TDispatchMessageWithValue<Boolean>);
var
  i: Integer;
begin
  if Model.CheckSpelling then
  begin
    if not TPlatformServices.Current.SupportsPlatformService(IFMXSpellCheckerService, IInterface(FSpellService)) then
      FSpellService := nil;
    FUpdateSpelling := not Text.IsEmpty;
  end
  else
  begin
    for i := 0 to FSpellMenuItems.Count - 1 do
      FSpellMenuItems[i].Parent := nil;
    FSpellMenuItems.Clear;
    FSpellService := nil;
    SetLength(FSpellingRegions, 0);
    FUpdateSpelling := False;
    FSpellHightlightRect := TRectF.Empty;
  end;
end;

procedure TStyledMDEdit.MMImeModeChanged(var AMessage: TDispatchMessage);
begin
  if Model.Password then
    FTextService.SetImeMode(TImeMode.imDisable)
  else
    FTextService.SetImeMode(Model.ImeMode);
end;

procedure TStyledMDEdit.MMMaxLengthChanged(var Message: TDispatchMessage);
begin
  if FTextService <> nil then
    FTextService.MaxLength := Model.MaxLength;
end;

procedure TStyledMDEdit.MMPasswordChanged(var AMessage: TDispatchMessage);
begin
  if Model.Password then
    FTextService.SetImeMode(TImeMode.imDisable)
  else
    FTextService.SetImeMode(Model.ImeMode);
  UpdateCaretPosition;
  RepaintEdit;
end;

procedure TStyledMDEdit.MMPromptTextChanged(var Message: TDispatchMessage);
begin
  if FPromptText <> nil then
  begin
    if Supports(FPromptText, ICaption) then
    begin
      FNeedBuildOutlinedPathData:=True;
      FPromptText.Text := Model.TextPrompt;
    end;
  end;
end;

procedure TStyledMDEdit.MMCharCaseChanged(var Message: TDispatchMessage);
begin
  if FTextService <> nil then
    FTextService.CharCase := Model.CharCase;
end;

procedure TStyledMDEdit.MMFilterCharChanged(var Message: TDispatchMessage);
begin
  if FTextService <> nil then
    FTextService.FilterChar := Model.FilterChar;
end;

procedure TStyledMDEdit.MMSelLenghtChanged(var AMessage: TDispatchMessageWithValue<Integer>);
begin
  UpdateSelectionPointPositions;
  RepaintEdit;
end;

procedure TStyledMDEdit.MMSelStartChanged(var AMessage: TDispatchMessageWithValue<Integer>);
begin
  UpdateSelectionPointPositions;
  RepaintEdit;
end;

procedure TStyledMDEdit.MMTextChanged(var AMessage: TDispatchMessageWithValue<string>);
var
  LText: string;
begin
  LText := AMessage.Value;
  if FTextService.CombinedText <> LText then
  begin
    FTextLayout.Text := LText;
    FTextService.Text := LText;
    UpdateFirstVisibleChar;
    if FTextService.CaretPosition.X > LText.Length then
      SetCaretPosition(LText.Length)
    else
      UpdateCaretPosition;
    StylesData[PromptVisibilityStyleDataName] := LText.IsEmpty;
    RepaintEdit;
  end;
end;

procedure TStyledMDEdit.MMTextChanging(var AMessage: TDispatchMessageWithValue<string>);
begin
  DoChangeTracking;
end;

procedure TStyledMDEdit.MMTextSettingsChanged(var AMessage: TDispatchMessage);
begin
  if [csLoading, csDesigning] * ComponentState = [] then
  begin
    if Model.TextSettingsInfo.ResultingTextSettings.IsAdjustChanged then
    begin
      UpdateTextHeight;
      if not FDisableAlign then
        RealignContent;
    end;
    RepaintEdit;
  end;
  UpdateTextLayout;
end;

procedure TStyledMDEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  NewPosition: Integer;
begin
  inherited;
  Model.DisableNotify;
  try
    if (Button = TMouseButton.mbLeft) and Model.InputSupport then
    begin
      NewPosition := GetCoordinatePosition(X);
      if ssShift in Shift then
        Model.SelLength := NewPosition - Model.SelStart
      else
        Model.SelLength := 0;
      CaretPosition := NewPosition;
      Model.SelStart := NewPosition;
      if ssDouble in Shift then
      begin
        SelectionMode := TSelectionMode.None;
        Edit.SelectWord;
      end
      else
{$IF not Defined(IOS) and not Defined(ANDROID)}
        BeginSelection;
{$ENDIF}
    end
    else
      UpdateCaretPosition;
  finally
    Model.EnableNotify;
  end;
end;

procedure TStyledMDEdit.MouseMove(Shift: TShiftState; X, Y: Single);

  function DefineNewCarretPosition(const AX: Single): Integer;
  begin
    Result := GetCoordinatePosition(AX);
    if AX > ContentRect.Right then
      Inc(Result);
  end;

var
  OldCaretPosition: Integer;
begin
  inherited;
  { Changing cursor position }
  if SelectionMode = TSelectionMode.CursorPosChanging then
  begin
    if FLoupeService <> nil then
    begin
      FLoupeService.SetLoupeMode(TLoupeMode.Circle);
      SetLoupePosition(X, Y);
      ShowLoupe;
    end;
    CaretPosition := DefineNewCarretPosition(X);
  end;
  { Changing selection bounds }
  if SelectionMode = TSelectionMode.TextSelection then
  begin
    OldCaretPosition := GetOriginCaretPosition;
    Model.DisableNotify;
    try
{$IFNDEF ANDROID}
      CaretPosition := DefineNewCarretPosition(X);
      Model.SelStart := GetOriginCaretPosition;
{$ELSE}
      if Model.SelLength = 0 then
        Model.SelStart := OldCaretPosition;
      Model.SelStart := DefineNewCarretPosition(X);
{$ENDIF}
      Model.SelLength := Model.SelLength - (Model.SelStart - OldCaretPosition);
    finally
      Model.EnableNotify;
    end;
  end;
end;

procedure TStyledMDEdit.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  inherited;
  HideLoupe;
  if SelectionMode = TSelectionMode.CursorPosChanging then
    FTextService.EndSelection;
  SelectionMode := TSelectionMode.None;
  UpdateSelectionPointPositions;
end;

procedure TStyledMDEdit.PMGetTextContentRect(var Message: TDispatchMessageWithValue<TRectF>);
begin
  Message.Value := ContentRect;
end;

procedure TStyledMDEdit.PMInit(var Message: TDispatchMessage);
begin
  if FTextService <> nil then
  begin
    FTextService.MaxLength := Model.MaxLength;
    FTextLayout.Text := Model.Text;
    if FTextService.CaretPosition.X > Model.Text.Length then
      SetCaretPosition(Text.Length);
  end;
  StylesData[PromptVisibilityStyleDataName] := Model.Text.IsEmpty;
  RepaintEdit;

  Edit.ButtonsContent.BringToFront;
  RealignButtonsContainer;
  UpdateTextLayout;
end;

procedure TStyledMDEdit.PMSetAdjustType(var AMessage: TDispatchMessageWithValue<TAdjustType>);
begin
  SetAdjustType(TAdjustType.None);
end;

procedure TStyledMDEdit.MMEditButtonsChanged(var Message: TDispatchMessage);
begin
  RealignButtonsContainer;
end;

procedure TStyledMDEdit.RealignButtonsContainer;
var
  i: Integer;
  TotalWidth: Single;
  R: TRectF;
  PositionTmp: TPointF;
  EditControl: IEditControl;
begin
  if FButtonsLayout = nil then
    exit;

  TotalWidth := 0;
  for i := 0 to Edit.ButtonsContent.ChildrenCount - 1 do
  begin
    if Edit.ButtonsContent.Children[i].GetInterface(IEditControl, EditControl) and EditControl.GetControl.Visible then
      TotalWidth := TotalWidth + EditControl.BoundsRect.Width;
  end;
  FButtonsLayout.Width := TotalWidth;
  FButtonsLayout.Height := Height;
  PositionTmp := FButtonsLayout.LocalToAbsolute(TPointF.Zero);
  R := FButtonsLayout.AbsoluteRect;
  Edit.ButtonsContent.SetBounds(R.Left, R.Top, R.Width, R.Height);
  Edit.ButtonsContent.Position.Point := AbsoluteToLocal(PositionTmp);
end;

procedure TStyledMDEdit.RealignContent;
var
  XBtn: Single;
  LBtn: Single;
  Size: TSizeF;
  Pos: TPointF;
  OldDisableAlign: Boolean;
begin
  OldDisableAlign := FDisableAlign;
  try
    FDisableAlign := True;
    XBtn := 0;
    LBtn := 0;

    RealignButtonsContainer;

    if FContent <> nil then
    begin
      if FLeftLayout <> nil then
        LBtn := FLeftLayout.Width;
      if FButtonsLayout <> nil then
        XBtn := FButtonsLayout.Width;

      if FTextHeight <= 0 then
        UpdateTextHeight;
      Pos.X := Max(FContent.Margins.Left, 0);
      Pos.Y := Max(FContent.Margins.Top, 0);
      Size.cx := Max(Width - XBtn - LBtn - FContent.Margins.Right - Pos.X, 0);
      Size.cy := Max(Height - FContent.Margins.Bottom - Pos.Y, 0);
      FLineHeight := Max(Min(Size.cy, FTextHeight + Max(1, Round(FTextHeight / 10))), 0);
      case Model.TextSettingsInfo.ResultingTextSettings.VertAlign of
        TTextAlign.Center:
          FLineTop := Max((Size.cy - FLineHeight) / 2, 0) + Pos.Y;
        TTextAlign.Leading:
          FLineTop := Pos.Y;
        TTextAlign.Trailing:
          FLineTop := Max(Size.cy - FLineHeight, 0) + Pos.Y;
      end;
      FContent.SetBounds(Pos.X + LBtn, Pos.Y, Size.cx, Size.cy);
      if FPromptText <> nil then
      begin
        if (ParentControl.IsFocused) then
        begin
          FPromptText.TextSettings.Font.Size := 16;
          FPromptText.RecalcSize;
          FPromptText.Position.Y := (FPromptText.Height / 2) * -1;
        end;
        FPromptText.Visible := True;
      end;
      FNeedBuildOutlinedPathData := True;

      FTextLayout.TopLeft := ContentRect.TopLeft;

      UpdateLayoutSize;
    end;
  finally
    FDisableAlign := OldDisableAlign;
  end;
end;

procedure TStyledMDEdit.RepaintEdit;
begin

  if not Model.Text.IsEmpty then
  begin

    if FPromptText <> nil then
    begin
      FPromptText.Visible := True;
      FPromptText.TextSettings.Font.Size := 16;
      FPromptText.RecalcSize;
      FPromptText.Position.Y := (FPromptText.Height / 2) * -1;
    end;
    FNeedBuildOutlinedPathData := True;
  end
  else
  begin
    if FPromptText <> nil then
    begin
      FPromptText.Visible := True;
      if not FFocused then
      begin

        FPromptText.TextSettings.Font.Size := 20;
        FPromptText.RecalcSize;
        FPromptText.Position.Y := (FContent.Height / 2) - (FPromptText.Height / 2);
      end;

    end;
    FNeedBuildOutlinedPathData := True;
  end;

  if FContent <> nil then
    FContent.Repaint;
end;

procedure TStyledMDEdit.Resize;
begin
  inherited;
  UpdateSpelling;
  if Assigned(FPromptFloatAnimation) then
  begin
    FPromptFloatAnimation.StartValue := (FContent.Height / 2) - (FPromptText.Height / 2);
    FPromptFloatAnimation.StopValue := (FPromptText.Height / 2) * -1;
  end;

end;

procedure TStyledMDEdit.SetLoupePosition(const ASelectionPointType: TSelectionPointType);
var
  SelectionRect: TRectF;
  ZoomCenter: TPointF;
  LoupePos: TPointF;
begin
  SelectionRect := GetSelRect;
  if FLoupeService <> nil then
  begin
    case ASelectionPointType of
      TSelectionPointType.Left:
        begin
          ZoomCenter := TPointF.Create(SelectionRect.Left, SelectionRect.Top + SelectionRect.Height / 2);
          LoupePos := SelectionRect.TopLeft + TPointF.Create(-FLoupeService.GetWidth / 2, -FLoupeService.GetHeight) + TPointF.Create(0, -LOUPE_OFFSET);
        end;
      TSelectionPointType.Right:
        begin
          ZoomCenter := TPointF.Create(SelectionRect.Right, SelectionRect.Top + SelectionRect.Height / 2);
          LoupePos := TPointF.Create(SelectionRect.Right, SelectionRect.Top) + TPointF.Create(-FLoupeService.GetWidth / 2, -FLoupeService.GetHeight) +
            TPointF.Create(0, -LOUPE_OFFSET);
        end;
    end;
    ZoomCenter := LocalToAbsolute(ZoomCenter);
    LoupePos := LocalToAbsolute(LoupePos);

    FLoupeService.SetPosition(LoupePos);
    FLoupeService.SetZoomRegionCenter(ZoomCenter);
  end;
end;

procedure TStyledMDEdit.SetCaretPosition(const Value: Integer);
var
  P: TPoint;
begin
  if FTextService <> nil then
  begin
    P.X := 0;
    P.Y := 0;
    if Value < 0 then
      P.X := 0
    else if Value > Text.Length then
      P.X := Text.Length
    else
      P.X := Value;
    FTextService.CaretPosition := P;

    UpdateFirstVisibleChar;

    Model.DisableNotify;
    try
      Model.CaretPosition := P.X;
      if Model.SelLength <= 0 then
        Model.SelStart := Value;
    finally
      Model.EnableNotify;
    end;

    UpdateSelectionPointPositions;
    RepaintEdit;

    UpdateCaretPosition;
  end;
end;

procedure TStyledMDEdit.SetLoupePosition(const X, Y: Single);
var
  LoupePos: TPointF;
  ZoomPos: TPointF;
begin
  if FLoupeService <> nil then
  begin
    LoupePos := TPointF.Create(X - FLoupeService.GetWidth / 2, Y - FLoupeService.GetHeight);
    LoupePos := LocalToAbsolute(LoupePos);
    ZoomPos := LocalToAbsolute(TPointF.Create(X, Y));
    FLoupeService.SetPosition(LoupePos);
    FLoupeService.SetZoomRegionCenter(ZoomPos);
    ShowLoupe;
  end;
end;

procedure TStyledMDEdit.SetSelectionMode(const AValue: TSelectionMode);
begin
  FSelectionMode := AValue;
  if FLoupeService <> nil then
    case AValue of
      TSelectionMode.None:
        ;
      TSelectionMode.TextSelection:
        FLoupeService.SetLoupeMode(TLoupeMode.Rectangle);
      TSelectionMode.CursorPosChanging:
        FLoupeService.SetLoupeMode(TLoupeMode.Circle);
    end;
end;

procedure TStyledMDEdit.SetText(const Value: string);
begin
  if FTextService.CombinedText <> Value then
  begin
    SetTextInternal(Value);
    SetCaretPosition(Min(Value.Length, FTextService.CaretPosition.X));
    Model.DisableNotify;
    try
      Model.SelStart := 0;
      Model.SelLength := 0;
    finally
      Model.EnableNotify;
    end;
    Model.Change;
    RepaintEdit;
  end;
end;

procedure TStyledMDEdit.SetTextInternal(const Value: string);
begin
{$IFDEF ANDROID}
  FTextService.Text := Value;
{$ELSE}
  FTextService.Text := Model.Text;
{$ENDIF}
  Model.Text := Value;
  FTextLayout.Text := Model.Text;
  if FPromptText <> nil then
    FPromptText.Visible := True
  else
    UpdateCaretPosition;
end;

procedure TStyledMDEdit.ShowCaret;
begin
  Model.Caret.Show;
end;

function TStyledMDEdit.ShowContextMenu(const ScreenPosition: TPointF): Boolean;

  function ShowDefaultMenu: Boolean;
  begin
    Result := False;
    if EditPopupMenu <> nil then
      try
        if Root <> nil then
          EditPopupMenu.Parent := Root.GetObject;
        Result := True;
        UpdatePopupMenuItems;
        if Model.CheckSpelling and (FSpellService <> nil) and (Length(FSpellingRegions) > 0) then
          UpdateSpellPopupMenu(ScreenToLocal(ScreenPosition));
        EditPopupMenu.PopupComponent := SElf;
        EditPopupMenu.Popup(Round(ScreenPosition.X), Round(ScreenPosition.Y));
      finally
        EditPopupMenu.Parent := nil;
      end;
  end;

  function ShowUsersPopupMenu: Boolean;
  begin
    Result := IControl(PresentedControl).ShowContextMenu(ScreenPosition)
  end;

begin
  Result := False;
  if not(csDesigning in ComponentState) then
    if Supports(PresentedControl, IControl) and (PresentedControl.PopupMenu <> nil) then
      Result := ShowUsersPopupMenu
    else
      Result := ShowDefaultMenu;
end;

procedure TStyledMDEdit.ShowLoupe;
begin
  if FLoupeService <> nil then
  begin
    FLoupeService.SetLoupeScale(TCustomMagnifierGlass.DefaultLoupeScale);
    FLoupeService.ShowFor(PresentedControl);
  end;
end;

procedure TStyledMDEdit.Spell(const AWord: string);
var
  BP, EP: Integer;
begin
  if not Text.IsEmpty and (GetOriginCaretPosition >= 0) then
    if FMX.Text.FindWordBound(Text, GetOriginCaretPosition, BP, EP) then
    begin
      Text := Text.Remove(BP, EP - BP + 1).Insert(BP, AWord);
      FUpdateSpelling := True;
      HideHighlightSpell;
      UpdateSpelling;
      CaretPosition := BP + AWord.Length;
    end;
end;

procedure TStyledMDEdit.SpellFixContextMenuHandler(Sender: TObject);
var
  LPos: Integer;
  BP, EP: Integer;
begin
  if Sender is TMenuItem then
  begin
    LPos := TMenuItem(Sender).Tag;
    if (LPos > -1) and FMX.Text.FindWordBound(Text, LPos, BP, EP) then
      Text := Text.Substring(0, BP) + TMenuItem(Sender).Text + Text.Substring(EP + 1);
  end;
end;

procedure TStyledMDEdit.StartIMEInput;
begin
  FTextService.CaretPosition := Point(GetOriginCaretPosition, 0);
end;

function TStyledMDEdit.TextWidth(const AStart, ALength: Integer): Single;
var
  Rgn: TRegion;
  S, L, i: Integer;
begin
  if Model.Password then
    Result := GetPasswordCharWidth * ALength
  else if AStart < FTextLayout.Text.Length then
  begin
    S := AStart;
    L := ALength;
    if FTextLayout.Text.Chars[S].IsLowSurrogate then
    begin
      Inc(S);
      Dec(L);
    end;
    Rgn := FTextLayout.RegionForRange(TTextRange.Create(S, L));
    Result := 0;
    for i := Low(Rgn) to High(Rgn) do
      Result := Result + Rgn[i].Width;
  end
  else if AStart = FTextLayout.Text.Length then
    Result := FTextLayout.TextWidth
  else
    Result := 0;
end;

function LinkObserversValueModified(const AObservers: TObservers): Boolean;
begin
  Result := True;
  if AObservers.IsObserving(TObserverMapping.EditLinkID) then
  begin
    Result := TLinkObservers.EditLinkEdit(AObservers);
    if Result then
      TLinkObservers.EditLinkModified(AObservers);
  end;
  if Result and AObservers.IsObserving(TObserverMapping.ControlValueID) then
    TLinkObservers.ControlValueModified(AObservers);
end;

procedure TStyledMDEdit.IMEStateUpdated;
var
  CombinedText: string;
begin
  CombinedText := FTextService.CombinedText;
  FTextLayout.Text := CombinedText;
  SetCaretPosition(GetOriginCaretPosition);
  Model.SetTextWithoutValidation(CombinedText);
  if FPrompt <> nil then
    FPrompt.Visible := CombinedText.IsEmpty;
  if Model.SelLength > 0 then
  begin
    Model.DisableNotify;
    try
      Model.SelLength := 0;
    finally
      Model.EnableNotify;
    end;
    UpdateSelectionPointPositions;
  end;
  LinkObserversValueModified(SElf.Observers);
  DoChangeTracking;
  DoTyping;
end;

procedure TStyledMDEdit.UpdateCaretPosition;
var
  CaretHeight: Single;
  Pos: TPointF;
begin
  if (ParentControl <> nil) and ParentControl.IsFocused then
  begin
{$IFNDEF IOS}
    CaretHeight := Trunc(LineHeight);
    Pos.Y := Trunc(LineTop);
{$ELSE}
    CaretHeight := Trunc(ContentRect.Height);
    Pos.Y := Trunc(ContentRect.Top);
{$ENDIF}
    if FTextService.HasMarkedText then
      Pos.X := GetCharX(FTextService.TargetClausePosition.X)
    else
      Pos.X := GetCharX(FTextService.CaretPosition.X);
    Pos.X := Max(0, Min(Pos.X, ContentRect.Right - Model.Caret.Size.cx + 1));
    Model.Caret.BeginUpdate;
    try
      Model.Caret.Pos := Pos;
      Model.Caret.Size := TPointF.Create(Min(Model.Caret.Size.cx, ContentRect.Width), CaretHeight);
    finally
      Model.Caret.EndUpdate;
    end;
  end;
end;

procedure TStyledMDEdit.UpdateFirstVisibleChar;
var
  MarkedPosition: Integer;
  LEditRect: TRectF;
  TempStr: string;
begin
  if FContent <> nil then
  begin
    FTextLayout.Text := FTextService.CombinedText;
    MarkedPosition := FTextService.TargetClausePosition.X;
    if FFirstVisibleChar >= (MarkedPosition + 1) then
    begin
      FFirstVisibleChar := MarkedPosition;
      if FFirstVisibleChar < 1 then
        FFirstVisibleChar := 1;
    end
    else
    begin
      LEditRect := FContent.Padding.PaddingRect(ContentRect);
      if FTextLayout.TextWidth > LEditRect.Width then
      begin
        // Text is longer than content width
        TempStr := FTextService.CombinedText;
        if MarkedPosition < (FFirstVisibleChar - 1) then
          // New position is lefter than left visual character
          FFirstVisibleChar := MarkedPosition
        else
          // Looking for the shift when caret position will be visible
          while (TextWidth(FFirstVisibleChar - 1, MarkedPosition - FFirstVisibleChar + 1) > LEditRect.Width) and (FFirstVisibleChar < TempStr.Length) do
            Inc(FFirstVisibleChar);
      end
      else
        // Text fits content
        FFirstVisibleChar := 1;
    end;
    if (FFirstVisibleChar > 0) and (FTextLayout.Text.Length > 0) then
    begin
      if FTextLayout.Text.Chars[FFirstVisibleChar - 1].IsLowSurrogate then
        Inc(FFirstVisibleChar);
      FInvisibleTextWidth := TextWidth(0, FFirstVisibleChar - 1);
    end;
  end;
end;

procedure TStyledMDEdit.UpdateLayoutSize;
var
  LSize: TPointF;
begin
  LSize := TTextLayout.MaxLayoutSize;
  if Model.TextSettingsInfo.ResultingTextSettings.HorzAlign <> TTextAlign.Leading then
    LSize.X := ContentRect.Width;
  if Model.TextSettingsInfo.ResultingTextSettings.VertAlign <> TTextAlign.Leading then
    LSize.Y := ContentRect.Height;
  FTextLayout.MaxSize := LSize;
end;

procedure TStyledMDEdit.UpdatePopupMenuItems;
var
  SelTextIsValid: Boolean;

  procedure SetParam(AParamName: string; AValue: Boolean);
  var
    LMenuItem: TMenuItem;
  begin
    LMenuItem := FindContextMenuItem(AParamName);
    if LMenuItem <> nil then
      LMenuItem.Enabled := AValue;
  end;

begin
  SelTextIsValid := not SelText.IsEmpty;
  SetParam(CutStyleName, SelTextIsValid and not Model.ReadOnly and Model.InputSupport and not Model.Password);
  SetParam(CopyStyleName, SelTextIsValid and not Model.Password);
  if FClipboardSvc <> nil then
    SetParam(PasteStyleName, (not FClipboardSvc.GetClipboard.IsEmpty) and (not Model.ReadOnly) and Model.InputSupport)
  else
    SetParam(PasteStyleName, False);
  SetParam(DeleteStyleName, SelTextIsValid and not Model.ReadOnly and Model.InputSupport);
  SetParam(SelectAllStyleName, SelText <> Text);
end;

procedure TStyledMDEdit.UpdateSelectionPointPositions;
var
  R: TRectF;
  IsParentFocused: Boolean;
begin
  IsParentFocused := (ParentControl <> nil) and ParentControl.IsFocused;

  Model.Caret.TemporarilyHidden := Model.HasSelection and IsParentFocused;
  if HaveSelectionPickers then
  begin
    FLeftSelPt.Visible := (Model.SelLength > 0) and IsParentFocused and (Model.SelStart + 1 >= FFirstVisibleChar);
    FRightSelPt.Visible := (Model.SelLength > 0) and IsParentFocused and (GetCharX(Model.SelStart + Model.SelLength) < ContentRect.Right);

    R := GetSelRect;

    FLeftSelPt.Position.X := R.Left;
{$IFDEF ANDROID}
    FLeftSelPt.Position.Y := R.Bottom + 2 * FLeftSelPt.GripSize;
{$ELSE}
    FLeftSelPt.Position.Y := R.Top - 2 * FLeftSelPt.GripSize;
{$ENDIF}
    FRightSelPt.Position.X := R.Right;
    FRightSelPt.Position.Y := R.Bottom + 2 * FLeftSelPt.GripSize;
  end;
end;

procedure TStyledMDEdit.UpdateSpelling;
begin
  if Model.CheckSpelling then
  begin
    FUpdateSpelling := True;
    SetLength(FSpellingRegions, 0);
  end;
end;

procedure TStyledMDEdit.UpdateSpellPopupMenu(const APoint: TPointF);
var
  i, J, BP, EP: Integer;
  LPos: Integer;
  Spells: TArray<string>;
  LMenuItem: TMenuItem;
begin
  for i := 0 to FSpellMenuItems.Count - 1 do
    FSpellMenuItems[i].Parent := nil;
  FSpellMenuItems.Clear;

  for i := Low(FSpellingRegions) to High(FSpellingRegions) do
    if FSpellingRegions[i].Contains(APoint) then
    begin
      LPos := FTextLayout.PositionAtPoint(APoint);
      if (LPos > -1) and FMX.Text.FindWordBound(Text, LPos, BP, EP) then
      begin
        Spells := FSpellService.CheckSpelling(Text.Substring(BP, EP - BP + 1));
        if Length(Spells) > 0 then
        begin
          for J := Low(Spells) to High(Spells) do
          begin
            LMenuItem := TMenuItem.Create(EditPopupMenu);
            LMenuItem.Text := Spells[J];
            LMenuItem.Font.Style := LMenuItem.Font.Style + [TFontStyle.fsBold];
            LMenuItem.Tag := LPos;
            LMenuItem.OnClick := SpellFixContextMenuHandler;
            EditPopupMenu.InsertObject(FSpellMenuItems.Count, LMenuItem);
            FSpellMenuItems.Add(LMenuItem);
          end;
          LMenuItem := TMenuItem.Create(EditPopupMenu);
          LMenuItem.Text := SMenuSeparator;
          EditPopupMenu.InsertObject(FSpellMenuItems.Count, LMenuItem);
          FSpellMenuItems.Add(LMenuItem);
        end;
      end;
      Break;
    end;
end;

procedure TStyledMDEdit.UpdateTextHeight;
begin
  FTextHeight := 0;
  if (FContent <> nil) and (FContent.Canvas <> nil) then
  begin
    TCanvasManager.MeasureCanvas.Font.Assign(Model.TextSettingsInfo.ResultingTextSettings.Font);
    FTextHeight := TCanvasManager.MeasureCanvas.TextHeight('Lb|y');
    // do not localize
  end;
end;

procedure TStyledMDEdit.UpdatePromptTextSettings;
var
  PromptTextSettings: ITextSettings;
begin
  if Supports(FPrompt, ITextSettings, PromptTextSettings) then
  begin
    PromptTextSettings.StyledSettings := [];
    PromptTextSettings.TextSettings.Assign(Model.TextSettingsInfo.ResultingTextSettings);
  end;
end;

procedure TStyledMDEdit.UpdateTextLayout;
begin
  UpdatePromptTextSettings;
  FTextLayout.BeginUpdate;
  try
    FTextLayout.HorizontalAlign := Model.TextSettingsInfo.ResultingTextSettings.HorzAlign;
    FTextLayout.VerticalAlign := Model.TextSettingsInfo.ResultingTextSettings.VertAlign;
    FTextLayout.Font := Model.TextSettingsInfo.ResultingTextSettings.Font;
    FTextLayout.TopLeft := ContentRect.TopLeft;
    UpdateLayoutSize;
  finally
    FTextLayout.EndUpdate;
  end;
  UpdateTextHeight;
end;

procedure RegisterAliases;
begin
  AddEnumElementAliases(TypeInfo(TSelectionMode), ['smNone', 'smTextSelection', 'smCursorPosChanging']);
  AddEnumElementAliases(TypeInfo(TSelectionPointType), ['sptLeft', 'sptRight']);
end;

procedure UnregisterAliases;
begin
  RemoveEnumElementAliases(TypeInfo(TSelectionMode));
  RemoveEnumElementAliases(TypeInfo(TSelectionPointType));
end;

initialization

RegisterAliases;
TPresentationProxyFactory.Current.Register(TMDEdit, TControlType.Styled, TStyledPresentationProxy<TStyledMDEdit>);

finalization

TPresentationProxyFactory.Current.Unregister(TMDEdit, TControlType.Styled, TStyledPresentationProxy<TStyledMDEdit>);
UnregisterAliases;

end.
