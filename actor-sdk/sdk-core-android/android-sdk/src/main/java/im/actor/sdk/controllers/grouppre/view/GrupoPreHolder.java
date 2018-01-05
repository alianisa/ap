package im.actor.sdk.controllers.grouppre.view;

import android.graphics.Color;
import android.support.v4.view.MotionEventCompat;
import android.view.MotionEvent;
import android.view.View;

import im.actor.core.entity.GroupPre;
import im.actor.runtime.Log;
import im.actor.runtime.android.view.BindedViewHolder;
import im.actor.sdk.ActorSDK;
import im.actor.sdk.view.drag.ItemTouchHelperViewHolder;
import im.actor.sdk.view.adapters.OnItemClickedListener;
import im.actor.sdk.view.drag.OnStartDragListener;

/**
 * Created by diego on 06/06/17.
 */

public class GrupoPreHolder extends BindedViewHolder implements
        ItemTouchHelperViewHolder {

    private GroupPre bindedItem;
    private GrupoPreView grupoPreView;
    private OnStartDragListener onStartDragListener;

    public GrupoPreHolder(final GrupoPreView grupoPreView,
                          final OnItemClickedListener<GroupPre> onClickListener,
                          final OnStartDragListener onStartDragListener) {
        super(grupoPreView);
        this.grupoPreView = grupoPreView;
        this.onStartDragListener = onStartDragListener;

        if(this.onStartDragListener != null){
            this.grupoPreView.setOnTouchListener((v, event) -> {
                Log.d("GrupoPreHolder","Event: "+event.getAction());

                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    this.onStartDragListener.onStartDrag(this);
                }
                return false;
            });

        }

        this.grupoPreView.setOnClickListener(v -> {
            if (bindedItem != null) {
                onClickListener.onClicked(bindedItem);
            }
        });
        this.grupoPreView.setOnLongClickListener(v->{
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
        if(onStartDragListener != null)
            grupoPreView.setBackgroundColor(Color.LTGRAY);
    }

    @Override
    public void onItemClear() {
        if(onStartDragListener != null)
            grupoPreView.setBackgroundColor(0);
    }
}
