package com.medratech.findik.domain;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Lob;

@Entity
public class Options extends Model{
	
    private Boolean openSessionAutomatically = false;
    private String recoverPassword = "findik";
    @Lob @Basic(fetch=FetchType.EAGER)
    @Column(columnDefinition="LONGBLOB NULL")
    private byte[] screenSaverImage;
    @Lob @Basic(fetch=FetchType.EAGER)
    @Column(columnDefinition="LONGBLOB NULL")
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
