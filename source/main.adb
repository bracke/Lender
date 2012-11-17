with Controller_Quit;           use Controller_Quit;
with Controller_Resize;         use Controller_Resize;
with Controller_Filter;         use Controller_Filter;
with Controller_ListDisplay;    use Controller_ListDisplay;
with Controller_Internet;       use Controller_Internet;
with Controller_Bugz;           use Controller_Bugz;
with Controller_Choices;        use Controller_Choices;
with Controller_Help;           use Controller_Help;
with Controller_Dummy;          use Controller_Dummy;
with Controller_Error;          use Controller_Error;
with Controller_Select;         use Controller_Select;
with Controller_Sort;           use Controller_Sort;
with Controller_Find;           use Controller_Find;
with View_Main;                 use View_Main;
with StuffIO;                   use StuffIO;
with Reporter;                  use Reporter;
with Ada.Exceptions;

with RASCAL.Toolbox;            use RASCAL.Toolbox;
with RASCAL.FileExternal;       use RASCAL.FileExternal;
with RASCAL.Utility;            use RASCAL.Utility;
with RASCAL.Error;              use RASCAL.Error;
with RASCAL.MessageTrans;       use RASCAL.MessageTrans;
with RASCAL.ToolboxProgInfo;
with RASCAL.ToolboxWindow;

package body Main is

   --

   package Toolbox         renames RASCAL.Toolbox;
   package FileExternal    renames RASCAL.FileExternal;    
   package Utility         renames RASCAL.Utility;         
   package Error           renames RASCAL.Error;           
   package MessageTrans    renames RASCAL.MessageTrans;    
   package ToolboxProgInfo renames RASCAL.ToolboxProgInfo; 
   package ToolboxWindow   renames RASCAL.ToolboxWindow;
   package WimpTask        renames RASCAL.WimpTask;
   package OS              renames RASCAL.OS;      
   package Pointer         renames RASCAL.Pointer;
   package Variable        renames RASCAL.Variable;

   --

   procedure Report_Error (Token : in String;
                           Info  : in String) is

      E        : Error_Pointer          := Get_Error (Main_Task);
      M        : Error_Message_Pointer  := new Error_Message_Type;
      Result   : Error_Return_Type;
   begin
      M.all.Token(1..Token'Length) := Token;
      M.all.Param1(1..Info'Length) := Info;
      M.all.Category := Warning;
      M.all.Flags    := Error_Flag_OK;
      Result         := Error.Show_Message (E,M);
   end Report_Error;

   --

   procedure Main is

      ProgInfo_Window : Object_ID;
      Misc            : Messages_Handle_Type;
      Dummy           : Unbounded_String;
   begin
      -- WIMP Events
      Add_Listener (Main_Task,new WEL_Reason_OpenWindow);

      -- Messages
      Add_Listener (Main_Task,new MEL_Message_Bugz_Query);
      Add_Listener (Main_Task,new MEL_Message_Quit);

      -- Toolbox Events
      Add_Listener (Main_Task,new TEL_Quit_Quit);
      Add_Listener (Main_Task,new TEL_ViewManual_Type);
      Add_Listener (Main_Task,new TEL_ViewSection_Type);
      Add_Listener (Main_Task,new TEL_ViewIHelp_Type);
      Add_Listener (Main_Task,new TEL_ViewHomePage_Type);
      Add_Listener (Main_Task,new TEL_ViewChoices_Type);
      Add_Listener (Main_Task,new TEL_SendEmail_Type);
      Add_Listener (Main_Task,new TEL_CreateReport_Type);      
      Add_Listener (Main_Task,new TEL_Toolbox_Error);
      Add_Listener (Main_Task,new TEL_OpenWindow);
      Add_Listener (Main_Task,new TEL_RemoveItem_Type);
      Add_Listener (Main_Task,new TEL_AddItem_Type);
      Add_Listener (Main_Task,new TEL_EditItem_Type);
      Add_Listener (Main_Task,new TEL_ChangeItem_Type);
      Add_Listener (Main_Task,new TEL_OpenAddItem_Type);
      Add_Listener (Main_Task,new TEL_Toolbox_ScrollList_Selection);
      Add_Listener (Main_Task,new TEL_Today_Type);
      Add_Listener (Main_Task,new TEL_Select_Type);
      Add_Listener (Main_Task,new TEL_DeSelect_Type);
      Add_Listener (Main_Task,new TEL_Sort_Type);
      Add_Listener (Main_Task,new TEL_Find_Type);
      Add_Listener (Main_Task,new TEL_WritableField_Changed);
      Add_Listener (Main_Task,new TEL_Dummy);

      -- Start task
      WimpTask.Set_Resources_Path(Main_Task,"<LenderRes$Dir>");
      WimpTask.Initialise(Main_Task);

      if FileExternal.Exists("Choices:Lender.Misc") then
         Misc := MessageTrans.Open_File("Choices:Lender.Misc");
         begin
            Read_Integer ("XPOS",x_pos,Misc);
            Read_Integer ("YPOS",y_pos,Misc);
         exception
            when others => null;            
         end;
      end if;
      Sort_ObjectID      := Toolbox.Create_Object ("Sort");
      Find_ObjectID      := Toolbox.Create_Object ("Find");
      add_objectid       := Toolbox.Create_Object ("AddItem");
      edit_objectid      := Toolbox.Create_Object ("EditItem");
      main_objectid      := Toolbox.Create_Object ("Window");
      ProgInfo_Window    := Toolbox.Create_Object ("ProgInfo");
      ToolboxProgInfo.Set_Version(ProgInfo_Window,
                                  MessageTrans.Lookup("VERS",Get_Message_Block(Main_Task)));

      Read_String ("NAMEHEADER",Name_Header,Get_Message_Block(Main_Task));
      Read_String ("LENTTOHEADER",Lent_To_Header,Get_Message_Block(Main_Task));
      Read_String ("DATE",Date_Header,Get_Message_Block(Main_Task));

      StuffIO.Read;
      View_Main.Fill;

      WimpTask.Poll(Main_Task);

   exception
      when e: others => Report_Error("UNTRAPPED",Ada.Exceptions.Exception_Information (e));
   end Main;

   --

end Main;

