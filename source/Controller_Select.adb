with RASCAL.ToolboxWindow;       use RASCAL.ToolboxWindow;
with RASCAL.ToolboxScrollList;   use RASCAL.ToolboxScrollList;

with Main;                       use Main;
with Reporter;

package body Controller_Select is

   --

   package ToolboxWindow     renames RASCAL.ToolboxWindow;
   package ToolboxScrollList renames RASCAL.ToolboxScrollList;

   --

   List_Gadget   : constant Component_ID := 16#0#;
   Edit_Gadget   : constant Component_ID := 16#6#;
   Remove_Gadget : constant Component_ID := 16#2#;

   --
   
   procedure Handle(The : in TEL_Select_Type) is

      Selection : Integer;
   begin
      ToolboxScrollList.Select_All (main_objectid,List_Gadget,0);
      Selection := ToolboxScrollList.Get_Selected(main_objectid,List_Gadget);
      if Selection /= -1 then
         ToolboxWindow.Gadget_UnFade(main_objectid,Remove_Gadget);
         ToolboxWindow.Gadget_UnFade(main_objectid,Edit_Gadget);
      end if;
   end Handle;

   --

   procedure Handle(The : in TEL_DeSelect_Type) is
   begin
      ToolboxScrollList.DeSelect_All (main_objectid,List_Gadget);
      ToolboxWindow.Gadget_Fade(main_objectid,Remove_Gadget);
      ToolboxWindow.Gadget_Fade(main_objectid,Edit_Gadget);
   end Handle;

   --

end Controller_Select;
