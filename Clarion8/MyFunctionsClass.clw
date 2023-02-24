    MEMBER

!_ABCDllMode_        EQUATE(0)
!_ABCLinkMode_       EQUATE(1)
!
!--------------------------
!MyFunctionsClass
!--------------------------

!    INCLUDE('EQUATES.CLW'), ONCE
    INCLUDE('MyFunctionsClass.INC'),ONCE
    Include('WinEvent.Inc'),Once
	Compile('***',StringTheoryLinkMode=1)
    Include('StringTheory.inc'),Once
	****


    MAP
		!This is the callback method for the jdkCopyFileExA API call
        CopyProgressRoutine(REAL TotalFileSize,REAL TotalBytesTransferred,REAL StreamSize,REAL StreamBytesTransferred,ULONG dwStreamNumber,ULONG dwCallbackReason,Long hSourceFile,Long hDestinationFile,Long lpData),PASCAL,name('LpprogressRoutine')
        Module('Win32')
        	!Example of a simple Win32 API Call
            jdkOutputDebugString(*cstring msg), raw, pascal, name('OutputDebugStringA')
			!These two API calls come in handy when figuring out API calls.
			jdkGetLastError(),long,PASCAL,name('GetLastError')
			jdkFormatMessage(ulong dwFlags, ulong lpSource, ulong dwMessageId, ulong dwLanguageId, *cstring lpBuffer,ulong nSize, ulong Arguments), ulong, raw, pascal, name('FormatMessageA')
        End
        MODULE('kernel32.dll') 
			!Example of a Win32 API call that uses a "callback" method
            jdkCopyFileExA(*CSTRING lpExistingFileName,*CSTRING lpNewFileName,ULONG lpProgressRoutine,Long lpData,BOOL pbCancel,DWORD dwCopyFlags),BOOL,PASCAL,RAW,name('CopyFileExA')
        END
    END

jdkParent      		&MyFunctionsClass		!Store a reference to the original instance of this class for a callback when using CopyFile API


CopyProgressRoutine     Procedure(REAL TotalFileSize,REAL TotalBytesTransferred,REAL StreamSize,REAL StreamBytesTransferred,ULONG dwStreamNumber,ULONG dwCallbackReason,Long hSourceFile,Long hDestinationFile,Long lpData)
jdk      		MyFunctionsClass 
!st          StringTheory
TransferredG     Group(jdkINT64),Over(TotalBytesTransferred).
FileSizeG       Group(jdkINT64),Over(TotalFileSize).
StreamG			Group(jdkINT64),OVER(StreamSize).
FileProgress    Long
BytesHi			DECIMAL(31)
BytesLo			DECIMAL(31)
TotalBytes		DECIMAL(31)	
    CODE
	!Sending the progress back to the example app	
	jdk.Trace('CopyProgressRoutine - Transferred = ' & jdk.GetLargeIntBytes(TransferredG.lo,TransferredG.hi) & ' Stream = ' & jdk.GetLargeIntBytes(StreamG.lo,StreamG.hi) & ' FileSize = ' & jdk.GetLargeIntBytes(FileSizeG.lo,FileSizeG.hi))
	jdkParent.CopyFileCallback(jdk.GetProgress(jdk.GetLargeIntBytes(TransferredG.lo,TransferredG.hi),jdk.GetLargeIntBytes(FileSizeG.lo,FileSizeG.hi)))


!----------------------------------------
MyFunctionsClass.Construct        PROCEDURE()
!----------------------------------------
    CODE
    self.MyQ &= New SampleQueueType !Now there is a NEW queue instantiated as self.MyQ
					!We do not have to DISPOSE this as it is not NEW
        RETURN


!---------------------------------------
MyFunctionsClass.Destruct PROCEDURE()
!---------------------------------------
    CODE

        RETURN


!-----------------------------------
MyFunctionsClass.Init     PROCEDURE()
!-----------------------------------

    CODE

    RETURN

