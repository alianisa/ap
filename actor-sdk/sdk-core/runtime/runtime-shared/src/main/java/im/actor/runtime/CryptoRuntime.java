/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.runtime;

import im.actor.runtime.crypto.BlockCipher;
import im.actor.runtime.crypto.Digest;

/**
 * Provider for Cryptography support
 */
public interface CryptoRuntime {

    Digest SHA256();

    BlockCipher AES128(byte[] key);

    void waitForCryptoLoaded();
}