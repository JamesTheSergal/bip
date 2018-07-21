DeclareModule datahandler
  Declare Opendatafile(numb.i,path$)
  
  
  
EndDeclareModule


Module datahandler
  
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
  
  ;- making sql stuff
  
  Procedure selectableAllS(numb.i, Table$, List RetrivedData.s(),Column.i)
    If DatabaseQuery(numb.i,"SELECT * FROM "+Table$+";"
      While NextDatabaseRow(numb.i)
        Gotfrom$ = GetDatabaseString(numb.i,Column.i)
        AddElement(RetrivedData.s())
        RetrivedData.s() = Gotfrom$
      Wend
    Else
      Debug "Database Query Error. >L:20"
    EndIf
  EndProcedure
  
  Procedure Selectfrom(numb.i, List collumn.s(), table$)
    -
    
    
      If DatabaseQuery(numb.i,"SELECT * FROM "+Table$+";"
      While NextDatabaseRow(numb.i)
        Gotfrom$ = GetDatabaseString(numb.i,Column.i)
        AddElement(RetrivedData.s())
        RetrivedData.s() = Gotfrom$
      Wend
    Else
      Debug "Database Query Error. >L:20"
    EndIf
  
  EndProcedure
  
  Procedure CreateCollumnQueue(toadd$, List Queue.s())
    AddElement(Queue())
    Queue() = toadd$
  EndProcedure
  
  
EndModule

  
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 64
; Folding = b-
; EnableXP