package im.actor.sdk.controllers.dialogs.view;

import android.content.Context;
import android.view.ViewGroup;

import im.actor.core.entity.Dialog;
import im.actor.runtime.android.view.BindedListAdapter;
import im.actor.runtime.generic.mvvm.BindedDisplayList;
import im.actor.sdk.view.adapters.OnItemClickedListener;

public class DialogsAdapter extends BindedListAdapter<Dialog, DialogHolder> {

    private OnItemClickedListener<Dialog> onItemClicked;
    private Context context;

    public DialogsAdapter(BindedDisplayList<Dialog> displayList, OnItemClickedListener<Dialog> onItemClicked,
                          Context context) {
        super(displayList);
        this.context = context;
        this.onItemClicked = onItemClicked;
    }

    @Override
    public DialogHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        return new DialogHolder(new DialogView(context), onItemClicked);
    }

    @Override
    public void onBindViewHolder(DialogHolder dialogHolder, int index, Dialog item) {
        dialogHolder.bind(item, index == getItemCount() - 1);
    }

    @Override
    public void onViewRecycled(DialogHolder holder) {
        holder.unbind();
    }
}
