--
-- @filename StuffList.ads
-- @author bbracke
-- @date 2004.11.30
-- @version 1.0
-- @brief List datastructure definitions and handling.
--


with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with System;                use System;
with Unchecked_Conversion;

package StuffList is

   type Item_Type is tagged
   record
   Name     : Unbounded_String;
   Lent_To  : Unbounded_String;
   Date     : Unbounded_String;
   Notes    : Unbounded_String;
   Id       : Integer;
   end record;

   type Element_Pointer is access Item_Type;

   type Node is private;
   type Position is access Node;

   type List        is limited private;
   type ListPointer is access List;

   function Adr_To_Account is new Unchecked_Conversion (source => Address,
                                                        target => Element_Pointer);
                                                        
   --
   -- List
   --
   
   OutOfSpace : exception; -- raised if no space left for a new node
   PastEnd    : exception; -- raised if a Position is past the end
   PastBegin  : exception; -- raised if a Position is before the begin
   EmptyList  : exception;

   --
   -- Remove element from List
   --
   procedure Remove_Element (Section : in out StuffList.List;
                             Item_ID : in Natural);

   --
   -- Return element from List
   --
   function Get_Element (Section : in StuffList.List;
                         Item_ID : in Natural) return Element_Pointer;

   --
   -- Delete all elements in list
   --
   procedure Delete_List (L : in out List);

   --
   --  Pre:  L and X are defined
   --  Post: a node containing X is inserted
   --        at the front or rear of L, respectively
   --
   procedure AddToRear (L : in out List; X : StuffList.Element_Pointer);


   --
   -- Returns the number of elements in the list.
   --
   function Count_Elements (L : in List) return Integer;

   --
   --
   -- Swap contents of X and Y.
   --
   procedure Swap (L : in out List;
                   X : in Position;
                   Y : in Position);

   function First (L : List) return Position;

   --
   --  Pre:    L and P are defined; P designates a node in L
   --  Post:   returns the value of the element at position P
   --  Raises: EmptyList if L is empty
   --          PastBegin if P points before the beginning of L
   --          PastEnd   if P points beyond the end of L
   --
   function Retrieve (L : in List; P : in Position)
                           return StuffList.Element_Pointer;

   --
   --  Pre:    L and P are defined; P designates a node in L
   --  Post:   the node at position P of L is deleted
   --  Raises: EmptyList if L is empty
   --          PastBegin if P is NULL
   --
   procedure Delete (L : in out List; P : Position);

   --
   --  Pre:    L and P are defined; P designates a node in L
   --  Post:   P is advanced to designate the next node of L
   --  Raises: EmptyList if L is empty
   --          PastEnd   if P points beyond the end of L
   --
   procedure GoAhead (L : List; P : in out Position);

   --
   --  Pre:    L and P are defined; P designates a node in L
   --  Post:   P is moved to designate the previous node of L
   --  Raises: EmptyList if L is empty
   --          PastBegin if P points beyond the end of L
   --
   procedure GoBack    (L : List; P : in out Position);
   
   function  IsEmpty   (L : List) return Boolean;
   function  IsFirst   (L : List; P : Position) return Boolean;
   function  IsLast    (L : List; P : Position) return Boolean;
   function  IsPastEnd (L : List; P : Position) return Boolean;

   --
   --  Pre:    L and P are defined
   --  Post:   return True if the condition is met; False otherwise
   --
   function  IsPastBegin (L : List; P : Position) return Boolean;


private

   type Node is record
     Info : StuffList.Element_Pointer := null;
     Link : Position := null;
   end record;
   
   type List is record
     Head : Position := null;
     Tail : Position := null;
   end record;

------------------------------------------------------------------------
--  | Generic ADT for one-way linked lists
--  | Author: Michael B. Feldman, The George Washington University
--  | Last Modified: January 1996
------------------------------------------------------------------------

end StuffList;