!-----------------------------------
MyFunctionsClass.Kill     PROCEDURE()
!-----------------------------------

    CODE
    Dispose(self.MyQ)   !Always DISPOSE of your NEW refeerences

    RETURN

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.ExampleCallback    Procedure(<string pVal>)   
!---------------------------------------------------------------------------------------------------------------------
    code
    
    self.Trace('MyFunctionsClass.ExampleCallback - Code that runs between during the "Parent Call"')
    If pVal    
        Message('Code during Parent Call - Parameter Passed = ' & Clip(pVal))    
    End
    Return

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.CopyFileAPI				Procedure(string pSource,string pDest)
!---------------------------------------------------------------------------------------------------------------------
CallBackAddr        Ulong
RetVal              Byte
Source      CSTRING(255)
Dest        CSTRING(255)
	CODE
	self.Trace('MyFunctionsClass.CopyFileAPI')
	self.Trace('	pSource = ' & pSource)
	self.Trace('	pDest = ' & pDest)
	self.Trace('')
	jdkParent &= self	!Here I'm instantiating a reference to this class to be used in a callback to the example app
						!You don't have to DISPOSE it because it is not NEW
    Source  = pSource
    Dest    = pDest
    CallBackAddr = Address(CopyProgressRoutine)	!We pass the address of CopyProgressRoutine and the Win32 API uses that to call back into this class.
    RetVal = jdkCopyFileExA(Source, Dest, CallBackAddr, 0, False, jdkCOPY_FILE_NO_BUFFERING) 
	self.Trace('CopyFileAPI - Error: ' & self.FormatMessage(jdkGetLastError()))

!--------------------------------------------------------------------------------------------------------------------- 
MyFunctionsClass.CopyFileCallback		Procedure(long pProgress)
!--------------------------------------------------------------------------------------------------------------------- 
	CODE
	Return !No code here as we are calling back into the procedure that instantiated this class and passing in the value of pProgress


MyFunctionsClass.FormatMessage          Procedure(long pError)
winErrMessage       cstring(255)
errMessage          string(255)
numChars            ulong
    CODE
    numChars = jdkFormatMessage(jdkFORMAT_MESSAGE_FROM_SYSTEM + jdkFORMAT_MESSAGE_IGNORE_INSERTS, 0, pError, 0, winErrMessage, 255, 0)

    errMessage = winErrMessage
    Return(errMessage)


!---------------------------------------------------------------------------------------------------------------------        
MyFunctionsClass.WindowInMethod			Procedure()
!---------------------------------------------------------------------------------------------------------------------
SomeWindow	WINDOW('Your Window'),AT(,,200,80),ICON(ICON:Clarion),FONT('Segoe UI',10),GRAY,Timer(100)
          	PROMPT('Window Called Inside Your Class'),AT(20,10,160,19),USE(?PROMPT1)
          	PROMPT('Use DebugView++ to See Timer Output'),AT(20,20,160,19),USE(?PROMPT2)
          	PROMPT(''),AT(20,32,160,19),USE(?PROMPT3),FONT(,,00953C0Dh)
          	BUTTON('Close'),AT(160,65,33,14),USE(?CloseBtn)
        	END
	CODE
	Open(SomeWindow)
	ACCEPT
    	CASE ACCEPTED()
    	OF ?CloseBtn
			self.Trace('SomeWindow<39>s Close Button Clicked')
			POST(EVENT:CloseWindow)
		End      

		Case Event()
		Of EVENT:Timer
			?PROMPT3{PROP:Text} = 'SomeWindow<39>s Timer Event at ' & Format(Clock(),'@T04')
			self.Trace('SomeWindow<39>s Timer Event')
		End
	END



