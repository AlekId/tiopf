unit tiQuery_TST;

{$I tiDefines.inc}

interface
uses
  {$IFDEF FPC}
  testregistry,
  {$ENDIF}
  tiTestFramework
  ,tiDBConnectionPool
  ,tiQuery
  ,SysUtils
  ,Classes
  ,tiPersistenceLayers
  ,tiOPFManager
 ;


type

  // Test the meta data objects. No database access required.
  TTestTIMetaData = class(TtiTestCase)
  published
    procedure DBMetaDataAdd;
    procedure DBMetaDataFindByTableName;
    procedure MetaDataTableAdd;
    procedure MetaDataTableAddField;
    procedure MetaDataTableFindByFieldName;
    procedure MetaDataTableMaxFieldNameWidth;
    procedure MetaDataFieldClone;
    procedure MetaDataTableClone;
  end;


  TTestTIQueryParams = class(TtiTestCase)
  published
    procedure TestCheckStreamContentsSame;
    procedure AsString;
    procedure AsVariant_String;
    procedure AsInteger;
    procedure AsVariant_Integer;
    procedure AsFloat;
    procedure AsVariant_Float;
    procedure AsDateTime;
    procedure AsVariant_DateTime;
    procedure AsBoolean;
    procedure AsVariant_Boolean;
    procedure AsStream;
    procedure ParamByName;
    procedure ParamIsNull;
  end;

  TTestTIPersistenceLayers = class(TtiOPFTestCase)
  published
    procedure   ConnectDatabase;
    // ToDo: There are many tests on TtiPersistenceLayerList that must be tested here
  end;

  // Test TtiDatabase connectivity
  TTestTIDatabase = class(TtiOPFTestCase)
  private

  protected
    FTIOPFManager: TtiOPFManager;
    FPersistenceLayer : TtiPersistenceLayer;
    FDatabase : TtiDatabase;
    FDatabaseClass : TtiDatabaseClass;
    FPersistenceLayerDefaults: TtiPersistenceLayerDefaults;

    procedure SetUp; override;
    procedure TearDown; override;
    procedure DatabaseExists; virtual; abstract;
    procedure CreateDatabase; virtual; abstract;
    procedure DoThreadedDBConnectionPool(const ADBConnectionPool: TtiDBConnectionPool; const AThreadCount : integer);
    procedure CheckFieldMetaData(const pDBMetaDataTable : TtiDBMetaDataTable;
                                   const AFieldName : string;
                                   pKind : TtiQueryFieldKind;
                                   pWidth : integer = 0);
  published

    procedure tiOPFManager_ConnectDatabase; virtual;
    procedure Database_Connect; virtual;
    procedure NonThreadedDBConnectionPool; virtual;
    procedure ThreadedDBConnectionPool; virtual;

    procedure Transaction_InTransaction; virtual;
    procedure Transaction_Commit; virtual;
    procedure Transaction_RollBack; virtual;
    procedure CreateTableDropTable; virtual;
    procedure CreateTableDropTable_Timing; virtual;
    procedure ReadMetaData; virtual;
  end;


  // Test query access
  TTestTIQueryAbs = class(TtiOPFTestCase)
  private
    FPersistenceLayer : TtiPersistenceLayer;
    FDatabase : TtiDatabase;
    FQuery   : TtiQuery;
  protected
    // Some field vars used in the concrete
    property  Database : TtiDatabase read FDatabase   write FDatabase;
    property  Query   : TtiQuery    read FQuery      write FQuery;

    procedure SetUp; override;
    procedure TearDown; override;

    // Helper methods used in the concretes
    procedure DoAttachAndConnect;
    procedure DoDetachAndDisConnect;
    procedure DoReAttach;
    procedure PopulateTableString(  const AValue : String   );
    procedure PopulateTableInteger( const AValue : Integer  );
{$IFDEF TESTINT64}
    procedure PopulateTableInt64(   const AValue : Int64    );
{$ENDIF}
    procedure PopulateTableReal(    const AValue : Extended     );
    procedure PopulateTableBoolean( const AValue : Boolean  );
    procedure PopulateTableDateTime(const AValue : TDateTime);
    procedure PopulateTableStream(  const AValue : TStream);
    procedure DropTestTable;
    procedure DoFieldAsStringLong(pStrLen: integer);

    // Implement (or hide) these in the concrete
    procedure GetSetSQL; virtual; abstract;
    procedure QueryType; virtual; abstract;
    procedure ParamName; virtual; abstract;
    procedure ParamCount; virtual; abstract;
    procedure ParamsAsString; virtual; abstract;
    procedure ParamAsString; virtual; abstract;
    procedure ParamAsInteger; virtual; abstract;
    procedure ParamAsFloat; virtual; abstract;
    procedure ParamAsBoolean; virtual; abstract;
    procedure ParamAsDateTime; virtual; abstract;
    procedure ParamAsStream; virtual; abstract;
    procedure ParamAsMacro; virtual; abstract;
    procedure ParamIsNull; virtual; abstract;
    procedure OpenCloseActive; virtual; abstract;
    procedure ExecSQL; virtual; abstract;
  public
    constructor Create{$IFNDEF DUNIT2ORFPC}(AMethodName: string){$ENDIF}; override;
  published
    procedure ConfirmSetupWorks; virtual;
    procedure ConfirmDBConnectionWorks; virtual;
    procedure TypeKindToQueryFieldKind;
    // TtiQuery to TtiDatabase connection
    procedure QueryToDatabaseConnection; // AttachDatabase, DetachDatabase;
    // Data (field) access
    procedure FieldAsInteger;
{$IFDEF TESTINT64}
    procedure FieldAsInt64;
{$ENDIF}
    procedure FieldAsString;
    procedure FieldAsStringLong1;
    procedure FieldAsStringLong10;
    procedure FieldAsStringLong100;
    procedure FieldAsStringLong255;
    procedure FieldAsStringLong256;
    procedure FieldAsStringLong257;
    procedure FieldAsStringLong511;
    procedure FieldAsStringLong512;
    procedure FieldAsStringLong513;
    procedure FieldAsStringLong1023;
    procedure FieldAsStringLong1024;
    procedure FieldAsStringLong1025;
    procedure FieldAsStringLong1999;
    procedure FieldAsStringLong2000;
    procedure FieldAsStringLong2001;
    procedure FieldAsStringLong3999;
    procedure FieldAsStringLong4000;
    procedure FieldAsStringLong4001;
    procedure FieldAsStringLong5000;
    procedure FieldAsStringLong10000;
    procedure FieldAsFloat;
    procedure FieldAsBoolean;
    procedure FieldAsDateTime;
    procedure FieldAsStream;
    procedure FieldIsNull; virtual;
    procedure FieldByNameVSFieldByIndex; virtual;
    // Meta data access methods
    procedure FieldCount; virtual;
    procedure FieldName ; virtual;
    procedure FieldIndex; virtual;
    procedure FieldKind ; virtual;
    procedure FieldSize ; virtual;
    // Traversing result set
    procedure EOF; virtual;
    procedure Next; virtual;
    procedure InsertDeleteUpdate_Timing;
  end;
  
procedure RegisterTests;

const
  cTIQueryTestName  = 'Dynamically loaded persistence layer';
  // Number of threads and iterations for DBPool testing
  // Set a high number for thorough testing (eg, 100)
  // Set a low number for quick testing (eg, 5)
  cuThreadCount     = 5;
  cuIterations      = 5;
  cRepeatCount      = 5;
  // Seconds. Run the timing test for this number of seconds and count the
  // number of iterations. Higher value gives more accurate values.
  // Lower value gives faster tests.
  // Results are written to DataAccessTimingResults.txt
  CTimingTestPeriod = 2;

implementation
uses
  {$IFDEF MSWINDOWS}
   Forms
  ,Windows
  {$ENDIF}
  ,Contnrs
  ,TypInfo
  ,SyncObjs
  ,tiLog
  ,tiUtils
  ,tiConstants
  {$IFDEF DELPHI5}
  ,FileCtrl
  {$ENDIF}
  ,tiOPFTestManager
  ,tiTestDependencies
  ,tiThread
  ,tiStreams
  ,tiRTTI
 ;


procedure RegisterTests;
begin
  RegisterNonPersistentTest(TTestTIMetaData);
  RegisterNonPersistentTest(TTestTIQueryParams);
end;


