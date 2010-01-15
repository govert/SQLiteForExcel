Attribute VB_Name = "Sqlite3Demo"
Option Explicit

Public Sub AllTests()
    Dim InitReturn As Long
    
    InitReturn = SQLite3Initialize ' Default path is ThisWorkbook.Path but can specify other path where the .dlls reside.
    If InitReturn <> SQLITE_INIT_OK Then
        Debug.Print "Error Initializing SQLite. Error: " & Err.LastDllError
        Exit Sub
    End If
    
    TestVersion
    TestOpenClose
    TestError
    TestInsert
    TestSelect
    TestBinding
    TestDates
    
    SQLite3Free ' Quite optional
End Sub

Public Sub TestVersion()

    Debug.Print SQLite3LibVersion()

End Sub

Public Sub TestApiCallSpeed()
    
    Dim i As Long
    Dim version As String
    Dim start As Date
    
    start = Now()
    For i = 0 To 10000000 ' 10 million
        version = SQLite3LibVersion()
    Next
    
    Debug.Print "ApiCall Elapsed: " & Format(Now() - start, "HH:mm:ss")
    
End Sub

Public Sub TestOpenClose()
    Dim testFile As String
    Dim myDbHandle As Long
    Dim RetVal As Long
    
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    RetVal = SQLite3Close(myDbHandle)
    Debug.Print "SQLite3Close returned " & RetVal
    
    Kill testFile

End Sub

