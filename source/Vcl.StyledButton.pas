{******************************************************************************}
{                                                                              }
{       StyledButton: a Button Component based on TGraphicControl              }
{                                                                              }
{       Copyright (c) 2022-2023 (Ethea S.r.l.)                                 }
{       Author: Carlo Barazzetta                                               }
{       Contributors:                                                          }
{                                                                              }
{       https://github.com/EtheaDev/StyledComponents                           }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit Vcl.StyledButton;

interface

{$INCLUDE StyledComponents.inc}

uses
  Vcl.ImgList
  , System.UITypes
  , Vcl.Graphics
  , Vcl.buttons
  , System.SysUtils
  , System.Classes
  , Vcl.StdCtrls
  , Vcl.Themes
  , Vcl.Controls
  , Vcl.ActnList
  , Winapi.CommCtrl
  , Winapi.Messages
  , Winapi.Windows
  , System.Math
  , Vcl.ButtonStylesAttributes
  , Vcl.Menus
  ;

const
  StyledButtonsVersion = '2.0.0';
  DEFAULT_BTN_WIDTH = 75;
  DEFAULT_BTN_HEIGHT = 25;

resourcestring
  ERROR_SETTING_BUTTON_STYLE = 'Error setting Button Style: %s/%s/%s not available';

type
  EStyledButtonError = Exception;

  TStyledButtonState = (bsmNormal, bsmPressed, bsmSelected, bsmHot, bsmDisabled);

  TStyledGraphicButton = class;
  TStyledButton = class;

  TButtonFocusControl = class(TWinControl)
  private
    FButton: TStyledButton;
  protected
    procedure WMKeyUp(var Message: TWMKeyDown); message WM_KEYUP;
    procedure WndProc(var Message: TMessage); override;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure CMFocusChanged(var Message: TCMFocusChanged); message CM_FOCUSCHANGED;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
  public
    constructor Create(AOwner: TComponent; AStyledButton: TStyledButton); reintroduce;
    property TabOrder;
    property TabStop default True;
  end;

  TGraphicButtonActionLink = class(TControlActionLink)
  protected
    FClient: TStyledGraphicButton;
    function IsImageIndexLinked: Boolean; override;
    {$IFDEF D10_4+}
    function IsImageNameLinked: Boolean; override;
    {$ENDIF}
    procedure SetImageIndex(Value: Integer); override;
    procedure AssignClient(AClient: TObject); override;
    procedure SetChecked(Value: Boolean); override;
  public
    function IsCheckedLinked: Boolean; override;
  end;

  TStyledGraphicButton = class(TGraphicControl)
  private
    FButtonStyleNormal: TStyledButtonAttributes;
    FButtonStylePressed: TStyledButtonAttributes;
    FButtonStyleSelected: TStyledButtonAttributes;
    FButtonStyleHot: TStyledButtonAttributes;
    FButtonStyleDisabled: TStyledButtonAttributes;
    FModalResult: TModalResult;
    FMouseInControl: Boolean;
    FState: TButtonState;
    FImageMargins: TImageMargins;

    FStyleRadius: Integer;
    FStyleDrawType: TStyledButtonDrawType;
    FStyleFamily: TStyledButtonFamily;
    FStyleClass: TStyledButtonClass;
    FStyleAppearance: TStyledButtonAppearance;

    FCustomDrawType: Boolean;
    FStyleApplied: Boolean;

    FDisabledImages: TCustomImageList;
    FImages: TCustomImageList;
    FImageChangeLink: TChangeLink;

    FDisabledImageIndex: TImageIndex;
    FHotImageIndex: TImageIndex;
    FImageIndex: TImageIndex;
    FPressedImageIndex: TImageIndex;
    FSelectedImageIndex: TImageIndex;
    {$IFDEF D10_4+}
    FDisabledImageName: TImageName;
    FHotImageName: TImageName;
    FImageName: TImageName;
    FPressedImageName: TImageName;
    FSelectedImageName: TImageName;
    {$ENDIF}

    FImageAlignment: TImageAlignment;
    FTag: Integer;
    FWordWrap: Boolean;
    FActive: Boolean;
    FDefault: Boolean;
    FCancel: Boolean;

    procedure SetImageMargins(const AValue: TImageMargins);
    function IsCustomRadius: Boolean;
    procedure SetStyleRadius(const AValue: Integer);
    function GetImage(out AImageList: TCustomImageList;
      out AImageIndex: Integer): Boolean;
    function IsStoredStyleClass: Boolean;
    function IsStoredStyleFamily: Boolean;
    function IsStoredStyleAppearance: Boolean;
    function IsStoredStyleElements: Boolean;
    procedure SetStyleFamily(const AValue: TStyledButtonFamily);
    procedure SetStyleClass(const AValue: TStyledButtonClass);
    procedure SetStyleAppearance(const AValue: TStyledButtonAppearance);
    function ApplyButtonStyle: Boolean;

    procedure SetDisabledImages(const AValue: TCustomImageList);
    procedure SetImages(const AValue: TCustomImageList);

    function IsImageIndexStored: Boolean;
    procedure SetDisabledImageIndex(const AValue: TImageIndex);
    procedure SetHotImageIndex(const AValue: TImageIndex);
    procedure SetImageIndex(const AValue: TImageIndex);
    procedure SetPressedImageIndex(const AValue: TImageIndex);
    procedure SetSelectedImageIndex(const AValue: TImageIndex);

    {$IFDEF D10_4+}
    procedure UpdateImageIndex(Name: TImageName; var Index: TImageIndex);
    procedure UpdateImageName(Index: TImageIndex; var Name: TImageName);
    function IsImageNameStored: Boolean;
    procedure SetDisabledImageName(const AValue: TImageName);
    procedure SetHotImageName(const AValue: TImageName);
    procedure SetImageName(const AValue: TImageName);
    procedure SetPressedImageName(const AValue: TImageName);
    procedure SetSelectedImageName(const AValue: TImageName);
    {$ENDIF}

    function GetAttributes(const AMode: TStyledButtonState): TStyledButtonAttributes;
    procedure ImageMarginsChange(Sender: TObject);
    procedure SetImageAlignment(const AValue: TImageAlignment);
    procedure DrawButton;
    procedure DrawBackgroundAndBorder;
    procedure DrawText(const AText: string; var ARect: TRect; AFlags: Cardinal);
    function GetDrawingStyle: TStyledButtonAttributes;
    function IsCustomDrawType: Boolean;
    procedure SetStyleDrawType(const AValue: TStyledButtonDrawType);
    procedure ImageListChange(Sender: TObject);
    function GetText: TCaption;
    procedure SetText(const AValue: TCaption);

    procedure SetButtonStylePressed(const AValue: TStyledButtonAttributes);
    procedure SetButtonStyleSelected(const AValue: TStyledButtonAttributes);
    procedure SetButtonStyleHot(const AValue: TStyledButtonAttributes);
    procedure SetButtonStyleNormal(const AValue: TStyledButtonAttributes);
    procedure SetButtonStyleDisabled(const AValue: TStyledButtonAttributes);

    function IsCaptionStored: Boolean;
    function IsStyleSelectedStored: Boolean;
    function IsStyleHotStored: Boolean;
    function IsStyleNormalStored: Boolean;
    function IsStyleDisabledStored: Boolean;
    function IsStylePressedStored: Boolean;

    procedure UpdateControlStyle;
    procedure CMStyleChanged(var Message: TMessage); message CM_STYLECHANGED;
    procedure SetModalResult(const AValue: TModalResult);
    procedure SetWordWrap(const AValue: Boolean);
    procedure SetStyleApplied(const AValue: Boolean);
    procedure SetDefault(const AValue: Boolean);
  protected
    function GetButtonState: TStyledButtonState; virtual;
    function IsPressed: Boolean; virtual;
    function IsDefault: Boolean; virtual;
    function GetFocused: Boolean; virtual;
    function GetCanFocus: Boolean; virtual;
    procedure UpdateImageIndexAndName; virtual;
    {$IFDEF D10_4+}
    procedure UpdateImages; virtual;
    procedure CheckImageIndexes;
    {$ENDIF}
    procedure ActionChange(Sender: TObject; CheckDefaults: Boolean); override;
    function GetActionLinkClass: TControlActionLinkClass; override;
    procedure SetName(const AValue: TComponentName); override;
    procedure Loaded; override;
    procedure DoKeyUp;
    procedure Paint; override;
    procedure DoKeyDown(var AKey: Word; AShift: TShiftState);
    {$IFDEF HiDPISupport}
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    {$ENDIF}
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMMouseEnter(var Message: TNotifyEvent); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TNotifyEvent); message CM_MOUSELEAVE;
    procedure Notification(AComponent: TComponent; AOperation: TOperation); override;
    function CalcImageRect(var ATextRect: TRect;
      const AImageWidth, AImageHeight: Integer): TRect;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure UpdateStyleElements; override;
  public
    procedure SetButtonStyle(const AStyleFamily: TStyledButtonFamily;
      const AStyleClass: TStyledButtonClass;
      const AStyleAppearance: TStyledButtonAppearance); overload;
    procedure SetButtonStyle(const AStyleFamily: TStyledButtonFamily;
      const AModalResult: TModalResult); overload;

    procedure SetFocus; virtual;
    procedure AssignStyleTo(ADest: TStyledGraphicButton); virtual;
    procedure AssignTo(ADest: TPersistent); override;
    function AssignAttributes(
      const AEnabled: Boolean = True;
      const AImageList: TCustomImageList = nil;
      {$IFDEF D10_4+}const AImageName: string = '';{$ENDIF}
      const AImageIndex: Integer = -1;
      const AImageAlignment: TImageAlignment = iaLeft;
      const AAction: TCustomAction = nil;
      const AOnClick: TNotifyEvent = nil;
      const AName: string = ''): TStyledGraphicButton;

    procedure Click; override;
    procedure SetButtonStyles(
      const AFamily: TStyledButtonFamily;
      const AClass: TStyledButtonClass;
      const AAppearance: TStyledButtonAppearance);

    constructor CreateStyled(AOwner: TComponent;
      const AFamily: TStyledButtonFamily;
      const AClass: TStyledButtonClass;
      const AAppearance: TStyledButtonAppearance); virtual;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Focused: Boolean read GetFocused;
    property ButtonState: TStyledButtonState read GetButtonState;
    property StyleApplied: Boolean read FStyleApplied write SetStyleApplied;
  published
    property Action;
    property Align;
    property Anchors;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnGesture;
    property OnStartDock;
    property OnStartDrag;
    property OnClick;
    property PopUpMenu;
    property ParentFont default true;
    property ParentShowHint;
    property ShowHint;
    {$IFDEF D10_4+}
    property StyleName;
    {$ENDIF}
    property StyleElements stored IsStoredStyleElements;
    property Touch;
    property Visible;

    property Caption: TCaption read GetText write SetText stored IsCaptionStored;
    property Cursor default crHandPoint;

    property Default: Boolean read FDefault write SetDefault default False;
    property Cancel: Boolean read FCancel write FCancel default False;

    property Height default DEFAULT_BTN_HEIGHT;
    property ImageAlignment: TImageAlignment read FImageAlignment write SetImageAlignment default iaLeft;
    property DisabledImageIndex: TImageIndex read FDisabledImageIndex write SetDisabledImageIndex default -1;
    property DisabledImages: TCustomImageList read FDisabledImages write SetDisabledImages;
    property HotImageIndex: TImageIndex read FHotImageIndex write SetHotImageIndex default -1;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex stored IsImageIndexStored default -1;
    property PressedImageIndex: TImageIndex read FPressedImageIndex write SetPressedImageIndex default -1;
    property SelectedImageIndex: TImageIndex read FSelectedImageIndex write SetSelectedImageIndex default -1;

    {$IFDEF D10_4+}
    property DisabledImageName: TImageName read FDisabledImageName write SetDisabledImageName;
    property HotImageName: TImageName read FHotImageName write SetHotImageName;
    property ImageName: TImageName read FImageName write SetImageName stored IsImageNameStored;
    property PressedImageName: TImageName read FPressedImageName write SetPressedImageName;
    property SelectedImageName: TImageName read FSelectedImageName write SetSelectedImageName;
    {$ENDIF}
    property ImageMargins: TImageMargins read FImageMargins write SetImageMargins;
    property ModalResult: TModalResult read FModalResult write SetModalResult default mrNone;

    //StyledComponents Attributes
    property StyleRadius: Integer read FStyleRadius write SetStyleRadius stored IsCustomRadius default DEFAULT_RADIUS;
    property StyleDrawType: TStyledButtonDrawType read FStyleDrawType write SetStyleDrawType stored IsCustomDrawType default btRounded;
    property StyleFamily: TStyledButtonFamily read FStyleFamily write SetStyleFamily stored IsStoredStyleFamily;
    property StyleClass: TStyledButtonClass read FStyleClass write SetStyleClass stored IsStoredStyleClass;
    property StyleAppearance: TStyledButtonAppearance read FStyleAppearance write SetStyleAppearance stored IsStoredStyleAppearance;

    property Tag: Integer read FTag write FTag default 0;
    property Width default DEFAULT_BTN_WIDTH;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;

    property ButtonStyleNormal: TStyledButtonAttributes read FButtonStyleNormal write SetButtonStyleNormal stored IsStyleNormalStored;
    property ButtonStylePressed: TStyledButtonAttributes read FButtonStylePressed write SetButtonStylePressed stored IsStylePressedStored;
    property ButtonStyleSelected: TStyledButtonAttributes read FButtonStyleSelected write SetButtonStyleSelected stored IsStyleSelectedStored;
    property ButtonStyleHot: TStyledButtonAttributes read FButtonStyleHot write SetButtonStyleHot stored IsStyleHotStored;
    property ButtonStyleDisabled: TStyledButtonAttributes read FButtonStyleDisabled write SetButtonStyleDisabled stored IsStyleDisabledStored;
  end;

  TStyledButton = class(TStyledGraphicButton)
  private
    FTabStop: Boolean;
    FFocusControl: TButtonFocusControl;
    function GetTabOrder: Integer;
    procedure SetTabStop(const AValue: Boolean);
    function GetTabStop: Boolean;
    procedure SetTabOrder(const AValue: Integer);
    procedure DestroyFocusControl;
    procedure CreateFocusControl(const AParent: TWinControl);
    procedure AdjustFocusControlPos;
    function GetOnKeyDown: TKeyEvent;
    procedure SetOnKeyDown(const AValue: TKeyEvent);
    function GetOnKeyUp: TKeyEvent;
    procedure SetOnKeyUp(const AValue: TKeyEvent);
  protected
    function GetEnabled: Boolean; override;
    procedure SetEnabled(AValue: Boolean); override;
    function GetFocused: Boolean; override;
    function GetCanFocus: Boolean; override;
    procedure VisibleChanging; override;
    procedure SetName(const AValue: TComponentName); override;
    procedure SetParent(AParent: TWinControl); override;
  public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetFocus; override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure Click; override;
    constructor CreateStyled(AOwner: TComponent;
      const AFamily: TStyledButtonFamily;
      const AClass: TStyledButtonClass;
      const AAppearance: TStyledButtonAppearance); override;
    destructor Destroy; override;
    property CanFocus: Boolean read GetCanFocus;
  published
    //property Enabled: Boolean read GetEnabled write SetEnabled;
    property TabOrder: Integer read GetTabOrder write SetTabOrder;
    property TabStop: Boolean read GetTabStop write SetTabStop default True;
    property OnKeyDown: TKeyEvent read GetOnKeyDown write SetOnKeyDown;
    property OnKeyUp: TKeyEvent read GetOnKeyUp write SetOnKeyUp;
  end;

