unit MD.TextFields;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.Controls.Presentation, FMX.Text, FMX.Graphics, MD.ColorPalette,
  FMX.Controls.Model, FMX.Platform, System.Rtti, System.Types;

type

  TCustomEditModel = class(TDataModel)

  end;

  TContentEdit = class(TContent)

  end;

  TMDCustomTextFields = class(TPresentedControl, ITextActions, IVirtualKeyboardControl, IItemsContainer, ITextSettings, IReadOnly)
    FButtonsContent: TContentEdit;
    function GetOriginCaretPosition: Integer;
    function GetSelText: string;
    procedure SetSelLength(const Value: Integer);
    function GetSelLength: Integer;
    procedure SetSelStart(const Value: Integer);
    function GetSelStart: Integer;
    procedure SetCaretPosition(const Value: Integer);
    function GetCaretPosition: Integer;
    procedure SetCaret(const Value: TCaret);
    function GetCaret: TCaret;
    procedure SetPromptText(const Prompt: string);
    function GetPromptText: string;
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetOnChange: TNotifyEvent;
    procedure SetOnChangeTracking(const Value: TNotifyEvent);
    function GetOnChangeTracking: TNotifyEvent;
    procedure SetMaxLength(const Value: Integer);
    function GetMaxLength: Integer;
    procedure SetPassword(const Value: Boolean);
    function GetPassword: Boolean;
    procedure SetOnTyping(const Value: TNotifyEvent);
    function GetOnTyping: TNotifyEvent;
    procedure SetKillFocusByReturn(const Value: Boolean);
    function GetKillFocusByReturn: Boolean;
    procedure SetCheckSpelling(const Value: Boolean);
    function GetCheckSpelling: Boolean;
    function GetSelectionFill: TBrush;
    { ITextSettings }
    function GetDefaultTextSettings: TTextSettings;
    function GetTextSettings: TTextSettings;
    function GetResultingTextSettings: TTextSettings;
    function GetStyledSettings: TStyledSettings;
    procedure SetTextAlign(const Value: TTextAlign);
    function GetTextAlign: TTextAlign;
    procedure SetVertTextAlign(const Value: TTextAlign);
    function GetVertTextAlign: TTextAlign;
    procedure SetFont(const Value: TFont);
    function GetFont: TFont;
    procedure SetFontColor(const Value: TMaterialColor);
    function GetFontColor: TMaterialColor;
    function GetTyping: Boolean;
    procedure SetTyping(const Value: Boolean);
    function GetFilterChar: string;
    procedure SetFilterChar(const Value: string);
    function GetInputSupport: Boolean;
    function GetModel: TCustomEditModel; overload;
    function GetTextContentRect: TRectF;
    function GetOnValidate: TValidateTextEvent;
    function GetOnValidating: TValidateTextEvent;
    procedure SetOnValidate(const Value: TValidateTextEvent);
    procedure SetOnValidating(const Value: TValidateTextEvent);
    procedure ReadReadOnly(Reader: TReader);
    { IReadOnly }
    procedure SetReadOnly(const Value: Boolean);
    function GetReadOnly: Boolean;
  protected
    FClipboardSvc: IFMXClipboardService;
    FSavedReadOnly: Boolean;
    function GetData: TValue; override;
    procedure SetData(const Value: TValue); override;
    procedure Loaded; override;
    function GetText: string; virtual;
    procedure SetText(const Value: string); virtual;
    procedure DoAddObject(const AObject: TFmxObject); override;
    procedure DoInsertObject(Index: Integer; const AObject: TFmxObject); override;
    procedure DoRemoveObject(const AObject: TFmxObject); override;
    function GetImeMode: TImeMode; virtual;
    procedure SetImeMode(const Value: TImeMode); virtual;
    procedure SetInputSupport(const Value: Boolean); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    function GetDefaultSize: TSizeF; override;
    procedure Resize; override;
    procedure RealignButtonsContainer; virtual;
    { Live Binding }
    function CanObserve(const ID: Integer): Boolean; override;
    procedure ObserverAdded(const ID: Integer; const Observer: IObserver); override;
    procedure ObserverToggle(const AObserver: IObserver; const Value: Boolean);
    { ITextSettings }
    procedure SetTextSettings(const Value: TTextSettings); virtual;
    procedure SetStyledSettings(const Value: TStyledSettings); virtual;
    function StyledSettingsStored: Boolean; virtual;
    { IVirtualKeyboardControl }
    procedure SetKeyboardType(Value: TVirtualKeyboardType);
    function GetKeyboardType: TVirtualKeyboardType;
    procedure SetReturnKeyType(Value: TReturnKeyType);
    function GetReturnKeyType: TReturnKeyType;
    function IVirtualKeyboardControl.IsPassword = GetPassword;
    property InputSupport: Boolean read GetInputSupport write SetInputSupport;
    { IItemsContainer }
    function GetItemsCount: Integer;
    function GetItem(const AIndex: Integer): TFmxObject;
    procedure ButtonsChanged; virtual;
  protected
    function DefineModelClass: TDataModelClass; override;
    function DefinePresentationName: string; override;
  public
    property ControlType;
    property Model: TCustomEditModel read GetModel;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { ITextActions }
    procedure DeleteSelection;
    procedure CopyToClipboard;
    procedure CutToClipboard;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure SelectWord;
    procedure ResetSelection;
    procedure GoToTextEnd;
    procedure GoToTextBegin;
    procedure Replace(const AStartPos: Integer; const ALength: Integer; const AStr: string);
    function HasSelection: Boolean;
    property ButtonsContent: TContentEdit read FButtonsContent;
    property Caret: TCaret read GetCaret write SetCaret;
    property CaretPosition: Integer read GetCaretPosition write SetCaretPosition;
    property TextContentRect: TRectF read GetTextContentRect;
    property CheckSpelling: Boolean read GetCheckSpelling write SetCheckSpelling default False;
    property DefaultTextSettings: TTextSettings read GetDefaultTextSettings;
    property Font: TFont read GetFont write SetFont;
    property FontColor: TMaterialColor read GetFontColor write SetFontColor default TMaterialColorRec.Black;
    property FilterChar: string read GetFilterChar write SetFilterChar;
    property ImeMode: TImeMode read GetImeMode write SetImeMode default TImeMode.imDontCare;
    property KeyboardType: TVirtualKeyboardType read GetKeyboardType write SetKeyboardType default TVirtualKeyboardType.Default;
    property KillFocusByReturn: Boolean read GetKillFocusByReturn write SetKillFocusByReturn default False;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property Password: Boolean read GetPassword write SetPassword default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ReturnKeyType: TReturnKeyType read GetReturnKeyType write SetReturnKeyType default TReturnKeyType.Default;
    property ResultingTextSettings: TTextSettings read GetResultingTextSettings;
    property SelectionFill: TBrush read GetSelectionFill;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText;
    property StyledSettings: TStyledSettings read GetStyledSettings write SetStyledSettings stored StyledSettingsStored nodefault;
    property Text: string read GetText write SetText;
    property TextAlign: TTextAlign read GetTextAlign write SetTextAlign default TTextAlign.Leading;
    property TextSettings: TTextSettings read GetTextSettings write SetTextSettings;
    property TextPrompt: string read GetPromptText write SetPromptText;
    property Typing: Boolean read GetTyping write SetTyping default False;
    property VertTextAlign: TTextAlign read GetVertTextAlign write SetVertTextAlign default TTextAlign.Center;
    property OnChange: TNotifyEvent read GetOnChange write SetOnChange;
    property OnChangeTracking: TNotifyEvent read GetOnChangeTracking write SetOnChangeTracking;
    property OnTyping: TNotifyEvent read GetOnTyping write SetOnTyping;
    property OnValidating: TValidateTextEvent read GetOnValidating write SetOnValidating;
    property OnValidate: TValidateTextEvent read GetOnValidate write SetOnValidate;
  published
    property Align;
    property Anchors;
    property StyleLookup;
    property TabOrder;
    property TabStop;
  end;

  TMDTextFields = class(TMDCustomTextFields)

  end;