Public Sub TestError()
    Dim myDbHandle As Long
    Dim RetVal As Long
    
    Dim ErrMsg As String
    
    Debug.Print "----- TestError Start -----"
    
    ' DbHandle is set up even if there is an error !
    RetVal = SQLite3Open("::::", myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    ErrMsg = SQLite3ErrMsg(myDbHandle)
    Debug.Print "SQLite3Open error message: " & ErrMsg
  
    RetVal = SQLite3Close(myDbHandle)
    Debug.Print "SQLite3Close returned " & RetVal

    Debug.Print "----- TestError End -----"

End Sub

Public Sub TestStatement()
    Dim testFile As String
    
    Dim myDbHandle As Long
    Dim myStmtHandle As Long
    Dim RetVal As Long
    
    Dim stepMsg As String
    
    Debug.Print "----- TestStatement Start -----"
    
    ' Open the database - getting a DbHandle back
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "CREATE TABLE MyFirstTable (TheId INTEGER, TheText TEXT, TheValue REAL)", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    Debug.Print "SQLite3Step returned " & RetVal
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal
    
    ' Close the database
    RetVal = SQLite3Close(myDbHandle)
    Kill testFile

    Debug.Print "----- TestStatement End -----"
End Sub

Public Sub TestInsert()
    Dim testFile As String
    
    Dim myDbHandle As Long
    Dim myStmtHandle As Long
    Dim RetVal As Long
    Dim recordsAffected As Long
    
    Dim stepMsg As String
    
    Debug.Print "----- TestInsert Start -----"
    
    ' Open the database - getting a DbHandle back
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    '------------------------
    ' Create the table
    ' ================
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "CREATE TABLE MySecondTable (TheId INTEGER, TheText TEXT, TheValue REAL)", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_DONE Then
        Debug.Print "SQLite3Step Done"
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal
    
    '-------------------------
    ' Insert a record
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "INSERT INTO MySecondTable Values (123, 'ABC', 42.1)", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_DONE Then
        Debug.Print "SQLite3Step Done"
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    '-------------------------
    ' Insert  using helper
    ' ====================
    recordsAffected = SQLite3ExecuteNonQuery(myDbHandle, "INSERT INTO MySecondTable Values (456, 'DEF', 49.3)")
    Debug.Print "SQLite3Execute - Insert affected " & recordsAffected & " record(s)."
    
    ' Close the database
    RetVal = SQLite3Close(myDbHandle)
    Kill testFile

    Debug.Print "----- TestInsert End -----"
End Sub

Public Sub TestSelect()
    Dim testFile As String
    
    Dim myDbHandle As Long
    Dim myStmtHandle As Long
    Dim RetVal As Long
    
    Dim stepMsg As String
    
    Debug.Print "----- TestSelect Start -----"
    
    ' Open the database - getting a DbHandle back
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    '------------------------
    ' Create the table
    ' ================
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "CREATE TABLE MyFirstTable (TheId INTEGER, TheText TEXT, TheValue REAL)", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_DONE Then
        Debug.Print "SQLite3Step Done"
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal
    
    '-------------------------
    ' Insert a record
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "INSERT INTO MyFirstTable Values (123, 'ABC', 42.1)", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_DONE Then
        Debug.Print "SQLite3Step Done"
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    '-------------------------
    ' Insert another record
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "INSERT INTO MyFirstTable Values (987654, ""ZXCVBNM"", NULL)", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_DONE Then
        Debug.Print "SQLite3Step Done"
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    '-------------------------
    ' Select statement
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "SELECT * FROM MyFirstTable", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    ' Start running the statement
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_ROW Then
        Debug.Print "SQLite3Step Row Ready"
        PrintColumns myStmtHandle
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Move to next row
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_ROW Then
        Debug.Print "SQLite3Step Row Ready"
        PrintColumns myStmtHandle
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Move on again (now we are done)
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_DONE Then
        Debug.Print "SQLite3Step Done"
    Else
        Debug.Print "SQLite3Step returned " & RetVal
    End If
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    
    ' Close the database
    RetVal = SQLite3Close(myDbHandle)
    Kill testFile

    Debug.Print "----- TestSelect End -----"
End Sub

Sub PrintColumns(ByVal stmtHandle As Long)
    Dim colCount As Long
    Dim colName As String
    Dim colType As Long
    Dim colTypeName As String
    Dim colValue As Variant
    
    Dim i As Long
    
    colCount = SQLite3ColumnCount(stmtHandle)
    Debug.Print "Column count: " & colCount
    For i = 0 To colCount - 1
        colName = SQLite3ColumnName(stmtHandle, i)
        colType = SQLite3ColumnType(stmtHandle, i)
        colTypeName = TypeName(colType)
        colValue = ColumnValue(stmtHandle, i, colType)
        Debug.Print "Column " & i & ":", colName, colTypeName, colValue
    Next
End Sub

Sub PrintParameters(ByVal stmtHandle As Long)
    Dim paramCount As Long
    Dim paramName As String
    
    Dim i As Long
    
    paramCount = SQLite3BindParameterCount(stmtHandle)
    Debug.Print "Parameter count: " & paramCount
    For i = 1 To paramCount
        paramName = SQLite3BindParameterName(stmtHandle, i)
        Debug.Print "Parameter " & i & ":", paramName
    Next
End Sub


Function TypeName(ByVal SQLiteType As Long) As String
    Select Case SQLiteType
        Case SQLITE_INTEGER:
            TypeName = "INTEGER"
        Case SQLITE_FLOAT:
            TypeName = "FLOAT"
        Case SQLITE_TEXT:
            TypeName = "TEXT"
        Case SQLITE_BLOB:
            TypeName = "BLOB"
        Case SQLITE_NULL:
            TypeName = "NULL"
    End Select
End Function

Function ColumnValue(ByVal stmtHandle As Long, ByVal ZeroBasedColIndex As Long, ByVal SQLiteType As Long) As Variant
    Select Case SQLiteType
        Case SQLITE_INTEGER:
            ColumnValue = SQLite3ColumnInt32(stmtHandle, ZeroBasedColIndex)
        Case SQLITE_FLOAT:
            ColumnValue = SQLite3ColumnDouble(stmtHandle, ZeroBasedColIndex)
        Case SQLITE_TEXT:
            ColumnValue = SQLite3ColumnText(stmtHandle, ZeroBasedColIndex)
        Case SQLITE_BLOB:
            ColumnValue = SQLite3ColumnText(stmtHandle, ZeroBasedColIndex)
        Case SQLITE_NULL:
            ColumnValue = Null
    End Select
End Function

Public Sub TestBinding()
    Dim testFile As String
    
    Dim myDbHandle As Long
    Dim myStmtHandle As Long
    Dim RetVal As Long
    Dim stepMsg As String
    Dim i As Long
    
    Dim paramIndexId As Long
    Dim paramIndexDate As Long
    
    Dim startDate As Date
    Dim curDate As Date
    Dim curValue As Double
    Dim offset As Long
    
    Dim testStart As Date
    
    Debug.Print "----- TestBinding Start -----"
    
    ' Open the database - getting a DbHandle back
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    '------------------------
    ' Create the table
    ' ================
    ' (O've got no error checking here...)
    SQLite3PrepareV2 myDbHandle, "CREATE TABLE MyBigTable (TheId INTEGER, TheDate REAL, TheText TEXT, TheValue REAL)", myStmtHandle
    SQLite3Step myStmtHandle
    SQLite3Finalize myStmtHandle
    
    '---------------------------
    ' Add an index
    ' ================
    SQLite3PrepareV2 myDbHandle, "CREATE INDEX idx_MyBigTable_Id_Date ON MyBigTable (TheId, TheDate)", myStmtHandle
    SQLite3Step myStmtHandle
    SQLite3Finalize myStmtHandle
    
    ' START Insert Time
    testStart = Now()
    
    '-------------------
    ' Begin transaction
    '==================
    SQLite3PrepareV2 myDbHandle, "BEGIN TRANSACTION", myStmtHandle
    SQLite3Step myStmtHandle
    SQLite3Finalize myStmtHandle

    '-------------------------
    ' Prepare an insert statement with parameters
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "INSERT INTO MyBigTable Values (?, ?, ?, ?)", myStmtHandle)
    If RetVal <> SQLITE_OK Then
        Debug.Print "SQLite3PrepareV2 returned " & SQLite3ErrMsg(myDbHandle)
        Beep
    End If
    
    Randomize
    startDate = DateValue("1 Jan 2000")
    
    For i = 1 To 100000
        curDate = startDate + i
        curValue = Rnd() * 1000
        
        RetVal = SQLite3BindInt32(myStmtHandle, 1, 42000 + i)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3BindDate(myStmtHandle, 2, curDate)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3BindText(myStmtHandle, 3, "The quick brown fox jumped over the lazy dog.")
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3BindDouble(myStmtHandle, 4, curValue)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3Step(myStmtHandle)
        If RetVal <> SQLITE_DONE Then
            Debug.Print "SQLite3Step returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    
        RetVal = SQLite3Reset(myStmtHandle)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Reset returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    Next
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    '-------------------
    ' Commit transaction
    '==================
    ' (I'm re-using the same variable myStmtHandle for the new statement)
    SQLite3PrepareV2 myDbHandle, "COMMIT TRANSACTION", myStmtHandle
    SQLite3Step myStmtHandle
    SQLite3Finalize myStmtHandle

    ' STOP Insert Time
    Debug.Print "Insert Elapsed: " & Format(Now() - testStart, "HH:mm:ss")

    ' START Select  Time
    testStart = Now()

    '-------------------------
    ' Select statement
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    ' Now using named parameters!
    RetVal = SQLite3PrepareV2(myDbHandle, "SELECT TheId, datetime(TheDate), TheText, TheValue FROM MyBigTable WHERE TheId = @FindThisId AND TheDate <= @FindThisDate LIMIT 1", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    paramIndexId = SQLite3BindParameterIndex(myStmtHandle, "@FindThisId")
    If paramIndexId = 0 Then
        Debug.Print "SQLite3BindParameterIndex could not find the Id parameter!"
        Beep
    End If
    
    paramIndexDate = SQLite3BindParameterIndex(myStmtHandle, "@FindThisDate")
    If paramIndexDate = 0 Then
        Debug.Print "SQLite3BindParameterIndex could not find the Date parameter!"
        Beep
    End If
    
    startDate = DateValue("1 Jan 2000")
    
    
    For i = 1 To 100000
        offset = i Mod 10000
        ' Bind the parameters
        RetVal = SQLite3BindInt32(myStmtHandle, paramIndexId, 42000 + 500 + offset)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    
        RetVal = SQLite3BindDate(myStmtHandle, paramIndexDate, startDate + 500 + offset)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3Step(myStmtHandle)
        If RetVal = SQLITE_ROW Then
            ' We have access to the result columns here.
            If offset = 1 Then
                Debug.Print "At row " & i
                Debug.Print "------------"
                PrintColumns myStmtHandle
                Debug.Print "============"
            End If
        ElseIf RetVal = SQLITE_DONE Then
            Debug.Print "No row found"
        End If
    
        RetVal = SQLite3Reset(myStmtHandle)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Reset returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    Next
        
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal
    
    ' STOP Select time
    Debug.Print "Select Elapsed: " & Format(Now() - testStart, "HH:mm:ss")
    
    ' Close the database
    RetVal = SQLite3Close(myDbHandle)
    Kill testFile

    Debug.Print "----- TestBinding End -----"
End Sub


Public Sub TestBindingMore()
    Dim testFile As String
    
    Dim myDbHandle As Long
    Dim myStmtHandle As Long
    Dim RetVal As Long
    Dim stepMsg As String
    Dim i As Long
    
    Dim paramIndexId As Long
    Dim paramIndexDate As Long
    
    Dim startDate As Date
    Dim curDate As Date
    Dim curValue As Double
    Dim offset As Long
    
    Dim testStart As Date
    
    Debug.Print "----- TestBinding Start -----"
    
    ' Open the database - getting a DbHandle back
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    '------------------------
    ' Create the table
    ' ================
    ' (O've got no error checking here...)
    SQLite3ExecuteNonQuery myDbHandle, "CREATE TABLE MyBigTable (TheId INTEGER, TheDate REAL, TheText TEXT, TheValue REAL)", myStmtHandle
    
    '---------------------------
    ' Add an index
    ' ================
    SQLite3ExecuteNonQuery myDbHandle, "CREATE INDEX idx_MyBigTable_Id_Date ON MyBigTable (TheId, TheDate)", myStmtHandle
    
    ' START Insert Time
    testStart = Now()
    
    '-------------------
    ' Begin transaction
    '==================
    SQLite3ExecuteNonQuery myDbHandle, "BEGIN TRANSACTION", myStmtHandle

    '-------------------------
    ' Prepare an insert statement with parameters
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "INSERT INTO MyBigTable Values (?, ?, ?, ?)", myStmtHandle)
    If RetVal <> SQLITE_OK Then
        Debug.Print "SQLite3PrepareV2 returned " & SQLite3ErrMsg(myDbHandle)
        Beep
    End If
    
    PrintParameters myStmtHandle
        
    Randomize
    startDate = DateValue("1 Jan 2000")
    
    For i = 1 To 100000
        curDate = startDate + i
        curValue = Rnd() * 1000
        
        RetVal = SQLite3BindInt32(myStmtHandle, 1, 42000 + i)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3BindDate(myStmtHandle, 2, curDate)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3BindText(myStmtHandle, 3, "The quick brown fox jumped over the lazy dog.")
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3BindDouble(myStmtHandle, 4, curValue)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3Step(myStmtHandle)
        If RetVal <> SQLITE_DONE Then
            Debug.Print "SQLite3Step returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    
        RetVal = SQLite3Reset(myStmtHandle)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Reset returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    Next
    
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    '-------------------
    ' Commit transaction
    '==================
    SQLite3ExecuteNonQuery myDbHandle, "COMMIT TRANSACTION", myStmtHandle

    ' STOP Insert Time
    Debug.Print "Insert Elapsed: " & Format(Now() - testStart, "HH:mm:ss")

    ' START Select  Time
    testStart = Now()

    '-------------------------
    ' Select statement
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    ' Now using named parameters!
    RetVal = SQLite3PrepareV2(myDbHandle, "SELECT TheId, datetime(TheDate), TheText, TheValue FROM MyBigTable WHERE TheId = @FindThisId AND TheDate <= julianday(@FindThisDate) LIMIT 1", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    PrintParameters myStmtHandle

    paramIndexId = SQLite3BindParameterIndex(myStmtHandle, "@FindThisId")
    If paramIndexId = 0 Then
        Debug.Print "SQLite3BindParameterIndex could not find the Id parameter!"
        Beep
    End If
    
    paramIndexDate = SQLite3BindParameterIndex(myStmtHandle, "@FindThisDate")
    If paramIndexDate = 0 Then
        Debug.Print "SQLite3BindParameterIndex could not find the Date parameter!"
        Beep
    End If
    
    startDate = DateValue("1 Jan 2000")
    
    For i = 1 To 100000
        offset = i Mod 10000
        ' Bind the parameters
        RetVal = SQLite3BindInt32(myStmtHandle, paramIndexId, 42000 + 500 + offset)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    
        RetVal = SQLite3BindText(myStmtHandle, paramIndexDate, Format(startDate + 500 + offset, "yyyy-MM-dd HH:mm:ss"))
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
        
        RetVal = SQLite3Step(myStmtHandle)
        If RetVal = SQLITE_ROW Then
            ' We have access to the result columns here.
            If offset = 1 Then
                Debug.Print "At row " & i
                Debug.Print "------------"
                PrintColumns myStmtHandle
                Debug.Print "============"
            End If
        ElseIf RetVal = SQLITE_DONE Then
            Debug.Print "No row found"
        End If
    
        RetVal = SQLite3Reset(myStmtHandle)
        If RetVal <> SQLITE_OK Then
            Debug.Print "SQLite3Reset returned " & RetVal, SQLite3ErrMsg(myDbHandle)
            Beep
        End If
    Next
        
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal
    
    ' STOP Select time
    Debug.Print "Select Elapsed: " & Format(Now() - testStart, "HH:mm:ss")
    
    ' Close the database
    RetVal = SQLite3Close(myDbHandle)
    Kill testFile

    Debug.Print "----- TestBinding End -----"
End Sub

Public Sub TestDates()
    Dim testFile As String
    
    Dim myDbHandle As Long
    Dim myStmtHandle As Long
    Dim RetVal As Long
    Dim stepMsg As String
    Dim i As Long
    
    Dim myDate As Date
    Dim myEvent As String
    
    Debug.Print "----- TestDates Start -----"
    
    ' Open the database - getting a DbHandle back
    testFile = "C:\TestSqlite3ForExcel.db3"
    RetVal = SQLite3Open(testFile, myDbHandle)
    Debug.Print "SQLite3Open returned " & RetVal
    
    '------------------------
    ' Create the table
    ' ================
    ' (I've got no error checking here...)
    SQLite3ExecuteNonQuery myDbHandle, "CREATE TABLE MyDateTable (MyDate REAL, MyEvent TEXT)"
    
    '-------------------------
    ' Prepare an insert statement with parameters
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    RetVal = SQLite3PrepareV2(myDbHandle, "INSERT INTO MyDateTable Values (@SomeDate, @SomeEvent)", myStmtHandle)
    If RetVal <> SQLITE_OK Then
        Debug.Print "SQLite3PrepareV2 returned " & SQLite3ErrMsg(myDbHandle)
        Beep
    End If
    
    RetVal = SQLite3BindDate(myStmtHandle, 1, DateSerial(2010, 6, 19))
    If RetVal <> SQLITE_OK Then
        Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
        Beep
    End If
    
    RetVal = SQLite3BindText(myStmtHandle, 2, "Nice trip somewhere")
    If RetVal <> SQLITE_OK Then
        Debug.Print "SQLite3Bind returned " & RetVal, SQLite3ErrMsg(myDbHandle)
        Beep
    End If
    
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal <> SQLITE_DONE Then
        Debug.Print "SQLite3Step returned " & RetVal, SQLite3ErrMsg(myDbHandle)
        Beep
    End If
    
    ' Finalize the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal

    '-------------------------
    ' Select statement
    ' ===============
    ' Create the sql statement - getting a StmtHandle back
    ' Now using named parameters!
    RetVal = SQLite3PrepareV2(myDbHandle, "SELECT * FROM MyDateTable", myStmtHandle)
    Debug.Print "SQLite3PrepareV2 returned " & RetVal
    
    RetVal = SQLite3Step(myStmtHandle)
    If RetVal = SQLITE_ROW Then
        ' We have access to the result columns here.
        myDate = SQLite3ColumnDate(myStmtHandle, 0)
        myEvent = SQLite3ColumnText(myStmtHandle, 1)
        Debug.Print "Event: " & myEvent, "Date: " & myDate
    ElseIf RetVal = SQLITE_DONE Then
        Debug.Print "No row found"
    End If
        
    ' Finalize (delete) the statement
    RetVal = SQLite3Finalize(myStmtHandle)
    Debug.Print "SQLite3Finalize returned " & RetVal
    
    ' Close the database
    RetVal = SQLite3Close(myDbHandle)
    Kill testFile

    Debug.Print "----- TestDates End -----"
End Sub

' SQLite3 Helper Functions
Public Function SQLite3ExecuteNonQuery(ByVal DbHandle As Long, ByVal SqlCommand As String) As Long
    Dim stmtHandle As Long
    
    SQLite3PrepareV2 DbHandle, SqlCommand, stmtHandle
    SQLite3Step stmtHandle
    SQLite3Finalize stmtHandle
    
    SQLite3ExecuteNonQuery = SQLite3Changes(DbHandle)
End Function