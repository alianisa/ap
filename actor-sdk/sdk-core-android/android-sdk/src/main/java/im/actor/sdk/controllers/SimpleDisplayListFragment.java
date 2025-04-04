package im.actor.sdk.controllers;

import android.app.Activity;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import im.actor.runtime.android.view.SimpleBindedListAdapter;
import im.actor.runtime.bser.BserObject;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.runtime.storage.ListEngineItem;
import im.actor.sdk.R;
import im.actor.sdk.view.adapters.HeaderViewRecyclerAdapter;

/**
 * Created by diego on 20/12/2017.
 */

public abstract class SimpleDisplayListFragment<T extends BserObject & ListEngineItem,
        V extends RecyclerView.ViewHolder> extends BaseFragment {

    private RecyclerView collection;
    private SimpleBindedDisplayList<T> displayList;
    private SimpleBindedListAdapter<T, V> adapter;

    protected View inflate(LayoutInflater inflater, ViewGroup container, int resource, SimpleBindedDisplayList<T> displayList) {
        View res = inflater.inflate(resource, container, false);
        afterViewInflate(res, displayList);
        return res;
    }

    protected void afterViewInflate(View view, SimpleBindedDisplayList<T> displayList) {
        collection = (RecyclerView) view.findViewById(R.id.collection);
        setAnimationsEnabled(true);
        this.displayList = displayList;
        configureRecyclerView(collection);
        adapter = onCreateAdapter(displayList, getActivity());
        collection.setAdapter(adapter);
        afterAdapterCreated();
    }

    protected void afterAdapterCreated() {
    }

    public void setAnimationsEnabled(boolean isEnabled) {
        if (isEnabled) {
            DefaultItemAnimator itemAnimator = new DefaultItemAnimator();
            itemAnimator.setSupportsChangeAnimations(false);
            itemAnimator.setMoveDuration(200);
            itemAnimator.setAddDuration(150);
            itemAnimator.setRemoveDuration(200);
            collection.setItemAnimator(itemAnimator);
        } else {
            collection.setItemAnimator(null);
        }
    }

    protected void configureRecyclerView(RecyclerView recyclerView) {
        recyclerView.setHasFixedSize(true);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(getActivity());
        linearLayoutManager.setRecycleChildrenOnDetach(false);
        linearLayoutManager.setSmoothScrollbarEnabled(false);
        recyclerView.setLayoutManager(linearLayoutManager);
        recyclerView.setHorizontalScrollBarEnabled(false);
        recyclerView.setVerticalScrollBarEnabled(true);
    }

    protected void addHeaderView(View header) {
        if (collection.getAdapter() instanceof HeaderViewRecyclerAdapter) {
            HeaderViewRecyclerAdapter h = (HeaderViewRecyclerAdapter) collection.getAdapter();
            h.addHeaderView(header);
        } else {
            HeaderViewRecyclerAdapter headerViewRecyclerAdapter = new HeaderViewRecyclerAdapter(adapter);
            headerViewRecyclerAdapter.addHeaderView(header);
            collection.setAdapter(headerViewRecyclerAdapter);
        }
    }

    protected void addFooterView(View header) {
        if (collection.getAdapter() instanceof HeaderViewRecyclerAdapter) {
            HeaderViewRecyclerAdapter h = (HeaderViewRecyclerAdapter) collection.getAdapter();
            h.addFooterView(header);
        } else {
            HeaderViewRecyclerAdapter headerViewRecyclerAdapter = new HeaderViewRecyclerAdapter(adapter);
            headerViewRecyclerAdapter.addFooterView(header);
            collection.setAdapter(headerViewRecyclerAdapter);
        }
    }

    protected abstract SimpleBindedListAdapter<T, V> onCreateAdapter(SimpleBindedDisplayList<T> displayList, Activity activity);

    protected void onListStateChange(SimpleBindedDisplayList.State state) {
        if (state == SimpleBindedDisplayList.State.LOADED) {
            getCollection().setVisibility(View.VISIBLE);
        } else {
            getCollection().setVisibility(View.GONE);
        }
    }

    public SimpleBindedListAdapter<T, V> getAdapter() {
        return adapter;
    }

    public SimpleBindedDisplayList<T> getDisplayList() {
        return displayList;
    }

    public RecyclerView getCollection() {
        return collection;
    }

    @Override
    public void onResume() {
        super.onResume();
        adapter.resume();
        setUnbindOnPause(true);

        bind(displayList.getState(), val -> {
            onListStateChange(val);
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        adapter.pause();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (adapter != null) {
            adapter.dispose();
        }
        collection = null;
    }
}
