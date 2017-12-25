/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.runtime.generic.mvvm;

import com.google.j2objc.annotations.ObjectiveCName;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import im.actor.runtime.Log;
import im.actor.runtime.annotations.MainThread;
import im.actor.runtime.bser.BserObject;
import im.actor.runtime.collections.ArrayUtils;
import im.actor.runtime.mvvm.ValueModel;
import im.actor.runtime.storage.ListEngineDisplayExt;
import im.actor.runtime.storage.ListEngineDisplayListener;
import im.actor.runtime.storage.ListEngineItem;

/*-[
#define J2OBJC_DISABLE_ARRAY_BOUND_CHECKS 1
]-*/

public class SimpleBindedDisplayList<T extends BserObject & ListEngineItem>{

    private static final String TAG = "SimpleBindedDisplayList";

    private final ListEngineDisplayExt<T> listEngine;
    private final ListEngineDisplayListener<T> engineListener;
    private Filter<T> filter;
    private List<T> currentList = new ArrayList<>();
    private ValueModel<State> state;

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
                addOrUpdateItens(Arrays.asList(item));
            }

            @Override
            public void addOrUpdate(List<T> items) {
               addOrUpdateItens(items);
            }

            @Override
            public void onItemsReplaced(List<T> items) {
                Log.d(TAG, "onItemsReplaced");
            }

            @Override
            public void onListClear() {
               currentList.clear();
               updateListState();
            }
        };

        this.state = new ValueModel<>("simple_display_list.state", State.LOADING_EMPTY);

        listEngine.subscribe(engineListener);
        listEngine.loadForward(Integer.MAX_VALUE, (items, topSortKey, bottomSortKey) -> addOrUpdateItens(items));
    }


    private void addOrUpdateItens(List<T> values){
        for (T value : values) {
            if(applyFilter(value)){
                this.currentList.add(value);
            }
        }
        updateListState();

    }

    private void updateListState(){
        if(!this.currentList.isEmpty()){
            getState().change(State.LOADED);
        }else{
            getState().change(State.LOADED_EMPTY);
        }
    }

    private boolean applyFilter(T value){
        if(filter != null){
            return filter.accept(value);
        }
        return true;
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

    public ValueModel<State> getState() {
        return state;
    }

    public static interface Filter<T>{
        boolean accept(T value);
    }

    public enum State {
        LOADING_EMPTY, LOADED, LOADED_EMPTY
    }

}