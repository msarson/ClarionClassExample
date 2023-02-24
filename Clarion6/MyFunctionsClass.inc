
!Equate for CopyFile API Call
jdkCOPY_FILE_NO_BUFFERING                      Equate(00001000h)

! equates for passing the the FormatMessage() function
jdkFORMAT_MESSAGE_ALLOCATE_BUFFER    equate(000100h)
jdkFORMAT_MESSAGE_IGNORE_INSERTS     equate(000200h)
jdkFORMAT_MESSAGE_FROM_STRING        equate(000400h)
jdkFORMAT_MESSAGE_FROM_HMODULE       equate(000800h)
jdkFORMAT_MESSAGE_FROM_SYSTEM        equate(001000h)
jdkFORMAT_MESSAGE_ARGUMENT_ARRAY     equate(002000h)
jdkFORMAT_MESSAGE_MAX_WIDTH_MASK     equate(0000FFh)

!TYPE'd structures do not actuall exist yet.
!You're simply defining a structure for futre use.

SampleQueueType         Queue,TYPE
StringOne               String(20)
StringTwo               String(20)
                        End

!Used in the CopyFile API Call
jdkINT64    GROUP,TYPE
lo          ULONG
hi          ULONG
            END

MyFunctionsClass        CLASS,TYPE,MODULE('MyFunctionsClass.CLW'),LINK('MyFunctionsClass.CLW')   !,_ABCLinkMode_),DLL(_ABCDllMode_)

MyQ                     &SampleQueueType    ! The TYPE'd Queue still does not exist....yet.  This is just a reference to it.
SameQ                   &SampleQueueType    ! You can reference your TYPE'd Queue multiple times.  This would be an entirely new queue based on the SampleQueueType structure
                                            ! I am not going to instantiate this Queue in the Construct method.  Therefore it will not actually exist.
SomeString				String(100)

Init                    PROCEDURE()
Kill                    PROCEDURE()

Construct               PROCEDURE()
Destruct                PROCEDURE()

ExampleCallback         Procedure(<string pVal>),Virtual,PROC       !This demonstrates an optional parameter of pVal
CopyFileAPI				Procedure(string pSource,string pDest),Virtual,Proc
CopyFileCallback		Procedure(long pProgress),Virtual
FormatMessage           Procedure(long pError),String,Virtual,Proc
WindowInMethod			Procedure(),Virtual,Proc
GetDayOfWeek            PROCEDURE(LONG pDate),String,Virtual,Proc
GetDayOfWeekAsNumber    PROCEDURE(LONG p_Date=0),Long,Virtual,Proc
GetFirstDayOfMonth      PROCEDURE(LONG p_Date),Long,Virtual,Proc
GetIsWeekend            PROCEDURE(LONG p_Date=0),Long,Virtual,Proc
GetLargeIntBytes		Procedure(ulong pLow,ulong pHi),Real,Virtual,Proc
GetLastDayOfMonth       PROCEDURE(LONG p_Date),Long,Virtual,Proc
GetProgress             Procedure(real pCount,real pRecords),Long,Virtual,Proc
! GetUTCTimeStamp         Procedure(<long pDate>,<long pClock>),String,Virtual,Proc
Trace                   Procedure(string pDebug),Virtual,Proc
SetterExample			Procedure(string pVal),Virtual,PROC
GetterExample			Procedure(),String,Virtual,Proc

                    END
