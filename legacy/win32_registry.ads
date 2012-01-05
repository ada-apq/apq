-- $Id: win32_registry.ads,v 1.1 2003/09/24 14:16:58 wwg Exp $
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

with Win32.WinNT;
with Win32.WinReg;

package Win32_Registry is

   subtype HKEY_Type is Win32.WinReg.HKEY;

   Failed :       Exception;     -- General 'catch all' for errors
   Not_Found :    Exception;     -- Key not found
   Wrong_Type :   Exception;     -- Data type was different than was expected

   HKEY_CLASSES_ROOT :     constant HKEY_Type := Win32.WinReg.HKEY_CLASSES_ROOT;
   HKEY_LOCAL_MACHINE :    constant HKEY_Type := Win32.WinReg.HKEY_LOCAL_MACHINE;

   function Open(hKey : HKEY_Type; Key : String) return HKEY_Type;
   procedure Close(hKey : HKEY_Type);

   function Query(hKey : HKEY_Type; Key : String) return String;

end Win32_Registry;