procedure TTestTIDatabase.tiOPFManager_ConnectDatabase;
begin
  FTIOPFManager.ConnectDatabase(
    PerFrameworkSetup.DBName,
    PerFrameworkSetup.Username,
    PerFrameworkSetup.Password,
    '',
    PerFrameworkSetup.PerLayerName);
  try
    CheckEquals(PerFrameworkSetup.PerLayerName, FPersistenceLayer.PersistenceLayerName, 'PerLayerName');
    CheckNotNull(FPersistenceLayer.DefaultDBConnectionPool, 'DefaultDBConnectionPool');
    CheckEquals(PerFrameworkSetup.DBName, FPersistenceLayer.DefaultDBConnectionPool.DBConnectParams.DatabaseName, 'DatabaseName');
  finally
    FTIOPFManager.DisconnectDatabase(PerFrameworkSetup.DBName, PerFrameworkSetup.PerLayerName);
  end;
  CheckNull(FPersistenceLayer.DefaultDBConnectionPool, 'DefaultDBConnectionPool');
end;



procedure TTestTIDatabase.Database_Connect;
begin
  FDatabase.Connect(PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '');
  Check(FDatabase.Connected, 'Connect failed');
  FDatabase.Connected := false;
  Check(not FDatabase.Connected, 'Connected := false failed');
end;


procedure TTestTIDatabase.CreateTableDropTable;
  procedure _CreateTableDropTable(const AFieldName : string; AFieldKind : TtiQueryFieldKind; AFieldWidth : integer);
  var
    lTable : TtiDBMetaDataTable;
    lDBMetaData : TtiDBMetaData;
    lDBMetaDataTable : TtiDBMetaDataTable;
  begin
    lTable := TtiDBMetaDataTable.Create;
    try
      lTable.Name := cTableNameCreateTable;
      lTable.AddField(AFieldName, AFieldKind, AFieldWidth);
      FDatabase.CreateTable(lTable);
    finally
      lTable.Free;
    end;

    lDBMetaData := TtiDBMetaData.Create;
    try
      FDatabase.ReadMetaDataTables(lDBMetaData);
      lDBMetaDataTable := lDBMetaData.FindByTableName(cTableNameCreateTable);
      Check(lDBMetaDataTable <> nil, 'Unable to find metadata for <test_create_table> on field  <' + AFieldName + '>');
      Check(SameText(lDBMetaDataTable.Name, cTableNameCreateTable), 'Wrong table found when searching for <test_create_table> on field <' + AFieldName + '>');
      FDatabase.ReadMetaDataFields(lDBMetaDataTable);

      CheckFieldMetaData(lDBMetaDataTable, AFieldName, AFieldKind, AFieldWidth);

      FDatabase.DropTable(cTableNameCreateTable);
      lDBMetaData.Clear;
      FDatabase.ReadMetaDataTables(lDBMetaData);
      lDBMetaDataTable := lDBMetaData.FindByTableName(cTableNameCreateTable);
      Check(lDBMetaDataTable = nil, 'Drop table <test_create_table> failed on field <' + AFieldName + '>');
    finally
      lDBMetaData.Free;
    end;
  end;
begin
  FDatabase.Connect(PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '');
  try
    try FDatabase.DropTable(cTableNameCreateTable) except end;
    _CreateTableDropTable( 'Str_Field',   qfkString,    10);
    _CreateTableDropTable( 'Int_Field',   qfkInteger,    0);
    _CreateTableDropTable( 'Float_Field', qfkFloat,      0);
    _CreateTableDropTable( 'Date_Field',  qfkDateTime,   0);
    _CreateTableDropTable( 'Bool_Field' , qfkLogical,    0);
    _CreateTableDropTable( 'Notes_Field', qfkLongString, 0);
  finally
    FDatabase.Connected := false;
  end;
end;


procedure TTestTIQueryAbs.DoAttachAndConnect;
begin
  FQuery.AttachDatabase(FDatabase);
  FDatabase.StartTransaction;
end;


procedure TTestTIQueryAbs.DoDetachAndDisConnect;
begin
  if FDatabase.InTransaction then
    FDatabase.Commit;
  FQuery.DetachDatabase;
end;


procedure TTestTIQueryAbs.DoReAttach;
begin
  DoDetachAndDisConnect;
  DoAttachAndConnect;
end;


procedure TTestTIQueryAbs.EOF;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    FQuery.SelectRow('test_group', nil);
    Check(FQuery.EOF, 'FQuery.EOF = true failed.');
    FQuery.Close;
    InsertIntoTestGroup(Database, 1);
    FQuery.SelectRow('test_group', nil);
    Check(not FQuery.EOF, 'FQuery.EOF = false failed.');
    FQuery.Close;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.FieldAsBoolean;
begin
  CreateTableBoolean(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableBoolean(True);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableName, nil);
      CheckEquals(FQuery.FieldAsBoolean[ cTIQueryColName ], True, 'FieldAsBoolean');
      CheckEquals(FQuery.FieldAsBooleanByIndex[ cFieldAs_Index ], True, 'FieldAsBoolean');
      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;


procedure TTestTIQueryAbs.FieldAsDateTime;
var
  lNow : TDateTime;
begin
  lNow := Now;
  CreateTableDateTime(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableDateTime(lNow);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableName, nil);
      CheckEquals(FQuery.FieldAsDateTime[ cTIQueryColName ], lNow, cdtOneSecond, 'FieldAsDateTime');
      CheckEquals(FQuery.FieldAsDateTimeByIndex[ cFieldAs_Index ], lNow, cdtOneSecond, 'FieldAsDateTime');
      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;


procedure TTestTIQueryAbs.FieldAsFloat;
const
  cPrecision = 6;
begin
  CreateTableFloat(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableReal(1234.5678);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableName, nil);
      CheckEquals(FQuery.FieldAsFloat[ cTIQueryColName ], 1234.5678, 0.00001, 'FieldAsFloat');
      CheckEquals(FQuery.FieldAsFloatByIndex[ cFieldAs_Index ], 1234.5678, 0.00001, 'FieldAsFloat');
      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;


procedure TTestTIQueryAbs.FieldAsInteger;
begin
  CreateTableInteger(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableInteger(1);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableName, nil);
      CheckEquals(FQuery.FieldAsInteger[ cTIQueryColName ], 1, 'FieldAsInteger');
      CheckEquals(FQuery.FieldAsIntegerByIndex[ cFieldAs_Index ], 1, 'FieldAsIntegerByIndex');
      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;


{$IFDEF TESTINT64}
procedure TTestTIQueryAbs.FieldAsInt64;
begin
//  CreateTableInt64(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableInt64(1);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableNameInt64, nil);
      CheckEquals(FQuery.FieldAsInteger[ cTIQueryColName ], 1, 'FieldAsInt64');
      CheckEquals(FQuery.FieldAsIntegerByIndex[ cFieldAs_Index ], 1, 'FieldAsInt64ByIndex');
      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
//    DropTestTable;
  end;
end;
{$ENDIF}


procedure TTestTIQueryAbs.FieldAsString;
const
  cString = 'abcdefghij';
begin
  CreateTableString(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableString(cString);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableName, nil);
      CheckEquals(FQuery.FieldAsString[ cTIQueryColName ], cString, 'FieldAsString');
      CheckEquals(FQuery.FieldAsStringByIndex[ cFieldAs_Index ], cString, 'FieldAsStringByIndex');
      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;


procedure TTestTIQueryAbs.FieldCount;
var
  lFieldCount : integer;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    FDatabase.DeleteRow('test_group', nil);
    InsertIntoTestGroup(Database, 1);
    FQuery.SelectRow('test_group', nil);
    lFieldCount := FQuery.FieldCount;
    CheckEquals(7, lFieldCount);
    FQuery.Close;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.FieldIndex;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    InsertIntoTestGroup(Database, 1);
    FQuery.SelectRow('test_Group', nil);
    Check(FQuery.FieldIndex('oid'              ) = 0, 'FQuery.FieldIndex = 0 failed');
    Check(FQuery.FieldIndex('Group_Str_Field'  ) = 1, 'FQuery.FieldIndex = 1 failed');
    Check(FQuery.FieldIndex('Group_Int_Field'  ) = 2, 'FQuery.FieldIndex = 2 failed');
    Check(FQuery.FieldIndex('Group_Float_Field') = 3, 'FQuery.FieldIndex = 3 failed');
    Check(FQuery.FieldIndex('Group_Date_Field' ) = 4, 'FQuery.FieldIndex = 4 failed');
    Check(FQuery.FieldIndex('Group_Bool_Field' ) = 5, 'FQuery.FieldIndex = 5 failed');
    Check(FQuery.FieldIndex('Group_Notes_Field') = 6, 'FQuery.FieldIndex = 6 failed');
    FQuery.Close;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.FieldIsNull;
