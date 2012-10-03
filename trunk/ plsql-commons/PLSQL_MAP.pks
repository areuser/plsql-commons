CREATE OR REPLACE PACKAGE PLSQL_MAP 
/**
 * Copyright (c) 2008-2011, The PLSQL Commons team ( http://code.google.com/p/plsql-commons/)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *   
 * Authors     : arnold@reuser.info and dimtri.lambrou@gmail.com
 * Description : Handling a map structure with focus on performance
 *               Both key and value are of type string
 * Since       : 1.0
 *    
 */ 
AS 

  function createHashMap(nrOfBuckets pls_integer default 10) return StringHashMap;
  function getString(hashmap StringHashMap,key string) return string;
  procedure setString(hashmap in out nocopy StringHashMap, key string, value string);
  function keySet(hashmap StringHashMap) return StringList;
  procedure removeMapEntry(hashmap in out nocopy StringHashMap, key string);
  
  function getString(map StringList, key string) return string;
  procedure setString(map in out nocopy StringList, key string,value string);
  function keySet(map StringList) return StringList;
  procedure removeMapEntry(map in out nocopy StringList, key string);

end PLSQL_MAP;
/
