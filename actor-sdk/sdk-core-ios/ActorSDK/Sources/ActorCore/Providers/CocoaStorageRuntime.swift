//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

@objc class CocoaStorageRuntime : NSObject, ARStorageRuntime {
    
    var dbPath: String;
    let preferences = UDPreferencesStorage()
    let queryCreate: String
    let tableName = "test"
    
    override init() {
        self.dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
            .userDomainMask, true)[0].asNS.appendingPathComponent("actor.db")
        self.queryCreate = "CREATE TABLE IF NOT EXISTS " + tableName + " (" +
            "\"ID\" INTEGER NOT NULL, " +
            "\"BYTES\" BLOB NOT NULL, " +
        "PRIMARY KEY (\"ID\"));"
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
//        self.dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                          .userDomainMask, true)[0].asNS.appendingPathComponent("actor.db")
//        let db = FMDatabase(path: dbPath)
//        db.open()
//        db.executeStatements("select 'drop table ' || name || ';' from sqlite_master where type = 'table';")
//        db?.executeStatements("SELECT 'DELETE FROM ' || sqlite_master.name || ' WHERE name is NULL;' FROM sqlite_master WHERE type = 'table' AND sqlite_master.name NOT LIKE 'sqlite_%';")
//        db.close()
        
        let dbPath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].asNS.appendingPathComponent("actor.db")
        let db = FMDatabase(path: dbPath)
        db.open()
        let rs:FMResultSet = (db.executeQuery("select 'drop table ' || name || ';' as yj from sqlite_master where type = 'table';"))!
        var dropTable:String = ""
        while rs.next() {
            let drop:String = rs.string(forColumn: "yj")!
            dropTable = dropTable + drop
        }
        print("drop"+dropTable+"======")
        db.executeStatements(dropTable)
        db.close()
    }
    
    func deleteStorage() {
//        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
//        let destinationPath = documentsPath.appendingPathComponent("Filename.jpg")
//        try! filemanager.removeItem(atPath: dbPath)
//
        let fileManager = FileManager.default
//
//        guard let tempFolderPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString else {
//            return   // documents directory not found for some reason
//        }
        
//        do {
//            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
//            for filePath in filePaths {
//                try fileManager.removeItem(atPath: tempFolderPath + filePath)
        
//        self.dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                          .userDomainMask, true)[0].asNS.appendingPathComponent("actor.db")
        try! fileManager.removeItem(atPath: dbPath)
        
        let db = FMDatabase(path: dbPath)
        
//        FMDBKeyValue.init(databasePath: dbPath, tableName: "test")
        db.open()
        if (!db.tableExists(tableName)) {
            _ = db.executeUpdate(queryCreate)
        }
////        let data = db.executeStatements("select 'drop table ' || name || ';' from sqlite_master where type = 'table';")
//        db.executeStatements("delete from sqlite_master where type in ('table', 'index', 'trigger');")
////        log("Datavase Data: \(data)")
//        db.close()
        
//        let sqlDropTable = "DROP TABLE \(name)"
//        let dropStatus = db.executeStatements(sqlDropTable)
//        return dropStatus
        
//        createKeyValue(withName: "table")
//            }
//        } catch {
//            print("Could not clear temp folder: \(error)")
//        }
        
//        ActorSDK.sharedActor().presentMessengerInNewWindow()

    }
}