var
  lParams : TtiQueryParams;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    lParams := TtiQueryParams.Create;
    try
      lParams.SetValueAsString('OID', '1');
      FDatabase.InsertRow('Test_Group', lParams);
      FQuery.SelectRow('test_group', nil);
      Check(FQuery.FieldIsNull[ 'group_str_field' ], 'FieldIsNull  = true failed');
      Check(FQuery.FieldIsNullByIndex[ cFieldAs_Index ], 'FieldIsNull  = true failed');
      FQuery.Close;

      FDatabase.DeleteRow('test_group', nil);
      lParams.SetValueAsString('OID', '2');
      lParams.SetValueAsString('Group_Str_Field', '2');
      FDatabase.InsertRow('Test_Group', lParams);
      FQuery.SelectRow('test_group', nil);
      Check(not FQuery.FieldIsNull[ 'group_str_field' ], 'FieldIsNull = false failed');
      Check(not FQuery.FieldIsNullByIndex[ cFieldAs_Index ], 'FieldIsNull = false failed');
      FQuery.Close;
    finally
      lParams.Free;
    end;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.FieldKind;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    InsertIntoTestGroup(Database, 1);
    FQuery.SelectRow('test_group', nil);
    Check(FQuery.FieldKind(FQuery.FieldIndex('Group_Str_Field'  ))  = qfkString,     'FQuery.FieldKind = qfkString failed');
    Check(FQuery.FieldKind(FQuery.FieldIndex('Group_Int_Field'  ))  = qfkInteger,    'FQuery.FieldKind = qfkInteger failed');
    Check(FQuery.FieldKind(FQuery.FieldIndex('Group_Float_Field'))  = qfkFloat,      'FQuery.FieldKind = qfkFloat failed');
    Check(FQuery.FieldKind(FQuery.FieldIndex('Group_Date_Field' ))  = qfkDateTime,   'FQuery.FieldKind = qfkDateTime failed');
    if FQuery.HasNativeLogicalType then
      Check(FQuery.FieldKind(FQuery.FieldIndex('Group_Bool_Field' ))  = qfkLogical,    'FQuery.FieldKind = qfkLogical failed');
    Check(FQuery.FieldKind(FQuery.FieldIndex('Group_Notes_Field' )) = qfkLongString, 'FQuery.FieldKind = qfkLongString failed');
    FQuery.Close;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.FieldName;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    InsertIntoTestGroup(Database, 1);
    FQuery.SelectRow('test_group', nil);
    Check(SameText(FQuery.FieldName(0), 'oid'              ),  'FQuery.FieldName(0) failed');
    Check(SameText(FQuery.FieldName(1), 'Group_Str_Field'  ),  'FQuery.FieldName(1) failed');
    Check(SameText(FQuery.FieldName(2), 'Group_Int_Field'  ),  'FQuery.FieldName(2) failed');
    Check(SameText(FQuery.FieldName(3), 'Group_Float_Field'),  'FQuery.FieldName(3) failed');
    Check(SameText(FQuery.FieldName(4), 'Group_Date_Field' ),  'FQuery.FieldName(4) failed');
    Check(SameText(FQuery.FieldName(5), 'Group_Bool_Field' ),  'FQuery.FieldName(5) failed');
    Check(SameText(FQuery.FieldName(6), 'Group_Notes_Field' ), 'FQuery.FieldName(6) failed');
    FQuery.Close;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.FieldSize;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    InsertIntoTestGroup(Database, 1);
    FQuery.SelectRow('Test_Group', nil);
    CheckEquals(10, FQuery.FieldSize(FQuery.FieldIndex('Group_Str_Field'   )), 'Group_Str_Field'  );
    CheckEquals(0,  FQuery.FieldSize(FQuery.FieldIndex('Group_Int_Field'   )), 'Group_Int_Field'  );
    CheckEquals(0,  FQuery.FieldSize(FQuery.FieldIndex('Group_Float_Field' )), 'Group_Float_Field');
    CheckEquals(0,  FQuery.FieldSize(FQuery.FieldIndex('Group_Date_Field'  )), 'Group_Date_Field' );
    CheckEquals(0,  FQuery.FieldSize(FQuery.FieldIndex('Group_Notes_Field' )), 'Group_Notes_Field');
    // Nasty, but I can't think of a better solution right now...
    if PerLayerName <> 'DOA' then
      CheckEquals(0,  FQuery.FieldSize(FQuery.FieldIndex('Group_Bool_Field'  )), 'Group_Bool_Field' )
    else
      CheckEquals(1,  FQuery.FieldSize(FQuery.FieldIndex('Group_Bool_Field'  )), 'Group_Bool_Field' );

    FQuery.Close;
// qfkBinary,
// qfkMacro,
// qfkLongString
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.Next;
begin
  CreateTableTestGroup(Database);
  DoAttachAndConnect;
  try
    InsertIntoTestGroup(Database, 1);
    InsertIntoTestGroup(Database, 2);
    InsertIntoTestGroup(Database, 3);
    InsertIntoTestGroup(Database, 4);
    InsertIntoTestGroup(Database, 5);
    FQuery.SelectRow('test_group', nil);
    Check(not FQuery.EOF, '0 FQuery.EOF = true failed.');
    FQuery.Next;
    Check(not FQuery.EOF, '1 FQuery.EOF = true failed.');
    FQuery.Next;
    Check(not FQuery.EOF, '2 FQuery.EOF = true failed.');
    FQuery.Next;
    Check(not FQuery.EOF, '3 FQuery.EOF = true failed.');
    FQuery.Next;
    Check(not FQuery.EOF, '4 FQuery.EOF = true failed.');
    FQuery.Next;
    Check(FQuery.EOF, '5 FQuery.EOF = true failed.');
    FQuery.Close;
  finally
    DoDetachAndDisconnect;
  end;
end;


procedure TTestTIQueryAbs.QueryToDatabaseConnection;
begin
  FQuery.AttachDatabase(FDatabase);
  Check(FQuery.Database <> nil, 'FQuery.AttachDatabase failed');
  FQuery.DetachDatabase;
  Check(FQuery.Database = nil, 'FQuery.DetachDatabase failed');
end;


procedure TTestTIDatabase.ReadMetaData;
var
  lDBMetaData : TtiDBMetaData;
  lDBMetaDataTable : TtiDBMetaDataTable;
  lDatabase : TtiDatabase;
begin
  FTIOPFManager.ConnectDatabase(
                     PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '',
                     PerFrameworkSetup.PerLayerName);

  SetupTestTables(FTIOPFManager);
  try
    lDBMetaData := TtiDBMetaData.Create;
    try
      LDatabase := FPersistenceLayer.DBConnectionPools.Lock(PerFrameworkSetup.DBName);
      try
        lDatabase.ReadMetaDataTables(lDBMetaData);
        lDBMetaDataTable := lDBMetaData.FindByTableName('test_item');
        Check(lDBMetaDataTable <> nil, 'Unable to find metadata for test_item');
        Check(SameText(lDBMetaDataTable.Name, 'Test_Item'), 'Wrong table found when searching for <test_item>');
        lDatabase.ReadMetaDataFields(lDBMetaDataTable);

        // So, we will just search for the field.
        // Currently, there is no field information like type or size returned.
        // This should be added.
        CheckFieldMetaData(lDBMetaDataTable, 'OID',              qfkInteger);
        CheckFieldMetaData(lDBMetaDataTable, 'OID_GROUP',        qfkInteger);
        CheckFieldMetaData(lDBMetaDataTable, 'ITEM_INT_FIELD',   qfkInteger);
        CheckFieldMetaData(lDBMetaDataTable, 'ITEM_FLOAT_FIELD', qfkFloat);
        CheckFieldMetaData(lDBMetaDataTable, 'ITEM_STR_FIELD',   qfkString, 10);
        CheckFieldMetaData(lDBMetaDataTable, 'ITEM_Bool_FIELD',  qfkLogical);
        CheckFieldMetaData(lDBMetaDataTable, 'ITEM_Date_FIELD',  qfkDateTime);
        CheckFieldMetaData(lDBMetaDataTable, 'ITEM_Notes_FIELD', qfkLongString);

        lDBMetaDataTable := lDBMetaData.FindByTableName('test_group');
        Check(lDBMetaDataTable <> nil, 'Unable to find metadata for test_group');
        Check(SameText(lDBMetaDataTable.Name, 'Test_Group'), 'Wrong table found when searching for <test_group>');
        lDatabase.ReadMetaDataFields(lDBMetaDataTable);

        CheckFieldMetaData(lDBMetaDataTable, 'OID',               qfkInteger);
        CheckFieldMetaData(lDBMetaDataTable, 'GROUP_INT_FIELD',   qfkInteger);
        CheckFieldMetaData(lDBMetaDataTable, 'GROUP_FLOAT_FIELD', qfkFloat  );
        CheckFieldMetaData(lDBMetaDataTable, 'GROUP_STR_FIELD',   qfkString, 10);
        CheckFieldMetaData(lDBMetaDataTable, 'GROUP_Bool_FIELD',  qfkLogical);
        CheckFieldMetaData(lDBMetaDataTable, 'GROUP_Date_FIELD',  qfkDateTime);
        CheckFieldMetaData(lDBMetaDataTable, 'GROUP_Notes_FIELD', qfkLongString);
      finally
        FPersistenceLayer.DBConnectionPools.UnLock(PerFrameworkSetup.DBName, LDatabase);
      end;
    finally
      lDBMetaData.Free;
    end;
  finally
    DeleteTestTables(FTIOPFManager);
  end;