!==============================================================================
MyFunctionsClass.GetDayOfWeek            PROCEDURE(LONG pDate)!!,LONG
!------------------------------------------------------------------------------
RetVal                          STRING(10)
Compile('***',StringTheoryLinkMode=1)
STdebg                          StringTheory
****
    CODE
    !Eample StringTheory call
	Compile('***',StringTheoryLinkMode=1)
   	STdebg.Trace('Your Debug String')
	****

    RetVal = CHOOSE(pDate % 7,'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday')
    !    CASE pDate % 7
    !        OF 0
    !            RetVal = 'Sunday'
    !        OF 1
    !            RetVal = 'Monday'
    !        OF 2
    !            RetVal = 'Tuesday'
    !        OF 3
    !            RetVal = 'Wednesday'
    !        OF 4
    !            RetVal = 'Thursday'
    !        OF 5
    !            RetVal = 'Friday'
    !        OF 6
    !            RetVal = 'Saturday'
    !    END

  RETURN RetVal

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetDayOfWeekAsNumber    PROCEDURE(LONG p_Date=0)
!---------------------------------------------------------------------------------------------------------------------
    CODE
    RETURN p_Date % 7 

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetFirstDayOfMonth      PROCEDURE(LONG p_Date)
!---------------------------------------------------------------------------------------------------------------------
    CODE
    Return DATE(MONTH(p_Date),1,YEAR(p_Date))

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetLargeIntBytes		Procedure(ulong pLow,ulong pHi)
!---------------------------------------------------------------------------------------------------------------------
BytesHi		REAL
BytesLo		REAL
	CODE
	If pLow < 0
		BytesLo = 2 ^ 32 + pLow
	ELSE
		BytesLo = pLow
	END
	If pHi < 0
		BytesHi = 2 ^ 32 + pHi
	ELSE
		BytesHi = pHi
	End
	Return BytesLo + BytesHi * 2 ^ 32


!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetIsWeekend            PROCEDURE(LONG p_Date=0)
!---------------------------------------------------------------------------------------------------------------------
    CODE
    CASE SELF.GetDayOfWeekAsNumber(p_Date)
    OF 0
    OROF 6
      RETURN 1
    END
    RETURN 0

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetLastDayOfMonth       PROCEDURE(LONG p_Date)
!---------------------------------------------------------------------------------------------------------------------
mn          LONG
yr          LONG
LOC:Day     LONG
    CODE
    mn = MONTH(p_Date)
    yr = YEAR(p_Date)
    LOC:Day = DAY(DATE(mn + 1,0,yr))
    RETURN DATE(MONTH(p_Date),LOC:Day,YEAR(p_Date))

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetProgress             Procedure(real pCount,real pRecords)
!---------------------------------------------------------------------------------------------------------------------
	CODE
	Return (pCount / pRecords) * 100

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetUTCTimeStamp         Procedure(<long pDate>,<long pClock>)
!---------------------------------------------------------------------------------------------------------------------
FastTime            String(12)
TimeStamp           String(25)
ThisTime            Real
    CODE
    ThisTime = ds_FastClock()
    FastTime = ds_FormatFastTime(ThisTime,4) 
    If FastTime[1] = '' Then FastTime[1] = 0 End
    Return FORMAT(TODAY(),'@d10-') & 'T' & FastTime & 'Z' 

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.Trace                   Procedure(string pDebug)
!---------------------------------------------------------------------------------------------------------------------
DebugStr         CSTRING(len(pDebug)+13)
    CODE
    If pDebug = ''
        DebugStr = '<13,10>'
    Else
        DebugStr = clip(pDebug)
    End
    jdkOutputDebugString(DebugStr)
    Return

!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.SetterExample			Procedure(string pVal)	!,Virtual,PROC
!---------------------------------------------------------------------------------------------------------------------
	CODE
	self.SomeString = pVal
!---------------------------------------------------------------------------------------------------------------------
MyFunctionsClass.GetterExample			Procedure()				!,String,Virtual,Proc
!---------------------------------------------------------------------------------------------------------------------
	CODE
	Return self.SomeString