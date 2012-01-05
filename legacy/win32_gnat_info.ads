-- $Id: win32_gnat_info.ads,v 1.2 2003/09/24 15:44:43 wwg Exp $
-- Copyright (c) 2002, Warren W. Gay VE3WWG
--
-- Licensed under the ACL (Ada Community License)
-- or
-- GNU Public License 2 (GPL2)
-- 
--     This program is free software; you can redistribute it and/or modify
--     it under the terms of the GNU General Public License as published by
--     the Free Software Foundation; either version 2 of the License, or
--     (at your option) any later version.
-- 
--     This program is distributed in the hope that it will be useful,
--     but WITHOUT ANY WARRANTY; without even the implied warranty of
--     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--     GNU General Public License for more details.
-- 
--     You should have received a copy of the GNU General Public License
--     along with this program; if not, write to the Free Software
--     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

package Win32_GNAT_Info is

   Failed : Exception;                    -- Operation failed

   function Root return String;                          -- Return Win32 path to root of installed GNAT compiler & tools
   function Version return String;                       -- Return installed GNAT version info (e.g. "3.13p")
   function Win32Ada_Bindings_Directory return String;   -- Return directory name of GNAT's Win32Ada bindings
   function Bindings_Directory return String;            -- Return directory name of bindings
   function Bin return String;                           -- Return the pathname to the GNAT bin directory

   function ADAINCLUDE return String;                    -- Return the path to the ADAINCLUDE directory
   function ADALIB return String;                        -- Return the path to the ADALIB directory

   function ADA_INCLUDE_PATH return String;              -- Return the ADA_INCLUDE_PATH environment string
   function ADA_OBJECTS_PATH return String;              -- Return the ADA_OBJECTS_PATH environment string


   function APQ_Version return String;                   -- APQ version if installed

end Win32_GNAT_Info;
