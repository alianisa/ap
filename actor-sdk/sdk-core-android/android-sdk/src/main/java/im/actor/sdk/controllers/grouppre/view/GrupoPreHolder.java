package im.actor.sdk.controllers.grouppre.view;

import android.graphics.Color;

import im.actor.core.entity.GroupPre;
import im.actor.runtime.android.view.BindedViewHolder;
import im.actor.sdk.view.adapters.OnItemClickedListener;
import im.actor.sdk.view.drag.ItemTouchHelperViewHolder;

/**
 * Created by diego on 06/06/17.
 */

public class GrupoPreHolder extends BindedViewHolder implements
        ItemTouchHelperViewHolder {

    private GroupPre bindedItem;
    private GrupoPreView grupoPreView;

    public GrupoPreHolder(final GrupoPreView grupoPreView,
                          final OnItemClickedListener<GroupPre> onClickListener) {
        super(grupoPreView);
        this.grupoPreView = grupoPreView;

        this.grupoPreView.setOnClickListener(v -> {
            if (bindedItem != null) {
                onClickListener.onClicked(bindedItem);
            }
        });

        this.grupoPreView.setOnLongClickListener(v -> {
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
        grupoPreView.setBackgroundColor(Color.LTGRAY);
    }

    @Override
    public void onItemClear() {
        grupoPreView.setBackgroundColor(0);
    }
}
