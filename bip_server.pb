OpenConsole("Bip - Chat - Server.")
IncludeFile "bip_data_handler.pb"

UseModule datahandler

Opendatafile(1,"database.db")
BuildBaseFromFile(1,"onetime.BUILD")

Input()

; AddInsDestVal("Users","Name","noisycat05")
; AddInsDestVal("Users","MessageCount","0")
; Insertdata(1,"Users")
; 
; AddInsDestVal("Users","Name","Jake10s")
; AddInsDestVal("Users","MessageCount","0")
; Insertdata(1,"Users")
; 
; AddInsDestVal("Users","Name","Xperxt")
; AddInsDestVal("Users","MessageCount","0")
; Insertdata(1,"Users")
; 
; AddInsDestVal("Users","Name","PrincessM")
; AddInsDestVal("Users","MessageCount","0")
; Insertdata(1,"Users")
; 
; Input()
; 
; NewList gotdat.s()
; NewList ColumnsSearch.s()
; 
; selectableAllSingle(1,"Users",gotdat.s(),0)
; 
; ResetList(gotdat())
; 
; ForEach gotdat()
;   Debug gotdat()
; Next
; ClearList(gotdat())
; 
; selectsinglewhere(1,"Users","MessageCount","1",gotdat.s())
; ResetList(gotdat())
; 
; ForEach gotdat()
;   Debug gotdat()
; Next
; Input()










; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 9
; FirstLine = 2
; EnableXP