  MEMBER('ClassUseExample.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('ClassUseExample_BC0.CLW')
ClassUseExample_BC0:DctInit             PROCEDURE
ClassUseExample_BC0:DctKill             PROCEDURE
ClassUseExample_BC0:FilesInit           PROCEDURE
    END
  END

DctInit PROCEDURE
  CODE
  ClassUseExample_BC0:DctInit
  ClassUseExample_BC0:FilesInit


DctKill PROCEDURE
  CODE
  ClassUseExample_BC0:DctKill