end;


procedure TTestTIQueryAbs.SetUp;
begin
  inherited;
  FPersistenceLayer := gTIOPFManager.PersistenceLayers.FindByPerLayerName(PerFrameworkSetup.PerLayerName);
  CheckNotNull(FPersistenceLayer, 'Unable to find RegPerLayer <' + PerFrameworkSetup.PerLayerName);
  FDatabase := FPersistenceLayer.DBConnectionPools.Lock(PerFrameworkSetup.DBName);
  Assert(not FDatabase.InTransaction, 'Database in transaction after <gTIOPFManager.DefaultPerLayer.DBConnectionPools.Lock> called');
  DropTestTable;
  DropTableTestGroup(FDatabase);
  FQuery   := FPersistenceLayer.QueryClass.Create;
end;


procedure TTestTIQueryAbs.TearDown;
begin
  if FDatabase.InTransaction then
    FDatabase.RollBack;
  DropTestTable;
  DropTableTestGroup(FDatabase);
  CheckNotNull(FPersistenceLayer, 'Unable to find RegPerLayer <' + PerFrameworkSetup.PerLayerName);
  FPersistenceLayer.DBConnectionPools.UnLock(PerFrameworkSetup.DBName, FDatabase);
  FQuery.Free;
  inherited;
end;

procedure TTestTIDatabase.Transaction_InTransaction;
begin
  FDatabase.Connect(PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '');
  FDatabase.StartTransaction;
  Check(FDatabase.InTransaction, 'Database not in a transaction');
  FDatabase.Commit;
  Check(not FDatabase.InTransaction, 'Database in a transaction when it should not be');
  FDatabase.StartTransaction;
  Check(FDatabase.InTransaction, 'Database not in a transaction');
  FDatabase.RollBack;
  Check(not FDatabase.InTransaction, 'Database in a transaction when it should not be');
  FDatabase.Connected := false;
end;

procedure TTestTIDatabase.CheckFieldMetaData(
  const pDBMetaDataTable: TtiDBMetaDataTable; const AFieldName: string;
  pKind: TtiQueryFieldKind; pWidth: integer);
var
  lField : TtiDBMetaDataField;
begin
  lField := pDBMetaDataTable.FindByFieldName(AFieldName);
  Check(lField <> nil,   'Field <' + AFieldName + '> not found');
// ToDo: The meta data system wont read in field kind or size yet. Requires work.
//      Check(lField.Kind = pKind, 'Field <' + AFieldName + '> field kind of wrong type');
//      if pWidth <> 0 then
//        Check(lField.Width = pWidth, 'Field <' + AFieldName + '> field width of wrong size');
end;

procedure TTestTIQueryAbs.TypeKindToQueryFieldKind;
begin
  Check(tiTypeKindToQueryFieldKind(tiTKInteger) = qfkInteger,  'Failed on tiTKInteger ');
  Check(tiTypeKindToQueryFieldKind(tiTKFloat  ) = qfkFloat   , 'Failed on tiTKFloat   ');
  Check(tiTypeKindToQueryFieldKind(tiTKString ) = qfkString  , 'Failed on tiTKString  ');
  Check(tiTypeKindToQueryFieldKind(tiTKDateTime) = qfkDateTime, 'Failed on tiTKDateTime');
  Check(tiTypeKindToQueryFieldKind(tiTKBoolean) = qfkLogical , 'Failed on tiTKBoolean ');
end;

type

  TThrdDBConnectionPoolTest = class(TtiThread)
  private
    FCycles: integer;
    FDone: Boolean;
    FCritSect: TCriticalSection;
    FDBConnectionPool: TtiDBConnectionPool;
    function GetDone: Boolean;
    procedure SetDone(const Value: Boolean);
  public
    constructor CreateExt(const ADBConnectionPool: TtiDBConnectionPool;
                          const ACycles: integer);
    destructor  Destroy; override;
    procedure   Execute; override;
    property    Done: Boolean read GetDone write SetDone;
  end;

  constructor TThrdDBConnectionPoolTest.CreateExt(
    const ADBConnectionPool: TtiDBConnectionPool;
    const ACycles : integer);
  begin
    Create(true);
    FCritSect:= TCriticalSection.Create;
    FreeOnTerminate := false;
    FCycles := ACycles;
    FDBConnectionPool:= ADBConnectionPool;
    Done := False;
  end;

  destructor TThrdDBConnectionPoolTest.Destroy;
begin
  FCritSect.Free;
  inherited;
end;

  procedure TThrdDBConnectionPoolTest.Execute;
  var
    i : integer;
    LDatabase : TtiDatabase;
  begin
    for i := 1 to FCycles do
    begin
      LDatabase := FDBConnectionPool.Lock;
      Sleep(100);
      FDBConnectionPool.UnLock(LDatabase);
    end;
    Done := True;
  end;

function TThrdDBConnectionPoolTest.GetDone: Boolean;
begin
  FCritSect.Enter;
  try
    result:= FDone;
  finally
    FCritSect.Leave;
  end;
end;

procedure TThrdDBConnectionPoolTest.SetDone(const Value: Boolean);
begin
  FCritSect.Enter;
  try
    FDone:= Value;
  finally
    FCritSect.Leave;
  end;
end;

procedure TTestTIDatabase.DoThreadedDBConnectionPool(
  const ADBConnectionPool: TtiDBConnectionPool; const AThreadCount : integer);
  procedure _CreateThreads(
    const ADBConnectionPool: TtiDBConnectionPool;
    const AList : TList; const AThreadCount, AIterations : integer);
  var
    i : integer;
  begin
    for i := 1 to AThreadCount do
      AList.Add(TThrdDBConnectionPoolTest.CreateExt(
                   ADBConnectionPool,
                   AIterations));
  end;

  procedure _StartThreads(AList : TList);
  var
    i : integer;
  begin
    for i := 0 to AList.Count - 1 do
      TThread(AList.Items[i]).Resume;
  end;

  procedure _WaitForThreads(AList : TList);
  var
    i : integer;
    lAllFinished : boolean;
  begin
    lAllFinished := false;
    while not lAllFinished do
    begin
      lAllFinished := true;
      for i := 0 to AList.Count - 1 do
      begin
        lAllFinished := lAllFinished and TThrdDBConnectionPoolTest(AList.Items[i]).Done;
      end;
      Sleep(100);
    end;
  end;
var
  LList : TObjectList;
begin
  Check(True); // To Force OnCheckCalled to be called
  LList := TObjectList.Create;
  try
    _CreateThreads(ADBConnectionPool, LList, AThreadCount, cuIterations);
    _StartThreads(LList);
    _WaitForThreads(LList);
  finally
    LList.Free;
  end;
end;

procedure TTestTIDatabase.NonThreadedDBConnectionPool;
var
  i : integer;
  LDatabase : TtiDatabase;
  lDBConnectionName : string;
const
  CAlias = 'TestAliasName';
begin
  FPersistenceLayer.DBConnectionPools.Connect(
    CAlias,
    PerFrameworkSetup.DBName,
    PerFrameworkSetup.Username,
    PerFrameworkSetup.Password,
    '');
  try
    lDBConnectionName := PerFrameworkSetup.DBName;
    for i := 1 to 10 do
    begin
      LDatabase := FPersistenceLayer.DBConnectionPools.Lock(CAlias);
      CheckNotNull(LDatabase);
      Sleep(100);
      FPersistenceLayer.DBConnectionPools.UnLock(CAlias, LDatabase);
      Sleep(100);
    end;
  finally
    FPersistenceLayer.DBConnectionPools.Disconnect(CAlias);
  end;
end;

procedure TTestTIDatabase.ThreadedDBConnectionPool;
const
  CAlias = 'TestAliasName';
begin
  FPersistenceLayer.DBConnectionPools.Connect(
    CAlias,
    PerFrameworkSetup.DBName,
    PerFrameworkSetup.Username,
    PerFrameworkSetup.Password,
    '');
  try
    if FPersistenceLayerDefaults.CanSupportMultiUser then
      DoThreadedDBConnectionPool(FPersistenceLayer.DefaultDBConnectionPool, cuThreadCount)
    else
      DoThreadedDBConnectionPool(FPersistenceLayer.DefaultDBConnectionPool, 1)
  finally
    FPersistenceLayer.DBConnectionPools.Disconnect(CAlias);
  end;
end;

