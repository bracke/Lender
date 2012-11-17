with StuffList;                  use StuffList;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Main;                       use Main;
with Ada.Exceptions;
with Reporter;

with RASCAL.Error;                      use RASCAL.Error;
with RASCAL.MessageTrans;               use RASCAL.MessageTrans;
with RASCAL.Utility;                    use RASCAL.Utility;
with RASCAL.WimpTask;                   use RASCAL.WimpTask;
with RASCAL.ToolboxOptionButton;        use RASCAL.ToolboxOptionButton;
with RASCAL.ToolboxWindow;              use RASCAL.ToolboxWindow;
with RASCAL.Toolbox;                    use RASCAL.Toolbox;
with RASCAL.ToolboxScrollList;          use RASCAL.ToolboxScrollList;
with RASCAL.ToolboxWritableField;
with RASCAL.Pointer;

package body Controller_Find is

   --

   package Error                 renames RASCAL.Error;
   package MessageTrans          renames RASCAL.MessageTrans;        
   package Utility               renames RASCAL.Utility;             
   package WimpTask              renames RASCAL.WimpTask;            
   package ToolboxOptionButton   renames RASCAL.ToolboxOptionButton; 
   package ToolboxWindow         renames RASCAL.ToolboxWindow;       
   package Toolbox               renames RASCAL.Toolbox;             
   package ToolboxScrollList     renames RASCAL.ToolboxScrollList;   
   package ToolboxWritableField  renames RASCAL.ToolboxWritableField;
   package Pointer               renames RASCAL.Pointer;

   --

   List_Gadget   : constant Component_ID := 16#0#;
   Edit_Gadget   : constant Component_ID := 16#6#;
   Remove_Gadget : constant Component_ID := 16#2#;

   --

   procedure Handle (The : in TEL_Find_Type) is

      Select_Button : Boolean                 := Pointer.Is_Select;
      Search        : String                  := To_Lower(ToolboxWritableField.Get_Value (Find_ObjectID,16#0#));

      E             : Error_Pointer           := Get_Error (Main_Task);
      M             : Error_Message_Pointer   := new Error_Message_Type;
      Result        : Error_Return_Type       := XButton1;

      Name          : Boolean                 := ToolboxOptionButton.Get_State(Find_ObjectID,3) = On;
      Lent_To       : Boolean                 := ToolboxOptionButton.Get_State(Find_ObjectID,4) = On;
      Date          : Boolean                 := ToolboxOptionButton.Get_State(Find_ObjectID,6) = On;
      Notes         : Boolean                 := ToolboxOptionButton.Get_State(Find_ObjectID,5) = On;
      CaseSensitive : Boolean                 := ToolboxOptionButton.Get_State(Find_ObjectID,16#11#) = On;

      last          : Boolean                 := false;
      Match         : Boolean                 := false;
      First         : Boolean                 := true;
      i             : StuffList.Position;
      Item          : Element_Pointer;
   begin
      ToolboxScrolllist.DeSelect_All(main_objectid,List_Gadget);

      if Search'Length > 0 then
         if not isEmpty(Model) then
            i := StuffList.First(Model);
            loop
               Match := False;
               Item := Retrieve (Model,i);

               if CaseSensitive then
                  if Name then
                     Match := Match or (Index(Item.all.Name,Search) > 0);
                  end if;
                  if Lent_To then
                     Match := Match or (Index(Item.all.Lent_To,Search) > 0);
                  end if;
                  if Date then
                     Match := Match or (Index(Item.all.Date,Search) > 0);
                  end if;
                  if Notes then
                     Match := Match or (Index(Item.all.Notes,Search) > 0);
                  end if;
               else
                  if Name then
                     Match := Match or (Index(U(To_Lower(S(Item.all.Name))),Search) > 0);
                  end if;
                  if Lent_To then
                     Match := Match or (Index(U(To_Lower(S(Item.all.Lent_To))),Search) > 0);
                  end if;
                  if Date then
                     Match := Match or (Index(U(To_Lower(S(Item.all.Date))),Search) > 0);
                  end if;
                  if Notes then
                     Match := Match or (Index(U(To_Lower(S(Item.all.Notes))),Search) > 0);
                  end if;
               end if;
               if Match then
                  ToolboxScrollList.Select_Item(main_objectid,List_Gadget,Item.all.ID);
                  if First then
                     First := false;
                     ToolboxScrollList.Make_Visible(main_objectid,List_Gadget,Item.all.ID-1);
               
                     ToolboxWindow.Gadget_UnFade(main_objectid,Remove_Gadget);
                     ToolboxWindow.Gadget_UnFade(main_objectid,Edit_Gadget);
                  end if;
               end if;
               exit when IsLast(Model,i);
               GoAhead(Model,i);
            end loop;
         end if;            
      end if;
      if First then
         -- Search did not find anything
         M.all.Token(1..8) := "NORESULT";
         M.all.Category := Info;
         Result := Error.Show_Message (E,M);
      else
         if Select_Button then
            Toolbox.Hide_Object (Find_ObjectID);
         end if;
      end if;
   exception
      when Exception_Data : others => Report_Error("HANDLE_FIND",Ada.Exceptions.Exception_Information (Exception_Data));
   end Handle;

   --

end Controller_Find;
