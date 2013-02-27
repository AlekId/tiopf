unit Client_BOM;

interface
uses
  tiPtnVisPerObj
  ,Classes
  ;

const
  cErrorClientName    = 'Please enter a client name' ;
  cErrorClientSource  = 'Please select a client source' ;

type

  TClientSources = class ;
  TClientSource  = class ;
  TClient        = class ;
  TClients       = class ;

  TClientName = String[200];

  TClients = class( TPerObjList )
  private
  protected
    function    GetItems(i: integer): TClient ; reintroduce ;
    procedure   SetItems(i: integer; const Value: TClient); reintroduce ;
  public
    property    Items[i:integer] : TClient read GetItems write SetItems ;
    procedure   Add( pObject : TClient   ; pDefDispOrdr : boolean = true ) ; reintroduce ;
  published
  end ;

  TClient = class( TPerObjAbs )
  private
    FClientName: TClientName;
    FClientSource: TClientSource;
    function    GetClientSouceAsGUIString: string;
    function    GetClientSourceOIDAsString: string;
    procedure   SetClientSourceAsGUIString(const Value: string);
    procedure   SetClientSourceOIDAsString(const Value: string);
  protected
    function    GetOwner: TClients; reintroduce ;
    procedure   SetOwner(const Value: TClients ); reintroduce ;
  public
    constructor create ; override ;
    property    Owner       : TClients             read GetOwner      write SetOwner ;
    function    IsValid( const pErrors : TPerObjErrors ) : boolean ; override ;
    property    ClientSource : TClientSource read FClientSource write FClientSource ;
  published
    property    ClientName : TClientName read FClientName write FClientName ;
    property    ClientSourceOIDAsString  : string read GetClientSourceOIDAsString write SetClientSourceOIDAsString ;
    property    ClientSourceAsGUIString  : string read GetClientSouceAsGUIString  write SetClientSourceAsGUIString ;
  end ;

  //----------------------------------------------------------------------------
  TClientSources = class( TPerObjList )
  private
  protected
    function    GetItems(i: integer): TClientSource ; reintroduce ;
    procedure   SetItems(i: integer; const Value: TClientSource); reintroduce ;
  public
    property    Items[i:integer] : TClientSource read GetItems write SetItems ;
    procedure   Add( pObject : TClientSource   ; pDefDispOrdr : boolean = true ) ; reintroduce ;
    function    Find( pOIDToFindAsString : string ) : TClientSource ;  reintroduce ;
    function    FindByDisplayText(const pValue : string ) : TClientSource ;
    function    Unknown : TClientSource ;
  published
  end ;

  //----------------------------------------------------------------------------
  TClientSource = class( TPerObjAbs )
  private
    FDisplayText: string;
  protected
    function    GetOwner: TClientSources; reintroduce ;
    procedure   SetOwner(const Value: TClientSources ); reintroduce ;
  public
    property    Owner       : TClientSources             read GetOwner      write SetOwner ;
  published
    property    DisplayText : string read FDisplayText write FDisplayText ;
  end ;

procedure RegisterMappings ;
function  gClientSources : TClientSources ;

implementation
uses
  tiPersist
  ,tiClassToDBMap_BOM
  ,SysUtils
  ;

var
  uClientSources : TClientSources ;


procedure RegisterMappings ;
begin
  gTIPerMgr.ClassDBMappingMgr.RegisterMapping(TClientSource, 'Client_Source', 'OID', 'OID', [pktDB] );
  gTIPerMgr.ClassDBMappingMgr.RegisterMapping(TClientSource, 'Client_Source', 'DisplayText', 'Display_Text' );
  gTIPerMgr.ClassDBMappingMgr.RegisterCollection(TClientSources, TClientSource);

  gTIPerMgr.ClassDBMappingMgr.RegisterMapping(TClient, 'Client', 'OID', 'OID', [pktDB] );
  gTIPerMgr.ClassDBMappingMgr.RegisterMapping(TClient, 'Client', 'ClientName', 'Client_Name' );
  gTIPerMgr.ClassDBMappingMgr.RegisterMapping(TClient, 'Client', 'ClientSourceOIDAsString', 'Client_Source' ) ;
  gTIPerMgr.ClassDBMappingMgr.RegisterCollection(TClients, TClient);
