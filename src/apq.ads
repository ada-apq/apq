------------------------------------------------------------------------------
--                                                                          --
--                          APQ DATABASE BINDINGS                           --
--                                                                          --
--                                  A P Q                                   --
--                                                                          --
--                                 S p e c                                  --
--                                                                          --
--         Copyright (C) 2002-2007, Warren W. Gay VE3WWG                    --
--         Copyright (C) 2007-2009, Ada Works Project                       --
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
--                                                                          --
------------------------------------------------------------------------------



-------------------------------------------------------------------------------
-- This is the base package for APQ.                                         --
-- That's  everything  that  should  be  used when developping in a database --
-- vendor  independent  manner.                                              --
-- It doesn't mean that by only using those methods your code will run at any--
-- backend.  This  only  assures  that your code will be able to be linked   --
-- against  other  drivers,  even  in  runtime  (using  plugins).            --
-------------------------------------------------------------------------------



-- TODO: move all the database dependent code to the database driver!
-- TIP for Time and Date values:
-- 	make the Value() return String abstract in such way that, when it's
-- 	a date value, it should be automatically translated to a standard way
--
-- 	This way should be the ISO way so it's a lot easier to develop.
--
-- 	An equivalent technique should be applied whenever needed.
-- Other approach might be implemeting Value() for each primitive APQ supports.
-- Then the generic methods would use those primitives whever needed.
-- These generic methods would have to be changed in order to receive Class wide objetcs.



with Ada.Calendar;
with Ada.Exceptions;	use Ada.Exceptions;
with Ada.Text_IO;
with Ada.Finalization;
with Ada.Unchecked_Deallocation;
with Ada.Streams;
with Ada.Characters.Latin_1;
with Ada.Strings.Bounded;
with Ada.Strings.Unbounded;	use Ada.Strings.Unbounded;
with Interfaces.C.Strings;
with Interfaces.C_Streams;
with System;

