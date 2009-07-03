------------------------------------------------------------------------------
--                                                                          --
--                          APQ DATABASE BINDINGS                           --
--                                                                          --
--                                  A P Q                                   --
--                                                                          --
--                                 B o d y                                  --
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



with Ada.Text_IO;	use Ada.Text_IO;


package body APQ.Samples is


	procedure Query_Results( C: in out Root_Connection_Type'Class ) is
		Q: Root_Query_Type'Class := New_Query( C );


		function Value( S: in String ) return String is
		begin
			return Value( Q, Column_Index( Q, S ) );
		end Value;
	begin
		Prepare( Q, "SELECT * FROM USERS" );

		Execute( Q, C );

		loop
			begin
				Fetch( Q );
			exception
				when No_Tuple => exit;
			end;

			Put( "Name: " & Value( "Name" ) );
			Put( "   |   " );
			Put( "Birth date: " & Value( "Birth" ) );

			New_Line;
		end loop;
	end Query_Results;



	procedure Insert_Value( C: in out Root_Connection_Type'Class; Name: in String; Birth: in APQ_Date ) is
		Q: Root_Query_Type'Class := New_Query( C );	
	begin
		Prepare( Q, "INSERT INTO USERS(Name, Birth) VALUES(" );
		Append_Quoted( Q, C, Name, "," );
		Append( Q, Birth, ")" );

		Execute( Q, C );

	end Insert_Value;

end APQ.Samples;
