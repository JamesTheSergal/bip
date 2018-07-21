OpenConsole("Bip - Chat - Server.")
IncludeFile "bip_data_handler.pb"
Input()
UseModule datahandler

Opendatafile(1,"database.db")

Tableform("test",2,1,0,1,Unique)
Tableform("test1",2,1,0,1,Unique)
Tableform("test2",2,1,0,1,Unique)
Tableform("test3",2,1,0,1,Unique)
addtable(1,"Section")

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 10
; EnableXP