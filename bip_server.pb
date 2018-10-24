OpenConsole("Bip - Chat - Server.")
IncludeFile "bip_data_handler.pb"
IncludeFile "Custom_networkmod.pb"



UseModule datahandler
UseModule net

If Opendatafile(1,"database.db")
  PrintN("Opened database file successfully.")
Else
  BuildBaseFromFile(1,"onetime.BUILD")
  PrintN("Created database file.")
EndIf

If FileSize("servername.nm") > 1
  OpenFile(50,"servername.nm")
  Global servername$ = ReadString(50)
Else
  PrintN("Please enter a server name:")
  Global servername$ = Input()
  OpenFile(50,"servername.nm")
  WriteString(50,servername$)
EndIf
CloseFile(50)
UnuseModule datahandler


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



StartServer(5858)

PrintN("Server main thread has closed.")
Input()





; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 71
; FirstLine = 32
; EnableThread
; EnableXP
; Executable = ServerTest.exe
; Warnings = Display
; EnablePurifier = 1,1,1,1