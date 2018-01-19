//
//  Copyright (c) 2014-2016 Actor LLC. <https://actor.im>
//

import Foundation

public enum AASimpleContentTableStyle {
    case settingsPlain
    case settingsGrouped
    case plain
}

open class AASimpleContentTableController: AAManagedTableController, AAManagedTableControllerDelegate {
    
    fileprivate var isInLoad: Bool = false
    open var autoSections = true
    
    // Controller constructor
    
    public override init(style: AASimpleContentTableStyle) {
        super.init(style: style)
        self.managedTableDelegate = self
        self.autoSections = style != .plain
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // DSL Implementation
    
    open func section(_ closure: (_ s: AASimpleManagedSection) -> ()) -> AASimpleManagedSection {
        if !isInLoad {
            fatalError("Unable to change sections not during tableDidLoad method call")
        }
        
        let isFirst = managedTable.sections.count == 0
        let s = managedTable.addSection(true)
        
        if autoSections {
            s.headerHeight = 15
            s.footerHeight = 15
            if isFirst {
                s.headerHeight = 0
            }
        }
        closure(s)
        return s
    }
    
    open func search<C>(_ cell: C.Type, closure: (_ s: AAManagedSearchConfig<C>) -> ()) where C: AABindedSearchCell, C: UITableViewCell {
        managedTable.search(cell, closure: closure)
    }
    
    open func afterTableCreated() {
        if autoSections {
            managedTable.sections.last?.footerHeight = 30
        }
    }
    
    // Implement it in subclass
    
    open func tableWillLoad() {
        
    }
    
    open func tableDidLoad() {
        
    }
    
    open func tableWillBind(_ binder: AABinder) {
        
    }
    
    open func tableWillUnbind(_ binder: AABinder) {
        
    }
    
    // Delegate implementation
    
    open func managedTableLoad(_ controller: AAManagedTableController, table: AAManagedTable) {
        isInLoad = true
        table.beginUpdates()
        tableDidLoad()
        table.endUpdates()
        afterTableCreated()
        isInLoad = false
    }
    
    open func managedTableBind(_ controller: AAManagedTableController, table: AAManagedTable, binder: AABinder) {
        tableWillBind(binder)
    }
    
    open func managedTableUnbind(_ controller: AAManagedTableController, table: AAManagedTable, binder: AABinder) {
        tableWillUnbind(binder)
    }
    
    open func managedTableWillLoad(_ controller: AAManagedTableController) {
        tableWillLoad()
    }
}