constructor TTestTIQueryAbs.Create{$IFNDEF DUNIT2ORFPC}(AMethodName: string){$ENDIF};
begin
  inherited;
  SetupTasks := [sutPerLayer, sutDBConnection ];
end;

{ TTestTIDatabase }

procedure TTestTIDatabase.SetUp;
begin
  inherited;
  FTIOPFManager:= TtiOPFManager.Create;
  FTIOPFManager.PersistenceLayers.__RegisterPersistenceLayer(PerFrameworkSetup.PersistenceLayerClass);
  FPersistenceLayer:= FTIOPFManager.DefaultPerLayer;
  FPersistenceLayerDefaults:= TtiPersistenceLayerDefaults.Create;
  FPersistenceLayer.AssignPersistenceLayerDefaults(FPersistenceLayerDefaults);
  FDatabaseClass := FPersistenceLayer.DatabaseClass;
  FDatabase := FDatabaseClass.Create;
end;

procedure TTestTIDatabase.TearDown;
begin
  if FDatabase.Connected then
    FDatabase.Connected := false;
  FreeAndNil(FDatabase);
  FDatabaseClass := nil;
  FreeAndNil(FTIOPFManager);
  FreeAndNil(FPersistenceLayerDefaults);
  inherited;
end;

procedure TTestTIDatabase.Transaction_Commit;
var
  lQuery : TtiQuery;
begin
  FDatabase.Connect(PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '');
  try FDatabase.DropTable(cTableNameTestGroup) except end;

  CreateTableTestGroup(FDatabase);

  FDatabase.StartTransaction;
  try
    InsertIntoTestGroup(FDatabase, 1);
    FDatabase.Commit;
    lQuery := FPersistenceLayer.QueryClass.Create;
    try
      lQuery.AttachDatabase(FDatabase);
      FDatabase.StartTransaction;
      lQuery.SelectRow(cTableNameTestGroup, nil);
      Check(not lQuery.EOF, 'Transaction not committed');
      lQuery.Next;
      Check(lQuery.EOF, 'Wrong number of records');
      FDatabase.Commit;
    finally
      lQuery.Free;
    end;
  finally
    FDatabase.DropTable(cTableNameTestGroup);
  end;
end;

procedure TTestTIDatabase.Transaction_RollBack;
var
  lQuery : TtiQuery;
  lEOF : boolean;
begin
  FDatabase.Connect(PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '');
  try FDatabase.DropTable(cTableNameTestGroup) except end;
  CreateTableTestGroup(FDatabase);

  FDatabase.StartTransaction;
  try
    InsertIntoTestGroup(FDatabase, 1);
    FDatabase.RollBack;
    lQuery := FPersistenceLayer.QueryClass.Create;
    try
      lQuery.AttachDatabase(FDatabase);
      FDatabase.StartTransaction;
      lQuery.SelectRow(cTableNameTestGroup, nil);
      lEOF := lQuery.EOF;
      Check(lEOF, 'Transaction not rolled back');
      FDatabase.Commit;
    finally
      lQuery.Free;
    end;
  finally
    FDatabase.DropTable(cTableNameTestGroup);
  end;
end;

procedure TTestTIDatabase.CreateTableDropTable_Timing;
var
  lTable1         : TtiDBMetaDataTable;
  lTable2         : TtiDBMetaDataTable;
  lCreateTableTime : DWord;
  lDropTableTime  : DWord;
  lMetaDataTime   : DWord;
  LBulkTestStart:   DWord;
  LSingleTestStart: DWord;
  LCount               : integer;
begin
  Check(True); // To Force OnCheckCalled to be called
  lCreateTableTime := 0;
  lDropTableTime  := 0;
  lMetaDataTime   := 0;
  FDatabase.Connect(PerFrameworkSetup.DBName,
                     PerFrameworkSetup.UserName,
                     PerFrameworkSetup.Password,
                     '');
  try
    try FDatabase.DropTable(cTableNameCreateTable) except end;
    
    lTable1 := TtiDBMetaDataTable.Create;
    try
      lTable1.Name := cTableNameCreateTable;
      lTable2 := TtiDBMetaDataTable.Create;
      try
        lTable2.Name := cTableNameCreateTable;
        lTable1.AddField('test', qfkString, 10);
        LCount:= 0;
        LBulkTestStart:= tiGetTickCount;
        while (tiGetTickCount - LBulkTestStart) < (CTimingTestPeriod*1000) do
        begin
          Inc(LCount);
          // Create Table
          LSingleTestStart := tiGetTickCount;
          FDatabase.CreateTable(lTable1);
          Inc(lCreateTableTime, tiGetTickCount - LSingleTestStart);

          // Meta Data
          lTable2.Clear;
          LSingleTestStart := tiGetTickCount;
          FDatabase.ReadMetaDataFields(lTable2);
          Inc(lMetaDataTime, tiGetTickCount - LSingleTestStart);

          // Drop Table
          LSingleTestStart := tiGetTickCount;
          FDatabase.DropTable(cTableNameCreateTable);
          Inc(lDropTableTime, tiGetTickCount - LSingleTestStart);

        end;
        WriteTimingResult('TableTestIterationCount',     PerFrameworkSetup.PerLayerName, LCount);
        WriteTimingResult('TotalTestTime',  PerFrameworkSetup.PerLayerName, CTimingTestPeriod);
        WriteTimingResult('CreateTable',    PerFrameworkSetup.PerLayerName, tiSafeDiv(lCreateTableTime, LCount));
        WriteTimingResult('DropTableTable', PerFrameworkSetup.PerLayerName, tiSafeDiv(lDropTableTime, LCount));
        WriteTimingResult('ReadMetaData',   PerFrameworkSetup.PerLayerName, tiSafeDiv(lMetaDataTime, LCount));
      finally
        lTable2.Free;
      end;
    finally
      lTable1.Free;
    end;

  finally
    FDatabase.Connected := false;
  end;
end;

{ TTestTIMetaData }

procedure TTestTIMetaData.DBMetaDataAdd;
var
  lList : TtiDBMetaData;
  lData : TtiDBMetaDataTable;
begin
  lList := TtiDBMetaData.Create;
  try
    CheckEquals(0, lList.Count, 'Count');
    lData := TtiDBMetaDataTable.Create;
    lList.Add(lData);
    CheckEquals(1, lList.Count, 'Count');
    CheckSame(lData, lList.Items[0]);
    lList.Clear;
    CheckEquals(0, lList.Count, 'Count');
  finally
    lList.Free;
  end;
end;

procedure TTestTIMetaData.DBMetaDataFindByTableName;
var
  lList : TtiDBMetaData;
  lData : TtiDBMetaDataTable;
begin
  lList := TtiDBMetaData.Create;
  try
    lData := TtiDBMetaDataTable.Create;
    lData.Name := 'test1';
    lList.Add(lData);
    lData := TtiDBMetaDataTable.Create;
    lData.Name := 'test2';
    lList.Add(lData);
    lData := TtiDBMetaDataTable.Create;
    lData.Name := 'test3';
    lList.Add(lData);

    lData := lList.FindByTableName('test2');
    CheckNotNull(lData);
    CheckEquals('test2', lData.Name);

    lData := lList.FindByTableName('TEST3');
    CheckNotNull(lData);
    CheckEquals('test3', lData.Name);

  finally
    lList.Free;
  end;
end;

procedure TTestTIMetaData.MetaDataFieldClone;
var
  lField1 : TtiDBMetaDataField;
  lField2 : TtiDBMetaDataField;
begin
  lField1 := TtiDBMetaDataField.Create;
  try
    lField1.Name := 'test';
    lField1.Width := 10;
    lField1.Kind := qfkString;
    lField2 := lField1.Clone;
    try
      CheckEquals(lField1.Name, lField2.Name, 'lTable2.Name');
      CheckEquals(lField1.Width, lField2.Width, 'lTable2.Width');
      CheckEquals(lField1.KindAsStr, lField2.KindAsStr, 'lTable2.KindAsStr');
    finally
      lField2.Free;
    end;
  finally
    lField1.Free;
  end;
end;

procedure TTestTIMetaData.MetaDataTableAdd;
var
  lList : TtiDBMetaDataTable;
  lData : TtiDBMetaDataField;
begin
  lList := TtiDBMetaDataTable.Create;
  try
    CheckEquals(0, lList.Count, 'Count');
    lData := TtiDBMetaDataField.Create;
    lList.Add(lData);
    CheckEquals(1, lList.Count, 'Count');
    CheckSame(lData, lList.Items[0]);
    lList.Clear;
    CheckEquals(0, lList.Count, 'Count');
  finally
    lList.Free;
  end;
end;

procedure TTestTIMetaData.MetaDataTableAddField;
var
  lList : TtiDBMetaDataTable;