//Global function to create a StyledButton
function CreateAndPosStyledButton(const AOwner: TComponent;
  const AParent: TWinControl;
  const AFamily: TStyledButtonFamily;
  const AClass: TStyledButtonClass;
  const AAppearance: TStyledButtonAppearance;
  const ACaption: TCaption;
  const ARectPosition: TRect): TStyledButton;

implementation

uses
  System.Types
  , Vcl.Forms
  , Vcl.StandardButtonStyles
  ;

function CreateAndPosStyledButton(const AOwner: TComponent;
  const AParent: TWinControl;
  const AFamily: TStyledButtonFamily;
  const AClass: TStyledButtonClass;
  const AAppearance: TStyledButtonAppearance;
  const ACaption: TCaption;
  const ARectPosition: TRect): TStyledButton;
begin
  Result := TStyledButton.CreateStyled(AOwner, AFamily, AClass, AAppearance);
  Result.Parent := AParent;
  Result.Caption := ACaption;
  Result.SetBounds(ARectPosition.Left, ARectPosition.Top, ARectPosition.Right, ARectPosition.Bottom);
end;

{ TButtonFocusControl }

procedure TButtonFocusControl.CMDialogKey(var Message: TCMDialogKey);
begin
  with Message do
    if  (((CharCode = VK_RETURN) and FButton.FActive) or
      ((CharCode = VK_ESCAPE) and FButton.FCancel)) and
      (KeyDataToShiftState(Message.KeyData) = []) and FButton.CanFocus then
    begin
      FButton.Click;
      Result := 1;
    end
    else
      inherited;
