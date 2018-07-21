DeclareModule datahandler
  Declare Opendatafile(numb.i,path$)
  Declare addtable(database,Name$)
  Declare selectableAllS(numb.i, Table$, List RetrivedData.s(),Column.i)
  Declare Selectfrom(numb.i, List collumn.s(), table$, List output.s())
  Declare CreateCollumnQueue(toadd$, List Queue.s())
  Declare Tableform(Name$,Type,notnull,PK,AI,Unique)
  Structure def
    type.i
    notnull.i
    PK.i
    AI.i
    Unique.i
  EndStructure
  
  Global NewMap collumns.def()
  UseSQLiteDatabase()
  
EndDeclareModule


Module datahandler
  
  ;- database actions
  
  Procedure Opendatafile(database,name$)
    If Name$ = ":memory:"  ;Checks if the Application wants to make a database in memory for some odd reason.
   If OpenDatabase(database,Name$, "", "") ;Just open the database.
     If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));") ; Test writing to the database.     
       ; empty
     Else
       ; empty
       EndIf
  Else
    ProcedureReturn #False
  EndIf
Else
  If FileSize(Name$) = -1
  If CreateFile(0,Name$)
    
    CloseFile(0)
    If OpenDatabase(database,Name$, "", "")
      If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));")
        ; empty
      EndIf
    Else
      ProcedureReturn #False
    EndIf
    ProcedureReturn #True
  EndIf 
Else
  
  OpenDatabase(database,Name$, "", "")
  ProcedureReturn 3
EndIf
  If OpenDatabase(database,Name$, "", "")
    If DatabaseUpdate(database, "CREATE TABLE info (test VARCHAR(255));")
      
      ProcedureReturn 3
    EndIf
  Else
    ProcedureReturn #False
  EndIf
EndIf

ProcedureReturn #True
    
    
  EndProcedure
  
  Procedure addtable(database,Name$)
    SQLForm$ = "CREATE TABLE "
    Str$ = SQLForm$+"'"+Name$+"' ("
    size = MapSize(collumns())
    
    
    ForEach collumns()
      compaired+1
      
      If compaired = size
        comma = 0
      Else
        comma = 1
      EndIf
      
      
      
      
      Name$ = MapKey(collumns())
      type = collumns() \type
      Notnull = collumns() \notnull
      PK = collumns() \PK 
      AI = collumns() \AI
      
      
    Select type
      Case 1
        SQT$ = "INTEGER"
      Case 2
        SQT$ = "TEXT"
      Case 3
        SQT$ = "BLOB"
      Case 4
        SQT$ = "REAL"
      Case 5
        SQT$ = "NUMERIC"
    EndSelect
    SQMatt$ = "'"+Name$+"' "+SQT$+" "
    If Notnull = 1
      SQMatt$ = SQMatt$+"NOT NULL "
    EndIf  
   If PK = 1 And AI = 1 
      SQmatt$ = SQMatt$+"PRIMARY KEY AUTOINCREMENT "
    Else
    If PK = 1
      SQmatt$ = SQMatt$+"PRIMARY KEY "
    ElseIf AI = 1 And type <> 2 And type <> 3
      SQmatt$ = SQMatt$+"PRIMARY KEY AUTOINCREMENT "
    EndIf
  EndIf
  Str$ = Str$+Chr(10)+SQmatt$
  If comma = 1
    Str$ = Str$ + ","
  EndIf
  
Next

Str$ = Str$+Chr(10)+");"
Debug DatabaseUpdate(database,Str$)
  ClearMap(collumns())
  Debug str$
  EndProcedure
  
  ;- select stuff
  
  Procedure selectableAllS(numb.i, Table$, List RetrivedData.s(),Column.i)
    If DatabaseQuery(numb.i,"SELECT * FROM "+Table$+";")
      While NextDatabaseRow(numb.i)
        Gotfrom$ = GetDatabaseString(numb.i,Column.i)
        AddElement(RetrivedData.s())
        RetrivedData.s() = Gotfrom$
      Wend
    Else
      Debug "Database Query Error. >L:20"
    EndIf
  EndProcedure
  
  Procedure Selectfrom(numb.i, List collumn.s(), table$, List output.s())
    ResetList(collumn())
    size = ListSize(collumn())
    If size = -1
      Debug "Error, List had no elements."
    Else
    While NextElement(collumn())
      colname$ = collumn()
      If ListIndex(collumn()) = size
        CollumnList$ = CollumnList$+colname$
      Else
        CollumnList$ = CollumnList$+colname$+", "
      EndIf
      Debug CollumnList$
    Wend
    
    Debug "Select "+CollumnList$+" FROM "+Table$+";"
    
      If DatabaseQuery(numb.i,"SELECT "+CollumnList$+" FROM "+Table$+";")
      While NextDatabaseRow(numb.i)
        Gotfrom$ = GetDatabaseString(numb.i,Column.i)
        AddElement(output.s())
        output.s() = Gotfrom$
      Wend
    Else
      Debug "Database Query Error. >L:20"
    EndIf
  EndIf
  
  EndProcedure
  
  Procedure CreateCollumnQueue(toadd$, List Queue.s())
    AddElement(Queue())
    Queue() = toadd$
  EndProcedure
  
  ;- table making stuff
  
  Procedure Tableform(Name$,Type,notnull,PK,AI,Unique)
    If FindMapElement(collumns(),Name$)
      Debug "Error Table already exists in queue."
      ProcedureReturn 0
    Else
      AddMapElement(collumns(), Name$)
      collumns() \type = Type
      collumns() \notnull = notnull
      collumns() \PK = PK
      collumns() \AI = AI
      collumns() \Unique = Unique
    EndIf
  EndProcedure
  
  
EndModule

  
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 72
; FirstLine = 56
; Folding = -+
; EnableXP