implementation

{ TMDCustomTextFields }

procedure TMDCustomTextFields.ButtonsChanged;
begin

end;

function TMDCustomTextFields.CanObserve(const ID: Integer): Boolean;
begin

end;

procedure TMDCustomTextFields.CopyToClipboard;
begin

end;

constructor TMDCustomTextFields.Create(AOwner: TComponent);
begin
  inherited;

end;

procedure TMDCustomTextFields.CutToClipboard;
begin

end;

function TMDCustomTextFields.DefineModelClass: TDataModelClass;
begin

end;

function TMDCustomTextFields.DefinePresentationName: string;
begin

end;

procedure TMDCustomTextFields.DefineProperties(Filer: TFiler);
begin
  inherited;

end;

procedure TMDCustomTextFields.DeleteSelection;
begin

end;

destructor TMDCustomTextFields.Destroy;
begin

  inherited;
end;

procedure TMDCustomTextFields.DoAddObject(const AObject: TFmxObject);
begin
  inherited;

end;

procedure TMDCustomTextFields.DoInsertObject(Index: Integer; const AObject: TFmxObject);
begin
  inherited;

end;

procedure TMDCustomTextFields.DoRemoveObject(const AObject: TFmxObject);
begin
  inherited;

end;

function TMDCustomTextFields.GetCaret: TCaret;
begin

