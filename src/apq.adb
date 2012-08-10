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



with APQ_Helper;


with Ada.Calendar.Formatting;
with Ada.Characters.Latin_1;
with Ada.Strings.Fixed;
with Ada.Characters.Handling;

package body APQ is


	type Time_Unit is ( Hour, Minute, Second );

	----------------
	-- EXCEPTIONS --
	----------------

	function To_Pattern_Array(Zero: in String) return Pattern_Array is
		-- return a Pattern array that maps from 0 to Zero.
		A: Pattern_Array := (	0 => To_Unbounded_String(Zero));
	begin
		return A;
	end To_Pattern_Array;


	function To_Pattern_Array(Zero, One: in String) return Pattern_Array is
		-- same as the previous, but including both zero and one.
		A: Pattern_Array := (	0 => To_Unbounded_String(Zero) ,
					1 => To_Unbounded_String(One) );
	begin
		return A;
	end To_Pattern_Array;


	function To_Pattern_Array(Zero, One, Two: in String)
		return Pattern_Array is
		-- same as the previous, but including both zero, one and two.
		A: Pattern_Array := (	0 => To_Unbounded_String(Zero),
					1 => To_Unbounded_String(One),
					2 => To_Unbounded_String(Two) );
	begin
		return A;
	end To_Pattern_Array;


	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String; Zero: in String := "" ) is
		-- Raise the Exception E with a comprehensive error message
		Pragma Inline(Raise_APQ_Error_Exception);
		A: Pattern_Array := To_Pattern_Array( Zero );
	begin
		Raise_APQ_Error_Exception( E, Code, Where, A );
	end Raise_APQ_Error_Exception;

	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String; Zero, One: in String ) is
		-- Raise the Exception E with a comprehensive error message
		Pragma Inline(Raise_APQ_Error_Exception);
		A: Pattern_Array := To_Pattern_Array( Zero, One );
	begin
		Raise_APQ_Error_Exception( E, Code, Where, A );
	end Raise_APQ_Error_Exception;

	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String;
		Zero, One, Two: in String ) is
		-- Raise the Exception E with a comprehensive error message
		Pragma Inline(Raise_APQ_Error_Exception);

		A: Pattern_Array := To_Pattern_Array( Zero, One, Two );
	begin
		Raise_APQ_Error_Exception( E, Code, Where, A );
	end Raise_APQ_Error_Exception;


	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String;
		Patterns: in Pattern_Array ) is
		-- Raise the Exception E with a comprehensive error message

		use Ada.Strings;		-- for selecting the sides to Trim
		use Ada.Strings.Fixed;		-- Trim
		use APQ_Helper;			-- Str_Replace

		function Process_Message return String is
			Desc: Unbounded_String :=
				Unbounded_String(APQ_Error_Descriptions(Code));

			function Get_Pattern( i: in Integer ) return Unbounded_String is
				-- TODO: change the following line to a decent (and a LOT faster) implementation:
				P: String := "%" & Trim( Integer'Image( i ), Ada.Strings.Both ) & "%";
			begin
				return To_Unbounded_String( P );
			end Get_Pattern;

		begin
			for i in Patterns'Range
			loop
				Desc := Str_Replace(	From	=> Get_Pattern(i),
							To 	=> Patterns(i),
							Str	=> Desc );
			end loop;
			return To_String( Desc );
		end Process_Message;

		Message : String := "[" & APQ_Error'Image(Code) & " @ " & Where & "] " & Process_Message;
	begin
		Raise_Exception( E, Message );
	end Raise_APQ_Error_Exception;



	----------------------------------------------------------------------------------
	--			 IMPLEMENTED METHODS FOR BOTH				--
	-- 	. Root_Connection_Type and						--
	-- 	. Root_Query_Type							--
	----------------------------------------------------------------------------------
	-- These methods are provided by the APQ base package but the driver implementor--
	-- might provide their own implementations.					--
	-- Those methods, in their original implementation, make use of the abstract	--
	-- methods defined in the previous code session.				--
	----------------------------------------------------------------------------------

	function New_Query(C : Root_Connection_Type'Class) return Root_Query_Type'Class is
		-- Use this function to create a new query object for your connection.
		Q : Root_Query_Type'Class := Query_Factory(C);
	begin
		Q.SQL_Case := C.SQL_Case;  -- Preserve setting in connection
		return Q;
	end New_Query;


	--------------------------
	-- ROOT_CONNECTION_TYPE --
	--------------------------


	function Get_Case(C : Root_Connection_Type) return SQL_Case_Type is
		-- Get the SQL case used by default in this connection.
		-- All new queries will use this casing.
	begin
		return C.SQL_Case;
	end Get_Case;

	procedure Set_Case(C : in out Root_Connection_Type; SQL_Case : SQL_Case_Type) is
		-- Set the SQL case used by default in this connection.
		-- All new queries will use this casing.
	begin
		C.SQL_Case := Set_Case.SQL_Case;
	end Set_Case;



	function Get_Instance(C : Root_Connection_type) return String is
		-- Get the instance Name for the Database.
	begin
		return To_String(C.Instance);
	end Get_Instance;

	procedure Set_Instance(C : in out Root_Connection_Type; Instance : String) is
		-- Set the instance Name for the Database.
	begin
		Replace_String(C.Instance,"");
		Replace_String(C.Instance,Instance);
	end Set_Instance;



	function Get_Host_Name(C : Root_Connection_Type) return String is
		-- Get the host name for the Database server.
	begin
		return To_String(C.Host_Name);
	end Get_Host_Name;

   procedure Set_Host_Name(C : in out Root_Connection_Type; Host_Name : String) is
      -- Set the host name for the Database server.
   begin
      Replace_String(C.Host_Address,"");
      Replace_String(C.Host_Name,Set_Host_Name.Host_Name);
      c.Port_Format := UNIX_Port;

   end Set_Host_Name;



	function Get_Host_Address( C: in Root_Connection_Type ) return String is
		-- Set the host address for the database server.
	begin
		return To_String( C.Host_Address );
	end Get_Host_Address;

   procedure Set_Host_Address(C : in out Root_Connection_Type; Host_Address : String) is
      -- Set the host address for the database server.
   begin
      Replace_String(C.Host_Name,"");
      Replace_String(C.Host_Address, Set_Host_Address.Host_Address);
      c.Port_Format := IP_Port;

   end Set_Host_Address;



	function Get_Port(C : Root_Connection_Type) return Integer is
		-- Get the TCP port number.
	begin
		case C.Port_Format is
			when IP_Port =>
				return C.Port_Number;
			when UNIX_Port =>
				Raise_APQ_Error_Exception(
					E => Invalid_Format'Identity,
					Code => APQ01,
					Where => "Port" );
				return 0; -- so GNAT won't complaint
		end case;
	end Get_Port;

	procedure Set_Port(C : in out Root_Connection_Type; Port_Number : Integer) is
		-- Set the TCP port number.
	begin
		C.Port_Format := IP_Port;
		C.Port_Number := Set_Port.Port_Number;
	end Set_Port;



	function Get_Port(C : Root_Connection_Type) return String is
		-- Get the Unix Port.
	begin
		case C.Port_Format is
			when IP_Port =>
				Raise_APQ_Error_Exception(
					E => Invalid_Format'Identity,
					Code => APQ02,
					Where => "Port" );
				return ""; -- so GNAT won't complaint
			when UNIX_Port =>
				return To_String(C.Port_Name);
		end case;
	end Get_Port;

	procedure Set_Port(C : in out Root_Connection_Type; Port_Name : String) is
		-- Set the Unix Port
	begin
      		C.Port_Format     := UNIX_Port;
      		Free_Ptr(C.Port_Name);
		C.Port_Name       := new String(1..Port_Name'Length);
		C.Port_Name.all   := Set_Port.Port_Name;
	end Set_Port;



	function Get_DB_Name(C : Root_Connection_Type) return String is
		-- Get the Database name used in this connection.
	begin
		return To_String(C.DB_Name);
	end Get_DB_Name;

	procedure Set_DB_Name(C : in out Root_Connection_Type; DB_Name : String) is
		-- Set the Database name used in this connection.
	begin
		Replace_String(C.DB_Name,Set_DB_Name.DB_Name);
	end Set_DB_Name;



  	function Get_User( C: in Root_Connection_Type ) return String is
		-- Get the Username for this connection.
	begin
		return To_String(C.User_Name);
	end Get_User;

	procedure Set_User( C: in out Root_Connection_Type; User: in String ) is
		-- Set the Username for this connection.
	begin
		Replace_String( C.User_Name, User );
	end Set_User;


	function Get_Password( C: Root_Connection_Type ) return String is
		-- Get the Password for this connection.
	begin
		return To_String( C.User_Password );
	end Get_Password;

	procedure Set_Password( C: in out Root_Connection_Type; Password: in String ) is
		-- Get the Password for this connection.
	begin
		Replace_String( C.User_Password, Password );
	end Set_Password;


	procedure Set_User_Password(C : in out Root_Connection_Type; User_Name, User_Password : String) is
		-- Set both the username and the password for this connection.
	begin
		Set_User( C, Set_User_Password.User_Name );
		Set_Password( C, Set_User_Password.User_Password );
	end Set_User_Password;



	function In_Abort_State(C : Root_Connection_Type) return Boolean is
		-- Some database products (eg, PostgreSQL) can enter in a status where
		-- every operation is ignored.
		-- There is the Abort_State Exception for this, but there is also
		-- this function that checks if the connection is in this state.
	begin
		return C.Abort_State;
	end In_Abort_State;



	function Get_Rollback_On_Finalize(C : Root_Connection_Type) return Boolean is
		-- Get if the work will be rollbacked when finalizing.
	begin
		return C.Rollback_Finalize;
	end Get_Rollback_On_Finalize;

	procedure Set_Rollback_On_Finalize(C : in out Root_Connection_Type; Rollback : Boolean) is
		-- Set if the work will be rollbacked when finalizing
	begin
		C.Rollback_Finalize := Rollback;
	end Set_Rollback_On_Finalize;


	procedure Set_Auto_Reconnect( C : in out Root_Connection_Type; Auto_Reconnect : in Boolean := True ) is
		-- set if it should reconnect automatically when the connection is droped.
	begin
		C.Auto_Reconnect := Auto_Reconnect;
	end Set_Auto_Reconnect;


	function Get_Auto_Reconnect( C : in Root_Connection_Type ) return Boolean is
		-- return true if the connection should be automatically restablished when droped
	begin
		return C.Auto_Reconnect;
	end Get_Auto_Reconnect;

	---------------------
	-- ROOT_QUERY_TYPE --
   	---------------------



	-- Query setup ...

	function Get_Case(Q : Root_Query_Type) return SQL_Case_Type is
		-- Get the case used by this query
		-- This case might be different from the one used by default
	begin
		return Q.SQL_Case;
	end Get_Case;

	procedure Set_Case(Q : in out Root_Query_Type; SQL_Case : SQL_Case_Type) is
		-- Set the case used by this query.
	begin
		Q.SQL_Case := Set_Case.SQL_Case;
	end Set_Case;



	function Get_Fetch_Mode(Q : Root_Query_Type) return Fetch_Mode_Type is
		-- Get the fetch mode used by this query.
	begin
		return Q.Mode;
	end Get_Fetch_Mode;

	procedure Set_Fetch_Mode(Q : in out Root_Query_Type; Mode : Fetch_Mode_Type) is
		-- Set the fetch mode used by this query.
	begin
		Q.Mode := Mode;
	end Set_Fetch_Mode;



	procedure Raise_Exceptions(Query : in out Root_Query_Type; Raise_On : Boolean := True) is
		-- when Execute_Checked is called, should raise the exception back to the caller?
	begin
		Query.Raise_Exceptions := Raise_On;
	end Raise_Exceptions;

	procedure Report_Errors(Query : in out Root_Query_Type; Report_On : Boolean := True) is
		-- report sql erros when Execute_Checked is called?
	begin
		Query.Report_Errors := Report_On;
	end Report_Errors;



	-- Query information ...



	function To_String(Query : Root_Query_Type) return String is
		-- get the query text
		use Ada.Characters.Latin_1;
		Total_Length : Natural := 0;
		Append_NL    : Boolean := False;
	begin

		for X in 1..Query.Count loop
			Total_Length := Total_Length + Query.Collection(X).all'Length;
		end loop;

		if Total_Length <= 0 then
			return "";        -- No query started
		end if;

		Append_NL := Query.Collection(Query.Count).all(Query.Collection(Query.Count).all'Last) /= LF;
		if Append_NL then
			Total_Length := Total_Length + 1;
		end if;

		declare
			Return_String :   String(1..Total_Length);
			RX :              Positive := Return_String'First;
			EX :              Positive;
		begin
			for X in 1..Query.Count loop
				EX := RX + Query.Collection(X).all'Length - 1;
				case Query.SQL_Case is
					when Preserve_Case =>
						Return_String(RX..EX) := Query.Collection(X).all;
					when Upper_Case | Lower_Case =>
						if Query.Caseless(X) = True then
							Return_String(RX..EX) := To_Case(Query.Collection(X).all,Query.SQL_Case);
						else
							Return_String(RX..EX) := Query.Collection(X).all;
						end if;
				end case;
				RX := EX + 1;
			end loop;
			if Append_NL then
				Return_String(Return_String'Last) := LF;
			end if;
			return Return_String;
		end;
	end To_String;



	function Is_Select(Q : Root_Query_Type) return Boolean is
		-- is this query a select statement?
	begin
		if Q.Count < 1 then
			return False;
		end if;

		declare
			use Ada.Characters.Handling, Ada.Strings, Ada.Strings.Fixed;
			-- Get start of query :
			Query_Start : String := To_Upper(Trim(Q.Collection(1).all,Left));
		begin
			return Query_Start'Length >= 6 and then Query_Start(1..6) = "SELECT";
		end;

	end Is_Select;



	function Cursor_Name(Query : Root_Query_Type) return String is
		-- get the cursor name for the current result
		-- this function is meant to be overwriten by the driver if it supports cursor
	begin
		Raise_APQ_Error_Exception(
			E	=> Not_Supported'Identity,
			Code	=> APQ28,
			Where	=> "Cursor_Name");
		return "?";  -- For compiler only
	end Cursor_Name;



	-- SQL creation ...



	procedure Clear(Q : in out Root_Query_Type) is
		-- Clear the query so one can start a new SQL expression.
	begin
		for X in 1..Q.Count loop
			Free_Ptr(Q.Collection(X));
		end loop;
		Free(Q.Collection);
		Q.Count := 0;
		Q.Tuple_Index := Tuple_Index_Type'First;
		Q.Rewound := True;
	end Clear;



	procedure Grow(Q : in out Root_Query_Type) is
		-- used internally to grow the query size so Append works
	begin
		if Q.Count <= 0 then
			Q.Alloc := 64;
			Q.Collection := new String_Ptr_Array(1..Q.Alloc);
			Q.Caseless   := new Boolean_Array(1..Q.Alloc);
		elsif Q.Count >= Q.Alloc then
			declare
				New_Alloc : Natural := Q.Alloc + 128;
				New_Array : String_Ptr_Array_Access := new String_Ptr_Array(1..New_Alloc);
				New_Case  : Boolean_Array_Access    := new Boolean_Array(1..New_Alloc);
			begin
				New_Array(1..Q.Alloc) := Q.Collection.all;
				New_Case(1..Q.Alloc)  := Q.Caseless.all;
				Free(Q.Collection);
				Free(Q.Caseless);
				Q.Alloc := New_Alloc;
				Q.Collection := New_Array;
				Q.Caseless   := New_Case;
			end;
		end if;
	end Grow;


	procedure Prepare(Q : in out Root_Query_Type; SQL : String; After : String := Line_Feed) is
		-- Clear the query, starting a new one.
	begin
		Clear(Root_Query_Type'Class(Q));
		Append(Root_Query_Type'Class(Q),SQL,After);
	end Prepare;


	procedure Append(Q : in out Root_Query_Type; SQL : String; After : String := "") is
		-- Append a string to the query
		use Ada.Characters.Latin_1;
		NSL : Natural := SQL'Length + After'Length;
	begin
		Grow(Q);
		Q.Count := Q.Count + 1;
		Q.Collection(Q.Count) := new String(1..NSL);
		Q.Collection(Q.Count).all(1..SQL'Length) := SQL;
		Q.Collection(Q.Count).all(SQL'Length+1..NSL) := After;
		Q.Caseless(Q.Count) := True;    -- Don't preserve case
	end Append;



	procedure Append(Q: in out Root_Query_Type; SQL: in Ada.Strings.Unbounded.Unbounded_String; After: String := "") is
		-- Append an Unbounded_String to the query
		Pragma Inline(Append);
	begin
		Append( Q, Ada.Strings.Unbounded.To_String( SQL ), After );
	end Append;
--	procedure Append(Q : in out Root_Query_Type; SQL : Ada.Strings.Unbounded.Unbounded_String; After : String := "") is
--		use Ada.Characters.Latin_1, Ada.Strings.Unbounded;
--		Len : Natural := Length(SQL);
--		NSL : Natural := Len + After'Length;
--	begin
--		Grow(Q);
--		Q.Count := Q.Count + 1;
--		Q.Collection(Q.Count) := new String(1..NSL);
--		Q.Collection(Q.Count).all(1..Len) := To_String(SQL);
--		Q.Collection(Q.Count).all(Len+1..NSL) := After;
--		Q.Caseless(Q.Count) := True;    -- Don't preserve case
--	end Append;

	procedure Append_Line(Q : in out Root_Query_Type; SQL : String := "") is
		New_Line : String(1..1);
	begin
		New_Line(1) := Ada.Characters.Latin_1.LF;
		Append(Q, SQL, New_Line);
	end Append_Line;



	procedure Append(Q : in out Root_Query_Type; V : APQ_Boolean; After : String := "") is
		-- Append a boolean to the query
	begin
		Append(Root_Query_Type'Class(Q),To_String(V),After);
	end Append;



	procedure Append(Q : in out Root_Query_Type; V : APQ_Date; After : String := "") is
		-- Append a date to the query
		use Ada.Calendar;
		S : String := To_String(V);
	begin
		Append(Root_Query_Type'Class(Q),"'",S);
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append;



	procedure Append(Q : in out Root_Query_Type; V : APQ_Time; After : String := "") is
		-- Append a time...
		use Ada.Calendar;
		S : String := To_String(V);
	begin
		Append(Root_Query_Type'Class(Q),"'",S);
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append;



	procedure Append(Q : in out Root_Query_Type; V : APQ_Timestamp; After : String := "") is
		-- Append a timestamp...
		use Ada.Calendar;
		D : String := To_String(V);
	begin
		Append(Root_Query_Type'Class(Q),"'",D);
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append;


	procedure Append(Q : in out Root_Query_Type; V : Row_ID_Type; After : String := "") is
		-- Append a row_id_type...
		function To_String is new Modular_String(Row_ID_Type);
	begin
		Append(Root_Query_Type'Class(Q),To_String(V),After);
	end Append;



	procedure Append(Q : in out Root_Query_Type; V : APQ_Bitstring; After : String := "") is
		-- Append a bitstring...
		S : String := To_String(V);
	begin
		Append(Root_Query_Type'Class(Q),"B'",S);
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append;



	procedure Append_Quoted(Q : in out Root_Query_Type; Connection : Root_Connection_Type'Class; SQL : String; After : String := "") is
		-- Append a quoted String.
		-- The case of this String isn't changed.
		-- This primitive should normally be overriden for a specific database.
		-- PostgreSQL and MySQL will potentially have different quoting requirements.
	begin
		Append(Root_Query_Type'Class(Q),"'" & SQL & "'",After);
		Q.Caseless(Q.Count) := False;   -- Preserve case here
	end Append_Quoted;

	procedure Append_Quoted(Q : in out Root_Query_Type; Connection : Root_Connection_Type'Class; SQL : Ada.Strings.Unbounded.Unbounded_String; After : String := "") is
		-- Append a quoted String.
		-- The case of this String isn't changed.
		-- This primitive should normally be overriden for a specific database.
		-- PostgreSQL and MySQL will potentially have different quoting requirements.
	begin
		Append_Quoted(Root_Query_Type'Class(Q),Connection,Ada.Strings.Unbounded.To_String(SQL),After);
	end Append_Quoted;


	-- Data retrieval:


	procedure Value(Query: Root_Query_Type; CX : Column_Index_Type; V : out String) is
		-- Get the value of the CXth column as String.
		-- Fixed length String Fetch
		S : String := Value(Root_Query_Type'Class(Query),CX);
	begin
		if S'Length = V'Length then
			V := S;
		elsif S'Length > V'Length then
			Raise_APQ_Error_Exception(
				E	=> Small_Buffer'Identity,
				Code	=> APQ09,
				Where	=> "Value",
				Zero	=> Column_Index_Type'Image(CX) );
		else
			V(V'First..S'Length) := S;
			V(S'Length+1..V'Last) := ( others => ' ' );
		end if;
	end Value;



	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Ada.Strings.Unbounded.Unbounded_String is
		-- Get the value of the CXth column as Unbounded_String.
		use Ada.Strings.Unbounded;
		Str: String := Value(Root_Query_Type'Class(Query),CX);
	begin
		return To_Unbounded_String(Str);
	end Value;



	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Row_ID_Type is
		-- Get the value of the CXth column as Row_Id_Type.
		S : String := Value(Root_Query_Type'Class(Query),CX);
	begin
		return Row_ID_Type'Value(S);
	exception
		when Constraint_Error =>
			Raise_APQ_Error_Exception(
				E	=> Constraint_Error'Identity,
				Code	=> APQ08,
				Where	=> "Value",
				Zero	=> Column_Index_Type'Image(CX) );
			return 0; -- so GNAT won't complaint
	end Value;


	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Bitstring is
		-- Get the value of the CXth column as Bitstring.
		use Ada.Strings, Ada.Strings.Fixed;
		S : String := Trim(Value(Root_Query_Type'Class(Query),CX),Both);
		R : APQ_Bitstring(1..S'Length);
	begin
		for X in S'Range loop
			R(X) := S(X) /= '0';
		end loop;
		return R;
	end Value;





	--           METHODS THAT SHOULD BE OVERRIDDEN BY THE DATABASE DRIVER           --


	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Boolean is
		V : Integer := Value(Root_Query_Type'Class(Query),CX);
	begin
		if V = 0 then
			return FALSE;
		else
			return TRUE;
		end if;
	exception
		when Constraint_Error =>
			Raise_APQ_Error_Exception(
				E	=> Constraint_Error'Identity,
				Code	=> APQ10,
				Where	=> "Value (Returns Boolean)",
				Zero	=> Column_Index_Type'Image(CX) );
			return false; -- we return something so gnat won't complaint
	end Value;

	--TODO: Solve a possible problem with databases that can store values bigger or smaller than Integer.
	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Integer is
		S : String := Value(Root_Query_Type'Class(Query), CX);
	begin
		return Integer'Value(S);
	exception
		when Constraint_Error =>
			Raise_APQ_Error_Exception(
				E	=> Constraint_Error'Identity,
				Code	=> APQ11,
				Where	=> "Value (Returns Integer)",
				Zero	=> Column_Index_Type'Image(CX) );
	end Value;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Float is
		S : String := Value(Root_Query_Type'Class(Query), CX);
	begin
		return Float'Value(S);
	exception
		when Constraint_Error =>
			Raise_APQ_Error_Exception(
				E	=> Constraint_Error'Identity,
				Code	=> APQ13,
				Where	=> "Value (Returns Float)",
				Zero	=> Column_Index_Type'Image(CX) );
	end Value;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Date is
	begin
		return To_Date( Value( Root_Query_Type'Class( Query ), CX ) );
	exception
		when Constraint_Error =>
			Raise_APQ_Error_Exception(
				E	=> Constraint_Error'Identity,
				Code	=> APQ17,
				Where	=> "Value (Returns APQ_Date)",
				Zero	=> Column_Index_Type'Image(CX) );
		when Invalid_Format =>
			Raise_APQ_Error_Exception(
				E	=> Invalid_Format'Identity,
				Code	=> APQ18,
				Where	=> "Value (Returns APQ_Date)",
				Zero	=> Value( Root_Query_Type'Class(Query), CX ),
				One	=> Column_Index_Type'Image(CX) );
	end Value;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Time is
		function To_Time is new Convert_To_Time(APQ_Time);
		Text : String := Value(Root_Query_Type'Class(Query),CX);
	begin
		return To_Time(Text);
	exception
		when Constraint_Error =>
			Raise_APQ_Error_Exception(
				E	=> Constraint_Error'Identity,
				Code	=> APQ19,
				Where	=> "Value (Returns APQ_Time)",
				Zero	=> Value(Root_Query_Type'Class(Query), CX),
				One	=> Column_Index_Type'Image(CX) );
	end Value;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Timestamp is
		Text : String := Value( Root_Query_Type'Class( Query ), CX );
	begin
		return To_Timestamp( Text );
	exception
		when Constraint_Error | Invalid_Format =>
			Raise_APQ_Error_Exception(
				E	=> Invalid_Format'Identity,
				Code	=> APQ20,
				Where	=> "Value (Returns APQ_Timestamp)",
				Zero	=> Value(Root_Query_Type'Class(Query), CX),
				One	=> Column_Index_Type'Image(CX) );
	end Value;


	----------------------------------------------------------------------------------
	--				GENERIC METHODS FOR				--
	-- 	. Root_Query_Type							--
	----------------------------------------------------------------------------------
	-- These  methods  are  implemented  using the abstract and implemented methods	--
	-- that are listed before this block.						--
	--										--
	-- They  are  meant  to  enforce  strong  typing  with  Database  programming.	--
	----------------------------------------------------------------------------------



	-- SQL creation :: append ...


	procedure Append_Boolean(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
	begin
		Append( Q, APQ_Boolean( V ), After );
	end Append_Boolean;



	procedure Append_Integer(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Integer_String(Val_Type);
		S : String := To_String(V);
	begin
		Append(Root_Query_Type'Class(Q),S,After);
	end Append_Integer;



	procedure Append_Modular(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Modular_String(Val_Type);
		S : String := To_String(V);
	begin
		Append(Root_Query_Type'Class(Q),S,After);
	end Append_Modular;



	procedure Append_Float(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Float_String(Val_Type);
	begin
		Append(Root_Query_Type'Class(Q),To_String(V),After);
	end Append_Float;



	procedure Append_Fixed(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new APQ.Fixed_String(Val_Type);
	begin
		Append(Root_Query_Type'Class(Q),To_String(V),After);
	end Append_Fixed;



	procedure Append_Decimal(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Decimal_String(Val_Type);
	begin
		Append(Root_Query_Type'Class(Q),To_String(V),After);
	end Append_Decimal;




	procedure Append_Date(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Date_String(Val_Type);
	begin
		Append(Root_Query_Type'Class(Q),"'",To_String(V));
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append_Date;

	procedure Append_Time(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Time_String(Val_Type);
	begin
		Append(Root_Query_Type'Class(Q),"'",To_String(V));
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append_Time;



	procedure Append_Timestamp(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
		function To_String is new Timestamp_String(Val_Type);
	begin
		Append(Root_Query_Type'Class(Q),"'",To_String(V));
		Append(Root_Query_Type'Class(Q),"'",After);
	end Append_Timestamp;




	procedure Append_Bitstring(Q : in out Root_Query_Type'Class; V : Val_Type; After : String := "") is
	begin
		Append(Root_Query_Type'Class(Q),To_String(APQ_Bitstring(V)),After);
	end Append_Bitstring;



	procedure Append_Bounded(Q : in out Root_Query_Type'Class; SQL : P.Bounded_String; After : String := "") is
	begin
		Append(Root_Query_Type'Class(Q),P.To_String(SQL),After);
	end Append_Bounded;



	procedure Append_Bounded_Quoted(Q : in out Root_Query_Type'Class; Connection : Root_Connection_Type'Class; SQL : P.Bounded_String; After : String := "") is
	begin
		Append_Quoted(Root_Query_Type'Class(Q),Connection,P.To_String(SQL),After);
	end Append_Bounded_Quoted;



	-- SQL creation :: encode...
	-- encode is the same as append, but supporting null values.



	procedure Encode_Boolean(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Boolean(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Boolean;



	procedure Encode_Integer(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Integer(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Integer;



	procedure Encode_Modular(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Modular(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Modular;



	procedure Encode_Float(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Float(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Float;



	procedure Encode_Fixed(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Fixed(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Fixed;



	procedure Encode_Decimal(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Decimal(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Decimal;



	procedure Encode_Date(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Date(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Date;



	procedure Encode_Time(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure Append is new Append_Time(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Time;



	procedure Encode_Timestamp(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure App is new Append_Timestamp(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			App(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Timestamp;



	procedure Encode_Bitstring(Q : in out Root_Query_Type'Class; V : Val_Type; Indicator : Ind_Type; After : String := "") is
		procedure App is new Append_Bitstring(Val_Type);
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			App(Root_Query_Type'Class(Q),V,After);
		end if;
	end Encode_Bitstring;



	procedure Encode_String_Quoted(Q : in out Root_Query_Type'Class; Connection : Root_Connection_Type'Class; SQL : String; Indicator : Ind_Type; After : String := "") is
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append_Quoted(Root_Query_Type'Class(Q),Connection,SQL,After);
		end if;
	end Encode_String_Quoted;



	procedure Encode_Bounded_Quoted(Q : in out Root_Query_Type'Class; Connection : Root_Connection_Type'Class; SQL : P.Bounded_String; Indicator : Ind_Type; After : String := "") is
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append_Quoted(Root_Query_Type'Class(Q),Connection,P.To_String(SQL),After);
		end if;
	end Encode_Bounded_Quoted;



	procedure Encode_Unbounded(Q : in out Root_Query_Type'Class; Connection : Root_Connection_Type'Class; SQL : Ada.Strings.Unbounded.Unbounded_String; Indicator : Ind_Type; After : String := "") is
		use Ada.Strings.Unbounded;
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append(Root_Query_Type'Class(Q),To_String(SQL),After);
		end if;
	end Encode_Unbounded;



	procedure Encode_Unbounded_Quoted(Q : in out Root_Query_Type'Class; Connection : Root_Connection_Type'Class; SQL : Ada.Strings.Unbounded.Unbounded_String; Indicator : Ind_Type; After : String := "") is
		use Ada.Strings.Unbounded;
	begin
		if Indicator then
			Append(Root_Query_Type'Class(Q),"NULL",After);
		else
			Append_Quoted(Root_Query_Type'Class(Q),Connection,To_String(SQL),After);
		end if;
	end Encode_Unbounded_Quoted;






	-- Data retrieval :: misc ...



	function Column_Is_Null(Q : Root_Query_Type'Class; CX : Column_Index_Type) return Ind_Type is
		-- checks if the result in the CXth column is null.
	begin
		return Ind_Type(Is_Null(Root_Query_Type'Class(Q),CX));
	end Column_Is_Null;




	-- Data retrieval :: value operations ...



	function Boolean_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
--		function To_Boolean is new Convert_To_Boolean(Val_Type);
--		Text : String := Value(Root_Query_Type'Class(Query),CX);
		B: Boolean;
	begin
		B := Value( Query, CX );
		return Val_Type(B);
--		case Engine_Of(Query) is
--			when Engine_PostgreSQL =>
--				return To_Boolean(Text);
--			when Engine_MySQL =>
--				declare
--					I : Integer;
--				begin
--					I := Integer'Value(Text);  -- May raise Constraint_Error
--					return Val_Type(I /= 0);   -- Tinyint or Bit is TRUE when /= 0 for MySQL
--				end;
--			when Engine_Sybase =>
--				return To_Boolean(Text);
--			when Engine_Other =>
--				return To_Boolean(Text);
--		end case;
	end Boolean_Value;



	function Integer_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
--		S : String := Value(Root_Query_Type'Class(Query),CX);
		I : Integer;
	begin
--		return Val_Typel'Value(S);
		I := Value(Query, CX);
		return Val_Type(I);
	end Integer_Value;



	function Modular_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
		--This method may raise constraint error if the user is careless with his types.
--		S : String := Value(Root_Query_Type'Class(Query),CX);
		I : Integer;
	begin
--		return Val_Typel'Value(S);
		I := Value(Query, CX);
		return Val_Type(I);
	end Modular_Value;



	function Float_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
--		S : String := Value(Root_Query_Type'Class(Query),CX);
		F : Float;
	begin
--		return Val_Typel'Value(S);
		F := Value(Query, CX);
		return Val_Type(F);
	end Float_Value;



	function Fixed_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
		--This method may raise constraint error if the user is careless with his types.
--		S : String := Value(Root_Query_Type'Class(Query),CX);
		F : Float;
	begin
--		return Val_Typel'Value(S);
		F := Value(Query, CX);
		return Val_Type(F);
	end Fixed_Value;



	function Decimal_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
		--This method may raise constraint error if the user is careless with his types.
--		S : String := Value(Root_Query_Type'Class(Query),CX);
		F : Float;
	begin
--		return Val_Typel'Value(S);
		F := Value(Query, CX);
		return Val_Type(F);
	end Decimal_Value;



	function Date_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
		date : APQ_Date;
	begin
		date := Value(Query, CX);
		return Val_Type(date);
	end Date_Value;



	-- MySQL does not format the result: Explode it into YYYY-MM-DD HH:MM:SS format.
	--
	-- Acceptable formats:
	--
	--    "YYYY-MM-DD HH:MM:SS"   S'Length = 19
	--     1234567890123456789
	--    "YYYYMMDDHHMMSS"        S'Length = 14
	--     1234567890123456789
	--    "YYMMDDHHMMSS"          S'Length = 12
	--
	function MySQL_YYYYMMDDHHMMSS(S : String) return String is
		--TODO: Send this method over to the mysql client.
		T : String(1..S'Length) := S;
	begin
		case T'Length is
			when 19 =>
				return T;
			when 14 =>
				return T(1..4) & "-" & T(5..6) & "-" & T(7..8) & " "
					& T(9..10) & ":" & T(11..12) & ":" & T(13..14);
			when 12 =>
				declare
					YY : Natural;
				begin
					YY := Natural'Value(T(1..2));
					if YY >= 50 then
						YY := YY + 1900;
					else
						YY := YY + 2000;
					end if;
					declare
						YYYY : String(1..5) := Natural'Image(YY);
					begin
						return YYYY(2..5) & "-" & T(3..4) & "-" & T(5..6) & " "
							& T(7..8) & ":" & T(9..10) & ":" & T(11..12);
					end;
				exception
					when others =>
						raise Constraint_Error;
				end;
			when others =>
				raise Constraint_Error;
		end case;
	end MySQL_YYYYMMDDHHMMSS;

	--
	-- MySQL does not format the result: Explode it into YYYY-MM-DD HH:MM:SS format.
	--
	-- Acceptable formats:
	--
	--    "HH:MM:SS"  S'Length = 8
	--     12345678
	--    "HHMMSS"    S'Length = 6
	--
	function MySQL_HHMMSS(S : String) return String is
		--TODO: Send this method over to the mysql client.
		T : String(1..S'Length) := S;
	begin
		case T'Length is
			when 8 =>
				return T;
			when 6 =>
				return T(1..2) & ":" & T(3..4) & ":" & T(5..6);
			when others =>
				raise Constraint_Error;
		end case;
	end MySQL_HHMMSS;



	function Time_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
		Time : APQ_Time;
	begin
		Time := Value(Query, CX);
		return Val_Type(Time);
	end Time_Value;



	function Timestamp_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return Val_Type is
		Timestamp : APQ_Timestamp;
	begin
		Timestamp := Value(Query, CX);
		return Val_Type(Timestamp);

	exception
		when Constraint_Error | Invalid_Format =>
			Raise_APQ_Error_Exception(
				E	=> Invalid_Format'Identity,
				Code	=> APQ20,
				Where	=> "Timestamp_Value",
				Zero	=> Value(Root_Query_Type'Class(Query), CX),
				One	=> Column_Index_Type'Image(CX) );
	end Timestamp_Value;



	function Bounded_Value(Query : Root_Query_Type'Class; CX : Column_Index_Type) return P.Bounded_String is
		use Ada.Strings.Bounded;
	begin
		return P.To_Bounded_String(Value(Root_Query_Type'Class(Query),CX));
	end Bounded_Value;




	-- Data retrieval :: fetch operations ...
	-- They are the same as the value operations, but with null support



	procedure Boolean_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Boolean_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Boolean_Fetch;



	procedure Integer_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Integer_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Integer_Fetch;



	procedure Modular_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Modular_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Modular_Fetch;



	procedure Float_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Float_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Float_Fetch;



	procedure Fixed_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Fixed_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Fixed_Fetch;



	procedure Decimal_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Decimal_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Decimal_Fetch;



	procedure Date_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Date_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		end if;
	end Date_Fetch;



	procedure Time_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Time_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		else
			V := Val_Type'First;
		end if;
	end Time_Fetch;



	procedure Timestamp_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type) is
		function Value is new Timestamp_Value(Val_Type);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := Value(Root_Query_Type'Class(Query),CX);
		end if;
	end Timestamp_Fetch;



	procedure Bitstring_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out APQ_Bitstring; Last : out Natural; Indicator : out Ind_Type) is
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			declare
				B : APQ_Bitstring := Value(Root_Query_Type'Class(Query),CX);
			begin
				if B'Length > V'Length then
					Raise_APQ_Error_Exception(
						E	=> Small_Buffer'Identity,
						Code	=> APQ27,
						Where	=> "Bitstring_Fetch",
						Zero	=> Column_Index_Type'Image(CX) );
				end if;
				Last := V'First + B'Length - 1;
				V(V'First..Last) := B;
			end;
		end if;
	end Bitstring_Fetch;



	procedure Bounded_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out P.Bounded_String; Indicator : out Ind) is
		use Ada.Strings, P;
	begin
		Indicator := Ind( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			declare
				S : String := Value(Root_Query_Type'Class(Query),CX);
			begin
				if S'Length > Max_Length then
					Raise_APQ_Error_Exception(
						E	=> Small_Buffer'Identity,
						Code	=> APQ26,
						Where	=> "Bounded_Fetch",
						Zero	=> Column_Index_Type'Image(CX) );
				else
					V := To_Bounded_String(S,Error);
				end if;
			end;
		else
			V := Null_Bounded_String;
		end if;
	end Bounded_Fetch;



	procedure Unbounded_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out Ada.Strings.Unbounded.Unbounded_String; Indicator : out Ind_Type) is
		use Ada.Strings.Unbounded;

		Str: String := Value(Root_Query_Type'Class(Query),CX);
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			V := To_Unbounded_String(Str);
		else
			V := Null_Unbounded_String;
		end if;
	end Unbounded_Fetch;



	procedure Char_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out String; Indicator : out Ind_Type) is
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			declare
				S :      String := Value(Root_Query_Type'Class(Query),CX);
				Last :   Natural := V'First + S'Length - 1;
			begin
				if S'Length > V'Length then
					Raise_APQ_Error_Exception(
						E	=> Small_Buffer'Identity,
						Code	=> APQ25,
						Where	=> "Char_Fetch",
						Zero	=> Column_Index_Type'Image(CX) );
				end if;
				if S'Length > 0 then
					V(V'First..Last) := S;
					if Last < V'Last then
						V(Last+1..V'Last) := ( others => ' ' );
					end if;
				else
					V := ( others => ' ' );
				end if;
			end;
		end if;
	end Char_Fetch;



	procedure Varchar_Fetch(Query : Root_Query_Type'Class; CX : Column_Index_Type; V : out String; Last : out Natural; Indicator : out Ind_Type) is
	begin
		Indicator := Ind_Type( Is_Null(Root_Query_Type'Class(Query),CX) );
		if not Indicator then
			declare
				S : String := Value(Root_Query_Type'Class(Query),CX);
			begin
				if S'Length > V'Length then
					Raise_APQ_Error_Exception(
						E	=> Small_Buffer'Identity,
						Code	=> APQ24,
						Where	=> "Varchar_Fetch",
						Zero	=> Column_Index_Type'Image(CX) );
				end if;
				Last := V'First + S'Length - 1;
				V(V'First..Last) := S;
			end;
		end if;
	end Varchar_Fetch;





	-- Conversion :: anything to string (APQ primitives) ...



	function To_String(V : APQ_Boolean) return String is
	begin
		if V then
			return "1";
		else
			return "0";
		end if;
	end To_String;



	function To_String( V : APQ_Date ) return String is
		use Ada.Calendar;

		Str : constant String := Ada.Calendar.Formatting.Image(
							Date			=> V,
							Include_time_Fraction	=> False,
							Time_Zone		=> Ada.Calendar.Time_Zones.UTC_Time_Offset( V )
						);
	begin
		return Str( Str'First .. Ada.Strings.Fixed.Index( Str, " " ) );
	end To_String;



	function To_String( V : APQ_Time ) return String is
	begin
		return Ada.Calendar.Formatting.Image(
					Elapsed_Time		=> Duration( V ),
					Include_Time_Fraction	=> True
				);
	end To_String;



	function To_String( V : APQ_Timestamp ) return String is
	begin
		return Ada.Calendar.Formatting.Image(
						Date			=> Ada.Calendar.Time( V ),
						Include_Time_Fraction	=> True,
						Time_zone		=> 0
					);
	end To_String;



	function To_String(V : APQ_Bitstring) return String is
		S : String(V'Range);
	begin
		for X in V'Range loop
			if V(X) then
				S(X) := '1';
			else
				S(X) := '0';
			end if;
		end loop;
		return S;
	end To_String;



	-- Conversion :: anything to string (generic for derived types) ...



	function Modular_String(V : Val_Type) return String is
		use Ada.Strings.Fixed, Ada.Strings;
		package MODIO is new Ada.Text_IO.Modular_IO(Val_Type);
		S : String(1..40);
	begin
		MODIO.Put(To => S, Item => V, Base => 10);
		return Trim(S,Both);
	end Modular_String;



	function Integer_String(V : Val_Type) return String is
		use Ada.Strings.Fixed, Ada.Strings;
		package INTIO1 is new Ada.Text_IO.Integer_IO(Val_Type);
		S : String(1..40);
	begin
		INTIO1.Put(To => S, Item => V, Base => 10);
		return Trim(S,Both);
	end Integer_String;



	function Float_String(V : Val_Type) return String is
		use Ada.Strings.Fixed, Ada.Strings;
		package FLTIO is new Ada.Text_IO.Float_IO(Val_Type);
		S : String(1..50);
	begin
		FLTIO.Put(To => S, Item => V, Exp => 3);
		return Trim(S,Both);
	end Float_String;



	function Fixed_String(V : Val_Type) return String is
		use Ada.Strings.Fixed, Ada.Strings;
		package FXTIO is new Ada.Text_IO.Fixed_IO(Val_Type);
		S : String(1..50);
	begin
		FXTIO.Put(To => S, Item => V);
		return Trim(S,Both);
	end Fixed_String;



	function Decimal_String(V : Val_Type) return String is
		use Ada.Strings.Fixed, Ada.Strings;
		package DECIO is new Ada.Text_IO.Decimal_IO(Val_Type);
		S : String(1..50);
	begin
		DECIO.Put(To => S, Item => V);
		return Trim(S,Both);
	end Decimal_String;



	function Date_String(V : Val_Type) return String is
	begin
		return To_String(APQ_Date(V));
	end Date_String;



	function Time_String(V : Val_Type) return String is
	begin
		return To_String(APQ_Time(V));
	end Time_String;



	function Timestamp_String(V : Val_Type) return String is
	begin
		return To_String(APQ_Timestamp(V));
	end Timestamp_String;



	-- Conversion :: anything from string ...



	function Convert_To_Boolean(S : String) return Val_Type is
		use Ada.Characters.Handling, Ada.Strings, Ada.Strings.Fixed;
		UC : String := To_Upper(Trim(S,Both));
	begin

		if UC'Length = 1 then
			if UC = "T" then
				return True;
			elsif UC = "F" then
				return False;
			end if;
		else
			return Val_Type'Value( S );
		end if;

		Raise_APQ_Error_Exception(
			E	=> Invalid_Format'Identity,
			Code	=> APQ07,
			Where	=> "Convert_To_Boolean",
			Zero	=> S );
		--This is here to avoid useless warnings.
		return False;
	end Convert_To_Boolean;





	function Convert_To_Time(S : String) return Val_Type is
		-- S must be HH:MM:SS[.FFF] format
	begin
		return Val_Type(
				Ada.Calendar.Formatting.Value(
						Elapsed_Time		=> S
					)
				);
	end Convert_To_Time;


	function Convert_to_Timestamp(
				S	: in String;
				TZ	: in Ada.Calendar.Time_Zones.Time_Offset
			) return Val_Type is
		D : Ada.Calendar.Time;
	begin
		D := Ada.Calendar.Formatting.Value(
						Date			=> S,
						Time_Zone		=> TZ
					);
		return Val_Type( D );
	end Convert_To_Timestamp;


	function To_Date(
				S	: in String
			) return APQ_Date is
		-- convert the string to apq_date using the UTC timezone
		function To_Date is new Convert_To_Timestamp(APQ_Date);
	begin
		return To_Date(
				S	=> S,
				TZ	=> Ada.Calendar.Time_Zones.UTC_Time_Offset( Ada.Calendar.Clock )
			);
	end To_Date;


	function To_Time(
				S	: in String
			) return APQ_Time is
		function Inner_To_Time is new Convert_To_Time( APQ_Time );
	begin
		return Inner_To_Time( S );
	end To_Time;

	function To_Timestamp(
				S	: in String
			) return APQ_Timestamp	is
		-- convert the string to apq_timestamp using the UTC timezone
		function To_Timestamp is new Convert_To_Timestamp( APQ_Timestamp );
	begin
		return To_Timestamp(
					S	=> S,
					TZ	=> Ada.Calendar.Time_Zones.UTC_Time_Offset( Ada.Calendar.Clock )
				);
	end To_Timestamp;

	function Convert_Date_and_Time(
					DT	: in Date_Type;
					TM	: in Time_Type
				) return Result_Type is
		-- return a new timestamp in DT's timezone at TM duration
		use Ada.Calendar;
		Year		: Year_Number;
		Month		: Month_Number;
		Day		: Day_Number;

		Hour		: Formatting.Hour_Number;
		Minute		: Formatting.Minute_Number;
		Second		: Formatting.Second_Number;
		Sub_Second	: Formatting.Second_Duration;
	begin
		Formatting.Split(
				Date		=> Time( DT ),
				Year		=> Year,
				Month		=> Month,
				Day		=> Day,
				Hour		=> Hour,	-- placeholder
				Minute		=> Minute,	-- placeholder
				Second		=> Second,	-- placeholder
				Sub_Second	=> Sub_Second,	-- placeholder
				Time_Zone	=> Time_Zones.UTC_Time_Offset( Time( DT ) )
			);

		Formatting.Split(
				Seconds		=> Day_Duration( TM ),
				Hour		=> Hour,
				Minute		=> Minute,
				Second		=> Second,
				Sub_Second	=> Sub_Second
			);

		return Result_Type(
				Formatting.Time_Of(
						Year		=> Year,
						Month		=> Month,
						Day		=> Day,
						Hour		=> Hour,
						Minute		=> Minute,
						Second		=> Second,
						Sub_Second	=> Sub_Second,
						Time_Zone	=> Time_Zones.UTC_Time_Offset( Time( DT ) )
					)
				);
	end Convert_Date_and_Time;




	-- Misc ...


	function Generic_Command_Oid(Query : Root_Query_Type'Class) return Oid_Type is
		-- The Generic_Command_Oid causes GNAT 3.14p to fall over and die.
		--
		-- It isn't really required, since Command_Oid(Query) can be used instead,
		-- and the return value converted to whatever Oid_Type is.

		Row : Row_ID_Type := Command_Oid(Query);
	begin
		return Oid_Type(Row);
	end Generic_Command_Oid;


	---------------------------------
	-- EXTENDED CALENDAR FUNCTIONS --
	---------------------------------


	-- A special note on these functions:
	--
	-- They have been split out to avoid a GNAT 3.13p compiler bug.

	-- internal functions ...

	function Time_Component(TM : Ada.Calendar.Day_Duration; Unit : Time_Unit) return Natural is

		S   : Ada.Calendar.Day_Duration := TM;
		Hr  : Natural range 0 .. 23;
		Min : Natural range 0 .. 59;
	begin -- Time_Component
		if TM >= Ada.Calendar.Day_Duration'Last then -- 00:00:00.0 of the next day.
			return 0;
		end if;

		Hr := Integer'Max (Integer (S / 3600 - 0.5), 0);

		if Unit = Hour then
			return Hr;
		end if;

		S := S - Duration (Hr) * 3600;
		Min := Integer'Max (Integer (S / 60 - 0.5), 0);

		if Unit = Minute then
			return Min;
		end if;

		S := S - Duration (Min) * 60;

		return Integer'Max (Integer (S - 0.5), 0);
	end Time_Component;



	function Internal_Time_of_Day(DT : Ada.Calendar.Time) return Ada.Calendar.Day_Duration is
		use Ada.Calendar;
		Year :      Year_Number;
		Month :     Month_Number;
		Day :       Day_Number;
		Seconds :   Day_Duration;
	begin
		Split(DT,Year,Month,Day,Seconds);
		return Seconds;
	end Internal_Time_of_Day;



	-- implementation of the package spec ...



	function Generic_Time_of_Day(V : Date_Type) return Time_Type is
	begin
		return Time_Type(Internal_Time_of_Day(Ada.Calendar.Time(V)));
	end Generic_Time_of_Day;



	function Generic_Hour(TM : Time_Type) return Hour_Number is
	begin
		return Hour_Number(Time_Component(Ada.Calendar.Day_Duration(TM),Hour));
	end Generic_Hour;



	function Generic_Minute(TM : Time_Type) return Minute_Number is
	begin
		return Minute_Number(Time_Component(Ada.Calendar.Day_Duration(TM),Minute));
	end Generic_Minute;



	function Generic_Second(TM : Time_Type) return Second_Number is
	begin
		return Second_Number(Time_Component(Ada.Calendar.Day_Duration(TM),Second));
	end Generic_Second;



 -- private



	function To_Case(S : String; C : SQL_Case_Type) return String is
		-- convert the string to the selected case
		use Ada.Characters.Handling;
	begin
		case C is
			when Preserve_Case =>
				return S;
			when Lower_Case =>
				return To_Lower(S);
			when Upper_case =>
				return To_Upper(S);
		end case;
	end To_Case;



	procedure Clear_Abort_State(C : in out Root_Connection_Type) is
	begin
		C.Abort_State := False;
	end Clear_Abort_State;



	procedure Adjust(Q : in out Root_Query_Type) is
	begin
		Q.Count := 0;
		Q.Alloc := 0;
		Q.Collection := null;
		Q.Caseless   := null;
		Q.Tuple_Index := Tuple_Index_Type'First;
	end Adjust;



	function Is_Insert(Q : Root_Query_Type) return Boolean is
	begin
		if Q.Count < 1 or else Q.Collection = null then
			return False;
		end if;
		declare
			use Ada.Characters.Handling;
			SQL : String := To_Upper(Q.Collection(Q.Collection'First).all);
			X :   Positive := SQL'First;
		begin
			while X <= SQL'Last loop
				exit when SQL(X) /= ' ';
				X := X + 1;
			end loop;
			if X + 5 > SQL'Last then
				return False;
			end if;
			return SQL(X..X+5) = "INSERT";
		end;
	end Is_Insert;

	function Is_Update(Q : Root_Query_Type) return Boolean is
	begin
		if Q.Count < 1 or else Q.Collection = null then
			return False;
		end if;
		declare
			use Ada.Characters.Handling;
			SQL : String := To_Upper(Q.Collection(Q.Collection'First).all);
			X :   Positive := SQL'First;
		begin
			while X <= SQL'Last loop
				exit when SQL(X) /= ' ';
				X := X + 1;
			end loop;
			if X + 5 > SQL'Last then
				return False;
			end if;
			return SQL(X..X+5) = "UPDATE";
		end;
	end Is_Update;



	procedure Free_Ptr(SP : in out String_Ptr) is
	begin
		if SP /= null then
			Free(SP);
		end if;
	end Free_Ptr;



	function To_String(S : String_Ptr) return String is
	begin
		if S /= null then
			return S.all;
		else
			return "";
		end if;
	end To_String;



	function To_Ada_String(P : Interfaces.C.Strings.chars_ptr) return String is
		use Interfaces.C, Interfaces.C.Strings;
	begin
		if P = Null_Ptr then
			return "";
		end if;
		return To_Ada(Value(P));
	end To_Ada_String;



	function Blanks_To_Zero(S : String) return String is
		R : String(S'Range) := S;
	begin
		for X in S'Range loop
			if R(X) = ' ' then
				R(X) := '0';
			end if;
		end loop;
		return R;
	end Blanks_To_Zero;



	procedure C_String(S : String_Ptr; CP : out Interfaces.C.Strings.char_array_access; Addr : out System.Address) is
		use Interfaces.C;
	begin
		if S /= null then
			CP   := new char_array'(To_C(S.all));
			Addr := CP.all'Address;
		else
			CP := null;
			Addr := System.Null_Address;
		end if;
	end C_String;



	procedure C_String(S : String; CP : out Interfaces.C.Strings.char_array_access; Addr : out System.Address) is
		use Interfaces.C;
	begin
		CP   := new char_array'(To_C(S));
		Addr := CP.all'Address;
	end C_String;



	function Strip_NL(S : String) return String is
		use Ada.Characters.Latin_1;
		NX : Natural := S'Last;
	begin
		for X in S'Range loop
			if S(X) = LF or S(X) = CR then
				return S(S'First..X-1);
			end if;
		end loop;
		return S;
	end Strip_NL;



	procedure Replace_String(SP : in out String_Ptr; S : String) is
	begin
		if SP /= null then
			Free(SP);
		end if;
		if S'Length > 1 then
			SP := new String(1..S'Length);
			SP.all := S;
		end if;
	end Replace_String;




	function Value_Of(C_String : Interfaces.C.Strings.chars_ptr) return String is
		use Interfaces.C.Strings, Interfaces.C;
	begin
		return To_Ada(Value(C_String));
	end Value_Of;



	function Is_Null(C_String : Interfaces.C.Strings.chars_ptr) return Boolean is
		use Interfaces.C.Strings;
	begin
		return C_String = Null_Ptr;
   end Is_Null;
   --
    function to_string( val : Unsigned_Integer ) return string
   is
      use ada.Strings.Fixed;
   begin
      return string'(trim(string'(Unsigned_Integer'Image(val)), ada.Strings.Both));
   end to_string;

   function to_string( val : Unsigned_Integer ) return string_ptr
   is
   begin
      return new string'(to_string(val));
   end to_string;
   --
   function to_string( val : Unsigned_Integer_ptr ) return string
   is
      use ada.Strings.Fixed;
   begin
      if val /= null then
	 return string'(trim(string'(Unsigned_Integer'Image(val.all)), ada.Strings.Both));
      end if;
      return "";
   end to_string;

   function to_string( val : Unsigned_Integer_ptr ) return string_ptr
   is
      use ada.Strings.Fixed;
   begin
      return new string'(to_string(val));
   end to_string;
   --
   --
   function to_unsigned_integer( val : string ) return Unsigned_Integer
   is
      use Ada.Strings.Fixed;
      mi_hold : Unsigned_Integer := 0;
   begin
      declare
	    val_hold : string := trim( val, ada.Strings.Both);
      begin
	 mi_hold := Unsigned_Integer'(Unsigned_Integer'value(val_hold));
      exception
	 when others =>
	    mi_hold := 0;
      end;
      return mi_hold;
   end to_unsigned_integer;

   function to_unsigned_integer( val : string ) return Unsigned_Integer_Ptr
   is
   begin
      return new Unsigned_Integer'(to_unsigned_integer(val));
   end to_unsigned_integer;

   function to_unsigned_integer( val : string_ptr ) return Unsigned_Integer
   is
   begin
     if val /= null then
	 return Unsigned_Integer'(to_unsigned_integer(val.all));
      end if;
      return 0;
   end to_unsigned_integer;

   function to_unsigned_integer( val : String_Ptr ) return Unsigned_Integer_Ptr
   is
   begin
      return new Unsigned_Integer'(to_unsigned_integer(val));
   end to_unsigned_integer;

   function is_valid_unsigned( val : string ) return boolean
   is
      use Ada.Strings.Fixed;
      mi_hold : Unsigned_Integer := 0;
      mi_bool : boolean := false;
   begin
      declare
	 val_hold : string := trim( val, ada.Strings.Both);
      begin
	 if val_hold = "" then
	    return false;
	 end if;
	 mi_hold := Unsigned_Integer'(Unsigned_Integer'value(val_hold));
	 mi_bool := true;
      exception
	 when others =>
	    mi_bool := false;
      end;
      return mi_bool;
   end is_valid_unsigned;

   function is_valid_unsigned( val : String_Ptr ) return boolean
   is
   begin
      if val = null then
	 return false;
      end if;
      return boolean'(is_valid_unsigned(val.all));
   end is_valid_unsigned;


end APQ;
