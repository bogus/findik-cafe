package com.medratech.findik.domain;

import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;

@Entity
public class SessionData extends Model {
	
    private long eventStartTime;
    private long eventEndTime;
    private String eventData;
    private long cafeItemId;

    public String getEventData() {
        return eventData;
    }

    public void setEventData(String eventData) {
        this.eventData = eventData;
    }

    public long getEventEndTime() {
        return eventEndTime;
    }

    public void setEventEndTime(long eventEndTime) {
        this.eventEndTime = eventEndTime;
    }

    public long getEventStartTime() {
        return eventStartTime;
    }

    public void setEventStartTime(long eventStartTime) {
        this.eventStartTime = eventStartTime;
    }

    public long getCafeItemId() {
        return cafeItemId;
    }

    public void setCafeItemId(long cafeItemId) {
        this.cafeItemId = cafeItemId;
    }

    
}