begin
  lList := TtiDBMetaDataTable.Create;
  try
    CheckEquals(0, lList.Count, 'Count');
    lList.AddField('test1', qfkString, 10);
    CheckEquals(1, lList.Count, 'Count');
    lList.AddField('test2', qfkInteger);
    CheckEquals(2, lList.Count, 'Count');
    lList.AddField('test3', qfkFloat);
    CheckEquals(3, lList.Count, 'Count');
    lList.AddField('test4', qfkDateTime);
    CheckEquals(4, lList.Count, 'Count');
    lList.AddField('test5', qfkLogical);
    CheckEquals(5, lList.Count, 'Count');
    lList.Clear;
    CheckEquals(0, lList.Count, 'Count');
  finally
    lList.Free;
  end;
end;

procedure TTestTIMetaData.MetaDataTableClone;
var
  lTable1 : TtiDBMetaDataTable;
  lTable2 : TtiDBMetaDataTable;
  lData : TtiDBMetaDataField;
begin
  lTable1 := TtiDBMetaDataTable.Create;
  try
    lTable1.Name := 'test';
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'test';
    lData.Width := 10;
    lData.Kind := qfkString;
    lTable1.Add(lData);

    lTable2 := lTable1.Clone;
    try
      CheckEquals('test', lTable2.Name, 'Name');
      CheckEquals(lTable1.Count, lTable2.Count, 'Count');
      CheckEquals(lTable1.Items[0].Name, lTable2.Items[0].Name, 'lTable2.Items[0].Name');
      CheckEquals(lTable1.Items[0].Width, lTable2.Items[0].Width, 'lTable2.Items[0].Width');
      CheckEquals(lTable1.Items[0].KindAsStr, lTable2.Items[0].KindAsStr, 'lTable2.Items[0].KindAsStr');
    finally
      lTable2.Free;
    end;

  finally
    lTable1.Free;
  end;
end;

procedure TTestTIMetaData.MetaDataTableFindByFieldName;
var
  lList : TtiDBMetaDataTable;
  lData : TtiDBMetaDataField;
begin
  lList := TtiDBMetaDataTable.Create;
  try
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'test1';
    lList.Add(lData);
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'test2';
    lList.Add(lData);
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'test3';
    lList.Add(lData);

    lData := lList.FindByFieldName('test2');
    CheckNotNull(lData);
    CheckEquals('test2', lData.Name);

    lData := lList.FindByFieldName('TEST3');
    CheckNotNull(lData);
    CheckEquals('test3', lData.Name);

  finally
    lList.Free;
  end;
end;

procedure TTestTIMetaData.MetaDataTableMaxFieldNameWidth;
var
  lList : TtiDBMetaDataTable;
  lData : TtiDBMetaDataField;
begin
  lList := TtiDBMetaDataTable.Create;
  try
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'a';
    lList.Add(lData);
    CheckEquals(1, lList.MaxFieldNameWidth);
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'ab';
    lList.Add(lData);
    CheckEquals(2, lList.MaxFieldNameWidth);
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'abc';
    lList.Add(lData);
    CheckEquals(3, lList.MaxFieldNameWidth);
    lData := TtiDBMetaDataField.Create;
    lData.Name := 'def';
    lList.Add(lData);
    CheckEquals(3, lList.MaxFieldNameWidth);

  finally
    lList.Free;
  end;
end;

procedure TTestTIQueryAbs.ConfirmSetupWorks;
begin
  CheckNotNull(FPersistenceLayer, 'RegPerlayerNotAssigned');
  CheckEquals(PerFrameworkSetup.PerLayerName, FPersistenceLayer.PersistenceLayerName, 'Wrong RegPerLayer');
  Check(not FDatabase.InTransaction, 'Database InTransaction when it should not be');
end;

procedure TTestTIQueryAbs.ConfirmDBConnectionWorks;
begin
  DoAttachAndConnect;
  try
    Check(FDatabase.InTransaction, 'Database not InTransaction when it should be');
    // Do nothing;
  finally
    DoDetachAndDisconnect;
  end;
end;

procedure TTestTIQueryAbs.PopulateTableString(const AValue : String);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsString(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableName, lParams);
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryAbs.FieldAsStringLong1;
begin
  DoFieldAsStringLong(    1);
end;

procedure TTestTIQueryAbs.FieldAsStringLong10;
begin
  DoFieldAsStringLong(   10);
end;

procedure TTestTIQueryAbs.FieldAsStringLong100;
begin
  DoFieldAsStringLong(  100);
end;

procedure TTestTIQueryAbs.FieldAsStringLong255;
begin
  DoFieldAsStringLong(  255);
end;

procedure TTestTIQueryAbs.FieldAsStringLong256;
begin
  DoFieldAsStringLong(  256);
end;

procedure TTestTIQueryAbs.FieldAsStringLong257;
begin
  DoFieldAsStringLong(  257);
end;

procedure TTestTIQueryAbs.FieldAsStringLong511;
begin
  DoFieldAsStringLong(  511);
end;

procedure TTestTIQueryAbs.FieldAsStringLong512;
begin
  DoFieldAsStringLong(  512);
end;

procedure TTestTIQueryAbs.FieldAsStringLong513;
begin
  DoFieldAsStringLong(  513);
end;

procedure TTestTIQueryAbs.FieldAsStringLong1023;
begin
  DoFieldAsStringLong( 1023);
end;

procedure TTestTIQueryAbs.FieldAsStringLong1024;
begin
  DoFieldAsStringLong( 1024);
end;

procedure TTestTIQueryAbs.FieldAsStringLong1025;
begin
  DoFieldAsStringLong( 1025);
end;

procedure TTestTIQueryAbs.FieldAsStringLong5000;
begin
  DoFieldAsStringLong( 5000);
end;

procedure TTestTIQueryAbs.FieldAsStringLong10000;
begin
  DoFieldAsStringLong(10000);
end;

procedure TTestTIQueryAbs.DoFieldAsStringLong(pStrLen : integer);
var
  lValue : string;
  lTarget : string;
begin
  lTarget := tiCreateStringOfSize(pStrLen);
  CreateTableLongString(Database);
  try
    DoAttachAndConnect;
    try
      PopulateTableString(lTarget);
      DoReAttach;
      FQuery.SelectRow(cTIQueryTableName, nil);
      lValue := FQuery.FieldAsString[ cTIQueryColName ];

      CheckEquals(Length(lTarget), Length(lValue), 'FieldAsString: ' + IntToStr(pStrLen));
      CheckEquals(lTarget, lValue, 'FieldAsString: ' + IntToStr(pStrLen));

      lValue := FQuery.FieldAsStringByIndex[ cFieldAs_Index ];
      CheckEquals(lTarget, lValue, 'FieldAsStringByIndex: ' + IntToStr(pStrLen));

      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;

procedure TTestTIQueryAbs.DropTestTable;
begin
  Assert(FDatabase <> nil, 'FDatabase not assigned');
  try FDatabase.DropTable(cTIQueryTableName) except end;
end;

procedure TTestTIQueryAbs.PopulateTableReal(const AValue: Extended);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsFloat(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableName, lParams);
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryAbs.PopulateTableInteger(const AValue: Integer);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsInteger(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableName, lParams);
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryAbs.PopulateTableDateTime(const AValue: TDateTime);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsDateTime(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableName, lParams);
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryAbs.PopulateTableBoolean(const AValue: Boolean);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsBoolean(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableName, lParams);
  finally
    lParams.Free;
  end;
end;

{ TTestTIQueryParams }

