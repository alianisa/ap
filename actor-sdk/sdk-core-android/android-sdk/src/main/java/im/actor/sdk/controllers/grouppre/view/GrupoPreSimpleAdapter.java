package im.actor.sdk.controllers.grouppre.view;

import android.content.Context;
import android.view.ViewGroup;

import im.actor.core.entity.GroupPre;
import im.actor.runtime.android.view.SimpleBindedListAdapter;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.sdk.view.adapters.OnItemClickedListener;
import im.actor.sdk.view.drag.OnStartDragListener;

public class GrupoPreSimpleAdapter extends SimpleBindedListAdapter<GroupPre, GrupoPreHolder>{

    private OnItemClickedListener<GroupPre> onItemClicked;
    private OnStartDragListener onStartDragListener;
    private Context context;

    public GrupoPreSimpleAdapter(SimpleBindedDisplayList<GroupPre> displayList,
                                 OnItemClickedListener<GroupPre> onItemClicked,
                                 OnStartDragListener onStartDragListener,
                                 Context context) {
        super(displayList);
        this.context = context;
        this.onItemClicked = onItemClicked;
        this.onStartDragListener = onStartDragListener;
    }

    @Override
    public GrupoPreHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        return new GrupoPreHolder(new GrupoPreView(context), onItemClicked, onStartDragListener);
    }

    @Override
    public void onBindViewHolder(GrupoPreHolder dialogHolder, int index, GroupPre item) {
        dialogHolder.bind(item, index == (getItemCount() - 1));
    }

    @Override
    public void onViewRecycled(GrupoPreHolder holder) {
        holder.unbind();
    }
}
