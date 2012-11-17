with RASCAL.WimpTask;            use RASCAL.WimpTask;
with View_Main;                  use View_Main;
with Main;                       use Main;
with Ada.Exceptions;
with Reporter;

package body Controller_Filter is

   --


   procedure Handle (The : in TEL_WritableField_Changed) is

      Object        : Object_ID    := Get_Self_Id(Main_Task);
   begin
      if Object = main_objectid then
         View_Main.Fill;
      end if;
   exception
      when Exception_Data : others =>
           Report_Error("FIELDCHANGED",Ada.Exceptions.Exception_Information (Exception_Data));
   end Handle;
   --
        
end Controller_Filter;
