/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.runtime.generic.mvvm;

import com.google.j2objc.annotations.ObjectiveCName;

import java.util.ArrayList;
import java.util.List;

import im.actor.runtime.Log;
import im.actor.runtime.annotations.MainThread;
import im.actor.runtime.bser.BserObject;
import im.actor.runtime.storage.ListEngineDisplayExt;
import im.actor.runtime.storage.ListEngineDisplayListener;
import im.actor.runtime.storage.ListEngineDisplayLoadCallback;
import im.actor.runtime.storage.ListEngineItem;

// Disabling Bounds checks for speeding up calculations

/*-[
#define J2OBJC_DISABLE_ARRAY_BOUND_CHECKS 1
]-*/

public class SimpleBindedDisplayList<T extends BserObject & ListEngineItem>{

    private static final String TAG = "SimpleBindedDisplayList";

    private final ListEngineDisplayExt<T> listEngine;
    private final ListEngineDisplayListener<T> engineListener;
    private Filter<T> filter;
    private ListChanged<T> listChanged;
    private List<T> currentList = new ArrayList<>();


    public SimpleBindedDisplayList(ListEngineDisplayExt<T> listEngine,
                                   Filter<T> filter){
        this.filter = filter;
        this.listEngine = listEngine;

        engineListener = new ListEngineDisplayListener<T>() {
            @Override
            public void onItemRemoved(long key) {
                Log.d(TAG, "onItemRemoved");
            }

            @Override
            public void onItemsRemoved(long[] keys) {
                Log.d(TAG, "onItemsRemoved");
            }

            @Override
            public void addOrUpdate(T item) {
                Log.d(TAG, "addOrUpdate");
            }

            @Override
            public void addOrUpdate(List<T> items) {
                Log.d(TAG, "addOrUpdate");
            }

            @Override
            public void onItemsReplaced(List<T> items) {
                Log.d(TAG, "onItemsReplaced");
            }

            @Override
            public void onListClear() {
                Log.d(TAG, "onListClear");
            }
        };
        listEngine.subscribe(engineListener);
        listEngine.loadForward(Integer.MAX_VALUE, (items, topSortKey, bottomSortKey) -> addOrUpdateItens(items));
    }

    private void addOrUpdateItens(List<T> values){
        for (T value : values) {
            if(applyFilter(value)){
                this.currentList.add(value);
            }
        }
        if(listChanged != null){
            listChanged.onListChanged();
        }
    }

    private boolean applyFilter(T value){
        if(filter != null){
            return filter.accept(value);
        }
        return true;
    }

    public void setListChanged(ListChanged<T> listChanged) {
        this.listChanged = listChanged;
    }

    @MainThread
    @ObjectiveCName("dispose")
    public void dispose() {
        im.actor.runtime.Runtime.checkMainThread();
        listEngine.unsubscribe(engineListener);
    }


    @MainThread
    @ObjectiveCName("resume")
    public void resume() {
        im.actor.runtime.Runtime.checkMainThread();
        listEngine.subscribe(engineListener);
    }

    public int getSize(){
        return currentList.size();
    }

    public T getValue(int position){
        return currentList.get(position);
    }

    public static interface Filter<T>{
        boolean accept(T value);
    }

    public static interface ListChanged<T>{
        void onListChanged();
    }



}