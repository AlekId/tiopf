
(* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
The contents of this file are subject to the Mozilla Public
License Version 1.1 (the "License"); you may not use this file
except in compliance with the License. You may obtain a copy of
the License at http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS
IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
implied. See the License for the specific language governing
rights and limitations under the License.

If you make any changes or enhancements, which you think will
benefit other developers and will not break any existing code,
please forward your changes (well commented) to graemeg@gmail.com
and I will make them permanent.

Revision history:

  2005-08-17: First release by Graeme Geldenhuys (graemeg@gmail.com)

Purpose:
  Abstract mediating view and Mediator Factory. This allows you to use
  standard edit components and make them object-aware.  See the demo
  application for usage.

ToDo:
  * Implement container controls. eg: TTreeview and Virtual TreeView
  * Unit tests
  * More refactoring
  * Implement a View Manager class, so we can remove the View Lists
    created in each Form using mediating views.

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *)

unit tiGenericEditMediators;

{$I tiDefines.inc}

interface
uses
  tiObject
  ,Controls
  ,Classes
  ,StdCtrls   { TEdit, TComboBox }
  ;

type
  TMediatingViewClass = class of TMediatorView;

  { Base class to inherit from to make more customised Mediator Views. }
  TMediatorView = class(TtiObject)
  private
    FSettingUp: Boolean;
    FFieldName: string;
    FSubject: TtiObject;
    FEditControl: TControl;
    FGuiFieldName: string;
    FErrorMessage: string;
    procedure   TestIfValid;
  protected
    UseInternalOnChange: boolean;
    function    GetSubject: TtiObject; virtual;
    { Used to setup things like the MaxLength of a edit box, etc. }
    procedure   SetupGUIandObject; virtual;
    { Used for doing validation checks and changing the color of edit controls
      in error }
    procedure   UpdateGuiValidStatus(pErrors: TtiObjectErrors); virtual;
    function    DataAndPropertyValid: Boolean;
    procedure   DoOnChange(Sender: TObject); virtual;
  public
    constructor Create; override;
    constructor CreateCustom( pEditControl: TControl; pSubject: TtiObject; pFieldName: string; pGuiFieldName: string = '' );
    destructor  Destroy; override;
    { Copies values from the edit control to the Subject }
    procedure   GuiToObject; virtual;
    { Copies property values from the Subject to the edit control }
    procedure   ObjectToGui; virtual;
    procedure   Update(pSubject: TtiObject); override;
    { This is what gets called from the edit controls OnChange event, to
      trigger a update }
    procedure   GUIChanged;
    { The object being edited or observed }
    property    Subject: TtiObject read GetSubject write FSubject;
    { The edit control used for editing a property of the Subject }
    property    EditControl: TControl read FEditControl write FEditControl;
    { Not being used at the moment }
    property    ErrorMessage: string read FErrorMessage write FErrorMessage;
    class function ComponentClass: TClass; virtual; abstract;
  published
    { Property of the Subject being edited }
    property    FieldName: string read FFieldName write FFieldName;
    { Property of the edit control used to get/set the new updated value }
    property    GuiFieldName: string read FGuiFieldName write FGuiFieldName;
  end;


  { Base class to handle TEdit controls }
  TMediatorEditView = class(TMediatorView)
  public
    class function ComponentClass: TClass; override;
  end;


  { Base class to handle TSpinEdit controls }
  TMediatorSpinEditView = class(TMediatorView)
  private
    procedure   OnLostFocus(Sender: TObject);
  protected
    procedure   SetupGUIandObject; override;
  public
    class function ComponentClass: TClass; override;
    procedure   GuiToObject; override;
  end;


  { Base class to handle TTrackBar controls }
  TMediatorTrackBarView = class(TMediatorView)
  public
    class function ComponentClass: TClass; override;
  end;


  { Base class to handle TComboBox controls }
  TMediatorComboBoxView = class(TMediatorView)
  private
    function    GetEditControl: TComboBox;
    procedure   SetEditControl(const AValue: TComboBox);
  public
    property    EditControl: TComboBox read GetEditControl write SetEditControl;
    procedure   ObjectToGui; override;
    class function ComponentClass: TClass; override;
  end;
  

  { TComboBox observing a list and setting a Object property }
  TMediatorDynamicComboBoxView = class(TMediatorComboBoxView)
  private
    FList: TtiObjectList;
    FExternalOnChange: TNotifyEvent;
    procedure   SetList(const AValue: TtiObjectList);
    procedure   InternalListRefresh;
  protected
    procedure   SetOnChangeActive(AValue: Boolean); virtual;
    procedure   SetupGUIandObject; override;
  public
    constructor CreateCustom(pList: TtiObjectList; pEditControl: TControl; pSubject: TtiObject; pFieldName: string); reintroduce;
    destructor  Destroy; override;
    procedure   GuiToObject; override;
    procedure   ObjectToGui; override;
    property    List: TtiObjectList read FList write SetList;
  end;
  

  { Base class to handle TMemo controls }
  TMediatorMemoView = class(TMediatorView)
  protected
    procedure   SetupGUIandObject; override;
  public
    class function ComponentClass: TClass; override;
    procedure   ObjectToGui; override;
    procedure   GuiToObject; override;
  end;


  { Data class for mapping a name to a class }
  TMediatorViewMapping = class(TObject)
  private
    FMediatingViewClass: TMediatingViewClass;
    FName: string;
  public
    constructor CreateExt( pName: String; pMediatingClass: TMediatingViewClass );
    property    Name: string read FName write FName;
    property    MediatingViewClass: TMediatingViewClass read FMediatingViewClass write FMediatingViewClass;
  end;


  { This is a parameter object, instead of a whole bunch of single parameters }
  TMGMEditLink = class(TObject)
  private
    FEditControl: TControl;
    FEditObject: TtiObject;
    FObjectEditProperty: string;
    FControlEditProperty: string;
  public
    property    EditControl: TControl read FEditControl write FEditControl;
    property    EditObject: TtiObject read FEditObject write FEditObject;
    property    ObjectEditProperty: string read FObjectEditProperty write FObjectEditProperty;
    property    ControlEditProperty: string read FControlEditProperty write FControlEditProperty;
  end;


  { Factory class to register and create your mediating views }

  { TMediatorFactory }

  TMediatorFactory = class(TObject)
  private
    MappingList: TStringList;
    function    FindMediatorClass(pSubject: TtiObject; pComponentClass: TClass; pFieldName: string): TMediatingViewClass;
    function    GetMediatorClass(pSubject: TtiObject; pComponentClass: TClass; pFieldName: string): TMediatingViewClass;
  public
    constructor Create;
    destructor  Destroy; override;
    function    CreateMediator(pComponent: TControl; pSubject: TtiObject; pFieldName: String; pGuiFieldName: string): TMediatorView; overload;
    function    CreateMediator(pEditLink: TMGMEditLink): TMediatorView; overload;
