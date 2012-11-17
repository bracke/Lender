with StuffList;                 use StuffList;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Characters.Handling;   use Ada.Characters.Handling;
with Main;                      use Main;
with Reporter;
with Ada.Exceptions;

with RASCAL.Utility;            use RASCAL.Utility;
with RASCAL.ToolboxScrollList;  use RASCAL.ToolboxScrollList;
with RASCAL.ToolboxWindow;      use RASCAL.ToolboxWindow;
with RASCAL.ToolboxNumberRange;
with RASCAL.ToolboxWritableField;
with RASCAL.ToolboxTextArea;
with RASCAL.Toolbox;

package body View_Main is

   --

   package Utility              renames RASCAL.Utility;
   package ToolboxScrollList    renames RASCAL.ToolboxScrollList;  
   package ToolboxWindow        renames RASCAL.ToolboxWindow;      
   package ToolboxNumberRange   renames RASCAL.ToolboxNumberRange; 
   package ToolboxWritableField renames RASCAL.ToolboxWritableField;
   package ToolboxTextArea      renames RASCAL.ToolboxTextArea;    
   package Toolbox              renames RASCAL.Toolbox;            

   --

   -- Main window
   List_Gadget      : constant Component_ID := 16#0#;
   Edit_Gadget      : constant Component_ID := 16#6#;
   Remove_Gadget    : constant Component_ID := 16#2#;
                    
   -- Movie window (Add,Edit)
   Name_Gadget      : constant Component_ID := 16#6#;
   Lent_To_Gadget   : constant Component_ID := 16#4#;
   Date_Gadget      : constant Component_ID := 16#2#;
   Notes_Gadget     : constant Component_ID := 16#1F#;

   Element_Gadget   : constant Component_ID := 16#4e#;

   --

   procedure Fill is

      Start,i    : StuffList.Position;
      Item       : Element_Pointer;
      Item_Str   : Unbounded_String;
      Header     : Unbounded_String := U("");
      ID_Counter : Natural := 0;
      Filer_1    : String := ToolboxWritableField.Get_Value(main_objectid,16#26d#);
      Filer_2    : String := ToolboxWritableField.Get_Value(main_objectid,16#26e#);
      Filer_3    : String := ToolboxWritableField.Get_Value(main_objectid,16#26f#);
      Add        : Boolean;
   begin
      ToolboxScrollList.Delete_All(main_objectid,List_Gadget);

      -- create header
      Append(Header,Name_Header);
      Append(Header,ASCII.HT);
      Append(Header,Lent_To_Header);
      Append(Header,ASCII.HT);
      Append(Header,Date_Header);
      ToolboxScrollList.Set_Heading (main_Objectid,List_Gadget,ID_Counter,S(Header));

      if not isEmpty(Model) then
         Start := First(Model);
         i     := Start;
         loop
            Item := Retrieve (Model,i);
            Add  := (Filer_1'Length = 0) or else
                    (Index(U(To_Lower(S(Item.all.Name))),To_Lower(Filer_1)) > 0);
                 
            Add  := Add and ((Filer_2'Length = 0) or else
                    (Index(U(To_Lower(S(Item.all.Lent_To))),To_Lower(Filer_2)) > 0));
                 
            Add  := Add and ((Filer_3'Length = 0) or else
                    (Index(U(To_Lower(S(Item.all.Date))),To_Lower(Filer_3)) > 0));

            if Add then
               Item_Str := U("");
               Append(Item_Str,Item.all.Name);
               Append(Item_Str,ASCII.HT);
               Append(Item_Str,Item.all.Lent_To);
               Append(Item_Str,ASCII.HT);
               Append(Item_Str,Item.all.Date);
   
               ToolboxScrollList.Add_Item(main_Objectid,List_Gadget,S(Item_Str),ID_Counter);
               Item.all.ID := ID_Counter;
            end if;
            ID_Counter  := ID_Counter + 1;

            exit when IsLast(Model,i);
            GoAhead(Model,i);
         end loop;
      end if;
   end Fill;

   --

   procedure Add is

      Name     : String := ToolboxWritableField.Get_Value(Add_objectid,Name_Gadget);
      Lent_To  : String := ToolboxWritableField.Get_Value(Add_objectid,Lent_To_Gadget);
      Date     : String := ToolboxWritableField.Get_Value(Add_objectid,Date_Gadget);
      Notes    : String := ToolboxTextArea.Get_Text(Add_objectid,Notes_Gadget);
      Item     : Element_Pointer := new Item_Type'(U(Name),U(Lent_To),U(Date),U(Notes),0);
   begin
      AddToRear(Model,Item);
      Fill;
      ToolboxWindow.Gadget_Fade(main_objectid,Remove_Gadget);
      ToolboxWindow.Gadget_Fade(main_objectid,Edit_Gadget);
   end Add;

   --

   procedure Edit (Index : in Integer := -1) is

      Item_ID : Natural;
      Element : Element_Pointer; 
   begin
      if Index <=-1 then
         Item_ID := ToolboxScrollList.Get_Selected(main_objectid,List_Gadget);
      else
         Item_ID := Index;
      end if;
      Element := Get_Element(Model,Item_ID);

      if Element /= null then
         ToolboxWritableField.Set_Value(Edit_objectid,Name_Gadget,S(Element.all.Name));
         ToolboxWritableField.Set_Value(Edit_objectid,Lent_To_Gadget,S(Element.all.Lent_To));
         ToolboxWritableField.Set_Value(Edit_objectid,Date_Gadget,S(Element.all.Date));
         ToolboxTextArea.Set_Text(Edit_objectid,Notes_Gadget,S(Element.all.Notes));
         ToolboxNumberRange.Set_Value(Edit_objectid,Element_Gadget,Item_ID);
      end if;
   end Edit;

   --

   procedure Change is

      Name     : String := ToolboxWritableField.Get_Value(Edit_objectid,Name_Gadget);
      Lent_To  : String := ToolboxWritableField.Get_Value(Edit_objectid,Lent_To_Gadget);
      Date     : String := ToolboxWritableField.Get_Value(Edit_objectid,Date_Gadget);
      Notes    : String := ToolboxTextArea.Get_Text(Edit_Objectid,Notes_Gadget);
      Item     : Natural:= ToolboxNumberRange.Get_Value (Edit_objectid,Element_Gadget);
      Element  : Element_Pointer      := Get_Element (Model,Item);
      Items    : ItemNumber_List_Type := ToolboxScrollList.Get_SelectionNumbers(main_objectid,List_Gadget);
   begin
      if Element /= null then
         Element.all.Name      := U(Name);
         Element.all.Lent_To   := U(Lent_To);
         Element.all.Date      := U(Date);
         Element.all.Notes     := U(Notes);
         Fill;
         ToolboxScrollList.Select_Items (main_objectid,List_Gadget,Items);
      end if;                       
   end Change;

   --

   procedure Clear_Movie (Window : in Object_ID) is
   begin
      ToolboxWritableField.Set_Value(Window,Name_Gadget,"");
      ToolboxWritableField.Set_Value(Window,Lent_To_Gadget,"");
      ToolboxWritableField.Set_Value(Window,Date_Gadget,"");
      ToolboxTextArea.Set_Text(Window,Notes_Gadget,"");
   end Clear_Movie;

   --

end View_Main;
