object CashInCashOutReportDataModule: TCashInCashOutReportDataModule
  OldCreateOrder = False
  Left = 251
  Top = 253
  Height = 540
  Width = 783
  object CashInCashOutReport: TfrReport
    Dataset = TransactionDataset
    InitialZoom = pzDefault
    PreviewButtons = [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit]
    StoreInDFM = True
    OnGetValue = CashInCashOutReportGetValue
    Left = 48
    Top = 24
    ReportForm = {
      17000000130B000017000000000C0043616E6F6E2053323030535000FF090000
      00340800009A0B000000000000000000000000000000000000000000FFFF0100
      00000000000002000B005061676548656164657231000000000018000000F002
      0000280000003000020001000000000000000000FFFFFF1F0000000000000000
      0000000000FFFF02000D004D6173746572486561646572310000000000580000
      00F0020000180000003000040001000000000000000000FFFFFF1F0000000000
      0000000000000000FFFF02000A004D6173746572446174610000000000900000
      00F0020000180000003000050001000000000000000000FFFFFF1F0000000012
      005472616E73616374696F6E4461746173657400000000000000FFFF02000D00
      4D6173746572466F6F74657231000000000000010000F0020000280000003000
      060001000000000000000000FFFFFF1F00000000000000000000000000FFFF02
      000B0050616765466F6F746572310000000000BC000000F00200002800000030
      00030001000000000000000000FFFFFF1F00000000000000000000000000FFFF
      000005004D656D6F3100940200005B0000004C0000000F000000030000000100
      0000000000000000FFFFFF1F2E0200000000000100050056616C756500000000
      FFFF0500417269616C0008000000020000000000010000000000020000000000
      FFFFFF00000000000005004D656D6F3200900200009300000050000000120000
      000300000001000000000000000000FFFFFF1F2E02010100000001002700245B
      5472616E73616374696F6E51756572792E225452414E53414354494F4E5F5641
      4C5545225D00000000FFFF0500417269616C0008000000000000000000010000
      000000020000000000FFFFFF00000000000005004D656D6F33000F0000001C00
      000020010000120000000300000001000000000000000000FFFFFF1F2E020000
      000000010007005B5449544C455D00000000FFFF0500417269616C000A000000
      020000000000000000000000020000000000FFFFFF00000000000005004D656D
      6F34000F0000005B0000005C0000000F00000003000000010000000000000000
      00FFFFFF1F2E0200000000000100090054696D657374616D7000000000FFFF05
      00417269616C0008000000020000000000000000000000020000000000FFFFFF
      00000000000005004D656D6F35000F0000009300000080000000120000000300
      000001000000000000000000FFFFFF1F2E02000000000001002A005B5472616E
      73616374696F6E51756572792E225452414E53414354494F4E5F54494D455354
      414D50225D00000000FFFF0500417269616C0008000000000000000000000000
      000000020000000000FFFFFF00000000000005004D656D6F3600FC0000005B00
      00004C0000000F0000000300000001000000000000000000FFFFFF1F2E020000
      00000001000C00436F6E7472616374206E6F2E00000000FFFF0500417269616C
      0008000000020000000000000000000000020000000000FFFFFF000000000000
      05004D656D6F3700FC0000009300000050000000120000000300000001000000
      000000000000FFFFFF1F2E02000000000001004C005B5472616E73616374696F
      6E51756572792E22434F4E54524143545F4E554D424552225D2045205B547261
      6E73616374696F6E51756572792E22455854454E53494F4E5F4E554D42455222
      5D00000000FFFF0500417269616C000800000000000000000000000000000002
      0000000000FFFFFF00000000000006004D656D6F3130004C0100005B00000044
      0000000F0000000300000001000000000000000000FFFFFF1F2E020000000000
      01000A00436C69656E74206E6F2E00000000FFFF0500417269616C0008000000
      020000000000000000000000020000000000FFFFFF00000000000006004D656D
      6F31310050010000930000004400000012000000030000000100000000000000
      0000FFFFFF1F2E020000000000010022005B5472616E73616374696F6E517565
      72792E22434C49454E545F4E554D424552225D00000000FFFF0500417269616C
      0008000000000000000000000000000000020000000000FFFFFF000000000000
      06004D656D6F313200940100005B000000540000001200000003000000010000
      00000000000000FFFFFF1F2E02000000000002000B00436C69656E74206E616D
      650D000000000000FFFF0500417269616C000800000002000000000000000000
      0000020000000000FFFFFF00000000000006004D656D6F313300980100009300
      0000C4000000120000000300000001000000000000000000FFFFFF1F2E020000
      000000010042005B5472616E73616374696F6E51756572792E22474956454E5F
      4E414D4553225D205B5472616E73616374696F6E51756572792E2246414D494C
      595F4E414D45225D2000000000FFFF0500417269616C00080000000000000000
      00000000000000020000000000FFFFFF00000000000005004D656D6F38009400
      00005B00000054000000120000000300000001000000000000000000FFFFFF1F
      2E020000000000010009004F7065726174696F6E00000000FFFF050041726961
      6C0008000000020000000000000000000000020000000000FFFFFF0000000000
      0005004D656D6F39009200000093000000640000001200000003000000010000
      00000000000000FFFFFF1F2E02000000000001001E005B5472616E7361637469
      6F6E51756572792E224F5045524154494F4E225D00000000FFFF050041726961
      6C0008000000000000000000000000000000020000000000FFFFFF0000000000
      0006004D656D6F313700880200001C0000005800000012000000030000000100
      0000000000000000FFFFFF1F2E02000000000001000E0050616765202D205B50
      414745235D00000000FFFF0500417269616C0008000000000000000000010000
      000000020000000000FFFFFF00000000000006004D656D6F313800400200001C
      0000003C000000120000000300000001000000000000000000FFFFFF1F2E0200
      00000000010006005B444154455D00000000FFFF0500417269616C0008000000
      000000000000000000000000020000000000FFFFFF00000000000006004D656D
      6F3134008C020000040100005400000012000000030000000100000000000000
      0000FFFFFF1F2E02010100000001003A00245B53554D285B5472616E73616374
      696F6E51756572792E225452414E53414354494F4E5F56414C5545225D2C204D
      617374657244617461295D00000000FFFF0500417269616C0008000000000000
      000000010000000000020000000000FFFFFF00000000000006004D656D6F3135
      0038020000040100004C0000000F0000000300000001000000000000000000FF
      FFFF1F2E02000000000001000500546F74616C00000000FFFF0500417269616C
      0008000000020000000000010000000000020000000000FFFFFF000000000000
      06004D656D6F31360090020000C0000000500000001200000003000000010000
      00000000000000FFFFFF1F2E02010100000001003A00245B53554D285B547261
      6E73616374696F6E51756572792E225452414E53414354494F4E5F56414C5545
      225D2C204D617374657244617461295D00000000FFFF0500417269616C000800
      0000000000000000010000000000020000000000FFFFFF00000000000006004D
      656D6F31390014020000C0000000740000000F00000003000000010000000000
      00000000FFFFFF1F2E02000000000001001100546F74616C2028746869732070
      6167652900000000FFFF0500417269616C000800000002000000000001000000
      0000020000000000FFFFFF00000000FE0100000000000000000000055449544C
      4502000C00555345525F444546494E45440D0600205449544C4500}
  end
  object TransactionDataset: TfrDBDataSet
    CloseDataSource = True
    DataSet = TransactionQuery
    Left = 176
    Top = 160
  end
  object TransactionQuery: TIBQuery
    Database = Database
    Transaction = IBTransaction1
    OnCalcFields = TransactionQueryCalcFields
    BufferChunks = 1000
    CachedUpdates = False
    SQL.Strings = (
      'SELECT CONTRACT_TRANSACTION.*, CONTRACT.*, CLIENT.* '
      'FROM '
      '  CONTRACT_TRANSACTION, CONTRACT, CLIENT'
      'WHERE'
      '  CONTRACT.OID =  CONTRACT_TRANSACTION.OWNER_OID AND'
      '  CLIENT.OID = CONTRACT.CLIENT_OID AND'
      '  TRANSACTION_TIMESTAMP >= :STARTTIME AND'
      '  TRANSACTION_TIMESTAMP <= :ENDTIME '
      ''
      '  '
      '')
    Left = 176
    Top = 104
    ParamData = <
      item
        DataType = ftDateTime
        Name = 'STARTTIME'
        ParamType = ptUnknown
      end
      item
        DataType = ftDateTime
        Name = 'ENDTIME'
        ParamType = ptUnknown
      end>
    object TransactionQueryOID: TIntegerField
      FieldName = 'OID'
    end
    object TransactionQueryOWNER_OID: TIntegerField
      FieldName = 'OWNER_OID'
    end
    object TransactionQueryDETAILS: TIBStringField
      FieldName = 'DETAILS'
      Size = 50
    end
    object TransactionQueryEXTENSION_NUMBER: TIntegerField
      FieldName = 'EXTENSION_NUMBER'
      Required = True
    end
    object TransactionQueryTRANSACTION_TIMESTAMP: TDateTimeField
      FieldName = 'TRANSACTION_TIMESTAMP'
    end
    object TransactionQueryTRANSACTION_TYPE: TIntegerField
      FieldName = 'TRANSACTION_TYPE'
      Required = True
    end
    object TransactionQueryTRANSACTION_VALUE: TFloatField
      FieldName = 'TRANSACTION_VALUE'
    end
    object TransactionQueryPAYMENT_TYPE_OID: TIntegerField
      FieldName = 'PAYMENT_TYPE_OID'
    end
    object TransactionQueryCLIENT_ADDRESS_OID: TIntegerField
      FieldName = 'CLIENT_ADDRESS_OID'
    end
    object TransactionQueryOID1: TIntegerField
      FieldName = 'OID1'
    end
    object TransactionQueryCONTRACT_FEE: TFloatField
      FieldName = 'CONTRACT_FEE'
    end
    object TransactionQueryCONTRACT_NUMBER: TIntegerField
      FieldName = 'CONTRACT_NUMBER'
      Required = True
    end
    object TransactionQueryEND_DATE: TDateTimeField
      FieldName = 'END_DATE'
    end
    object TransactionQueryEXTENSION_NUMBER1: TIntegerField
      FieldName = 'EXTENSION_NUMBER1'
      Required = True
    end
    object TransactionQueryINTEREST_RATE: TFloatField
      FieldName = 'INTEREST_RATE'
    end
    object TransactionQueryCONTRACT_STATE: TIntegerField
      FieldName = 'CONTRACT_STATE'
      Required = True
    end
    object TransactionQuerySTART_DATE: TDateTimeField
      FieldName = 'START_DATE'
    end
    object TransactionQueryCLIENT_OID: TIntegerField
      FieldName = 'CLIENT_OID'
    end
    object TransactionQueryOID2: TIntegerField
      FieldName = 'OID2'
    end
    object TransactionQueryCLIENT_NUMBER: TIntegerField
      FieldName = 'CLIENT_NUMBER'
      Required = True
    end
    object TransactionQueryEMAIL_ADDRESS: TIBStringField
      FieldName = 'EMAIL_ADDRESS'
      Size = 50
    end
    object TransactionQueryFAMILY_NAME: TIBStringField
      FieldName = 'FAMILY_NAME'
      Size = 50
    end
    object TransactionQueryGIVEN_NAMES: TIBStringField
      FieldName = 'GIVEN_NAMES'
      Size = 50
    end
    object TransactionQueryDATE_OF_BIRTH: TDateTimeField
      FieldName = 'DATE_OF_BIRTH'
    end
    object TransactionQueryPHONE_HOME: TIBStringField
      FieldName = 'PHONE_HOME'
    end
    object TransactionQueryPHONE_MOBILE: TIBStringField
      FieldName = 'PHONE_MOBILE'
    end
    object TransactionQueryPHONE_WORK: TIBStringField
      FieldName = 'PHONE_WORK'
    end
    object TransactionQueryNOTES: TMemoField
      FieldName = 'NOTES'
      BlobType = ftMemo
      Size = 8
    end
    object TransactionQueryPHOTO: TBlobField
      FieldName = 'PHOTO'
      BlobType = ftBlob
      Size = 8
    end
    object TransactionQueryUNDESIRABLE: TIBStringField
      FieldName = 'UNDESIRABLE'
      Size = 5
    end
    object TransactionQueryUNDESIRABLE_CODE: TIBStringField
      FieldName = 'UNDESIRABLE_CODE'
    end
    object TransactionQueryUNDESIRABLE_NOTES: TMemoField
      FieldName = 'UNDESIRABLE_NOTES'
      BlobType = ftMemo
      Size = 8
    end
    object TransactionQueryOPERATION: TStringField
      FieldKind = fkCalculated
      FieldName = 'OPERATION'
      Calculated = True
    end
    object TransactionQueryCURRENT_ADDRESS_OID: TIntegerField
      FieldName = 'CURRENT_ADDRESS_OID'
      Required = True
    end
  end
  object Database: TIBDatabase
    DatabaseName = '..\data\pbpro.gdb'
    Params.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    LoginPrompt = False
    DefaultTransaction = IBTransaction1
    IdleTimer = 0
    SQLDialect = 3
    TraceFlags = []
    Left = 56
    Top = 104
  end
  object IBTransaction1: TIBTransaction
    Active = False
    DefaultDatabase = Database
    Left = 56
    Top = 152
  end
end