//    function    FindMediator(pComponent: TControl): TMediatorView;
    procedure   RegisterMediatorClass(FieldName: string; MediatorClass: TMediatingViewClass);
  end;


  { Simple singelton for the Factory }
  function gMediatorFactory: TMediatorFactory;


implementation
uses
  SysUtils
  ,TypInfo
  ,tiExcept
  ,Dialogs    { MessageDlg }
  {$IFDEF FPC}
  ,Spin       { TSpinEdit - standard component included in Lazarus LCL }
  {$ELSE}
  ,tiSpin     { TSpinEdit - tiSpin.pas cloned from Borland's Spin.pas so remove package import warning}
  {$ENDIF}
  ,ComCtrls   { TTrackBar }
  ;

var
  uMediatorFactory: TMediatorFactory;
  
  
const
  cErrorListHasNotBeenAssigned   = 'List has not been assigned';


function gMediatorFactory: TMediatorFactory;
begin
  if not Assigned(uMediatorFactory) then
    uMediatorFactory := TMediatorFactory.Create;
  result := uMediatorFactory;
end;


{ TMediatorView }

constructor TMediatorView.Create;
begin
  inherited;
  FSettingUp := True;
  UseInternalOnChange := True;
end;


constructor TMediatorView.CreateCustom(pEditControl: TControl; pSubject: TtiObject; pFieldName: string; pGuiFieldName: string);
begin
  Create;
  FSubject        := pSubject;
  FFieldName      := pFieldName;
  FGuiFieldName   := pGuiFieldName;
  FEditControl    := pEditControl;
  FSubject.AttachObserver(self);
  SetupGUIandObject;
  
  // I prefer to do this once in the form after all mediator are created.
//  FSubject.NotifyObservers;
  FSettingUp      := False;
end;

destructor TMediatorView.Destroy;
begin
  FSubject.DetachObserver(self);
  inherited Destroy;
end;


procedure TMediatorView.GUIChanged;
begin
  if not FSettingUp then
  begin
    GuiToObject;
    TestIfValid;
  end;
end;


procedure TMediatorView.UpdateGuiValidStatus(pErrors: TtiObjectErrors);
begin
  { This will be implemented by a concrete class }
end;

function TMediatorView.DataAndPropertyValid: Boolean;
begin
  result := (FSubject <> nil) and (FFieldName <> '');
  if not result then
    Exit; //==>

  result := (IsPublishedProp(FSubject, FFieldName));

  if not result then
    raise Exception.CreateFmt('<%s> is not a property of <%s>',
                               [FFieldName, FSubject.ClassName ]);

//  EditControl.ReadOnly := ReadOnly or IsPropReadOnly;
end;

procedure TMediatorView.DoOnChange(Sender: TObject);
begin
  GUIChanged;
end;


procedure TMediatorView.TestIfValid;
var
  Errors: TtiObjectErrors;
begin
  Errors := TtiObjectErrors.Create;
  try
    Subject.IsValid(Errors);
    UpdateGuiValidStatus( Errors );
  finally
    Errors.Free;
  end;
end;


procedure TMediatorView.Update(pSubject: TtiObject);
begin
  inherited;
  ObjectToGui;
  TestIfValid;
end;


function TMediatorView.GetSubject: TtiObject;
begin
  Result := FSubject;
end;


procedure TMediatorView.GuiToObject;
begin
  Subject.PropValue[FieldName] := TypInfo.GetPropValue((FEditControl as ComponentClass), GuiFieldName);
end;


procedure TMediatorView.ObjectToGui;
begin
  TypInfo.SetPropValue( (FEditControl as ComponentClass), GuiFieldName,
      Subject.PropValue[FieldName]);
end;


procedure TMediatorView.SetupGUIandObject;
begin
  { do nothing here }
end;


{ TMediatorFactory }

constructor TMediatorFactory.Create;
begin
  MappingList := TStringList.Create;
end;


function TMediatorFactory.CreateMediator(pComponent: TControl; pSubject: TtiObject;
    pFieldName: string; pGuiFieldName: string): TMediatorView;
var
  MediatorClass: TMediatingViewClass;
begin
  if not Assigned(pComponent) then
    raise Exception.Create('TMediatorFactory.CreateMediator: pComponent is not assigned');
  if not Assigned(pSubject) then
    raise Exception.Create('TMediatorFactory.CreateMediator: pSubject is not assigned');

  MediatorClass := GetMediatorClass(
                      pSubject,
                      pComponent.ClassType,
                      pFieldName );
  result        := MediatorClass.CreateCustom(
                      pComponent,
                      pSubject,
                      pFieldName,
                      pGuiFieldName );
  pSubject.AttachObserver( result );
end;


function TMediatorFactory.CreateMediator(pEditLink: TMGMEditLink): TMediatorView;
var
  MediatorClass: TMediatingViewClass;
begin
  MediatorClass := GetMediatorClass(
                      pEditLink.EditObject,
                      pEditLink.EditControl.ClassType,
                      pEditLink.ObjectEditProperty );
  result        := MediatorClass.CreateCustom(
                      pEditLink.EditControl,
                      pEditLink.EditObject,
                      pEditLink.ObjectEditProperty,
                      pEditLink.ControlEditProperty );
  pEditLink.EditObject.AttachObserver( Result );
end;


destructor TMediatorFactory.Destroy;
var
  i: integer;
begin
  for i := 0 to MappingList.Count -1 do
    TObject(MappingList.Objects[i]).Free;
  MappingList.Free;
  inherited;
end;


function TMediatorFactory.FindMediatorClass(pSubject: TtiObject; pComponentClass: TClass; pFieldName: string): TMediatingViewClass;
const
  cName = '%s.%s.%s';    { Subject Classname, FieldName, Edit control name }
var
  i: Integer;
  lName: string;
begin
  { Get the name formatting correct }
  lName := Format(cName, [UpperCase(pSubject.ClassName), UpperCase(pFieldName), UpperCase(pComponentClass.ClassName)]);
  { Does the Type exist in the list? }
  i := MappingList.IndexOf( lName );
  if i <> -1 then
    Result := TMediatorViewMapping(MappingList.Objects[i]).MediatingViewClass
  else
    Result := nil;
end;


function TMediatorFactory.GetMediatorClass(pSubject: TtiObject; pComponentClass: TClass; pFieldName: string): TMediatingViewClass;
begin
  Result := FindMediatorClass(pSubject, pComponentClass, pFieldName);
  if not Assigned(Result) then
    raise Exception.Create('No mediator registered for:' + #13#10 +
        '  Component: ' + pComponentClass.ClassName + #13#10 +
        '  FieldName: ' + pSubject.ClassName + '.' + pFieldName);
end;


procedure TMediatorFactory.RegisterMediatorClass(FieldName: string; MediatorClass: TMediatingViewClass);
const
  cName = '%s.%s';
var
  lName: String;
  i: Integer;
  lMapping: TMediatorViewMapping;
begin
  lName := Format(cName, [UpperCase(FieldName), UpperCase(MediatorClass.ComponentClass.ClassName)]);
  { Does the Medator mapping already exist? }
  i := MappingList.IndexOf( lName );
  if i <> -1 then
  begin   { If yes, notify the user }
    { We cannot raise an exception as this will be called in the Initialization
      section of a unit. Delphi's exception handling may not have been loaded yet! }
    MessageDlg('Registering a duplicate Mediator View Type <' + FieldName + '> with ' + ClassName,
        mtInformation, [mbOK], 0);
  end
  else
  begin   { If no, then add it to the list }
    lMapping := TMediatorViewMapping.CreateExt( lName, MediatorClass );
    MappingList.AddObject( lName, lMapping );
  end;
end;


{ TMediatorEditView }

class function TMediatorEditView.ComponentClass: TClass;
begin
  Result := TEdit;
end;


{ TMediatorSpinEditView}

class function TMediatorSpinEditView.ComponentClass: TClass;
begin
  Result := TSpinEdit;
end;


procedure TMediatorSpinEditView.GuiToObject;
begin
  { Control is busy clearing the value before replacing it with what the user
    typed. }
  if (TSpinEdit(EditControl).Text = '') then
    Exit; //==>
//  try
//    if (TSpinEdit(EditControl).Text = '') and (TSpinEdit(EditControl).Value = 0) then
//      Exit; //==>
//  except
//    on EConvertError do
//      begin
//        if (TSpinEdit(EditControl).Text = '') then
//          Exit; //==>
//      end;
//  end;

  { continue as normal }
  inherited;
end;


procedure TMediatorSpinEditView.OnLostFocus(Sender: TObject);
begin
  if (TSpinEdit(EditControl).Text = '') then
  begin
    { Default the EditControl to a valid value }
    TSpinEdit(EditControl).Value := 0;
    GUIChanged;
  end;
end;


procedure TMediatorSpinEditView.SetupGUIandObject;
begin
  inherited;
  TSpinEdit(EditControl).OnExit := OnLostFocus;
end;


{ TMediatorSpinEditView}

class function TMediatorTrackBarView.ComponentClass: TClass;
begin
  Result := TTrackBar;
end;


{ TMediatorComboBoxView }

class function TMediatorComboBoxView.ComponentClass: TClass;
begin
  Result := TComboBox;
end;

function TMediatorComboBoxView.GetEditControl: TComboBox;
begin
  result := TComboBox(FEditControl);
end;

procedure TMediatorComboBoxView.SetEditControl(const AValue: TComboBox);
begin
  FEditControl := AValue;
end;

procedure TMediatorComboBoxView.ObjectToGui;
begin
  EditControl.ItemIndex :=
      EditControl.Items.IndexOf(Subject.PropValue[FieldName]);
end;


{ TMediatorMemoView }

class function TMediatorMemoView.ComponentClass: TClass;
begin
  Result := TMemo;
end;


procedure TMediatorMemoView.GuiToObject;
begin
  Subject.PropValue[ FieldName ] := TMemo(EditControl).Lines.Text;
end;


procedure TMediatorMemoView.ObjectToGui;
begin
  TMemo(EditControl).Lines.Text := Subject.PropValue[ FieldName ];
end;


procedure TMediatorMemoView.SetupGUIandObject;
begin
  inherited;
  TMemo(EditControl).ScrollBars := ssVertical;
  TMemo(EditControl).WordWrap   := True;
end;


{ TMediatorViewMapping }

constructor TMediatorViewMapping.CreateExt(pName: String; pMediatingClass: TMediatingViewClass);
begin
  Create;
  Name                := pName;
  MediatingViewClass  := pMediatingClass;
end;


{ TMediatorDynamicComboBoxView }

procedure TMediatorDynamicComboBoxView.SetList(const AValue: TtiObjectList);
begin
  if FList = AValue then
    Exit; //==>

  FList := AValue;

  InternalListRefresh;
end;

procedure TMediatorDynamicComboBoxView.InternalListRefresh;
var
  lItems: TStrings;
  i: Integer;
  v: variant;
begin
  lItems := EditControl.Items;
  lItems.Clear;

  if (FList = nil) or
     (FList.Count < 1) or
     (SameText(FFieldName, EmptyStr)) then
    Exit; //==>

  try
    for i := 0 to FList.Count - 1 do
    begin
      lItems.Add(FList.Items[i].Caption);
    end;
  except
    on E: Exception do
      raise Exception.CreateFmt('Error adding list items to combobox ' +
                                 'Message: %s, Item Property Name: %s',
                                 [E.message, FFieldName]);
  end;

  ObjectToGui;
end;

procedure TMediatorDynamicComboBoxView.SetOnChangeActive(AValue: Boolean);
begin
  if AValue then
  begin
    if not UseInternalOnChange then
      EditControl.OnChange := FExternalOnChange
    else
      EditControl.OnChange := DoOnChange;
  end
  else
  begin
    if not UseInternalOnChange then
      FExternalOnChange := EditControl.OnChange;
    EditControl.OnChange := nil;
  end;
end;

procedure TMediatorDynamicComboBoxView.SetupGUIandObject;
begin
  inherited SetupGUIandObject;

  if UseInternalOnChange then
    EditControl.OnChange := DoOnChange; // default OnChange event handler

  EditControl.ReadOnly  := True;
  EditControl.Style     := csDropDownList;  // combos are meant for selection not typing
  EditControl.Enabled   := (FList.Count > 0);
end;

constructor TMediatorDynamicComboBoxView.CreateCustom(pList: TtiObjectList;
  pEditControl: TControl; pSubject: TtiObject; pFieldName: string);
begin
  Create;
  FGuiFieldName   := 'Text';    // TComboBox defaults to Text property

  FSubject        := pSubject;
  FFieldName      := pFieldName;
  FEditControl    := pEditControl;
  
  if Assigned(EditControl.OnChange) then
    UseInternalOnChange := False;

  { This will fire a refresh }
  List := pList;

  FSubject.AttachObserver(self);
  SetupGUIandObject;

  // I prefer to do this once in the form after all mediator are created.
//  FSubject.NotifyObservers;
  FSettingUp      := False;
end;

destructor TMediatorDynamicComboBoxView.Destroy;
begin
  FList := nil;
  inherited Destroy;
end;

procedure TMediatorDynamicComboBoxView.GuiToObject;
var
  lValue: TtiObject;
  lPropType: TTypeKind;
begin
  if not DataAndPropertyValid then
    Exit; //==>
  if EditControl.ItemIndex < 0 then
    Exit; //==>

  lValue := TtiObject(FList.Items[EditControl.ItemIndex]);

  lPropType := typinfo.PropType(Subject, FieldName);
  if lPropType = tkClass then
    typinfo.SetObjectProp(Subject, FieldName, lValue)
  else
    raise EtiOPFProgrammerException.Create('Error property type not a Class');
end;

procedure TMediatorDynamicComboBoxView.ObjectToGui;
var
  i: Integer;
  lValue: TtiObject;
  lPropType: TTypeKind;
begin
  SetOnChangeActive(false);

  //  Set the index only (We're assuming the item is present in the list)
  EditControl.ItemIndex := -1;
  if FSubject = nil then
    Exit; //==>

  if not Assigned(FList) then
    raise EtiOPFProgrammerException.Create(cErrorListHasNotBeenAssigned);

  lPropType := typinfo.PropType(Subject, FieldName);
  if lPropType = tkClass then
    lValue := TtiObject(typinfo.GetObjectProp(Subject, FieldName))
  else
    raise Exception.Create('Property is not a class type!');

  for i := 0 to FList.Count - 1 do
    if FList.Items[i] = lValue then
    begin
      EditControl.ItemIndex := i;
      Break; //==>
    end;

  SetOnChangeActive(true);
end;

initialization
finalization
  gMediatorFactory.Free;

end.

