------------------------------------------------------------------------------
--                                                                          --
--                          APQ DATABASE BINDINGS                           --
--                                                                          --
--                                  A P Q                                   --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2002-2007, Warren W. Gay VE3WWG                    --
--         Copyright (C) 2007-2011, KOW Framework Project                   --
--                                                                          --
--                                                                          --
-- APQ is free software;  you can  redistribute it  and/or modify it under  --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 2,  or (at your option) any later ver- --
-- sion.  APQ is distributed in the hope that it will be useful, but WITH-  --
-- OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY --
-- or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License --
-- for  more details.  You should have  received  a copy of the GNU General --
-- Public License  distributed with APQ;  see file COPYING.  If not, write  --
-- to  the Free Software Foundation,  59 Temple Place - Suite 330,  Boston, --
-- MA 02111-1307, USA.                                                      --
--                                                                          --
-- As a special exception,  if other files  instantiate  generics from this --
-- unit, or you link  this unit with other files  to produce an executable, --
-- this  unit  does not  by itself cause  the resulting  executable  to  be --
-- covered  by the  GNU  General  Public  License.  This exception does not --
-- however invalidate  any other reasons why  the executable file  might be --
-- covered by the  GNU Public License.                                      --
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- This is the APQ_Helper package                                   --
--                                                                          --
-- Library to perform actions over Strings                                  --
------------------------------------------------------------------------------


with Ada.Strings.Unbounded;	use Ada.Strings.Unbounded;

with Ada.Text_IO;
with Ada.Characters.Handling;	use Ada.Characters.Handling;

-- Used for string replacement
-- with GNAT.Spitbol.Patterns;


package body APQ_Helper is


	procedure Str_Replace( From, To: in Character; Str: in out String ) is
	-- replace all the ocurences of the character From by To.
	begin
		for i in Str'Range loop
			if Str(i) = From then
			Str(i) := To;
	end if;
	end loop;
	end Str_Replace;

	function Str_Replace( From, To: in Character; Str: in String ) return String is
	 -- replace all the ocurences of the character From by To returning the new Value.
		R: String := Str;
	begin
		Str_Replace( From, To, R );
		return R;
	end Str_Replace;



	procedure Str_Replace(	From, To, Str: in Unbounded_String;
				Result: in out Unbounded_String;
				Case_Sensitive: Boolean := True	) is
	begin
		Result := Str_Replace( From, To, Str, Case_Sensitive );
	end Str_Replace;

	function Str_Replace(	From, To, Str: in Unbounded_String;
				Case_Sensitive: Boolean := True	) return Unbounded_String is
	begin
		return Str_Replace(	To_String( From ),
					To_String( To ),
					To_String( Str ),
					Case_Sensitive	);
	end Str_Replace;



	procedure Str_Replace(	From, To, Str: in String;
				Result: in out Unbounded_String;
				Case_Sensitive: Boolean := True	) is
	begin
		Result := Str_Replace( From, To, Str, Case_Sensitive );
	end Str_Replace;


	function Str_Replace(	From, To: in String;
				Str: in String; Case_Sensitive: Boolean := True )
		return Unbounded_String is

		Occurances  : Positions_Array := Find_Occurances( From, Str, Case_Sensitive );
		Size_Dif	: Integer := To'Length - From'Length;
		Result		: Unbounded_String;
		Index_str	: Positive := Str'First;
		Index_Occu	: Integer := Occurances'First;
--		Element_Occu	: Integer;
		Actual		: Natural;
		
		subtype i is Integer range To'Range;

	begin

		if Occurances'Length = 0 then
			return To_Unbounded_String( Str );
		end if;

		while Index_str <= Str'Last loop

			if Index_Occu /= Occurances'Last + 1 then
				Actual :=Occurances( Index_Occu );
			else
				Actual := 0;
			end if;

			if Index_str = Actual then
				-- replace 

				for i in To'Range loop
					Append( Result, To( i ) );
				end loop;

				Index_Str := Index_Str + From'Length;
				Index_Occu := Index_Occu + 1;
				-- Index_Occu := Occurances.Next;
			else
				Append( Result, Str( Index_Str ) );
				Index_Str := Index_Str + 1;
			end if;

		end loop;

		return Result;

	end Str_Replace;


	function Find_Occurances(	Find, Context : in String; 
					Case_Sensitive: Boolean	)
		return Positions_Array is

		type List is array ( Natural range <> ) of Integer;

		function Pre_Compute( Str : in String; Case_Sensitive: Boolean ) return List is
			Pragma Inline ( Pre_Compute );

			-- computes the failure_function table of the KMP algorithm
			pos : Integer;
			T : List( 0 .. Str'Length ) := ( 0 .. Str'Length => -1 );
			Str2 : String := Str;

			use Ada.Text_IO;
		begin

			if Case_Sensitive then
				Str2 := To_Lower( Str );
			end if;

			for i in 1 .. Str'Length loop
				pos := T( i - 1 );

				while pos /= -1 and then Str( pos + 1 ) /= Str( i ) loop
					pos := T( pos );
				end loop;

				T( i ) := pos + 1;
			end loop;

			return T;

		end;

		-- declarations
		Matches		: Positions_Array( Context'Range );
		Matches_Idx	: Integer := Matches'First;
		Context_Idx	: Positive := 1;
		Table		: List := Pre_Compute( Find, Case_Sensitive );
		Find_Idx	: Integer := 0;

		Find2		: String := Find;
		Context2	: String := Context;

		use Ada.Text_IO;
	begin
		-- Knuth-Morris-Pratt algorithm

		if Case_Sensitive then
			Find2 := To_Lower( Find );
			Context2 := To_Lower( Context );
		end if;

		while Context_Idx <= Context2'Length loop

			while Find_Idx /= -1 and then ( Find_Idx = Find2'Length or 
				else Find2( Find_Idx + 1 ) /= Context2( Context_Idx ) )
			loop
				Find_Idx := Table( Find_Idx );
			end loop;

			Find_Idx := Find_Idx + 1;
			Context_Idx := Context_Idx + 1;

			if Find_Idx = Find2'Length then
				Matches( Matches_Idx ) := Context_idx - Find2'Length;
				Matches_Idx := Matches_Idx + 1;
			end if;
		end loop;

		return Matches( Matches'First .. Matches_Idx - 1 );

	end Find_Occurances;


	-- for compatibility with older version
	procedure Str_Replace( From, To: in Unbounded_String; Str: in out Unbounded_String ) is
	begin
		Str := Str_Replace( To_String( From ), To_String( To ), To_String( Str ) );
	end Str_Replace;


	procedure Str_Replace( From, To: in String; Str: in out Unbounded_String ) is
	begin
		Str := Str_Replace( From, To, To_String( Str ) );
	end Str_Replace;
 
	function Str_Replace( From, To: in String; Str: in Unbounded_String )
		return Unbounded_String is
	begin
		return Str_Replace( From, To, To_String( Str ) );
	end Str_Replace;


end APQ_Helper;

