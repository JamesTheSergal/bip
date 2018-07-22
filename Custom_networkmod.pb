DeclareModule net
  Declare.i StartServer(port)
  ;Declare.i StartClient(serveraddress$,port)
  ;- Server Globals
  Global NewList serverIDs.i()
  Global mapaccess = CreateMutex()
  Global mapmemlis = CreateMutex()
  
  ;- Client Globals
  Declare.i StartClient(ClientAgent,Address$,port)
  Declare.s ClientSendDataWait(ClientAgent,String$)
  Structure liz
    Address.s
    port.i
    ThreadID.i
    Status.i
  EndStructure
  Structure xob
    ClientAgent.i
    returncode.s
    message.s
  EndStructure
  Global NewMap Clients.liz()
  Global ClientlizMutx = CreateMutex()
  Global sendmutex = CreateMutex()
  Global inmutex = CreateMutex()
  Global NewList Outbox.xob()
  Global NewList Inbox.xob()
  
  
EndDeclareModule


Module net
  Declare serverthread(port)
  Declare ServerIndividualThread(ClientID)
  Declare ClientThread(ClientAgent)
  ;Declare ClientSendData(ClientAgent,String$)
  InitNetwork()
  
  ;- Server
  
  Procedure.i StartServer(port)
    CreateThread(@serverthread(),port)
    ;serverthread(port)
  EndProcedure
  
  Procedure serverthread(port)
    Global NewMap Threads.i()
    Global NewMap Memlist.i()
    Debug "Server Started"
    ServerID = Random(9999,0)
    Debug ServerID
    CreateNetworkServer(ServerID,port)
    
    Repeat
      
      ServerEvent = NetworkServerEvent()
      
      If ServerEvent
        ClientID = EventClient()
        Debug ServerEvent
        Select ServerEvent
            
          Case #PB_NetworkEvent_Connect
            Debug "Client connected."
            Thread = CreateThread(@ServerIndividualThread(),ClientID)
            ResetMap(Threads())
            AddMapElement(Threads(),Str(ClientID))
            Threads() = Thread
            
            
          Case #PB_NetworkEvent_Disconnect
            Debug "Client: "+Str(ClientID)+" Disconnected."
            LockMutex(mapaccess)
            Debug Str(Threads(Str(ClientID)))+" Is the Thread ID."
            KillThread(Threads(Str(ClientID)))
            DeleteMapElement(Threads(),Str(ClientID))
            UnlockMutex(mapaccess)
            Debug "killed thread"
            
          Case #PB_NetworkEvent_Data
            *ReceiveBuffer = AllocateMemory(65536)
            ReceiveNetworkData(ClientID,*ReceiveBuffer,65536)
            LockMutex(mapmemlis)
            AddMapElement(Memlist(),Str(ClientID))
            Memlist() = *ReceiveBuffer
            UnlockMutex(mapmemlis)
            *ReceiveBuffer = AllocateMemory(65536)
            
            
        EndSelect
      Else
        Delay(1)
      EndIf

    ForEver

  EndProcedure
  
  Procedure ServerIndividualThread(ClientID)
    Debug "Individual thread started."
    Repeat  
      If FindMapElement(Memlist(),Str(ClientID))
        LockMutex(mapmemlis)
        memory = Memlist()
        DeleteMapElement(Memlist(),Str(ClientID))
        UnlockMutex(mapmemlis)
        received$ = PeekS(memory)
        message$ = StringField(received$,2,"<sep-ret*message>")
        retco$ = StringField(received$,1,"<sep-ret*message>")
        
      FreeMemory(memory)
    EndIf
    ;- custom commands section
    
    
    Select message$
      Case "ping"
        Debug "Sent a ping response."
        SendNetworkString(ClientID,retco$+"<sep-ret*message>"+"pong",#PB_Unicode)
        
    EndSelect
    
    ;- end of custom commands section
    message$ = ""
      Delay(5)
    Until exit = 1
  EndProcedure
  
  ;- Client
  
  Procedure.i StartClient(ClientAgent,Address$,port)
    LockMutex(ClientlizMutx)
    If FindMapElement(Clients(),Str(ClientAgent))
      If Clients() \Status = 0
        Clients() \Address = Address$
        Clients() \port = port
        Thread = CreateThread(@ClientThread(),ClientAgent)
        ;Input()
        ;ClientThread(ClientAgent)
        Clients() \ThreadID = Thread
        UnlockMutex(ClientlizMutx)
      Else
        Debug "ClientAgent Number already in use."
      EndIf
      Else
    AddMapElement(Clients(),Str(ClientAgent))
    Clients() \Address = Address$
    Clients() \port = port
    Thread = CreateThread(@ClientThread(),ClientAgent)
        ;Input()
        ;ClientThread(ClientAgent)
    Clients() \ThreadID = Thread
    UnlockMutex(ClientlizMutx)
  EndIf
  
  EndProcedure
  
  Procedure ClientThread(ClientAgent)
    LockMutex(ClientlizMutx)
    If FindMapElement(Clients(),Str(ClientAgent))
      ConnAddress$ = Clients() \Address
      ConnPort = Clients() \port
      Clients() \Status = 1
      UnlockMutex(ClientlizMutx)
    Else
      Clients() \Status = 0
      UnlockMutex(ClientlizMutx)
      Debug "Error. Could not find Client Agent Map element."
    EndIf
    
    ConnectionID = OpenNetworkConnection(ConnAddress$,ConnPort)
    If ConnectionID
      Repeat
        ; send out any data so that it is possible we can get data back quicker.
        LockMutex(sendmutex)
        ResetList(Outbox())
        While NextElement(Outbox())
          If Outbox() \ClientAgent = ClientAgent
            retco$ = Outbox() \returncode
            Message$ = Outbox() \message
            UnlockMutex(sendmutex)
            SendNetworkString(ConnectionID,retco$+"<sep-ret*message>"+Message$,#PB_Unicode)
            LockMutex(sendmutex)
            DeleteElement(Outbox())
          EndIf
        Wend
        UnlockMutex(sendmutex)
        
        
        
        ; Check for incoming data.
        CliEvent = NetworkClientEvent(ConnectionID)
        If CliEvent
          Select CliEvent
              
            Case #PB_NetworkEvent_Data
              Debug "Client has received data."
              *ReceiveBuffer = AllocateMemory(65536)
              Debug PeekS(*ReceiveBuffer,65536,#PB_Unicode)
              Debug ReceiveNetworkData(ConnectionID,*ReceiveBuffer,65536)
              Received$ =  PeekS(*ReceiveBuffer)
              FreeMemory(*ReceiveBuffer)
              
              
              retco$ = StringField(Received$,1,"<sep-ret*message>")
              message$ = StringField(Received$,2,"<sep-ret*message>")
              LockMutex(inmutex)
              AddElement(inbox())
              Inbox() \ClientAgent = ClientAgent
              Inbox() \message = Message$
              Inbox() \returncode = retco$
              UnlockMutex(inmutex)
              
            Case #PB_NetworkEvent_Disconnect
              MessageRequester("Server-side","Server has shutdown or disconnected.")
              exit = 1
              LockMutex(ClientlizMutx)
              Clients(Str(ClientAgent)) \Status = 0
              UnlockMutex(ClientlizMutx)
          EndSelect
        Else
          Delay(1)
        EndIf
        
          
        Until exit = 1
    Else
      LockMutex(ClientlizMutx)
      Clients(Str(ClientAgent)) \Status = 0
      UnlockMutex(ClientlizMutx)
      Debug "Error, Was unable to connect to server."
    EndIf
 
  EndProcedure
  
  Procedure.s ClientSendDataWait(ClientAgent,String$)
    returncode$ = Str(Random(9999,0))
    LockMutex(sendmutex)
    InsertElement(Outbox())
    Outbox() \ClientAgent = ClientAgent
    Outbox() \message = String$
    Outbox() \returncode = returncode$
    UnlockMutex(sendmutex)
    
    retry:
    LockMutex(inmutex)
    ResetList(Inbox())
    ForEach Inbox()
      If Inbox() \ClientAgent = ClientAgent
        Debug "Looking for "+Str(ClientAgent)+" found "+Inbox() \ClientAgent
        If Inbox() \returncode = returncode$
          Message$ = Inbox() \message
          DeleteElement(Inbox())
          Break
        EndIf
      EndIf
      If ListIndex(Inbox()) = ListSize(Inbox())
        ResetList(Inbox())
        UnlockMutex(inmutex)
        Delay(100)
        LockMutex(inmutex)
      EndIf
    Next
    UnlockMutex(Inmutex)
    Delay(100)
    If message$ = ""
      Goto retry
    EndIf
      ProcedureReturn Message$  
    
  EndProcedure
  
  
EndModule 

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 268
; FirstLine = 234
; Folding = 8-
; EnableXP