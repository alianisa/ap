//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

@objc class CocoaStorageRuntime : NSObject, ARStorageRuntime {
    
    let dbPath: String;
    let preferences = UDPreferencesStorage()
    
    override init() {
        self.dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask, true)[0].asNS.appendingPathComponent("actor.db")
    }
    
    func createPreferencesStorage() -> ARPreferencesStorage! {
        return preferences
    }
    
    func createKeyValue(withName name: String!) -> ARKeyValueStorage! {
        let retorno = FMDBKeyValue(databasePath: dbPath, tableName: name);
        return retorno
    }
    
    func createList(withName name: String!) -> ARListStorage! {
        let retorno = FMDBList(databasePath: dbPath, tableName: name) as ARListStorageDisplayEx
        return retorno;
    }
    
    func resetStorage() {
        preferences.clear()
        
        let db = FMDatabase(path: dbPath)
        db?.open()
        db?.executeStatements("select 'drop table ' || name || ';' from sqlite_master where type = 'table';")
        db?.close()
    }
}
