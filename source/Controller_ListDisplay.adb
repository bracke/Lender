with RASCAL.Error;               use RASCAL.Error;
with RASCAL.MessageTrans;        use RASCAL.MessageTrans;
with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.ToolboxWindow;       use RASCAL.ToolboxWindow;
with RASCAL.Mode;                use RASCAL.Mode;
with RASCAL.Toolbox;             use RASCAL.Toolbox;
with RASCAL.WimpWindow;          use RASCAL.WimpWindow;

with RASCAL.Caret;
with RASCAL.ToolboxWritableField;
with RASCAL.Pointer;
with RASCAL.Time;

with Controller_Resize;          use Controller_Resize;
with StuffList;                  use StuffList;
with Main;                       use Main;
with View_Main;                  use View_Main;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with StuffIO;
with Ada.Exceptions;
with Reporter;

package body Controller_ListDisplay is

   --

   package Error                  renames RASCAL.Error;
   package MessageTrans           renames RASCAL.MessageTrans;
   package Utility                renames RASCAL.Utility;
   package WimpTask               renames RASCAL.WimpTask;
   package ToolboxWindow          renames RASCAL.ToolboxWindow;
   package Mode                   renames RASCAL.Mode;
   package Toolbox                renames RASCAL.Toolbox;
   package Caret                  renames RASCAL.Caret;                
   package ToolboxWritableField   renames RASCAL.ToolboxWritableField; 
   package Pointer                renames RASCAL.Pointer;              
   package Time                   renames RASCAL.Time;
   package ToolboxScrolllist      renames RASCAL.ToolboxScrolllist;
   
   --

   List_Gadget   : constant Component_ID := 16#0#;
   Edit_Gadget   : constant Component_ID := 16#6#;
   Remove_Gadget : constant Component_ID := 16#2#;

   --

   procedure Open_Window is
   begin
      if x_pos > Mode.Get_X_Resolution (OSUnits) or
         y_pos > Mode.Get_Y_Resolution (OSUnits) or
                                       x_pos < 0 or y_pos < 0 then

         Toolbox.Show_Object (main_objectid,0,0,Centre);
      else
         Toolbox.Show_Object_At (main_objectid,x_pos,y_pos,0,0);
      end if;
      
   end Open_Window;

   --

   procedure Handle (The : in TEL_OpenWindow) is
   begin
      Open_Window;
   exception
      when Exception_Data : others => Report_Error("OPENWINDOW",Ada.Exceptions.Exception_Information (Exception_Data));
   end Handle;


   --

   procedure Handle (The : in TEL_RemoveItem_Type) is

      E           : Error_Pointer          := Get_Error (Wimp_Task_Class(Main_Task));
      M           : Error_Message_Pointer  := new Error_Message_Type;
      Result      : Error_Return_Type      := XButton1;

      Items       : ItemNumber_List_Type := Get_SelectionNumbers(main_Objectid,List_Gadget);
      Name,Dummy  : Unbounded_String;
   begin
      if Items'Length > 0 then

         -- Delete entries ?
         M.all.Token(1..8) := "DELENTRY";
         M.all.Category := Warning;
         M.all.Flags    := Error_Flag_Cancel;
         Dummy := U(MessageTrans.Lookup("DELBUTTON",E.all.Msg_Handle));

         M.all.Buttons(1..Length(Dummy))  := S(Dummy);
         Result := Error.Show_Message (E,M);

         if Result = XButton1 then
            ToolboxWindow.Gadget_Fade(main_Objectid,Remove_Gadget);
            ToolboxWindow.Gadget_Fade(main_Objectid,Edit_Gadget);
            for i in Items'Range loop
                Remove_Element(Model,Items(i));
            end loop;
            View_Main.Fill;
         end if;
      end if;
      StuffIO.Save;
   exception
      when ex: others => Report_Error("HANDLE_REMOVEITEM",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --

   procedure Handle (The : in TEL_AddItem_Type) is

      Window : Wimp_Handle_Type := Get_Wimp_Handle(main_objectid);
      State  : Wimp_WindowState_Type := Get_WindowState (Window);
   begin
      View_Main.Add;
      Resize (State);
      StuffIO.Save;
   exception
      when ex: others => Report_Error("HANDLE_ADDITEM",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --

   procedure Handle (The : in TEL_EditItem_Type) is

      Item        : Integer;
   begin
      Item := ToolboxScrollList.Get_Selected(main_Objectid,List_Gadget);
      if Item /= -1 then
         View_Main.Edit;
      end if;
      Toolbox.Show_Object(edit_objectid,0,0,Toolbox.AtPointer);
   exception
      when ex: others => Report_Error("HANDLE_EDITITEM",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --

   procedure Handle (The : in TEL_ChangeItem_Type) is

      Select_Button : Boolean := Pointer.Is_Select;
   begin      
      View_Main.Change;
      StuffIO.Save;
   exception
      when ex: others => Report_Error("HANDLE_CHANGEITEM",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --
   
   procedure Handle (The : in TEL_OpenAddItem_Type) is
   begin
      View_Main.Clear_Movie (add_objectid);
      Toolbox.Show_Object(add_objectid,0,0,Toolbox.AtPointer);
   exception
      when ex: others => Report_Error("HANDLE_OADDITEM",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --

   procedure Handle (The : in TEL_Toolbox_ScrollList_Selection) is

      Select_Button : Boolean := Pointer.Is_Select;
      Selection     : Integer := ToolboxScrollList.Get_Selected(main_objectid,List_Gadget);
      New_Time      : Integer := Time.Read_MonotonicTime;
   begin
      if Selection = -1 then
         ToolboxWindow.Gadget_Fade(main_Objectid,Remove_Gadget);
         ToolboxWindow.Gadget_Fade(main_Objectid,Edit_Gadget);
      else
         ToolboxWindow.Gadget_UnFade(main_Objectid,Remove_Gadget);
         ToolboxWindow.Gadget_UnFade(main_Objectid,Edit_Gadget);
      end if;
      Caret.Set_Position (ToolboxWindow.Get_Wimp_Handle(main_Objectid));

      if Select_Button then
         -- Open edit window if double clicked with select
         if ((New_Time - LastClick_Time) < DoubleClick_Delay) and (LastClick_Time /= 0) then

            View_Main.Edit(The.Event.all.Item);
            Toolbox.Show_Object(edit_objectid,0,0,Toolbox.AtPointer);
         end if;
         LastClick_Time := New_Time;
      end if;   
   exception
      when ex: others => Report_Error("HANDLE_SCROLLIST",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --

   procedure Handle (The : in TEL_Today_Type) is

      Object : Object_ID := Get_Self_Id(Main_Task);
      Date   : String    := Time.Get_Date(S(Choice_Time_Format));
   begin
      ToolboxWritableField.Set_Value(Object,2,Date);
   exception
      when ex: others => Report_Error("HANDLE_DATE",Ada.Exceptions.Exception_Information (ex));
   end Handle;

   --
   
end Controller_ListDisplay;
