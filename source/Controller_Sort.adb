with StuffList;                  use StuffList;
with View_Main;                  use View_Main;
with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Main;                       use Main;
with Alphabetical;
with Ada.Exceptions;
with Reporter;

with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.Toolbox;             use RASCAL.Toolbox;
with RASCAL.ToolboxRadioButton;  use RASCAL.ToolboxRadioButton;
with RASCAL.ToolboxStringSet;

package body Controller_Sort is

   --

   package Utility             renames RASCAL.Utility;
   package WimpTask            renames RASCAL.WimpTask;          
   package Toolbox             renames RASCAL.Toolbox;           
   package ToolboxRadioButton  renames RASCAL.ToolboxRadioButton;
   package ToolboxStringSet    renames RASCAL.ToolboxStringSet;  

   --

   procedure Handle (The : in TEL_Sort_Type) is

      Object        : Object_ID               := Get_Self_Id(Main_Task);
      Ancestor      : Object_ID               := Get_Ancestor_Id(Main_Task);
      Template      : String                  := Toolbox.Get_Template_Name(Object);
      i,i2          : StuffList.Position;
      ItemI,ItemI2  : Element_Pointer;
      Changed       : Boolean := false;
      ItemI_Str     : Unbounded_String;
      ItemI2_Str    : Unbounded_String;
      Sort_Column   : Content_Type := Content_Type'Val(ToolboxStringSet.Get_Selected_Index(Sort_ObjectID,16#e#));
      Reverse_Direction : Boolean  := ToolboxRadioButton.Get_State(Sort_ObjectID,16#10#) = UnSelected;

      procedure SiftDown (x_in : in StuffList.Position;
                          y_in : in StuffList.Position) is

         x         : StuffList.Position := x_in;
         y         : StuffList.Position := y_in;
         ItemX     : Element_Pointer;
         ItemY     : Element_Pointer;
         ItemX_Str : Unbounded_String;
         ItemY_Str : Unbounded_String;
      begin
         loop
            exit when IsFirst (Model,x);
            GoBack (Model,x);
            ItemX := Retrieve (Model,x);
            case Sort_Column is
            when Name       => ItemX_Str := ItemX.all.Name;
            when Lent_To    => ItemX_Str := ItemX.all.Lent_To;
            when Date       => ItemX_Str := ItemX.all.Date;
            when Notes      => ItemX_Str := ItemX.all.Notes;
            end case;

            ItemY := Retrieve (Model,y);
            case Sort_Column is
            when Name       => ItemY_Str := ItemY.all.Name;
            when Lent_To    => ItemY_Str := ItemY.all.Lent_To;
            when Date       => ItemY_Str := ItemY.all.Date;
            when Notes      => ItemY_Str := ItemY.all.Notes;
            end case;                                            

            exit when ItemX_Str = ItemY_Str;
            exit when (Alphabetical.Pos(S(ItemX_Str)) < Alphabetical.Pos(S(ItemY_Str))) and (not Reverse_Direction);
            exit when (Alphabetical.Pos(S(ItemX_Str)) > Alphabetical.Pos(S(ItemY_Str))) and Reverse_Direction;

            Swap (Model,x,y);
            y := x;
         end loop;
      end SiftDown;

   begin
      if Template = "Window" then
         Ancestor := Object;
      end if;
      if not isEmpty(Model) then
         i := First(Model);
         loop
            i2 := i;
            loop
               exit when IsLast(Model,i2);
               GoAhead(Model,i2);

               ItemI := Retrieve (Model,I);
               case Sort_Column is
               when Name       => ItemI_Str := ItemI.all.Name;
               when Lent_To    => ItemI_Str := ItemI.all.Lent_To;
               when Date       => ItemI_Str := ItemI.all.Date;
               when Notes      => ItemI_Str := ItemI.all.Notes;
               end case;
   
               ItemI2 := Retrieve (Model,I2);
               case Sort_Column is
               when Name       => ItemI2_Str := ItemI2.all.Name;
               when Lent_To    => ItemI2_Str := ItemI2.all.Lent_To;
               when Date       => ItemI2_Str := ItemI2.all.Date;
               when Notes      => ItemI2_Str := ItemI2.all.Notes;
               end case;

               if ((Alphabetical.Pos(S(ItemI_Str)) > Alphabetical.Pos(S(ItemI2_Str))) and (not Reverse_Direction)) or
                  ((Alphabetical.Pos(S(ItemI_Str)) < Alphabetical.Pos(S(ItemI2_Str))) and Reverse_Direction) then

                  Changed := true;
                  Swap (Model,i,i2);
                  SiftDown (i,i);
               end if;
               exit when IsLast(Model,i2);
            end loop;
            exit when IsLast(Model,i);
            GoAhead(Model,i);
         end loop;
         if Changed then
            View_Main.Fill;
         end if;
      end if;            
   exception
      when Exception_Data : others => Report_Error("HAND_SORT",Ada.Exceptions.Exception_Information (Exception_Data));
   end Handle;

   --
    
end Controller_Sort;
