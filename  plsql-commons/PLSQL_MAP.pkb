CREATE OR REPLACE PACKAGE BODY PLSQL_MAP
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
 *    
 */   
AS 

    function getMapEntryIdx(map StringList, key string) return pls_integer
    is
        idx pls_integer; 
    begin
        if ( map is not null and map.count > 0 )
        then
            idx := map.first;
            while(idx is not null)
            loop
                if mod( idx, 2 ) = 1 and ( ( map(idx) is null and key is null ) or map(idx) = key ) 
                then 
                    return idx;
                end if;
                idx := map.next(idx);
            end loop;
        end if;        
        return null;
    end;   
    
    function  getString(map StringList, key string) return string
    is
        idx pls_integer;
        mapEntryValue plsql_type.string;
    begin
        idx := getMapEntryIdx(map,key);
        if ( idx is not null ) 
        then  
            mapEntryValue := map(idx+1);  
        end if;
        return mapEntryValue;
    end;
    
    procedure setString(map in out nocopy StringList, key string,value string)
    is
        idx pls_integer;
    begin
        idx := getMapEntryIdx(map,key);
        if ( idx is null ) 
        then 
            plsql_util.extend(map,key);
            plsql_util.extend(map,value);
        else 
            map(idx+1) := value; 
        end if;
    end;        
    
    function keySet(map StringList) return StringList
    is
        idx pls_integer; 
        vMapEntryKeys StringList := new StringList(); 
    begin            
        if ( map is null or map.count = 0 ) then return vMapEntryKeys; end if;
        idx := map.first;
        while(idx is not null)
        loop
            if ( mod( idx, 2 ) = 1 ) 
            then 
                plsql_util.extend(vMapEntryKeys,map(idx));
            end if;
            idx := map.next(idx);
        end loop;                
        return vMapEntryKeys;
    end;    
     
    procedure removeMapEntry(map in out nocopy StringList, key string)
    is
        idx pls_integer;
    begin
        idx := getMapEntryIdx(map,key);
        if ( idx is not null ) 
        then
             map.delete(idx);
             map.delete(idx+1);
        end if;
    end;    

    function createHashMap(nrOfBuckets pls_integer default 10) return StringHashMap
    is
        hashMap StringHashMap;
    begin
        hashMap := new StringHashMap();
        hashMap.extend;
        hashMap(hashMap.first) := StringList();
        hashMap.extend(nrOfBuckets-1,hashMap.first);
        return hashMap;
    end;
        
    function hash(key string) return number 
    is 
    begin
        -- To get a hash value on a string where the hash value should be 
        -- between 1000 and 3047, use 1000 as the base value and 2048
        -- as the hash_size value. Using a power of 2 for the hash_size
        -- parameter works best. (2^14 = 1048576)
        return dbms_utility.get_hash_value(key, 0, 1048576); 
    end;
    
    procedure setString(hashmap in out nocopy StringHashMap, key string, value string)
    is
        bucketIdx number := hash(key); 
        keyValues StringList;
    begin
        if ( hashmap is null ) then return; end if;
        bucketIdx := ( bucketIdx mod hashmap.count ) + 1;        
        keyValues := hashmap(bucketIdx);
        setString(keyValues,key,value);
        hashmap(bucketIdx) := keyValues;
    end;
    
    function getString(hashmap StringHashMap,key string) return string
    is
        bucketIdx number := hash(key);
        keyValues StringList;
    begin
        if ( hashmap is null ) then return null; end if;
        bucketIdx := ( bucketIdx mod hashmap.count ) + 1;
        keyValues := hashmap(bucketIdx);
        return getString(keyValues,key);
    end;

    function keySet(hashmap StringHashMap) return StringList
    is
        idx pls_integer;
        vMapEntryKeys StringList := new StringList(); 
    begin            
        if ( hashmap is null or hashmap.count = 0 ) then return vMapEntryKeys; end if;
        idx := hashmap.first;
        while(idx is not null)
        loop
            vMapEntryKeys :=  vMapEntryKeys multiset union distinct keyset(hashmap(idx)); 
            idx := hashmap.next(idx);
        end loop;                
        return vMapEntryKeys;        
    end;
    
    procedure removeMapEntry(hashmap in out nocopy StringHashMap, key string) 
    is
        bucketIdx number;
        keyValues StringList;        
    begin
        if ( hashmap is null ) then return; end if;
        bucketIdx := hash(key);        
        bucketIdx := ( bucketIdx mod hashmap.count ) + 1;
        keyValues := hashmap(bucketIdx);
        removeMapEntry(keyValues,key);
        hashmap(bucketIdx) := keyValues;
    end;
    
end plsql_map;
/