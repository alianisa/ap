package im.actor.core.modules.calls;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import im.actor.core.api.*;
import im.actor.core.entity.Peer;
import im.actor.core.modules.ModuleContext;
import im.actor.core.viewmodel.CallMember;
import im.actor.core.viewmodel.CallMemberState;
import im.actor.core.viewmodel.CallState;
import im.actor.core.viewmodel.CallVM;
import im.actor.runtime.Log;

public class CallViewModels {

    private final HashMap<Long, CallVM> callModels;
    private final ModuleContext context;

//    ArrayList<CallMember> members = new ArrayList<>();
//CallMember members;

    public CallViewModels(ModuleContext context) {
        this.context = context;
        this.callModels = new HashMap<>();
    }

    public synchronized CallVM getCall(long id) {
        return callModels.get(id);
    }

    public synchronized CallVM spawnNewVM(long callId, Peer peer, boolean isOutgoing,
                                          boolean isVideoEnabled, boolean isVideoPreffered, boolean isDeviceConnected,
                                          ArrayList<CallMember> members, CallState callState) {
        CallVM callVM = new CallVM(callId, peer, isOutgoing, isVideoEnabled, isVideoPreffered,
                members, callState);
        synchronized (callModels) {
            callModels.put(callId, callVM);
        }

//        members.get(peer.getPeerId());

//        if (context.getSettingsModule().isBusy()) {
//            callVM.getState().change(CallState.BUSY);
//        }


        return callVM;
    }

    public synchronized CallVM spawnNewIncomingVM(long callId, Peer peer, boolean isVideoEnabled,
                                                  boolean isVideoPreffered, boolean isDeviceConnected, CallState callState, ArrayList<CallMember> members) {
        CallVM callVM = new CallVM(callId, peer, false, isVideoEnabled, isVideoPreffered,
                members, callState);

        synchronized (callModels) {
            callModels.put(callId, callVM);
        }
        return callVM;
    }

    public synchronized CallVM spawnNewOutgoingVM(long callId, Peer peer, boolean isVideoEnabled,
                                                  boolean isVideoPreferred, boolean isDeviceConnected, CallState callState) {

//        ArrayList<CallMember> members = new ArrayList<>();
//        if (peer.getPeerType() == PeerType.PRIVATE ||
//                peer.getPeerType() == PeerType.PRIVATE_ENCRYPTED) {
//            members.add(new CallMember(peer.getPeerId(), CallMemberState.RINGING));
//        } else if (peer.getPeerType() == PeerType.GROUP) {
//            Group g = context.getGroupsModule().getGroups().getValue(peer.getPeerId());
//            for (GroupMember gm : g.getMembers()) {
//                if (gm.getUid() != context.getAuthModule().myUid()) {
//                    members.add(new CallMember(gm.getUid(), CallMemberState.RINGING));
//                }
//            }
//        }


//        CallState callState = CallState.RINGING;

//        if (isDeviceConnected) {
//            callState = CallState.RINGING_REACHED;
//        } else {
//            callState = CallState.RINGING;
//        }

//        ApiCallMemberState apiCallMemberState = ApiCallMemberState.RINGING;
//
//        ApiCallMemberStateHolder apiCallMemberStateHolder = new ApiCallMemberStateHolder(apiCallMemberState, false, true, false, false, false);

//                buildApiCallMember(peer, apiCallMemberStateHolder);



//        ArrayList<ApiCallMember>  members = new ArrayList<>();
//        members.add(members);

//        ArrayList<ApiCallMember> apiCallMember = new ArrayList<>();
//        apiCallMember.add(new ApiCallMember(peer.getPeerId(), apiCallMemberStateHolder));
//
//        ApiPeer apiPeer = new ApiPeer(ApiPeerType.PRIVATE, peer.getPeerId());
//
//        List<ApiActiveCall> apiActiveCallArray = new ArrayList<>();
//        apiActiveCallArray.add(new ApiActiveCall(callId, apiPeer, apiCallMember));

//                ApiCallMember apiCallMember = new ApiCallMember(peer.getPeerId(), apiCallMemberStateHolder);
    ArrayList<CallMember> members = new ArrayList<>();
//    members.add(new CallMember(peer.getPeerId(), CallMemberState.RINGING));

//        Log.d("CallActor", " Members Out - " + members.toString());

        return spawnNewVM(callId, peer, true, isVideoEnabled, isVideoPreferred, isDeviceConnected, members,
                callState);
    }
}