procedure TTestTIQueryParams.AsBoolean;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsBoolean('param1', True);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamBoolean, 'Wrong class');
    CheckEquals(True, lParams.GetValueAsBoolean('param1'), 'GetValueAsBoolean failed');
    CheckEquals('T', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lParams.SetValueAsString('param1', 'False');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamBoolean, 'Wrong class');
    CheckEquals(False, lParams.GetValueAsBoolean('param1'), 'GetValueAsBoolean failed');
    CheckEquals('F', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsDateTime;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
  lDate : TDateTime;
begin
  lDate := EncodeDate(2004, 01, 01);
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsDateTime('param1', lDate);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamDateTime, 'Wrong class');
    CheckEquals(lDate, lParams.GetValueAsDateTime('param1'), 0.0001, 'GetValueAsDateTime failed');
    CheckEquals(tiDateTimeAsXMLString(lDate), lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lDate := EncodeDate(2004, 02, 02);
    lParams.SetValueAsString('param1', tiDateTimeAsXMLString(lDate));
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamDateTime, 'Wrong class');
    CheckEquals(lDate, lParams.GetValueAsDateTime('param1'), 0.0001, 'GetValueAsDateTime failed');
    CheckEquals(tiDateTimeAsXMLString(lDate), lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsFloat;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsFloat('param1', 123.456);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamFloat, 'Wrong class');
    CheckEquals(123.456, lParams.GetValueAsFloat('param1'), 0.0001, 'GetValueAsFloat failed');
    CheckEquals('123.456', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lParams.SetValueAsString('param1', '456.789');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamFloat, 'Wrong class');
    CheckEquals(456.789, lParams.GetValueAsFloat('param1'), 0.0001,  'GetValueAsFloat failed');
    CheckEquals('456.789', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsInteger;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsInteger('param1', 123);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamInteger, 'Wrong class');
    CheckEquals(123, lParams.GetValueAsInteger('param1'), 'GetValueAsInteger failed');
    CheckEquals('123', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lParams.SetValueAsString('param1', '456');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamInteger, 'Wrong class');
    CheckEquals(456, lParams.GetValueAsInteger('param1'), 'GetValueAsInteger failed');
    CheckEquals('456', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsStream;
var
  lParams : TtiQueryParams;
  lParam  : TtiQueryParamAbs;
  lStream1 : TStringStream;
  lStream2 : TStream;
  ls      : string;
begin
  lStream1 := TStringStream.Create(LongString);
  try
      lParams := TtiQueryParams.Create;
      try
        lParams.SetValueAsStream('param1', lStream1);
        CheckEquals(1, lParams.Count, 'Count');
        lParam := lParams.Items[0];
        CheckNotNull(lParams, 'NotNull failed');
        CheckIs(lParam, TtiQueryParamStream, 'Wrong class');
        lStream2 := lParams.GetValueAsStream('param1');
        CheckStreamContentsSame(lStream1, lStream2);
        ls := lParams.GetValueAsString('param1');
        // Because, it's MIME encoded when it's read out as a string
        // (for persisting to a DB that does not have a native BIN field type)
        ls := MimeDecodeString(ls);
        CheckEquals(LongString, ls, 'GetValueAsString failed');

        lStream1.WriteString('a');
        lParams.SetValueAsStream('param1', lStream1);
        CheckEquals(1, lParams.Count, 'Count');
        lParam := lParams.Items[0];
        CheckNotNull(lParams, 'NotNull failed');
        CheckIs(lParam, TtiQueryParamStream, 'Wrong class');
        lStream2 := lParams.GetValueAsStream('param1');
        CheckStreamContentsSame(lStream1, lStream2);
        ls := lParams.GetValueAsString('param1');
        // Because, it's MIME encoded when it's read out as a string
        // (for persisting to a DB that does not have a native BIN field type)
        ls := MimeDecodeString(ls);
        CheckEquals(LongString+'a', ls, 'GetValueAsString failed');

      finally
        lParams.Free;
      end;
  finally
    lStream1.Free;
  end;
end;

procedure TTestTIQueryParams.AsString;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsString('param1', 'test');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamString, 'Wrong class');
    CheckEquals('test', lParams.GetValueAsString('param1'), 'GetValueAsString failed');
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsVariant_Boolean;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsVariant('param1', True);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamBoolean, 'Wrong class');
    CheckEquals(True, lParams.GetValueAsBoolean('param1'), 'GetValueAsBoolean failed');
    CheckEquals('T', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lParams.SetValueAsVariant('param1', 'False');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamBoolean, 'Wrong class');
    CheckEquals(False, lParams.GetValueAsBoolean('param1'), 'GetValueAsBoolean failed');
    CheckEquals('F', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsVariant_DateTime;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
  lDate : TDateTime;
begin
  lDate := EncodeDate(2004, 01, 01);
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsVariant('param1', lDate);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamDateTime, 'Wrong class');
    CheckEquals(lDate, lParams.GetValueAsDateTime('param1'), 0.0001, 'GetValueAsDateTime failed');

    lDate := EncodeDate(2004, 02, 02);
    lParams.SetValueAsVariant('param1', tiDateTimeAsXMLString(lDate));
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamDateTime, 'Wrong class');
    CheckEquals(lDate, lParams.GetValueAsDateTime('param1'), 0.0001, 'GetValueAsDateTime failed');
    CheckEquals(tiDateTimeAsXMLString(lDate), lParams.GetValueAsString('param1'), 'GetValueAsString failed');
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsVariant_Float;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsVariant('param1', 123.456);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamFloat, 'Wrong class');
    CheckEquals(123.456, lParams.GetValueAsFloat('param1'), 0.0001, 'GetValueAsFloat failed');
    CheckEquals('123.456', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lParams.SetValueAsVariant('param1', '456.789');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamFloat, 'Wrong class');
    CheckEquals(456.789, lParams.GetValueAsFloat('param1'), 0.0001,  'GetValueAsFloat failed');
    CheckEquals('456.789', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsVariant_Integer;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsVariant('param1', 123);
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamInteger, 'Wrong class');
    CheckEquals(123, lParams.GetValueAsInteger('param1'), 'GetValueAsInteger failed');
    CheckEquals('123', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

    lParams.SetValueAsVariant('param1', '456');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamInteger, 'Wrong class');
    CheckEquals(456, lParams.GetValueAsInteger('param1'), 'GetValueAsInteger failed');
    CheckEquals('456', lParams.GetValueAsString('param1'), 'GetValueAsString failed');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.AsVariant_String;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsVariant('param1', 'test');
    CheckEquals(1, lParams.Count, 'Count');
    lParam := lParams.Items[0];
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamString, 'Wrong class');
    CheckEquals('test', lParams.GetValueAsString('param1'), 'GetValueAsString failed');
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.ParamByName;
var
  lParams : TtiQueryParams;
  lParam : TtiQueryParamAbs;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsString( 'paramS', 'test');
    CheckEquals(1, lParams.Count, 'Count');
    lParams.SetValueAsInteger('paramI', 123);
    CheckEquals(2, lParams.Count, 'Count');
    lParams.SetValueAsFloat(  'paramF', 123.456);
    CheckEquals(3, lParams.Count, 'Count');
    lParams.SetValueAsDateTime('paramD', Date);
    CheckEquals(4, lParams.Count, 'Count');
    lParams.SetValueAsBoolean('paramB', True);
    CheckEquals(5, lParams.Count, 'Count');

    lParam := lParams.FindParamByName('paramS');
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamString, 'Wrong class');

    lParam := lParams.FindParamByName('paramI');
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamInteger, 'Wrong class');

    lParam := lParams.FindParamByName('paramF');
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamFloat, 'Wrong class');

    lParam := lParams.FindParamByName('paramD');
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamDateTime, 'Wrong class');

    lParam := lParams.FindParamByName('paramB');
    CheckNotNull(lParams, 'NotNull failed');
    CheckIs(lParam, TtiQueryParamBoolean, 'Wrong class');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.ParamIsNull;
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsString( 'paramS', 'test');
    lParams.SetValueAsInteger('paramI', 123);
    lParams.SetValueAsFloat(  'paramF', 123.456);
    lParams.SetValueAsDateTime('paramD', Date);
    lParams.SetValueAsBoolean('paramB', True);

    Check(lParams.ParamIsNull['parmaS'], 'String param null');
    Check(lParams.ParamIsNull['parmaI'], 'Integer param null');
    Check(lParams.ParamIsNull['parmaF'], 'Float param null');
    Check(lParams.ParamIsNull['parmaD'], 'Date param null');
    Check(lParams.ParamIsNull['parmaB'], 'Boolean param null');

    lParams.ParamIsNull[ 'paramS' ]:= true;
    lParams.ParamIsNull[ 'paramI' ]:= true;
    lParams.ParamIsNull[ 'paramF' ]:= true;
    lParams.ParamIsNull[ 'paramD' ]:= true;
    lParams.ParamIsNull[ 'paramB' ]:= true;

    Check(lParams.ParamIsNull['parmaS'], 'String param not null');
    Check(lParams.ParamIsNull['parmaI'], 'Integer param not null');
    Check(lParams.ParamIsNull['parmaF'], 'Float param not null');
    Check(lParams.ParamIsNull['parmaD'], 'Date param not null');
    Check(lParams.ParamIsNull['parmaB'], 'Boolean param not null');

  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryParams.TestCheckStreamContentsSame;
var
  lStreamFrom : TStringStream;
  lStreamTo  : TStream;
  lResult    : boolean;
  lMessage   : string;