end;

procedure TButtonFocusControl.CMFocusChanged(var Message: TCMFocusChanged);
begin
  with Message do
  begin
    if Sender is TButtonFocusControl then
      FButton.FActive := Sender = Self
    else
      FButton.FActive := FButton.FDefault;
  end;
  inherited;
end;

constructor TButtonFocusControl.Create(AOwner: TComponent; AStyledButton: TStyledButton);
begin
  inherited Create(AOwner);
  FButton := AStyledButton;
  Self.TabStop := false;
end;

procedure TButtonFocusControl.WMKeyDown(var Message: TWMKeyDown);
var
  Shift: TShiftState;
begin
  if Assigned(FButton) then
  begin
    Shift := KeyDataToShiftState(Message.KeyData);
    FButton.DoKeyDown(Message.CharCode, Shift);
  end;
  inherited;
end;

procedure TButtonFocusControl.WndProc(var Message: TMessage);
begin
  inherited;
  if Assigned(FButton) then
  begin
    if (Message.Msg = WM_KILLFOCUS) then
      FButton.Invalidate
    else if (Message.Msg = WM_SETFOCUS) and not FButton.FActive then
      FButton.Invalidate;
  end;
end;

procedure TButtonFocusControl.WMKeyUp(var Message: TWMKeyDown);
begin
  if Assigned(FButton) then
    FButton.DoKeyUp;
  inherited;
end;

{ TGraphicButton }

procedure TStyledGraphicButton.AssignStyleTo(ADest: TStyledGraphicButton);
begin
  ADest.Font.Assign(Self.Font);
  ADest.FStyleRadius := Self.FStyleRadius;
  ADest.FImageMargins.Assign(FImageMargins);
  ADest.FButtonStyleNormal.Assign(Self.FButtonStyleNormal);
  ADest.FButtonStylePressed.Assign(Self.FButtonStylePressed);
  ADest.FButtonStyleSelected.Assign(Self.FButtonStyleSelected);
  ADest.FButtonStyleHot.Assign(Self.FButtonStyleHot);
  ADest.FButtonStyleDisabled.Assign(Self.FButtonStyleDisabled);
  ADest.SetButtonStyles(Self.FStyleFamily,
    Self.FStyleClass, Self.FStyleAppearance);
  ADest.FStyleDrawType := Self.FStyleDrawType;
  ADest.FCustomDrawType := Self.FCustomDrawType;
  if Assigned(FImages) then
  begin
    ADest.FImageAlignment := Self.FImageAlignment;
    ADest.Images := Images;
    ADest.DisabledImageIndex := Self.DisabledImageIndex;
    ADest.ImageIndex := Self.ImageIndex;
    ADest.HotImageIndex := Self.HotImageIndex;
    ADest.SelectedImageIndex := Self.SelectedImageIndex;
    ADest.PressedImageIndex := Self.PressedImageIndex;
    {$IFDEF D10_4+}
    ADest.DisabledImageName := Self.DisabledImageName;
    ADest.ImageName := Self.ImageName;
    ADest.HotImageName := Self.HotImageName;
    ADest.SelectedImageName := Self.SelectedImageName;
    ADest.PressedImageName := Self.PressedImageName;
    {$ENDIF}
  end;
  if Assigned(FDisabledImages) then
  begin
    ADest.DisabledImages := DisabledImages;
    ADest.DisabledImageIndex := Self.DisabledImageIndex;
    {$IFDEF D10_4+}
    ADest.DisabledImageName := Self.DisabledImageName;
    {$ENDIF}
  end;
end;

function TStyledGraphicButton.AssignAttributes(
  const AEnabled: Boolean = True;
  const AImageList: TCustomImageList = nil;
  {$IFDEF D10_4+}const AImageName: string = '';{$ENDIF}
  const AImageIndex: Integer = -1;
  const AImageAlignment: TImageAlignment = iaLeft;
  const AAction: TCustomAction = nil;
  const AOnClick: TNotifyEvent = nil;
  const AName: string = ''): TStyledGraphicButton;
begin
  Enabled := AEnabled;
  if Assigned(AImageList) then
  begin
    Images := AImageList;
    {$IFDEF D10_4+}
    if AImageName <> '' then
      ImageName := AImageName
    else
      ImageIndex := AImageIndex;
    {$ELSE}
    ImageIndex := AImageIndex;
    {$ENDIF}
    ImageAlignment := AImageAlignment;
  end;
  if Assigned(AAction) then
    Action := AAction
  else if Assigned(AOnClick) then
    OnClick := AOnClick;
  if AName <> '' then
    Name := AName;
  Result := Self;
end;

procedure TStyledGraphicButton.AssignTo(ADest: TPersistent);
var
  LDest: TStyledGraphicButton;
begin
  if ADest is TStyledGraphicButton then
  begin
    LDest := TStyledGraphicButton(ADest);
    AssignStyleTo(LDest);
    LDest.Caption := Self.Caption;
    LDest.Hint := Self.Hint;
    LDest.FModalResult := Self.FModalResult;
    LDest.FTag := Self.Tag;
    LDest.Enabled := Self.Enabled;
    LDest.Visible := Self.Visible;
  end;
end;

{$IFDEF HiDPISupport}
procedure TStyledGraphicButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  FImageMargins.Left := MulDiv(FImageMargins.Left, M, D);
  FImageMargins.Top := MulDiv(FImageMargins.Top, M, D);
  FImageMargins.Right := MulDiv(FImageMargins.Right, M, D);
  FImageMargins.Bottom := MulDiv(FImageMargins.Bottom, M, D);
  inherited;
end;
{$ENDIF}

