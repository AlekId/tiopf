unit tiFileSyncReader_Remote;

interface
uses
  tiFileName_BOM
  ,tiFileSyncReader_Abs
  ,tiFileSyncSetup_BOM
  ,tiHTTP
  ,tiHTTPIndy
  ;

type

  TFileSyncReaderRemote = class( TtiFileSyncReaderAbs )
  private
    FHTTP: TtiHTTPAbs ;
    Furl: string;
    procedure   ExecuteRemoteCall(const pCommand: string; const pData: string);
    function    DecodeResult: string;
  protected
    procedure   SetParamsAsString(const Value: string); override ;
  public
    constructor Create; override ;
    destructor  Destroy; override ;

    procedure ReadFileIndex(  pFileNames : TtiFileNames ;
                              pSourceFileNameFilters : TtiFileNameFilters =  nil ) ; override ;
    procedure ReadPathIndex(  pPathNames : TtiPathNames ;
                              pSourceFileNameFilters : TtiFileNameFilters = nil ) ; override ;
    procedure CreatePath(     pPathName : TtiPathName   ) ; override ;
    procedure DeletePath(     pPathName : TtiPathName   ) ; override ;
    procedure ReadFileData(   pFileName  : TtiFileName  ) ; override ;
    procedure WriteFileData(  pFileName  : TtiFileName  ) ; override ;
    procedure DeleteFileData( pFileName  : TtiFileName  ) ; override ;
    procedure WriteIndex(     pFileNames : TtiFileNames ) ; override ;
  end ;

implementation
uses
  Classes
  ,cFileSync
  ,tiUtils
  ,SysUtils
  ,cTIPersist
  ,tiXML
  ;


{ TFileSyncReaderRemote }

constructor TFileSyncReaderRemote.Create;
begin
  inherited;
  FHTTP:= gTIHTTPFactory.CreateInstance(cHTTPIndy);
end;

procedure TFileSyncReaderRemote.CreatePath(pPathName: TtiPathName);
begin
  ExecuteRemoteCall( ctiFileSyncCommand_CreatePath, pPathName.AsXML);
  pPathName.AsXML:= DecodeResult;
end;

function TFileSyncReaderRemote.DecodeResult: string;
begin
  Result := tiDecompressDecode(tiStreamToString(FHTTP.Output));
end;

procedure TFileSyncReaderRemote.DeleteFileData(pFileName: TtiFileName);
begin
  ExecuteRemoteCall(ctiFileSyncCommand_DeleteFileData, pFileName.AsXML);
  pFileName.AsXML:= DecodeResult;
end;

procedure TFileSyncReaderRemote.DeletePath(pPathName: TtiPathName);
begin
  ExecuteRemoteCall(ctiFileSyncCommand_DeletePath, pPathName.AsXML);
  pPathName.AsXML:= DecodeResult;
end;

destructor TFileSyncReaderRemote.Destroy;
begin
  FHTTP.Free;
  inherited;
end;

procedure TFileSyncReaderRemote.ExecuteRemoteCall(const pCommand, pData: string);
var
  lsl: TStringList;
begin
  lsl:= TStringList.Create;
  try
    lsl.Values[cHTTPParamNameCommand] := pCommand;
    lsl.Values[cHTTPParamNameData] := tiCompressEncode(pData);
    tiStringToStream(lsl.CommaText, FHTTP.Input);
  finally
    lsl.Free;
  end;
  FHTTP.Post(Furl);
end;

procedure TFileSyncReaderRemote.ReadFileData(pFileName: TtiFileName);
begin
  ExecuteRemoteCall(ctiFileSyncCommand_ReadFileData, pFileName.AsXML);
  pFileName.AsXML:= DecodeResult;
end;

procedure TFileSyncReaderRemote.ReadFileIndex(pFileNames: TtiFileNames;
  pSourceFileNameFilters: TtiFileNameFilters);
begin
  ExecuteRemoteCall( ctiFileSyncCommand_ReadFileIndex, pFileNames.AsXML);
  pFileNames.AsXML:= DecodeResult;
end;

procedure TFileSyncReaderRemote.ReadPathIndex(pPathNames: TtiPathNames;
  pSourceFileNameFilters: TtiFileNameFilters);
begin
  ExecuteRemoteCall(ctiFileSyncCommand_ReadPathIndex, pPathNames.AsXML);
  pPathNames.AsXML:= DecodeResult;
end;

procedure TFileSyncReaderRemote.SetParamsAsString(const Value: string);
var
  lProxyServer: string;
  lProxyPort  : Integer ;
  lProxyActive: Boolean;
  lHTTPClassMapping : string ;
begin
  inherited SetParamsAsString(Value);
  // Waning: This code is cloned in tiQueryRemote
  Furl := Params.Values[cHTTPURL];
  lHTTPClassMapping := Params.Values[cHTTPConnectWith];
  if not SameText( FHTTP.MappingName, lHTTPClassMapping) then
  begin
    FreeAndNil(FHTTP);
    FHTTP := gTIHTTPFactory.CreateInstance(lHTTPClassMapping);
  end ;
  if not SameText( cHTTPMSXML, FHTTP.MappingName ) then
  begin
    lProxyActive := tiStrToBool(Params.Values[cHTTPProxyServeractive]);
    lProxyServer := Params.Values[cHTTPProxyServerName];
    lProxyPort   := StrToIntDef(Params.Values[cHTTPProxyPort], 0);
    if (lProxyActive ) and
       ( lProxyServer <> '' ) and
       ( lProxyPort <> 0 ) then
    begin
      FHTTP.ProxyServer := lProxyServer;
      FHTTP.ProxyPort   := lProxyPort;
    end;
  end;
end;

procedure TFileSyncReaderRemote.WriteFileData(pFileName: TtiFileName);
begin
  ExecuteRemoteCall(ctiFileSyncCommand_WriteFileData, pFileName.AsXML);
  pFileName.AsXML:= DecodeResult;
end;

procedure TFileSyncReaderRemote.WriteIndex(pFileNames: TtiFileNames);
begin
//  Assert( false, 'Under construction' ) ;
end;

initialization
  gFileSyncReaderFactory.RegisterClass( cgsRemote, TFileSyncReaderRemote ) ;

end.
