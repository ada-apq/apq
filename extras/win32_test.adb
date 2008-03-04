-- A Very Simple Database Test

----------------------------------
-- UNCOMMENT ONE OF THE FOLLOWING:
-- (Choose one Database product)
----------------------------------
-- with APQ.PostgreSQL.Client; use APQ, APQ.PostgreSQL, APQ.PostgreSQL.Client;
-- with APQ.MySQL.Client; use APQ, APQ.MySQL, APQ.MySQL.Client;

with Ada.Text_IO; use Ada.Text_IO;

procedure Win_Test is
   C : Connection_Type;
   Q : Query_Type;
begin

   Put_Line("Win32_Test Started:");

-- Set_Host_Name(C,"<hostname>"); 		 -- Uncomment+edit if remote database
   Set_User_Password(C,"<userid>","<password>"); -- Edit in userid and password
   Set_DB_Name(C,"<database_name>");             -- Edit in your database name

   -- NO CHANGES REQUIRED BEYOND THIS POINT

   Put_Line("My Userid is '" & User(C) & "'");
   Put_Line("My Password is '" & Password(C) & "'");
   Put_Line("My Database is '" & DB_Name(C) & "'");
   Put_Line("My Host Name is '" & Host_Name(C) & "'");
   Put_Line("My Engine is " & Database_Type'Image(Engine_Of(C)));

   begin
      Put_Line("Connecting..");
      Connect(C);
      Put_Line("Connected!");
      New_Line;
   exception
      when Not_Connected =>
         Put_Line("Error: " & Error_Message(C));
         return;
   end;

   if Engine_Of(C) = Engine_PostgreSQL then
      begin
         Prepare(Q,"DROP SEQUENCE TEST_TBL_ID_SEQ");
         Execute(Q,C);
         Put_Line("Sequence was dropped.");
         New_Line;
      exception
         when SQL_Error =>
            Put_Line("Sequence did not exist: ");
            Put_Line(Error_Message(Q));
            Put_LIne("Error ignored.");
      end;
   end if;

   begin
      Prepare(Q,"DROP TABLE TEST_TBL");
      Put_Line(To_String(Q));
      Execute(Q,C);
      Put_Line("Table was dropped.");
      New_Line;
   exception
      when SQL_Error =>
         Put("Table did not exist: ");
         Put_Line(Error_Message(Q));
         Put_LIne("Error ignored.");
   end;

   Prepare(Q,"CREATE TABLE TEST_TBL (");
   Append_Line(Q,"  NAME   VARCHAR(32) NOT NULL,");
   if Engine_Of(C) = Engine_MySQL then
      Append_Line(Q,"  ID     INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY");
   else
      Append_Line(Q,"  ID     SERIAL");
   end if;
   Append_Line(Q,")");

   Put_Line(To_String(Q));
   Execute_Checked(Q,C);
   Put_Line("Table created.");

   Prepare(Q,"INSERT INTO TEST_TBL ( NAME )");
   Append_Line(Q,"  VALUES( 'ONE' )");
   New_Line;
   Put_Line(To_String(Q));
   Execute_Checked(Q,C);
   Put_Line("OID=" & Row_ID_Type'Image(Command_Oid(Q)));

   Prepare(Q,"INSERT INTO TEST_TBL ( NAME )");
   Append_Line(Q,"  VALUES( 'TWO' )");
   New_Line;
   Put_Line(To_String(Q));
   Execute_Checked(Q,C);
   Put_Line("OID=" & Row_ID_Type'Image(Command_Oid(Q)));

   Prepare(Q,"INSERT INTO TEST_TBL ( NAME )");
   Append_Line(Q,"  VALUES( 'THREE' )");
   New_Line;
   Put_Line(To_String(Q));
   Execute_Checked(Q,C);
   Put_Line("OID=" & Row_ID_Type'Image(Command_Oid(Q)));

   Prepare(Q,"SELECT NAME,ID");
   Append_Line(Q,"FROM TEST_TBL");
   New_Line;
   Put_Line(To_String(Q));
   Execute_Checked(Q,C);
   Put_Line("Got" & Tuple_Count_Type'Image(Tuples(Q)) & " Tuples..");

   begin
     loop
         Fetch(Q);
         Put("NAME='" & Value(Q,1) & "', ");
         Put_Line("ID='" & Value(Q,2) & "'");
      end loop;
   exception
      When No_Tuple =>
         Put_Line("<END>");
   end;

   Disconnect(C);
   Put_Line("Test Completed.");

end Win_Test;
