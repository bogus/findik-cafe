package com.medratech.findik.domain;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class Options extends Model{
	
    private Boolean openSessionAutomatically = false;
    private String recoverPassword = "findik";
    private byte[] screenSaverImage;
    private byte[] banner;

    public byte[] getBanner() {
        return banner;
    }

    public void setBanner(byte[] banner) {
        this.banner = banner;
    }

    public Boolean getOpenSessionAutomatically() {
        return openSessionAutomatically;
    }

    public void setOpenSessionAutomatically(Boolean openSessionAutomatically) {
        this.openSessionAutomatically = openSessionAutomatically;
    }

    public String getRecoverPassword() {
        return recoverPassword;
    }

    public void setRecoverPassword(String recoverPassword) {
        this.recoverPassword = recoverPassword;
    }

    public byte[] getScreenSaverImage() {
        return screenSaverImage;
    }

    public void setScreenSaverImage(byte[] screenSaverImage) {
        this.screenSaverImage = screenSaverImage;
    }
}
