{
  Abstract mediating views for GUI list controls. This allows you to use
  standard list components and make them object-aware.  See the demo
  application for usage.
}
unit tiCompositeMediators;

{$I tiDefines.inc}

interface

uses
  Classes
  ,SysUtils
  ,tiObject
  ,ComCtrls   { TListView }
  ,Contnrs    { TObjectList }
  ,Grids      { TStringGrid }
  ;

  
type

  { Composite mediator for TListView }
  TCompositeListViewMediator = class(TtiObject)
  private
    FIsObserving: Boolean;
    FDisplayNames: string;
    FShowDeleted: Boolean;
    function    GetSelectedObject: TtiObject;
    procedure   SetSelectedObject(const AValue: TtiObject);
    procedure   SetShowDeleted(const AValue: Boolean);
    procedure   DoCreateItemMediator(AData: TtiObject);
  protected
    FView: TListView;
    FModel: TtiObjectList;
    FMediatorList: TObjectList;
    FObserversInTransit: TList;
    FSelectedObject: TtiObject;
    procedure   CreateSubMediators; virtual;
    procedure   SetupGUIandObject; virtual;
    procedure   RebuildList; virtual;
    function    DataAndPropertyValid(const AData: TtiObject): Boolean;
  public
    constructor Create; override;
    constructor CreateCustom(AModel: TtiObjectList; AView: TListView; ADisplayNames: string; IsObserving: Boolean = True);
    procedure   BeforeDestruction; override;
    procedure   Update(ASubject: TtiObject); override;
    
    { Called from the GUI to trigger events }
    procedure   HandleSelectionChanged; virtual;
  published
    property    View: TListView read FView;
    property    Model: TtiObjectList read FModel;
    property    DisplayNames: string read FDisplayNames;
    property    IsObserving: Boolean read FIsObserving;
    property    SelectedObject: TtiObject read GetSelectedObject write SetSelectedObject;
    property    ShowDeleted: Boolean read FShowDeleted write SetShowDeleted;
  end;


  { Composite mediator for TStringGrid }
  TCompositeStringGridMediator = class(TtiObject)
  private
    FDisplayNames: string;
    FIsObserving: boolean;
    FShowDeleted: Boolean;
    function    GetSelectedObjected: TtiObject;
    procedure   SetSelectedObject(const AValue: TtiObject);
    procedure   SetShowDeleted(const AValue: Boolean);
    procedure   DoCreateItemMediator(AData: TtiObject); overload;
    procedure   DoCreateItemMediator(AData: TtiObject; pRowIdx : Integer); overload;
  protected
    FView: TStringGrid;
    FModel: TtiObjectList;
    FMediatorList: TObjectList;
    procedure   CreateSubMediators; virtual;
    procedure   SetupGUIandObject; virtual;
    procedure   RebuildStringGrid; virtual;
    function    DataAndPropertyValid(const AData: TtiObject): Boolean;
  public
    constructor CreateCustom(AModel: TtiObjectList; AGrid : TStringGrid; ADisplayNames : string; IsObserving: Boolean = True);
    procedure   BeforeDestruction; override;
    procedure   Update(ASubject: TtiObject); override;
  published
    property    View: TStringGrid read FView;
    property    Model: TtiObjectList read FModel;
    property    DisplayNames: string read FDisplayNames;
    property    IsObserving: boolean read FIsObserving;
    property    ShowDeleted: Boolean read FShowDeleted write SetShowDeleted;
    property    SelectedObject: TtiObject read GetSelectedObjected write SetSelectedObject;
  end;


  { Used internally for sub-mediators in ListView mediator. Moved to interface
    section so it can be overridden. }
  TListViewListItemMediator = class(TtiObject)
  private
    FModel: TtiObject;
    FView: TListItem;
    FDisplayNames: string;
    procedure   SetupFields;
  public
    constructor CreateCustom(AModel: TtiObject; AView: TListItem; const ADisplayNames: string; IsObserving: Boolean = True);
    procedure   BeforeDestruction; override;
    procedure   Update(ASubject: TtiObject); override;
  published
    property    View: TListItem read FView;
    property    Model: TtiObject read FModel;
    property    DisplayNames: string read FDisplayNames;
  end;


  { Used internally for sub-mediators in StringGrid mediator. Moved to interface
    section so it can be overridden. }
  TStringGridRowMediator = class(TtiObject)
  private
    FDisplayNames: string;
    FView: TStringGrid;
    FModel: TtiObject;
    FRowIndex : Integer;
