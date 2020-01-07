/*
 * Copyright (C) 2015 Actor LLC. <https://actor.im>
 */

package im.actor.core;

import com.google.j2objc.annotations.ObjectiveCName;

/**
 * API Configuration for accessing Actor Platform servers
 */
public class ApiConfiguration {

    private final String appTitle;

    private final int appId;
    private final String appKey;

    private final String deviceTitle;
    private final String deviceIpAddress;
    private final String deviceLocation;
    private final String deviceOS;
    private final String deviceString;

    /**
     * Construct API Configuration
     *
     * @param appTitle     title of application
     * @param appId        app id for API
     * @param appKey       app key for API
     * @param deviceTitle  device title
     * @param deviceIpAddress  device ip address
     * @param deviceLocation  device location
     * @param deviceOS  device OS
     * @param deviceString device unique key
     */
    @ObjectiveCName("initWithAppTitle:withAppId:withAppKey:withDeviceTitle:withDeviceIpAddress:withDeviceLocation:withDeviceOS:withDeviceId:")
    public ApiConfiguration(String appTitle, int appId, String appKey, String deviceTitle, String deviceIpAddress, String deviceLocation, String deviceOS, String deviceString) {
        this.appTitle = appTitle;
        this.appId = appId;
        this.appKey = appKey;
        this.deviceTitle = deviceTitle;
        this.deviceIpAddress = deviceIpAddress;
        this.deviceLocation = deviceLocation;
        this.deviceOS = deviceOS;
        this.deviceString = deviceString;
    }

    /**
     * Get App Title
     *
     * @return the App Title
     */
    @ObjectiveCName("getAppTitle")
    public String getAppTitle() {
        return appTitle;
    }

    /**
     * Get App API Id
     *
     * @return the App Id
     */
    @ObjectiveCName("getAppId")
    public int getAppId() {
        return appId;
    }

    /**
     * Get App API Key
     *
     * @return the App Key
     */
    @ObjectiveCName("getAppKey")
    public String getAppKey() {
        return appKey;
    }

    /**
     * Get Device Title
     *
     * @return the Device Title
     */
    @ObjectiveCName("getDeviceTitle")
    public String getDeviceTitle() {
        return deviceTitle;
    }

    /**
     * Get Device Ip Address
     *
     * @return the Device Ip Address
     */
    @ObjectiveCName("getDeviceIpAddress")
    public String getDeviceIpAddress() {
        return deviceIpAddress;
    }

    /**
     * Get Device Location
     *
     * @return the Device Location
     */
    @ObjectiveCName("getDeviceLocation")
    public String getDeviceLocation() {
        return deviceLocation;
    }

    /**
     * Get Device OS
     *
     * @return the Device OS
     */
    @ObjectiveCName("getDeviceOS")
    public String getDeviceOS() {
        return deviceOS;
    }

    /**
     * Get Device unique string
     *
     * @return the Unique String
     */
    @ObjectiveCName("getDeviceString")
    public String getDeviceString() {
        return deviceString;
    }
}
