{
  This persistence layer uses standard Free Pascal SQLDB (SQLite3) components.

  The connection string format is the same as the standard SQLite3 persistence layers.

  eg:
    GTIOPFManager.ConnectDatabase('Test.db','','', '');

  Initial Author:  Michael Van Canneyt (michael@freepascal.org) - Aug 2008
}

unit tiQuerySqldbSQLite3;

{$I tiDefines.inc}

interface

uses
  tiQuery
  ,Classes
  ,SysUtils
  ,sqldb
  ,sqlite3conn
  ,tiPersistenceLayers
  ,tiQuerySqldb
  ;

type

  TtiPersistenceLayerSqldSQLite3 = class(TtiPersistenceLayerSqldDB)
  protected
    function   GetPersistenceLayerName: string; override;
    function   GetDatabaseClass: TtiDatabaseClass; override;
  public
    procedure  AssignPersistenceLayerDefaults(const APersistenceLayerDefaults: TtiPersistenceLayerDefaults); override;
  end;


  TtiDatabaseSQLDBSQLite3 = Class(TtiDatabaseSQLDB)
  protected
    class function  CreateSQLConnection: TSQLConnection; override;
    class procedure CreateDatabase(const ADatabaseName, AUserName, APassword: string; const AParams: string = ''); override;
    class procedure DropDatabase(const ADatabaseName, AUserName, APassword: string; const AParams: string = ''); override;
    function    HasNativeLogicalType: boolean; override;
    function    FieldMetaDataToSQLCreate(const AFieldMetaData: TtiDBMetaDataField): string; override;
  end;



implementation

{ $define LOGSQLDB}
uses
{$ifdef LOGSQLDB}
  tiLog,
{$endif}
  tiOPFManager
  ,tiConstants
  ,tiUtils
  ,tiExcept
  ;


{ TtiPersistenceLayerSqldSQLite3 }

procedure TtiPersistenceLayerSqldSQLite3.AssignPersistenceLayerDefaults(
  const APersistenceLayerDefaults: TtiPersistenceLayerDefaults);
begin
  Assert(APersistenceLayerDefaults.TestValid, CTIErrorInvalidObject);
  APersistenceLayerDefaults.PersistenceLayerName := cTIPersistSqldbSQLite3;
  APersistenceLayerDefaults.DatabaseName := CDefaultDatabaseName + '.db';
  APersistenceLayerDefaults.IsDatabaseNameFilePath := True;
  APersistenceLayerDefaults.CanCreateDatabase := True;
  APersistenceLayerDefaults.CanSupportMultiUser := False;
  APersistenceLayerDefaults.CanSupportSQL := True;
end;

function TtiPersistenceLayerSqldSQLite3.GetDatabaseClass: TtiDatabaseClass;
begin
  Result := TtiDatabaseSQLDBSQLite3;
end;

function TtiPersistenceLayerSqldSQLite3.GetPersistenceLayerName: string;
begin
  Result := cTIPersistSqldbSQLite3;
end;


{ TtiDatabaseSQLDBSQLite3 }

class function TtiDatabaseSQLDBSQLite3.CreateSQLConnection: TSQLConnection;
begin
  Result := TSQLite3Connection.Create(Nil);
end;

class procedure TtiDatabaseSQLDBSQLite3.CreateDatabase(const ADatabaseName, AUserName,
    APassword: string; const AParams: string);
begin
  // SqlDB+SQLite3 doesn't have CreateDB, but querying the database causes it to be created
  DatabaseExists(ADatabaseName, AUserName, APassword, AParams);
end;

class procedure TtiDatabaseSQLDBSQLite3.DropDatabase(const ADatabaseName, AUserName,
    APassword: string; const AParams: string);
begin
  if FileExists(ADatabaseName) then
    tiDeleteFile(ADatabaseName);
end;


function TtiDatabaseSQLDBSQLite3.HasNativeLogicalType: boolean;
begin
  Result := False;
end;

{ User the following URL as reference: https://www.sqlite.org/datatype3.html }
function TtiDatabaseSQLDBSQLite3.FieldMetaDataToSQLCreate(const AFieldMetaData: TtiDBMetaDataField): string;
var
   lFieldName: string;
begin
  lFieldName := AFieldMetaData.Name;
  case AFieldMetaData.Kind of
    qfkString:     result := 'TEXT';
    qfkInteger:    result := 'INTEGER';
    qfkFloat:      result := 'REAL';
    qfkDateTime:   result := 'DATETIME';
    {$IFDEF BOOLEAN_CHAR_1}
    qfkLogical:    result := 'Char(1) default ''F'' check(' + lFieldName + ' in (''T'', ''F''))';
    {$ELSE}
      {$IFDEF BOOLEAN_NUM_1}
    qfkLogical:    result := 'SmallInt default 0 check(' + lFieldName + ' in (1, 0)) ';
      {$ELSE}
    qfkLogical:    result := 'VarChar(5) default ''FALSE'' check(' + lFieldName + ' in (''TRUE'', ''FALSE'')) ';
      {$ENDIF}
    {$ENDIF}
    qfkBinary:     result := 'BLOB';
    qfkLongString: result := 'TEXT';
  else
    raise EtiOPFInternalException.Create('Invalid FieldKind');
  end; { case }
end;

initialization

  GTIOPFManager.PersistenceLayers.__RegisterPersistenceLayer(
    TtiPersistenceLayerSqldSQLite3);

finalization
  if not tiOPFManager.ShuttingDown then
    GTIOPFManager.PersistenceLayers.__UnRegisterPersistenceLayer(cTIPersistSqldbSQLite3);

end.