//    procedure   SetupFields;
  public
    constructor CreateCustom(AModel: TtiObject; AGrid: TStringGrid; ADisplayNames: string; pRowIndex: integer; IsObserving: Boolean = True);
    procedure   BeforeDestruction; override;
    procedure   Update(ASubject: TtiObject); override;
  published
    property    Model: TtiObject read FModel;
    property    View: TStringGrid Read FView;
    property    DisplayNames: string read FDisplayNames;
  end;


implementation

uses
  tiUtils
  ,StdCtrls
  ,typinfo
  ,tiExcept
  ,tiGenericEditMediators
  ;
  
const
  cFieldDelimiter = ';';
  cBrackets = '()';
  
{ Helper functions }

{ Extract the field name part from the AField string which is in the format
  fieldname(width,"field caption")   eg:  Quantity(25,"Qty")   will return: Quantity
  Width and Field Caption is optional }
function tiFieldName(const AField: string): string;
begin
  Result := tiToken(AField, cBrackets[1], 1);
end;

{ Extract the width part from the AField string which is in the format
  fieldname(width,"field caption")   eg:  Quantity(25,"Qty")  will return: 25
  Width and Field Caption is optional }
function tiFieldWidth(const AField: string): integer;
var
  s: string;
begin
  s := tiSubStr(AField, cBrackets[1], cBrackets[2], 1);
  if trim(s) = '' then
    Result := 75  // default width
  else
    Result := StrToInt(tiToken(s, ',', 1));
end;

{ Extract the field caption part from the AField string which is in the format
  fieldname(width,"field caption")   eg:  Quantity(25,"Qty")   will return: Qty
  Width and Field Caption is optional }
function tiFieldCaption(const AField: string): string;
var
  s: string;
  p: pchar;
begin
  s := tiSubStr(AField, cBrackets[1], cBrackets[2]);
  if (trim(s) = '') or (Pos(',', s) = 0) then
    // It's only got a width or is blank, so we default to field name
    Result := tiFieldName(AField)
  else
  begin
    s := tiToken(s, ',', 2);
    p := PChar(s);
    Result := AnsiExtractQuotedStr(p, '"');
  end;
end;


{ TStringGridRowMediator }

//procedure TStringGridRowMediator.SetupFields;
//begin
//  {$ifdef fpc} {$Note Add the appropriate code here} {$endif}
//end;

constructor TStringGridRowMediator.CreateCustom(AModel: TtiObject; AGrid : TStringGrid; ADisplayNames: string; pRowIndex : integer; IsObserving: Boolean);
begin
  inherited Create;
  FModel        := AModel;
  FView         := AGrid;
  FDisplayNames := ADisplayNames;
  FRowIndex     := pRowIndex;

  if IsObserving then
    FModel.AttachObserver(self);
end;

procedure TStringGridRowMediator.BeforeDestruction;
begin
  FModel.DetachObserver(self);
  FModel := nil;
  
  inherited BeforeDestruction;
end;

procedure TStringGridRowMediator.Update(ASubject: TtiObject);
var
  i : Integer;
  lField : string;
  lFieldName : string;
begin
  Assert(FModel = ASubject);

  for i := 1 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(FDisplayNames, cFieldDelimiter, i);
    lFieldName := tiFieldName(lField);
    
    FView.Cells[i, FRowIndex] := FModel.PropValue[lFieldName];
  end;
end;


{ TListViewListItemMediator }

procedure TListViewListItemMediator.SetupFields;
var
  c: integer;
  lField: string;
begin
  lField := tiToken(FDisplayNames, cFieldDelimiter, 1);
  FView.Caption := FModel.PropValue[tiFieldName(lField)];

  for c := 2 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(FDisplayNames, cFieldDelimiter, c);
    FView.SubItems.Add(FModel.PropValue[tiFieldName(lField)]);
  end;
end;

constructor TListViewListItemMediator.CreateCustom(AModel: TtiObject;
  AView: TListItem; const ADisplayNames: string; IsObserving: Boolean);