begin
  lStreamFrom := TStringStream.Create(LongString);
  try
    lStreamTo := TStringStream.Create(LongString);
    try
      lResult := AreStreamContentsSame(lStreamFrom, lStreamTo, lMessage);
      Check(lResult, 'Returned FALSE but should have returned TRUE');
    finally
      lStreamTo.Free;
    end;
  finally
    lStreamFrom.Free;
  end;

  lStreamFrom := TStringStream.Create(LongString);
  try
    lStreamTo := TStringStream.Create(LongString + 'a');
    try
      lResult := AreStreamContentsSame(lStreamFrom, lStreamTo, lMessage);
      Check(not lResult, 'Returned TRUE but should have returned FALSE <' + lMessage + '>');
    finally
      lStreamTo.Free;
    end;
  finally
    lStreamFrom.Free;
  end;

  lStreamFrom := TStringStream.Create(LongString);
  try
    lStreamTo := TStringStream.Create(Copy(LongString, 1, Length(LongString) - 1) + 'a');
    try
      lResult := AreStreamContentsSame(lStreamFrom, lStreamTo, lMessage);
      Check(not lResult, 'Returned TRUE but should have returned FALSE <' + lMessage + '>');
    finally
      lStreamTo.Free;
    end;
  finally
    lStreamFrom.Free;
  end;

end;

procedure TTestTIQueryAbs.FieldAsStream;
var
  lStream1 : TStringStream;
  lStream2 : TMemoryStream;
begin
  CreateTableStream(FDatabase);
  try
    DoAttachAndConnect;
    try
      lStream1 := TStringStream.Create(tiCreateStringOfSize(1000));
      try
        PopulateTableStream(lStream1);
        DoReAttach;
        FQuery.SelectRow(cTIQueryTableName, nil);
        lStream2 := TMemoryStream.Create;
        try
          FQuery.AssignFieldAsStream(cTIQueryColName, lStream2);
          CheckStreamContentsSame(lStream1, lStream2);
          lStream2.Size := 0;
          FQuery.AssignFieldAsStreamByIndex(cFieldAs_Index, lStream2);
          CheckStreamContentsSame(lStream1, lStream2);
        finally
          lStream2.Free;
        end;
        FQuery.Close;
      finally
        lStream1.Free;
      end;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
end;

procedure TTestTIQueryAbs.PopulateTableStream(const AValue: TStream);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    lParams.SetValueAsStream(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableName, lParams);
  finally
    lParams.Free;
  end;
end;

procedure TTestTIQueryAbs.InsertDeleteUpdate_Timing;
var
  lParams : TtiQueryParams;
  lInsertTime : DWord;
  lUpdateTime : DWord;
  lDeleteTime : DWord;
  LSingleTestStart     : DWord;
  LCount : integer;
  LBulkTestStart: DWord;
begin
  Check(True); // To Force OnCheckCalled to be called
  lInsertTime := 0;
  lUpdateTime := 0;
  lDeleteTime := 0;
  CreateTableString(FDatabase);
  try
    FQuery.AttachDatabase(FDatabase);
    try

      lParams := TtiQueryParams.Create;
      try
        lParams.SetValueAsString(cTIQueryColName, 'test');

        LCount:= 0;
        LBulkTestStart:= tiGetTickCount;
        while (tiGetTickCount - LBulkTestStart) < (CTimingTestPeriod*1000) do
        begin
          Inc(LCount);

          LSingleTestStart := tiGetTickCount;
          FDatabase.StartTransaction;
          FQuery.InsertRow(cTIQueryTableName, lParams);
          FDatabase.Commit;
          Inc(lInsertTime, tiGetTickCount - LSingleTestStart);
          FQuery.Close;

          LSingleTestStart := tiGetTickCount;
          FDatabase.StartTransaction;
          FQuery.UpdateRow(cTIQueryTableName, lParams, lParams);
          FDatabase.Commit;
          Inc(lUpdateTime, tiGetTickCount - LSingleTestStart);
          FQuery.Close;

          LSingleTestStart := tiGetTickCount;
          FDatabase.StartTransaction;
          FQuery.DeleteRow(cTIQueryTableName, lParams);
          FDatabase.Commit;
          Inc(lDeleteTime, tiGetTickCount - LSingleTestStart);
          FQuery.Close;
        end;

      finally
        lParams.Free;
      end;
    finally
      FQuery.DetachDatabase;
    end;
  finally
    DropTestTable;
  end;
  WriteTimingResult('RowTestIterationCount',  PerFrameworkSetup.PerLayerName, LCount);
  WriteTimingResult('TotalTestTime', PerFrameworkSetup.PerLayerName, CTimingTestPeriod);
  WriteTimingResult('InsertRow',     PerFrameworkSetup.PerLayerName, tiSafeDiv(lInsertTime, LCount));
  WriteTimingResult('UpdateRow',     PerFrameworkSetup.PerLayerName, tiSafeDiv(lUpdateTime, LCount));
  WriteTimingResult('DeleteRow',     PerFrameworkSetup.PerLayerName, tiSafeDiv(lDeleteTime, LCount));
end;

{$IFDEF TESTINT64}
procedure TTestTIQueryAbs.PopulateTableInt64(const AValue: Int64);
var
  lParams : TtiQueryParams;
begin
  lParams := TtiQueryParams.Create;
  try
    FDatabase.DeleteRow(cTIQueryTableNameInt64, nil);
    lParams.SetValueAsInteger(cTIQueryColName, AValue);
    FDatabase.InsertRow(cTIQueryTableNameInt64, lParams);
  finally
    lParams.Free;
  end;
end;
{$ENDIF}

procedure TTestTIQueryAbs.FieldByNameVSFieldByIndex;
const
  cString = 'abcdefghij';
  cCount  = 1000000;
  cImprovement = 100;
var
  lStart : DWord;
  i : Integer;
  lByName : DWOrd;
  lByIndex : DWord;
//  lRatio  : Extended;
begin
  CreateTableString(FDatabase);
  try
    DoAttachAndConnect;
    try
      PopulateTableString(cString);
      FQuery.SelectRow(cTIQueryTableName, nil);
      lStart := tiGetTickCount;
      for i := 1 to cCount do
        FQuery.FieldAsString[ cTIQueryColName ];
      lByName := tiGetTickCount - lStart;

      lStart := tiGetTickCount;
      for i := 1 to cCount do
        FQuery.FieldAsStringByIndex[ cFieldAs_Index ];
      lByIndex := tiGetTickCount - lStart;

      FQuery.Close;
    finally
      DoDetachAndDisconnect;
    end;
  finally
    DropTestTable;
  end;
  Check(lByIndex < lByName, 'It got slower. ByIndex: ' +
         IntToStr(lByIndex) + ' ByName: ' + IntToStr(lByName));
//  lRatio := 10000 / (lByIndex * 10000 div lByName);
//  Check(lRatio > cImprovement, 'Not fast enough: ' + tiFloatToStr(lRatio, 2) + ' x faster (should be ' + IntToStr(cImprovement) + ')');

end;

procedure TTestTIQueryAbs.FieldAsStringLong1999;
begin
  DoFieldAsStringLong(1999);
end;

procedure TTestTIQueryAbs.FieldAsStringLong2000;
begin
  DoFieldAsStringLong(2000);
end;

procedure TTestTIQueryAbs.FieldAsStringLong2001;
begin
  DoFieldAsStringLong(2001);
end;

procedure TTestTIQueryAbs.FieldAsStringLong3999;
begin
  DoFieldAsStringLong(3999);
end;

procedure TTestTIQueryAbs.FieldAsStringLong4000;
begin
  DoFieldAsStringLong(4000);
end;

procedure TTestTIQueryAbs.FieldAsStringLong4001;
begin
  DoFieldAsStringLong(4001);
end;

procedure TTestTIPersistenceLayers.ConnectDatabase;
var
  LPersistenceLayer: TtiPersistenceLayer;
const
  CDatabaseAlias = 'TestDatabaseAlias';  
begin
  CreateDBIfNotExists;
  LPersistenceLayer:= PerFrameworkSetup.PersistenceLayerClass.Create;
  try
    LPersistenceLayer.DBConnectionPools.Connect(
      CDatabaseAlias,
      PerFrameworkSetup.DBName,
      PerFrameworkSetup.Username,
      PerFrameworkSetup.Password,
      '');
    try
      CheckNotNull(LPersistenceLayer.DefaultDBConnectionPool, 'DefaultDBConnectionPool');
      CheckEquals(CDatabaseAlias, LPersistenceLayer.DefaultDBConnectionName, 'DefaultDBConnectionName');
      CheckEquals(1, LPersistenceLayer.DBConnectionPools.Count, 'lRegPerLayer.DBConnectionPools.Count');
      CheckEquals(1, LPersistenceLayer.DefaultDBConnectionPool.Count, 'lRegPerLayer.DefaultDBConnectionPool.Count');
    finally
      LPersistenceLayer.DBConnectionPools.Disconnect(CDatabaseAlias);
    end;
    CheckNull(LPersistenceLayer.DefaultDBConnectionPool, 'DefaultDBConnectionPool');
    CheckEquals( '', LPersistenceLayer.DefaultDBConnectionName, 'DefaultDBConnectionName');
  finally
    LPersistenceLayer.Free;
  end;
end;

end.
