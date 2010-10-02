package com.medratech.findik.domain;

import java.util.Date;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OneToOne;
import javax.persistence.Temporal;

@Entity
public class CafeItem extends Model{

    private String name;
    private int type;
    private String generatedId;
    private String IP;
    private String hostname;
    @ManyToOne(cascade=CascadeType.ALL, fetch=FetchType.EAGER)
    private Tariff tariff;
    @OneToMany(cascade=CascadeType.ALL, fetch=FetchType.LAZY)
    private List<SessionData> sessionData;
    private Integer status = new Integer(0);
    private Long startTime = new Long(0);
    private Long endTime = new Long(0);
    private Double bill = new Double(0);
    private Boolean hasOpenRequest = new Boolean(false);
    
    public String getGeneratedId() {
            return generatedId;
    }
    public void setGeneratedId(String generatedId) {
            this.generatedId = generatedId;
    }
    public String getIP() {
            return IP;
    }
    public void setIP(String iP) {
            IP = iP;
    }
    public String getHostname() {
            return hostname;
    }
    public void setHostname(String hostname) {
            this.hostname = hostname;
    }
    public Tariff getTariff() {
            return tariff;
    }
    public void setTariff(Tariff tariff) {
            this.tariff = tariff;
    }
    public List<SessionData> getSessionData() {
        return sessionData;
    }
    public void setSessionData(List<SessionData> sessionData) {
        this.sessionData = sessionData;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public int getType() {
        return type;
    }
    public void setType(int type) {
        this.type = type;
    }
    public Integer getStatus() {
        return status;
    }
    public void setStatus(Integer status) {
        this.status = status;
    }
    public Long getEndTime() {
        return endTime;
    }
    public void setEndTime(Long endTime) {
        this.endTime = endTime;
    }
    public Long getStartTime() {
        return startTime;
    }
    public void setStartTime(Long startTime) {
        this.startTime = startTime;
    }

    public Double getBill() {
        return bill;
    }

    public void setBill(Double bill) {
        this.bill = bill;
    }

    public Boolean getHasOpenRequest() {
        return hasOpenRequest;
    }

    public void setHasOpenRequest(Boolean hasOpenRequest) {
        this.hasOpenRequest = hasOpenRequest;
    }
    
}