end;

function TMDCustomTextFields.GetCaretPosition: Integer;
begin

end;

function TMDCustomTextFields.GetCheckSpelling: Boolean;
begin

end;

function TMDCustomTextFields.GetData: TValue;
begin

end;

function TMDCustomTextFields.GetDefaultSize: TSizeF;
begin

end;

function TMDCustomTextFields.GetDefaultTextSettings: TTextSettings;
begin

end;

function TMDCustomTextFields.GetFilterChar: string;
begin

end;

function TMDCustomTextFields.GetFont: TFont;
begin

end;

function TMDCustomTextFields.GetFontColor: TMaterialColor;
begin

end;

function TMDCustomTextFields.GetImeMode: TImeMode;
begin

end;

function TMDCustomTextFields.GetInputSupport: Boolean;
begin

end;

function TMDCustomTextFields.GetItem(const AIndex: Integer): TFmxObject;
begin

end;

function TMDCustomTextFields.GetItemsCount: Integer;
begin

end;

function TMDCustomTextFields.GetKeyboardType: TVirtualKeyboardType;
begin

end;

function TMDCustomTextFields.GetKillFocusByReturn: Boolean;
begin

end;

function TMDCustomTextFields.GetMaxLength: Integer;
begin

end;

function TMDCustomTextFields.GetModel: TCustomEditModel;
begin

end;

function TMDCustomTextFields.GetOnChange: TNotifyEvent;
begin

end;

function TMDCustomTextFields.GetOnChangeTracking: TNotifyEvent;
begin

end;

function TMDCustomTextFields.GetOnTyping: TNotifyEvent;
begin

end;

function TMDCustomTextFields.GetOnValidate: TValidateTextEvent;
begin

end;

function TMDCustomTextFields.GetOnValidating: TValidateTextEvent;
begin

end;

function TMDCustomTextFields.GetOriginCaretPosition: Integer;
begin

end;

function TMDCustomTextFields.GetPassword: Boolean;
begin

end;

function TMDCustomTextFields.GetPromptText: string;
begin

end;

function TMDCustomTextFields.GetReadOnly: Boolean;
begin

end;

function TMDCustomTextFields.GetResultingTextSettings: TTextSettings;
begin

end;

function TMDCustomTextFields.GetReturnKeyType: TReturnKeyType;
begin

end;

function TMDCustomTextFields.GetSelectionFill: TBrush;
begin

end;

function TMDCustomTextFields.GetSelLength: Integer;
begin

end;

function TMDCustomTextFields.GetSelStart: Integer;
begin

end;

function TMDCustomTextFields.GetSelText: string;
begin

end;

function TMDCustomTextFields.GetStyledSettings: TStyledSettings;
begin

end;

function TMDCustomTextFields.GetText: string;
begin

end;

function TMDCustomTextFields.GetTextAlign: TTextAlign;
begin

