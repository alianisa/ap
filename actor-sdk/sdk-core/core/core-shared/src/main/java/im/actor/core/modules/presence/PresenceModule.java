/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core.modules.presence;

import im.actor.core.modules.AbsModule;
import im.actor.core.modules.Modules;

import static im.actor.runtime.actors.ActorSystem.system;

public class PresenceModule extends AbsModule {

    public PresenceModule(final Modules modules) {
        super(modules);

        // Creating own presence actor
        system().actorOf("actor/presence/own", () -> new OwnPresenceActor(modules));

        // Creating users and groups presence actor
        PresenceActor.create(modules);
    }
}