procedure TStyledGraphicButton.CMEnter(var Message: TCMEnter);
begin
  if not(Enabled) or (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := false;
//  Invalidate;
end;

procedure TStyledGraphicButton.CMMouseEnter(var Message: TNotifyEvent);
begin
  if not(Enabled) or (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := true;
  Invalidate;
end;

procedure TStyledGraphicButton.CMMouseLeave(var Message: TNotifyEvent);
begin
  if not(Enabled) or (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := false;
  Invalidate;
end;

procedure TStyledGraphicButton.UpdateControlStyle;
begin
  //try to remove flicker on "non style" Windows
  if not StyleServices.Enabled or
    (StyleServices.IsSystemStyle and Assigned(Parent) and (Parent.DoubleBuffered)) then
    ControlStyle := ControlStyle + [csOpaque]
  else
    ControlStyle := ControlStyle - [csOpaque];
  UpdateStyleElements;
end;

procedure TStyledGraphicButton.CMStyleChanged(var Message: TMessage);
begin
  UpdateControlStyle;
  Invalidate;
end;

procedure TStyledGraphicButton.Click;
begin
  FState := bsDown;
  try
    Invalidate;
    inherited;
  finally
    FState := bsUp;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.ImageListChange(Sender: TObject);
begin
  UpdateImageIndexAndName;
  Invalidate;
end;

procedure TStyledGraphicButton.ImageMarginsChange(Sender: TObject);
begin
  Invalidate;
end;

constructor TStyledGraphicButton.CreateStyled(AOwner: TComponent;
  const AFamily: TStyledButtonFamily;
  const AClass: TStyledButtonClass;
  const AAppearance: TStyledButtonAppearance);
begin
  inherited Create(AOwner);
  FButtonStyleNormal := TStyledButtonAttributes.Create(Self);
  FButtonStyleNormal.Name := 'Normal';
  FButtonStylePressed := TStyledButtonAttributes.Create(Self);
  FButtonStylePressed.Name := 'Pressed';
  FButtonStyleSelected := TStyledButtonAttributes.Create(Self);
  FButtonStyleSelected.Name := 'Selected';
  FButtonStyleHot := TStyledButtonAttributes.Create(Self);
  FButtonStyleHot.Name := 'Hot';
  FButtonStyleDisabled := TStyledButtonAttributes.Create(Self);
  FButtonStyleDisabled.Name := 'Disabled';
  ControlStyle := [csCaptureMouse, csClickEvents, csSetCaption, csDoubleClicks];
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FImageMargins := TImageMargins.Create;
  FImageMargins.OnChange := ImageMarginsChange;
  FImageAlignment := iaLeft;
  FCustomDrawType := False;
  Cursor := crHandPoint;
  ControlStyle := ControlStyle + [csReplicatable];
  ParentFont := true;
  Width := DEFAULT_BTN_WIDTH;
  Height := DEFAULT_BTN_HEIGHT;
  FMouseInControl := false;
  FDisabledImageIndex := -1;
  FHotImageIndex := -1;
  FImageAlignment := iaLeft;
  FImageIndex := -1;
  FPressedImageIndex := -1;
  FSelectedImageIndex := -1;
  {$IFDEF D10_4+}
  FImageName := '';
  {$ENDIF}
  FStyleDrawType := btRounded;
  FStyleRadius := DEFAULT_RADIUS;
  FStyleFamily := AFamily;
  FStyleAppearance := AAppearance;
  StyleClass := AClass;
end;

constructor TStyledGraphicButton.Create(AOwner: TComponent);
begin
  CreateStyled(AOwner,
    DEFAULT_CLASSIC_FAMILY,
    DEFAULT_WINDOWS_CLASS,
    DEFAULT_APPEARANCE);
end;

procedure TStyledGraphicButton.ActionChange(Sender: TObject; CheckDefaults: Boolean);
begin
  inherited;
  if Sender is TCustomAction then
  begin
    if not CheckDefaults or (ImageIndex = -1) then
      ImageIndex := TCustomAction(Sender).ImageIndex;
  {$IFDEF D10_4+}
    if not CheckDefaults or (ImageName = '') then
      ImageName := TCustomAction(Sender).ImageName;
  {$ENDIF}
  end;
end;

function TStyledGraphicButton.ApplyButtonStyle: Boolean;
begin
  Result := StyleFamilyCheckAttributes(FStyleFamily,
    FStyleClass, FStyleAppearance);
  if Result or (csDesigning in ComponentState) then
  begin
    StyleFamilyUpdateAttributes(
      FStyleFamily,
      FStyleClass,
      FstyleAppearance,
      FButtonStyleNormal,
      FButtonStylePressed,
      FButtonStyleSelected,
      FButtonStyleHot,
      FButtonStyleDisabled);

    if not FCustomDrawType then
      FStyleDrawType := FButtonStyleNormal.DrawType;
  end;
  if Result then
    Invalidate;
end;

destructor TStyledGraphicButton.Destroy;
begin
  Images := nil;
  FreeAndNil(FImageChangeLink);
  FreeAndNil(FImageMargins);
  FreeAndNil(FButtonStyleNormal);
  FreeAndNil(FButtonStylePressed);
  FreeAndNil(FButtonStyleSelected);
  FreeAndNil(FButtonStyleHot);
  FreeAndNil(FButtonStyleDisabled);

  inherited Destroy;
end;

procedure TStyledGraphicButton.DoKeyDown(var AKey: Word; AShift: TShiftState);
begin
  if ((AKey = VK_RETURN) or (AKey = VK_SPACE)) then
  begin
    Self.Click;
  end;
end;

procedure TStyledGraphicButton.DoKeyUp;
begin
  FState := bsUp;
  Invalidate;
end;

function TStyledGraphicButton.GetText: TCaption;
begin
  Result := inherited Caption;
end;

function TStyledGraphicButton.GetImage(out AImageList: TCustomImageList;
  out AImageIndex: Integer): Boolean;
begin
  case ButtonState of
    bsmNormal:
    begin
      AImageList := FImages;
      AImageIndex := FImageIndex;
    end;
    bsmPressed:
    begin
      AImageList := FImages;
      if FPressedImageIndex <> -1 then
        AImageIndex := FPressedImageIndex
      else
        AImageIndex := FImageIndex;
    end;
    bsmHot:
    begin
      AImageList := FImages;
        if FHotImageIndex <> -1 then
        AImageIndex := FHotImageIndex
      else
        AImageIndex := FImageIndex;
    end;
    bsmSelected:
    begin
      AImageList := FImages;
      if FSelectedImageIndex <> -1 then
        AImageIndex := FSelectedImageIndex
      else
        AImageIndex := FImageIndex;
    end;
    bsmDisabled:
    begin
      if Assigned(FDisabledImages) then
        AImageList := FDisabledImages
      else
        AImageList := FImages;
      if FDisabledImageIndex <> -1 then
        AImageIndex := FDisabledImageIndex
      else
        AImageIndex := FImageIndex;
    end;
  end;
  Result := Assigned(AImageList) and (AImageIndex <> -1);
end;

function TStyledGraphicButton.IsCaptionStored: Boolean;
begin
  Result := (ActionLink = nil) or
    not TGraphicButtonActionLink(ActionLink).IsCaptionLinked;
end;

function TStyledGraphicButton.IsImageIndexStored: Boolean;
begin
  Result := (ActionLink = nil) or
    not TGraphicButtonActionLink(ActionLink).IsImageIndexLinked;
end;

function TStyledGraphicButton.IsCustomDrawType: Boolean;
begin
  Result := FCustomDrawType;
end;

function TStyledGraphicButton.IsDefault: Boolean;
begin
  Result := False;
end;

function TStyledGraphicButton.IsPressed: Boolean;
begin
  Result := FState = bsDown;
end;

function TStyledGraphicButton.IsCustomRadius: Boolean;
begin
  Result := StyleRadius <> DEFAULT_RADIUS;
end;

function TStyledGraphicButton.IsStoredStyleFamily: Boolean;
begin
  Result := FStyleFamily <> DEFAULT_CLASSIC_FAMILY;
end;

function TStyledGraphicButton.IsStoredStyleClass: Boolean;
var
  LClass: TStyledButtonClass;
  LAppearance: TStyledButtonAppearance;
begin
  StyleFamilyCheckAttributes(FStyleFamily, LClass, LAppearance);
  Result := FStyleClass <> LClass;
end;

function TStyledGraphicButton.IsStoredStyleElements: Boolean;
begin
  if FStyleFamily = DEFAULT_CLASSIC_FAMILY then
    Result := StyleElements <> [seFont, seClient, seBorder]
  else
    Result := False;
end;

function TStyledGraphicButton.IsStoredStyleAppearance: Boolean;
var
  LClass: TStyledButtonClass;
  LAppearance: TStyledButtonAppearance;
begin
  StyleFamilyCheckAttributes(FStyleFamily, LClass, LAppearance);
  Result := FStyleAppearance <> LAppearance;
end;

function TStyledGraphicButton.IsStyleDisabledStored: Boolean;
begin
  Result := FButtonStyleDisabled.IsChanged;
end;

function TStyledGraphicButton.IsStylePressedStored: Boolean;
begin
  Result := FButtonStylePressed.IsChanged;
end;

function TStyledGraphicButton.IsStyleSelectedStored: Boolean;
begin
  Result := FButtonStyleSelected.IsChanged;
end;

function TStyledGraphicButton.IsStyleHotStored: Boolean;
begin
  Result := FButtonStyleHot.IsChanged;
end;

function TStyledGraphicButton.IsStyleNormalStored: Boolean;
begin
  Result := FButtonStyleNormal.IsChanged;
end;

function TStyledGraphicButton.GetActionLinkClass: TControlActionLinkClass;
begin
  Result := TGraphicButtonActionLink;
end;

function TStyledGraphicButton.GetAttributes(const AMode: TStyledButtonState): TStyledButtonAttributes;
begin
  case Amode of
    bsmPressed: Result := FButtonStylePressed;
    bsmSelected: Result := FButtonStyleSelected;
    bsmHot: Result := FButtonStyleHot;
    bsmDisabled: Result := FButtonStyleDisabled;
  else
    Result := FButtonStyleNormal;
  end;
end;

function TStyledGraphicButton.GetCanFocus: Boolean;
begin
  Result := False;
end;

procedure TStyledGraphicButton.DrawText(const AText: string; var ARect: TRect; AFlags: Cardinal);
var
  TextFormat: TTextFormatFlags;
  R: TRect;

  function CanvasDrawText(ACanvas: TCanvas; const AText: string; var Bounds: TRect; Flag: Cardinal): Integer;
  begin
    SetBkMode(ACanvas.Handle, TRANSPARENT);
    Result := Winapi.Windows.DrawText(ACanvas.Handle, PChar(AText), Length(AText), Bounds, Flag)
  end;

begin
  TextFormat := TTextFormatFlags(AFlags);
  //Drawing Caption
  R := ARect;
  CanvasDrawText(Canvas, AText, R, AFlags or DT_CALCRECT);
  OffsetRect(R, (ARect.Width - R.Width) div 2, (ARect.Height - R.Height) div 2);
  CanvasDrawText(Canvas, AText, R, AFlags);
end;

procedure TStyledGraphicButton.DrawBackgroundAndBorder;
var
  DrawRect: TRect;
begin
  DrawRect := ClientRect;

  //Draw Button Shape
  CanvasDrawshape(Canvas, DrawRect, FStyleDrawType, FStyleRadius);
end;

function TStyledGraphicButton.CalcImageRect(var ATextRect: TRect;
  const AImageWidth, AImageHeight: Integer): TRect;
var
  IW, IH, IX, IY: Integer;
begin
  //Calc Image Rect
  IH := AImageHeight;
  IW := AImageWidth;
  if (IH > 0) and (IW > 0) then
  begin
    IX := ATextRect.Left + 2;
    IY := ATextRect.Top + (ATextRect.Height - IH) div 2;
    case FImageAlignment of
      iaCenter:
        begin
          IX := ATextRect.CenterPoint.X - IW div 2;
        end;
      iaLeft:
        begin
          IX := ATextRect.Left + 2;
          Inc(IX, ImageMargins.Left);
          Inc(IY, ImageMargins.Top);
          Dec(IY, ImageMargins.Bottom);
          Inc(ATextRect.Left, IX + IW + ImageMargins.Right);
        end;
      iaRight:
        begin
          IX := ATextRect.Right - IW - 2;
          Dec(IX, ImageMargins.Right);
          Dec(IX, ImageMargins.Left);
          Inc(IY, ImageMargins.Top);
          Dec(IY, ImageMargins.Bottom);
          ATextRect.Right := IX;
        end;
      iaTop:
        begin
          IX := ATextRect.Left + (ATextRect.Width - IW) div 2;
          Inc(IX, ImageMargins.Left);
          Dec(IX, ImageMargins.Right);
          IY := ATextRect.Top + 2;
          Inc(IY, ImageMargins.Top);
          Inc(ATextRect.Top, IY + IH + ImageMargins.Bottom);
        end;
      iaBottom:
        begin
          IX := ATextRect.Left + (ATextRect.Width - IW) div 2;
          Inc(IX, ImageMargins.Left);
          Dec(IX, ImageMargins.Right);
          IY := ATextRect.Bottom - IH - 2;
          Dec(IY, ImageMargins.Bottom);
          Dec(IY, ImageMargins.Top);
          ATextRect.Bottom := IY;
        end;
    end;
  end
  else
  begin
    IX := 0;
    IY := 0;
  end;
  Result.Left := IX;
  Result.Top := IY;
  Result.Width := IW;
  Result.Height := IH;
end;

procedure TStyledGraphicButton.SetButtonStyles(
  const AFamily: TStyledButtonFamily; const AClass: TStyledButtonClass;
  const AAppearance: TStyledButtonAppearance);
begin
  if (AFamily <> FStyleFamily) or
    (AClass <> FStyleClass) or
    (AAppearance <> FStyleAppearance) then
  begin
    FStyleFamily := AFamily;
    FStyleClass := AClass;
    FStyleAppearance := AAppearance;
    ApplyButtonStyle;
  end;
end;

{$IFDEF D10_4+}
procedure TStyledGraphicButton.CheckImageIndexes;
begin
  if (Images = nil) or not Images.IsImageNameAvailable then
    Exit;
  Images.CheckIndexAndName(FImageIndex, FImageName);
  Images.CheckIndexAndName(FHotImageIndex, FHotImageName);
  Images.CheckIndexAndName(FPressedImageIndex, FPressedImageName);
  Images.CheckIndexAndName(FSelectedImageIndex, FSelectedImageName);
  //Images.CheckIndexAndName(FStylusHotImageIndex, FStylusHotImageName);
  if FDisabledImages <> nil then
    FDisabledImages.CheckIndexAndName(FDisabledImageIndex, FDisabledImageName)
  else
    Images.CheckIndexAndName(FDisabledImageIndex, FDisabledImageName);
end;
{$ENDIF}

procedure TStyledGraphicButton.DrawButton;
var
  LTextFlags: Cardinal;
  LTextRect, LImageRect: TRect;
  LImageList: TCustomImageList;
  LImageIndex: Integer;
  LOldFontName: TFontName;
  LOldFontColor: TColor;
  LOldFontStyle: TFontStyles;
  LOldParentFont: boolean;
begin
  LOldParentFont := ParentFont;
  LOldFontName := Font.Name;
  LOldFontColor := Font.Color;
  LOldFontStyle := Font.Style;
  try
    GetDrawingStyle;
    LTextFlags := 0;
    if FWordWrap then
      LTextFlags := LTextFlags or DT_WORDBREAK or DT_CENTER;

    DrawBackgroundAndBorder;

    LTextRect := ClientRect;
    if GetImage(LImageList, LImageIndex) then
    begin
      LImageRect := CalcImageRect(LTextRect, LImageList.Width, LImageList.Height);
      LImageList.Draw(Canvas, LImageRect.Left, LImageRect.Top, LImageIndex, Enabled);
    end;
    if LTextRect.IsEmpty then
      LTextRect := ClientRect;
    DrawText(Caption, LTextRect, DrawTextBiDiModeFlags(LTextFlags));
  finally
    if LOldParentFont then
      ParentFont := LOldParentFont
    else
    begin
      Font.Name := LOldFontName;
      Font.Color := LOldFontColor;
      Font.Style := LOldFontStyle;
    end;
  end;
end;

function TStyledGraphicButton.GetButtonState: TStyledButtonState;
begin
  //Getting button state
  if not Enabled then
    Result := bsmDisabled
  else if FState = bsDown then
    Result := bsmPressed
  else if FMouseInControl then
    Result := bsmHot
  else if Focused then
    Result := bsmSelected
  else
    Result := bsmNormal;
end;

function TStyledGraphicButton.GetDrawingStyle: TStyledButtonAttributes;
begin
  //Getting drawing styles
  Result := GetAttributes(ButtonState);
  Canvas.Pen.Style := Result.PenStyle;
  Canvas.Pen.Width := Round(Result.BorderWidth{$IFDEF D10_3+}* ScaleFactor{$ENDIF});
  Canvas.Pen.Color := Result.BorderColor;
  Canvas.Brush.Style := Result.BrushStyle;
  if Canvas.Brush.Style <> bsClear then
    Canvas.Brush.Color := Result.ButtonColor;
  Canvas.Font := Font;
  Canvas.Font.Color := Result.FontColor;
  if ParentFont then
    Canvas.Font.Style := Result.FontStyle;
end;

function TStyledGraphicButton.GetFocused: Boolean;
begin
  Result := False;
end;

procedure TStyledGraphicButton.Paint;
begin
  DrawButton;
end;

procedure TStyledGraphicButton.SetStyleDrawType(const AValue: TStyledButtonDrawType);
begin
  if FStyleDrawType <> AValue then
  begin
    FStyleDrawType := AValue;
    FCustomDrawType := True;
(* do not assign DrawType to any Style
    FButtonStyleNormal.DrawType := FDrawType;
    FButtonStylePressed.DrawType := FDrawType;
    FButtonStyleSelected.DrawType := FDrawType;
    FButtonStyleHot.DrawType := FDrawType;
    FButtonStyleDisabled.DrawType := FDrawType;
*)
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.SetImageAlignment(const AValue: TImageAlignment);
begin
  if AValue <> FImageAlignment then
  begin
    FImageAlignment := AValue;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.SetDefault(const AValue: Boolean);
var
  Form: TCustomForm;
begin
  FDefault := AValue;
  if Assigned(Parent) then
  begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.Perform(CM_FOCUSCHANGED, 0, LPARAM(Form.ActiveControl));
  end;
  if (csLoading in ComponentState) then
    FActive := FDefault;
end;

procedure TStyledGraphicButton.SetDisabledImageIndex(const AValue: TImageIndex);
begin
  if AValue <> FDisabledImageIndex then
  begin
    FDisabledImageIndex := AValue;
    {$IFDEF D10_4+}
    if (FDisabledImages <> nil) and FDisabledImages.IsImageNameAvailable then
      FDisabledImageName := FDisabledImages.GetNameByIndex(FDisabledImageIndex)
    else
      if (FDisabledImages = nil) and (FImages <> nil) and FImages.IsImageNameAvailable then
        FDisabledImageName := FImages.GetNameByIndex(FDisabledImageIndex);
    {$ENDIF}
    UpdateImageIndexAndName;
  end;
end;

procedure TStyledGraphicButton.SetImageIndex(const AValue: TImageIndex);
begin
  if AValue <> FImageIndex then
  begin
    FImageIndex := AValue;
    {$IFDEF D10_4+}
    if (FImages <> nil) and FImages.IsImageNameAvailable then
       FImageName := FImages.GetNameByIndex(FImageIndex);
    {$ENDIF}
    UpdateImageIndexAndName;
    Invalidate;
  end;
end;

{$IFDEF D10_4+}
procedure TStyledGraphicButton.SetDisabledImageName(const AValue: TImageName);
begin
  if AValue <> FDisabledImageName then
  begin
    FDisabledImageName := AValue;
    if (FDisabledImages <> nil) and FDisabledImages.IsImageNameAvailable then
      FDisabledImageIndex := FDisabledImages.GetIndexByName(FDisabledImageName)
    else
      if (FDisabledImages = nil) and (FImages <> nil) and FImages.IsImageNameAvailable then
        FDisabledImageIndex := FImages.GetIndexByName(FDisabledImageName);
    UpdateImageIndexAndName;
  end;
end;

function TStyledGraphicButton.IsImageNameStored: Boolean;
begin
  Result := (ActionLink = nil) or
    not TGraphicButtonActionLink(ActionLink).IsImageNameLinked;
end;

procedure TStyledGraphicButton.SetImageName(const AValue: TImageName);
begin
  if AValue <> FImageName then
  begin
    FImageName := AValue;
    if (FImages <> nil) and FImages.IsImageNameAvailable then
      FImageIndex := FImages.GetIndexByName(FImageName);
    UpdateImageIndexAndName;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.UpdateImages;
begin
  if CheckWin32Version(5, 1) and (FImageIndex <> -1) then
  begin
    CheckImageIndexes;
  end;
end;

procedure TStyledGraphicButton.UpdateImageName(Index: TImageIndex;
  var Name: TImageName);
begin
  if (FImages <> nil) and FImages.IsImageNameAvailable then
      Name := FImages.GetNameByIndex(Index);
  UpdateImageIndexAndName;
end;

procedure TStyledGraphicButton.UpdateImageIndex(Name: TImageName;
  var Index: TImageIndex);
begin
  if (FImages <> nil) and FImages.IsImageNameAvailable then
      Index := FImages.GetIndexByName(Name);
  UpdateImageIndexAndName;
end;

procedure TStyledGraphicButton.SetHotImageName(const AValue: TImageName);
begin
  if AValue <> FHotImageName then
  begin
    FHotImageName := AValue;
    UpdateImageIndex(AValue, FHotImageIndex);
  end;
end;

procedure TStyledGraphicButton.SetPressedImageName(const AValue: TImageName);
begin
  if AValue <> FPressedImageName then
  begin
    FPressedImageName := AValue;
    UpdateImageIndex(AValue, FPressedImageIndex);
  end;
end;

procedure TStyledGraphicButton.SetSelectedImageName(const AValue: TImageName);
begin
  if AValue <> FSelectedImageName then
  begin
    FSelectedImageName := AValue;
    UpdateImageIndex(AValue, FSelectedImageIndex);
  end;
end;
{$ENDIF}

procedure TStyledGraphicButton.UpdateImageIndexAndName;
begin
{$IFDEF D10_4+}
  if (FImages <> nil) and FImages.IsImageNameAvailable then
  begin
    if (FImageName <> '') and (FImageIndex = -1) then
      FImageIndex := FImages.GetIndexByName(FImageName)
    else if (FImageName = '') and (FImageIndex <> -1) then
      FImageName := FImages.GetNameByIndex(FImageIndex);
    CheckImageIndexes;
  end;
{$ENDIF}
end;

procedure TStyledGraphicButton.UpdateStyleElements;
var
  LStyleClass: TStyledButtonClass;
begin
  if (StyleFamily = DEFAULT_CLASSIC_FAMILY) then
  begin
    //if StyleElements contains seClient then Update style
    //as VCL Style assigned to Button or Global VCL Style
    if (seClient in StyleElements) then
    begin
      if seBorder in StyleElements then
        StyleAppearance := DEFAULT_APPEARANCE;
      {$IFDEF D10_4+}
      LStyleClass := GetStyleName;
      if LStyleClass = '' then
      begin
        {$IFDEF D11+}
        if (csDesigning in ComponentState) then
          LStyleClass := TStyleManager.ActiveDesigningStyle.Name
        else
          LStyleClass := TStyleManager.ActiveStyle.Name;
        {$ELSE}
          LStyleClass := TStyleManager.ActiveStyle.Name;
        {$ENDIF}
      end;
      {$ELSE}
      LStyleClass := TStyleManager.ActiveStyle.Name;
      {$ENDIF}
      if LStyleClass <> FStyleClass then
      begin
        FStyleClass := LStyleClass;
        StyleApplied := ApplyButtonStyle;
      end;
    end;
  end;
  inherited;
end;

procedure TStyledGraphicButton.SetDisabledImages(const AValue: TCustomImageList);
begin
  if AValue <> FDisabledImages then
  begin
    if DisabledImages <> nil then
    begin
      DisabledImages.RemoveFreeNotification(Self);
      DisabledImages.UnRegisterChanges(FImageChangeLink);
    end;
    FDisabledImages := AValue;
    if DisabledImages <> nil then
    begin
      DisabledImages.RegisterChanges(FImageChangeLink);
      DisabledImages.FreeNotification(Self);
    end;
    UpdateImageIndexAndName;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.SetFocus;
begin
  ;
end;

procedure TStyledGraphicButton.SetHotImageIndex(const AValue: TImageIndex);
begin
  if AValue <> FHotImageIndex then
  begin
    FHotImageIndex := AValue;
    {$IFDEF D10_4+}
    UpdateImageName(AValue, FHotImageName);
    {$ENDIF}
  end;
end;

procedure TStyledGraphicButton.SetImages(const AValue: TCustomImageList);
begin
  if AValue <> FImages then
  begin
    if FImages <> nil then
    begin
      FImages.RemoveFreeNotification(Self);
      FImages.UnRegisterChanges(FImageChangeLink);
    end;
    FImages := AValue;
    if FImages <> nil then
    begin
      FImages.RegisterChanges(FImageChangeLink);
      FImages.FreeNotification(Self);
    end;
    UpdateImageIndexAndName;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.SetModalResult(const AValue: TModalResult);
begin
  if FModalResult <> AValue then
  begin
    FModalResult := AValue;
    //At design time force style of the button as defined into Family
    if csDesigning in ComponentState then
    begin
      StyleFamilyUpdateAttributesByModalResult(FModalResult,
        FStyleFamily, FStyleClass, FStyleAppearance);
      StyleApplied := ApplyButtonStyle;
    end;
  end;
end;

procedure TStyledGraphicButton.SetName(const AValue: TComponentName);
var
  LOldValue: string;
begin
  LOldValue := Caption;
  inherited;
  if LOldValue <> Caption then
    Invalidate;
end;

procedure TStyledGraphicButton.SetPressedImageIndex(const AValue: TImageIndex);
begin
  if AValue <> FPressedImageIndex then
  begin
    FPressedImageIndex := AValue;
    {$IFDEF D10_4+}
    UpdateImageName(AValue, FPressedImageName);
    {$ENDIF}
  end;
end;

procedure TStyledGraphicButton.SetButtonStyleNormal(const AValue: TStyledButtonAttributes);
begin
  if not SameStyledButtonStyle(FButtonStyleNormal, AValue) then
  begin
    FButtonStyleNormal := AValue;
  end;
end;

procedure TStyledGraphicButton.SetButtonStyle(
  const AStyleFamily: TStyledButtonFamily;
  const AStyleClass: TStyledButtonClass;
  const AStyleAppearance: TStyledButtonAppearance);
begin
  FStyleFamily := AStyleFamily;
  FStyleClass := AStyleClass;
  FStyleAppearance := AStyleAppearance;
  if not ApplyButtonStyle then
    raise EStyledButtonError.CreateFmt(ERROR_SETTING_BUTTON_STYLE,
      [AStyleFamily, AStyleClass, AStyleAppearance]);
end;

procedure TStyledGraphicButton.SetButtonStyle(const AStyleFamily: TStyledButtonFamily;
  const AModalResult: TModalResult);
begin
  FStyleFamily := AStyleFamily;
  FModalResult := AModalResult;
  StyleFamilyUpdateAttributesByModalResult(FModalResult,
    FStyleFamily, FStyleClass, FStyleAppearance);
  if not ApplyButtonStyle then
    raise EStyledButtonError.CreateFmt(ERROR_SETTING_BUTTON_STYLE,
      [FStyleFamily, FStyleClass, FStyleAppearance]);
end;

procedure TStyledGraphicButton.SetButtonStyleDisabled(
  const AValue: TStyledButtonAttributes);
begin
  if not SameStyledButtonStyle(FButtonStyleDisabled, AValue) then
  begin
    FButtonStyleDisabled := AValue;
  end;
end;

procedure TStyledGraphicButton.SetButtonStylePressed(const AValue: TStyledButtonAttributes);
begin
  if not SameStyledButtonStyle(FButtonStylePressed, AValue) then
  begin
    FButtonStylePressed := AValue;
  end;
end;

procedure TStyledGraphicButton.SetButtonStyleSelected(const AValue: TStyledButtonAttributes);
begin
  if not SameStyledButtonStyle(FButtonStyleSelected, AValue) then
  begin
    FButtonStyleSelected := AValue;
  end;
end;

procedure TStyledGraphicButton.SetButtonStyleHot(const AValue: TStyledButtonAttributes);
begin
  if not SameStyledButtonStyle(FButtonStyleHot, AValue) then
  begin
    FButtonStyleHot := AValue;
  end;
end;

procedure TStyledGraphicButton.SetImageMargins(const AValue: TImageMargins);
begin
  FImageMargins.Assign(AValue);
end;

procedure TStyledGraphicButton.SetStyleRadius(const AValue: Integer);
begin
  if FStyleRadius <> AValue then
  begin
    FStyleRadius := AValue;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.SetSelectedImageIndex(const AValue: TImageIndex);
begin
  if AValue <> FSelectedImageIndex then
  begin
    FSelectedImageIndex := AValue;
    {$IFDEF D10_4+}
    UpdateImageName(AValue, FSelectedImageName);
    {$ENDIF}
  end;
end;

procedure TStyledGraphicButton.SetStyleAppearance(
  const AValue: TStyledButtonAppearance);
var
  LValue: TStyledButtonAppearance;
begin
  LValue := AValue;
  if LValue = '' then
    LValue := DEFAULT_APPEARANCE;
  if (LValue <> Self.FStyleAppearance) or not FStyleApplied then
  begin
    Self.FStyleAppearance := LValue;
    StyleApplied := ApplyButtonStyle;
  end;
end;

procedure TStyledGraphicButton.SetStyleApplied(const AValue: Boolean);
begin
  FStyleApplied := AValue;
end;

procedure TStyledGraphicButton.SetStyleClass(
  const AValue: TStyledButtonClass);
var
  LValue: TStyledButtonClass;
begin
  LValue := AValue;
  if LValue = '' then
    LValue := DEFAULT_WINDOWS_CLASS;
  if (LValue <> Self.FStyleClass) or not FStyleApplied then
  begin
    Self.FStyleClass := LValue;
    //Using a specific Class in Classic Family force
    //StyleElements without seClient
    if (FStyleFamily = DEFAULT_CLASSIC_FAMILY) and (LValue <> DEFAULT_WINDOWS_CLASS) then
      StyleElements := StyleElements - [seClient];
    StyleApplied := ApplyButtonStyle;
  end;
end;

procedure TStyledGraphicButton.SetStyleFamily(
  const AValue: TStyledButtonFamily);
var
  LValue: TStyledButtonFamily;
begin
  LValue := AValue;
  if LValue = '' then
    LValue := DEFAULT_CLASSIC_FAMILY;
  if (LValue <> Self.FStyleFamily) or not FStyleApplied then
  begin
    FStyleFamily := LValue;
    StyleApplied := ApplyButtonStyle;
  end;
  if FStyleFamily = DEFAULT_CLASSIC_FAMILY then
    StyleElements := [seFont, seClient, seBorder];
end;

procedure TStyledGraphicButton.SetText(const AValue: TCaption);
begin
  if inherited Caption <> AValue then
  begin
    inherited Caption := AValue;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.SetWordWrap(const AValue: Boolean);
begin
  if FWordWrap <> AValue then
  begin
    FWordWrap := AValue;
    Invalidate;
  end;
end;

procedure TStyledGraphicButton.Loaded;
begin
  inherited;
  SetImageIndex(ImageIndex);
  if not FStyleApplied then
  begin
    StyleFamilyUpdateAttributesByModalResult(FModalResult,
      FStyleFamily, FStyleClass, FStyleAppearance);
    StyleApplied := ApplyButtonStyle;
  end;
end;

procedure TStyledGraphicButton.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Enabled then
  begin
    FState := bsDown;
    SetFocus;
    Invalidate;
    inherited;
  end;
end;

procedure TStyledGraphicButton.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Enabled then
  begin
    FState := bsUp;
    Invalidate;
    inherited;
  end;
end;


procedure TStyledGraphicButton.Notification(AComponent: TComponent; AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);
  if AOperation = opRemove then
  begin
    if AComponent = Images then
      Images := nil;
    if AComponent = DisabledImages then
      DisabledImages := nil;
  end;
end;

{ TGraphicButtonActionLink }

procedure TGraphicButtonActionLink.AssignClient(AClient: TObject);
begin
  inherited AssignClient(AClient);
  FClient := AClient as TStyledGraphicButton;
end;

function TGraphicButtonActionLink.IsCheckedLinked: Boolean;
begin
  Result := inherited IsCheckedLinked;
   (*and (FClient.Checked = TCustomAction(Action).Checked);*)
end;

function TGraphicButtonActionLink.IsImageIndexLinked: Boolean;
begin
  Result := inherited IsImageIndexLinked and
    (TStyledGraphicButton(FClient).ImageIndex = TStyledGraphicButton(Action).ImageIndex);
end;

{$IFDEF D10_4+}
function TGraphicButtonActionLink.IsImageNameLinked: Boolean;
begin
  Result := inherited IsImageNameLinked and
    (TStyledGraphicButton(FClient).ImageName =
      TCustomAction(Action).ImageName);
end;
{$ENDIF}

procedure TGraphicButtonActionLink.SetChecked(Value: Boolean);
begin
  inherited;
  ;
end;

procedure TGraphicButtonActionLink.SetImageIndex(Value: Integer);
begin
  inherited;
  if IsImageIndexLinked then
    TStyledGraphicButton(FClient).ImageIndex := Value;
end;

{ TStyledButton }

procedure TStyledButton.AssignTo(Dest: TPersistent);
begin
  inherited;
  if Dest is TStyledButton then
  begin
    TStyledButton(Dest).TabStop := Self.TabStop;
  end;
end;

function TStyledButton.GetCanFocus: Boolean;
begin
  if Assigned(FFocusControl) then
    Result := FFocusControl.CanFocus
  else
    Result := False;
end;

function TStyledButton.GetEnabled: Boolean;
begin
  Result := inherited GetEnabled;
end;

procedure TStyledButton.Click;
begin
  inherited;
  SetFocus;
end;

constructor TStyledButton.CreateStyled(AOwner: TComponent;
  const AFamily: TStyledButtonFamily;
  const AClass: TStyledButtonClass;
  const AAppearance: TStyledButtonAppearance);
begin
  inherited;
  FFocusControl := nil;
  CreateFocusControl(TWinControl(AOwner));
  TabStop := True;
end;

procedure TStyledButton.AdjustFocusControlPos;
begin
  //The "invisible" focus control must be positioned as the real Graphic Button Control
  if Assigned(FFocusControl) then
    FFocusControl.SetBounds(Self.Left+(Self.Width div 2), Self.Top+(Self.Height div 2), 0, 0);
end;

procedure TStyledButton.CreateFocusControl(const AParent: TWinControl);
begin
  if not Assigned(FFocusControl) then
  begin
    FFocusControl := TButtonFocusControl.Create(nil, Self);
    try
      FFocusControl.TabStop := true;
      AdjustFocusControlPos;
    except
      raise;
    end;
  end;
end;

destructor TStyledButton.Destroy;
begin
  DestroyFocusControl;
  inherited;
end;

procedure TStyledButton.DestroyFocusControl;
begin
  if Assigned(FFocusControl) then
  begin
    if Assigned(FFocusControl.Parent) then
      FreeAndNil(FFocusControl);
  end;
end;

procedure TStyledButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  AdjustFocusControlPos;
end;

procedure TStyledButton.SetEnabled(AValue: Boolean);
begin
  inherited SetEnabled(AValue);
  if Assigned(FFocusControl) then
    FFocusControl.Enabled := AValue;
end;

procedure TStyledButton.SetFocus;
begin
  if Assigned(FFocusControl) then
    if FFocusControl.CanFocus then
    FFocusControl.SetFocus;
end;

procedure TStyledButton.SetName(const AValue: TComponentName);
begin
  if Assigned(FFocusControl) then
    FFocusControl.Name := AValue;
  inherited;
end;

procedure TStyledButton.SetOnKeyDown(const AValue: TKeyEvent);
begin
  if Assigned(FFocusControl) then
    FFocusControl.OnKeyDown := AValue;
end;

procedure TStyledButton.SetOnKeyUp(const AValue: TKeyEvent);
begin
  if Assigned(FFocusControl) then
    FFocusControl.OnKeyUp := AValue;
end;

procedure TStyledButton.SetParent(AParent: TWinControl);
begin
  inherited;
  if Assigned(Self.Parent) then
  begin
    UpdateControlStyle;
    FFocusControl.Parent := Self.Parent;
    FFocusControl.Show;
  end;
end;

procedure TStyledButton.SetTabOrder(const AValue: Integer);
begin
  if Assigned(FFocusControl) then
    FFocusControl.TabOrder := AValue;
end;

procedure TStyledButton.SetTabStop(const AValue: Boolean);
begin
  FTabStop := AValue;
  if Assigned(FFocusControl) then
    FFocusControl.TabStop := AValue;
end;

procedure TStyledButton.VisibleChanging;
begin
  inherited;
  if Assigned(FFocusControl) then
  begin
    FFocusControl.Visible := not Self.Visible;
    FFocusControl.TabStop := FTabStop;
  end;
end;

function TStyledButton.GetFocused: Boolean;
begin
  if Assigned(FFocusControl) then
    Result := FFocusControl.Focused
  else
    Result := false;
end;

function TStyledButton.GetOnKeyDown: TKeyEvent;
begin
  if Assigned(FFocusControl) then
    Result := FFocusControl.OnKeyDown;
end;

function TStyledButton.GetOnKeyUp: TKeyEvent;
begin
  if Assigned(FFocusControl) then
    Result := FFocusControl.OnKeyUp;
end;

function TStyledButton.GetTabOrder: Integer;
begin
  if Assigned(FFocusControl) then
    Result := FFocusControl.TabOrder
  else
    Result := -1;
end;

function TStyledButton.GetTabStop: Boolean;
begin
  if Assigned(FFocusControl) then
    Result := FFocusControl.TabStop
  else
    Result := false;
end;

end.
