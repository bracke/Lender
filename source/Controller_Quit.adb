with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.FileInternal;        use RASCAL.FileInternal;
with RASCAL.ToolboxWindow;       use RASCAL.ToolboxWindow;
with RASCAL.FileExternal;
with RASCAL.TaskManager;

with Main;                       use Main;
with Ada.Exceptions;
with Reporter;

package body Controller_Quit is

   --

   package Utility        renames RASCAL.Utility;
   package WimpTask       renames RASCAL.WimpTask;     
   package FileInternal   renames RASCAL.FileInternal; 
   package ToolboxWindow  renames RASCAL.ToolboxWindow;
   package FileExternal   renames RASCAL.FileExternal; 
   package TaskManager    renames RASCAL.TaskManager;
                                              
   --

   procedure Save_WindowPosition is
   begin
      if ToolboxWindow.Is_Open(main_objectid) then
         if not FileExternal.Exists ("<Choices$Write>.Lender") then
            FileExternal.Create_Directory ("<Choices$Write>.Lender");
         end if;

         ToolboxWindow.Get_WindowPosition (main_objectid,x_pos,y_pos);
         declare
            Target : FileHandle_Type(new UString'(U("<Choices$Write>.Lender.Misc")),Write);
         begin
            FileInternal.Put_String (Target,"XPOS:" & intstr(x_pos));
            FileInternal.Put_String (Target,"YPOS:" & intstr(y_pos));
         end;
      end if;
   exception
      when e: others => Report_Error("POSSAVE",Ada.Exceptions.Exception_Information (e));
   end Save_WindowPosition;

   --

   procedure Handle (The : in TEL_Quit_Quit) is
   begin
      Save_WindowPosition;
      Set_Status(Main_Task,false);
   exception
      when e: others => Report_Error("TQUIT",Ada.Exceptions.Exception_Information (e));
   end Handle;
   
   --

   procedure Handle (The : in MEL_Message_Quit) is
   begin
      Save_WindowPosition;
      Set_Status(Main_Task,false);
   exception
      when e: others => Report_Error("MQUIT",Ada.Exceptions.Exception_Information (e));      
   end Handle;

   --
        
end Controller_Quit;
