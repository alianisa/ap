/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.runtime.generic.mvvm;

import com.google.j2objc.annotations.ObjectiveCName;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import im.actor.runtime.Runtime;
import im.actor.runtime.annotations.MainThread;
import im.actor.runtime.bser.BserObject;
import im.actor.runtime.function.Tuple2;
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
    private ListChangedListener listChangeListener;
    private List<T> currentList = new ArrayList<>();
    private ValueModel<State> state;

    public SimpleBindedDisplayList(ListEngineDisplayExt<T> listEngine,
                                   Filter<T> filter){
        this.filter = filter;
        this.listEngine = listEngine;

        engineListener = new ListEngineDisplayListener<T>() {
            @Override
            public void onItemRemoved(long key) {
                itensRemoved(new long[]{key});
            }

            @Override
            public void onItemsRemoved(long[] keys) {
                itensRemoved(keys);
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
               itensReplaced(items);
            }

            @Override
            public void onListClear() {
               currentList.clear();
               updateListState();
            }
        };

        this.state = new ValueModel<>("simple_display_list.state", State.LOADING_EMPTY);
        listEngine.subscribe(engineListener);

        Runtime.dispatch(()->{
            listEngine.loadForward(Integer.MAX_VALUE, (items, topSortKey, bottomSortKey) -> addOrUpdateItens(items));
        });
    }


    private void addOrUpdateItens(List<T> values){
        for (T value : values) {
            if(applyFilter(value)){
                int position = findPositionById(value.getEngineId());
                if(position >= 0){
                    this.currentList.set(position, value);
                }else{
                    this.currentList.add(value);
                }
            }
        }
        updateListState();
    }

    private void itensRemoved(long[] keys){
        for (long value : keys) {
            int removedPos = findPositionById(value);
            if(removedPos >= 0)
                this.currentList.remove(removedPos);
        }
        updateListState();
    }

    private void itensReplaced(List<T> items){
        List<Tuple2<Integer, T>> valuesReplaced = new ArrayList<>();
        for(T vr : items){
            int posReplaced = findPositionById(vr.getEngineId());
            if(posReplaced > 0){
                valuesReplaced.add(new Tuple2<>(posReplaced, vr));
            }
        }
        for(Tuple2<Integer, T> tuple : valuesReplaced){
            currentList.set(tuple.getT1(), tuple.getT2());
        }
        updateListState();
    }

    public int findPositionById(long key){
        for(int i =0; i < currentList.size(); i++){
            T currentVal = currentList.get(i);
            if(currentVal.getEngineId() == key){
                return i;
            }
        }
        return -1;
    }


    private void updateListState(){
        if(!this.currentList.isEmpty()){
            getState().change(State.LOADED);
        }else{
            getState().change(State.LOADED_EMPTY);
        }
        notifyListChanged();
    }

    private void notifyListChanged(){
        if(listChangeListener != null){
            listChangeListener.onListChange(currentList.size());
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

    public void setListChangeListener(ListChangedListener listChangeListener) {
        this.listChangeListener = listChangeListener;
    }

    public static interface Filter<T>{
        boolean accept(T value);
    }

    public static interface ListChangedListener{
        void onListChange(int size);
    }

    public enum State {
        LOADING_EMPTY, LOADED, LOADED_EMPTY
    }

}