

   MEMBER('ClassUseExample.clw')                           ! This is a MEMBER module


   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABUTIL.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

                     MAP
                       INCLUDE('CLASSUSEEXAMPLE001.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
Main PROCEDURE 

JohansClass         	Class(MyFunctionsClass)        ! Instantiate your class
ExampleCallback     	Procedure(<string pVal>),DERIVED    ! Notice the Derived property.  This means we are referencing the Parent procedure in the class.
CopyFileCallback		Procedure(long pProgress),DERIVED
                    	End

! Example of a local class declared inside this procedure
local					CLASS
RefreshCopyBtn			Procedure()
						End

NameOnly	String(100)
SourceFile           STRING(255)                           !
Destination          STRING(255)                           !
Window               WINDOW('Using a Class Example'),AT(,,363,168),FONT('Segoe UI',10),AUTO,ICON('Teacher1.ico'), |
  GRAY,SYSTEM,WALLPAPER('Background.jpg'),IMM
                       BUTTON('Close'),AT(326,149),USE(?Close)
                       PROMPT('Make sure you have DebugView++ Running as Admin for more info...'),AT(5,5),USE(?PROMPT1), |
  TRN
                       SHEET,AT(2,17,359,129),USE(?SHEET1)
                         TAB('List From QUEUE in Class'),USE(?TAB1)
                           LIST,AT(7,37,345,98),USE(?LIST1),VSCROLL,FORMAT('86L(2)M~String One~@s20@80L(2)M~String' & |
  ' Two~@s20@')
                         END
                         TAB('Sample Method Calls'),USE(?TAB2)
                           BUTTON('Example Callback Method (Parameter Set)'),AT(107,35,93,37),USE(?ExampleCallbackBtn:2)
                           BUTTON('Example Callback Method (Parameter Empty)'),AT(10,35,93,37),USE(?ExampleCallbackBtn)
                           BUTTON('Get Value from Getter Method'),AT(203,35,93,37),USE(?GetterBtn)
                           BUTTON('Window in Method'),AT(11,75,93,37),USE(?WindowInMethodBtn)
                         END
                         TAB('Copy File API'),USE(?TAB3)
                           TEXT,AT(8,58,343,17),USE(SourceFile)
                           PROMPT('Source File:'),AT(7,45),USE(?SourceFile:Prompt),TRN
                           PROMPT('Destination:'),AT(7,80),USE(?Destination:Prompt),TRN
                           TEXT,AT(8,92,343,17),USE(Destination)
                           BUTTON,AT(49,42,12,12),USE(?LookupFile),ICON('Search1.ico')
                           BUTTON,AT(49,77,12,12),USE(?LookupFile:2),ICON('Search1.ico')
                           BUTTON('Copy Files'),AT(289,125,63,15),USE(?CopyBtn),HIDE
                           PROGRESS,AT(7,112,345,11),USE(?PROGRESS1),HIDE,RANGE(0,100),SMOOTH
                           PROMPT('Try copying a fairly large file to see the progress in action.'),AT(7,32),USE(?PROMPT2), |
  TRN
                         END
                       END
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass
FileLookup2          SelectFileClass
FileLookup3          SelectFileClass

  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Close
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  IF SELF.Request = SelectRecord
     SELF.AddItem(?Close,RequestCancelled)                 ! Add the close control to the window manger
  ELSE
     SELF.AddItem(?Close,RequestCompleted)                 ! Add the close control to the window manger
  END
  SELF.Open(Window)                                        ! Open window
  	JohansClass.SetterExample('Value that was set')
  
  	JohansClass.MyQ.StringOne = 'Johan'
  	JohansClass.MyQ.StringTwo = 'de Klerk'
  	Add(JohansClass.MyQ)
  
  	JohansClass.MyQ.StringOne = 'Don'
  	JohansClass.MyQ.StringTwo = 'Ridley'
  	Add(JohansClass.MyQ)
  
  	JohansClass.MyQ.StringOne = 'Mike'
  	JohansClass.MyQ.StringTwo = 'Hanson'
  	Add(JohansClass.MyQ)
        
  Do DefineListboxStyle
    ?LIST1{PROP:From} = JohansClass.MyQ  
  INIMgr.Fetch('Main',Window)                              ! Restore window settings from non-volatile store
  	SourceFile=GETINI('SavedPaths','SourceFile',,'.\ClassUseExample.INI')
  	Destination=GETINI('SavedPaths','Destination',,'.\ClassUseExample.INI')  
  FileLookup2.Init
  FileLookup2.ClearOnCancel = True
  FileLookup2.Flags=BOR(FileLookup2.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup2.SetMask('All Files','*.*')                   ! Set the file mask
  FileLookup3.Init
  FileLookup3.ClearOnCancel = True
  FileLookup3.Flags=BOR(FileLookup3.Flags,FILE:LongName)   ! Allow long filenames
  FileLookup3.Flags=BOR(FileLookup3.Flags,FILE:Directory)  ! Allow Directory Dialog
  FileLookup3.SetMask('All Files','*.*')                   ! Set the file mask
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  	  
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('Main',Window)                           ! Save window data to non-volatile store
  END
  	PUTINI('SavedPaths','SourceFile',Clip(SourceFile),'.\ClassUseExample.INI')
  	PUTINI('SavedPaths','Destination',Clip(Destination),'.\ClassUseExample.INI')  
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

BS  		USHORT
Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
    CASE ACCEPTED()
    OF ?ExampleCallbackBtn:2
      JohansClass.ExampleCallback('Johan de Klerk') 
    OF ?ExampleCallbackBtn
      JohansClass.ExampleCallback() 
    OF ?GetterBtn
      	Case Message(JohansClass.GetterExample(),'Value from Setter Method',ICON:Asterisk,BUTTON:OK+BUTTON:No,0,MSGMODE:SYSMODAL)   
      		Of BUTTON:OK
      			Message('You Clicked Ok')
      		Of BUTTON:NO
      			Message('You Clicked No')
      		End   
    OF ?WindowInMethodBtn
      	JohansClass.WindowInMethod()      
    OF ?CopyBtn
      	?PROGRESS1{PROP:Hide} = FALSE
      	JohansClass.CopyFileAPI(Clip(SourceFile),Clip(Destination))      
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?LookupFile
      ThisWindow.Update
      SourceFile = FileLookup2.Ask(1)
      DISPLAY
      local.RefreshCopyBtn()   
      
      ! Getting just the file name here.
      ! Normally I would just use StringTheory but I didn't know if you had it.
      ! Credit: Carl Barnes - https://clarionhub.com/t/dos-filename-lookup-how-to-get-file-name-without-path/4464/13
      BS=INSTRING('\',SourceFile,-1,SIZE(SourceFile))   !-1 Reverse step, must start at the end i.e. size
      NameOnly=SUB(SourceFile,BS+1,999)   
    OF ?LookupFile:2
      ThisWindow.Update
      Destination = FileLookup3.Ask(1)
      DISPLAY
      Destination = Clip(Destination) & '\' & Clip(NameOnly)
      local.RefreshCopyBtn()      
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

JohansClass.ExampleCallback     Procedure(<string pVal>)
    CODE
    self.Trace('Main - JohansClass.ExampleCallback - Before Parent Call - pVal = ' & pVal)
    Parent.ExampleCallback(pVal)
    self.Trace('Main - JohansClass.ExampleCallback - After Parent Call - pVal = ' & pVal)

JohansClass.CopyFileCallback		Procedure(long pProgress)
	CODE
	!self.Trace('JohansClass.CopyFileCallback - Before PC - pProgress = ' & pProgress)
	?PROGRESS1{PROP:Progress} = pProgress
	Parent.CopyFileCallback(pProgress)
	!self.Trace('JohansClass.CopyFileCallback - After PC - pProgress = ' & pProgress)
	If pProgress = 100
		?PROGRESS1{PROP:Hide} = True
	End
	Return

local.RefreshCopyBtn			Procedure()
	code
	If SourceFile<>'' and Destination<>''
		?CopyBtn{PROP:Hide} = False
	End
