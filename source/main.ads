with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with StuffList;

with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.OS;                  use RASCAL.OS;
with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.Pointer;             use RASCAL.Pointer;
with RASCAL.Variable;

package Main is

   type Content_Type is (Name,Lent_To,Date,Notes);

   -- Constants
   app_name       : constant String := "Lender";
   Choices_Write  : constant String := "<Choices$Write>." & app_name;
   Choices_Read   : constant String := "Choices:" & app_name;

   --
   Main_Task          : ToolBox_Task_Class;
   Model              : StuffList.List;

   x_pos              : Integer          := -1;
   y_pos              : Integer          := -1;
   DoubleClick_Delay  : constant Integer := Get_DoubleClick_Delay;
   LastClick_Time     : Integer          := 0;
   Last_Selected_Node : Integer          := -1;

   Name_Header        : Unbounded_String := U("Name");
   Lent_To_Header     : Unbounded_String := U("Borrower");
   Date_Header        : Unbounded_String := U("Date");
   Replace_Characters : Unbounded_String := U("¢");
   Choice_Time_Format : Unbounded_String := U("%ce%yr-%mn-%dy");

   Add_Objectid       : Object_ID        := -1;
   Main_Objectid      : Object_ID        := -1;
   Edit_Objectid      : Object_ID        := -1;
   Sort_ObjectID      : Object_ID        := -1;
   Find_ObjectID      : Object_ID        := -1;

   --

   procedure Report_Error (Token : in String;
                           Info  : in String);

   --

   procedure Main;

   --

 end Main;