package APQ is


	pragma Linker_Options("-lapq");



	----------------
	-- EXCEPTIONS --
	----------------

	SQL_Error :          exception;     -- SQL Error Occurred
	Use_Error :          exception;     -- USE Database error occurred
	Not_Connected :      exception;     -- Connect failed, or no connection
	Already_Connected :  exception;     -- A connection has already been established
	No_Result :          exception;     -- No result available
	No_Column :          exception;     -- Column does not exist (at index)
	No_Tuple :           exception;     -- No such tuple
	Null_Value :         exception;     -- Attempt to access a null value
	Invalid_Format :     exception;     -- Invalid format or bad data
	Small_Buffer :       exception;     -- Truncation into a small buffer
	Blob_Error :         exception;     -- Operation on blob failed
	Abort_State :        exception;     -- A ROLLBACK operation is required
	Tracing_State :      exception;     -- Already tracing to a file
	Failed :             exception;     -- General operation failed
	Not_Supported :      exception;     -- Feature or attribute is not supported



	type APQ_Error is (
		APQ01,
		APQ02,
		APQ03,
		APQ04,
		APQ05,
		APQ06,
		APQ07,
		APQ08,
		APQ09,
		APQ10,
		APQ11,
		APQ12,
		APQ13,
		APQ14,
		APQ15,
		APQ16,
		APQ17,
		APQ18,
		APQ19,
		APQ20,
		APQ21,
		APQ22,
		APQ23,
		APQ24,
		APQ25,
		APQ26,
		APQ27,
		APQ28);
	-- It's a type used to raise exceptions with messages
	-- Each APQ_Error is linked to an error message that can be retrieved from the
	-- constant array APQ_Error_Descriptions.


	subtype APQ_Error_Description is Unbounded_String;
	-- represents a description message for an APQ error.
	-- This message should follow the pattern:
	-- "some text %0% %1% some other text %2% ...."
	-- Where %i% will be substituted by the 1th element of an pattern array
	-- See To_UString_Array() and Raise_APQ_Exception.

	type APQ_Error_Description_Array is Array(APQ_Error range <>) of APQ_Error_Description;
	-- it's used to map the error codes to messages

	APQ_Error_Descriptions: constant APQ_Error_Description_Array :=
		(
			APQ01 => To_Unbounded_String("Unable to return UNIX socket port as Integer"),
			APQ02 => To_Unbounded_String("Unable to return TCP/IP port # as string"),
			APQ03 => To_Unbounded_String("String '%0%' is not a YYYY-MM-DD format date"),
			APQ04 => To_Unbounded_String("'%0%' is invalid APQ date format"),
			APQ05 => To_Unbounded_String("String '%0%' is an invalid time format"),
			APQ06 => To_Unbounded_String("String '%0%' is an invalid time format"),
			APQ07 => To_Unbounded_String("String '%0%' does not a boolean represent"),
			APQ08 => To_Unbounded_String("Converting Row_ID_Type value for column #%0%"),
			APQ09 => To_Unbounded_String("Buffer is too small to receive column #%0%"),
			APQ10 => To_Unbounded_String("Bad value for boolean in column #%0%"),
			APQ11 => To_Unbounded_String("Bad integer value for column #%0%"),
			APQ12 => To_Unbounded_String("Bad modular value for column #%0%"),
			APQ13 => To_Unbounded_String("Bad float value for column #%0%"),
			APQ14 => To_Unbounded_String("Bad fixed value for column #%0%"),
			APQ15 => To_Unbounded_String(""), -- empty error slot
			APQ16 => To_Unbounded_String("Bad decimal value for column #%0%"),
			APQ17 => To_Unbounded_String("Bad date value for column #%0%"),
			APQ18 => To_Unbounded_String("Bad date value (%0%) for column #%1%"),
			APQ19 => To_Unbounded_String("Bad time value (%0%) for column #%1%"),
			APQ20 => To_Unbounded_String("Bad timestamp format (%0%) for column #%1%"),
			APQ21 => To_Unbounded_String("Bad timezone value for column #%0%"),
			APQ22 => To_Unbounded_String("Bad timezone value for column #%0%"),
			APQ23 => To_Unbounded_String("Bad timezone value for column #%0%"),
			APQ24 => To_Unbounded_String("Receiving string too small for column #%0%"),
			APQ25 => To_Unbounded_String("Receiving string too small for column #%0%"),
			APQ26 => To_Unbounded_String("Receiving bounded string too small for column #%0%"),
			APQ27 => To_Unbounded_String("Receiving bitstring too small for column #%0%"),
			APQ28 => To_Unbounded_String("Cursors are not supported for this database product in the client library")
		);


	type Pattern_Array is Array(Natural range<>) of Unbounded_String;

	function To_Pattern_Array(Zero: in String) return Pattern_Array;
	-- return a Pattern array that maps from 0 to Zero.

	function To_Pattern_Array(Zero, One: in String) return Pattern_Array;
	-- same as the previous, but including both zero and one.
	function To_Pattern_Array(Zero, One, Two: in String) return Pattern_Array;
	-- same as the previous, but including both zero, one and two.

	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String; Zero: in String := "" );
	-- Raise the Exception E with a comprehensive error message
	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String; Zero, One: in String );
	-- Raise the Exception E with a comprehensive error message
	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String; Zero, One, Two: in String );
	-- Raise the Exception E with a comprehensive error message
	procedure Raise_APQ_Error_Exception( E: in Exception_Id;
		Code: in APQ_Error; Where: in String; Patterns: in Pattern_Array );
	-- Raise the Exception E with a comprehensive error message



	--------------------
	-- SQL DATA MODEL --
	--------------------

	-- scalar types
	type APQ_Smallint is range -32768..32767;
	type APQ_Integer is range -2 ** 31 .. 2 ** 31 - 1;
	type APQ_Bigint is range -2 ** 63 .. 2 ** 63 - 1;
	type APQ_Real is digits 6;
	type APQ_Double is digits 15;
	type APQ_Serial is range 1..2147483647;
	type APQ_Bigserial is range 1..9223372036854775807;


	-- time types
	subtype APQ_Date is Ada.Calendar.Time;          -- Date (time ignored)
	subtype APQ_Time is Ada.Calendar.Day_Duration;  -- Time only (date ignored)
	type APQ_Timestamp is new Ada.Calendar.Time;    -- Date and time
	type APQ_Timezone is new Integer range -23..23; -- Timezone in +/- hours from UTC

	type Hour_Number is range 0..23;
	type Minute_Number is range 0..59;
	type Second_Number is range 0..59;


	-- other types..
	subtype APQ_Boolean is Boolean;                 -- Boolean type
	type APQ_Bitstring is array(Positive range <>) of APQ_Boolean;
	pragma pack(APQ_Bitstring);


	--------------
	-- SQL MISC --
	--------------

	type SQL_Case_Type is ( Upper_Case, Lower_Case, Preserve_Case );

	Line_Feed : constant String(1..1) := Ada.Characters.Latin_1.LF & "";
	-- it's a String for a simple reason:
	-- 	it's appended by several functions to the end of a query.
	-- 	an this suffix can be changed by another (bigger) string.
	-- 	this makes things a lot easier

	type SQL_Code_Type is range -2 ** 31 .. 2 ** 31 - 1;


	-------------------------------------
	-- SQL Fetch, Indexing and Tracing --
	-------------------------------------


	-- INDEX:
	type Row_ID_Type is mod 2 ** 64;
	-- Identifies a specific row
	type Tuple_Index_Type is mod 2 ** 64;
	-- Related concept to Row_ID_Type
	First_Tuple_Index : constant Tuple_Index_Type := 1;

	subtype Tuple_Count_Type is Tuple_Index_Type;

	type Column_Index_Type is new Positive;

	-- FETCH:

	type Fetch_Mode_Type is (
		Sequential_Fetch,		-- All databases : sequential fetch mode
		Random_Fetch,			-- PostgreSQL, MySQL, not Sybase
		Cursor_For_Update,		-- Sybase
		Cursor_For_Read_Only		-- Sybase
		);

	type Trace_Mode_Type is (
		Trace_None,			-- No tracing
		Trace_DB,			-- Enable database library tracing
		Trace_APQ,			-- APQ Trace
		Trace_Full			-- Full trace information (Trace_DB and Trace_APQ)
		);



	 type Database_Type is (
		 Engine_PostgreSQL,		-- PostgreSQL database engine is being used
		 Engine_MySQL,			-- MySQL database engine is being used
		 Engine_Sybase,			-- Sybase ASE 12.5x +
		 Engine_CT_Lib,			-- The native, low-level programming interface for
		 				-- the Sybase SQL Server database
		 Engine_ODBC,                   -- ODBC engine (not ready)
		 Engine_Other			-- Other engine, not supported by the APQ team
		 );


	----------------------------------------------------------------------------------
	--				THE MAIN TYPEs					--
	----------------------------------------------------------------------------------
	-- Those types should be extended and have their abstract methods implemented	--
	-- by the new type.                                                           	--
	--										--
	-- Those are the types responsible for interfacing with the database's native	--
	-- connector.									--
	----------------------------------------------------------------------------------

	type Root_Connection_Type is abstract new Ada.Finalization.Limited_Controlled with private;
	type Connection_Ptr is access all Root_Connection_Type'Class;

	type Root_Query_Type is abstract new Ada.Finalization.Controlled with private;
	type Query_Ptr is access all Root_Query_Type'Class;



	----------------------------------------------------------------------------------
	--				ABSTRACT METHOS FOR BOTH			--
	-- 	. Root_Connection_Type and						--
	-- 	. Root_Query_Type							--
	----------------------------------------------------------------------------------
	-- Those are the basic methos do be implemented by the driver implementor.	--
	-- Other methods shall be implemented as well, but these represent the basic set--
	-- of funcionalities required by APQ.						--
	----------------------------------------------------------------------------------


	--------------------------
	-- ROOT_CONNECTION_TYPE --
	--------------------------
	function Engine_Of(C : Root_Connection_Type) return Database_Type is abstract;
	-- Return a identifier for the connection used.


	procedure Connect(C : in out Root_Connection_Type; Check_Connection : Boolean := True) is abstract;
	-- Connect to the Database C.
	-- if Check_Connection = False, then assume it's not connected.
	-- Usefull when Is_Connected has been called before.

	procedure Connect(C : in out Root_Connection_Type; Same_As : Root_Connection_Type'Class) is abstract;
	-- Clone the connection Same_As to C

	procedure Disconnect(C : in out Root_Connection_Type) is abstract;
	-- Close the database connection

	function Is_Connected(C : Root_Connection_Type) return Boolean is abstract;
	-- Checks if the connection is active

	procedure Reset(C : in out Root_Connection_Type) is abstract;
	-- Reset the Connection object, not the connection itself.
	-- It makes possible the reuse of the Root_Connection_Type object in another
	-- connection.
	-- It does not disconnect and then reconnect!


	function Error_Message(C : Root_Connection_Type) return String is abstract;
	-- Return an error message describing why the connection might have failed.
	-- To be used when the No_Connection exception is raised by the Connect predicate


	procedure Open_DB_Trace(C : in out Root_Connection_Type;
		Filename : String; Mode : Trace_Mode_Type := Trace_APQ) is abstract;
	-- Initialize the tracing

	---------------------
	-- ROOT_QUERY_TYPE --
	---------------------
	function Engine_Of(Q : Root_Query_Type) return Database_Type is abstract;
	-- Return an identifier for the database type used.

	procedure Execute(Query : in out Root_Query_Type;
		Connection : in out Root_Connection_Type'Class) is abstract;
	-- Execute the query using the specified connection

	procedure Execute_Checked(Query : in out Root_Query_Type;
		Connection : in out Root_Connection_Type'Class; Msg : String := "") is abstract;
	-- Execute the query using the specified connection, reporting
	-- any error that might occur to the Standard_Error output.
	--
	-- The exception is then re-raised to leave control in the caller's hands.
	--
	-- If the Msg string is specified, a line is printed before
	-- the error message following the pattern:
	-- **** SQL ERROR: [Msg]


	-- Transation Operations --
	--
	--  Use these procedures in favour of using the custom SQL syntax for better portability:
	procedure Begin_Work(Query : in out Root_Query_Type;
		Connection : in out Root_Connection_Type'Class) is abstract;
	procedure Commit_Work(Query : in out Root_Query_Type;
		Connection : in out Root_Connection_Type'Class) is abstract;
	procedure Rollback_Work(Query : in out Root_Query_Type;
		Connection : in out Root_Connection_Type'Class) is abstract;


	procedure Rewind(Q : in out Root_Query_Type) is abstract;
	-- Rewind to the first result when Random_Fetch mode is used.
	-- Raises SQL_Error when not in the right mode.


	procedure Fetch(Q : in out Root_Query_Type) is abstract;
	-- Fetch the next result of the query when in Random_Fetch or Sequential_Fetch mode

	procedure Fetch(Q : in out Root_Query_Type; TX : Tuple_Index_Type) is abstract;
	-- Fetch the TXth result when in the Random_Fetch mode.

	function End_of_Query(Q : Root_Query_Type) return Boolean is abstract;
	-- !!!!DEPRECATED!!!!
	-- Catch the No_Tuple exception instead!
	-- This won't work as expected with MySQL due to a bug in the client library used
	--
	-- Checks if there are more results to be fetched.

	function Tuple(Q : Root_Query_Type) return Tuple_Index_Type is abstract;
	-- return the last tuple fetched

	function Tuples(Q : Root_Query_Type) return Tuple_Count_Type is abstract;
	-- count the tuples returned by the query

	function Columns(Q : Root_Query_Type) return Natural is abstract;
	-- count the columns returned by the query

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return String is abstract;
	-- get a value as an String.

	function Column_Name(Query : Root_Query_Type; Index : Column_Index_Type) return String is abstract;
	-- get the Index'th column name.

	function Column_Index(Query : Root_Query_Type; Name : String) return Column_Index_Type is abstract;
	-- get the index for the column "Name"

	function Result(Query : Root_Query_Type) return Natural is abstract;
	-- get the result code for the query
	-- the meaning of the returned code varies from database product to another.

	function Is_Null(Q : Root_Query_Type; CX : Column_Index_Type) return Boolean is abstract;
	-- checks if the result in the CXth column is null.

	function Command_Oid(Query : Root_Query_Type) return Row_ID_Type is abstract;
	-- After running an INSERT statement, return the Row_ID for the inserted column.
	-- Can raise:
	-- 	No_Result	=> there is no result status (no execution)
	-- 	SQL_Error	=> An SQL error occurred obtaining the OID
	--
	-- Each database product has it's own requirements for this function to work.
	-- For more information reffer to the driver's documentation.

	function Null_Oid(Query : Root_Query_Type) return Row_ID_Type is abstract;
	-- Used to avoid hardcoded numbers.
	-- Return the ID that represents a NULL OID.

	function Error_Message(Query : Root_Query_Type) return String is abstract;
	-- Return an error message when the query has failed.

	function Is_Duplicate_Key(Query : Root_Query_Type) return Boolean is abstract;
	-- When an INSERT statement runs it might have a duplicated key.
	-- When it does, SQL_Error is raised and then the developer might use
	-- Is_Duplicate_Key to check if the error was due the row being duplicated.

	function SQL_Code(Query : Root_Query_Type) return SQL_Code_Type is abstract;
	-- Return a Code, that varies from database product to another, representing
	-- the result status.
	-- Currently, this feature is only avaliable to the Sybase binding.


	function Query_Factory( C: in Root_Connection_Type ) return Root_Query_Type'Class is abstract;
	-- create a query object for the selected connection type.
	-- this is used internally by the New_Query function.
	-- NOTE: DO NOT USE THIS FUNCTION AS IT'S MEANT TO BE USED INTERNALLY ONLY!
	-- NOTE: USE New_Query INSTEAD




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


	function New_Query(C : Root_Connection_Type'Class) return Root_Query_Type'Class;
	-- Use this function to create a new query object for your connection.


	--------------------------
	-- ROOT_CONNECTION_TYPE --
	--------------------------

	function Get_Case(C : Root_Connection_Type) return SQL_Case_Type;
	-- Get the SQL case used by default in this connection.
	-- All new queries will use this casing by default.
	procedure Set_Case(C : in out Root_Connection_Type; SQL_Case : SQL_Case_Type);
	-- Set the SQL case used by default in this connection.
	-- All new queries will use this casing by default.
	pragma Inline(Get_Case,Set_Case);


	function Get_Instance(C: Root_Connection_Type) return String;
	-- Get the instance Name for the Database.
	function Instance(C : Root_Connection_type) return String renames Get_Instance;
	-- Get the instance Name for the Database. It's an alias for Get_Instance
	procedure Set_Instance(C : in out Root_Connection_Type; Instance : String);
	-- Set the instance Name for the Database.

	function Get_Host_Name(C: Root_Connection_Type) return String;
	-- Get the host name for the Database server.
	function Host_Name(C : Root_Connection_Type) return String renames Get_Host_Name;
	-- Get the host name for the Database server. It's an alias for Get_Host_Name
	procedure Set_Host_Name(C : in out Root_Connection_Type; Host_Name : String);
	-- Set the host name for the Database server.

	function Get_Host_Address(C: in Root_Connection_Type) return String;
	-- Set the host address for the database server.
	function Host_Address(C: in Root_Connection_Type) return String renames Get_Host_Address;
	-- Set the host address for the database server. It's an alias for Get_Host_Address
	procedure Set_Host_Address(C : in out Root_Connection_Type; Host_Address : String);
	-- Set the host address for the database server.

	function Get_Port( C: in Root_Connection_Type ) return Integer;
	-- Get the TCP port number.
	function Port(C : Root_Connection_Type) return Integer renames Get_Port;
	-- Get the TCP port number. It's an alias for Get_Port.
	procedure Set_Port(C : in out Root_Connection_Type; Port_Number : Integer);
	-- Set the TCP port number.

	function Get_Port( C: in Root_Connection_Type) return String;
	-- Get the Unix Port.
	function Port(C : Root_Connection_Type) return String renames Get_Port;
	-- Get the Unix Port. It's an alias for Get_Port.
	procedure Set_Port(C : in out Root_Connection_Type; Port_Name : String);
	-- Set the Unix Port

	function Get_DB_Name(C : Root_Connection_Type) return String;
	-- Get the Database name used in this connection.
	function DB_Name(C : Root_Connection_Type) return String renames Get_DB_Name;
	-- Get the Database name used in this connection. It's an alias for Get_DB_Name.
	procedure Set_DB_Name(C : in out Root_Connection_Type; DB_Name : String);
	-- Set the Database name used in this connection.


	function Get_User( C: in Root_Connection_Type ) return String;
	-- Get the Username for this connection.
	function User( C: in Root_Connection_Type ) return String renames Get_User;
	-- Get the Username for this connection. It's ana alias for Get_User
	procedure Set_User( C: in out Root_Connection_Type; User: in String );
	-- Set the Username for this connection.

	function Get_Password( C: Root_Connection_Type ) return String;
	-- Get the Password for this connection.
	function Password(C : Root_Connection_Type) return String renames Get_Password;
	-- Get the Password for this connection. It's an alias for Get_Password
	procedure Set_Password( C: in out Root_Connection_Type; Password: in String );
	-- Get the Password for this connection.

	procedure Set_User_Password(C : in out Root_Connection_Type;
		User_Name, User_Password : String);
	-- Set both the username and the password for this connection.


	function In_Abort_State(C : Root_Connection_Type) return Boolean;
	-- Some database products (eg, PostgreSQL) can enter in a status where
	-- every operation is ignored.
	-- There is the Abort_State Exception for this, but there is also
	-- this function that checks if the connection is in this state.


	function Get_Rollback_On_Finalize( C: in Root_Connection_Type ) return Boolean;
	-- Get if the work will be rollbacked when finalizing.
	function Will_Rollback_On_Finalize(C : Root_Connection_Type)
		return Boolean renames Get_Rollback_On_Finalize;
	-- Get if the work will be rollbacked when finalizing.
	-- It's an alias for Get_Rollback_on_Finalize.
	procedure Set_Rollback_On_Finalize(C : in out Root_Connection_Type;
		Rollback : Boolean);
	-- Set if the work will be rollbacked when finalizing



	procedure Set_Auto_Reconnect( C : in out Root_Connection_Type; Auto_Reconnect : in Boolean := True );
	-- set if it should reconnect automatically when the connection is droped.
	
	function Get_Auto_Reconnect( C : in Root_Connection_Type ) return Boolean;
	-- return true if the connection should be automatically restablished when droped


	---------------------
	-- ROOT_QUERY_TYPE --
	---------------------

	-- Query setup ...

	function Get_Case(Q : Root_Query_Type) return SQL_Case_Type;
	-- Get the case used by this query
	-- This case might be different from the one used by default
	procedure Set_Case(Q : in out Root_Query_Type; SQL_Case : SQL_Case_Type);
	-- Set the case used by this query.

	function Get_Fetch_Mode( Q: in Root_Query_Type ) return Fetch_Mode_Type;
	-- Get the fetch mode used by this query.
	function Fetch_Mode(Q : Root_Query_Type) return Fetch_Mode_Type renames Get_Fetch_Mode;
	-- Get the fetch mode used by this query. It's an alias for Get_Fetch_Mode
	procedure Set_Fetch_Mode(Q : in out Root_Query_Type; Mode : Fetch_Mode_Type);
	-- Set the fetch mode used by this query.

	procedure Raise_Exceptions(Query : in out Root_Query_Type; Raise_On : Boolean := True);
	-- when Execute_Checked is called, should raise the exception back to the caller?
	pragma No_Return (Raise_APQ_Error_Exception);

	procedure Report_Errors(Query : in out Root_Query_Type; Report_On : Boolean := True);
	-- report sql erros when Execute_Checked is called?


	-- Query information ...

	function To_String(Query : Root_Query_Type) return String;
	-- get the query text

	function Is_Select(Q : Root_Query_Type) return Boolean;
	-- is this query a select statement?

	function Cursor_Name(Query : Root_Query_Type) return String;
	-- get the cursor name for the current result
	-- this function is meant to be overwriten by the driver if it supports cursor


	-- SQL creation ...

	procedure Clear(Q : in out Root_Query_Type);
	-- Clear the query so one can start a new SQL expression.

	procedure Grow(Q : in out Root_Query_Type);
	-- used internally to grow the query lines size so one can Append to it.

	procedure Prepare(Q : in out Root_Query_Type; SQL : String; After : String := Line_Feed);
	-- Clear the query, starting a new one.


	procedure Append(Q : in out Root_Query_Type; SQL : String; After : String := "");
	-- Append a string to the query
	procedure Append(Q : in out Root_Query_Type;
		SQL : Ada.Strings.Unbounded.Unbounded_String; After : String := "");
	-- Append an Unbounded_String to the query
	procedure Append_Line(Q : in out Root_Query_Type; SQL : String := "");
	-- Append a String followed by a new line.
	-- If the parameter SQL is omited, there is inserted only a line break

	procedure Append(Q : in out Root_Query_Type; V : APQ_Boolean; After : String := "");
	-- Append a boolean to the query

	procedure Append(Q : in out Root_Query_Type; V : APQ_Date; After : String := "");
	-- Append a date to the query

	procedure Append(Q : in out Root_Query_Type; V : APQ_Time; After : String := "");
	-- Append a time...

	procedure Append(Q : in out Root_Query_Type; V : APQ_Timestamp; After : String := "");
	-- Append a timestamp...
	procedure Append(Q : in out Root_Query_Type;
		TS : APQ_Timestamp; TZ : APQ_Timezone; After : String := "");
	-- Append a timestamp at a timezone...

	procedure Append(Q : in out Root_Query_Type; V : APQ_Bitstring; After : String := "");
	-- Append a bitstring...

	procedure Append(Q : in out Root_Query_Type; V : Row_ID_Type; After : String := "");
	-- Append a row_id_type...

	procedure Append_Quoted(Q : in out Root_Query_Type;
		Connection : Root_Connection_Type'Class; SQL : String; After : String := "");
	-- Append a quoted String.
	-- The case of this String isn't changed.
	-- This primitive should normally be overriden for a specific database.
	-- PostgreSQL and MySQL will potentially have different quoting requirements.

	procedure Append_Quoted(Q : in out Root_Query_Type;
		Connection : Root_Connection_Type'Class;
		SQL : Ada.Strings.Unbounded.Unbounded_String; After : String := "");
	-- Append a quoted Unbouned_String.
	-- The case of this String isn't changed.
	-- This primitive should normally be overriden for a specific database.
	-- PostgreSQL and MySQL will potentially have different quoting requirements.



	-- Data retrieval:


	--Note: there is an abstract function value() which returns string;
	-- This function is used in all these following methods:

	procedure Value(Query: Root_Query_Type; CX : Column_Index_Type; V : out String);
	-- Get the value of the CXth column as String.
	-- Fixed length String Fetch
	function Value(Query : Root_Query_Type; CX : Column_Index_Type)
		return Ada.Strings.Unbounded.Unbounded_String;
	-- Get the value of the CXth column as Unbounded_String.
	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Row_ID_Type;
	-- Get the value of the CXth column as Row_Id_Type.
	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Bitstring;
	-- Get the value of the CXth column as Bitstring.


	--           METHODS THAT SHOULD BE OVERRIDDEN BY THE DATABASE DRIVER           --

	--TODO: change the types to APQ_Something.
	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Boolean;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Integer;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return Float;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Date;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Time;

	function Value(Query : Root_Query_Type; CX : Column_Index_Type) return APQ_Timestamp;

	procedure Value(Query : Root_Query_Type; CX : Column_Index_Type; TS : out APQ_Timestamp; TZ : out APQ_Timezone);




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

	generic
	type Val_Type is new Boolean;
	procedure Append_Boolean(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is range <>;
	procedure Append_Integer(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is mod <>;
	procedure Append_Modular(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is digits <>;
	procedure Append_Float(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is delta <>;
	procedure Append_Fixed(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is delta <> digits <>;
	procedure Append_Decimal(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is new Ada.Calendar.Time;
	procedure Append_Date(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is new Ada.Calendar.Day_Duration;
	procedure Append_Time(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Val_Type is new APQ_Timestamp;
	procedure Append_Timestamp(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	type Date_Type is new Ada.Calendar.Time;
	type Zone_Type is new APQ_Timezone;
	procedure Append_Timezone(Q : in out Root_Query_Type'Class;
		V : Date_Type; Z : Zone_Type; After : String := "");

	generic
	type Val_Type is new APQ_Bitstring;
	procedure Append_Bitstring(Q : in out Root_Query_Type'Class;
		V : Val_Type; After : String := "");

	generic
	with package P is new Ada.Strings.Bounded.Generic_Bounded_Length(<>);
	procedure Append_Bounded(Q : in out Root_Query_Type'Class;
		SQL : P.Bounded_String; After : String := "");

	generic
	with package P is new Ada.Strings.Bounded.Generic_Bounded_Length(<>);
	procedure Append_Bounded_Quoted(Q : in out Root_Query_Type'Class;
		Connection : Root_Connection_Type'Class;
		SQL : P.Bounded_String; After : String := "");


	-- SQL creation :: encode...
	-- encode is the same as append, but supporting null values.


	generic
	type Val_Type is new Boolean;
	type Ind_Type is new Boolean;
	procedure Encode_Boolean(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is range <>;
	type Ind_Type is new Boolean;
	procedure Encode_Integer(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is mod <>;
	type Ind_Type is new Boolean;
	procedure Encode_Modular(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is digits <>;
	type Ind_Type is new Boolean;
	procedure Encode_Float(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is delta <>;
	type Ind_Type is new Boolean;
	procedure Encode_Fixed(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is delta <> digits <>;
	type Ind_Type is new Boolean;
	procedure Encode_Decimal(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is new APQ_Date;
	type Ind_Type is new Boolean;
	procedure Encode_Date(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is new APQ_Time;
	type Ind_Type is new Boolean;
	procedure Encode_Time(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is new APQ_Timestamp;
	type Ind_Type is new Boolean;
	procedure Encode_Timestamp(Q : in out Root_Query_Type'Class;
		V : Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Date_Type is new APQ_Timestamp;
	type Zone_Type is new APQ_Timezone;
	type Ind_Type is new Boolean;
	procedure Encode_Timezone(Q : in out Root_Query_Type'Class;
		D : Date_Type; Z : Zone_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Val_Type is new APQ_Bitstring;
	type Ind_Type is new Boolean;
	procedure Encode_Bitstring(Q : in out Root_Query_Type'Class;
		V: Val_Type; Indicator : Ind_Type; After : String := "");

	generic
	type Ind_Type is new Boolean;
	procedure Encode_String_Quoted(Q : in out Root_Query_Type'Class;
		Connection : Root_Connection_Type'Class;
		SQL : String; Indicator : Ind_Type; After : String := "");

	generic
	type Ind_Type is new Boolean;
	with package P is new Ada.Strings.Bounded.Generic_Bounded_Length(<>);
	procedure Encode_Bounded_Quoted(Q : in out Root_Query_Type'Class;
		Connection : Root_Connection_Type'Class;
		SQL : P.Bounded_String; Indicator : Ind_Type; After : String := "");

	generic
	type Ind_Type is new Boolean;
	procedure Encode_Unbounded(Q : in out Root_Query_Type'Class;
		Connection : Root_Connection_Type'Class;
		SQL : Ada.Strings.Unbounded.Unbounded_String;
		Indicator : Ind_Type; After : String := "");

	generic
	type Ind_Type is new Boolean;
	procedure Encode_Unbounded_Quoted(Q : in out Root_Query_Type'Class;
		Connection : Root_Connection_Type'Class;
		SQL : Ada.Strings.Unbounded.Unbounded_String;
		Indicator : Ind_Type; After : String := "");




	-- Data retrieval :: misc ...



	generic
	type Ind_Type is new Boolean;
	function Column_Is_Null(Q : Root_Query_Type'Class; CX : Column_Index_Type) return Ind_Type;
	-- checks if the result in the CXth column is null.



	-- Data retrieval :: value operations ...
	-- TODO: Remove all these operations and implement value operations instead returning the correct type.


	generic
	type Val_Type is new Boolean;
	function Boolean_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is range <>;
	function Integer_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is mod <>;
	function Modular_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is digits <>;
	function Float_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is delta <>;
	function Fixed_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is delta <> digits <>;
	function Decimal_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is new APQ_Date;
	function Date_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is new APQ_Time;
	function Time_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Val_Type is new Ada.Calendar.Time;
	function Timestamp_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return Val_Type;

	generic
	type Date_Type is new Ada.Calendar.Time;
	type Zone_Type is new APQ_Timezone;
	procedure Timezone_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; TS : out Date_Type; TZ : out Zone_Type);

	generic
	with package P is new Ada.Strings.Bounded.Generic_Bounded_Length(<>);
	function Bounded_Value(Query : Root_Query_Type'Class;
		CX : Column_Index_Type) return P.Bounded_String;



	-- Data retrieval :: fetch operations ...
	-- They are the same as the value operations, but with null support


	generic
	type Val_Type is new Boolean;
	type Ind_Type is new Boolean;
	procedure Boolean_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is range <>;
	type Ind_Type is new Boolean;
	procedure Integer_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is mod <>;
	type Ind_Type is new Boolean;
	procedure Modular_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is digits <>;
	type Ind_Type is new Boolean;
	procedure Float_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is delta <>;
	type Ind_Type is new Boolean;
	procedure Fixed_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is delta <> digits <>;
	type Ind_Type is new Boolean;
	procedure Decimal_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is new Ada.Calendar.Time;
	type Ind_Type is new Boolean;
	procedure Date_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is new Ada.Calendar.Day_Duration;
	type Ind_Type is new Boolean;
	procedure Time_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Val_Type is new Ada.Calendar.Time;
	type Ind_Type is new Boolean;
	procedure Timestamp_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Val_Type; Indicator : out Ind_Type);

	generic
	type Date_Type is new Ada.Calendar.Time;
	type Zone_Type is new APQ_Timezone;
	type Ind_Type is new Boolean;
	procedure Timezone_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Date_Type;
		Z : out Zone_Type; Indicator : out Ind_Type);

	generic
	type Ind_Type is new Boolean;
	procedure Bitstring_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out APQ_Bitstring; Last : out Natural;
		Indicator : out Ind_Type);

	generic
	type Ind is new Boolean;
	with package P is new Ada.Strings.Bounded.Generic_Bounded_Length(<>);
	procedure Bounded_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out P.Bounded_String; Indicator : out Ind);

	generic
	type Ind_Type is new Boolean;
	procedure Unbounded_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out Ada.Strings.Unbounded.Unbounded_String;
		Indicator : out Ind_Type);

	generic
	type Ind_Type is new Boolean;
	procedure Char_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out String; Indicator : out Ind_Type);

	generic
	type Ind_Type is new Boolean;
	procedure Varchar_Fetch(Query : Root_Query_Type'Class;
		CX : Column_Index_Type; V : out String; Last : out Natural;
		Indicator : out Ind_Type);


	-- Conversion :: anything to string (APQ primitives) ...

	function To_String(V : APQ_Boolean) return String;

	function To_String(V : APQ_Date) return String;

	function To_String(V : APQ_Time) return String;

	function To_String(V : APQ_Timestamp) return String;

	function To_String(V : APQ_Timezone) return String;

	function To_String(V : APQ_Timestamp; TZ : APQ_Timezone) return String;

	function To_String(V : APQ_Bitstring) return String;


	-- Conversion :: anything to string (generic for derived types) ...

	generic
	type Val_Type is range <>;
	function Integer_String(V : Val_Type) return String;

	generic
	type Val_Type is mod <>;
	function Modular_String(V : Val_Type) return String;

	generic
	type Val_Type is digits <>;
	function Float_String(V : Val_Type) return String;

	generic
	type Val_Type is delta <>;
	function Fixed_String(V : Val_Type) return String;

	generic
	type Val_Type is delta <> digits <>;
	function Decimal_String(V : Val_Type) return String;

	generic
	type Val_Type is new Ada.Calendar.Time;
	function Date_String(V : Val_Type) return String;

	generic
	type Val_Type is new Ada.Calendar.Day_Duration;
	function Time_String(V : Val_Type) return String;

	generic
	type Val_Type is new Ada.Calendar.Time;
	function Timestamp_String(V : Val_Type) return String;

	generic
	type Val_Type is new APQ_Timezone;
	function Timezone_String(V : Val_Type) return String;



	-- Conversion :: anything from string ...
 	--TODO: These functions may not need to be generic anymore. If so, make
 	--them return the APQ_types.

	generic
	type Val_Type is new Boolean;
	function Convert_To_Boolean(S : String) return Val_Type;

	generic
	type Val_Type is new Ada.Calendar.Time;
	function Convert_To_Date(S : String) return Val_Type;
	-- S must be ISO date format (YYYY-MM-DD - / is valid too) or in YYYYMMDD.
	-- Hour, minutes, ..., are ignored.
	--
	-- There is no check but for constraint error made.

	generic
	type Val_Type is new Ada.Calendar.Day_Duration;
	function Convert_To_Time(S : String) return Val_Type;
	-- S must be HH:MM:SS[.FFF] format

	generic
	type Val_Type is new Ada.Calendar.Time;
	function Convert_To_Timestamp(S : String) return Val_Type;
	-- S must be YYYY-MM-DD HH:MM:SS[.FFF] format

	generic
	type Date_Type is new Ada.Calendar.Time;
	type Time_Type is new Ada.Calendar.Day_Duration;
	type Result_Type is new Ada.Calendar.Time;
	function Convert_Date_and_Time(DT : Date_Type; TM : Time_Type) return Result_Type;


	-- Misc ...


	generic
	type Oid_Type is new Row_ID_Type;
	function Generic_Command_Oid(Query : Root_Query_Type'Class) return Oid_Type;
	-- The Generic_Command_Oid causes GNAT 3.14p to fall over and die.
	--
	-- It isn't really required, since Command_Oid(Query) can be used instead,
	-- and the return value converted to whatever Oid_Type is.

	generic
	type Date_Type is new Ada.Calendar.Time;
	type Zone_Type is new APQ_Timezone;
	procedure Extract_Timezone(S : String; DT : out Date_Type; TZ : out Zone_Type);

	------------------------------
	-- EXTENDED CALENDAR FUNCTIONS :
	------------------------------

	generic
	type Date_Type is new Ada.Calendar.Time;
	type Time_Type is new Ada.Calendar.Day_Duration;
	function Generic_Time_of_Day(V : Date_Type) return Time_Type;

	generic
	type Time_Type is new Ada.Calendar.Day_Duration;
	function Generic_Hour(TM : Time_Type) return Hour_Number;

	generic
	type Time_Type is new Ada.Calendar.Day_Duration;
	function Generic_Minute(TM : Time_Type) return Minute_Number;

	generic
	type Time_Type is new Ada.Calendar.Day_Duration;
	function Generic_Second(TM : Time_Type) return Second_Number;





	procedure Finalize(Q : in out Root_Query_Type) is abstract;
	-- TODO: colocar no seu devido lugar..
private

	package CStr renames Interfaces.C_Streams;

	type String_Ptr is access all String;
	type String_Ptr_Array is array(Natural range <>) of String_Ptr;
	type String_Ptr_Array_Access is access all String_Ptr_Array;
	type Stream_Element_Array_Ptr is access all Ada.Streams.Stream_Element_Array;

	type Boolean_Array is array(Natural range <>) of Boolean;
	type Boolean_Array_Access is access all Boolean_Array;

	subtype Port_Integer is Integer range 0..32768;
	type Port_Format_Type is ( IP_Port, UNIX_Port );


	type Root_Connection_Type is abstract new Ada.Finalization.Limited_Controlled with record
		Instance		: String_Ptr;                      -- Engine instance name
		Host_Name		: String_Ptr;                      -- Host name string or..
		Host_Address		: String_Ptr;                      -- Host IP address
		Port_Format		: Port_Format_Type := UNIX_Port;   -- I/O type
		Port_Number		: Port_Integer := 0;               -- Port number of the database server
		Port_Name		: String_Ptr;                      -- UNIX pathname for UNIX socket
		DB_Name			: String_Ptr;                      -- Database name
		User_Name		: String_Ptr;                      -- The user name
		User_Password		: String_Ptr;                      -- User password (if required)
		Abort_State		: Boolean := False;                -- Transaction abort state
		Rollback_Finalize	: Boolean := True;                 -- Rollback transaction on Finalization
		Trace_Filename		: String_Ptr;                      -- Filename for tracing
		Trace_On		: Boolean := False;                -- True if tracing is enabled
		Trace_Mode		: Trace_Mode_Type := Trace_None;   -- Current Trace mode
		Trace_File		: CStr.FILEs := CStr.Null_Stream;  -- C Stream (FILE *)
		Trace_Ada		: Ada.Text_IO.File_Type;           -- Ada version of Trace_File
		SQL_Case		: SQL_Case_Type := Upper_Case;     -- How to map SQL "case"
		Auto_Reconnect		: Boolean := False;                -- TODO: reconnect when the connection drops
	end record;


	type Root_Query_Type is abstract new Ada.Finalization.Controlled with record
		Count		: Natural := 0;					-- # of elements in the Collection
		Alloc		: Natural := 0;					-- # of allocated elements in the Collection
		Collection	: String_Ptr_Array_Access;			-- Array of strings
		Caseless	: Boolean_Array_Access;				-- True where case is to be preserved
		Raise_Exceptions: Boolean := True;				-- Raise exception in Execute_Checked()
		Report_Errors	: Boolean := True;				-- Report SQL error in Execute_Checked()
		Mode		: Fetch_Mode_Type := Random_Fetch;		-- Random Fetches
		Rewound		: Boolean := True;				-- At first tuple
		Tuple_Index	: Tuple_Index_Type := Tuple_Index_Type'First;	-- Current tuple index
		SQL_Case	: SQL_Case_Type := Upper_Case;			-- How to map SQL "case"
	end record;


	function To_Case(S : String; C : SQL_Case_Type) return String;
	-- convert the string to the selected case


	procedure Clear_Abort_State(C : in out Root_Connection_Type);

	procedure Adjust(Q : in out Root_Query_Type);
	function Is_Insert(Q : Root_Query_Type) return Boolean;
	-- True if query is an INSERT statement
	function Is_Update(Q : Root_Query_Type) return Boolean;
	-- True if query is an UPDATE statement

	procedure Free is new Ada.Unchecked_Deallocation(String,String_Ptr);
	procedure Free is new Ada.Unchecked_Deallocation(
		Interfaces.C.char_array,Interfaces.C.Strings.char_array_access);
	procedure Free is new Ada.Unchecked_Deallocation(String_Ptr_Array,String_Ptr_Array_Access);
	procedure Free is new Ada.Unchecked_Deallocation(Boolean_Array,Boolean_Array_Access);
	procedure Free is new Ada.Unchecked_Deallocation(
		Ada.Streams.Stream_Element_Array,Stream_Element_Array_Ptr);

	procedure Free_Ptr(SP : in out String_Ptr);

	function To_String(S : String_Ptr) return String;
	function To_Ada_String(P : Interfaces.C.Strings.chars_ptr) return String;
	function Blanks_To_Zero(S : String) return String;

	procedure C_String(S : String_Ptr;
		CP : out Interfaces.C.Strings.char_array_access;
		Addr : out System.Address);

	procedure C_String(S : String;
		CP : out Interfaces.C.Strings.char_array_access;
		Addr : out System.Address);

	function Strip_NL(S : String) return String;

	procedure Replace_String(SP : in out String_Ptr; S : String);

	function Value_Of(C_String : Interfaces.C.Strings.chars_ptr) return String;
	function Is_Null(C_String : Interfaces.C.Strings.chars_ptr) return Boolean;

end APQ;