end;

function TMDCustomTextFields.GetTextContentRect: TRectF;
begin

end;

function TMDCustomTextFields.GetTextSettings: TTextSettings;
begin

end;

function TMDCustomTextFields.GetTyping: Boolean;
begin

end;

function TMDCustomTextFields.GetVertTextAlign: TTextAlign;
begin

end;

procedure TMDCustomTextFields.GoToTextBegin;
begin

end;

procedure TMDCustomTextFields.GoToTextEnd;
begin

end;

function TMDCustomTextFields.HasSelection: Boolean;
begin

end;

procedure TMDCustomTextFields.Loaded;
begin
  inherited;

end;

procedure TMDCustomTextFields.ObserverAdded(const ID: Integer; const Observer: IObserver);
begin
  inherited;

end;

procedure TMDCustomTextFields.ObserverToggle(const AObserver: IObserver; const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.PasteFromClipboard;
begin

end;

procedure TMDCustomTextFields.ReadReadOnly(Reader: TReader);
begin

end;

procedure TMDCustomTextFields.RealignButtonsContainer;
begin

end;

procedure TMDCustomTextFields.Replace(const AStartPos, ALength: Integer; const AStr: string);
begin

end;

procedure TMDCustomTextFields.ResetSelection;
begin

end;

procedure TMDCustomTextFields.Resize;
begin
  inherited;

end;

procedure TMDCustomTextFields.SelectAll;
begin

end;

procedure TMDCustomTextFields.SelectWord;
begin

end;

procedure TMDCustomTextFields.SetCaret(const Value: TCaret);
begin

end;

procedure TMDCustomTextFields.SetCaretPosition(const Value: Integer);
begin

end;

procedure TMDCustomTextFields.SetCheckSpelling(const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.SetData(const Value: TValue);
begin
  inherited;

end;

procedure TMDCustomTextFields.SetFilterChar(const Value: string);
begin

end;

procedure TMDCustomTextFields.SetFont(const Value: TFont);
begin

end;

procedure TMDCustomTextFields.SetFontColor(const Value: TMaterialColor);
begin

end;

procedure TMDCustomTextFields.SetImeMode(const Value: TImeMode);
begin

end;

procedure TMDCustomTextFields.SetInputSupport(const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.SetKeyboardType(Value: TVirtualKeyboardType);
begin

end;

procedure TMDCustomTextFields.SetKillFocusByReturn(const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.SetMaxLength(const Value: Integer);
begin

end;

procedure TMDCustomTextFields.SetOnChange(const Value: TNotifyEvent);
begin

end;

procedure TMDCustomTextFields.SetOnChangeTracking(const Value: TNotifyEvent);
begin

end;

procedure TMDCustomTextFields.SetOnTyping(const Value: TNotifyEvent);
begin

end;

procedure TMDCustomTextFields.SetOnValidate(const Value: TValidateTextEvent);
begin

end;

procedure TMDCustomTextFields.SetOnValidating(const Value: TValidateTextEvent);
begin

end;

procedure TMDCustomTextFields.SetPassword(const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.SetPromptText(const Prompt: string);
begin

end;

procedure TMDCustomTextFields.SetReadOnly(const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.SetReturnKeyType(Value: TReturnKeyType);
begin

end;

procedure TMDCustomTextFields.SetSelLength(const Value: Integer);
begin

end;

procedure TMDCustomTextFields.SetSelStart(const Value: Integer);
begin

end;

procedure TMDCustomTextFields.SetStyledSettings(const Value: TStyledSettings);
begin

end;

procedure TMDCustomTextFields.SetText(const Value: string);
begin

end;

procedure TMDCustomTextFields.SetTextAlign(const Value: TTextAlign);
begin

end;

procedure TMDCustomTextFields.SetTextSettings(const Value: TTextSettings);
begin

end;

procedure TMDCustomTextFields.SetTyping(const Value: Boolean);
begin

end;

procedure TMDCustomTextFields.SetVertTextAlign(const Value: TTextAlign);
begin

end;

function TMDCustomTextFields.StyledSettingsStored: Boolean;
begin

end;

end.
