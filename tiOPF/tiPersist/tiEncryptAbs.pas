{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  Originally developed by TechInsite Pty. Ltd.
  23 Victoria Pde, Collingwood, Melbourne, Victoria 3066 Australia
  PO Box 429, Abbotsford, Melbourne, Victoria 3067 Australia
  Phone: +61 3 9419 6456
  Fax:   +61 3 9419 1682
  Web:   www.techinsite.com.au

  This code is made available on the TechInsite web site as open source.
  You may use this code in any way you like, except to sell it to other
  developers. Please be sure to leave the file header and list of
  contributors unchanged.

  If you make any changes or enhancements, which you think will benefit other
  developers and will not break any existing code, please forward your changes
  (well commented) to TechInsite and I will make them available in the next
  version.

  Purpose:
    Provide String, Stream and File (via TStrings) encryption & decryption.

  Classes:
    TtiEncryptAbs       - Provides string and stream encryption
    TEncrypt          - Provide file encryption/decryption
    TEncryptTest      - Test the encryption routines.

  Revision History:
    ???,  ????, Scott Maskiel,    Created with support for files
                                  (Scott_Maskiel@nemmco.com.au)
    June, 2000, Peter Hinrichsen, Abstracted and added String & TStream support
                                  Added NewSeed method
                                  (peter_hinrichsen@techinsite.com.au)

    May,  2005, Ian Krigsman      Added IntSeed for implementations that require
                                  a numeric seed (Int64) rather than string
                                  SetSeed/SetIntSeed can be overridden in concrete.

  ToDo:

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

{$I tiDefines.inc}

unit tiEncryptAbs;

interface

uses
  Classes
  ,Contnrs
  ;

const
  cuSeedString : String = '12%6348i(oikruK**9oi57&^1`!@bd)';

type

  // Base encryption component. Wrappers Scott's encryption algorithm and
  // exposes the EncryptString & EncryptStream interface. Indroduces the
  // NewSeed method to increase security in comms apps
  // ---------------------------------------------------------------------------
  TtiEncryptAbs = class( TObject )
  private
    FSeed : string ;
    FIntSeed : Int64;
  protected
    procedure SetSeed   (const Value: string); virtual ;
    procedure SetIntSeed(const Value: Int64 ); virtual ;
  public
    constructor Create ; virtual ;
    function    EncryptString( const psData : string ) : string ; virtual ; abstract ;
    function    DecryptString( const psData : string ) : string ; virtual ; abstract ;
    procedure   EncryptStream( const pSrc, pDest : TStream ) ; virtual ; abstract ;
    procedure   DecryptStream( const pSrc, pDest : TStream ) ; virtual ; abstract ;
    property    Seed    : string read FSeed    write SetSeed ;
    property    IntSeed : Int64  read FIntSeed write SetIntSeed ;
    procedure   NewSeed ;
//    procedure   NewIntSeed ; // Implement when required
  end ;

  // A class reference for the TtiEncrypt descendants
  // ---------------------------------------------------------------------------
  TtiEncryptClass = class of TtiEncryptAbs ;

  // A class to hold the TtiEncrypt class mappings. The factory maintains
  // a list of these and uses the EncryptClass property to create the objects.
  // ---------------------------------------------------------------------------
  TtiEncryptClassMapping = class( TObject )
  private
    FsMappingName  : string;
    FEncryptClass : TtiEncryptClass;
  public
    Constructor Create( const psMappingName : string ;
                        pEncryptClass      : TtiEncryptClass ) ;
    property    MappingName : string read FsMappingName ;
    property    EncryptClass : TtiEncryptClass read FEncryptClass ;
  end ;

  // Factory pattern - Create a descendant of the TtiEncrypt at runtime.
  // ---------------------------------------------------------------------------
  TtiEncryptFactory = class( TObject )
  private
    FList : TObjectList ;
    FsDefaultEncryptionType: string;
  public
    constructor Create ;
    destructor  Destroy ; override ;
    procedure   RegisterClass( const psEncryptionType : string ;
                                     pEncryptClass : TtiEncryptClass ) ;
    function    CreateInstance( const psEncryptionType : string ) : TtiEncryptAbs ; overload ;
    function    CreateInstance : TtiEncryptAbs ; overload ;
    procedure   AssignEncryptionTypes( pStrings : TStrings ) ;
    property    DefaultEncryptionType : string
                read  FsDefaultEncryptionType
                write FsDefaultEncryptionType ;

  end ;


// The EncryptFactory is a singleton
// -----------------------------------------------------------------------------
function gEncryptFactory : TtiEncryptFactory ;

var
  gTiEncryptClass : TtiEncryptClass ;

implementation
uses
  SysUtils
  {$IFDEF MSWINDOWS}
  ,Windows
  {$ENDIF MSWINDOWS}
  ;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *
// *  TtiEncryptAbs
// *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
constructor TtiEncryptAbs.Create;
begin
  inherited;
  FSeed := cuSeedString ;
end;

// -----------------------------------------------------------------------------
procedure TtiEncryptAbs.NewSeed;
var
  i : integer ;
  ls : string ;
begin
  ls := '' ;
  for i := 1 to length( FSeed ) do
    ls := ls + Char( Random( 254 ) + 1 ) ;
  FSeed := ls ;
end;

// A var to hold our single instance of the TtiEncryptFactory
var
  uEncryptFactory : TtiEncryptFactory ;

// The EncryptFactory is a singleton
// -----------------------------------------------------------------------------
function gEncryptFactory : TtiEncryptFactory ;
begin
  if uEncryptFactory = nil then
    uEncryptFactory := TtiEncryptFactory.Create ;
  result := uEncryptFactory ;
end ;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *
// * TtiEncryptFactory
// *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
constructor TtiEncryptFactory.Create;
begin
  inherited ;
  FList := TObjectList.Create ;
end;

// Assing the registered list of TtiEncrypt names to a stringList
// This can be used to populate a combobox with the available TtiEncrypt
// class types.
// -----------------------------------------------------------------------------
procedure TtiEncryptFactory.AssignEncryptionTypes(pStrings: TStrings);
var
  i : integer ;
begin
  pStrings.Clear ;
  for i := 0 to FList.Count - 1 do
    pStrings.Add( TtiEncryptClassMapping( FList.Items[i] ).MappingName ) ;
end;

// Call the factory to create an instance of TtiEncrypt
// -----------------------------------------------------------------------------
function TtiEncryptFactory.CreateInstance( const psEncryptionType: string): TtiEncryptAbs;
var
  i : integer ;
begin
  result := nil ;
  for i := 0 to FList.Count - 1 do
    if UpperCase( TtiEncryptClassMapping( FList.Items[i] ).MappingName ) =
         UpperCase( psEncryptionType ) then begin
      result := TtiEncryptClassMapping( FList.Items[i] ).EncryptClass.Create ;
      Break ; //==>
    end ;

  Assert( result <> nil,
          Format( '<%s> does not identify a registered Encryption class.',
                   [psEncryptionType] )) ;

end;

// -----------------------------------------------------------------------------
function TtiEncryptFactory.CreateInstance: TtiEncryptAbs;
begin
  result := CreateInstance( FsDefaultEncryptionType ) ;
end;

// -----------------------------------------------------------------------------
destructor TtiEncryptFactory.Destroy;
begin
  FList.Free ;
  inherited;
end;

// Register a TtiEncrypt class for creation by the factory
// -----------------------------------------------------------------------------
procedure TtiEncryptFactory.RegisterClass(
  const psEncryptionType: string; pEncryptClass: TtiEncryptClass);
var
  i : integer ;
begin
  for i := 0 to FList.Count - 1 do
    if UpperCase( TtiEncryptClassMapping( FList.Items[i] ).MappingName ) =
         UpperCase( psEncryptionType ) then
      Assert( false,
              Format( 'Encryption class <%s> already registered.',
                      [psEncryptionType] )) ;
  FList.Add( TtiEncryptClassMapping.Create( psEncryptionType, pEncryptClass )) ;
  FsDefaultEncryptionType := UpperCase( psEncryptionType ) ;
end;

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *
// * TtiEncryptClassMapping
// *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// Overloaded constructor - used to create an instance ot TtiEncryptClassMapping
// and to preset it's properties.
constructor TtiEncryptClassMapping.Create(const psMappingName: string;
  pEncryptClass: TtiEncryptClass);
begin
  inherited Create ;
  FsMappingName :=  psMappingName ;
  FEncryptClass := pEncryptClass ;
end;

procedure TtiEncryptAbs.SetIntSeed( const Value: Int64 );
begin
  FIntSeed := Value;
end;

procedure TtiEncryptAbs.SetSeed( const Value: string );
begin
  FSeed := Value;
end;

initialization

finalization
  // Free the TtiEncryptFactory
  uEncryptFactory.Free ;

end.

