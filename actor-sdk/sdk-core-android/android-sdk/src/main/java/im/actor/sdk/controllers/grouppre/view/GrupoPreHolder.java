package im.actor.sdk.controllers.grouppre.view;

import im.actor.core.entity.GroupPre;
import im.actor.runtime.android.view.BindedViewHolder;
import im.actor.sdk.view.drag.ItemTouchHelperViewHolder;
import im.actor.sdk.view.adapters.OnItemClickedListener;

/**
 * Created by diego on 06/06/17.
 */

public class GrupoPreHolder extends BindedViewHolder implements
        ItemTouchHelperViewHolder {

    private GroupPre bindedItem;
    private GrupoPreView grupoPreView;

    public GrupoPreHolder(GrupoPreView grupoPreView, final OnItemClickedListener<GroupPre> onClickListener) {
        super(grupoPreView);
        this.grupoPreView = grupoPreView;

        grupoPreView.setOnClickListener(v -> {
            if (bindedItem != null) {
                onClickListener.onClicked(bindedItem);
            }
        });

        grupoPreView.setOnLongClickListener(v->{
            if (bindedItem != null) {
                return onClickListener.onLongClicked(bindedItem);
            }

            return false;
        });
    }

    public void bind(GroupPre data, boolean isLast) {
        this.bindedItem = data;
        this.grupoPreView.bind(data);
        this.grupoPreView.setDividerVisible(!isLast);
    }

    public void unbind() {
        this.bindedItem = null;
        this.grupoPreView.unbind();
    }

    @Override
    public void onItemSelected() {

    }

    @Override
    public void onItemClear() {

    }
}
