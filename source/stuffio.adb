with Ada.Strings.Maps;           use Ada.Strings.Maps;
with Ada.Characters.Handling;    use Ada.Characters.Handling;
with Main;                       use Main;
with Strings_Cutter;             use Strings_Cutter;
with Ada.Exceptions;
with Reporter;

with RASCAL.WimpTask;            use RASCAL.WimpTask;
with RASCAL.Utility;             use RASCAL.Utility;
with RASCAL.Error;               use RASCAL.Error;
with RASCAL.MessageTrans;        use RASCAL.MessageTrans;
with RASCAL.FileExternal;        use RASCAL.FileExternal;
with RASCAL.FileInternal;        use RASCAL.FileInternal;
with RASCAL.FileName;            use RASCAL.FileName;
with RASCAL.Heap;                use RASCAL.Heap;
with RASCAL.Memory;

package body StuffIO is

   --

   package WimpTask     renames RASCAL.WimpTask;
   package Utility      renames RASCAL.Utility;     
   package Error        renames RASCAL.Error;       
   package MessageTrans renames RASCAL.MessageTrans;
   package FileExternal renames RASCAL.FileExternal;
   package FileInternal renames RASCAL.FileInternal;
   package FileName     renames RASCAL.FileName;    
   package Heap         renames RASCAL.Heap;        
   package Memory       renames RASCAL.Memory;

   --

   List_Gadget   : constant Component_ID := 16#0#;
   Edit_Gadget   : constant Component_ID := 16#6#;
   Remove_Gadget : constant Component_ID := 16#2#;

   Extent   : Natural       := 0;
   TabSpace : Character_Set := To_Set("  " & ASCII.HT);
   Offset   : Integer       := 0;

   --

   function Read_Buffer (Buffer : in Heap_Block_Type) return String is

      Line : String := Memory.Get_Line (Heap.Get_Address(Buffer),Offset);
   begin
      Offset := Offset + Line'Length+1;     
      return Line;
   end Read_Buffer;

   --

   function IsEOF return Boolean is
   begin
      return not (Offset < Extent);
   end IsEOF;

   --

   procedure Read is

      Path : String  := Choices_Read & ".Data";
   begin
      if FileExternal.Exists(Path) then
         declare
            File            : FileHandle_Type(new UString'(U(Path)),Read);
            Illegal_Letters : constant String            := S(Replace_Characters);
            Legal_Letters   : constant String            := ",";
            Legalise        : constant Character_Mapping := To_Mapping(Illegal_Letters,Legal_Letters);
            E               : Error_Pointer              := Get_Error (Wimp_Task_Class(Main_Task));
            M               : Error_Message_Pointer      := new Error_Message_Type;
            Result          : Error_Return_Type          := XButton1;
            Ext             : constant integer           := FileInternal.Get_Extent(File);
            File_Buffer     : Heap_Block_Type(Ext+1);
            Line            : Unbounded_String;
            Cutted          : Cut_String;
            Bad_Data        : Boolean := false;
            Seperator       : String := ",";
         begin
            Extent := Ext;
            FileInternal.Load_File (Path,Heap.Get_Address(File_Buffer));
            loop
               exit when IsEOF;
   
               Line := Trim(U(Read_Buffer (File_Buffer)),TabSpace,TabSpace);
               if Length(Line) > 0 then
                  if Count (Line,"¤") > 0 then
                     Seperator(Seperator'First..Seperator'Last) := "¤";
                  end if;   
                  if Count (Line,Seperator) >= 3 then
                     if Count (Line,Seperator) > 3 then
                        Bad_Data := true;
                     end if;
                     Create (Cutted, From => S(Line), Separators => Seperator);
                     AddToRear (Model,new Item_Type'(Translate(U(Field(Cutted,1)),Legalise),
                                                     Translate(U(Field(Cutted,2)),Legalise),
                                                     Translate(U(Field(Cutted,3)),Legalise),
                                                     Translate(U(Field(Cutted,4)),Legalise),0));
                  else
                     Bad_Data := true;
                  end if;
               end if;
            end loop;
            if Bad_Data then
               M.all.Token(1..7) := "BADDATA";
               M.all.Category     := Warning;                                      
               M.all.Flags        := Error_Flag_Ok;
               Result := Error.Show_Message (E,M);
            end if;
         end;
      end if;   
   exception
      when ex : others => Report_Error("HANDLE_CSVREAD",Ada.Exceptions.Exception_Information (ex));
   end Read;

   --

   procedure Save is
   begin
      if not FileExternal.Exists(Choices_Write) then
         FileExternal.Create_Directory (Choices_Write);
      end if;
      if FileExternal.Exists(Choices_Write) then
         declare
            Path            : String                 := Choices_Write & ".Data";
            Illegal_Letters : constant String        := ",";
            Legal_Letters   : constant String        := S(Replace_Characters);
            Legalise        : Character_Mapping      := To_Mapping(Illegal_Letters,Legal_Letters);
            i               : StuffList.Position;
            Item            : Element_Pointer;
            Item_Str        : Unbounded_String;
            File            : FileHandle_Type(new UString'(U(Path)),Write);
         begin
            if not isEmpty(Model) then
               i := First(Model);
               loop
                  Item := Retrieve (Model,i);
                  Item_Str := Translate (Item.all.Name,Legalise);
                  Append(Item_Str,',');
                  Append(Item_Str,Translate (Item.all.Lent_To,Legalise));
                  Append(Item_Str,',');
                  Append(Item_Str,Translate (Item.all.Date,Legalise));
                  Append(Item_Str,',');
                  Append(Item_Str,Translate (Item.all.Notes,Legalise));
                  Put_String (File,S(Item_Str));
                  
                  exit when IsLast(Model,i);
                  GoAhead(Model,i);
               end loop;
            end if;
         end;
      end if;
   exception
      when ex: others => Report_Error("HANDLE_SAVECSV",Ada.Exceptions.Exception_Information (ex));
   end Save;

   --
    
end StuffIO;