/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.runtime.android.view;

import android.support.v7.widget.RecyclerView;
import android.view.ViewGroup;

import im.actor.runtime.bser.BserObject;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.runtime.storage.ListEngineItem;

public abstract class SimpleBindedListAdapter<V extends BserObject & ListEngineItem,
        T extends RecyclerView.ViewHolder>
        extends RecyclerView.Adapter<T>
        implements SimpleBindedDisplayList.ListChanged<V>{


    private SimpleBindedDisplayList<V> displayList;

    public SimpleBindedListAdapter(SimpleBindedDisplayList<V> displayList) {
        this(displayList, true);
    }

    public SimpleBindedListAdapter(SimpleBindedDisplayList<V> displayList, boolean autoConnect) {
        this.displayList = displayList;
        this.displayList.setListChanged(this);
        setHasStableIds(true);
        if (autoConnect) {
            resume();
        }
    }

    @Override
    public int getItemCount() {
        if (displayList != null) {
            return displayList.getSize();
        }
        return 0;
    }

    protected V getItem(int position) {
        if (displayList != null) {
            return displayList.getValue(position);
        }
        return null;
    }

    @Override
    public long getItemId(int position) {
        return getItem(position).getEngineId();
    }

    @Override
    public abstract T onCreateViewHolder(ViewGroup viewGroup, int viewType);

    @Override
    public final void onBindViewHolder(T dialogHolder, int i) {
        onBindViewHolder(dialogHolder, i, getItem(i));
    }

    @Override
    public void onListChanged(){
        notifyDataSetChanged();
    }

    public abstract void onBindViewHolder(T dialogHolder, int index, V item);


    public void resume() {
        displayList.resume();
        notifyDataSetChanged();
    }

    public void pause() {
        displayList.dispose();
    }

    public void dispose() {
        pause();
    }
}