begin
  inherited Create;
  FModel        := AModel;
  FView         := AView;
  FDisplayNames := ADisplayNames;

  SetupFields;
  
  if IsObserving then
    FModel.AttachObserver(self);
end;

procedure TListViewListItemMediator.BeforeDestruction;
begin
  FModel.DetachObserver(self);
  FModel  := nil;
  FView   := nil;
  inherited BeforeDestruction;
end;

procedure TListViewListItemMediator.Update(ASubject: TtiObject);
var
  c: integer;
  lField: string;
begin
  Assert(FModel = ASubject);
  
  lField := tiToken(DisplayNames, cFieldDelimiter, 1);
  FView.Caption := FModel.PropValue[tiFieldName(lField)];

  for c := 2 to tiNumToken(DisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(DisplayNames, cFieldDelimiter, c);
    FView.SubItems[c-2] := FModel.PropValue[tiFieldName(lField)];
  end;
end;

{ TCompositeListViewMediator }

procedure TCompositeListViewMediator.SetSelectedObject(const AValue: TtiObject);
var
  i: integer;
begin
  for i := 0 to FView.Items.Count - 1 do
  begin
    if TtiObject(FView.Items[i].Data) = AValue then
    begin
      FView.Selected := FView.Items[i];
      HandleSelectionChanged;
      Exit; //==>
    end;
  end;
end;

function TCompositeListViewMediator.GetSelectedObject: TtiObject;
begin
  if FView.SelCount = 0 then
    FSelectedObject := nil
  else
    FSelectedObject := TtiObject(FView.Selected.Data);
  result := FSelectedObject;
end;

procedure TCompositeListViewMediator.SetShowDeleted(const AValue: Boolean);
begin
  if FShowDeleted = AValue then
    exit; //==>
    
  BeginUpdate;
  try
    FShowDeleted := AValue;
    RebuildList;
  finally
    EndUpdate;
  end;
end;

procedure TCompositeListViewMediator.DoCreateItemMediator(AData: TtiObject);
var
  li: TListItem;
  m: TListViewListItemMediator;
begin
  DataAndPropertyValid(AData);
  
  { Create ListItem and Mediator }
  li        := FView.Items.Add;
  li.Data   := AData;
  m         := TListViewListItemMediator.CreateCustom(AData, li, FDisplayNames, FIsObserving);
  FMediatorList.Add(m);
end;

procedure TCompositeListViewMediator.CreateSubMediators;
var
  c: integer;
  lc: TListColumn;
  lField: string;
begin
  { Create column headers }
  for c := 1 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lc            := FView.Columns.Add;
    lc.AutoSize   := False;
    lField        := tiToken(FDisplayNames, cFieldDelimiter, c);
    lc.Caption    := tiFieldCaption(lField);
    lc.Width      := tiFieldWidth(lField);
  end;

  FModel.ForEach(DoCreateItemMediator, FShowDeleted);
end;

procedure TCompositeListViewMediator.SetupGUIandObject;
begin
  { Setup TListView defaults }
  FView.Columns.Clear;
  FView.Items.Clear;
  FView.ViewStyle         := vsReport;
  FView.ShowColumnHeaders := True;
  FView.RowSelect         := True;
  {$IFDEF FPC}
  FView.AutoSize          := False;
  FView.ScrollBars        := ssAutoBoth;
  {$ENDIF}
end;

procedure TCompositeListViewMediator.RebuildList;
begin
  { This rebuilds the whole list. Not very efficient. You can always override
    this in your mediators to create a more optimised rebuild. }
  {$ifdef fpc}
  View.BeginUpdate;
  {$else}
  View.Items.BeginUpdate;
  {$endif}
  try
    FMediatorList.Clear;
    View.Columns.Clear;
    View.Items.Clear;
    CreateSubMediators;
  finally
  {$ifdef fpc}
  View.EndUpdate;
  {$else}
  View.Items.EndUpdate;
  {$endif}
  end;
end;

function TCompositeListViewMediator.DataAndPropertyValid(const AData: TtiObject): Boolean;
var
  c: integer;
  lField: string;
begin
  result := (FModel <> nil) and (FDisplayNames <> '');
  if not result then
    Exit; //==>

  for c := 1 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(FDisplayNames, cFieldDelimiter, c);
    { WRONG!!  We should test the items of the Model }
    result := (IsPublishedProp(AData, tiFieldName(lField)));
    if not result then
      raise Exception.CreateFmt('<%s> is not a property of <%s>',
                               [tiFieldName(lField), AData.ClassName ]);
  end;
end;

constructor TCompositeListViewMediator.Create;
begin
  inherited Create;
  FObserversInTransit := TList.Create;
end;

constructor TCompositeListViewMediator.CreateCustom(AModel: TtiObjectList;
  AView: TListView; ADisplayNames: string; IsObserving: Boolean);
begin
  Create; // don't forget this
  
  FModel        := AModel;
  FView         := AView;
  FMediatorList := TObjectList.Create;
  FIsObserving  := IsObserving;
  FDisplayNames := ADisplayNames;
  FShowDeleted  := False;
  
  SetupGUIandObject;

  { TODO: This must be improved. If no ADisplayNames value maybe default to a
   single column listview using the Caption property }
  if (ADisplayNames <> '') and (tiNumToken(ADisplayNames, cFieldDelimiter) > 0) then
  begin
    CreateSubMediators;
  end;
    
  if IsObserving then
    FModel.AttachObserver(self);
end;

procedure TCompositeListViewMediator.BeforeDestruction;
begin
  FObserversInTransit.Free;
  FMediatorList.Free;
  FModel.DetachObserver(self);
  FModel  := nil;
  FView   := nil;
  inherited BeforeDestruction;
end;

procedure TCompositeListViewMediator.Update(ASubject: TtiObject);
begin
  Assert(FModel = ASubject);
  RebuildList;
end;

{ TODO: This is not working 100% yet. Be warned! }
procedure TCompositeListViewMediator.HandleSelectionChanged;
var
  i: integer;
begin
  if View.SelCount = 0 then
    FSelectedObject := nil
  else
  begin
    FObserversInTransit.Clear;
    { If an item is already selected, assign the item's List of observers to a
      temporary container. This is done so that the same observers can be
      assigned to the new item. }
    if Assigned(FSelectedObject) then
      FObserversInTransit.Assign(FSelectedObject.ObserverList);

    // Assign Newly selected item to SelectedObject Obj.
    FSelectedObject := TtiObject(View.Selected.Data);

    { If an object was selected, copy the old item's observer List
      to the new item's observer List. }
    if FObserversInTransit.Count > 0 then
      FSelectedObject.ObserverList.Assign(FObserversInTransit);

    { Set the Observers Subject property to the selected object }
    for i := 0 to FSelectedObject.ObserverList.Count - 1 do
    begin
      TMediatorView(FSelectedObject.ObserverList.Items[i]).Subject :=
          FSelectedObject;
    end;

    // execute the NotifyObservers event to update the observers.
    FSelectedObject.NotifyObservers;
  end;
end;

{ TCompositeStringGridMediator }

function TCompositeStringGridMediator.GetSelectedObjected: TtiObject;
begin
  if FView.Selection.Top = 0 then
    Result := nil
  else
    Result := TtiObject(FView.Objects[1, FView.Selection.Top]);
end;

procedure TCompositeStringGridMediator.SetSelectedObject(const AValue: TtiObject);
var
  i : integer;
begin
  for i := 1 to FView.RowCount - 1 do
  begin
    if TtiObject(FView.Objects[1, i]) = AValue then
    begin
    
      FView.Row := i;
      Exit; //==>
    end;
  end;
end;

procedure TCompositeStringGridMediator.SetShowDeleted(const AValue: Boolean);
begin
  if FShowDeleted = AValue then
    Exit; //==>
  
  BeginUpdate;
  try
    FShowDeleted := AVAlue;

    RebuildStringGrid;
  finally
    EndUpdate;
  end;
end;

procedure TCompositeStringGridMediator.DoCreateItemMediator(AData: TtiObject);
begin
  DataAndPropertyValid(AData);
end;

procedure TCompositeStringGridMediator.DoCreateItemMediator(AData: TtiObject; pRowIdx: Integer);
var
  i: Integer;
  lField: string;
  lFieldName: string;
  lMediatorView: TStringGridRowMediator;
begin
  FView.Objects[1, pRowIdx + 1] := AData;
  for i := 1 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(FDisplayNames, cFieldDelimiter, i);
    lFieldName := tiFieldName(lField);
    FView.Cells[i, pRowIdx + 1] := AData.PropValue[lFieldName];
    
    lMediatorView := TStringGridRowMediator.CreateCustom(AData, FView, FDisplayNames, pRowIdx +  1, FIsObserving);
    FMediatorList.Add(lMediatorView);
  end;
end;


procedure TCompositeStringGridMediator.CreateSubMediators;
var
  i: integer;
  lField: string;
  lColumnTotalWidth: integer;
begin
  lColumnTotalWidth:= 0;
  for i := 1 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(FDisplayNames, cFieldDelimiter, i);
    FView.Cells[i, 0]   := tiFieldCaption(lField);
    FView.ColWidths[i]  := tiFieldWidth(lField);

    //resize the last column to fill the grid.
    if i = tiNumToken(FDisplayNames, cFieldDelimiter) then
      FView.ColWidths[i] := FView.width - lColumnTotalWidth + 10
    else
      lColumnTotalWidth := lColumnTotalWidth + FView.ColWidths[i] + 20;
  end;
  
  for i := 0 to FModel.Count - 1 do
  begin
    if not FModel.Items[i].Deleted or FShowDeleted then
    begin
      DoCreateItemMediator(FModel.Items[i], i);
    end;
  end;
end;

procedure TCompositeStringGridMediator.SetupGUIandObject;
begin
  //Setup default properties for the StringGrid
  {$ifdef fpc}
  FView.Clear;
  FView.Columns.Clear;
  {$endif}
  FView.Options       := FView.Options + [goRowSelect];
  FView.ColCount      := tiNumToken(FDisplayNames, cFieldDelimiter) + 1;
  FView.RowCount      := FModel.Count + 1;
  FView.FixedCols     := 1;
  FView.FixedRows     := 1;
  FView.ColWidths[0]  := 20;
  
  {$IFDEF FPC}
  FView.AutoSize := False;
  FView.ScrollBars := ssAutoBoth;
  {$ENDIF}
end;

procedure TCompositeStringGridMediator.RebuildStringGrid;
begin
  { Do nothing. Can be implement as you see fit. A simple example is given
    in the Demos/GenericMediatingViews/Composite_ListView_Mediator }
  raise EtiOPFProgrammerException.Create('You are trying to call ' + Classname
    + '.RebuildStringGrid, which must be overridden in the concrete class.');
end;

function TCompositeStringGridMediator.DataAndPropertyValid(const AData: TtiObject): Boolean;
var
  i: Integer;
  lField: string;
begin
  Result := (FModel <> nil) and (FDisplayNames <> '');
  
  if not Result then
    Exit; //==>

  for i := 1 to tiNumToken(FDisplayNames, cFieldDelimiter) do
  begin
    lField := tiToken(FDisplayNames, cFieldDelimiter, i);
    Result := IsPublishedProp(AData, tiFieldName(lField));
    
    if not Result then
      raise Exception.CreateFmt('<%s> is not a property of <%s>',
            [tiFieldName(lField), AData.ClassName]);
  end;
end;

constructor TCompositeStringGridMediator.CreateCustom(AModel: TtiObjectList;
  AGrid: TStringGrid; ADisplayNames: string; IsObserving: Boolean);
begin
  inherited Create;
  
  FModel        := AModel;
  FView         := AGrid;
  FMediatorList := TObjectList.Create;
  FIsObserving  := IsObserving;
  FDisplayNames := ADisplayNames;
  FShowDeleted  := False;
  
  SetupGUIandObject;
  
  if (FDisplayNames <> '') and (tiNumToken(ADisplayNames, cFieldDelimiter) > 0) then
  begin
    CreateSubMediators;
  end;

  if IsObserving then
    FModel.AttachObserver(Self);
end;

procedure TCompositeStringGridMediator.BeforeDestruction;
begin
  FMediatorList.Free;
  FModel.DetachObserver(Self);
  FModel  := nil;
  FView   := nil;
  
  inherited BeforeDestruction;
end;

procedure TCompositeStringGridMediator.Update(ASubject: TtiObject);
begin
  Assert(FModel = ASubject);
  RebuildStringGrid;
end;

end.

