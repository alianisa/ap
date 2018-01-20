package im.actor.sdk.controllers.grouppre.view;

import android.content.Context;
import android.view.ViewGroup;

import im.actor.core.entity.GroupPre;
import im.actor.runtime.android.view.SimpleBindedListAdapter;
import im.actor.runtime.generic.mvvm.SimpleBindedDisplayList;
import im.actor.sdk.util.ActorSDKMessenger;
import im.actor.sdk.view.adapters.OnItemClickedListener;
import im.actor.sdk.view.drag.ItemTouchHelperAdapter;

public class GrupoPreSimpleAdapter extends SimpleBindedListAdapter<GroupPre, GrupoPreHolder>
        implements ItemTouchHelperAdapter {

    private OnItemClickedListener<GroupPre> onItemClicked;
    private Context context;

    private GroupPre dragFrom = null;
    private GroupPre dragTo = null;

    public GrupoPreSimpleAdapter(SimpleBindedDisplayList<GroupPre> displayList,
                                 OnItemClickedListener<GroupPre> onItemClicked,
                                 Context context) {
        super(displayList);
        this.context = context;
        this.onItemClicked = onItemClicked;
    }

    @Override
    public GrupoPreHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        return new GrupoPreHolder(new GrupoPreView(context), onItemClicked);
    }

    @Override
    public void onBindViewHolder(GrupoPreHolder dialogHolder, int index, GroupPre item) {
        dialogHolder.bind(item, index == (getItemCount() - 1));
    }

    @Override
    public void onViewRecycled(GrupoPreHolder holder) {
        holder.unbind();
    }

    @Override
    public boolean onItemMove(int fromPosition, int toPosition) {

        fromPosition--;
        toPosition--;

        if (dragFrom == null) {
            dragFrom = getItem(fromPosition);
        }
        dragTo = getItem(toPosition);

        getDisplayList().itensMoved(fromPosition, toPosition);
        notifyItemMoved(fromPosition, toPosition);
        return true;
    }

    @Override
    public void onItemDismiss(int position) {
    }

    @Override
    public void onClear() {
        if (dragFrom != null && dragTo != null && dragFrom.getEngineId() != dragTo.getEngineId()) {
            ActorSDKMessenger.messenger().changeGroupPreOrder(dragFrom, dragTo);
        }
        dragFrom = dragTo = null;
    }
}