end ;

function  gClientSources : TClientSources ;
begin
  if uClientSources = nil then
  begin
    uClientSources := TClientSources.Create ;
    uClientSources.Read ;
  end;
  result := uClientSources;
end ;

{ TClients }

procedure TClients.Add(pObject: TClient; pDefDispOrdr: boolean);
begin
  inherited Add( pObject, pDefDispOrdr ) ;
end;

function TClients.GetItems(i: integer): TClient;
begin
  result := TClient( inherited GetItems( i )) ;
end;

procedure TClients.SetItems(i: integer; const Value: TClient);
begin
  inherited SetItems( i, Value ) ;
end;

{ TClient }

constructor TClient.create;
begin
  inherited;
  FClientSource := nil ;
end;

function TClient.GetClientSouceAsGUIString: string;
begin
  if FClientSource = nil then
    result := ''
  else
    result := FClientSource.DisplayText;
end;

function TClient.GetClientSourceOIDAsString: string;
begin
  if FClientSource = nil then
    result := ''
  else
    result := FClientSource.OID.AsString;
end;

function TClient.GetOwner: TClients;
begin
  result := TClients( inherited GetOwner );
end;

function TClient.IsValid(const pErrors: TPerObjErrors): boolean;
begin
  inherited IsValid( pErrors ) ;

  if ClientName = '' then
    pErrors.AddError( 'ClientName', cErrorClientName ) ;

  if ( FClientSource = nil ) or
     ( FClientSource = gClientSources.Unknown ) then
    pErrors.AddError( 'ClientSource', cErrorClientSource ) ;

  result := pErrors.Count = 0 ;

end;

procedure TClient.SetClientSourceAsGUIString(const Value: string);
begin
  FClientSource := gClientSources.FindByDisplayText(Value);
end;

procedure TClient.SetClientSourceOIDAsString(const Value: string);
begin
  FClientSource := gClientSources.Find(Value);
end;

procedure TClient.SetOwner(const Value: TClients);
begin
  inherited SetOwner( Value ) ;
end;

{ TClientSources }

procedure TClientSources.Add(pObject: TClientSource;pDefDispOrdr: boolean);
begin
  inherited Add( pObject, pDefDispOrdr ) ;
end;

function TClientSources.Find(pOIDToFindAsString: string): TClientSource;
begin
  if pOIDToFindAsString = '' then
    result := nil
  else
    result := TClientSource( inherited Find( pOIDToFindAsString ));
end;

function TClientSources.FindByDisplayText(const pValue: string): TClientSource;
var
  i : integer ;
begin
  result := nil ;
  for i := 0 to Count - 1 do
    if SameText( Items[i].DisplayText, pValue ) then
    begin
      result := Items[i];
      Exit ; //==>
    end ;
end;

function TClientSources.GetItems(i: integer): TClientSource;
begin
  result := TClientSource( inherited GetItems( i )) ;
end;

procedure TClientSources.SetItems(i: integer; const Value: TClientSource);
begin
  inherited SetItems( i, Value ) ;
end;

function TClientSources.Unknown: TClientSource;
var
  i : integer ;
begin
  result := nil ;
  for i := 0 to Count - 1 do
    if SameText( Items[i].DisplayText, 'Unknown' ) then
    begin
      result := Items[i];
      Exit ; //==>
    end ;
end;

{ TClientSource }

function TClientSource.GetOwner: TClientSources;
begin
  result := TClientSources( inherited GetOwner );
end;

procedure TClientSource.SetOwner(const Value: TClientSources);
begin
  inherited SetOwner( Value ) ;
end;

initialization
finalization
  uClientSources.Free;

end.

